import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/constants/persona.dart';
import '../../../../core/services/notification_service.dart';

const _explicitLanguageKey = 'explicit_language';
const _notificationsEnabledKey = 'notifications_enabled';
const _notificationHourKey = 'notification_hour';
const _notificationMinuteKey = 'notification_minute';
const _onboardingCompletedKey = 'onboarding_completed';
const _personaKey = 'persona';

final settingsProvider = StateNotifierProvider<SettingsNotifier, SettingsState>(
  (ref) {
    return SettingsNotifier();
  },
);

class SettingsState {
  final bool explicitLanguage;
  final bool notificationsEnabled;
  final TimeOfDay notificationTime;
  final bool onboardingCompleted;
  final Persona persona;

  const SettingsState({
    this.explicitLanguage = false,
    this.notificationsEnabled = false,
    this.notificationTime = const TimeOfDay(hour: 7, minute: 0),
    this.onboardingCompleted = false,
    this.persona = Persona.heather,
  });

  SettingsState copyWith({
    bool? explicitLanguage,
    bool? notificationsEnabled,
    TimeOfDay? notificationTime,
    bool? onboardingCompleted,
    Persona? persona,
  }) {
    return SettingsState(
      explicitLanguage: explicitLanguage ?? this.explicitLanguage,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      notificationTime: notificationTime ?? this.notificationTime,
      onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
      persona: persona ?? this.persona,
    );
  }
}

class SettingsNotifier extends StateNotifier<SettingsState> {
  SettingsNotifier() : super(const SettingsState()) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final explicit = prefs.getBool(_explicitLanguageKey) ?? false;
    final notificationsEnabled =
        prefs.getBool(_notificationsEnabledKey) ?? false;
    final hour = prefs.getInt(_notificationHourKey) ?? 7;
    final minute = prefs.getInt(_notificationMinuteKey) ?? 0;
    final onboardingCompleted =
        prefs.getBool(_onboardingCompletedKey) ?? false;
    final personaName = prefs.getString(_personaKey);
    final persona = Persona.values.where((p) => p.name == personaName).firstOrNull ?? Persona.heather;
    state = SettingsState(
      explicitLanguage: explicit,
      notificationsEnabled: notificationsEnabled,
      notificationTime: TimeOfDay(hour: hour, minute: minute),
      onboardingCompleted: onboardingCompleted,
      persona: persona,
    );
  }

  Future<void> setExplicitLanguage(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_explicitLanguageKey, value);
    state = state.copyWith(explicitLanguage: value);
  }

  /// Returns false if permission was denied.
  Future<bool> setNotificationsEnabled(bool value) async {
    if (value) {
      final granted = await NotificationService().requestPermissions();
      if (!granted) return false;
    } else {
      await NotificationService().cancelNotification();
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_notificationsEnabledKey, value);
    state = state.copyWith(notificationsEnabled: value);
    return true;
  }

  Future<void> setNotificationTime(TimeOfDay time) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_notificationHourKey, time.hour);
    await prefs.setInt(_notificationMinuteKey, time.minute);
    state = state.copyWith(notificationTime: time);
  }

  Future<void> setPersona(Persona persona) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_personaKey, persona.name);
    state = state.copyWith(persona: persona);
  }

  Future<void> completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_onboardingCompletedKey, true);
    state = state.copyWith(onboardingCompleted: true);
  }
}
