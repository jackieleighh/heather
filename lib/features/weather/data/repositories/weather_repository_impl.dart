import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/forecast.dart';
import '../../domain/entities/location_info.dart';
import '../../domain/entities/saved_location.dart';
import '../../domain/repositories/weather_repository.dart';
import '../models/forecast_response_model.dart';
import '../sources/location_source.dart';
import '../sources/weather_remote_source.dart';

class WeatherRepositoryImpl implements WeatherRepository {
  final WeatherRemoteSource remoteSource;
  final LocationSource locationSource;

  WeatherRepositoryImpl({
    required this.remoteSource,
    required this.locationSource,
  });

  @override
  Future<Forecast> getForecast({
    required double latitude,
    required double longitude,
    bool forceRefresh = false,
  }) async {
    final cacheKey = 'cached_forecast_${latitude}_$longitude';
    final cacheTsKey = 'cached_forecast_ts_${latitude}_$longitude';

    // Return fresh cache for automatic refreshes (timer/resume)
    if (!forceRefresh) {
      final fresh = await _getFreshCachedForecast(cacheKey, cacheTsKey);
      if (fresh != null) {
        // Track the key so readCachedWeather always points at the right entry
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('last_forecast_cache_key', cacheKey);
        await prefs.setString('last_forecast_cache_ts_key', cacheTsKey);
        return fresh;
      }
    }

    try {
      final response = await remoteSource.fetchForecast(
        latitude: latitude,
        longitude: longitude,
      );
      await _cacheForecast(response, cacheKey, cacheTsKey);
      // Track the exact key so readCachedWeather can find it
      // regardless of GPS coordinate drift between refreshes.
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('last_forecast_cache_key', cacheKey);
      await prefs.setString('last_forecast_cache_ts_key', cacheTsKey);
      return response.toEntity();
    } catch (_) {
      final cached = await _getCachedForecast(cacheKey, cacheTsKey);
      if (cached != null) return cached;
      rethrow;
    }
  }

  @override
  Future<Map<String, Forecast>> getForecastBatch({
    required List<({String id, double latitude, double longitude})> locations,
    bool forceRefresh = false,
  }) async {
    if (locations.isEmpty) return {};

    final results = <String, Forecast>{};
    final uncached = <({String id, double latitude, double longitude})>[];

    // Check fresh cache for each location individually
    if (!forceRefresh) {
      for (final loc in locations) {
        final cacheKey = 'cached_forecast_${loc.latitude}_${loc.longitude}';
        final cacheTsKey =
            'cached_forecast_ts_${loc.latitude}_${loc.longitude}';
        final fresh = await _getFreshCachedForecast(cacheKey, cacheTsKey);
        if (fresh != null) {
          results[loc.id] = fresh;
        } else {
          uncached.add(loc);
        }
      }
    } else {
      uncached.addAll(locations);
    }

    if (uncached.isEmpty) return results;

    try {
      final responses = await remoteSource.fetchForecastBatch(
        locations: uncached,
      );

      for (final loc in uncached) {
        final model = responses[loc.id];
        if (model != null) {
          final cacheKey = 'cached_forecast_${loc.latitude}_${loc.longitude}';
          final cacheTsKey =
              'cached_forecast_ts_${loc.latitude}_${loc.longitude}';
          await _cacheForecast(model, cacheKey, cacheTsKey);
          results[loc.id] = model.toEntity();
        }
      }
    } catch (_) {
      // Fall back to stale cache for any locations that failed
      for (final loc in uncached) {
        if (results.containsKey(loc.id)) continue;
        final cacheKey = 'cached_forecast_${loc.latitude}_${loc.longitude}';
        final cacheTsKey =
            'cached_forecast_ts_${loc.latitude}_${loc.longitude}';
        final cached = await _getCachedForecast(cacheKey, cacheTsKey);
        if (cached != null) {
          results[loc.id] = cached;
        }
      }
      if (results.length < locations.length) rethrow;
    }

    return results;
  }

  @override
  Future<LocationInfo> getCurrentLocation() {
    return locationSource.getCurrentLocation();
  }

  Future<void> _cacheForecast(
    ForecastResponseModel model,
    String cacheKey,
    String cacheTsKey,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(cacheKey, jsonEncode(model.toJson()));
    await prefs.setInt(cacheTsKey, DateTime.now().millisecondsSinceEpoch);
  }

  Future<Forecast?> _getFreshCachedForecast(
    String cacheKey,
    String cacheTsKey,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final cached = prefs.getString(cacheKey);
    final ts = prefs.getInt(cacheTsKey);

    if (cached == null || ts == null) return null;

    final age = DateTime.now().millisecondsSinceEpoch - ts;
    if (age > const Duration(minutes: 16).inMilliseconds) return null;

    final json = jsonDecode(cached) as Map<String, dynamic>;
    return ForecastResponseModel.fromJson(json).toEntity();
  }

  /// Synchronously reads cached [LocationInfo] + [Forecast] from an
  /// already-resolved [SharedPreferences] instance.
  /// Returns null if either is missing. No TTL — the background refresh()
  /// will update stale data after the UI renders.
  static (LocationInfo, Forecast)? readCachedWeather(SharedPreferences prefs) {
    final cityName = prefs.getString('last_city_name');
    final lat = prefs.getDouble('last_city_lat');
    final lon = prefs.getDouble('last_city_lon');
    if (cityName == null || lat == null || lon == null) return null;

    // Use stored key (immune to GPS coordinate drift between refreshes)
    final cacheKey = prefs.getString('last_forecast_cache_key');
    final cacheTsKey = prefs.getString('last_forecast_cache_ts_key');
    if (cacheKey == null || cacheTsKey == null) return null;

    final cached = prefs.getString(cacheKey);
    if (cached == null) return null;

    try {
      final json = jsonDecode(cached) as Map<String, dynamic>;
      final forecast = ForecastResponseModel.fromJson(json).toEntity();
      final countryCode = prefs.getString('last_country_code');
      final location = LocationInfo(
        latitude: lat,
        longitude: lon,
        cityName: cityName,
        countryCode: countryCode,
      );
      return (location, forecast);
    } catch (_) {
      return null;
    }
  }

  /// Synchronously reads cached forecasts for a list of saved locations
  /// from an already-resolved [SharedPreferences]. No TTL check.
  static Map<String, Forecast> readCachedSavedForecasts(
    SharedPreferences prefs,
    List<SavedLocation> locations,
  ) {
    final results = <String, Forecast>{};
    for (final loc in locations) {
      final cacheKey = 'cached_forecast_${loc.latitude}_${loc.longitude}';
      final cached = prefs.getString(cacheKey);
      if (cached == null) continue;
      try {
        final json = jsonDecode(cached) as Map<String, dynamic>;
        results[loc.id] = ForecastResponseModel.fromJson(json).toEntity();
      } catch (_) {}
    }
    return results;
  }

  Future<Forecast?> _getCachedForecast(
    String cacheKey,
    String cacheTsKey,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final cached = prefs.getString(cacheKey);
    final ts = prefs.getInt(cacheTsKey);

    if (cached == null || ts == null) return null;

    final age = DateTime.now().millisecondsSinceEpoch - ts;
    if (age > const Duration(hours: 12).inMilliseconds) return null;

    final json = jsonDecode(cached) as Map<String, dynamic>;
    return ForecastResponseModel.fromJson(json).toEntity();
  }
}
