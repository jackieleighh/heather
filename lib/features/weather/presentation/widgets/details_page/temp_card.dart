import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:heather/core/constants/app_colors.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:weather_icons/weather_icons.dart';
import './card_container.dart';
import './card_display_mode.dart';

class TemperatureCard extends StatelessWidget {
  final List<double> temps;
  final List<DateTime> hours;
  final DateTime? now;
  final bool compact;
  final double? averageHigh;
  final double? todayHigh;
  final CardDisplayMode mode;
  final List<double> feelsLikeTemps;

  const TemperatureCard({
    super.key,
    required this.temps,
    required this.hours,
    this.now,
    this.compact = false,
    this.averageHigh,
    this.todayHigh,
    this.mode = CardDisplayMode.normal,
    this.feelsLikeTemps = const [],
  });

  @override
  Widget build(BuildContext context) {
    if (temps.isEmpty) return const SizedBox.shrink();

    final lo = temps.reduce(math.min);
    final hi = temps.reduce(math.max);

    if (mode == CardDisplayMode.collapsed) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: Row(
          children: [
            Icon(
              WeatherIcons.thermometer,
              size: 14,
              color: AppColors.cream.withValues(alpha: 0.9),
            ),
            const SizedBox(width: 4),
            Text(
              'Temp',
              style: GoogleFonts.figtree(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: AppColors.cream,
              ),
            ),
            const Spacer(),
            Text(
              '${hi.round()}° / ${lo.round()}°',
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.cream,
              ),
            ),
          ],
        ),
      );
    }

    if (mode == CardDisplayMode.expanded) {
      var hiIdx = 0;
      var loIdx = 0;
      for (var i = 1; i < temps.length; i++) {
        if (temps[i] > temps[hiIdx]) hiIdx = i;
        if (temps[i] < temps[loIdx]) loIdx = i;
      }
      final hiTime = hours[hiIdx];
      final loTime = hours[loIdx];

      return CardContainer(
        backgroundIcon: WeatherIcons.thermometer,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeaderRow(hi, lo),
            if (averageHigh != null && todayHigh != null)
              Row(
                children: [
                  const Spacer(),
                  _buildAvgIndicator(todayHigh!, averageHigh!),
                ],
              ),
            const SizedBox(height: 6),
            Row(
              children: [
                _buildHiLoLabel('High @ ', hiTime, hi),
                const SizedBox(width: 12),
                _buildHiLoLabel('Low @ ', loTime, lo),
              ],
            ),
            const SizedBox(height: 10),
            // Legend
            if (feelsLikeTemps.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Container(
                      width: 16,
                      height: 2,
                      color: AppColors.cream.withValues(alpha: 0.5),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      'Temp',
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: AppColors.cream.withValues(alpha: 0.8),
                      ),
                    ),
                    const SizedBox(width: 14),
                    _buildDashedLegendLine(),
                    const SizedBox(width: 5),
                    Text(
                      'Feels Like',
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: AppColors.cream.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 4),
            Expanded(
              child: CustomPaint(
                size: Size.infinite,
                painter: _TempLinePainter(
                  temps: temps,
                  hours: hours,
                  now: now,
                  feelsLikeTemps: feelsLikeTemps,
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Normal mode
    return CardContainer(
      backgroundIcon: WeatherIcons.thermometer,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeaderRow(hi, lo),
          if (averageHigh != null &&
              todayHigh != null &&
              !compact)
            Row(
              children: [
                const Spacer(),
                _buildAvgIndicator(todayHigh!, averageHigh!),
              ],
            ),
          SizedBox(height: compact ? 4 : 6),
          Expanded(
            child: CustomPaint(
              size: Size.infinite,
              painter: _TempLinePainter(
                temps: temps,
                hours: hours,
                now: now,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderRow(double hi, double lo) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Icon(
          WeatherIcons.thermometer,
          size: compact ? 10 : 15,
          color: AppColors.cream.withValues(alpha: 0.9),
        ),
        SizedBox(width: compact ? 3 : 4),
        Text(
          'Temp',
          style: GoogleFonts.figtree(
            fontSize: compact ? 14 : 18,
            fontWeight: FontWeight.w400,
            color: AppColors.cream,
          ),
        ),
        const Spacer(),
        Text(
          '${hi.round()}°',
          style: GoogleFonts.poppins(
            fontSize: compact ? 11 : 14,
            fontWeight: FontWeight.w700,
            color: AppColors.cream,
          ),
        ),
        Text(
          ' / ${lo.round()}°',
          style: GoogleFonts.poppins(
            fontSize: compact ? 11 : 14,
            fontWeight: FontWeight.w600,
            color: AppColors.cream.withValues(alpha: 0.9),
          ),
        ),
      ],
    );
  }

  Widget _buildHiLoLabel(String prefix, DateTime time, double temp) {
    final timeLabel = DateFormat('ha').format(time).toLowerCase();
    return Text.rich(
      TextSpan(
        style: GoogleFonts.poppins(
          fontSize: 11,
          fontWeight: FontWeight.w400,
          color: AppColors.cream.withValues(alpha: 0.85),
        ),
        children: [
          TextSpan(
            text: prefix,
            style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
          ),
          TextSpan(text: '$timeLabel  ${temp.round()}°'),
        ],
      ),
    );
  }

  Widget _buildDashedLegendLine() {
    return SizedBox(
      width: 16,
      height: 2,
      child: CustomPaint(
        painter: _DashedLinePainter(
          color: AppColors.cream.withValues(alpha: 0.35),
        ),
      ),
    );
  }

  Widget _buildAvgIndicator(double todayHigh, double averageHigh) {
    final diff = (todayHigh - averageHigh).round();
    if (diff == 0) return const SizedBox.shrink();
    final isAbove = diff > 0;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          isAbove ? Icons.arrow_upward : Icons.arrow_downward,
          size: 12,
          color: AppColors.cream.withValues(alpha: 0.8),
        ),
        const SizedBox(width: 2),
        Text(
          '${diff.abs()}° ${isAbove ? 'above' : 'below'} avg',
          style: GoogleFonts.poppins(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppColors.cream.withValues(alpha: 0.8),
          ),
        ),
      ],
    );
  }
}

class _TempLinePainter extends CustomPainter {
  final List<double> temps;
  final List<DateTime> hours;
  final DateTime? now;
  final List<double> feelsLikeTemps;

  _TempLinePainter({
    required this.temps,
    required this.hours,
    this.now,
    this.feelsLikeTemps = const [],
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (temps.length < 2) return;

    final allValues = [...temps, ...feelsLikeTemps];
    final dataLo = allValues.reduce(math.min);
    final dataHi = allValues.reduce(math.max);
    if (dataHi - dataLo == 0) return;

    const step = 5.0;          // y-axis snaps to 5° increments
    const minHeadroom = 2.0;   // minimum gap between data and chart edge

    var lo = (dataLo / step).floor() * step;
    var hi = (dataHi / step).ceil() * step;
    if (dataLo - lo < minHeadroom) lo -= step;
    if (hi - dataHi < minHeadroom) hi += step;

    final range = hi - lo;

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

    // 1. Horizontal grid lines at y-axis label positions
    final gridPaint = Paint()
      ..color = AppColors.cream.withValues(alpha: 0.06)
      ..strokeWidth = 1.0;
    final mid = (lo + hi) / 2;
    for (final temp in [hi, mid, lo]) {
      final y = padTop + graphH * (1 - (temp - lo) / range);
      canvas.drawLine(Offset(padLeft, y), Offset(size.width, y), gridPaint);
    }

    // 2. Build the main temperature curve path
    final linePath = Path()..moveTo(points.first.dx, points.first.dy);
    for (var i = 1; i < points.length; i++) {
      final prev = points[i - 1];
      final curr = points[i];
      final cpx = (prev.dx + curr.dx) / 2;
      linePath.cubicTo(cpx, prev.dy, cpx, curr.dy, curr.dx, curr.dy);
    }

    // Gradient fill under the temperature curve
    final fillPath = Path.from(linePath)
      ..lineTo(points.last.dx, padTop + graphH)
      ..lineTo(points.first.dx, padTop + graphH)
      ..close();
    final fillRect = Rect.fromLTRB(
      points.first.dx,
      padTop,
      points.last.dx,
      padTop + graphH,
    );
    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          AppColors.cream.withValues(alpha: 0.15),
          AppColors.cream.withValues(alpha: 0.02),
        ],
      ).createShader(fillRect);
    canvas.drawPath(fillPath, fillPaint);

    // 3. Feels-like dashed line overlay
    if (feelsLikeTemps.length == temps.length) {
      final flPoints = <Offset>[];
      for (var i = 0; i < feelsLikeTemps.length; i++) {
        final x = padLeft + i * stepX;
        final y = padTop + graphH * (1 - (feelsLikeTemps[i] - lo) / range);
        flPoints.add(Offset(x, y));
      }

      final flPath = Path()..moveTo(flPoints.first.dx, flPoints.first.dy);
      for (var i = 1; i < flPoints.length; i++) {
        final prev = flPoints[i - 1];
        final curr = flPoints[i];
        final cpx = (prev.dx + curr.dx) / 2;
        flPath.cubicTo(cpx, prev.dy, cpx, curr.dy, curr.dx, curr.dy);
      }

      final dashPaint = Paint()
        ..color = AppColors.cream.withValues(alpha: 0.35)
        ..strokeWidth = 1.5
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      _drawDashedPath(canvas, flPath, dashPaint, 6, 4);
    }

    // 4. Main temperature stroke line (on top of fill and feels-like)
    canvas.drawPath(
      linePath,
      Paint()
        ..color = AppColors.cream.withValues(alpha: 0.6)
        ..strokeWidth = 2.5
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );

    // 5. "Now" vertical reference line + dot
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
        final interpTemp =
            temps[idx] + (temps[idx + 1] - temps[idx]) * segFraction;
        dotY = padTop + graphH * (1 - (interpTemp - lo) / range);
      }

      // Vertical now-line (behind the dot)
      canvas.drawLine(
        Offset(dotX, padTop),
        Offset(dotX, padTop + graphH),
        Paint()
          ..color = AppColors.cream.withValues(alpha: 0.15)
          ..strokeWidth = 1.0,
      );

      canvas.drawCircle(
        Offset(dotX, dotY),
        4,
        Paint()..color = AppColors.cream,
      );
    }

    // 6. Y-axis temp labels (high, mid, low)
    final yLabelStyle = TextStyle(
      color: AppColors.cream.withValues(alpha: 0.95),
      fontSize: 10,
      fontWeight: FontWeight.w600,
    );
    for (final temp in [hi, mid, lo]) {
      final y = padTop + graphH * (1 - (temp - lo) / range);
      final tp = TextPainter(
        text: TextSpan(text: '${temp.round()}°', style: yLabelStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(0, y - tp.height / 2));
    }

    // 7. Hour labels
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

  void _drawDashedPath(
    Canvas canvas,
    Path path,
    Paint paint,
    double dashLen,
    double gapLen,
  ) {
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final end = math.min(distance + dashLen, metric.length);
        final segment = metric.extractPath(distance, end);
        canvas.drawPath(segment, paint);
        distance += dashLen + gapLen;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _TempLinePainter old) =>
      temps != old.temps || now != old.now || feelsLikeTemps != old.feelsLikeTemps;
}

class _DashedLinePainter extends CustomPainter {
  final Color color;

  _DashedLinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    final y = size.height / 2;
    var x = 0.0;
    while (x < size.width) {
      canvas.drawLine(Offset(x, y), Offset(math.min(x + 3, size.width), y), paint);
      x += 5;
    }
  }

  @override
  bool shouldRepaint(covariant _DashedLinePainter old) => color != old.color;
}
