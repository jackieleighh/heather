import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _explicitLanguageKey = 'explicit_language';
const _onboardingCompletedKey = 'onboarding_completed';
const _severeAlertsEnabledKey = 'severe_alerts_enabled';

final settingsProvider = StateNotifierProvider<SettingsNotifier, SettingsState>(
  (ref) {
    return SettingsNotifier();
  },
);

class SettingsState {
  final bool explicitLanguage;
  final bool onboardingCompleted;
  final bool severeAlertsEnabled;

  const SettingsState({
    this.explicitLanguage = true,
    this.onboardingCompleted = false,
    this.severeAlertsEnabled = true,
  });

  SettingsState copyWith({
    bool? explicitLanguage,
    bool? onboardingCompleted,
    bool? severeAlertsEnabled,
  }) {
    return SettingsState(
      explicitLanguage: explicitLanguage ?? this.explicitLanguage,
      onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
      severeAlertsEnabled: severeAlertsEnabled ?? this.severeAlertsEnabled,
    );
  }
}

class SettingsNotifier extends StateNotifier<SettingsState> {
  SettingsNotifier() : super(const SettingsState()) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final explicit = prefs.getBool(_explicitLanguageKey) ?? true;
    final onboardingCompleted = prefs.getBool(_onboardingCompletedKey) ?? false;
    final severeAlertsEnabled = prefs.getBool(_severeAlertsEnabledKey) ?? true;
    state = SettingsState(
      explicitLanguage: explicit,
      onboardingCompleted: onboardingCompleted,
      severeAlertsEnabled: severeAlertsEnabled,
    );
  }

  Future<void> setExplicitLanguage(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_explicitLanguageKey, value);
    state = state.copyWith(explicitLanguage: value);
  }

  Future<void> setSevereAlertsEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_severeAlertsEnabledKey, value);
    state = state.copyWith(severeAlertsEnabled: value);
  }

  Future<void> completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_onboardingCompletedKey, true);
    state = state.copyWith(onboardingCompleted: true);
  }
}
