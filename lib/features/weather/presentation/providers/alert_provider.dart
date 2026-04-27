import 'package:dio/dio.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/utils/geo_utils.dart';
import '../../domain/entities/weather_alert.dart';

/// Fetches active NWS alerts for the given coordinates.
/// Returns an empty list on failure or for non-US locations.
/// Accepts an optional [dio] instance for connection pooling; falls back to
/// a one-off instance when not provided (e.g. from non-Riverpod call sites).
Future<List<WeatherAlert>> fetchAlerts({
  required double latitude,
  required double longitude,
  Dio? dio,
}) async {
  // NWS alerts only cover US territories
  if (!isInUSBounds(latitude, longitude)) return [];

  try {
    final client =
        dio ??
        Dio(
          BaseOptions(
            connectTimeout: const Duration(seconds: 10),
            receiveTimeout: const Duration(seconds: 10),
          ),
        );
    final response = await client.get(
      ApiEndpoints.nwsAlerts(latitude: latitude, longitude: longitude),
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

    // Collect IDs of superseded alerts from the references field.
    // When NWS updates/extends/continues an alert it issues a new one whose
    // `references` array points back to the old alert IDs.
    final supersededIds = <String>{};
    for (final feature in features) {
      final props = feature['properties'] as Map<String, dynamic>;
      final refs = props['references'] as List<dynamic>? ?? [];
      for (final ref in refs) {
        if (ref is Map<String, dynamic>) {
          final refId =
              ref['@id'] as String? ?? ref['identifier'] as String? ?? '';
          if (refId.isNotEmpty) supersededIds.add(refId);
        }
      }
    }

    final alerts = features
        .map((feature) {
          final props = feature['properties'] as Map<String, dynamic>;
          final expires = DateTime.tryParse(props['expires'] as String? ?? '');

          // Skip expired alerts
          if (expires != null && expires.isBefore(now)) return null;

          // Skip alerts that have been superseded by a newer one
          final alertId = props['id'] as String? ?? '';
          if (supersededIds.contains(alertId)) return null;

          return WeatherAlert(
            id: alertId,
            event: props['event'] as String? ?? 'Weather Alert',
            severity: AlertSeverity.fromString(props['severity'] as String?),
            headline: props['headline'] as String? ?? '',
            description: _cleanAlertText(props['description'] as String? ?? ''),
            instruction: _cleanAlertText(props['instruction'] as String? ?? ''),
            effective:
                DateTime.tryParse(props['effective'] as String? ?? '') ?? now,
            expires: expires ?? now.add(const Duration(hours: 1)),
            senderName: props['senderName'] as String? ?? '',
            areaDesc: props['areaDesc'] as String? ?? '',
          );
        })
        .whereType<WeatherAlert>()
        .toList();

    // Deduplicate by event name — when the same event (e.g. "Heat Advisory")
    // covers multiple overlapping zones for one point, keep only the alert
    // with the latest effective time.
    final eventMap = <String, WeatherAlert>{};
    for (final alert in alerts) {
      final existing = eventMap[alert.event];
      if (existing == null || alert.effective.isAfter(existing.effective)) {
        eventMap[alert.event] = alert;
      }
    }

    return eventMap.values.toList()
      ..sort((a, b) => a.severity.sortOrder.compareTo(b.severity.sortOrder));
  } catch (_) {
    return [];
  }
}

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
