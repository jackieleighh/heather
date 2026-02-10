import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/saved_location.dart';
import '../providers/location_provider.dart';
import '../providers/weather_provider.dart';
import '../widgets/settings_sheet.dart';
import '../widgets/vertical_forecast_pager.dart';
import 'location_search_screen.dart';

class WeatherScreen extends ConsumerStatefulWidget {
  const WeatherScreen({super.key});

  @override
  ConsumerState<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends ConsumerState<WeatherScreen> {
  late PageController _horizontalController;

  @override
  void initState() {
    super.initState();
    _horizontalController = PageController();
  }

  @override
  void dispose() {
    _horizontalController.dispose();
    super.dispose();
  }

  void _showSettings() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cream,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const SettingsSheet(),
    );
  }

  void _openSearch() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const LocationSearchScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(weatherStateProvider);
    final savedLocations = ref.watch(savedLocationsProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: state.when(
        loading: () => const _LoadingView(),
        error: (message) => _ErrorView(
          message: message,
          onRetry: () => ref.read(weatherStateProvider.notifier).loadWeather(),
          onSettings: _showSettings,
        ),
        loaded: (forecast, location, quip) {
          final pages = <Widget>[
            // Page 0: GPS location
            VerticalForecastPager(
              forecast: forecast,
              cityName: location.cityName,
              quip: quip,
              onRefresh: () =>
                  ref.read(weatherStateProvider.notifier).refresh(),
              onSettings: _showSettings,
            ),
            // Pages 1-N: Saved locations
            ...savedLocations.map((loc) => _SavedLocationPage(
                  location: loc,
                  onSettings: _showSettings,
                )),
          ];

          return Stack(
            children: [
              PageView(
                controller: _horizontalController,
                physics: const ClampingScrollPhysics(),
                children: pages,
              ),
              // Horizontal page dots (bottom center)
              if (savedLocations.isNotEmpty)
                Positioned(
                  bottom: MediaQuery.paddingOf(context).bottom + 12,
                  left: 0,
                  right: 0,
                  child: _HorizontalPageIndicator(
                    controller: _horizontalController,
                    count: pages.length,
                  ),
                ),
              // Add location button
              Positioned(
                top: MediaQuery.paddingOf(context).top + 8,
                left: 12,
                child: IconButton(
                  onPressed: _openSearch,
                  icon: Icon(
                    Icons.add_location_alt_outlined,
                    color: Colors.white.withValues(alpha: 0.6),
                    size: 24,
                  ),
                ),
              ),
            ],
          );
        },
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
            duration: const Duration(milliseconds: 200),
            width: isActive ? 8 : 6,
            height: isActive ? 8 : 6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isActive
                  ? Colors.white.withValues(alpha: 0.9)
                  : Colors.white.withValues(alpha: 0.35),
            ),
            child: isFirst && !isActive
                ? const Icon(Icons.my_location, size: 4, color: Colors.white54)
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

  const _SavedLocationPage({
    required this.location,
    required this.onSettings,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final params = (name: location.name, lat: location.latitude, lon: location.longitude);
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
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.chartreuse, AppColors.vibrantPurple, AppColors.magenta],
        ),
      ),
      child: const Center(
        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
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
            const Icon(Icons.cloud_off, size: 48, color: Colors.white70),
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
                foregroundColor: Colors.white,
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
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.chartreuse, AppColors.vibrantPurple, AppColors.magenta],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'heather',
              style: Theme.of(context).textTheme.displayMedium,
            ),
            const SizedBox(height: 8),
            Text(
              "it's heather with the weather",
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(height: 32),
            const CircularProgressIndicator(
              color: Colors.white,
              strokeWidth: 3,
            ),
            const SizedBox(height: 24),
            Text(
              "there's a 30% chance it's already raining.",
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
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
              const Icon(Icons.cloud_off, size: 64, color: Colors.white70),
              const SizedBox(height: 24),
              Text(
                'Yikes!',
                style: Theme.of(context).textTheme.headlineLarge,
              ),
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
                  foregroundColor: Colors.white,
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
                    color: Colors.white.withValues(alpha: 0.7),
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
