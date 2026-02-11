import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:weather_icons/weather_icons.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/moon_phase.dart';
import '../../domain/entities/forecast.dart';
import '../providers/air_quality_provider.dart';

class DetailsPage extends ConsumerWidget {
  final Forecast forecast;
  final double latitude;
  final double longitude;

  const DetailsPage({
    super.key,
    required this.forecast,
    required this.latitude,
    required this.longitude,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final today = forecast.daily.first;
    final now = forecast.locationNow;
    final aqi = ref.watch(airQualityProvider((lat: latitude, lon: longitude)));

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 26, 12),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 44),
              child: SizedBox(
                height: 62,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    'Today',
                    style: GoogleFonts.quicksand(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: AppColors.cream,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            // Sun + UV
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _SunUvCard(
                  sunrise: today.sunrise,
                  sunset: today.sunset,
                  uvIndex: today.uvIndexMax,
                ),
              ),
            ),
            // Temperature
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _TemperatureCard(
                  temps: forecast.hourlyToday
                      .map((h) => h.temperature)
                      .toList(),
                  hours: forecast.hourlyToday.map((h) => h.time).toList(),
                  now: now,
                ),
              ),
            ),
            // Conditions
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _ConditionsCard(
                  windSpeed: forecast.current.windSpeed,
                  humidity: forecast.current.humidity,
                  precipitationIn: today.precipitationSum / 25.4,
                ),
              ),
            ),
            // Air Quality
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _AirQualityCard(
                  aqi: aqi.whenOrNull(data: (v) => v),
                  isLoading: aqi.isLoading,
                ),
              ),
            ),
            // Moon
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _MoonCard(now: now),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- Sun + UV combined card ---

class _SunUvCard extends StatelessWidget {
  final DateTime sunrise;
  final DateTime sunset;
  final double uvIndex;

  const _SunUvCard({
    required this.sunrise,
    required this.sunset,
    required this.uvIndex,
  });

