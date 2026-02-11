import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/api_endpoints.dart';

final airQualityProvider =
    FutureProvider.family<int?, ({double lat, double lon})>((ref, coords) async {
  try {
    final response = await Dio().get(
      ApiEndpoints.airQuality(
        latitude: coords.lat,
        longitude: coords.lon,
      ),
    );
    final data = response.data as Map<String, dynamic>;
    final current = data['current'] as Map<String, dynamic>;
    return (current['us_aqi'] as num).toInt();
  } catch (_) {
    return null;
  }
});
