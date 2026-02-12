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

  static Future<void> init() async {
    await HomeWidget.setAppGroupId(_appGroupId);
  }

  static Future<void> updateWidget({
    required Forecast forecast,
    required LocationInfo location,
    required String quip,
    required Persona persona,
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
      'quip': quip,
      'persona': persona.name,
      'cityName': location.cityName,
      'lastUpdated': DateTime.now().toIso8601String(),
      'gradientColors': gradientColors.map(_colorToHex).toList(),
    });

    await HomeWidget.saveWidgetData<String>(_dataKey, payload);
    await HomeWidget.updateWidget(iOSName: _iOSWidgetName);
  }

  static String _colorToHex(Color color) {
    return '#${color.toARGB32().toRadixString(16).padLeft(8, '0').toUpperCase()}';
  }
}
