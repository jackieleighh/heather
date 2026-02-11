import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';

class TemperatureDisplay extends StatelessWidget {
  final double temperature;
  final double high;
  final double low;

  const TemperatureDisplay({
    super.key,
    required this.temperature,
    required this.high,
    required this.low,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${temperature.round()}',
              style: Theme.of(context).textTheme.displayLarge,
            ),
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Text(
                '°F',
                style: Theme.of(context).textTheme.headlineLarge,
              ),
            ),
          ],
        ),
        Text(
          '${high.round()}° / ${low.round()}°',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppColors.cream.withValues(alpha: 0.7),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
