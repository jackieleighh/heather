import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:heather/features/weather/presentation/screens/error_screen.dart';
import 'package:heather/features/weather/presentation/screens/saved_locations_page.dart';
import 'package:heather/features/weather/presentation/widgets/logo_overlay.dart';
import '../../../../core/constants/app_colors.dart';
import '../providers/location_provider.dart';
import '../providers/weather_provider.dart';
import '../screens/location_search_screen.dart';
import '../widgets/animated_background/weather_background.dart';
import '../widgets/vertical_forecast_pager.dart';

class WeatherScreen extends ConsumerStatefulWidget {
  const WeatherScreen({super.key});

  @override
  ConsumerState<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends ConsumerState<WeatherScreen> {
  late PageController _horizontalController;
  bool _minTimeElapsed = false;
  bool _splashRemoved = false;
  bool _quipsLoaded = false;
  bool _quipsLoading = false;
  int _batchedLocationCount = -1;
  int _currentHorizontalPage = 0;

  @override
  void initState() {
    super.initState();
    _horizontalController = PageController(initialPage: 0);
    _horizontalController.addListener(_onHorizontalPageChanged);
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) setState(() => _minTimeElapsed = true);
    });
  }

  @override
  void dispose() {
    _horizontalController.removeListener(_onHorizontalPageChanged);
    _horizontalController.dispose();
    super.dispose();
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

  Future<bool> _refreshAll() async {
    final savedLocations = ref.read(savedLocationsProvider);
    final results = await Future.wait([
      ref.read(weatherStateProvider.notifier).refresh(),
      ...savedLocations.map((loc) {
        final params = (name: loc.name, lat: loc.latitude, lon: loc.longitude);
        return ref.read(locationForecastProvider(params).notifier).refresh();
      }),
    ]);
    // Single Gemini call for all locations — await before completing refresh
    if (mounted) {
      await ref.read(batchQuipLoaderProvider).loadBatchQuips();
    }
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

    // Once all weather data is loaded, fetch Gemini quips (single batch call).
    // Await completion before removing splash — page doesn't show until quips
    // are ready (Gemini or local fallback).
    if (gpsReady && locationsReady && !_quipsLoaded && !_quipsLoading) {
      _quipsLoading = true;
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (!mounted) return;
        await ref.read(batchQuipLoaderProvider).loadBatchQuips();
        if (mounted) {
          setState(() {
            _quipsLoaded = true;
            _quipsLoading = false;
          });
        }
      });
    }

    // Re-trigger batch quips when saved locations change after initial load
    if (_quipsLoaded && gpsReady && locationsReady) {
      final currentCount = 1 + savedLocations.length;
      if (currentCount != _batchedLocationCount) {
        _batchedLocationCount = currentCount;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          ref.read(batchQuipLoaderProvider).loadBatchQuips();
        });
      }
    }

    // Remove native splash when min time elapsed + all data loaded + quips ready
    if (_minTimeElapsed &&
        gpsReady &&
        locationsReady &&
        _quipsLoaded &&
        !_splashRemoved) {
      _splashRemoved = true;
      FlutterNativeSplash.remove();
    }

    final content = state.when(
      loading: () => Container(color: AppColors.magenta),
      error: (message) => ErrorScreen(
        message: message,
        onRetry: () => ref.read(weatherStateProvider.notifier).loadWeather(),
      ),
      loaded: (forecast, location, quip) {
        final pages = <Widget>[
          VerticalForecastPager(
            forecast: forecast,
            cityName: location.cityName,
            quip: quip,
            latitude: location.latitude,
            longitude: location.longitude,
            onRefresh: _refreshAll,
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
              loaded: (locForecast, _) {
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
            // Gradient scrim for text readability (lighter at night)
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: bgIsDay
                        ? [
                            AppColors.cream.withValues(alpha: 0.08),
                            AppColors.cream.withValues(alpha: 0.02),
                            AppColors.cream.withValues(alpha: 0.12),
                          ]
                        : [
                            AppColors.cream.withValues(alpha: 0.05),
                            AppColors.cream.withValues(alpha: 0.01),
                            AppColors.cream.withValues(alpha: 0.08),
                          ],
                  ),
                ),
              ),
            ),
            // Logo behind all page content
            const LogoOverlay(),
            PageView(
              controller: _horizontalController,
              physics: const ClampingScrollPhysics(),
              children: pages,
            ),
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
