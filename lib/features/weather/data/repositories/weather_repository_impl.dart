import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/forecast.dart';
import '../../domain/entities/location_info.dart';
import '../../domain/entities/weather.dart';
import '../../domain/repositories/weather_repository.dart';
import '../models/forecast_response_model.dart';
import '../models/weather_response_model.dart';
import '../sources/location_source.dart';
import '../sources/weather_remote_source.dart';

class WeatherRepositoryImpl implements WeatherRepository {
  final WeatherRemoteSource remoteSource;
  final LocationSource locationSource;

  WeatherRepositoryImpl({
    required this.remoteSource,
    required this.locationSource,
  });

  static const _cacheKey = 'cached_weather';
  static const _cacheTsKey = 'cached_weather_ts';

  @override
  Future<Weather> getWeather({
    required double latitude,
    required double longitude,
  }) async {
    try {
      final response = await remoteSource.fetchWeather(
        latitude: latitude,
        longitude: longitude,
      );
      await _cacheWeather(response);
      return response.toEntity();
    } catch (_) {
      final cached = await _getCachedWeather();
      if (cached != null) return cached;
      rethrow;
    }
  }

  @override
  Future<Forecast> getForecast({
    required double latitude,
    required double longitude,
  }) async {
    final cacheKey = 'cached_forecast_${latitude}_$longitude';
    final cacheTsKey = 'cached_forecast_ts_${latitude}_$longitude';

    try {
      final response = await remoteSource.fetchForecast(
        latitude: latitude,
        longitude: longitude,
      );
      await _cacheForecast(response, cacheKey, cacheTsKey);
      return response.toEntity();
    } catch (_) {
      final cached = await _getCachedForecast(cacheKey, cacheTsKey);
      if (cached != null) return cached;
      rethrow;
    }
  }

  @override
  Future<LocationInfo> getCurrentLocation() {
    return locationSource.getCurrentLocation();
  }

  Future<void> _cacheWeather(WeatherResponseModel model) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_cacheKey, jsonEncode(model.toJson()));
    await prefs.setInt(_cacheTsKey, DateTime.now().millisecondsSinceEpoch);
  }

  Future<Weather?> _getCachedWeather() async {
    final prefs = await SharedPreferences.getInstance();
    final cached = prefs.getString(_cacheKey);
    final ts = prefs.getInt(_cacheTsKey);

    if (cached == null || ts == null) return null;

    final age = DateTime.now().millisecondsSinceEpoch - ts;
    if (age > const Duration(hours: 2).inMilliseconds) return null;

    final json = jsonDecode(cached) as Map<String, dynamic>;
    return WeatherResponseModel.fromJson(json).toEntity();
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

  Future<Forecast?> _getCachedForecast(
    String cacheKey,
    String cacheTsKey,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final cached = prefs.getString(cacheKey);
    final ts = prefs.getInt(cacheTsKey);

    if (cached == null || ts == null) return null;

    final age = DateTime.now().millisecondsSinceEpoch - ts;
    if (age > const Duration(hours: 2).inMilliseconds) return null;

    final json = jsonDecode(cached) as Map<String, dynamic>;
    return ForecastResponseModel.fromJson(json).toEntity();
  }
}
