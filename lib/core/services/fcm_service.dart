import 'dart:io';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Top-level handler for background FCM messages.
/// Must be a top-level function (not a class method).
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Background messages on Android are automatically shown by the system
  // when a notification payload is present. This handler is for data-only
  // messages or additional processing.
  if (kDebugMode) {
    print('FCM background message: ${message.messageId}');
  }
}

class FcmService {
  static final FcmService _instance = FcmService._();
  factory FcmService() => _instance;
  FcmService._();

  static const _alertChannelId = 'heather_weather_alerts';
  static const _alertChannelName = 'Severe Weather Alerts';
  static const _alertChannelDescription =
      'Critical weather alerts like tornado warnings and severe thunderstorms';

  final _messaging = FirebaseMessaging.instance;
  final _localNotifications = FlutterLocalNotificationsPlugin();
  final _functions = FirebaseFunctions.instance;
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;

    // Register background handler
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Request notification permissions
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      criticalAlert: true,
      provisional: false,
    );

    if (kDebugMode) {
      print('FCM permission status: ${settings.authorizationStatus}');
    }

    // Create Android notification channel for alerts
    if (Platform.isAndroid) {
      await _createAndroidAlertChannel();
    }

    // Get and log the FCM token
    final token = await _messaging.getToken();
    if (kDebugMode) {
      print('FCM token: $token');
    }

    // Listen for token refreshes
    _messaging.onTokenRefresh.listen((newToken) {
      if (kDebugMode) {
        print('FCM token refreshed: $newToken');
      }
      // Re-register with updated token (lat/lon will be sent on next
      // registerDevice call from the app when location is available)
    });

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Handle notification taps when app was in background
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

    // Check if app was opened from a terminated state via notification
    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      _handleNotificationTap(initialMessage);
    }

    _initialized = true;
  }

  Future<void> _createAndroidAlertChannel() async {
    const channel = AndroidNotificationChannel(
      _alertChannelId,
      _alertChannelName,
      description: _alertChannelDescription,
      importance: Importance.high,
      enableVibration: true,
      playSound: true,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  void _handleForegroundMessage(RemoteMessage message) {
    final notification = message.notification;
    if (notification == null) return;

    // Show local notification since FCM doesn't auto-show in foreground
    _localNotifications.show(
      notification.hashCode,
      notification.title,
      notification.body,
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
  }

  void _handleNotificationTap(RemoteMessage message) {
    // When user taps the notification, the app opens to the weather screen
    // which is already the default route. No navigation needed.
    if (kDebugMode) {
      print('FCM notification tapped: ${message.data}');
    }
  }

  /// Registers the device's FCM token + location with the cloud function
  /// so the backend can send location-targeted severe weather push alerts.
  Future<void> registerDevice({
    required double latitude,
    required double longitude,
  }) async {
    final token = await _messaging.getToken();
    if (token == null) return;

    try {
      await _functions.httpsCallable('registerDevice').call({
        'fcmToken': token,
        'latitude': latitude,
        'longitude': longitude,
      });
    } catch (e) {
      if (kDebugMode) {
        print('Failed to register device: $e');
      }
    }
  }

  /// Returns the current FCM token, or null if unavailable.
  Future<String?> getToken() => _messaging.getToken();

  /// Subscribe to a topic (e.g., for location-based alert routing).
  Future<void> subscribeToTopic(String topic) =>
      _messaging.subscribeToTopic(topic);

  /// Unsubscribe from a topic.
  Future<void> unsubscribeFromTopic(String topic) =>
      _messaging.unsubscribeFromTopic(topic);
}
