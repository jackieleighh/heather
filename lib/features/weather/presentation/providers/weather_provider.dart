import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/services/widget_service.dart';
import '../../data/repositories/quip_repository_impl.dart';
import '../../data/repositories/weather_repository_impl.dart';
import '../../data/sources/location_source.dart';
import '../../data/sources/weather_remote_source.dart';
import '../../domain/entities/forecast.dart';
import '../../domain/entities/location_info.dart';
import '../../domain/entities/temperature_tier.dart';
import '../../domain/entities/weather_alert.dart';
import '../../domain/entities/weather_condition.dart';
import 'alert_provider.dart';
import 'settings_provider.dart';

part 'weather_provider.freezed.dart';

typedef _QuipKey = ({WeatherCondition condition, TemperatureTier tier, bool isDay});

_QuipKey _quipKeyFor(Forecast forecast) => (
  condition: forecast.current.condition,
  tier: TemperatureTier.fromTemperature(forecast.current.temperature),
  isDay: forecast.isCurrentlyDay,
);

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
    @Default([]) List<WeatherAlert> alerts,
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
      );

      ref.listen<SettingsState>(settingsProvider, (previous, next) {
        if (previous?.explicitLanguage != next.explicitLanguage) {
          notifier.updateExplicit(next.explicitLanguage);
        }
      });

      return notifier;
    });

class WeatherNotifier extends StateNotifier<WeatherState> {
  final WeatherRepositoryImpl weatherRepo;
  final QuipRepositoryImpl quipRepo;
  bool _explicit;
  _QuipKey? _lastQuipKey;
  bool isLocationPermissionError = false;
  bool isLocationServiceDisabled = false;

  WeatherNotifier({
    required this.weatherRepo,
    required this.quipRepo,
    required bool explicit,
  }) : _explicit = explicit,
       super(const WeatherState.loading()) {
    loadWeather();
  }

  void updateExplicit(bool value) {
    _explicit = value;
    _swapLocalQuip();
  }

  void _swapLocalQuip() {
    final current = state;
    current.whenOrNull(
      loaded: (forecast, location, _, alerts) {
        final quip = quipRepo.getLocalQuip(
          weather: forecast.current,
          explicit: _explicit,
        );
        _lastQuipKey = _quipKeyFor(forecast);
        state = WeatherState.loaded(
          forecast: forecast,
          location: location,
          quip: quip,
          alerts: alerts,
        );
        _pushToWidget();
      },
    );
  }

  void updateQuip(String quip) {
    state.whenOrNull(
      loaded: (forecast, location, _, alerts) {
        state = WeatherState.loaded(
          forecast: forecast,
          location: location,
          quip: quip,
          alerts: alerts,
        );
        _pushToWidget();
      },
    );
  }

  void _pushToWidget() {
    final current = state;
    if (current is! _Loaded) return;
    WidgetService.updateWidget(
      forecast: current.forecast,
      location: current.location,
      quip: current.quip,
      explicit: _explicit,
    );
  }

  Future<void> loadWeather() async {
    state = const WeatherState.loading();
    isLocationPermissionError = false;
    isLocationServiceDisabled = false;
    try {
      final location = await weatherRepo.getCurrentLocation();
      final results = await Future.wait([
        weatherRepo.getForecast(
          latitude: location.latitude,
          longitude: location.longitude,
        ),
        fetchAlerts(latitude: location.latitude, longitude: location.longitude),
      ]);
      final forecast = results[0] as Forecast;
      final alerts = results[1] as List<WeatherAlert>;
      final quip = quipRepo.getLocalQuip(
        weather: forecast.current,
        explicit: _explicit,
      );
      _lastQuipKey = _quipKeyFor(forecast);
      if (!mounted) return;
      state = WeatherState.loaded(
        forecast: forecast,
        location: location,
        quip: quip,
        alerts: alerts,
      );
      _pushToWidget();
    } catch (e) {
      if (!mounted) return;
      if (e is LocationPermissionException) {
        isLocationPermissionError = true;
        isLocationServiceDisabled = e.isServiceDisabled;
      }
      state = WeatherState.error(e.toString());
    }
  }

