import 'dart:async';
import 'dart:convert';

import 'package:home_widget/home_widget.dart';

import '../../features/weather/domain/entities/forecast.dart';
import '../../features/weather/domain/entities/location_info.dart';
import '../../features/weather/domain/entities/weather_alert.dart';
import '../constants/persona.dart';
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

  static Future<void> init() async {
    await HomeWidget.setAppGroupId(_appGroupId);

    // Handle cold start from widget tap
    final initialUri = await HomeWidget.initiallyLaunchedFromHomeWidget();
    if (initialUri != null) {
      coldLaunchedFromWidget = true;
      widgetTapped.add(null);
    }

    // Handle warm start (app resumed from background via widget tap)
    HomeWidget.widgetClicked.listen((_) {
      widgetTapped.add(null);
    });
  }

  static Future<void> updateWidget({
    required Forecast forecast,
    required LocationInfo location,
    required String quip,
    required bool explicit,
    List<WeatherAlert> alerts = const [],
  }) async {
    // Compute alert label and severity from the most severe extreme/severe alert
    String? alertLabel;
    String? alertSeverity;
    for (final alert in alerts) {
      if (alert.severity == AlertSeverity.extreme ||
          alert.severity == AlertSeverity.severe) {
        alertLabel = '\u26A0 ${alert.event}';
        alertSeverity = alert.severity.name;
        break; // alerts are pre-sorted by severity
      }
    }

    final payload = buildWidgetPayload(
      forecast: forecast,
      cityName: location.cityName,
      latitude: location.latitude,
      longitude: location.longitude,
      quip: quip,
      alertLabel: alertLabel,
      alertSeverity: alertSeverity,
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
