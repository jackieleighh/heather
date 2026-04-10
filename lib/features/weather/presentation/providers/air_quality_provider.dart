import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../../domain/entities/air_quality.dart';

final airQualityProvider =
    FutureProvider.family<AirQuality?, ({double lat, double lon})>((ref, coords) async {
  final prefs = await SharedPreferences.getInstance();
  final cacheKey = 'cached_aqi_json_${coords.lat}_${coords.lon}';
  final cacheTsKey = 'cached_aqi_ts_${coords.lat}_${coords.lon}';

  final cachedJson = prefs.getString(cacheKey);
  final cachedTs = prefs.getInt(cacheTsKey);

  AirQuality? fromCache;
  if (cachedJson != null) {
    fromCache = _parseAirQuality(jsonDecode(cachedJson) as Map<String, dynamic>);
  }

  // Return cached value if <30 min old
  if (fromCache != null && cachedTs != null) {
    final age = DateTime.now().millisecondsSinceEpoch - cachedTs;
    if (age < const Duration(minutes: 30).inMilliseconds) {
      return fromCache;
    }
  }

  try {
    final response = await Dio().get(
      ApiEndpoints.airQuality(
        latitude: coords.lat,
        longitude: coords.lon,
      ),
    );
    final data = response.data as Map<String, dynamic>;
    final current = data['current'] as Map<String, dynamic>;
    final result = _parseAirQuality(current);

    // Cache the full current map as JSON
    await prefs.setString(cacheKey, jsonEncode(current));
    await prefs.setInt(cacheTsKey, DateTime.now().millisecondsSinceEpoch);

    return result;
  } catch (_) {
    // Return stale cache on failure instead of null
    return fromCache;
  }
});

AirQuality _parseAirQuality(Map<String, dynamic> current) {
  return AirQuality(
    aqi: (current['us_aqi'] as num).toInt(),
    pm25: (current['pm2_5'] as num?)?.toDouble(),
    pm10: (current['pm10'] as num?)?.toDouble(),
    ozone: (current['ozone'] as num?)?.toDouble(),
    no2: (current['nitrogen_dioxide'] as num?)?.toDouble(),
    so2: (current['sulphur_dioxide'] as num?)?.toDouble(),
    co: (current['carbon_monoxide'] as num?)?.toDouble(),
  );
}
