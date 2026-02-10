import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _explicitLanguageKey = 'explicit_language';

final settingsProvider = StateNotifierProvider<SettingsNotifier, SettingsState>(
  (ref) {
    return SettingsNotifier();
  },
);

class SettingsState {
  final bool explicitLanguage;

  const SettingsState({this.explicitLanguage = false});

  SettingsState copyWith({bool? explicitLanguage}) {
    return SettingsState(
      explicitLanguage: explicitLanguage ?? this.explicitLanguage,
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
    state = SettingsState(explicitLanguage: explicit);
  }

  Future<void> setExplicitLanguage(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_explicitLanguageKey, value);
    state = state.copyWith(explicitLanguage: value);
  }
}
