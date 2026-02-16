import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/constants/persona.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../core/services/widget_service.dart';
import '../../data/repositories/quip_repository_impl.dart';
import '../../data/repositories/weather_repository_impl.dart';
import '../../data/sources/location_source.dart';
import '../../data/sources/weather_remote_source.dart';
import '../../domain/entities/forecast.dart';
import '../../domain/entities/location_info.dart';
import 'settings_provider.dart';

part 'weather_provider.freezed.dart';

// Dependencies
final weatherRepositoryProvider = Provider<WeatherRepositoryImpl>((ref) {
  final apiClient = ApiClient();
  return WeatherRepositoryImpl(
    remoteSource: WeatherRemoteSource(dio: apiClient.weatherClient),
    locationSource: LocationSource(),
  );
});

final quipRepositoryProvider = Provider<QuipRepositoryImpl>((ref) {
  return QuipRepositoryImpl();
});

// State
@freezed
class WeatherState with _$WeatherState {
  const factory WeatherState.loading() = _Loading;
  const factory WeatherState.loaded({
    required Forecast forecast,
    required LocationInfo location,
    required String quip,
  }) = _Loaded;
  const factory WeatherState.error(String message) = _Error;
}

// Main provider
final weatherStateProvider =
    StateNotifierProvider<WeatherNotifier, WeatherState>((ref) {
      final settings = ref.read(settingsProvider);
      final notifier = WeatherNotifier(
        weatherRepo: ref.watch(weatherRepositoryProvider),
        quipRepo: ref.watch(quipRepositoryProvider),
        explicit: settings.explicitLanguage,
        persona: settings.persona,
        notificationsEnabled: settings.notificationsEnabled,
        notificationTime: settings.notificationTime,
      );

      ref.listen<SettingsState>(settingsProvider, (previous, next) {
        final toneOrPersonaChanged =
            previous?.explicitLanguage != next.explicitLanguage ||
            previous?.persona != next.persona;
        if (toneOrPersonaChanged) {
          notifier.updateExplicit(next.explicitLanguage);
          notifier.updatePersona(next.persona);
        }
        final notifChanged =
            previous?.notificationsEnabled != next.notificationsEnabled ||
            previous?.notificationTime != next.notificationTime;
        if (notifChanged) {
          notifier.updateNotificationSettings(
            enabled: next.notificationsEnabled,
            time: next.notificationTime,
          );
        }
      });

      return notifier;
    });

class WeatherNotifier extends StateNotifier<WeatherState> {
  final WeatherRepositoryImpl weatherRepo;
  final QuipRepositoryImpl quipRepo;
  bool _explicit;
  Persona _persona;
  bool _notificationsEnabled;
  TimeOfDay _notificationTime;

  WeatherNotifier({
    required this.weatherRepo,
    required this.quipRepo,
    required bool explicit,
    required Persona persona,
    required bool notificationsEnabled,
    required TimeOfDay notificationTime,
  }) : _explicit = explicit,
       _persona = persona,
       _notificationsEnabled = notificationsEnabled,
       _notificationTime = notificationTime,
       super(const WeatherState.loading()) {
    loadWeather();
  }

  void updateExplicit(bool value) {
    _explicit = value;
    _swapLocalQuip();
  }

  void updatePersona(Persona persona) {
    _persona = persona;
    _swapLocalQuip();
  }

  void _swapLocalQuip() {
    final current = state;
    current.whenOrNull(
      loaded: (forecast, location, _) {
        state = WeatherState.loaded(
          forecast: forecast,
          location: location,
          quip: quipRepo.getLocalQuip(
            weather: forecast.current,
            explicit: _explicit,
            persona: _persona,
          ),
        );
        _pushToWidget();
      },
    );
  }

  void updateQuip(String quip) {
    state.whenOrNull(
      loaded: (forecast, location, _) {
        state = WeatherState.loaded(
          forecast: forecast,
          location: location,
          quip: quip,
        );
        _scheduleNotificationIfNeeded();
        _pushToWidget();
      },
    );
  }

  void updateNotificationSettings({
    required bool enabled,
    required TimeOfDay time,
  }) {
    _notificationsEnabled = enabled;
    _notificationTime = time;
    _scheduleNotificationIfNeeded();
  }

  void _scheduleNotificationIfNeeded() {
    final current = state;
    if (current is! _Loaded) return;

    if (!_notificationsEnabled) {
      NotificationService().cancelNotification();
      return;
    }

    final today = current.forecast.daily.first;
    final high = today.temperatureMax.round();
    final low = today.temperatureMin.round();
    final description = current.forecast.current.description.toLowerCase();
    final body = 'H:$high° L:$low° and $description. ${current.quip}';
    NotificationService().scheduleDailyNotification(
      hour: _notificationTime.hour,
      minute: _notificationTime.minute,
      title: NotificationService.randomTitle(persona: _persona),
      body: body,
    );
  }

  void _pushToWidget() {
    final current = state;
    if (current is! _Loaded) return;
    WidgetService.updateWidget(
      forecast: current.forecast,
      location: current.location,
      quip: current.quip,
      persona: _persona,
      explicit: _explicit,
    );
  }

