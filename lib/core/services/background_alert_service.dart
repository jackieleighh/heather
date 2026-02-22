import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';

import '../constants/api_endpoints.dart';

const _taskName = 'com.totms.heather.alertCheck';
const _locationsKey = 'bg_alert_locations';
const _sentIdsKey = 'sent_alert_ids';

const _alertChannelId = 'heather_weather_alerts';
const _alertChannelName = 'Severe Weather Alerts';
const _alertChannelDescription =
    'Critical weather alerts like tornado warnings and severe thunderstorms';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    if (task == _taskName || task == Workmanager.iOSBackgroundTask) {
      await _checkAlerts();
      // iOS doesn't support periodic tasks — re-schedule a one-off
      if (!Platform.isAndroid) {
        await Workmanager().registerOneOffTask(
          _taskName,
          _taskName,
          initialDelay: const Duration(minutes: 15),
          constraints: Constraints(networkType: NetworkType.connected),
          existingWorkPolicy: ExistingWorkPolicy.replace,
        );
      }
    }
    return true;
  });
}

Future<void> _checkAlerts() async {
  final prefs = await SharedPreferences.getInstance();

  final locationsJson = prefs.getString(_locationsKey);
  if (locationsJson == null) return;

  final locations =
      (jsonDecode(locationsJson) as List<dynamic>).cast<Map<String, dynamic>>();
  if (locations.isEmpty) return;

  // Load previously sent alert IDs with timestamps
  final sentIdsJson = prefs.getString(_sentIdsKey);
  final sentIds = <String, int>{};
  if (sentIdsJson != null) {
    final decoded = jsonDecode(sentIdsJson) as Map<String, dynamic>;
    for (final entry in decoded.entries) {
      sentIds[entry.key] = entry.value as int;
    }
  }

  // Prune IDs older than 48 hours
  final cutoff =
      DateTime.now().subtract(const Duration(hours: 48)).millisecondsSinceEpoch;
  sentIds.removeWhere((_, timestamp) => timestamp < cutoff);

  final dio = Dio();
  Map<String, dynamic>? mostSevereNew;
  int bestSortOrder = 999;

  for (final loc in locations) {
    final lat = loc['latitude'] as double;
    final lon = loc['longitude'] as double;

    try {
      final response = await dio.get(
        ApiEndpoints.nwsAlerts(latitude: lat, longitude: lon),
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

      for (final feature in features) {
        final props = feature['properties'] as Map<String, dynamic>;
        final id = props['id'] as String? ?? '';
        final expires = DateTime.tryParse(props['expires'] as String? ?? '');

        if (expires != null && expires.isBefore(now)) continue;
        if (sentIds.containsKey(id)) continue;

        final severityStr = (props['severity'] as String? ?? '').toLowerCase();
        final sortOrder = switch (severityStr) {
          'extreme' => 0,
          'severe' => 1,
          'moderate' => 2,
          'minor' => 3,
          _ => 4,
        };

        if (sortOrder < bestSortOrder) {
          bestSortOrder = sortOrder;
          mostSevereNew = props;
        }
      }
    } catch (_) {
      // Skip location on error, try next
    }
  }

  if (mostSevereNew != null) {
    final alertId = mostSevereNew['id'] as String? ?? '';
    final event = mostSevereNew['event'] as String? ?? 'Weather Alert';
    final headline = mostSevereNew['headline'] as String? ?? '';

    final localNotifications = FlutterLocalNotificationsPlugin();
    await localNotifications.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(),
      ),
    );

    await localNotifications.show(
      alertId.hashCode,
      event,
      headline,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          _alertChannelId,
          _alertChannelName,
          channelDescription: _alertChannelDescription,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
    );

    sentIds[alertId] = DateTime.now().millisecondsSinceEpoch;
    await prefs.setString(_sentIdsKey, jsonEncode(sentIds));
  }

  dio.close();
}

class BackgroundAlertService {
  BackgroundAlertService._();

  static Future<void> init() async {
    try {
      await Workmanager().initialize(callbackDispatcher, isInDebugMode: kDebugMode);
    } catch (e) {
      if (kDebugMode) {
        print('WorkManager init failed: $e');
      }
    }
  }

  static Future<void> registerPeriodicCheck() async {
    try {
      if (Platform.isAndroid) {
        await Workmanager().registerPeriodicTask(
          _taskName,
          _taskName,
          frequency: const Duration(minutes: 15),
          constraints: Constraints(networkType: NetworkType.connected),
          existingWorkPolicy: ExistingWorkPolicy.replace,
        );
      } else {
        await Workmanager().registerOneOffTask(
          _taskName,
          _taskName,
          initialDelay: const Duration(minutes: 15),
          constraints: Constraints(networkType: NetworkType.connected),
          existingWorkPolicy: ExistingWorkPolicy.replace,
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('WorkManager task registration failed: $e');
      }
    }
  }

  static Future<void> cancelPeriodicCheck() async {
    try {
      await Workmanager().cancelByUniqueName(_taskName);
    } catch (e) {
      if (kDebugMode) {
        print('WorkManager task cancellation failed: $e');
      }
    }
  }

  static Future<void> updateLocations(
    List<Map<String, dynamic>> locations,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_locationsKey, jsonEncode(locations));
  }
}
