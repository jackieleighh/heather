import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:geocoding/geocoding.dart' as geocoding;
import 'package:geolocator/geolocator.dart';
import 'package:home_widget/home_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';

import '../../features/weather/data/models/forecast_response_model.dart';
import '../../features/weather/domain/entities/temperature_tier.dart';
import '../constants/api_endpoints.dart';
import '../constants/persona.dart';
import '../utils/geo_utils.dart';
import 'widget_payload_builder.dart';

const _taskName = 'com.totms.heather.alertCheck';
const _locationsKey = 'bg_alert_locations';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    if (task == _taskName || task == Workmanager.iOSBackgroundTask) {
      await _refreshWidgetData();
      // iOS doesn't support periodic tasks — re-schedule a one-off
      if (!Platform.isAndroid) {
        await Workmanager().registerOneOffTask(
          _taskName,
          _taskName,
          initialDelay: const Duration(minutes: 15),
          constraints: Constraints(networkType: NetworkType.connected),
          existingWorkPolicy: ExistingWorkPolicy.replace,
        );
      }
    }
    return true;
  });
}

const _appGroupId = 'group.com.totms.heather';
const _iOSWidgetName = 'HeatherWeatherWidget';
const _androidWidgetName = 'HeatherWidgetReceiver';
const _widgetDataKey = 'widget_data';

Future<void> _refreshWidgetData() async {
  try {
    await HomeWidget.setAppGroupId(_appGroupId);

    // Read existing widget data to get stored location as fallback
    final existingJson =
        await HomeWidget.getWidgetData<String>(_widgetDataKey);
    if (existingJson == null) return;

    final existing = jsonDecode(existingJson) as Map<String, dynamic>;
    final storedLat = existing['latitude'] as double?;
    final storedLon = existing['longitude'] as double?;
    final storedCity = existing['cityName'] as String?;
    if (storedLat == null || storedLon == null || storedCity == null) return;

    var lat = storedLat;
    var lon = storedLon;
    var cityName = storedCity;

    // Try to refresh location from system cache (no GPS activation)
    try {
      final position = await Geolocator.getLastKnownPosition();
      if (position != null) {
        lat = position.latitude;
        lon = position.longitude;
        try {
          final placemarks = await geocoding.placemarkFromCoordinates(lat, lon);
          if (placemarks.isNotEmpty) {
            final place = placemarks.first;
            cityName = place.locality?.isNotEmpty == true
                ? place.locality!
                : place.subAdministrativeArea ??
                    place.administrativeArea ??
                    cityName;
          }
        } catch (_) {
          // Keep existing cityName if reverse geocoding fails
        }
      }
    } catch (_) {
      // Keep stored location on any failure (permission denied, etc.)
    }

    // Read explicit language preference
    final prefs = await SharedPreferences.getInstance();
    final explicit = prefs.getBool('explicit_language') ?? true;

    // Try foreground cache first (shared via SharedPreferences)
    final cacheKey = 'cached_forecast_${lat}_$lon';
    final cacheTsKey = 'cached_forecast_ts_${lat}_$lon';
    final cachedJson = prefs.getString(cacheKey);
    final cachedTs = prefs.getInt(cacheTsKey);

    ForecastResponseModel forecastModel;
    if (cachedJson != null &&
        cachedTs != null &&
        DateTime.now().millisecondsSinceEpoch - cachedTs <
            const Duration(minutes: 5).inMilliseconds) {
      // Cache is <5 min old — reuse foreground data
      forecastModel = ForecastResponseModel.fromJson(
          jsonDecode(cachedJson) as Map<String, dynamic>);
    } else {
      // Cache is stale or missing — fetch from API
      final dio = Dio();
      final response = await dio.get(
        ApiEndpoints.forecast(latitude: lat, longitude: lon),
        options: Options(
          receiveTimeout: const Duration(seconds: 15),
          sendTimeout: const Duration(seconds: 15),
        ),
      );
      dio.close();
      forecastModel =
          ForecastResponseModel.fromJson(response.data as Map<String, dynamic>);

      // Write back to shared cache so foreground benefits too
      await prefs.setString(cacheKey, jsonEncode(forecastModel.toJson()));
      await prefs.setInt(
          cacheTsKey, DateTime.now().millisecondsSinceEpoch);
    }

    // Update pointer keys so readCachedWeather() always finds the freshest
    // data, regardless of GPS coordinate drift between refreshes.
    await prefs.setString('last_forecast_cache_key', cacheKey);
    await prefs.setString('last_forecast_cache_ts_key', cacheTsKey);
    await prefs.setString('last_city_name', cityName);
    await prefs.setDouble('last_city_lat', lat);
    await prefs.setDouble('last_city_lon', lon);

    final forecast = forecastModel.toEntity();

    final current = forecast.current;
    final isDay = forecast.isCurrentlyDay;
    final tier = TemperatureTier.fromTemperature(current.temperature);

    // Pick a random quip
    final quipMap = heatherQuipMap(altTone: explicit, isDay: isDay);
    final quips = quipMap[current.condition]?[tier] ?? ['Stay cozy.'];
    final quip = quips[Random().nextInt(quips.length)];

    // Compute alert label and severity from NWS alerts (all severities)
    String? alertLabel;
    String? alertSeverity;
    if (isInUSBounds(lat, lon)) {
      try {
        final alertDio = Dio();
        final alertResponse = await alertDio.get(
          ApiEndpoints.nwsAlerts(latitude: lat, longitude: lon),
          options: Options(
            headers: {
              'User-Agent': '(Heather Weather App)',
              'Accept': 'application/geo+json',
            },
            receiveTimeout: const Duration(seconds: 10),
            sendTimeout: const Duration(seconds: 10),
          ),
        );
        alertDio.close();
        final alertData = alertResponse.data as Map<String, dynamic>;
        final features = alertData['features'] as List<dynamic>? ?? [];
        final now = DateTime.now();
        int bestSortOrder = 999;

        for (final feature in features) {
          final props = feature['properties'] as Map<String, dynamic>;
          final expires = DateTime.tryParse(props['expires'] as String? ?? '');
          if (expires != null && expires.isBefore(now)) continue;

          final severityStr = (props['severity'] as String? ?? '').toLowerCase();
          final sortOrder = switch (severityStr) {
            'extreme' => 0,
            'severe' => 1,
            'moderate' => 2,
            'minor' => 3,
            _ => 4,
          };

          if (sortOrder < bestSortOrder) {
            bestSortOrder = sortOrder;
            alertLabel = '\u26A0 ${props['event'] as String? ?? 'Weather Alert'}';
            alertSeverity = severityStr;
            if (sortOrder == 0) break; // can't get more severe
          }
        }
      } catch (e) {
        if (kDebugMode) print('Widget alert fetch failed: $e');
      }
    }

    // Read cached USNO moon data
    String? moonPhase;
    int? moonIllum;
    try {
      final moonCacheKey = 'cached_moon_${lat}_$lon';
      final cachedMoonJson = prefs.getString(moonCacheKey);
      if (cachedMoonJson != null) {
        final moonData =
            jsonDecode(cachedMoonJson) as Map<String, dynamic>;
        moonPhase = moonData['curPhase'] as String?;
        final fracVal = moonData['fracIllum'];
        if (fracVal is num) {
          moonIllum = fracVal.round();
        }
      }
    } catch (_) {}

    final payload = buildWidgetPayload(
      forecast: forecast,
      cityName: cityName,
      latitude: lat,
      longitude: lon,
      quip: quip,
      alertLabel: alertLabel,
      alertSeverity: alertSeverity,
      moonPhase: moonPhase,
      moonIllumination: moonIllum,
    );

    await HomeWidget.saveWidgetData<String>(_widgetDataKey, payload);

    // Write quip map for native widget random selection
    final map = heatherQuipMap(altTone: explicit, isDay: isDay);
    final quipJson = map.map(
      (condition, tiers) => MapEntry(
        condition.name,
        tiers.map((tier, quips) => MapEntry(tier.name, quips)),
      ),
    );
    await HomeWidget.saveWidgetData<String>(
        'widget_quips', jsonEncode(quipJson));

    await HomeWidget.updateWidget(
      iOSName: _iOSWidgetName,
      androidName: _androidWidgetName,
    );
  } catch (e) {
    if (kDebugMode) print('Widget refresh failed: $e');
  }
}

