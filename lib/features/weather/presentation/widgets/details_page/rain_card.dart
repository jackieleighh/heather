import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:heather/core/constants/app_colors.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:weather_icons/weather_icons.dart';
import './card_container.dart';

class RainCard extends StatelessWidget {
  final double precipitationIn;
  final int precipitationProbability;
  final List<int> hourlyPrecipProb;
  final List<DateTime> hours;
  final DateTime? now;
  final bool compact;

  const RainCard({
    super.key,
    required this.precipitationIn,
    required this.precipitationProbability,
    required this.hourlyPrecipProb,
    required this.hours,
    this.now,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final precipLabel = precipitationIn < 0.01
        ? '0"'
        : '${precipitationIn.toStringAsFixed(2)}"';

    return CardContainer(
      backgroundIcon: WeatherIcons.rain,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                WeatherIcons.raindrop,
                size: compact ? 12 : 18,
                color: AppColors.cream.withValues(alpha: 0.9),
              ),
              SizedBox(width: compact ? 5 : 8),
              Text(
                'Rain',
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              const Spacer(),
              Text(
                precipLabel,
                style: GoogleFonts.poppins(
                  fontSize: compact ? 11 : 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.cream,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                '$precipitationProbability% chance',
                style: GoogleFonts.poppins(
                  fontSize: compact ? 11 : 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.cream.withValues(alpha: 0.9),
                ),
              ),
            ],
          ),
          SizedBox(height: compact ? 4 : 6),
          Expanded(
            child: CustomPaint(
              size: Size.infinite,
              painter: _PrecipBarPainter(
                precipProb: hourlyPrecipProb,
                hours: hours,
                now: now,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PrecipBarPainter extends CustomPainter {
  final List<int> precipProb;
  final List<DateTime> hours;
  final DateTime? now;

  _PrecipBarPainter({required this.precipProb, required this.hours, this.now});

  @override
  void paint(Canvas canvas, Size size) {
    if (precipProb.isEmpty) return;

    const padBottom = 14.0;
    const padLeft = 28.0;
    final graphH = size.height - padBottom;
    final graphW = size.width - padLeft;
    final barCount = precipProb.length;
    final barW = graphW / barCount;

    // Y-axis percentage labels
    final yLabelStyle = TextStyle(
      color: AppColors.cream.withValues(alpha: 0.95),
      fontSize: 10,
      fontWeight: FontWeight.w600,
    );
    for (final pct in [100, 50, 0]) {
      final y = graphH * (1 - pct / 100.0);
      final tp = TextPainter(
        text: TextSpan(text: '$pct%', style: yLabelStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(0, y - tp.height / 2));

      // Subtle grid line
      canvas.drawLine(
        Offset(padLeft, y),
        Offset(size.width, y),
        Paint()..color = AppColors.cream.withValues(alpha: 0.25),
      );
    }

    // Precipitation probability bars
    for (var i = 0; i < barCount; i++) {
      final pct = precipProb[i] / 100.0;
      final barH = math.max(graphH * pct, pct > 0 ? 2.0 : 0.0);
      final x = padLeft + i * barW;
      final y = graphH - barH;

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x + 1, y, barW - 2, barH),
          const Radius.circular(2),
        ),
        Paint()..color = AppColors.cream.withValues(alpha: 0.45 + 0.45 * pct),
      );
    }

    // "Now" indicator line
    final nowTime = now;
    if (nowTime != null && hours.length >= 2) {
      if (!nowTime.isBefore(hours.first) && !nowTime.isAfter(hours.last)) {
        final totalMs = hours.last
            .difference(hours.first)
            .inMilliseconds
            .toDouble();
        if (totalMs > 0) {
          final nowMs = nowTime
              .difference(hours.first)
              .inMilliseconds
              .toDouble();
          final nowX = padLeft + graphW * (nowMs / totalMs);
          canvas.drawLine(
            Offset(nowX, 0),
            Offset(nowX, graphH),
            Paint()
              ..color = AppColors.cream.withValues(alpha: 0.9)
              ..strokeWidth = 1,
          );
        }
      }
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
      final x = (padLeft + i * barW + barW / 2 - tp.width / 2).clamp(
        padLeft,
        size.width - tp.width,
      );
      tp.paint(canvas, Offset(x, size.height - padBottom + 2));
    }
  }

  @override
  bool shouldRepaint(covariant _PrecipBarPainter old) =>
      precipProb != old.precipProb || now != old.now;
}
