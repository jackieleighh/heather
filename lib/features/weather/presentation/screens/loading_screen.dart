import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../widgets/pulsing_dots.dart';

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.magenta,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/images/splash.png',
              width: 270,
            ),
            const SizedBox(height: 48),
            const PulsingDots(
              dotSize: 10,
              bounceHeight: 12,
              color: AppColors.cream,
            ),
            const SizedBox(height: 24),
            Text(
              'Getting your forecast...',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AppColors.cream.withValues(alpha: 0.7),
                    fontSize: 14,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
