import 'package:dio/dio.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../../domain/entities/weather_alert.dart';

/// Rough bounding box for US territories (CONUS, Alaska, Hawaii, PR/USVI, Guam).
bool _isInUSBounds(double lat, double lon) {
  if (lat >= 24.0 && lat <= 50.0 && lon >= -125.0 && lon <= -66.0) return true;
  if (lat >= 51.0 && lat <= 72.0 && lon >= -180.0 && lon <= -129.0) return true;
  if (lat >= 18.5 && lat <= 22.5 && lon >= -161.0 && lon <= -154.0) return true;
  if (lat >= 17.5 && lat <= 18.6 && lon >= -67.5 && lon <= -64.5) return true;
  if (lat >= 13.0 && lat <= 21.0 && lon >= 144.0 && lon <= 146.5) return true;
  return false;
}

/// Fetches active NWS alerts for the given coordinates.
/// Returns an empty list on failure or for non-US locations.
Future<List<WeatherAlert>> fetchAlerts({
  required double latitude,
  required double longitude,
}) async {
  // NWS alerts only cover US territories
  if (!_isInUSBounds(latitude, longitude)) return [];

  try {
    final dio = Dio(BaseOptions(
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ));
    final response = await dio.get(
      ApiEndpoints.nwsAlerts(
        latitude: latitude,
        longitude: longitude,
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
}
