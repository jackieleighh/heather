import 'dart:math';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/storage/secure_storage.dart';
import '../../domain/entities/weather.dart';
import '../../domain/entities/weather_condition.dart';
import '../../domain/repositories/quip_repository.dart';
import '../sources/quip_remote_source.dart';

class QuipRepositoryImpl implements QuipRepository {
  final QuipRemoteSource remoteSource;
  final SecureStorage secureStorage;
  final Random _random = Random();

  static const _cachedQuipKey = 'cached_quip';
  static const _cachedConditionKey = 'cached_quip_condition';
  static const _cachedTempKey = 'cached_quip_temp';

  QuipRepositoryImpl({required this.remoteSource, required this.secureStorage});

  @override
  Future<String> getQuip({
    required Weather weather,
    required String cityName,
  }) async {
    final cached = await _getCachedQuip(weather);
    if (cached != null) return cached;

    final apiKey = await secureStorage.getGeminiKey();
    if (apiKey != null && apiKey.isNotEmpty) {
      try {
        final quip = await remoteSource.fetchQuip(
          weather: weather,
          cityName: cityName,
          apiKey: apiKey,
        );
        await _cacheQuip(quip, weather);
        return quip;
      } catch (_) {
        // Fall through to local quips
      }
    }

    return _getLocalQuip(weather);
  }

  String _getLocalQuip(Weather weather) {
    if (weather.temperature >= 90) {
      return AppStrings.hotQuips[_random.nextInt(AppStrings.hotQuips.length)];
    }
    if (weather.temperature <= 32) {
      return AppStrings.coldQuips[_random.nextInt(AppStrings.coldQuips.length)];
    }
    final quips =
        AppStrings.fallbackQuips[weather.condition] ??
        AppStrings.fallbackQuips[WeatherCondition.clear]!;
    return quips[_random.nextInt(quips.length)];
  }

  Future<void> _cacheQuip(String quip, Weather weather) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_cachedQuipKey, quip);
    await prefs.setString(_cachedConditionKey, weather.condition.name);
    await prefs.setInt(_cachedTempKey, weather.temperature.round());
  }

  Future<String?> _getCachedQuip(Weather weather) async {
    final prefs = await SharedPreferences.getInstance();
    final cached = prefs.getString(_cachedQuipKey);
    final condition = prefs.getString(_cachedConditionKey);
    final temp = prefs.getInt(_cachedTempKey);

    if (cached == null || condition == null || temp == null) return null;

    if (condition == weather.condition.name &&
        (temp - weather.temperature.round()).abs() < 3) {
      return cached;
    }
    return null;
  }
}
