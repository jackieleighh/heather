import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:heather/core/constants/app_colors.dart';
import 'package:intl/intl.dart';
import 'package:weather_icons/weather_icons.dart';
import './card_container.dart';

class SunCard extends StatelessWidget {
  final DateTime sunrise;
  final DateTime sunset;
  final double uvIndex;

  const SunCard({
    super.key,
    required this.sunrise,
    required this.sunset,
    required this.uvIndex,
  });

  @override
  Widget build(BuildContext context) {
    final timeFmt = DateFormat('h:mm a');
    final theme = Theme.of(context);

    return CardContainer(
      backgroundIcon: WeatherIcons.day_sunny,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(
                WeatherIcons.day_sunny,
                size: 18,
                color: AppColors.cream.withValues(alpha: 0.8),
              ),
              const SizedBox(width: 8),
              Text(
                'Sun',
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Text(
                'UV ${uvIndex.round()}',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.cream,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                _uvLabel(uvIndex),
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.cream.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(
                WeatherIcons.sunrise,
                size: 16,
                color: AppColors.cream.withValues(alpha: 0.7),
              ),
              const SizedBox(width: 6),
              Text(
                timeFmt.format(sunrise),
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  fontSize: 22,
                ),
              ),
              const SizedBox(width: 20),
              Icon(
                WeatherIcons.sunset,
                size: 16,
                color: AppColors.cream.withValues(alpha: 0.7),
              ),
              const SizedBox(width: 6),
              Text(
                timeFmt.format(sunset),
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  fontSize: 22,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static String _uvLabel(double uv) {
    if (uv < 3) return 'Low';
    if (uv < 6) return 'Moderate';
    if (uv < 8) return 'High';
    if (uv < 11) return 'Very High';
    return 'Extreme';
  }
}
