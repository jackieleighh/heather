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
  List<Map<String, dynamic>>? _lastLocations;

  Future<void> init() async {
    if (_initialized) return;

    // Register background handler
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Initialize local notifications plugin (needed for foreground .show())
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestSoundPermission: false,
      requestBadgePermission: false,
    );
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    await _localNotifications.initialize(initSettings);

    // Create Android notification channel for alerts
    if (Platform.isAndroid) {
      await _createAndroidAlertChannel();
    }

    // Fetch FCM token without blocking startup (on iOS this hangs until
    // notification permission is granted, which happens later in onboarding).
    _messaging.getToken().then((token) {
      if (kDebugMode) {
        print('FCM token: $token');
      }
    });

    // Listen for token refreshes – re-register with cached locations
    _messaging.onTokenRefresh.listen((newToken) {
      if (kDebugMode) {
        print('FCM token refreshed: $newToken');
      }
      if (_lastLocations != null) {
        registerDevice(locations: _lastLocations!);
      }
    });

    // Tell iOS to show banners/badges/sound even when the app is in foreground
    await _messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

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

  /// Requests notification permission from the OS. Call this from the
  /// onboarding notifications step rather than at app launch.
  Future<bool> requestPermission() async {
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

    return settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional;
  }

  /// Registers the device's FCM token + all locations with the cloud function
  /// so the backend can send location-targeted severe weather push alerts.
  Future<void> registerDevice({
    required List<Map<String, dynamic>> locations,
  }) async {
    // On iOS, getToken() returns null until notification permission is granted.
    // Ensure we have permission before attempting to fetch the token.
    final status = await _messaging.getNotificationSettings();
    if (status.authorizationStatus == AuthorizationStatus.notDetermined) {
      final granted = await requestPermission();
      if (!granted) return;
    } else if (status.authorizationStatus == AuthorizationStatus.denied) {
      return;
    }

    final token = await _messaging.getToken();
    if (token == null) return;

    _lastLocations = locations;

    try {
      await _functions.httpsCallable('registerDevice').call({
        'fcmToken': token,
        'locations': locations,
      });
    } catch (e) {
      if (kDebugMode) {
        print('Failed to register device: $e');
      }
    }
  }

  /// Unregisters the device by sending an empty locations array so the backend
  /// stops sending push alerts. Called when the user disables severe alerts.
  Future<void> unregisterDevice() async {
    final token = await _messaging.getToken();
    if (token == null) return;

    _lastLocations = null;

    try {
      await _functions.httpsCallable('registerDevice').call({
        'fcmToken': token,
        'locations': <Map<String, dynamic>>[],
      });
    } catch (e) {
      if (kDebugMode) {
        print('Failed to unregister device: $e');
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
