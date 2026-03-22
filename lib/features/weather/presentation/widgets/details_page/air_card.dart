import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:heather/core/constants/app_colors.dart';
import 'package:heather/core/utils/wind_direction.dart';
import 'package:weather_icons/weather_icons.dart';
import './card_container.dart';

class AirCard extends StatelessWidget {
  final int? aqi;
  final bool isLoading;
  final double windSpeed;
  final double pressure;
  final double windGusts;
  final int windDirection;
  final List<double> hourlyPressure;

  const AirCard({
    super.key,
    required this.aqi,
    required this.isLoading,
    required this.windSpeed,
    this.pressure = 0.0,
    this.windGusts = 0.0,
    this.windDirection = 0,
    this.hourlyPressure = const [],
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Compute pressure trend from hourly data
    final hasPressureData =
        hourlyPressure.length >= 2 && hourlyPressure.any((p) => p > 0);
    final double? pressureDelta;
    if (hasPressureData) {
      pressureDelta = hourlyPressure.last - hourlyPressure.first;
    } else {
      pressureDelta = null;
    }

    return CardContainer(
      backgroundIcon: WeatherIcons.smoke,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Icon(
                WeatherIcons.smoke,
                size: 15,
                color: AppColors.cream.withValues(alpha: 0.9),
              ),
              const SizedBox(width: 4),
              Text(
                'Air',
                style: GoogleFonts.figtree(
                  fontSize: 18,
                  fontWeight: FontWeight.w400,
                  color: AppColors.cream,
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
                '${windDirectionLabel(windDirection)} ($windDirection\u00B0)',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.cream.withValues(alpha: 0.95),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${windSpeed.round()} mph',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.cream.withValues(alpha: 0.95),
                ),
              ),
              if (windGusts > windSpeed) ...[
                const SizedBox(width: 4),
                Text(
                  'up to ${windGusts.round()} mph',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                    color: AppColors.cream.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ],
          ),
          if (pressure > 0)
            Row(
              children: [
                const Spacer(),
                Icon(
                  WeatherIcons.barometer,
                  size: 14,
                  color: AppColors.cream.withValues(alpha: 0.8),
                ),
                const SizedBox(width: 4),
                Text(
                  '${pressure.round()} mb',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.cream.withValues(alpha: 0.8),
                  ),
                ),
                if (pressureDelta != null) ...[
                  Icon(
                    pressureDelta > 0.5
                        ? Icons.arrow_upward
                        : pressureDelta < -0.5
                        ? Icons.arrow_downward
                        : Icons.arrow_forward,
                    size: 12,
                    color: AppColors.cream.withValues(alpha: 0.8),
                  ),
                  const SizedBox(width: 2),
                  Text(
                    pressureDelta.abs() < 0.5
                        ? 'steady'
                        : '${pressureDelta > 0 ? '+' : ''}${pressureDelta.toStringAsFixed(1)} mb',
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.cream.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ],
            ),
          const Spacer(),
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
            height: 12,
            child: CustomPaint(
              size: Size.infinite,
              painter: _AqiScalePainter(aqi: aqi),
            ),
          ),
          const SizedBox(height: 4),
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
