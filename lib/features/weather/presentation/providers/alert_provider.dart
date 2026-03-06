import 'package:dio/dio.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/utils/geo_utils.dart';
import '../../domain/entities/weather_alert.dart';

/// Cleans NWS alert text by replacing hard-wrapped single newlines with spaces
/// while preserving paragraph breaks (double newlines).
String _cleanAlertText(String text) {
  return text
      .replaceAll('\r\n', '\n')
      .replaceAll(RegExp(r'\n\n+'), '\u0000')
      .replaceAll('\n', ' ')
      .replaceAll('\u0000', '\n\n')
      .trim();
}

/// Fetches active NWS alerts for the given coordinates.
/// Returns an empty list on failure or for non-US locations.
Future<List<WeatherAlert>> fetchAlerts({
  required double latitude,
  required double longitude,
}) async {
  // NWS alerts only cover US territories
  if (!isInUSBounds(latitude, longitude)) return [];

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
            description: _cleanAlertText(props['description'] as String? ?? ''),
            instruction: _cleanAlertText(props['instruction'] as String? ?? ''),
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
