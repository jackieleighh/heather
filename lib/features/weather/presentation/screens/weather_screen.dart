import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:heather/features/weather/presentation/widgets/logo_overlay.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/saved_location.dart';
import '../providers/location_provider.dart';
import '../providers/weather_provider.dart';
import '../screens/location_search_screen.dart';
import '../widgets/vertical_forecast_pager.dart';

class WeatherScreen extends ConsumerStatefulWidget {
  const WeatherScreen({super.key});

  @override
  ConsumerState<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends ConsumerState<WeatherScreen> {
  late PageController _horizontalController;
  bool _minTimeElapsed = false;
  bool _splashComplete = false;
  bool _splashFaded = false;
  int _currentHorizontalPage = 1;

  @override
  void initState() {
    super.initState();
    _horizontalController = PageController(initialPage: 1);
    _horizontalController.addListener(_onHorizontalPageChanged);
    Future.delayed(const Duration(seconds: 4), () {
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
    final page = _horizontalController.page?.round() ?? 1;
    if (page != _currentHorizontalPage) {
      setState(() => _currentHorizontalPage = page);
    }
  }

  void _openLocationSearch() {
    Navigator.of(context).push(
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
  }

  void _showSettings() {
    context.push('/settings');
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

    // Splash completes when min time elapsed + GPS loaded + all locations done loading
    final gpsReady = state != const WeatherState.loading();
    final locationsReady = locationStates.every(
      (s) => s != const LocationForecastState.loading(),
    );
    if (_minTimeElapsed && gpsReady && locationsReady && !_splashComplete) {
      _splashComplete = true;
    }

    final content = state.when(
      loading: () => const _LoadingView(),
      error: (message) => _ErrorView(
        message: message,
        onRetry: () => ref.read(weatherStateProvider.notifier).loadWeather(),
        onSettings: _showSettings,
      ),
      loaded: (forecast, location, quip) {
        final pages = <Widget>[
          VerticalForecastPager(
            forecast: forecast,
            cityName: location.cityName,
            quip: quip,
            onRefresh: () => ref.read(weatherStateProvider.notifier).refresh(),
            onSettings: _showSettings,
          ),
          ...savedLocations.map(
            (loc) =>
                _SavedLocationPage(location: loc, onSettings: _showSettings),
          ),
        ];

        return Stack(
          children: [
            PageView(controller: _horizontalController, children: pages),
            Positioned(
              bottom: MediaQuery.paddingOf(context).bottom + 12,
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
                      color: AppColors.cream.withValues(alpha: 0.6),
                      size: 24,
                    ),
                  ),
                ],
              ),
            ),
            const LogoOverlay(),
          ],
        );
      },
    );

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          content,
          if (!_splashFaded)
            IgnorePointer(
              ignoring: _splashComplete,
              child: AnimatedOpacity(
                opacity: _splashComplete ? 0.0 : 1.0,
                duration: const Duration(milliseconds: 2000),
                onEnd: () => setState(() => _splashFaded = true),
                child: const _LoadingView(),
              ),
            ),
        ],
      ),
    );
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
  int _currentPage = 1;

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

class _SavedLocationPage extends ConsumerWidget {
  final SavedLocation location;
  final VoidCallback onSettings;

  const _SavedLocationPage({required this.location, required this.onSettings});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final params = (
      name: location.name,
      lat: location.latitude,
      lon: location.longitude,
    );
    final state = ref.watch(locationForecastProvider(params));

    return state.when(
      loading: () => const _MiniLoadingView(),
      error: (message) => _MiniErrorView(
        message: message,
        onRetry: () =>
            ref.read(locationForecastProvider(params).notifier).load(),
      ),
      loaded: (forecast, quip) => VerticalForecastPager(
        forecast: forecast,
        cityName: location.name,
        quip: quip,
        onRefresh: () =>
            ref.read(locationForecastProvider(params).notifier).refresh(),
        onSettings: onSettings,
      ),
    );
  }
}

class _MiniLoadingView extends StatelessWidget {
  const _MiniLoadingView();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.magenta,
      child: const Center(
        child: CircularProgressIndicator(
          color: AppColors.cream,
          strokeWidth: 3,
        ),
      ),
    );
  }
}

class _MiniErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _MiniErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.deepPurple, AppColors.darkTeal],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.cloud_off,
              size: 48,
              color: AppColors.cream.withValues(alpha: 0.54),
            ),
            const SizedBox(height: 16),
            Text(
              'Couldn\'t load this one.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.vibrantPurple,
                foregroundColor: AppColors.cream,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.magenta,
      child: Stack(
        children: [
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'heather',
                  style: Theme.of(context).textTheme.displayMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  "it's heather with the weather...",
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 24),
                const _PulsingDots(),
                const SizedBox(height: 24),
                Text(
                  "there's a 30% chance it's already raining.",
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
          Builder(
            builder: (context) {
              final screenHeight = MediaQuery.sizeOf(context).height;
              return Positioned(
                left: -40,
                bottom: 0,
                child: Opacity(
                  opacity: 0.12,
                  child: SvgPicture.asset(
                    'assets/images/heather_logo.svg',
                    height: screenHeight * 0.45,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  final VoidCallback onSettings;

  const _ErrorView({
    required this.message,
    required this.onRetry,
    required this.onSettings,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.deepPurple, AppColors.darkTeal],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.cloud_off,
                size: 64,
                color: AppColors.cream.withValues(alpha: 0.54),
              ),
              const SizedBox(height: 24),
              Text('Yikes!', style: Theme.of(context).textTheme.headlineLarge),
              const SizedBox(height: 12),
              Text(
                'Heather tried to get the weather but the vibes are off right now.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 4),
              Text(
                "there's a 30% chance it's already raining.",
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Try Again, Bestie'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.vibrantPurple,
                  foregroundColor: AppColors.cream,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: onSettings,
                child: Text(
                  'Settings',
                  style: TextStyle(
                    color: AppColors.cream.withValues(alpha: 0.7),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PulsingDots extends StatefulWidget {
  const _PulsingDots();

  @override
  State<_PulsingDots> createState() => _PulsingDotsState();
}

class _PulsingDotsState extends State<_PulsingDots>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final active = (_controller.value * 3).floor() % 3;
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.cream.withValues(
                    alpha: i == active ? 0.9 : 0.25,
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}
