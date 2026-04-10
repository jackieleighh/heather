import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  final apiClient = ref.watch(apiClientProvider);
  final prefs = ref.watch(sharedPreferencesProvider);
  return WeatherRepositoryImpl(
    remoteSource: WeatherRemoteSource(dio: apiClient.weatherClient),
    locationSource: LocationSource(),
    prefs: prefs,
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

// Seed provider: holds pre-read cached weather for synchronous constructor use
final cachedWeatherSeedProvider =
    StateProvider<(LocationInfo, Forecast)?>((_) => null);

// Main provider
final weatherStateProvider =
    StateNotifierProvider<WeatherNotifier, WeatherState>((ref) {
      final settings = ref.read(settingsProvider);
      final seed = ref.read(cachedWeatherSeedProvider);
      // Defer clearing seed to avoid modifying another provider during initialization
      Future.microtask(() => ref.read(cachedWeatherSeedProvider.notifier).state = null);

      final notifier = WeatherNotifier(
        weatherRepo: ref.watch(weatherRepositoryProvider),
        quipRepo: ref.watch(quipRepositoryProvider),
        dio: ref.watch(dioProvider),
        explicit: settings.explicitLanguage,
        cachedSeed: seed,
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
  final Dio dio;
  bool _explicit;
  _QuipKey? _lastQuipKey;
  bool isLocationPermissionError = false;
  bool isLocationServiceDisabled = false;
  int _loadGeneration = 0;

  WeatherNotifier({
    required this.weatherRepo,
    required this.quipRepo,
    required this.dio,
    required bool explicit,
    (LocationInfo, Forecast)? cachedSeed,
  }) : _explicit = explicit,
       super(
         _initialState(cachedSeed, quipRepo, explicit),
       ) {
    // A seed is only usable if it has full forecast data. The standalone
    // widget seed (no cached forecast) carries just a current-conditions
    // snapshot with empty daily/hourly, which can't render the full UI —
    // treat it as no seed so we show LoadingScreen and call loadWeather().
    final hasUsableSeed = cachedSeed != null &&
        cachedSeed.$2.daily.isNotEmpty &&
        cachedSeed.$2.hourly.isNotEmpty;
    if (hasUsableSeed) {
      _lastQuipKey = _quipKeyFor(cachedSeed.$2);
      // Force-refresh when the native widget has fresher data than the
      // app's cache, or when cold-launched from a widget tap.
      refresh(
        forceRefresh: WidgetService.coldLaunchedFromWidget ||
            WidgetService.widgetDataIsNewer,
      );
    } else {
      loadWeather();
    }
  }

  /// Compute the initial state for [super] so Riverpod never sees `loading`
  /// when a usable cached seed is available.
  static WeatherState _initialState(
    (LocationInfo, Forecast)? seed,
    QuipRepositoryImpl quipRepo,
    bool explicit,
  ) {
    if (seed == null ||
        seed.$2.daily.isEmpty ||
        seed.$2.hourly.isEmpty) {
      return const WeatherState.loading();
    }
    final (location, forecast) = seed;
    return WeatherState.loaded(
      forecast: forecast,
      location: location,
      quip: quipRepo.getLocalQuip(weather: forecast.current, explicit: explicit),
    );
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

  Future<void> _pushToWidget() async {
    final current = state;
    if (current is! _Loaded) return;

    // Read cached visible planets from SharedPreferences
    List<String> planets = const [];
    try {
      final prefs = await SharedPreferences.getInstance();
      final lat = current.location.latitude;
      final lon = current.location.longitude;
      final cachedJson = prefs.getString('cached_planets_${lat}_$lon');
      if (cachedJson != null) {
        planets = (jsonDecode(cachedJson) as List).cast<String>();
      }
    } catch (_) {}

    WidgetService.updateWidget(
      forecast: current.forecast,
      location: current.location,
      quip: current.quip,
      explicit: _explicit,
      alerts: current.alerts,
      visiblePlanets: planets,
    );
  }

  Future<void> loadWeather() async {
    final gen = ++_loadGeneration;
    state = const WeatherState.loading();
    isLocationPermissionError = false;
    isLocationServiceDisabled = false;

    const maxAttempts = 4;
    const backoffDurations = [
      Duration(seconds: 1),
      Duration(seconds: 2),
      Duration(seconds: 4),
    ];

    for (var attempt = 0; attempt < maxAttempts; attempt++) {
      if (_loadGeneration != gen) return;
      try {
        final location = await weatherRepo.getCurrentLocation();
        if (_loadGeneration != gen) return;
        final results = await Future.wait([
          weatherRepo.getForecast(
            latitude: location.latitude,
            longitude: location.longitude,
          ),
          fetchAlerts(
            latitude: location.latitude,
            longitude: location.longitude,
            dio: dio,
          ),
        ]);
        if (_loadGeneration != gen) return;
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
        return;
      } catch (e) {
        if (_loadGeneration != gen) return;
        if (!mounted) return;
        if (e is LocationPermissionException) {
          isLocationPermissionError = true;
          isLocationServiceDisabled = e.isServiceDisabled;
          state = WeatherState.error(e.toString());
          return;
        }
        if (attempt < maxAttempts - 1) {
          await Future.delayed(backoffDurations[attempt]);
          if (_loadGeneration != gen) return;
          if (!mounted) return;
        } else {
          state = WeatherState.error(e.toString());
        }
      }
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
        fetchAlerts(latitude: location.latitude, longitude: location.longitude, dio: dio),
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

// Seed provider: holds pre-read cached saved-location forecasts
final cachedSavedForecastsSeedProvider =
    StateProvider<Map<String, Forecast>?>((_) => null);

final savedLocationsForecastProvider = StateNotifierProvider<
  SavedLocationsForecastNotifier,
  SavedLocationsForecastState
>((ref) {
  final settings = ref.read(settingsProvider);
  final seed = ref.read(cachedSavedForecastsSeedProvider);
  // Defer clearing seed to avoid modifying another provider during initialization
  Future.microtask(() => ref.read(cachedSavedForecastsSeedProvider.notifier).state = null);

  final notifier = SavedLocationsForecastNotifier(
    weatherRepo: ref.watch(weatherRepositoryProvider),
    quipRepo: ref.watch(quipRepositoryProvider),
    dio: ref.watch(dioProvider),
    explicit: settings.explicitLanguage,
    cachedSeed: seed,
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
  final Dio dio;
  bool _explicit;
  final Map<String, _QuipKey> _lastQuipKeys = {};

  SavedLocationsForecastNotifier({
    required this.weatherRepo,
    required this.quipRepo,
    required this.dio,
    required bool explicit,
    Map<String, Forecast>? cachedSeed,
  }) : _explicit = explicit,
       super(_initialState(cachedSeed, quipRepo, explicit)) {
    if (cachedSeed != null && cachedSeed.isNotEmpty) {
      for (final entry in cachedSeed.entries) {
        _lastQuipKeys[entry.key] = _quipKeyFor(entry.value);
      }
    }
  }

  static SavedLocationsForecastState _initialState(
    Map<String, Forecast>? seed,
    QuipRepositoryImpl quipRepo,
    bool explicit,
  ) {
    if (seed == null || seed.isEmpty) {
      return const SavedLocationsForecastState.loading();
    }
    final forecasts = <String, LocationForecastData>{};
    for (final entry in seed.entries) {
      forecasts[entry.key] = (
        forecast: entry.value,
        quip: quipRepo.getLocalQuip(
          weather: entry.value.current,
          explicit: explicit,
        ),
        alerts: const [],
      );
    }
    return SavedLocationsForecastState.loaded(forecasts: forecasts);
  }

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

  Map<String, LocationForecastData> _buildForecasts(
    List<SavedLocation> locations,
    Map<String, Forecast> forecastResults,
    List<List<WeatherAlert>> alertResults,
  ) {
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
    return forecasts;
  }

  Future<void> load(List<SavedLocation> locations) async {
    if (locations.isEmpty) {
      state = const SavedLocationsForecastState.loaded(forecasts: {});
      return;
    }
    // If already loaded (e.g. from seed), refresh in background instead of
    // resetting to loading which would flash a loading view.
    if (state is _SavedLoaded) {
      refresh(locations);
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

      final alertResults = await Future.wait(
        locations.map(
          (loc) => fetchAlerts(
            latitude: loc.latitude,
            longitude: loc.longitude,
            dio: dio,
          ),
        ),
      );

      if (!mounted) return;
      state = SavedLocationsForecastState.loaded(
        forecasts: _buildForecasts(locations, forecastResults, alertResults),
      );
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

      final alertResults = await Future.wait(
        locations.map(
          (loc) => fetchAlerts(
            latitude: loc.latitude,
            longitude: loc.longitude,
            dio: dio,
          ),
        ),
      );

      if (!mounted) return false;
      state = SavedLocationsForecastState.loaded(
        forecasts: _buildForecasts(locations, forecastResults, alertResults),
      );
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
