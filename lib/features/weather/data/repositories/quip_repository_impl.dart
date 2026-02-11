import 'dart:math';

import 'package:flutter/foundation.dart';
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

  QuipRepositoryImpl({required this.remoteSource, required this.secureStorage});

  @override
  String getLocalQuip({required Weather weather, bool explicit = false}) {
    return _pickLocalQuip(weather, explicit);
  }

  @override
  Future<Map<String, String>> getBatchQuips({
    required List<({Weather weather, String cityName})> locations,
    bool explicit = false,
  }) async {
    final results = <String, String>{};
    final uncached = <({Weather weather, String cityName})>[];

    // Check per-location cache
    for (final loc in locations) {
      final cached = await _getCachedQuip(loc.cityName, loc.weather, explicit);
      if (cached != null) {
        results[loc.cityName] = cached;
      } else {
        uncached.add(loc);
      }
    }

    if (uncached.isEmpty) return results;

    // Try batch Gemini call for uncached locations
    final apiKey = await secureStorage.getGeminiKey();
    if (apiKey != null && apiKey.isNotEmpty) {
      try {
        final quips = await remoteSource.fetchBatchQuips(
          locations: uncached,
          apiKey: apiKey,
          explicit: explicit,
        );
        for (var i = 0; i < uncached.length; i++) {
          final cityName = uncached[i].cityName;
          results[cityName] = quips[i];
          await _cacheQuip(cityName, quips[i], uncached[i].weather, explicit);
        }
        return results;
      } catch (e) {
        debugPrint('Gemini batch quip failed: $e');
      }
    } else {
      debugPrint('Gemini API key missing from secure storage');
    }

    // Local fallback for anything still missing
    for (final loc in uncached) {
      results[loc.cityName] = _pickLocalQuip(loc.weather, explicit);
    }
    return results;
  }

  String _pickLocalQuip(Weather weather, bool explicit) {
    final condition = weather.condition;
    final tier = TemperatureTier.fromTemperature(weather.temperature);
    final quipMap = explicit ? AppStrings.explicitQuips : AppStrings.quips;

    final quips =
        quipMap[condition]?[tier] ??
        quipMap[condition]?[TemperatureTier.shortsWeather] ??
        quipMap.values.first.values.first;
    return quips[_random.nextInt(quips.length)];
  }

  // ── Per-location caching ──────────────────────────────────────────

  String _quipKey(String city) => 'cached_quip_$city';
  String _conditionKey(String city) => 'cached_quip_condition_$city';
  String _tempKey(String city) => 'cached_quip_temp_$city';
  String _explicitKey(String city) => 'cached_quip_explicit_$city';

  Future<void> _cacheQuip(
    String cityName,
    String quip,
    Weather weather,
    bool explicit,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_quipKey(cityName), quip);
    await prefs.setString(_conditionKey(cityName), weather.condition.name);
    await prefs.setInt(_tempKey(cityName), weather.temperature.round());
    await prefs.setBool(_explicitKey(cityName), explicit);
  }

  Future<String?> _getCachedQuip(
    String cityName,
    Weather weather,
    bool explicit,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final cached = prefs.getString(_quipKey(cityName));
    final condition = prefs.getString(_conditionKey(cityName));
    final temp = prefs.getInt(_tempKey(cityName));
    final cachedExplicit = prefs.getBool(_explicitKey(cityName)) ?? false;

    if (cached == null || condition == null || temp == null) return null;
    if (cachedExplicit != explicit) return null;

    final oldTier = TemperatureTier.fromTemperature(temp.toDouble());
    final newTier = TemperatureTier.fromTemperature(weather.temperature);

    if (condition == weather.condition.name && oldTier == newTier) {
      return cached;
    }
    return null;
  }
}
