import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:heather/features/weather/presentation/screens/error_screen.dart';
import 'package:heather/features/weather/domain/entities/saved_location.dart';
import 'package:heather/features/weather/presentation/screens/saved_locations_page.dart';
import 'package:heather/features/weather/presentation/widgets/logo_overlay.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/background_alert_service.dart';
import '../../../../core/services/fcm_service.dart';
import '../../../../core/services/widget_service.dart';
import '../../domain/entities/weather_alert.dart';
import '../providers/location_provider.dart';
import '../providers/settings_provider.dart';
import '../providers/weather_provider.dart';
import '../screens/alert_detail_sheet.dart';
import '../screens/location_search_screen.dart';
import '../widgets/animated_background/weather_background.dart';
import '../widgets/vertical_forecast_pager.dart';

class WeatherScreen extends ConsumerStatefulWidget {
  const WeatherScreen({super.key});

  @override
  ConsumerState<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends ConsumerState<WeatherScreen>
    with WidgetsBindingObserver {
  late PageController _horizontalController;
  final _verticalPagerKey = GlobalKey<VerticalForecastPagerState>();
  StreamSubscription<void>? _widgetTapSub;
  StreamSubscription<void>? _alertTapSub;
  Timer? _pollTimer;
  Timer? _splashTimeout;
  bool _minTimeElapsed = true;
  bool _splashRemoved = false;
  bool _initialRegistrationDone = false;
  int _currentHorizontalPage = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _horizontalController = PageController(initialPage: 0);
    _horizontalController.addListener(_onHorizontalPageChanged);
    _widgetTapSub = WidgetService.widgetTapped.stream.listen((_) {
      if (!mounted) return;
      _resetToFirstAndRefresh();
    });
    _alertTapSub = FcmService().alertTapped.listen((_) {
      _showPendingAlert();
    });
    _pollTimer = Timer.periodic(const Duration(minutes: 15), (_) {
      if (mounted) _refreshAll();
    });
    _splashTimeout = Timer(const Duration(seconds: 25), () {
      if (!_splashRemoved && mounted) {
        _splashRemoved = true;
        FlutterNativeSplash.remove();
        ref.read(weatherStateProvider.notifier).forceTimeout();
      }
    });
  }

