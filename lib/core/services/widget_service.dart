import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:home_widget/home_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/weather/domain/entities/forecast.dart';
import '../../features/weather/domain/entities/location_info.dart';
import '../../features/weather/domain/entities/weather.dart';
import '../../features/weather/domain/entities/weather_alert.dart';
import '../../features/weather/domain/entities/weather_condition.dart';
import '../../features/weather/presentation/providers/moon_data_provider.dart';
import '../constants/persona.dart';
import '../constants/weather_codes.dart';
import 'widget_payload_builder.dart';

const _appGroupId = 'group.com.totms.heather';
const _iOSWidgetName = 'HeatherWeatherWidget';
const _androidWidgetName = 'widget.HeatherWidgetReceiver';
const _dataKey = 'widget_data';

class WidgetService {
  WidgetService._();

  /// Broadcasts when the app is opened via a widget tap.
  static final widgetTapped = StreamController<void>.broadcast();

  /// True when the app was cold-started from a home screen widget tap.
  /// Read by WeatherScreen and WeatherNotifier to skip the loading screen.
  static bool coldLaunchedFromWidget = false;

  /// Coordinates from the widget's cached data, set during cold launch so
  /// the app can seed its initial view with the same data the widget shows.
  static double? widgetLatitude;
  static double? widgetLongitude;
  static String? widgetCityName;

  /// The widget cache's lastUpdated timestamp, read on every launch so the
  /// app can detect when the native widget has fetched fresher data than the
  /// app's own SharedPreferences cache.
  static DateTime? widgetLastUpdated;

  /// True when the widget's cached data is newer than the app's own forecast
  /// cache. Set by main.dart after comparing timestamps.
  static bool widgetDataIsNewer = false;

  /// Full parsed widget_data JSON, stored so applyWidgetOverlay() can
  /// merge the widget's fresh conditions into the app's cached forecast.
  static Map<String, dynamic>? _widgetData;

  static Future<void> init() async {
    await HomeWidget.setAppGroupId(_appGroupId);

    // Handle cold start from widget tap
    final initialUri = await HomeWidget.initiallyLaunchedFromHomeWidget();
    if (initialUri != null) {
      coldLaunchedFromWidget = true;
      widgetTapped.add(null);
    } else {
      // Fallback: check native flag written by AppDelegate
      final nativeFlag =
          await HomeWidget.getWidgetData<bool>('widget_cold_launch');
      if (nativeFlag == true) {
        coldLaunchedFromWidget = true;
        widgetTapped.add(null);
      }
    }
    // Always clear the native flag so normal launches aren't affected
    await HomeWidget.saveWidgetData<bool>('widget_cold_launch', null);

    // Always read widget data so we can detect when the native widget
    // (iOS WidgetKit) has independently fetched fresher weather data.
    try {
      final json = await HomeWidget.getWidgetData<String>(_dataKey);
      if (json != null) {
        final data = jsonDecode(json) as Map<String, dynamic>;
        _widgetData = data;
        final lastUpdatedStr = data['lastUpdated'] as String?;
        if (lastUpdatedStr != null) {
          widgetLastUpdated = DateTime.tryParse(lastUpdatedStr);
        }
        if (coldLaunchedFromWidget) {
          widgetLatitude = (data['latitude'] as num?)?.toDouble();
          widgetLongitude = (data['longitude'] as num?)?.toDouble();
          widgetCityName = data['cityName'] as String?;
        }
      }
    } catch (_) {}

    // Handle warm start (app resumed from background via widget tap)
    HomeWidget.widgetClicked.listen((_) {
      widgetTapped.add(null);
    });
  }

