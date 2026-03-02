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
import '../../domain/entities/saved_location.dart';
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

// Batch provider for all saved location forecasts (single API call)
typedef LocationForecastData =
    ({Forecast forecast, String quip, List<WeatherAlert> alerts});

@freezed
class SavedLocationsForecastState with _$SavedLocationsForecastState {
  const factory SavedLocationsForecastState.loading() = _SavedLoading;
  const factory SavedLocationsForecastState.loaded({
    required Map<String, LocationForecastData> forecasts,
  }) = _SavedLoaded;
  const factory SavedLocationsForecastState.error(String message) =
      _SavedError;
}

final savedLocationsForecastProvider = StateNotifierProvider<
  SavedLocationsForecastNotifier,
  SavedLocationsForecastState
>((ref) {
  final settings = ref.read(settingsProvider);
  final notifier = SavedLocationsForecastNotifier(
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

class SavedLocationsForecastNotifier
    extends StateNotifier<SavedLocationsForecastState> {
  final WeatherRepositoryImpl weatherRepo;
  final QuipRepositoryImpl quipRepo;
  bool _explicit;
  final Map<String, _QuipKey> _lastQuipKeys = {};

  SavedLocationsForecastNotifier({
    required this.weatherRepo,
    required this.quipRepo,
    required bool explicit,
  }) : _explicit = explicit,
       super(const SavedLocationsForecastState.loading());

  void updateExplicit(bool value) {
    _explicit = value;
    _swapLocalQuips();
  }

  void _swapLocalQuips() {
    final current = state;
    if (current is! _SavedLoaded) return;
    final updated = <String, LocationForecastData>{};
    for (final entry in current.forecasts.entries) {
      final forecast = entry.value.forecast;
      final quip = quipRepo.getLocalQuip(
        weather: forecast.current,
        explicit: _explicit,
      );
      _lastQuipKeys[entry.key] = _quipKeyFor(forecast);
      updated[entry.key] = (
        forecast: forecast,
        quip: quip,
        alerts: entry.value.alerts,
      );
    }
    state = SavedLocationsForecastState.loaded(forecasts: updated);
  }

  Future<void> load(List<SavedLocation> locations) async {
    if (locations.isEmpty) {
      state = const SavedLocationsForecastState.loaded(forecasts: {});
      return;
    }
    state = const SavedLocationsForecastState.loading();
    try {
      final batchLocations = locations
          .map(
            (loc) => (
              id: loc.id,
              latitude: loc.latitude,
              longitude: loc.longitude,
            ),
          )
          .toList();

      final forecastResults = await weatherRepo.getForecastBatch(
        locations: batchLocations,
      );

      // Fetch alerts in parallel for each location
      final alertFutures = locations.map(
        (loc) => fetchAlerts(
          latitude: loc.latitude,
          longitude: loc.longitude,
        ),
      );
      final alertResults = await Future.wait(alertFutures);

      final forecasts = <String, LocationForecastData>{};
      for (var i = 0; i < locations.length; i++) {
        final loc = locations[i];
        final forecast = forecastResults[loc.id];
        if (forecast == null) continue;
        final alerts = alertResults[i];

        final newKey = _quipKeyFor(forecast);
        final String quip;
        if (newKey == _lastQuipKeys[loc.id] &&
            state is _SavedLoaded &&
            (state as _SavedLoaded).forecasts.containsKey(loc.id)) {
          quip = (state as _SavedLoaded).forecasts[loc.id]!.quip;
        } else {
          quip = quipRepo.getLocalQuip(
            weather: forecast.current,
            explicit: _explicit,
          );
          _lastQuipKeys[loc.id] = newKey;
        }

        forecasts[loc.id] = (
          forecast: forecast,
          quip: quip,
          alerts: alerts,
        );
      }

      if (!mounted) return;
      state = SavedLocationsForecastState.loaded(forecasts: forecasts);
    } catch (e) {
      if (!mounted) return;
      state = SavedLocationsForecastState.error(e.toString());
    }
  }

  Future<bool> refresh(
    List<SavedLocation> locations, {
    bool forceRefresh = false,
  }) async {
    if (locations.isEmpty) {
      state = const SavedLocationsForecastState.loaded(forecasts: {});
      return true;
    }
    try {
      final batchLocations = locations
          .map(
            (loc) => (
              id: loc.id,
              latitude: loc.latitude,
              longitude: loc.longitude,
            ),
          )
          .toList();

      final forecastResults = await weatherRepo.getForecastBatch(
        locations: batchLocations,
        forceRefresh: forceRefresh,
      );

      final alertFutures = locations.map(
        (loc) => fetchAlerts(
          latitude: loc.latitude,
          longitude: loc.longitude,
        ),
      );
      final alertResults = await Future.wait(alertFutures);

      final forecasts = <String, LocationForecastData>{};
      for (var i = 0; i < locations.length; i++) {
        final loc = locations[i];
        final forecast = forecastResults[loc.id];
        if (forecast == null) continue;
        final alerts = alertResults[i];

        final newKey = _quipKeyFor(forecast);
        final String quip;
        if (newKey == _lastQuipKeys[loc.id] &&
            state is _SavedLoaded &&
            (state as _SavedLoaded).forecasts.containsKey(loc.id)) {
          quip = (state as _SavedLoaded).forecasts[loc.id]!.quip;
        } else {
          quip = quipRepo.getLocalQuip(
            weather: forecast.current,
            explicit: _explicit,
          );
          _lastQuipKeys[loc.id] = newKey;
        }

        forecasts[loc.id] = (
          forecast: forecast,
          quip: quip,
          alerts: alerts,
        );
      }

      if (!mounted) return false;
      state = SavedLocationsForecastState.loaded(forecasts: forecasts);
      return true;
    } catch (e) {
      if (!mounted) return false;
      if (state is! _SavedLoaded) {
        state = SavedLocationsForecastState.error(e.toString());
      }
      return false;
    }
  }
}
