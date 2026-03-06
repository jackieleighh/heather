import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/constants/api_endpoints.dart';

final visiblePlanetsProvider = FutureProvider.family<List<String>,
    ({double lat, double lon})>((ref, coords) async {
  final prefs = await SharedPreferences.getInstance();
  final cacheKey = 'cached_planets_${coords.lat}_${coords.lon}';
  final cacheTsKey = 'cached_planets_ts_${coords.lat}_${coords.lon}';

  final cachedJson = prefs.getString(cacheKey);
  final cachedTs = prefs.getInt(cacheTsKey);

  List<String>? cachedPlanets;
  if (cachedJson != null) {
    cachedPlanets =
        (jsonDecode(cachedJson) as List).cast<String>();
  }

  // Return cached value if <30 min old
  if (cachedPlanets != null && cachedTs != null) {
    final age = DateTime.now().millisecondsSinceEpoch - cachedTs;
    if (age < const Duration(minutes: 30).inMilliseconds) {
      return cachedPlanets;
    }
  }

  try {
    final response = await Dio().get(
      ApiEndpoints.visiblePlanets(
        latitude: coords.lat,
        longitude: coords.lon,
      ),
    );
    final data = response.data as Map<String, dynamic>;
    final bodies = data['data'] as List<dynamic>;
    final planets = bodies
        .where((b) =>
            b['nakedEyeObject'] == true &&
            b['name'] != 'Sun' &&
            b['name'] != 'Moon')
        .map<String>((b) => b['name'] as String)
        .toList();

    // Cache the result
    await prefs.setString(cacheKey, jsonEncode(planets));
    await prefs.setInt(cacheTsKey, DateTime.now().millisecondsSinceEpoch);

    return planets;
  } catch (_) {
    // Return stale cache on failure, or empty list if no cache
    return cachedPlanets ?? [];
  }
});
