import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:home_widget/home_widget.dart';

import '../../features/weather/domain/entities/forecast.dart';
import '../../features/weather/domain/entities/location_info.dart';
import '../../features/weather/domain/entities/temperature_tier.dart';
import '../constants/background_gradients.dart';
import '../constants/persona.dart';

const _appGroupId = 'group.com.totms.heather';
const _iOSWidgetName = 'HeatherWeatherWidget';
const _dataKey = 'widget_data';

class WidgetService {
  WidgetService._();

  /// Broadcasts when the app is opened via a widget tap.
  static final widgetTapped = StreamController<void>.broadcast();

  static Future<void> init() async {
    await HomeWidget.setAppGroupId(_appGroupId);

    // Handle cold start from widget tap
    final initialUri = await HomeWidget.initiallyLaunchedFromHomeWidget();
    if (initialUri != null) {
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
    required Persona persona,
    required bool explicit,
  }) async {
    final current = forecast.current;
    final today = forecast.daily.first;
    final isDay = forecast.isCurrentlyDay;
    final tier = TemperatureTier.fromTemperature(current.temperature);
    final gradientColors = BackgroundGradients.forCondition(
      current.condition,
      tier,
      isDay: isDay,
    );

    final payload = jsonEncode({
      'temperature': current.temperature.round(),
      'feelsLike': current.feelsLike.round(),
      'high': today.temperatureMax.round(),
      'low': today.temperatureMin.round(),
      'conditionName': current.condition.name,
      'description': current.description,
      'isDay': isDay,
      'humidity': current.humidity,
      'windSpeed': current.windSpeed.round(),
      'uvIndex': current.uvIndex.round(),
      'quip': quip,
      'persona': persona.name,
      'cityName': location.cityName,
      'latitude': location.latitude,
      'longitude': location.longitude,
      'lastUpdated': DateTime.now().toIso8601String(),
      'gradientColors': gradientColors.map(_colorToHex).toList(),
      'hourly': forecast.hourly.take(8).map((h) => {
        'time': h.time.toIso8601String(),
        'temperature': h.temperature.round(),
        'weatherCode': h.weatherCode,
      }).toList(),
    });

    await HomeWidget.saveWidgetData<String>(_dataKey, payload);
    await _writeQuipMap(persona, explicit, isDay: isDay);
    await HomeWidget.updateWidget(iOSName: _iOSWidgetName);
  }

  static Future<void> _writeQuipMap(Persona persona, bool explicit, {required bool isDay}) async {
    final map = persona.quipMap(altTone: explicit, isDay: isDay);
    final json = map.map(
      (condition, tiers) => MapEntry(
        condition.name,
        tiers.map((tier, quips) => MapEntry(tier.name, quips)),
      ),
    );
    final payload = jsonEncode(json);
    await HomeWidget.saveWidgetData<String>('widget_quips', payload);
  }

  static String _colorToHex(Color color) {
    return '#${color.toARGB32().toRadixString(16).padLeft(8, '0').toUpperCase()}';
  }
}
