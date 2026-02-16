import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:heather/core/constants/app_colors.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:weather_icons/weather_icons.dart';
import './card_container.dart';

class TemperatureCard extends StatelessWidget {
  final List<double> temps;
  final List<DateTime> hours;
  final DateTime now;

  const TemperatureCard({
    super.key,
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

    return CardContainer(
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
      color: AppColors.cream.withValues(alpha: 0.7),
      fontSize: 10,
      fontWeight: FontWeight.w600,
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
      color: AppColors.cream.withValues(alpha: 0.8),
      fontSize: 10,
      fontWeight: FontWeight.w600,
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
