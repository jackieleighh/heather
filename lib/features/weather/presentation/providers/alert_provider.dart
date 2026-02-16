import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../../domain/entities/weather_alert.dart';

final alertsProvider = FutureProvider.family<List<WeatherAlert>,
    ({double lat, double lon})>((ref, coords) async {
  try {
    final response = await Dio().get(
      ApiEndpoints.nwsAlerts(
        latitude: coords.lat,
        longitude: coords.lon,
      ),
      options: Options(
        headers: {
          'User-Agent': '(Heather Weather App)',
          'Accept': 'application/geo+json',
        },
      ),
    );

    final data = response.data as Map<String, dynamic>;
    final features = data['features'] as List<dynamic>? ?? [];
    final now = DateTime.now();

    final alerts = features
        .map((feature) {
          final props = feature['properties'] as Map<String, dynamic>;
          final expires = DateTime.tryParse(props['expires'] as String? ?? '');

          // Skip expired alerts
          if (expires != null && expires.isBefore(now)) return null;

          return WeatherAlert(
            id: props['id'] as String? ?? '',
            event: props['event'] as String? ?? 'Weather Alert',
            severity:
                AlertSeverity.fromString(props['severity'] as String?),
            headline: props['headline'] as String? ?? '',
            description: props['description'] as String? ?? '',
            instruction: props['instruction'] as String? ?? '',
            effective:
                DateTime.tryParse(props['effective'] as String? ?? '') ??
                    now,
            expires: expires ?? now.add(const Duration(hours: 1)),
            senderName: props['senderName'] as String? ?? '',
            areaDesc: props['areaDesc'] as String? ?? '',
          );
        })
        .whereType<WeatherAlert>()
        .toList()
      ..sort((a, b) => a.severity.sortOrder.compareTo(b.severity.sortOrder));

    return alerts;
  } catch (_) {
    return [];
  }
});
