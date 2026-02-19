import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/constants/persona.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/services/widget_service.dart';
import '../../data/repositories/quip_repository_impl.dart';
import '../../data/repositories/weather_repository_impl.dart';
import '../../data/sources/location_source.dart';
import '../../data/sources/weather_remote_source.dart';
import '../../domain/entities/forecast.dart';
import '../../domain/entities/location_info.dart';
import '../../domain/entities/temperature_tier.dart';
import '../../domain/entities/weather_condition.dart';
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
      );

      ref.listen<SettingsState>(settingsProvider, (previous, next) {
        if (previous?.explicitLanguage != next.explicitLanguage) {
          notifier.updateExplicit(next.explicitLanguage);
        }
        // final personaChanged = previous?.persona != next.persona;
        // if (personaChanged) {
        //   notifier.updatePersona(next.persona);
        // }
      });

      return notifier;
    });

class WeatherNotifier extends StateNotifier<WeatherState> {
  final WeatherRepositoryImpl weatherRepo;
  final QuipRepositoryImpl quipRepo;
  bool _explicit;
  final Persona _persona; // made final while persona switching is disabled
  _QuipKey? _lastQuipKey;

  WeatherNotifier({
    required this.weatherRepo,
    required this.quipRepo,
    required bool explicit,
    required Persona persona,
  }) : _explicit = explicit,
       _persona = persona,
       super(const WeatherState.loading()) {
    loadWeather();
  }

  void updateExplicit(bool value) {
    _explicit = value;
    _swapLocalQuip();
  }

  // void updatePersona(Persona persona) {
  //   _persona = persona;
  //   _swapLocalQuip();
  // }

  void _swapLocalQuip() {
    final current = state;
    current.whenOrNull(
      loaded: (forecast, location, _) {
        final quip = quipRepo.getLocalQuip(
          weather: forecast.current,
          explicit: _explicit,
          persona: _persona,
        );
        _lastQuipKey = _quipKeyFor(forecast);
        state = WeatherState.loaded(
          forecast: forecast,
          location: location,
          quip: quip,
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
      _lastQuipKey = _quipKeyFor(forecast);
      if (!mounted) return;
      state = WeatherState.loaded(
        forecast: forecast,
        location: location,
        quip: quip,
      );
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
      final newKey = _quipKeyFor(forecast);
      final String quip;
      if (newKey == _lastQuipKey && state is _Loaded) {
        quip = (state as _Loaded).quip;
      } else {
        quip = quipRepo.getLocalQuip(
          weather: forecast.current,
          explicit: _explicit,
          persona: _persona,
        );
        _lastQuipKey = newKey;
      }
      if (!mounted) return false;
      state = WeatherState.loaded(
        forecast: forecast,
        location: location,
        quip: quip,
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
        if (previous?.explicitLanguage != next.explicitLanguage) {
          notifier.updateExplicit(next.explicitLanguage);
        }
        // final personaChanged = previous?.persona != next.persona;
        // if (personaChanged) {
        //   notifier.updatePersona(next.persona);
        // }
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
  final Persona _persona; // made final while persona switching is disabled
  _QuipKey? _lastQuipKey;

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

  // void updatePersona(Persona persona) {
  //   _persona = persona;
  //   _swapLocalQuip();
  // }

  void _swapLocalQuip() {
    state.whenOrNull(
      loaded: (forecast, _) {
        final quip = quipRepo.getLocalQuip(
          weather: forecast.current,
          explicit: _explicit,
          persona: _persona,
        );
        _lastQuipKey = _quipKeyFor(forecast);
        state = LocationForecastState.loaded(forecast: forecast, quip: quip);
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
      _lastQuipKey = _quipKeyFor(forecast);
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
      final newKey = _quipKeyFor(forecast);
      final String quip;
      if (newKey == _lastQuipKey && state is _LocationLoaded) {
        quip = (state as _LocationLoaded).quip;
      } else {
        quip = quipRepo.getLocalQuip(
          weather: forecast.current,
          explicit: _explicit,
          persona: _persona,
        );
        _lastQuipKey = newKey;
      }
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
