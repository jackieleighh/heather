import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:heather/core/constants/app_colors.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:weather_icons/weather_icons.dart';
import './card_container.dart';

class SunCard extends StatelessWidget {
  final DateTime sunrise;
  final DateTime sunset;
  final double uvIndex;
  final List<double> hourlyUv;
  final List<DateTime> hours;
  final DateTime? now;

  const SunCard({
    super.key,
    required this.sunrise,
    required this.sunset,
    required this.uvIndex,
    required this.hourlyUv,
    required this.hours,
    this.now,
  });

  @override
  Widget build(BuildContext context) {
    final timeFmt = DateFormat('h:mm a');
    final theme = Theme.of(context);

    return CardContainer(
      backgroundIcon: WeatherIcons.day_sunny,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                WeatherIcons.day_sunny,
                size: 18,
                color: AppColors.cream.withValues(alpha: 0.9),
              ),
              const SizedBox(width: 8),
              Text(
                'Sun',
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Row(
                children: [
                  Icon(
                    WeatherIcons.sunrise,
                    size: 13,
                    color: AppColors.cream.withValues(alpha: 0.95),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    timeFmt.format(sunrise),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Icon(
                    WeatherIcons.sunset,
                    size: 13,
                    color: AppColors.cream.withValues(alpha: 0.95),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    timeFmt.format(sunset),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 2),
          Row(
            children: [
              const Spacer(),
              Text(
                'UV ${uvIndex.round()}',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.cream,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                _uvLabel(uvIndex),
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.cream.withValues(alpha: 0.9),
                ),
              ),
            ],
          ),
          if (hourlyUv.length >= 2) ...[
            const SizedBox(height: 2),
            Expanded(
              child: CustomPaint(
                size: Size.infinite,
                painter: _UvLinePainter(
                  uvValues: hourlyUv,
                  hours: hours,
                  now: now,
                ),
              ),
            ),
          ],
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

class _UvLinePainter extends CustomPainter {
  final List<double> uvValues;
  final List<DateTime> hours;
  final DateTime? now;

  _UvLinePainter({required this.uvValues, required this.hours, this.now});

  @override
  void paint(Canvas canvas, Size size) {
    if (uvValues.length < 2) return;

    final hi = uvValues.reduce(math.max);
    final maxY = math.max(
      hi,
      3.0,
    ); // minimum scale of 3 so low UV days look right
    if (maxY == 0) return;

    const padTop = 2.0;
    const padBottom = 14.0;
    const padLeft = 20.0;
    final graphH = size.height - padTop - padBottom;
    final graphW = size.width - padLeft;
    final stepX = graphW / (uvValues.length - 1);

    final points = <Offset>[];
    for (var i = 0; i < uvValues.length; i++) {
      final x = padLeft + i * stepX;
      final y = padTop + graphH * (1 - (uvValues[i] / maxY).clamp(0.0, 1.0));
      points.add(Offset(x, y));
    }

    // Y-axis labels
    final yLabelStyle = TextStyle(
      color: AppColors.cream.withValues(alpha: 0.95),
      fontSize: 10,
      fontWeight: FontWeight.w600,
    );
    for (final val in [maxY, maxY / 2, 0.0]) {
      final y = padTop + graphH * (1 - val / maxY);
      final tp = TextPainter(
        text: TextSpan(text: '${val.round()}', style: yLabelStyle),
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

    // "Now" dot
    final nowTime = now;
    if (nowTime != null && hours.length >= 2) {
      double dotX;
      double dotY;

      if (nowTime.isBefore(hours.first)) {
        dotX = points.first.dx;
        dotY = points.first.dy;
      } else if (nowTime.isAfter(hours.last)) {
        dotX = points.last.dx;
        dotY = points.last.dy;
      } else {
        var idx = 0;
        for (var i = 0; i < hours.length - 1; i++) {
          if (!nowTime.isBefore(hours[i]) && nowTime.isBefore(hours[i + 1])) {
            idx = i;
            break;
          }
        }
        final segFraction = hours[idx + 1].difference(hours[idx]).inSeconds > 0
            ? nowTime.difference(hours[idx]).inSeconds /
                  hours[idx + 1].difference(hours[idx]).inSeconds
            : 0.0;
        dotX =
            points[idx].dx +
            (points[idx + 1].dx - points[idx].dx) * segFraction;
        final interpUv =
            uvValues[idx] + (uvValues[idx + 1] - uvValues[idx]) * segFraction;
        dotY = padTop + graphH * (1 - (interpUv / maxY).clamp(0.0, 1.0));
      }

      canvas.drawCircle(
        Offset(dotX, dotY),
        4,
        Paint()..color = AppColors.cream,
      );
    }

    // Hour labels
    final labelStyle = TextStyle(
      color: AppColors.cream.withValues(alpha: 0.9),
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
  bool shouldRepaint(covariant _UvLinePainter old) =>
      uvValues != old.uvValues || now != old.now;
}
