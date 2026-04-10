import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_client.dart';
import '../../domain/entities/air_quality.dart';

/// Round to 3 decimal places (~111m precision) to avoid GPS micro-drift
/// creating duplicate provider instances and cache entries.
({double lat, double lon}) _roundCoords(({double lat, double lon}) c) => (
  lat: (c.lat * 1000).roundToDouble() / 1000,
  lon: (c.lon * 1000).roundToDouble() / 1000,
);

final airQualityProvider = FutureProvider.autoDispose
    .family<AirQuality?, ({double lat, double lon})>((ref, rawCoords) async {
  final coords = _roundCoords(rawCoords);
  final prefs = ref.watch(sharedPreferencesProvider);
  final dio = ref.watch(dioProvider);
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
    final response = await dio.get(
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
