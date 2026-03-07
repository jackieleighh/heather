import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/app.dart';
import 'app/router.dart';
import 'core/services/background_alert_service.dart';
import 'core/services/device_registration_service.dart';
import 'core/services/fcm_service.dart';
import 'core/services/widget_service.dart';
import 'features/weather/data/repositories/weather_repository_impl.dart';
import 'features/weather/data/sources/saved_locations_local_source.dart';
import 'features/weather/domain/entities/forecast.dart';
import 'features/weather/domain/entities/location_info.dart';
import 'features/weather/domain/entities/saved_location.dart';
import 'features/weather/presentation/providers/location_provider.dart';
import 'features/weather/presentation/providers/weather_provider.dart';

Future<void> main() async {
  final binding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: binding);

  // Minimal pre-runApp init: only what's needed for instant widget render
  await WidgetService.init();
  final prefs = await SharedPreferences.getInstance();

  final onboardingCompleted = prefs.getBool('onboarding_completed') ?? false;
  final router = buildRouter(onboardingCompleted: onboardingCompleted);

  // Pre-read cached data synchronously so notifier constructors can
  // skip the loading state entirely on widget-launched cold starts.
  (LocationInfo, Forecast)? cachedWeatherSeed;
  List<SavedLocation>? savedLocationsSeed;
  Map<String, Forecast>? savedForecastsSeed;

  if (WidgetService.coldLaunchedFromWidget) {
    cachedWeatherSeed = WeatherRepositoryImpl.readCachedWeather(prefs);

    final savedLocs = SavedLocationsLocalSource.readSync(prefs);
    if (savedLocs.isNotEmpty) {
      savedLocationsSeed = savedLocs;
      final forecasts =
          WeatherRepositoryImpl.readCachedSavedForecasts(prefs, savedLocs);
      if (forecasts.isNotEmpty) savedForecastsSeed = forecasts;
    }
  }

  runApp(
    ProviderScope(
      overrides: [
        if (cachedWeatherSeed != null)
          cachedWeatherSeedProvider.overrideWith((_) => cachedWeatherSeed),
        if (savedLocationsSeed != null)
          savedLocationsSeedProvider.overrideWith((_) => savedLocationsSeed),
        if (savedForecastsSeed != null)
          cachedSavedForecastsSeedProvider
              .overrideWith((_) => savedForecastsSeed),
      ],
      child: HeatherApp(router: router),
    ),
  );

  // Heavy init runs AFTER first frame is on screen
  await Firebase.initializeApp();
  await Future.wait([
    BackgroundAlertService.init(),
    FcmService().init(),
    DeviceRegistrationService().init(),
  ]);
}
