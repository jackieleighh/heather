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
import 'features/weather/domain/entities/forecast.dart';
import 'features/weather/domain/entities/location_info.dart';
import 'features/weather/presentation/providers/weather_provider.dart';

Future<void> main() async {
  final binding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: binding);

  // Minimal pre-runApp init: only what's needed for instant widget render
  await WidgetService.init();
  final prefs = await SharedPreferences.getInstance();

  final onboardingCompleted = prefs.getBool('onboarding_completed') ?? false;
  final router = buildRouter(onboardingCompleted: onboardingCompleted);

  // Pre-read cached weather synchronously so the notifier constructor can
  // skip the loading state entirely on widget-launched cold starts.
  (LocationInfo, Forecast)? cachedWeatherSeed;
  if (WidgetService.coldLaunchedFromWidget) {
    cachedWeatherSeed = WeatherRepositoryImpl.readCachedWeather(prefs);
  }

  runApp(
    ProviderScope(
      overrides: [
        if (cachedWeatherSeed != null)
          cachedWeatherSeedProvider.overrideWith((_) => cachedWeatherSeed),
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