  @override
  void dispose() {
    _splashTimeout?.cancel();
    _pollTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    _widgetTapSub?.cancel();
    _alertTapSub?.cancel();
    _horizontalController.removeListener(_onHorizontalPageChanged);
    _horizontalController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _refreshAll();
    }
  }

  void _resetToFirstAndRefresh() {
    if (_horizontalController.hasClients) {
      _horizontalController.jumpToPage(0);
    }
    _verticalPagerKey.currentState?.jumpToFirst();
    _refreshAll();
  }

  void _onHorizontalPageChanged() {
    final page = _horizontalController.page?.round() ?? 0;
    if (page != _currentHorizontalPage) {
      setState(() => _currentHorizontalPage = page);
    }
  }

  Future<void> _openLocationSearch() async {
    final added = await Navigator.of(context).push<bool>(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const LocationSearchScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final offset =
              Tween<Offset>(
                begin: const Offset(-1.0, 0.0),
                end: Offset.zero,
              ).animate(
                CurvedAnimation(parent: animation, curve: Curves.easeInOut),
              );
          return SlideTransition(position: offset, child: child);
        },
      ),
    );

    if (added == true && mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final savedLocations = ref.read(savedLocationsProvider);
        final targetPage = savedLocations
            .length; // GPS is page 0, last saved location is at this index
        if (_horizontalController.hasClients) {
          _horizontalController.animateToPage(
            targetPage,
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeInOut,
          );
        }
      });
    }
  }

  void _showSettings() {
    context.push('/settings');
  }

  void _showPendingAlert() {
    if (!mounted) return;
    final alerts = _collectAllAlerts();
    if (alerts.isNotEmpty) {
      FcmService().clearPendingAlertTap();
      showAlertDetailSheet(context, alerts);
    }
  }

  List<WeatherAlert> _collectAllAlerts() {
    final alerts = <WeatherAlert>[];
    final seenIds = <String>{};

    final state = ref.read(weatherStateProvider);
    state.whenOrNull(
      loaded: (forecast, location, quip, gpsAlerts) {
        for (final a in gpsAlerts) {
          if (seenIds.add(a.id)) alerts.add(a);
        }
      },
    );

    final savedLocations = ref.read(savedLocationsProvider);
    for (final loc in savedLocations) {
      final params = (name: loc.name, lat: loc.latitude, lon: loc.longitude);
      final locState = ref.read(locationForecastProvider(params));
      locState.whenOrNull(
        loaded: (forecast, quip, locAlerts) {
          for (final a in locAlerts) {
            if (seenIds.add(a.id)) alerts.add(a);
          }
        },
      );
    }

    alerts.sort((a, b) => a.severity.sortOrder.compareTo(b.severity.sortOrder));
    return alerts;
  }

  Future<void> _registerAllLocations({
    required double gpsLatitude,
    required double gpsLongitude,
  }) async {
    final alertsEnabled = ref.read(settingsProvider).severeAlertsEnabled;

    // When alerts are disabled, pass empty locations so _checkAlerts() no-ops,
    // but still register the periodic task so _refreshWidgetData() keeps running.
    final savedLocations = ref.read(savedLocationsProvider);
    final locations = alertsEnabled
        ? <Map<String, dynamic>>[
            {'latitude': gpsLatitude, 'longitude': gpsLongitude, 'name': 'GPS'},
            ...savedLocations.map(
              (loc) => {
                'latitude': loc.latitude,
                'longitude': loc.longitude,
                'name': loc.name,
              },
            ),
          ]
        : <Map<String, dynamic>>[];
    await BackgroundAlertService.updateLocations(locations);
    await BackgroundAlertService.registerPeriodicCheck();
  }

  Future<bool> _refreshAll({bool force = false}) async {
    final savedLocations = ref.read(savedLocationsProvider);
    final results = await Future.wait([
      ref.read(weatherStateProvider.notifier).refresh(forceRefresh: force),
      ...savedLocations.map((loc) {
        final params = (name: loc.name, lat: loc.latitude, lon: loc.longitude);
        return ref
            .read(locationForecastProvider(params).notifier)
            .refresh(forceRefresh: force);
      }),
    ]);
    return results.every((success) => success);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(weatherStateProvider);
    final savedLocations = ref.watch(savedLocationsProvider);

    // Eagerly warm up all saved location providers so data loads during splash
    final locationStates = <LocationForecastState>[];
    for (final loc in savedLocations) {
      locationStates.add(
        ref.watch(
          locationForecastProvider((
            name: loc.name,
            lat: loc.latitude,
            lon: loc.longitude,
          )),
        ),
      );
    }

    // Check if all weather data is loaded
    final gpsReady = state != const WeatherState.loading();
    final locationsReady = locationStates.every(
      (s) => s != const LocationForecastState.loading(),
    );

    // Remove native splash when min time elapsed + all data loaded
    if (_minTimeElapsed && gpsReady && locationsReady && !_splashRemoved) {
      _splashRemoved = true;
      _splashTimeout?.cancel();
      FlutterNativeSplash.remove();
    }

    final content = state.when(
      loading: () => Container(color: Theme.of(context).colorScheme.secondary),
      error: (message) {
        final notifier = ref.read(weatherStateProvider.notifier);
        return ErrorScreen(
          message: message,
          onRetry: () => notifier.loadWeather(),
          onOpenSettings: notifier.isLocationPermissionError
              ? () => notifier.isLocationServiceDisabled
                    ? Geolocator.openLocationSettings()
                    : Geolocator.openAppSettings()
              : null,
        );
      },
      loaded: (forecast, location, quip, alerts) {
        // Show alert sheet if app was opened via notification tap (cold start)
        if (FcmService().pendingAlertTap) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) _showPendingAlert();
          });
        }

        // Register device with cloud function for push alerts (GPS + saved)
        if (!_initialRegistrationDone) {
          _initialRegistrationDone = true;
          _registerAllLocations(
            gpsLatitude: location.latitude,
            gpsLongitude: location.longitude,
          );
          // Re-register whenever saved locations change (add/remove)
          ref.listen<List<SavedLocation>>(savedLocationsProvider, (prev, next) {
            _registerAllLocations(
              gpsLatitude: location.latitude,
              gpsLongitude: location.longitude,
            );
          });
          // Re-register or unregister when alert setting is toggled
          ref.listen<SettingsState>(settingsProvider, (prev, next) {
            if (prev?.severeAlertsEnabled != next.severeAlertsEnabled) {
              _registerAllLocations(
                gpsLatitude: location.latitude,
                gpsLongitude: location.longitude,
              );
            }
          });
        }

        final pages = <Widget>[
          VerticalForecastPager(
            key: _verticalPagerKey,
            forecast: forecast,
            cityName: location.cityName,
            quip: quip,
            latitude: location.latitude,
            longitude: location.longitude,
            alerts: alerts,
            onRefresh: () => _refreshAll(force: true),
            onSettings: _showSettings,
          ),
          ...savedLocations.map(
            (loc) =>
                SavedLocationsPage(location: loc, onSettings: _showSettings),
          ),
        ];

        // Determine active weather for background based on current page
        var bgCondition = forecast.current.condition;
        var bgIsDay = forecast.isCurrentlyDay;
        var bgTemperature = forecast.current.temperature;

        if (_currentHorizontalPage > 0) {
          final locIndex = _currentHorizontalPage - 1;
          if (locIndex < locationStates.length) {
            locationStates[locIndex].whenOrNull(
              loaded: (locForecast, quip, alerts) {
                bgCondition = locForecast.current.condition;
                bgIsDay = locForecast.isCurrentlyDay;
                bgTemperature = locForecast.current.temperature;
              },
            );
          }
        }

        return Stack(
          children: [
            // Animated background
            WeatherBackground(
              condition: bgCondition,
              isDay: bgIsDay,
              temperature: bgTemperature,
            ),
            // Light scrim for text readability
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: bgIsDay
                        ? [
                            Colors.black.withValues(alpha: 0.03),
                            Colors.black.withValues(alpha: 0.0),
                            Colors.black.withValues(alpha: 0.06),
                          ]
                        : [
                            Colors.black.withValues(alpha: 0.03),
                            Colors.black.withValues(alpha: 0.0),
                            Colors.black.withValues(alpha: 0.05),
                          ],
                  ),
                ),
              ),
            ),
            // Logo behind all page content
            LogoOverlay(isDay: bgIsDay),
            PageView(
              controller: _horizontalController,
              physics: const ClampingScrollPhysics(),
              children: pages,
            ),
            if (pages.length > 1)
              Positioned(
                bottom: MediaQuery.paddingOf(context).bottom,
                left: 0,
                right: 0,
                child: _HorizontalPageIndicator(
                  controller: _horizontalController,
                  count: pages.length,
                ),
              ),
            Positioned(
              top: MediaQuery.paddingOf(context).top + 8,
              left: 12,
              right: 12,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: _openLocationSearch,
                    icon: Icon(
                      Icons.add_location_alt_outlined,
                      color: AppColors.cream.withValues(alpha: 0.6),
                      size: 24,
                    ),
                  ),
                  IconButton(
                    onPressed: _showSettings,
                    icon: Icon(
                      Icons.settings_outlined,
                      color: AppColors.cream.withValues(alpha: 0.85),
                      size: 24,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );

    return Scaffold(backgroundColor: Colors.transparent, body: content);
  }
}

