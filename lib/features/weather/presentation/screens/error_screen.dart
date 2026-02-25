import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class ErrorScreen extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  final VoidCallback? onOpenSettings;

  const ErrorScreen({
    super.key,
    required this.message,
    required this.onRetry,
    this.onOpenSettings,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: Theme.of(context).colorScheme.secondary),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                onOpenSettings != null ? Icons.location_off : Icons.cloud_off,
                size: 64,
                color: AppColors.cream.withValues(alpha: 0.54),
              ),
              const SizedBox(height: 24),
              Text('Yikes!', style: Theme.of(context).textTheme.headlineLarge),
              const SizedBox(height: 12),
              Text(
                message,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 32),
              if (onOpenSettings != null) ...[
                ElevatedButton.icon(
                  onPressed: onOpenSettings,
                  icon: const Icon(Icons.settings),
                  label: Text(
                    'Open Settings',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.darkMagenta,
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
                const SizedBox(height: 12),
              ],
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: Text(
                  'Try Again',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.darkMagenta,
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
            ],
          ),
        ),
      ),
    );
  }
}
