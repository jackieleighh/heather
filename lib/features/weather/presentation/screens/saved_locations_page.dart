import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/saved_location.dart';
import '../providers/weather_provider.dart';
import '../widgets/vertical_forecast_pager.dart';

class SavedLocationsPage extends ConsumerWidget {
  final SavedLocation location;
  final VoidCallback onSettings;

  const SavedLocationsPage({
    super.key,
    required this.location,
    required this.onSettings,
  });

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
      error: (_) => _MiniErrorView(
        onRetry: () =>
            ref.read(locationForecastProvider(params).notifier).load(),
      ),
      loaded: (forecast, quip) => VerticalForecastPager(
        forecast: forecast,
        cityName: location.name,
        quip: quip,
        latitude: location.latitude,
        longitude: location.longitude,
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
  final VoidCallback onRetry;

  const _MiniErrorView({required this.onRetry});

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