  /// Overlays the widget's fresh current-weather data onto an existing cached
  /// forecast seed. If [base] is null (no cached forecast), builds a
  /// standalone seed from the widget data alone.
  ///
  /// This preserves the full 10-day/24-hour forecast structure from the cache
  /// while updating the current conditions (temperature, condition, etc.) to
  /// match what the widget is currently displaying.
  static (LocationInfo, Forecast)? applyWidgetOverlay(
    (LocationInfo, Forecast)? base,
  ) {
    final data = _widgetData;
    if (data == null) {
      if (kDebugMode) debugPrint('[widgetSeed] _widgetData is null');
      return base;
    }

    try {
      // Parse the widget's current condition
      final conditionName = data['conditionName'] as String? ?? '';
      final condition = WeatherCondition.values.firstWhere(
        (e) => e.name == conditionName,
        orElse: () => WeatherCondition.unknown,
      );
      final wmoCode = WeatherCodes.canonicalWmoCode[condition] ?? 0;
      final isDay = data['isDay'] as bool? ?? true;

      // Build the fresh current Weather from widget data
      final widgetCurrent = Weather(
        temperature: (data['temperature'] as num?)?.toDouble() ?? 0,
        feelsLike: (data['feelsLike'] as num?)?.toDouble() ?? 0,
        humidity: (data['humidity'] as num?)?.toInt() ?? 0,
        windSpeed: (data['windSpeed'] as num?)?.toDouble() ?? 0,
        weatherCode: wmoCode,
        condition: condition,
        description: data['description'] as String? ?? '',
        isDay: isDay,
        precipitation: base?.$2.current.precipitation ?? 0,
        cloudCover: base?.$2.current.cloudCover ?? 0,
        uvIndex: (data['uvIndex'] as num?)?.toDouble() ?? 0,
        dewPoint: base?.$2.current.dewPoint ?? 0,
        visibility: base?.$2.current.visibility ?? 0,
        pressure: base?.$2.current.pressure ?? 0,
        windGusts: base?.$2.current.windGusts ?? 0,
        windDirection: base?.$2.current.windDirection ?? 0,
      );

      final widgetCity = data['cityName'] as String?;
      final widgetLat = (data['latitude'] as num?)?.toDouble();
      final widgetLon = (data['longitude'] as num?)?.toDouble();

      if (base != null) {
        // Merge: keep the full cached forecast but swap in the widget's
        // current conditions so the temperature/condition match the widget.
        final (baseLocation, baseForecast) = base;
        final merged = baseForecast.copyWith(current: widgetCurrent);
        final location = baseLocation.copyWith(
          cityName: widgetCity ?? baseLocation.cityName,
        );

        if (kDebugMode) {
          debugPrint('[widgetSeed] MERGED: ${widgetCurrent.temperature}° '
              '${condition.name} onto cached forecast '
              '(daily=${baseForecast.daily.length}, '
              'hourly=${baseForecast.hourly.length})');
        }
        return (location, merged);
      }

      // No cached forecast — build a minimal standalone seed.
      // This is a fallback; the force-refresh will replace it quickly.
      final utcOffset = (data['utcOffsetSeconds'] as num?)?.toInt() ?? 0;
      final forecast = Forecast(
        current: widgetCurrent,
        hourly: const [],
        daily: const [],
        utcOffsetSeconds: utcOffset,
      );
      final location = LocationInfo(
        latitude: widgetLat ?? 0,
        longitude: widgetLon ?? 0,
        cityName: widgetCity ?? '',
      );

      if (kDebugMode) {
        debugPrint('[widgetSeed] STANDALONE: ${widgetCurrent.temperature}° '
            '${condition.name}, city=${location.cityName}');
      }
      return (location, forecast);
    } catch (e, st) {
      if (kDebugMode) debugPrint('[widgetSeed] FAILED: $e\n$st');
      return base;
    }
  }

  static Future<void> updateWidget({
    required Forecast forecast,
    required LocationInfo location,
    required String quip,
    required bool explicit,
    List<WeatherAlert> alerts = const [],
    List<String> visiblePlanets = const [],
  }) async {
    // Compute alert label and severity from the most severe alert
    String? alertLabel;
    String? alertSeverity;
    if (alerts.isNotEmpty) {
      final alert = alerts.first; // alerts are pre-sorted by severity
      alertLabel = '\u26A0 ${alert.event}';
      alertSeverity = alert.severity.name;
    }

    // Read cached USNO moon data and interpolate illumination for "now"
    // so the widget value matches what's shown in-app.
    String? moonPhase;
    int? moonIllum;
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheKey =
          'cached_moon_${location.latitude}_${location.longitude}';
      final cachedJson = prefs.getString(cacheKey);
      if (cachedJson != null) {
        final moonData = UsnoMoonData.fromJson(
          jsonDecode(cachedJson) as Map<String, dynamic>,
        );
        moonPhase = moonData.curPhase;
        moonIllum = moonData.illuminationForDate(DateTime.now()).round();
      }
    } catch (_) {}

    final payload = buildWidgetPayload(
      forecast: forecast,
      cityName: location.cityName,
      latitude: location.latitude,
      longitude: location.longitude,
      quip: quip,
      alertLabel: alertLabel,
      alertSeverity: alertSeverity,
      visiblePlanets: visiblePlanets,
      moonPhase: moonPhase,
      moonIllumination: moonIllum,
    );

    await HomeWidget.saveWidgetData<String>(_dataKey, payload);
    await _writeQuipMap(explicit, isDay: forecast.isCurrentlyDay);
    await HomeWidget.updateWidget(
      iOSName: _iOSWidgetName,
      androidName: _androidWidgetName,
    );
  }

  static Future<void> _writeQuipMap(bool explicit, {required bool isDay}) async {
    final map = heatherQuipMap(altTone: explicit, isDay: isDay);
    final json = map.map(
      (condition, tiers) => MapEntry(
        condition.name,
        tiers.map((tier, quips) => MapEntry(tier.name, quips)),
      ),
    );
    final payload = jsonEncode(json);
    await HomeWidget.saveWidgetData<String>('widget_quips', payload);
  }
}