  void forceTimeout() {
    if (state == const WeatherState.loading()) {
      state = const WeatherState.error(
        "Heather's taking forever to load. Check your connection and try again, babe.",
      );
    }
  }

  Future<bool> refresh({bool forceRefresh = false}) async {
    try {
      final location = await weatherRepo.getCurrentLocation();
      final results = await Future.wait([
        weatherRepo.getForecast(
          latitude: location.latitude,
          longitude: location.longitude,
          forceRefresh: forceRefresh,
        ),
        fetchAlerts(latitude: location.latitude, longitude: location.longitude),
      ]);
      final forecast = results[0] as Forecast;
      final alerts = results[1] as List<WeatherAlert>;
      final newKey = _quipKeyFor(forecast);
      final String quip;
      if (newKey == _lastQuipKey && state is _Loaded) {
        quip = (state as _Loaded).quip;
      } else {
        quip = quipRepo.getLocalQuip(
          weather: forecast.current,
          explicit: _explicit,
        );
        _lastQuipKey = newKey;
      }
      if (!mounted) return false;
      state = WeatherState.loaded(
        forecast: forecast,
        location: location,
        quip: quip,
        alerts: alerts,
      );
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
    @Default([]) List<WeatherAlert> alerts,
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
  _QuipKey? _lastQuipKey;

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
    _swapLocalQuip();
  }

  void _swapLocalQuip() {
    state.whenOrNull(
      loaded: (forecast, _, alerts) {
        final quip = quipRepo.getLocalQuip(
          weather: forecast.current,
          explicit: _explicit,
        );
        _lastQuipKey = _quipKeyFor(forecast);
        state = LocationForecastState.loaded(
          forecast: forecast,
          quip: quip,
          alerts: alerts,
        );
      },
    );
  }

  void updateQuip(String quip) {
    state.whenOrNull(
      loaded: (forecast, _, alerts) {
        state = LocationForecastState.loaded(
          forecast: forecast,
          quip: quip,
          alerts: alerts,
        );
      },
    );
  }

  Future<void> load() async {
    state = const LocationForecastState.loading();
    try {
      final results = await Future.wait([
        weatherRepo.getForecast(latitude: latitude, longitude: longitude),
        fetchAlerts(latitude: latitude, longitude: longitude),
      ]);
      final forecast = results[0] as Forecast;
      final alerts = results[1] as List<WeatherAlert>;
      final quip = quipRepo.getLocalQuip(
        weather: forecast.current,
        explicit: _explicit,
      );
      _lastQuipKey = _quipKeyFor(forecast);
      if (!mounted) return;
      state = LocationForecastState.loaded(
        forecast: forecast,
        quip: quip,
        alerts: alerts,
      );
    } catch (e) {
      if (!mounted) return;
      state = LocationForecastState.error(e.toString());
    }
  }

  Future<bool> refresh({bool forceRefresh = false}) async {
    try {
      final results = await Future.wait([
        weatherRepo.getForecast(
          latitude: latitude,
          longitude: longitude,
          forceRefresh: forceRefresh,
        ),
        fetchAlerts(latitude: latitude, longitude: longitude),
      ]);
      final forecast = results[0] as Forecast;
      final alerts = results[1] as List<WeatherAlert>;
      final newKey = _quipKeyFor(forecast);
      final String quip;
      if (newKey == _lastQuipKey && state is _LocationLoaded) {
        quip = (state as _LocationLoaded).quip;
      } else {
        quip = quipRepo.getLocalQuip(
          weather: forecast.current,
          explicit: _explicit,
        );
        _lastQuipKey = newKey;
      }
      if (!mounted) return false;
      state = LocationForecastState.loaded(
        forecast: forecast,
        quip: quip,
        alerts: alerts,
      );
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