  Future<void> loadWeather() async {
    state = const WeatherState.loading();
    try {
      final location = await weatherRepo.getCurrentLocation();
      final forecast = await weatherRepo.getForecast(
        latitude: location.latitude,
        longitude: location.longitude,
      );
      final quip = quipRepo.getLocalQuip(
        weather: forecast.current,
        explicit: _explicit,
        persona: _persona,
      );
      if (!mounted) return;
      state = WeatherState.loaded(
        forecast: forecast,
        location: location,
        quip: quip,
      );
      _scheduleNotificationIfNeeded();
      _pushToWidget();
    } catch (e) {
      if (!mounted) return;
      state = WeatherState.error(e.toString());
    }
  }

  Future<bool> refresh() async {
    try {
      final location = await weatherRepo.getCurrentLocation();
      final forecast = await weatherRepo.getForecast(
        latitude: location.latitude,
        longitude: location.longitude,
      );
      final quip = quipRepo.getLocalQuip(
        weather: forecast.current,
        explicit: _explicit,
        persona: _persona,
      );
      if (!mounted) return false;
      state = WeatherState.loaded(
        forecast: forecast,
        location: location,
        quip: quip,
      );
      _scheduleNotificationIfNeeded();
      _pushToWidget();
      return true;
    } catch (e) {
      if (!mounted) return false;
      if (state is! _Loaded) {
        state = WeatherState.error(e.toString());
      }
      return false;
    }
  }
}

// Family provider for saved location forecasts
@freezed
class LocationForecastState with _$LocationForecastState {
  const factory LocationForecastState.loading() = _LocationLoading;
  const factory LocationForecastState.loaded({
    required Forecast forecast,
    required String quip,
  }) = _LocationLoaded;
  const factory LocationForecastState.error(String message) = _LocationError;
}

final locationForecastProvider =
    StateNotifierProvider.family<
      LocationForecastNotifier,
      LocationForecastState,
      ({String name, double lat, double lon})
    >((ref, params) {
      final settings = ref.read(settingsProvider);
      final notifier = LocationForecastNotifier(
        weatherRepo: ref.watch(weatherRepositoryProvider),
        quipRepo: ref.watch(quipRepositoryProvider),
        name: params.name,
        latitude: params.lat,
        longitude: params.lon,
        explicit: settings.explicitLanguage,
        persona: settings.persona,
      );

      ref.listen<SettingsState>(settingsProvider, (previous, next) {
        if (previous?.explicitLanguage != next.explicitLanguage ||
            previous?.persona != next.persona) {
          notifier.updateExplicit(next.explicitLanguage);
          notifier.updatePersona(next.persona);
        }
      });

      return notifier;
    });

class LocationForecastNotifier extends StateNotifier<LocationForecastState> {
  final WeatherRepositoryImpl weatherRepo;
  final QuipRepositoryImpl quipRepo;
  final String name;
  final double latitude;
  final double longitude;
  bool _explicit;
  Persona _persona;

  LocationForecastNotifier({
    required this.weatherRepo,
    required this.quipRepo,
    required this.name,
    required this.latitude,
    required this.longitude,
    required bool explicit,
    required Persona persona,
  }) : _explicit = explicit,
       _persona = persona,
       super(const LocationForecastState.loading()) {
    load();
  }

  void updateExplicit(bool value) {
    _explicit = value;
    _swapLocalQuip();
  }

  void updatePersona(Persona persona) {
    _persona = persona;
    _swapLocalQuip();
  }

  void _swapLocalQuip() {
    state.whenOrNull(
      loaded: (forecast, _) {
        state = LocationForecastState.loaded(
          forecast: forecast,
          quip: quipRepo.getLocalQuip(
            weather: forecast.current,
            explicit: _explicit,
            persona: _persona,
          ),
        );
      },
    );
  }

  void updateQuip(String quip) {
    state.whenOrNull(
      loaded: (forecast, _) {
        state = LocationForecastState.loaded(forecast: forecast, quip: quip);
      },
    );
  }

  Future<void> load() async {
    state = const LocationForecastState.loading();
    try {
      final forecast = await weatherRepo.getForecast(
        latitude: latitude,
        longitude: longitude,
      );
      final quip = quipRepo.getLocalQuip(
        weather: forecast.current,
        explicit: _explicit,
        persona: _persona,
      );
      if (!mounted) return;
      state = LocationForecastState.loaded(forecast: forecast, quip: quip);
    } catch (e) {
      if (!mounted) return;
      state = LocationForecastState.error(e.toString());
    }
  }

  Future<bool> refresh() async {
    try {
      final forecast = await weatherRepo.getForecast(
        latitude: latitude,
        longitude: longitude,
      );
      final quip = quipRepo.getLocalQuip(
        weather: forecast.current,
        explicit: _explicit,
        persona: _persona,
      );
      if (!mounted) return false;
      state = LocationForecastState.loaded(forecast: forecast, quip: quip);
      return true;
    } catch (e) {
      if (!mounted) return false;
      if (state is! _LocationLoaded) {
        state = LocationForecastState.error(e.toString());
      }
      return false;
    }
  }
}
