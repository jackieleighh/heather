import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:heather/core/constants/app_colors.dart';
import 'package:weather_icons/weather_icons.dart';
import './card_container.dart';

class AirCard extends StatelessWidget {
  final int? aqi;
  final bool isLoading;
  final double windSpeed;
  final List<double> hourlyWind;

  const AirCard({
    super.key,
    required this.aqi,
    required this.isLoading,
    required this.windSpeed,
    required this.hourlyWind,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final maxWind = hourlyWind.isEmpty
        ? windSpeed
        : hourlyWind.reduce(math.max);

    return CardContainer(
      backgroundIcon: WeatherIcons.smoke,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(
                WeatherIcons.smoke,
                size: 18,
                color: AppColors.cream.withValues(alpha: 0.9),
              ),
              const SizedBox(width: 8),
              Text(
                'Air',
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Icon(
                WeatherIcons.windy,
                size: 14,
                color: AppColors.cream.withValues(alpha: 0.95),
              ),
              const SizedBox(width: 6),
              Text(
                '${windSpeed.round()} mph now',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.cream.withValues(alpha: 0.95),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'up to ${maxWind.round()} mph',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.cream.withValues(alpha: 0.95),
                ),
              ),
            ],
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  children: [
                    const Spacer(),
                    if (isLoading)
                      Text(
                        '...',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                          fontSize: 20,
                        ),
                      )
                    else if (aqi != null)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            aqi.toString(),
                            style: theme.textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w800,
                              fontSize: 20,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            _aqiLabel(aqi!),
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.cream.withValues(alpha: 0.9),
                            ),
                          ),
                        ],
                      )
                    else
                      Text(
                        '--',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                          fontSize: 20,
                        ),
                      ),
                  ],
                ),
                SizedBox(
                  height: 16,
                  child: CustomPaint(
                    size: Size.infinite,
                    painter: _AqiScalePainter(aqi: aqi),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static String _aqiLabel(int aqi) {
    if (aqi <= 50) return 'Good';
    if (aqi <= 100) return 'Moderate';
    if (aqi <= 150) return 'Unhealthy (Sensitive)';
    if (aqi <= 200) return 'Unhealthy';
    if (aqi <= 300) return 'Very Unhealthy';
    return 'Hazardous';
  }
}

class _AqiScalePainter extends CustomPainter {
  final int? aqi;

  _AqiScalePainter({required this.aqi});

  @override
  void paint(Canvas canvas, Size size) {
    const barH = 6.0;
    final barY = (size.height - barH) / 2;
    final barRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, barY, size.width, barH),
      const Radius.circular(3),
    );

    // Muted, semi-transparent gradient
    final barPaint = Paint()
      ..shader = const LinearGradient(
        colors: [
          Color(0x8068BB59), // green, 50% opacity
          Color(0x80B8CC40), // yellow-green
          Color(0x80D4A030), // amber
          Color(0x80CC6644), // salmon
          Color(0x80994466), // muted rose
          Color(0x80775588), // muted purple
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, barH));

    canvas.save();
    canvas.clipRRect(barRect);
    canvas.drawRect(Rect.fromLTWH(0, barY, size.width, barH), barPaint);
    canvas.restore();

    if (aqi != null) {
      final clamped = aqi!.clamp(0, 300);
      final x = (clamped / 300) * size.width;
      canvas.drawCircle(
        Offset(x, barY + barH / 2),
        5,
        Paint()..color = AppColors.cream,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _AqiScalePainter old) => aqi != old.aqi;
}
