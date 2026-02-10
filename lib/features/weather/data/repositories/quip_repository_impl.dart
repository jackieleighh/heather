import 'dart:math';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/storage/secure_storage.dart';
import '../../domain/entities/temperature_tier.dart';
import '../../domain/entities/weather.dart';
import '../../domain/repositories/quip_repository.dart';
import '../sources/quip_remote_source.dart';

class QuipRepositoryImpl implements QuipRepository {
  final QuipRemoteSource remoteSource;
  final SecureStorage secureStorage;
  final Random _random = Random();

  static const _cachedQuipKey = 'cached_quip';
  static const _cachedConditionKey = 'cached_quip_condition';
  static const _cachedTempKey = 'cached_quip_temp';
  static const _cachedExplicitKey = 'cached_quip_explicit';

  QuipRepositoryImpl({required this.remoteSource, required this.secureStorage});

  @override
  Future<String> getQuip({
    required Weather weather,
    required String cityName,
    bool explicit = false,
  }) async {
    final cached = await _getCachedQuip(weather, explicit);
    if (cached != null) return cached;

    final apiKey = await secureStorage.getGeminiKey();
    if (apiKey != null && apiKey.isNotEmpty) {
      try {
        final quip = await remoteSource.fetchQuip(
          weather: weather,
          cityName: cityName,
          apiKey: apiKey,
          explicit: explicit,
        );
        await _cacheQuip(quip, weather, explicit);
        return quip;
      } catch (_) {
        // Fall through to local quips
      }
    }

    return _getLocalQuip(weather, explicit);
  }

  String _getLocalQuip(Weather weather, bool explicit) {
    final condition = weather.condition;
    final tier = TemperatureTier.fromTemperature(weather.temperature);
    final quipMap = explicit ? AppStrings.explicitQuips : AppStrings.quips;

    final quips =
        quipMap[condition]?[tier] ??
        quipMap[condition]?[TemperatureTier.shortsWeather] ??
        quipMap.values.first.values.first;
    return quips[_random.nextInt(quips.length)];
  }

  Future<void> _cacheQuip(String quip, Weather weather, bool explicit) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_cachedQuipKey, quip);
    await prefs.setString(_cachedConditionKey, weather.condition.name);
    await prefs.setInt(_cachedTempKey, weather.temperature.round());
    await prefs.setBool(_cachedExplicitKey, explicit);
  }

  Future<String?> _getCachedQuip(Weather weather, bool explicit) async {
    final prefs = await SharedPreferences.getInstance();
    final cached = prefs.getString(_cachedQuipKey);
    final condition = prefs.getString(_cachedConditionKey);
    final temp = prefs.getInt(_cachedTempKey);
    final cachedExplicit = prefs.getBool(_cachedExplicitKey) ?? false;

    if (cached == null || condition == null || temp == null) return null;

    // Invalidate if explicit setting changed
    if (cachedExplicit != explicit) return null;

    final oldTier = TemperatureTier.fromTemperature(temp.toDouble());
    final newTier = TemperatureTier.fromTemperature(weather.temperature);

    if (condition == weather.condition.name && oldTier == newTier) {
      return cached;
    }
    return null;
  }
}
