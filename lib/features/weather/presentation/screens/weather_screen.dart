import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:heather/features/weather/presentation/screens/error_screen.dart';
import 'package:heather/features/weather/presentation/screens/loading_screen.dart';
import 'package:heather/features/weather/domain/entities/saved_location.dart';
import 'package:heather/features/weather/presentation/screens/saved_locations_page.dart';
import 'package:heather/features/weather/presentation/widgets/logo_overlay.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/background_alert_service.dart';
import '../../../../core/services/device_registration_service.dart';
import '../../../../core/services/fcm_service.dart';
import '../../../../core/services/widget_service.dart';
import '../../domain/entities/weather_alert.dart';
import '../providers/location_provider.dart';
import '../providers/settings_provider.dart';
import '../providers/weather_provider.dart';
import '../screens/alert_detail_sheet.dart';
import '../screens/location_search_screen.dart';
import '../widgets/animated_background/weather_background.dart';
import '../../../../core/utils/smooth_page_physics.dart';
import '../widgets/vertical_forecast_pager.dart';

class WeatherScreen extends ConsumerStatefulWidget {
  const WeatherScreen({super.key});

  @override
  ConsumerState<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends ConsumerState<WeatherScreen>
    with WidgetsBindingObserver {
  static const _dayScrim = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color.fromRGBO(0, 0, 0, 0.12),
      Color.fromRGBO(0, 0, 0, 0.05),
      Color.fromRGBO(0, 0, 0, 0.15),
    ],
  );
  static const _nightScrim = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color.fromRGBO(0, 0, 0, 0.03),
      Color.fromRGBO(0, 0, 0, 0.0),
      Color.fromRGBO(0, 0, 0, 0.05),
    ],
  );

  late PageController _horizontalController;
  final _verticalPagerKey = GlobalKey<VerticalForecastPagerState>();
  StreamSubscription<void>? _widgetTapSub;
  StreamSubscription<void>? _alertTapSub;
  Timer? _pollTimer;
  Timer? _gracePeriodTimer;
  Timer? _forceTimeoutTimer;
  Timer? _pendingAlertRetryTimer;
  DateTime? _lastRefreshTime;
  DateTime? _lastForceRefreshTime;
  DateTime? _pendingAlertStartTime;
  bool _splashRemoved = false;
  bool _gracePeriodElapsed = false;
  bool _minimumDisplayElapsed = false;
  bool _initialRegistrationDone = false;
  bool _savedLocationsLoaded = false;
  bool _pendingAlertNavigated = false;
  bool _pendingAlertActive = false;
  bool _pendingAlertSheetShown = false;
  bool _isAppActive = true;
  String? _pendingLocationId;
  String? _pendingLocationName;
  final _currentHorizontalPage = ValueNotifier<int>(0);

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
      if (kDebugMode) debugPrint('[ALERT] stream fired');
      _handlePendingAlert();
    });
    _pollTimer = Timer.periodic(const Duration(minutes: 15), (_) {
      if (mounted) _refreshAll();
    });
    // Remove native splash on the very first frame so our in-app
    // LoadingScreen (same magenta bg + splash image) takes over seamlessly.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_splashRemoved) {
        _splashRemoved = true;
        FlutterNativeSplash.remove();
      }
    });
    // Skip the 3-second loading screen when cold-launched from widget (cache
    // will render instantly). For normal launches, keep the visual polish timer.
    if (WidgetService.coldLaunchedFromWidget) {
      _minimumDisplayElapsed = true;
    } else {
      Timer(const Duration(seconds: 3), () {
        if (mounted) {
          setState(() => _minimumDisplayElapsed = true);
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) _handlePendingAlert();
          });
        }
      });
    }
    // Grace period: show loading screen for at least 10s before showing errors
    _gracePeriodTimer = Timer(const Duration(seconds: 10), () {
      if (mounted) setState(() => _gracePeriodElapsed = true);
    });
    // Hard timeout: force error if still loading after 25s
    _forceTimeoutTimer = Timer(const Duration(seconds: 25), () {
      if (mounted) {
        ref.read(weatherStateProvider.notifier).forceTimeout();
      }
    });
  }

  @override
  void dispose() {
    _gracePeriodTimer?.cancel();
    _forceTimeoutTimer?.cancel();
    _pollTimer?.cancel();
    _pendingAlertRetryTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    _widgetTapSub?.cancel();
    _alertTapSub?.cancel();
    _horizontalController.removeListener(_onHorizontalPageChanged);
    _horizontalController.dispose();
    _currentHorizontalPage.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final wasActive = _isAppActive;
    _isAppActive = state == AppLifecycleState.resumed;
    if (_isAppActive != wasActive) {
      setState(() {});
    }

    if (state == AppLifecycleState.resumed) {
      // Check for pending notification tap (fallback for background→foreground)
      _handlePendingAlert();

      final now = DateTime.now();
      if (_lastRefreshTime != null &&
          now.difference(_lastRefreshTime!).inMinutes < 5) {
        return; // Data is <5 min old, skip refresh
      }
      _refreshAll();
    }
  }

  void _resetToFirstAndRefresh() {
    if (_horizontalController.hasClients) {
      _horizontalController.jumpToPage(0);
    }
    _verticalPagerKey.currentState?.jumpToFirst();
    _refreshAll(force: true);
  }

  void _onHorizontalPageChanged() {
    final page = _horizontalController.page?.round() ?? 0;
    if (page != _currentHorizontalPage.value) {
      _currentHorizontalPage.value = page;
    }
  }

  Future<void> _openLocationSearch() async {
    final locationId = await Navigator.of(context).push<String>(
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

    if (locationId != null && mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final savedLocations = ref.read(savedLocationsProvider);
        final index = savedLocations.indexWhere((l) => l.id == locationId);
        if (index < 0) return;
        // GPS is page 0, saved locations start at page 1
        final targetPage = index + 1;
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

  /// Single idempotent entry point for handling pending notification taps.
  /// Called from: stream listener, 3s timer, lifecycle resume, and build callback.
  /// Safe to call multiple times — each call re-checks FcmService and local state.
  void _handlePendingAlert() {
    if (!mounted) return;

    // Try to consume from FcmService (may have new data since last check)
    final fcm = FcmService();
    if (fcm.pendingAlertTap && !_pendingAlertActive) {
      _pendingAlertActive = true;
      _pendingAlertSheetShown = false;
      _pendingLocationId = fcm.pendingAlertLocationId;
      _pendingLocationName = fcm.pendingAlertLocationName;
      _pendingAlertNavigated = false;
      _pendingAlertStartTime = DateTime.now();
      fcm.clearPendingAlertTap();

      if (kDebugMode) {
        debugPrint(
          '[ALERT] consumed: locId=$_pendingLocationId, '
          'locName=$_pendingLocationName',
        );
      }

      // Force refresh to get fresh alert data from NWS
      final savedLocations = ref.read(savedLocationsProvider);
      if (savedLocations.isNotEmpty) {
        ref
            .read(savedLocationsForecastProvider.notifier)
            .refresh(savedLocations, forceRefresh: true);
      }
    }

    if (!_pendingAlertActive) return;
    if (!_minimumDisplayElapsed) return;

    // Timeout after 20 seconds
    if (_pendingAlertStartTime != null &&
        DateTime.now().difference(_pendingAlertStartTime!).inSeconds > 20) {
      if (kDebugMode) debugPrint('[ALERT] timed out after 20s');
      _clearPendingAlert();
      return;
    }

    // Navigate to the correct page
    if (!_pendingAlertNavigated && _horizontalController.hasClients) {
      _navigateToAlertLocation();
      _pendingAlertNavigated = true;
      if (kDebugMode) debugPrint('[ALERT] navigated to page');
    }

    // Try to show alert sheet
    if (!_pendingAlertSheetShown) {
      final alerts = _collectAlertsForPendingLocation();
      if (alerts.isNotEmpty) {
        if (kDebugMode) {
          debugPrint('[ALERT] showing sheet with ${alerts.length} alerts');
        }
        _pendingAlertSheetShown = true;
        _clearPendingAlert();
        showAlertDetailSheet(context, alerts);
        return;
      }
    }

    // Alerts not found yet — start retry timer if not already running
    _pendingAlertRetryTimer ??= Timer.periodic(
      const Duration(seconds: 1),
      (_) => _handlePendingAlert(),
    );
  }

  void _clearPendingAlert() {
    _pendingAlertActive = false;
    _pendingAlertSheetShown = false;
    _pendingLocationId = null;
    _pendingLocationName = null;
    _pendingAlertNavigated = false;
    _pendingAlertStartTime = null;
    _pendingAlertRetryTimer?.cancel();
    _pendingAlertRetryTimer = null;
  }

  void _navigateToAlertLocation() {
    if (!_horizontalController.hasClients) return;

    final locationId = _pendingLocationId;
    final locationName = _pendingLocationName;

    // GPS or empty → ensure we're on page 0
    if ((locationId == null || locationId.isEmpty || locationId == 'GPS') &&
        (locationName == null ||
            locationName.isEmpty ||
            locationName == 'GPS')) {
      if (_horizontalController.page?.round() != 0) {
        _horizontalController.jumpToPage(0);
      }
      return;
    }

    final savedLocations = ref.read(savedLocationsProvider);

    // Match by ID first, fall back to name
    var index = -1;
    if (locationId != null && locationId.isNotEmpty) {
      index = savedLocations.indexWhere((loc) => loc.id == locationId);
    }
    if (index < 0 && locationName != null && locationName.isNotEmpty) {
      index = savedLocations.indexWhere((loc) => loc.name == locationName);
    }

    if (kDebugMode) {
      debugPrint(
        '[ALERT] navigate: locId=$locationId, index=$index, '
        'savedIds=${savedLocations.map((l) => l.id).toList()}',
      );
    }

    if (index >= 0 && _horizontalController.hasClients) {
      _horizontalController.jumpToPage(index + 1);
    }
  }

  /// Collect alerts for the specific location referenced by the pending notification.
  /// Reads from local [_pendingLocationId] instead of the FcmService singleton.
  List<WeatherAlert> _collectAlertsForPendingLocation() {
    final locationId = _pendingLocationId;

    // GPS or empty/null → return GPS alerts
    if (locationId == null || locationId.isEmpty || locationId == 'GPS') {
      final alerts = <WeatherAlert>[];
      final state = ref.read(weatherStateProvider);
      state.whenOrNull(
        loaded: (forecast, location, quip, gpsAlerts) {
          alerts.addAll(gpsAlerts);
        },
      );
      alerts.sort(
        (a, b) => a.severity.sortOrder.compareTo(b.severity.sortOrder),
      );
      return alerts;
    }

    // Saved location → return alerts for that specific location
    final savedState = ref.read(savedLocationsForecastProvider);
    final alerts = <WeatherAlert>[];
    savedState.whenOrNull(
      loaded: (forecasts) {
        final entry = forecasts[locationId];
        if (entry != null) {
          alerts.addAll(entry.alerts);
        }
      },
    );
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
            {
              'latitude': gpsLatitude,
              'longitude': gpsLongitude,
              'name': 'GPS',
              'locationId': 'GPS',
            },
            ...savedLocations.map(
              (loc) => {
                'latitude': loc.latitude,
                'longitude': loc.longitude,
                'name': loc.name,
                'locationId': loc.id,
              },
            ),
          ]
        : <Map<String, dynamic>>[];
    await BackgroundAlertService.updateLocations(locations);
    await BackgroundAlertService.registerPeriodicCheck();
    await DeviceRegistrationService().registerLocations(
      locations: locations,
      alertsEnabled: alertsEnabled,
    );
  }

  void _resetPollTimer() {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(const Duration(minutes: 15), (_) {
      if (mounted) _refreshAll();
    });
  }

  Future<bool> _refreshAll({bool force = false}) async {
    // Debounce force refreshes: 30-second cooldown
    if (force) {
      final now = DateTime.now();
      if (_lastForceRefreshTime != null &&
          now.difference(_lastForceRefreshTime!).inSeconds < 30) {
        return false;
      }
      _lastForceRefreshTime = now;
    }

    final savedLocations = ref.read(savedLocationsProvider);
    final results = await Future.wait([
      ref.read(weatherStateProvider.notifier).refresh(forceRefresh: force),
      ref
          .read(savedLocationsForecastProvider.notifier)
          .refresh(savedLocations, forceRefresh: force),
    ]);

    final success = results[0];
    if (success) {
      _lastRefreshTime = DateTime.now();
      _resetPollTimer();
    }
    return success;
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(weatherStateProvider);
    final savedLocations = ref.watch(savedLocationsProvider);
    final savedForecastState = ref.watch(savedLocationsForecastProvider);

    final content = state.when(
      loading: () => const LoadingScreen(),
      error: (message) {
        // During grace period, keep showing loading screen instead of error
        if (!_gracePeriodElapsed) {
          return const LoadingScreen();
        }
        final notifier = ref.read(weatherStateProvider.notifier);
        return ErrorScreen(
          message: message,
          onRetry: () {
            _forceTimeoutTimer?.cancel();
            _forceTimeoutTimer = Timer(const Duration(seconds: 30), () {
              if (mounted) {
                ref.read(weatherStateProvider.notifier).forceTimeout();
              }
            });
            notifier.loadWeather();
          },
          onOpenSettings: notifier.isLocationPermissionError
              ? () => notifier.isLocationServiceDisabled
                    ? Geolocator.openLocationSettings()
                    : Geolocator.openAppSettings()
              : null,
        );
      },
      loaded: (forecast, location, quip, alerts) {
        // First successful load — cancel grace period and timeout timers
        if (!_gracePeriodElapsed) {
          _gracePeriodElapsed = true;
          _gracePeriodTimer?.cancel();
          _forceTimeoutTimer?.cancel();
        }

        // Trigger batch load for saved locations once GPS is loaded
        if (!_savedLocationsLoaded) {
          _savedLocationsLoaded = true;
          if (savedLocations.isNotEmpty) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                ref
                    .read(savedLocationsForecastProvider.notifier)
                    .load(savedLocations);
              }
            });
          }
        }

        // Keep showing loading screen until minimum display time passes
        if (!_minimumDisplayElapsed) {
          return const LoadingScreen();
        }

        // Check for pending notification tap on each build (covers late-arriving
        // FCM data and provider state changes that may now have alert data).
        if (_pendingAlertActive || FcmService().pendingAlertTap) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) _handlePendingAlert();
          });
        }

        // Register device with cloud function for push alerts (GPS + saved)
        if (!_initialRegistrationDone) {
          _initialRegistrationDone = true;
          _registerAllLocations(
            gpsLatitude: location.latitude,
            gpsLongitude: location.longitude,
          );
        }

        // Re-register and re-fetch whenever saved locations change (add/remove).
        // Must be outside the guard — ref.listen in build() is cleaned up on
        // every rebuild, so it needs to be re-registered each time.
        ref.listen<List<SavedLocation>>(savedLocationsProvider, (prev, next) {
          _registerAllLocations(
            gpsLatitude: location.latitude,
            gpsLongitude: location.longitude,
          );
          ref.read(savedLocationsForecastProvider.notifier).load(next);
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

        final pages = <Widget>[
          VerticalForecastPager(
            key: _verticalPagerKey,
            forecast: forecast,
            cityName: location.cityName,
            quip: quip,
            latitude: location.latitude,
            longitude: location.longitude,
            isUs: location.countryCode == 'US',
            alerts: alerts,
            onRefresh: () => _refreshAll(force: true),
            onSettings: _showSettings,
          ),
          ...savedLocations.map(
            (loc) =>
                SavedLocationsPage(location: loc, onSettings: _showSettings),
          ),
        ];

        return Stack(
          children: [
            // Background, scrim, and logo — only rebuild on page change
            ValueListenableBuilder<int>(
              valueListenable: _currentHorizontalPage,
              builder: (context, currentPage, _) {
                var bgCondition = forecast.current.condition;
                var bgIsDay = forecast.isCurrentlyDay;
                var bgTemperature = forecast.current.temperature;

                if (currentPage > 0) {
                  final locIndex = currentPage - 1;
                  if (locIndex < savedLocations.length) {
                    final locId = savedLocations[locIndex].id;
                    savedForecastState.whenOrNull(
                      loaded: (forecasts) {
                        final data = forecasts[locId];
                        if (data != null) {
                          bgCondition = data.forecast.current.condition;
                          bgIsDay = data.forecast.isCurrentlyDay;
                          bgTemperature = data.forecast.current.temperature;
                        }
                      },
                    );
                  }
                }

                return Stack(
                  children: [
                    RepaintBoundary(
                      child: WeatherBackground(
                        condition: bgCondition,
                        isDay: bgIsDay,
                        temperature: bgTemperature,
                        isActive: _isAppActive,
                      ),
                    ),
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: bgIsDay ? _dayScrim : _nightScrim,
                        ),
                      ),
                    ),
                    LogoOverlay(isDay: bgIsDay),
                  ],
                );
              },
            ),
            RepaintBoundary(
              child: PageView.builder(
                controller: _horizontalController,
                physics: const SmoothPageScrollPhysics(),
                clipBehavior: Clip.none,
                itemCount: pages.length,
                itemBuilder: (context, index) => pages[index],
              ),
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
              top:
                  MediaQuery.paddingOf(context).top + (Platform.isIOS ? -8 : 4),
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
                  // IconButton(
                  //   onPressed: () => context.push('/gallery'),
                  //   icon: Icon(
                  //     Icons.grid_view_rounded,
                  //     color: AppColors.cream.withValues(alpha: 0.6),
                  //     size: 24,
                  //   ),
                  // ),
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