class BackgroundAlertService {
  BackgroundAlertService._();

  static Future<void> init() async {
    try {
      await Workmanager().initialize(callbackDispatcher);
    } catch (e) {
      if (kDebugMode) {
        print('WorkManager init failed: $e');
      }
    }
  }

  static Future<void> registerPeriodicCheck() async {
    try {
      if (Platform.isAndroid) {
        await Workmanager().registerPeriodicTask(
          _taskName,
          _taskName,
          frequency: const Duration(minutes: 15),
          constraints: Constraints(networkType: NetworkType.connected),
          existingWorkPolicy: ExistingPeriodicWorkPolicy.replace,
        );
      } else {
        await Workmanager().registerOneOffTask(
          _taskName,
          _taskName,
          initialDelay: const Duration(minutes: 15),
          constraints: Constraints(networkType: NetworkType.connected),
          existingWorkPolicy: ExistingWorkPolicy.replace,
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('WorkManager task registration failed: $e');
      }
    }
  }

  static Future<void> cancelPeriodicCheck() async {
    try {
      await Workmanager().cancelByUniqueName(_taskName);
    } catch (e) {
      if (kDebugMode) {
        print('WorkManager task cancellation failed: $e');
      }
    }
  }

  static Future<void> updateLocations(
    List<Map<String, dynamic>> locations,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_locationsKey, jsonEncode(locations));
  }
}
