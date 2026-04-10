import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_client.dart';

class VisiblePlanet {
  final String name;
  final double altitude;
  final double azimuth;
  final double magnitude;
  final String constellation;

  const VisiblePlanet({
    required this.name,
    required this.altitude,
    required this.azimuth,
    required this.magnitude,
    required this.constellation,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'altitude': altitude,
    'azimuth': azimuth,
    'magnitude': magnitude,
    'constellation': constellation,
  };

  factory VisiblePlanet.fromJson(Map<String, dynamic> json) => VisiblePlanet(
    name: json['name'] as String,
    altitude: (json['altitude'] as num).toDouble(),
    azimuth: (json['azimuth'] as num).toDouble(),
    magnitude: (json['magnitude'] as num).toDouble(),
    constellation: json['constellation'] as String,
  );
}

/// Round to 3 decimal places (~111m precision) to avoid GPS micro-drift
/// creating duplicate provider instances and cache entries.
({double lat, double lon}) _roundCoords(({double lat, double lon}) c) => (
  lat: (c.lat * 1000).roundToDouble() / 1000,
  lon: (c.lon * 1000).roundToDouble() / 1000,
);

final visiblePlanetsProvider = FutureProvider.autoDispose.family<List<VisiblePlanet>,
    ({double lat, double lon})>((ref, rawCoords) async {
  final coords = _roundCoords(rawCoords);
  final prefs = ref.watch(sharedPreferencesProvider);
  final dio = ref.watch(dioProvider);
  final cacheKey = 'cached_planets_v2_${coords.lat}_${coords.lon}';
  final cacheTsKey = 'cached_planets_v2_ts_${coords.lat}_${coords.lon}';

  final cachedJson = prefs.getString(cacheKey);
  final cachedTs = prefs.getInt(cacheTsKey);

  List<VisiblePlanet>? cachedPlanets;
  if (cachedJson != null) {
    try {
      cachedPlanets = (jsonDecode(cachedJson) as List)
          .map((e) => VisiblePlanet.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {}
  }

  // Return cached value if <30 min old
  if (cachedPlanets != null && cachedTs != null) {
    final age = DateTime.now().millisecondsSinceEpoch - cachedTs;
    if (age < const Duration(minutes: 30).inMilliseconds) {
      return cachedPlanets;
    }
  }

  try {
    final response = await dio.get(
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
        .map<VisiblePlanet>((b) => VisiblePlanet(
              name: b['name'] as String,
              altitude: (b['altitude'] as num).toDouble(),
              azimuth: (b['azimuth'] as num).toDouble(),
              magnitude: (b['magnitude'] as num).toDouble(),
              constellation: b['constellation'] as String,
            ))
        .toList();

    // Cache the result
    await prefs.setString(
        cacheKey, jsonEncode(planets.map((p) => p.toJson()).toList()));
    await prefs.setInt(cacheTsKey, DateTime.now().millisecondsSinceEpoch);

    return planets;
  } catch (_) {
    // Return stale cache on failure, or empty list if no cache
    return cachedPlanets ?? [];
  }
});
