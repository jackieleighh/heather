import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/app.dart';
import 'app/router.dart';
import 'core/network/api_client.dart';
import 'core/services/background_alert_service.dart';
import 'core/services/device_registration_service.dart';
import 'core/services/fcm_service.dart';
import 'core/services/widget_service.dart';
import 'features/weather/data/repositories/weather_repository_impl.dart';
import 'features/weather/data/sources/saved_locations_local_source.dart';
import 'features/weather/domain/entities/forecast.dart';
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

  // Detect when the native widget (iOS WidgetKit) has independently fetched
  // fresher data than the app's own cache. In that case, the app should
  // force-refresh from the API so it doesn't show stale data while the
  // widget shows something newer.
  if (WidgetService.widgetLastUpdated != null) {
    final cacheTsKey = prefs.getString('last_forecast_cache_ts_key');
    final cacheTs = cacheTsKey != null ? prefs.getInt(cacheTsKey) : null;
    final widgetMs = WidgetService.widgetLastUpdated!.millisecondsSinceEpoch;
    if (cacheTs == null || widgetMs > cacheTs) {
      WidgetService.widgetDataIsNewer = true;
    }
  }

  // Always read the full cached forecast so providers start in `loaded`
  // state when cache exists.
  var cachedWeatherSeed = WeatherRepositoryImpl.readCachedWeather(
    prefs,
    overrideLat: WidgetService.coldLaunchedFromWidget
        ? WidgetService.widgetLatitude
        : null,
    overrideLon: WidgetService.coldLaunchedFromWidget
        ? WidgetService.widgetLongitude
        : null,
    overrideCityName: WidgetService.coldLaunchedFromWidget
        ? WidgetService.widgetCityName
        : null,
  );

  // When the widget has fresher data, overlay its current conditions onto
  // the cached forecast so the user immediately sees the same temperature
  // and condition the widget shows — while keeping the full 10-day/24-hour
  // structure intact for the detail pages.
  if (WidgetService.coldLaunchedFromWidget || WidgetService.widgetDataIsNewer) {
    cachedWeatherSeed = WidgetService.applyWidgetOverlay(cachedWeatherSeed);
  }

  List<SavedLocation>? savedLocationsSeed;
  Map<String, Forecast>? savedForecastsSeed;

  final savedLocs = SavedLocationsLocalSource.readSync(prefs);
  if (savedLocs.isNotEmpty) {
    savedLocationsSeed = savedLocs;
    final forecasts =
        WeatherRepositoryImpl.readCachedSavedForecasts(prefs, savedLocs);
    if (forecasts.isNotEmpty) savedForecastsSeed = forecasts;
  }

  if (kDebugMode) {
    debugPrint('[launch] weatherSeed=${cachedWeatherSeed != null}, '
        'savedLocs=${savedLocationsSeed?.length ?? 0}, '
        'savedForecasts=${savedForecastsSeed?.length ?? 0}, '
        'widgetColdLaunch=${WidgetService.coldLaunchedFromWidget}, '
        'widgetDataIsNewer=${WidgetService.widgetDataIsNewer}, '
        'widgetLastUpdated=${WidgetService.widgetLastUpdated}');
  }

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
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
