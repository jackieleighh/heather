import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:heather/core/constants/app_colors.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:weather_icons/weather_icons.dart';
import './card_container.dart';
import './card_display_mode.dart';
import './info_chip.dart';

class TemperatureCard extends StatelessWidget {
  final List<double> temps;
  final List<DateTime> hours;
  final DateTime? now;
  final bool compact;
  final double? averageHigh;
  final double? todayHigh;
  final double? currentTemp;
  final double? currentFeelsLike;
  final double? currentDewPoint;
  final CardDisplayMode mode;
  final List<double> feelsLikeTemps;
  final bool flat;

  const TemperatureCard({
    super.key,
    required this.temps,
    required this.hours,
    this.now,
    this.compact = false,
    this.averageHigh,
    this.todayHigh,
    this.currentTemp,
    this.currentFeelsLike,
    this.currentDewPoint,
    this.mode = CardDisplayMode.normal,
    this.feelsLikeTemps = const [],
    this.flat = false,
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
      final warmest = _findExtreme(temps, hours, warmest: true);
      final coldest = _findExtreme(temps, hours, warmest: false);

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
            const Spacer(),
            if (currentTemp != null) ...[
              _buildHeroNow(),
              const SizedBox(height: 2),
              _buildRangeGauge(lo, hi),
            ],
            const Spacer(),
            _build2x2InfoGrid(warmest, coldest, hi, lo),
            const Spacer(),
            // Legend
            if (feelsLikeTemps.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 10, bottom: 2),
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
            SizedBox(
              width: double.infinity,
              height: 106,
              child: CustomPaint(
                size: Size.infinite,
                painter: _TempLinePainter(
                  temps: temps,
                  hours: hours,
                  now: now,
                  feelsLikeTemps: feelsLikeTemps,
                  showAreaFill: true,
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
      flat: flat,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeaderRow(hi, lo),
          if (averageHigh != null && todayHigh != null && !compact)
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
                showAreaFill: true,
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

  Widget _buildHeroNow() {
    final temp = currentTemp!;
    final feels = currentFeelsLike;
    final showFeels = feels != null && (feels - temp).abs() >= 1;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        const Spacer(),
        if (showFeels) ...[
          Text(
            'feels ${feels.round()}°',
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: AppColors.cream.withValues(alpha: 0.85),
            ),
          ),
          const SizedBox(width: 8),
        ],
        Text(
          '${temp.round()}°',
          style: GoogleFonts.poppins(
            fontSize: 42,
            fontWeight: FontWeight.w700,
            color: AppColors.cream,
            height: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildRangeGauge(double todayLo, double todayHi) {
    final feels = currentFeelsLike;
    final showFeels = feels != null && (feels - currentTemp!).abs() >= 1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: double.infinity,
          height: 44,
          child: CustomPaint(
            size: Size.infinite,
            painter: _RangeGaugePainter(
              currentTemp: currentTemp,
              feelsLike: showFeels ? feels : null,
              avg: averageHigh,
              todayLo: todayLo,
              todayHi: todayHi,
            ),
          ),
        ),
        const SizedBox(height: 2),
        Transform.translate(
          offset: const Offset(0, -10),
          child: Row(
            children: [
              Text(
                '${todayLo.round()}°',
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: AppColors.cream.withValues(alpha: 0.7),
                ),
              ),
              const Spacer(),
              Text(
                '${todayHi.round()}°',
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: AppColors.cream.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _build2x2InfoGrid(
    (DateTime, double) warmest,
    (DateTime, double) coldest,
    double hi,
    double lo,
  ) {
    final swing = (hi - lo).round();
    final dew = currentDewPoint;
    final dewValue = (dew == null || dew == 0.0)
        ? '--'
        : '${dew.round()}° ${_dewPointLabel(dew)}';

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: InfoChip(
                icon: WeatherIcons.hot,
                label: 'Warmest',
                value:
                    '${_formatHourShort(warmest.$1)} · ${warmest.$2.round()}°',
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: InfoChip(
                icon: WeatherIcons.snowflake_cold,
                label: 'Coldest',
                value:
                    '${_formatHourShort(coldest.$1)} · ${coldest.$2.round()}°',
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: InfoChip(
                icon: WeatherIcons.thermometer_exterior,
                label: 'Swing',
                value: '$swing° range',
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: InfoChip(
                icon: WeatherIcons.raindrop,
                label: 'Dew point',
                value: dewValue,
              ),
            ),
          ],
        ),
      ],
    );
  }

  static (DateTime, double) _findExtreme(
    List<double> temps,
    List<DateTime> hours, {
    required bool warmest,
  }) {
    var idx = 0;
    for (var i = 1; i < temps.length; i++) {
      if (warmest ? temps[i] > temps[idx] : temps[i] < temps[idx]) {
        idx = i;
      }
    }
    return (hours[idx], temps[idx]);
  }

  static String _dewPointLabel(double dewF) {
    if (dewF < 55) return 'Dry';
    if (dewF < 60) return 'Comfy';
    if (dewF < 65) return 'Sticky';
    if (dewF < 70) return 'Muggy';
    return 'Oppressive';
  }

  static String _formatHourShort(DateTime dt) {
    final h = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final suffix = dt.hour >= 12 ? 'pm' : 'am';
    return '$h$suffix';
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
  final bool showAreaFill;

  _TempLinePainter({
    required this.temps,
    required this.hours,
    this.now,
    this.feelsLikeTemps = const [],
    this.showAreaFill = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (temps.length < 2) return;

    final allValues = [...temps, ...feelsLikeTemps];
    final dataLo = allValues.reduce(math.min);
    final dataHi = allValues.reduce(math.max);
    if (dataHi - dataLo == 0) return;

    const step = 5.0; // y-axis snaps to 5° increments
    const minHeadroom = 2.0; // minimum gap between data and chart edge

    var lo = (dataLo / step).floor() * step;
    var hi = (dataHi / step).ceil() * step;
    if (dataLo - lo < minHeadroom) lo -= step;
    if (hi - dataHi < minHeadroom) hi += step;

    final range = hi - lo;

    const padTop = 2.0;
    const padBottom = 14.0;
    const padLeft = 24.0;
    final graphH = size.height - padTop - padBottom;
    final graphW = size.width - padLeft;
    final stepX = graphW / (temps.length - 1);

    final points = <Offset>[];
    for (var i = 0; i < temps.length; i++) {
      final x = padLeft + i * stepX;
      final y = padTop + graphH * (1 - (temps[i] - lo) / range);
      points.add(Offset(x, y));
    }

    final mid = (lo + hi) / 2;

    // 1. Build the main temperature curve path
    final linePath = Path()..moveTo(points.first.dx, points.first.dy);
    for (var i = 1; i < points.length; i++) {
      final prev = points[i - 1];
      final curr = points[i];
      final cpx = (prev.dx + curr.dx) / 2;
      linePath.cubicTo(cpx, prev.dy, cpx, curr.dy, curr.dx, curr.dy);
    }

    // 2. Optional gradient fill under the curve (expanded mode only)
    if (showAreaFill) {
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
            AppColors.cream.withValues(alpha: 0.03),
          ],
        ).createShader(fillRect);
      canvas.drawPath(fillPath, fillPaint);
    }

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
        ..color = AppColors.cream.withValues(alpha: 0.5)
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );

    // 5. "Now" dot
    final nowTime = now;
    if (nowTime != null && hours.length >= 2) {
      double dotX;
      double dotY;
      double? feelsDotY;

      final hasFeelsLine = feelsLikeTemps.length == temps.length;

      if (nowTime.isBefore(hours.first)) {
        dotX = points.first.dx;
        dotY = points.first.dy;
        if (hasFeelsLine) {
          feelsDotY =
              padTop + graphH * (1 - (feelsLikeTemps.first - lo) / range);
        }
      } else if (nowTime.isAfter(hours.last)) {
        dotX = points.last.dx;
        dotY = points.last.dy;
        if (hasFeelsLine) {
          feelsDotY =
              padTop + graphH * (1 - (feelsLikeTemps.last - lo) / range);
        }
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
        if (hasFeelsLine) {
          final interpFeels =
              feelsLikeTemps[idx] +
              (feelsLikeTemps[idx + 1] - feelsLikeTemps[idx]) * segFraction;
          feelsDotY = padTop + graphH * (1 - (interpFeels - lo) / range);
        }
      }

      if (feelsDotY != null) {
        canvas.drawCircle(
          Offset(dotX, feelsDotY),
          3.5,
          Paint()
            ..color = AppColors.cream.withValues(alpha: 0.6)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.5,
        );
      }

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
      temps != old.temps ||
      now != old.now ||
      feelsLikeTemps != old.feelsLikeTemps ||
      showAreaFill != old.showAreaFill;
}

class _RangeGaugePainter extends CustomPainter {
  final double? currentTemp;
  final double? feelsLike;
  final double? avg;
  final double todayLo;
  final double todayHi;

  _RangeGaugePainter({
    required this.currentTemp,
    required this.feelsLike,
    required this.avg,
    required this.todayLo,
    required this.todayHi,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const barH = 6.0;
    final barY = (size.height - barH) / 2;
    final barRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, barY, size.width, barH),
      const Radius.circular(3),
    );

    // Track
    canvas.drawRRect(
      barRect,
      Paint()..color = AppColors.cream.withValues(alpha: 0.12),
    );

    // Compute scale window.
    var scaleLo = todayLo;
    var scaleHi = todayHi;
    for (final v in [currentTemp, feelsLike, avg]) {
      if (v != null && v != 0.0) {
        if (v < scaleLo) scaleLo = v;
        if (v > scaleHi) scaleHi = v;
      }
    }
    scaleLo -= 2;
    scaleHi += 2;

    // Flat-day / degenerate range guard.
    if (scaleHi - scaleLo < 10) {
      final center = (scaleLo + scaleHi) / 2;
      scaleLo = center - 5;
      scaleHi = center + 5;
    }

    final range = scaleHi - scaleLo;
    double posFor(double temp) {
      final frac = ((temp - scaleLo) / range).clamp(0.0, 1.0);
      return frac * size.width;
    }

    // Marker geometry (needed for collision detection).
    final nowX = currentTemp != null ? posFor(currentTemp!) : null;
    final feelsX = feelsLike != null ? posFor(feelsLike!) : null;
    final avgX = (avg != null && avg != 0.0) ? posFor(avg!) : null;

    // Draw avg tick first (thin, low-alpha) so dots sit on top cleanly.
    if (avgX != null) {
      final tickPaint = Paint()
        ..color = AppColors.cream.withValues(alpha: 0.55)
        ..strokeWidth = 2;
      final tickTop = barY + barH / 2 - 6;
      final tickBottom = barY + barH / 2 + 6;
      canvas.drawLine(
        Offset(avgX, tickTop),
        Offset(avgX, tickBottom),
        tickPaint,
      );
    }

    // Feels-like outline circle.
    if (feelsX != null) {
      canvas.drawCircle(
        Offset(feelsX, barY + barH / 2),
        4,
        Paint()
          ..color = AppColors.cream
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5,
      );
    }

    // Now dot on top.
    if (nowX != null) {
      canvas.drawCircle(
        Offset(nowX, barY + barH / 2),
        5,
        Paint()..color = AppColors.cream,
      );
    }

    // Labels: 'now' always below the bar; 'feels' and 'avg' above.
    // If feels and avg would horizontally overlap, stack them: feels on top,
    // avg immediately below (still above the bar).
    final labelStyle = TextStyle(
      color: AppColors.cream.withValues(alpha: 0.6),
      fontSize: 9,
      fontWeight: FontWeight.w600,
      fontFamily: GoogleFonts.poppins().fontFamily,
    );
    final nowLabelStyle = labelStyle.copyWith(
      color: AppColors.cream.withValues(alpha: 0.85),
    );

    TextPainter layoutLabel(String text, TextStyle style) => TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
    )..layout();

    final feelsTp = feelsX != null ? layoutLabel('feels', labelStyle) : null;
    final avgTp = avgX != null ? layoutLabel('avg', labelStyle) : null;
    final nowTp = nowX != null ? layoutLabel('now', nowLabelStyle) : null;

    // Horizontal collision between feels and avg.
    var feelsAvgOverlap = false;
    if (feelsX != null && avgX != null) {
      final minGap = (feelsTp!.width + avgTp!.width) / 2 + 4;
      feelsAvgOverlap = (feelsX - avgX).abs() < minGap;
    }

    // Vertical slots. Labels are painted by their top-left corner.
    final labelH = feelsTp?.height ?? avgTp?.height ?? nowTp?.height ?? 12.0;
    final topLowerY = barY - 6 - labelH; // just above the bar
    final topUpperY = topLowerY - labelH - 1; // stacked above lower
    final bottomY = barY + barH + 6; // just below the bar

    if (feelsAvgOverlap) {
      _paintLabelAt(canvas, feelsTp!, feelsX!, topUpperY, size.width);
      _paintLabelAt(canvas, avgTp!, avgX!, topLowerY, size.width);
    } else {
      if (feelsTp != null) {
        _paintLabelAt(canvas, feelsTp, feelsX!, topLowerY, size.width);
      }
      if (avgTp != null) {
        _paintLabelAt(canvas, avgTp, avgX!, topLowerY, size.width);
      }
    }
    if (nowTp != null) {
      _paintLabelAt(canvas, nowTp, nowX!, bottomY, size.width);
    }
  }

  void _paintLabelAt(
    Canvas canvas,
    TextPainter tp,
    double centerX,
    double topY,
    double maxWidth,
  ) {
    final x = (centerX - tp.width / 2).clamp(0.0, maxWidth - tp.width);
    tp.paint(canvas, Offset(x, topY));
  }

  @override
  bool shouldRepaint(covariant _RangeGaugePainter old) =>
      currentTemp != old.currentTemp ||
      feelsLike != old.feelsLike ||
      avg != old.avg ||
      todayLo != old.todayLo ||
      todayHi != old.todayHi;
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
      canvas.drawLine(
        Offset(x, y),
        Offset(math.min(x + 3, size.width), y),
        paint,
      );
      x += 5;
    }
  }

  @override
  bool shouldRepaint(covariant _DashedLinePainter old) => color != old.color;
}
