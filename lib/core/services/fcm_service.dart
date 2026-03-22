import 'dart:async';
import 'dart:io';

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

  late final _messaging = FirebaseMessaging.instance;
  final _localNotifications = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  /// Stream that emits when a weather alert notification is tapped.
  final _alertTapController = StreamController<void>.broadcast();
  Stream<void> get alertTapped => _alertTapController.stream;

  /// True when a notification tap opened the app but the UI hasn't consumed it yet.
  bool pendingAlertTap = false;

  /// The location name from the tapped alert notification (e.g. "GPS" or "Pittsburgh").
  String? pendingAlertLocationName;

  /// The location ID from the tapped alert notification (e.g. "GPS" or a saved location UUID).
  String? pendingAlertLocationId;

  void clearPendingAlertTap() {
    pendingAlertTap = false;
    pendingAlertLocationName = null;
    pendingAlertLocationId = null;
  }

  Future<void> init() async {
    if (_initialized) return;

    // Register background handler
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Initialize local notifications plugin (needed for foreground .show())
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/launcher_icon',
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
    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _handleLocalNotificationTap,
    );

    // Create Android notification channel for alerts
    if (Platform.isAndroid) {
      await _createAndroidAlertChannel();
    }

    // Don't let iOS show the FCM notification in the foreground — we show
    // our own local notification (with payload) via _handleForegroundMessage.
    // Showing both causes duplicates and unreliable cold-start tap detection.
    await _messaging.setForegroundNotificationPresentationOptions(
      alert: false,
      badge: true,
      sound: false,
    );

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Handle notification taps when app was in background
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

    // Check if app was opened from a terminated state via notification
    final initialMessage = await _messaging.getInitialMessage();
    if (kDebugMode) {
      debugPrint('[FCM] getInitialMessage: ${initialMessage != null ? 'YES data=${initialMessage.data}' : 'null'}');
    }
    if (initialMessage != null) {
      _handleNotificationTap(initialMessage);
    }

    // Check if app was launched by tapping a local notification (cold start)
    final launchDetails =
        await _localNotifications.getNotificationAppLaunchDetails();
    if (kDebugMode) {
      debugPrint('[FCM] getNotificationAppLaunchDetails: didLaunch=${launchDetails?.didNotificationLaunchApp}, '
          'payload=${launchDetails?.notificationResponse?.payload}');
    }
    if (launchDetails?.didNotificationLaunchApp == true) {
      pendingAlertTap = true;
      final payload = launchDetails!.notificationResponse?.payload ?? '';
      final parts = payload.split('|');
      pendingAlertLocationId = parts.isNotEmpty ? parts[0] : null;
      pendingAlertLocationName = parts.length > 1 ? parts[1] : payload;
      // Fire the stream so WeatherScreen's listener is notified regardless of
      // timing with the 3-second splash timer. Without this, the pending
      // alert can be missed if init() completes after the timer fires.
      _alertTapController.add(null);
    }

    if (kDebugMode) {
      debugPrint('[FCM] init complete: pendingAlertTap=$pendingAlertTap, '
          'locationId=$pendingAlertLocationId, locationName=$pendingAlertLocationName');
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
          icon: '@mipmap/launcher_icon',
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: '${message.data['locationId'] ?? ''}|${message.data['locationName'] ?? ''}',
    );
  }

  void _handleLocalNotificationTap(NotificationResponse response) {
    pendingAlertTap = true;
    final payload = response.payload ?? '';
    final parts = payload.split('|');
    pendingAlertLocationId = parts.isNotEmpty ? parts[0] : null;
    pendingAlertLocationName = parts.length > 1 ? parts[1] : payload;
    if (kDebugMode) {
      debugPrint('[FCM] _handleLocalNotificationTap: locId=$pendingAlertLocationId, '
          'locName=$pendingAlertLocationName, payload=$payload');
    }
    _alertTapController.add(null);
  }

  void _handleNotificationTap(RemoteMessage message) {
    pendingAlertTap = true;
    pendingAlertLocationId = message.data['locationId'];
    pendingAlertLocationName = message.data['locationName'];
    if (kDebugMode) {
      debugPrint('[FCM] _handleNotificationTap: locId=$pendingAlertLocationId, '
          'locName=$pendingAlertLocationName, data=${message.data}');
    }
    _alertTapController.add(null);
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

}
