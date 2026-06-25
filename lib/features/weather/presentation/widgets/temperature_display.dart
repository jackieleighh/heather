import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';

/// Cached text styles to avoid repeated GoogleFonts allocations.
const _quicksandBold22 = TextStyle(fontFamily: 'Quicksand',
  fontSize: 22,
  fontWeight: FontWeight.w700,
  color: AppColors.cream,
);
const _quicksandW50015Cream = TextStyle(fontFamily: 'Quicksand',
  fontSize: 15,
  fontWeight: FontWeight.w500,
  color: AppColors.cream,
);

class TemperatureDisplay extends StatelessWidget {
  final double temperature;
  final double high;
  final double low;
  final double? feelsLike;
  final String? precipLabel;

  const TemperatureDisplay({
    super.key,
    required this.temperature,
    required this.high,
    required this.low,
    this.feelsLike,
    this.precipLabel,
  });

  @override
  Widget build(BuildContext context) {
    final showFeels =
        feelsLike != null && (feelsLike! - temperature).abs() >= 1;

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
        Transform.translate(
          offset: const Offset(0, -6),
          child: Text(
            '${high.round()}° / ${low.round()}°',
            style: _quicksandBold22,
          ),
        ),
        if (showFeels)
          Transform.translate(
            offset: const Offset(0, -8),
            child: Text(
              'feels ${feelsLike!.round()}°',
              style: _quicksandW50015Cream,
            ),
          ),
        if (precipLabel != null)
          Transform.translate(
            offset: const Offset(0, 0),
            child: Text(precipLabel!, style: _quicksandW50015Cream),
          ),
      ],
    );
  }
}
