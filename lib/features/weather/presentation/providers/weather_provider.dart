import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/storage/secure_storage.dart';
import '../../data/repositories/quip_repository_impl.dart';
import '../../data/repositories/weather_repository_impl.dart';
import '../../data/sources/location_source.dart';
import '../../data/sources/quip_remote_source.dart';
import '../../data/sources/weather_remote_source.dart';
import '../../domain/entities/forecast.dart';
import '../../domain/entities/location_info.dart';
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
      final explicit = ref.watch(settingsProvider).explicitLanguage;
      return WeatherNotifier(
        weatherRepo: ref.watch(weatherRepositoryProvider),
        quipRepo: ref.watch(quipRepositoryProvider),
        explicit: explicit,
      );
    });

class WeatherNotifier extends StateNotifier<WeatherState> {
  final WeatherRepositoryImpl weatherRepo;
  final QuipRepositoryImpl quipRepo;
  final bool explicit;

  WeatherNotifier({
    required this.weatherRepo,
    required this.quipRepo,
    required this.explicit,
  }) : super(const WeatherState.loading()) {
    loadWeather();
  }

  Future<void> loadWeather() async {
    state = const WeatherState.loading();
    try {
      final location = await weatherRepo.getCurrentLocation();
      final forecast = await weatherRepo.getForecast(
        latitude: location.latitude,
        longitude: location.longitude,
      );
      final quip = await quipRepo.getQuip(
        weather: forecast.current,
        cityName: location.cityName,
        explicit: explicit,
      );
      if (!mounted) return;
      state = WeatherState.loaded(
        forecast: forecast,
        location: location,
        quip: quip,
      );
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
      final quip = await quipRepo.getQuip(
        weather: forecast.current,
        cityName: location.cityName,
        explicit: explicit,
      );
      if (!mounted) return false;
      state = WeatherState.loaded(
        forecast: forecast,
        location: location,
        quip: quip,
      );
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
      final explicit = ref.watch(settingsProvider).explicitLanguage;
      return LocationForecastNotifier(
        weatherRepo: ref.watch(weatherRepositoryProvider),
        quipRepo: ref.watch(quipRepositoryProvider),
        name: params.name,
        latitude: params.lat,
        longitude: params.lon,
        explicit: explicit,
      );
    });

class LocationForecastNotifier extends StateNotifier<LocationForecastState> {
  final WeatherRepositoryImpl weatherRepo;
  final QuipRepositoryImpl quipRepo;
  final String name;
  final double latitude;
  final double longitude;
  final bool explicit;

  LocationForecastNotifier({
    required this.weatherRepo,
    required this.quipRepo,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.explicit,
  }) : super(const LocationForecastState.loading()) {
    load();
  }

  Future<void> load() async {
    state = const LocationForecastState.loading();
    try {
      final forecast = await weatherRepo.getForecast(
        latitude: latitude,
        longitude: longitude,
      );
      final quip = await quipRepo.getQuip(
        weather: forecast.current,
        cityName: name,
        explicit: explicit,
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
      final quip = await quipRepo.getQuip(
        weather: forecast.current,
        cityName: name,
        explicit: explicit,
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
