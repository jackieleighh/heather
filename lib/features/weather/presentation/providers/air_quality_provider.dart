import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/constants/api_endpoints.dart';

final airQualityProvider =
    FutureProvider.family<int?, ({double lat, double lon})>((ref, coords) async {
  final prefs = await SharedPreferences.getInstance();
  final cacheKey = 'cached_aqi_${coords.lat}_${coords.lon}';
  final cacheTsKey = 'cached_aqi_ts_${coords.lat}_${coords.lon}';

  final cachedAqi = prefs.getInt(cacheKey);
  final cachedTs = prefs.getInt(cacheTsKey);

  // Return cached value if <30 min old
  if (cachedAqi != null && cachedTs != null) {
    final age = DateTime.now().millisecondsSinceEpoch - cachedTs;
    if (age < const Duration(minutes: 30).inMilliseconds) {
      return cachedAqi;
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
    final aqi = (current['us_aqi'] as num).toInt();

    // Cache the result
    await prefs.setInt(cacheKey, aqi);
    await prefs.setInt(cacheTsKey, DateTime.now().millisecondsSinceEpoch);

    return aqi;
  } catch (_) {
    // Return stale cache on failure instead of null
    return cachedAqi;
  }
});