class _HorizontalPageIndicator extends StatefulWidget {
  final PageController controller;
  final int count;

  const _HorizontalPageIndicator({
    required this.controller,
    required this.count,
  });

  @override
  State<_HorizontalPageIndicator> createState() =>
      _HorizontalPageIndicatorState();
}

class _HorizontalPageIndicatorState extends State<_HorizontalPageIndicator> {
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onPageChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onPageChanged);
    super.dispose();
  }

  void _onPageChanged() {
    final page = widget.controller.page?.round() ?? 0;
    if (page != _currentPage) {
      setState(() => _currentPage = page);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(widget.count, (index) {
        final isActive = index == _currentPage;
        final isFirst = index == 0;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 3),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: isActive ? 8 : 6,
            height: isActive ? 8 : 6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isActive
                  ? AppColors.cream.withValues(alpha: 0.9)
                  : AppColors.cream.withValues(alpha: 0.35),
            ),
            child: isFirst && !isActive
                ? Icon(
                    Icons.add,
                    size: 4,
                    color: AppColors.cream.withValues(alpha: 0.54),
                  )
                : index == 1 && !isActive
                ? Icon(
                    Icons.my_location,
                    size: 4,
                    color: AppColors.cream.withValues(alpha: 0.54),
                  )
                : null,
          ),
        );
      }),
    );
  }
}
