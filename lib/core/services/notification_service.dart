import 'dart:math';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../constants/persona.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._();
  factory NotificationService() => _instance;
  NotificationService._();

  static const _channelId = 'heather_daily_weather';
  static const _channelName = 'Daily Weather';
  static const _notificationId = 0;

  static final _random = Random();

  static const _heatherTitles = [
    'Wake up, babe',
    'Weather check',
    'Your daily briefing',
    'Heads up',
    'Before you leave...',
    'Real quick',
    'Outside report',
    'Read this first',
    'Hot take on today',
    'The sky called',
    'Dress accordingly',
    'You\'re welcome',
    'Today\'s damage report',
    'Breaking weather news',
    'Outfit advisory',
    'FYI',
    'Weather report incoming',
    'Got your weather, babe',
    'Rise and shine, babe',
    'Best day ever',
  ];

  static const _jadeTitles = [
    'Morning babe',
    'Weather vibes',
    'Your daily forecast',
    'Heads up',
    'Before you head out...',
    'Real quick',
    'Outside check',
    'Read this first',
    'Today\'s vibe check',
    'The sky\'s doing a thing',
    'Dress for the mood',
    'You\'re welcome',
    'Today\'s forecast',
    'Weather update',
    'FYI',
    'Weather incoming',
    'Got your weather',
    'Rise and shine',
    'Here\'s the deal',
  ];

  static const _lunaTitles = [
    'Good morning, sunshine',
    'Weather thoughts',
    'A sky update for you',
    'Hey guess what',
    'Before you go outside...',
    'Oh also',
    'Outside is happening',
    'Read this first',
    'The sky has feelings today',
    'The clouds told me something',
    'Dress for the universe',
    'You\'re welcome',
    'Today\'s sky report',
    'Weather news of sorts',
    'The wind whispered this',
    'So anyway',
    'Weather from the cosmos',
    'I checked the sky for you',
    'Wakey wakey',
    'The earth says hi',
  ];

  static const _aureliaTitles = [
    'Good morning, sunshine',
    'Weather thoughts',
    'A sky update for you',
    'Hey guess what',
    'Before you go outside...',
    'Oh also',
    'Outside is happening',
    'Read this first',
    'The sky has feelings today',
    'The clouds told me something',
    'Dress for the universe',
    'You\'re welcome',
    'Today\'s sky report',
    'Weather news of sorts',
    'The wind whispered this',
    'So anyway',
    'Weather from the cosmos',
    'I checked the sky for you',
    'Wakey wakey',
    'The earth says hi',
  ];

  static String randomTitle({Persona persona = Persona.heather}) {
    final titles = switch (persona) {
      Persona.heather => _heatherTitles,
      Persona.jade => _jadeTitles,
      Persona.luna => _lunaTitles,
      Persona.aurelia => _aureliaTitles,
    };
    return titles[_random.nextInt(titles.length)];
  }

  final _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;

    tz.initializeTimeZones();
    final localTZ = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(localTZ.identifier));

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestSoundPermission: false,
      requestBadgePermission: false,
    );
    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(settings);
    _initialized = true;
  }

  Future<bool> requestPermissions() async {
    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (android != null) {
      final granted = await android.requestNotificationsPermission();
      return granted ?? false;
    }

    final ios = _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();
    if (ios != null) {
      final granted = await ios.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      return granted ?? false;
    }

    return true;
  }

  Future<void> scheduleDailyNotification({
    required int hour,
    required int minute,
    required String title,
    required String body,
  }) async {
    await cancelNotification();

    final scheduledTime = _nextInstanceOfTime(hour, minute);

    const androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: 'Daily weather update from Heather',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
    );
    const iosDetails = DarwinNotificationDetails();
    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _plugin.zonedSchedule(
      _notificationId,
      title,
      body,
      scheduledTime,
      details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> cancelNotification() async {
    await _plugin.cancel(_notificationId);
  }

  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }
}
