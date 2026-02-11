import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../core/storage/secure_storage.dart';
import '../../data/repositories/quip_repository_impl.dart';
import '../../data/repositories/weather_repository_impl.dart';
import '../../data/sources/location_source.dart';
import '../../data/sources/quip_remote_source.dart';
import '../../data/sources/weather_remote_source.dart';
import '../../domain/entities/forecast.dart';
import '../../domain/entities/location_info.dart';
import '../../domain/entities/weather.dart';
import 'location_provider.dart';
import 'settings_provider.dart';

part 'weather_provider.freezed.dart';

// Dependencies
final apiClientProvider = Provider<ApiClient>((ref) => ApiClient());

final secureStorageProvider = Provider<SecureStorage>((ref) => SecureStorage());

final weatherRepositoryProvider = Provider<WeatherRepositoryImpl>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return WeatherRepositoryImpl(
    remoteSource: WeatherRemoteSource(dio: apiClient.weatherClient),
    locationSource: LocationSource(),
  );
});

final quipRepositoryProvider = Provider<QuipRepositoryImpl>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  final secureStorage = ref.watch(secureStorageProvider);
  return QuipRepositoryImpl(
    remoteSource: QuipRemoteSource(apiClient: apiClient),
    secureStorage: secureStorage,
  );
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
      final explicit = ref.read(settingsProvider).explicitLanguage;
      final settings = ref.read(settingsProvider);
      final notifier = WeatherNotifier(
        weatherRepo: ref.watch(weatherRepositoryProvider),
        quipRepo: ref.watch(quipRepositoryProvider),
        explicit: explicit,
        notificationsEnabled: settings.notificationsEnabled,
        notificationTime: settings.notificationTime,
      );

      ref.listen<SettingsState>(settingsProvider, (previous, next) {
        if (previous?.explicitLanguage != next.explicitLanguage) {
          notifier.updateExplicit(next.explicitLanguage);
          // Batch-refresh Gemini quips for all locations with new tone
          ref.read(batchQuipLoaderProvider).loadBatchQuips();
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
  bool _notificationsEnabled;
  TimeOfDay _notificationTime;

  WeatherNotifier({
    required this.weatherRepo,
    required this.quipRepo,
    required bool explicit,
    required bool notificationsEnabled,
    required TimeOfDay notificationTime,
  }) : _explicit = explicit,
       _notificationsEnabled = notificationsEnabled,
       _notificationTime = notificationTime,
       super(const WeatherState.loading()) {
    loadWeather();
  }

  void updateExplicit(bool value) {
    _explicit = value;
    // Swap to a local quip immediately; batch loader will upgrade to Gemini
    final current = state;
    current.whenOrNull(
      loaded: (forecast, location, _) {
        state = WeatherState.loaded(
          forecast: forecast,
          location: location,
          quip: quipRepo.getLocalQuip(
            weather: forecast.current,
            explicit: _explicit,
          ),
        );
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
      title: NotificationService.randomTitle,
      body: body,
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
      // Use instant local quip; batch loader will upgrade to Gemini
      final quip = quipRepo.getLocalQuip(
        weather: forecast.current,
        explicit: _explicit,
      );
      if (!mounted) return;
      state = WeatherState.loaded(
        forecast: forecast,
        location: location,
        quip: quip,
      );
      _scheduleNotificationIfNeeded();
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
      );
      if (!mounted) return false;
      state = WeatherState.loaded(
        forecast: forecast,
        location: location,
        quip: quip,
      );
      _scheduleNotificationIfNeeded();
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
      final explicit = ref.read(settingsProvider).explicitLanguage;
      final notifier = LocationForecastNotifier(
        weatherRepo: ref.watch(weatherRepositoryProvider),
        quipRepo: ref.watch(quipRepositoryProvider),
        name: params.name,
        latitude: params.lat,
        longitude: params.lon,
        explicit: explicit,
      );

      ref.listen<SettingsState>(settingsProvider, (previous, next) {
        if (previous?.explicitLanguage != next.explicitLanguage) {
          notifier.updateExplicit(next.explicitLanguage);
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

  LocationForecastNotifier({
    required this.weatherRepo,
    required this.quipRepo,
    required this.name,
    required this.latitude,
    required this.longitude,
    required bool explicit,
  }) : _explicit = explicit,
       super(const LocationForecastState.loading()) {
    load();
  }

  void updateExplicit(bool value) {
    _explicit = value;
    state.whenOrNull(
      loaded: (forecast, _) {
        state = LocationForecastState.loaded(
          forecast: forecast,
          quip: quipRepo.getLocalQuip(
            weather: forecast.current,
            explicit: _explicit,
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

// ── Batch quip loader ─────────────────────────────────────────────

final batchQuipLoaderProvider = Provider<BatchQuipLoader>((ref) {
  return BatchQuipLoader(ref);
});

class BatchQuipLoader {
  final Ref _ref;

  BatchQuipLoader(this._ref);

  Future<void> loadBatchQuips() async {
    final weatherState = _ref.read(weatherStateProvider);
    final savedLocations = _ref.read(savedLocationsProvider);
    final settings = _ref.read(settingsProvider);
    final quipRepo = _ref.read(quipRepositoryProvider);

    final locations = <({Weather weather, String cityName})>[];
    String? gpsCityName;

    weatherState.whenOrNull(
      loaded: (forecast, location, _) {
        gpsCityName = location.cityName;
        locations.add((weather: forecast.current, cityName: location.cityName));
      },
    );

    for (final loc in savedLocations) {
      final params = (name: loc.name, lat: loc.latitude, lon: loc.longitude);
      final locState = _ref.read(locationForecastProvider(params));
      locState.whenOrNull(
        loaded: (forecast, _) {
          locations.add((weather: forecast.current, cityName: loc.name));
        },
      );
    }

    if (locations.isEmpty) return;

    final quips = await quipRepo.getBatchQuips(
      locations: locations,
      explicit: settings.explicitLanguage,
    );

    // Distribute quips to each notifier
    if (gpsCityName != null && quips.containsKey(gpsCityName)) {
      _ref.read(weatherStateProvider.notifier).updateQuip(quips[gpsCityName]!);
    }

    for (final loc in savedLocations) {
      if (quips.containsKey(loc.name)) {
        final params = (name: loc.name, lat: loc.latitude, lon: loc.longitude);
        _ref
            .read(locationForecastProvider(params).notifier)
            .updateQuip(quips[loc.name]!);
      }
    }
  }
}