  @override
  Widget build(BuildContext context) {
    final timeFmt = DateFormat('h:mm a');
    final theme = Theme.of(context);

    return _CardContainer(
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

// --- Temperature line graph card ---

class _TemperatureCard extends StatelessWidget {
  final List<double> temps;
  final List<DateTime> hours;
  final DateTime now;

  const _TemperatureCard({
    required this.temps,
    required this.hours,
    required this.now,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (temps.isEmpty) return const SizedBox.shrink();

    final lo = temps.reduce(math.min);
    final hi = temps.reduce(math.max);

    return _CardContainer(
      backgroundIcon: WeatherIcons.thermometer,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                WeatherIcons.thermometer,
                size: 18,
                color: AppColors.cream.withValues(alpha: 0.8),
              ),
              const SizedBox(width: 8),
              Text(
                'Temp',
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Text(
                '${hi.round()}°',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.cream,
                ),
              ),
              Text(
                ' / ${lo.round()}°',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.cream.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Expanded(
            child: CustomPaint(
              size: Size.infinite,
              painter: _TempLinePainter(temps: temps, hours: hours, now: now),
            ),
          ),
        ],
      ),
    );
  }
}

class _TempLinePainter extends CustomPainter {
  final List<double> temps;
  final List<DateTime> hours;
  final DateTime now;

  _TempLinePainter({
    required this.temps,
    required this.hours,
    required this.now,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (temps.length < 2) return;

    final lo = temps.reduce(math.min);
    final hi = temps.reduce(math.max);
    final range = hi - lo;
    if (range == 0) return;

    const padTop = 2.0;
    const padBottom = 14.0;
    const padLeft = 28.0;
    final graphH = size.height - padTop - padBottom;
    final graphW = size.width - padLeft;
    final stepX = graphW / (temps.length - 1);

    final points = <Offset>[];
    for (var i = 0; i < temps.length; i++) {
      final x = padLeft + i * stepX;
      final y = padTop + graphH * (1 - (temps[i] - lo) / range);
      points.add(Offset(x, y));
    }

    // Y-axis temp labels (high, mid, low)
    final yLabelStyle = TextStyle(
      color: AppColors.cream.withValues(alpha: 0.4),
      fontSize: 9,
      fontWeight: FontWeight.w500,
    );
    final mid = (lo + hi) / 2;
    for (final temp in [hi, mid, lo]) {
      final y = padTop + graphH * (1 - (temp - lo) / range);
      final tp = TextPainter(
        text: TextSpan(text: '${temp.round()}°', style: yLabelStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(0, y - tp.height / 2));
    }

    // Filled area
    final fillPath = Path()..moveTo(points.first.dx, size.height);
    for (final p in points) {
      fillPath.lineTo(p.dx, p.dy);
    }
    fillPath.lineTo(points.last.dx, size.height);
    fillPath.close();

    canvas.drawPath(
      fillPath,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.cream.withValues(alpha: 0.2),
            AppColors.cream.withValues(alpha: 0.0),
          ],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height)),
    );

    // Curve
    final linePath = Path()..moveTo(points.first.dx, points.first.dy);
    for (var i = 1; i < points.length; i++) {
      final prev = points[i - 1];
      final curr = points[i];
      final cpx = (prev.dx + curr.dx) / 2;
      linePath.cubicTo(cpx, prev.dy, cpx, curr.dy, curr.dx, curr.dy);
    }
    canvas.drawPath(
      linePath,
      Paint()
        ..color = AppColors.cream.withValues(alpha: 0.9)
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );

    // "Now" dot — interpolate position along the hour axis
    if (hours.length >= 2) {
      double dotX;
      double dotY;

      if (now.isBefore(hours.first)) {
        // Before first data point — pin to start
        dotX = points.first.dx;
        dotY = points.first.dy;
      } else if (now.isAfter(hours.last)) {
        // After last data point — pin to end
        dotX = points.last.dx;
        dotY = points.last.dy;
      } else {
        // Find the two surrounding hours
        var idx = 0;
        for (var i = 0; i < hours.length - 1; i++) {
          if (!now.isBefore(hours[i]) && now.isBefore(hours[i + 1])) {
            idx = i;
            break;
          }
        }
        final segFraction = hours[idx + 1].difference(hours[idx]).inSeconds > 0
            ? now.difference(hours[idx]).inSeconds /
                  hours[idx + 1].difference(hours[idx]).inSeconds
            : 0.0;
        dotX =
            points[idx].dx +
            (points[idx + 1].dx - points[idx].dx) * segFraction;
        final interpTemp =
            temps[idx] + (temps[idx + 1] - temps[idx]) * segFraction;
        dotY = padTop + graphH * (1 - (interpTemp - lo) / range);
      }

      canvas.drawCircle(
        Offset(dotX, dotY),
        4,
        Paint()..color = AppColors.cream,
      );
    }

    // Hour labels
    final labelStyle = TextStyle(
      color: AppColors.cream.withValues(alpha: 0.5),
      fontSize: 9,
      fontWeight: FontWeight.w500,
    );
    for (var i = 0; i < hours.length; i++) {
      if (i % 6 != 0 && i != hours.length - 1) continue;
      final tp = TextPainter(
        text: TextSpan(
          text: DateFormat('ha').format(hours[i]).toLowerCase(),
          style: labelStyle,
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      final x = (padLeft + i * stepX - tp.width / 2).clamp(
        padLeft,
        size.width - tp.width,
      );
      tp.paint(canvas, Offset(x, size.height - padBottom + 2));
    }
  }

  @override
  bool shouldRepaint(covariant _TempLinePainter old) =>
      temps != old.temps || now != old.now;
}

// --- Conditions card (wind, precip, humidity) ---

class _ConditionsCard extends StatelessWidget {
  final double windSpeed;
  final int humidity;
  final double precipitationIn;

  const _ConditionsCard({
    required this.windSpeed,
    required this.humidity,
    required this.precipitationIn,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final precipLabel = precipitationIn < 0.01
        ? '0 in'
        : '${precipitationIn.toStringAsFixed(2)} in';

    return _CardContainer(
      backgroundIcon: WeatherIcons.windy,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(
                WeatherIcons.windy,
                size: 18,
                color: AppColors.cream.withValues(alpha: 0.8),
              ),
              const SizedBox(width: 8),
              Text(
                'Conditions',
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(
                WeatherIcons.windy,
                size: 16,
                color: AppColors.cream.withValues(alpha: 0.7),
              ),
              const SizedBox(width: 6),
              Text(
                '${windSpeed.round()} mph',
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  fontSize: 20,
                ),
              ),
              const SizedBox(width: 16),
              Icon(
                WeatherIcons.raindrop,
                size: 18,
                color: AppColors.cream.withValues(alpha: 0.7),
              ),
              const SizedBox(width: 6),
              Text(
                precipLabel,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  fontSize: 20,
                ),
              ),
              const SizedBox(width: 16),
              Icon(
                WeatherIcons.humidity,
                size: 12,
                color: AppColors.cream.withValues(alpha: 0.7),
              ),
              const SizedBox(width: 6),
              Text(
                '$humidity%',
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  fontSize: 20,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// --- Air Quality card with muted scale ---

class _AirQualityCard extends StatelessWidget {
  final int? aqi;
  final bool isLoading;

  const _AirQualityCard({required this.aqi, required this.isLoading});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return _CardContainer(
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
                color: AppColors.cream.withValues(alpha: 0.8),
              ),
              const SizedBox(width: 8),
              Text(
                'Air Quality',
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
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
                        color: AppColors.cream.withValues(alpha: 0.6),
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
          const SizedBox(height: 8),
          SizedBox(
            height: 16,
            child: CustomPaint(
              size: Size.infinite,
              painter: _AqiScalePainter(aqi: aqi),
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

// --- Moon card (styled like sun card) ---

class _MoonCard extends StatelessWidget {
  final DateTime now;

  const _MoonCard({required this.now});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final phase = getMoonPhase(now);
    final nextFull = nextFullMoon(now);
    final nextNew = nextNewMoon(now);
    final dateFmt = DateFormat('MMM d');

    final fullFirst = nextFull.isBefore(nextNew);
    final first = fullFirst ? nextFull : nextNew;
    final second = fullFirst ? nextNew : nextFull;
    final firstLabel = fullFirst ? 'Full' : 'New';
    final secondLabel = fullFirst ? 'New' : 'Full';
    final firstIcon = fullFirst
        ? WeatherIcons.moon_full
        : WeatherIcons.moon_new;
    final secondIcon = fullFirst
        ? WeatherIcons.moon_new
        : WeatherIcons.moon_full;

    return _CardContainer(
      backgroundIcon: moonPhaseIcon(now),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(
                moonPhaseIcon(now),
                size: 18,
                color: AppColors.cream.withValues(alpha: 0.8),
              ),
              const SizedBox(width: 8),
              Text(
                'Moon',
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Text(
                moonPhaseLabel(phase),
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.cream,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(
                firstIcon,
                size: 16,
                color: AppColors.cream.withValues(alpha: 0.7),
              ),
              const SizedBox(width: 6),
              Text(
                _relativeLabel(firstLabel, first, now, dateFmt),
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  fontSize: 20,
                ),
              ),
              const SizedBox(width: 16),
              Icon(
                secondIcon,
                size: 16,
                color: AppColors.cream.withValues(alpha: 0.7),
              ),
              const SizedBox(width: 6),
              Text(
                _relativeLabel(secondLabel, second, now, dateFmt),
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  fontSize: 20,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static String _relativeLabel(
    String type,
    DateTime target,
    DateTime now,
    DateFormat fmt,
  ) {
    final today = DateTime(now.year, now.month, now.day);
    final targetDay = DateTime(target.year, target.month, target.day);
    final diff = targetDay.difference(today).inDays;
    if (diff == 0) return '$type today';
    if (diff == 1) return '$type tmrw';
    return '$type ${fmt.format(target)}';
  }
}

// --- Shared card container ---

class _CardContainer extends StatelessWidget {
  final IconData backgroundIcon;
  final Widget child;

  const _CardContainer({required this.backgroundIcon, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        color: AppColors.cream.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -10,
            top: -10,
            child: Icon(
              backgroundIcon,
              color: AppColors.cream.withValues(alpha: 0.12),
              size: 80,
            ),
          ),
          Padding(padding: const EdgeInsets.all(14), child: child),
        ],
      ),
    );
  }
}
