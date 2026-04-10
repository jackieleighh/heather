import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:heather/core/constants/app_colors.dart';
import 'package:heather/core/utils/uv_index.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:weather_icons/weather_icons.dart';
import './card_container.dart';
import './card_display_mode.dart';
import './info_chip.dart';

class SunCard extends StatelessWidget {
  // Arc canvas geometry — kept here so the LayoutBuilder placing the
  // sunrise/sunset labels and `_SunArcPainter` agree on the endpoints.
  static const double _arcCanvasHeight = 60;
  static const double _arcTopPad = 6;
  static const double _arcBottomGutter = 4;
  // Arc is drawn as a true circular arc (not an ellipse). The visible
  // height is capped by the canvas; the circle radius is computed via the
  // sagitta formula so the curve always looks like the top of a circle.
  static const double _arcRadiusXMax = 200;

  final DateTime sunrise;
  final DateTime sunset;
  final bool isSunUp;
  final double uvIndex;
  final List<double> hourlyUv;
  final List<DateTime> hours;
  final DateTime? now;
  final CardDisplayMode mode;
  final double visibility;
  final int dayLengthDeltaMinutes;
  final DateTime? tomorrowSunrise;
  final DateTime? tomorrowSunset;

  const SunCard({
    super.key,
    required this.sunrise,
    required this.sunset,
    this.isSunUp = true,
    required this.uvIndex,
    required this.hourlyUv,
    required this.hours,
    this.now,
    this.mode = CardDisplayMode.normal,
    this.visibility = 0.0,
    this.dayLengthDeltaMinutes = 0,
    this.tomorrowSunrise,
    this.tomorrowSunset,
  });

  @override
  Widget build(BuildContext context) {
    final timeFmt = DateFormat('h:mm a');
    final theme = Theme.of(context);

    if (mode == CardDisplayMode.collapsed) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: Row(
          children: [
            Icon(
              WeatherIcons.day_sunny,
              size: 14,
              color: AppColors.cream90,
            ),
            const SizedBox(width: 4),
            Text(
              'Sun',
              style: GoogleFonts.figtree(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: AppColors.cream,
              ),
            ),
            const Spacer(),
            if (isSunUp) ...[
              Text(
                'UV ${uvIndex.round()}',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.cream,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                uvLevelLabel(uvIndex),
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: AppColors.cream,
                ),
              ),
            ] else ...[
              Icon(
                WeatherIcons.sunrise,
                size: 12,
                color: AppColors.cream90,
              ),
              const SizedBox(width: 3),
              Text(
                timeFmt.format(sunrise),
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.cream,
                ),
              ),
            ],
          ],
        ),
      );
    }

    if (mode == CardDisplayMode.expanded) {
      final dayLength = sunset.difference(sunrise);
      final dayH = dayLength.inHours;
      final dayM = dayLength.inMinutes % 60;
      final protection = _uvProtectionWindow(hourlyUv, hours);

      return CardContainer(
        backgroundIcon: WeatherIcons.day_sunny,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Header row
            _buildHeaderRow(timeFmt, theme),
            const SizedBox(height: 2),
            // 2. Subtitle row
            Row(
              children: [
                const Spacer(),
                Text(
                  _formatRemaining(now, isSunUp, sunrise, sunset),
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: AppColors.cream80,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'UV ${uvIndex.round()}',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.cream,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  uvLevelLabel(uvIndex),
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.cream90,
                  ),
                ),
                if (!isSunUp) ...[
                  const SizedBox(width: 4),
                  Text(
                    'tmrw',
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: FontWeight.w400,
                      color: AppColors.cream75,
                    ),
                  ),
                ],
              ],
            ),
            const Spacer(),
            // 3. Sun Arc visualization
            SizedBox(
              height: _arcCanvasHeight,
              child: CustomPaint(
                size: Size.infinite,
                painter: _SunArcPainter(
                  sunrise: sunrise,
                  sunset: sunset,
                  now: now ?? DateTime.now(),
                  goldenHour: _goldenHour(sunset),
                  protectionStart: protection?.$1,
                  protectionEnd: protection?.$2,
                ),
              ),
            ),
            // Sunrise / sunset labels — stacked under icons, centered exactly
            // on the arc's left and right endpoints. The arc is normally
            // height-limited on a phone, so we need to mirror the painter's
            // arcRadius math to know where the endpoints actually land.
            SizedBox(
              height: 34,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final w = constraints.maxWidth;
                  final arcRadiusX = math.min(_arcRadiusXMax, (w - 32) / 2);
                  final arcLeft = w / 2 - arcRadiusX;
                  final arcRight = w / 2 + arcRadiusX;
                  return Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Positioned(
                        left: arcLeft,
                        top: 0,
                        child: FractionalTranslation(
                          translation: const Offset(-0.5, 0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                WeatherIcons.sunrise,
                                size: 14,
                                color: AppColors.cream95,
                              ),
                              const SizedBox(height: 1),
                              Text(
                                DateFormat('h:mm a').format(sunrise),
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                  color: AppColors.cream95,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        left: arcRight,
                        top: 0,
                        child: FractionalTranslation(
                          translation: const Offset(-0.5, 0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                WeatherIcons.sunset,
                                size: 14,
                                color: AppColors.cream95,
                              ),
                              const SizedBox(height: 1),
                              Text(
                                DateFormat('h:mm a').format(sunset),
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                  color: AppColors.cream95,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            const Spacer(),
            // 4. Daylight text + protection window
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  WeatherIcons.time_3,
                  size: 12,
                  color: AppColors.cream95,
                ),
                const SizedBox(width: 5),
                Text.rich(
                  TextSpan(
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.cream95,
                    ),
                    children: [
                      if (!isSunUp)
                        TextSpan(
                          text: 'Tomorrow  \u00B7  ',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: AppColors.cream95,
                          ),
                        ),
                      TextSpan(text: '${dayH}h ${dayM}m daylight'),
                      if (isSunUp &&
                          _formatDayDelta(dayLengthDeltaMinutes).isNotEmpty)
                        TextSpan(
                          text: _formatDayDelta(dayLengthDeltaMinutes),
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: AppColors.cream75,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            if (protection != null) ...[
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    WeatherIcons.umbrella,
                    size: 12,
                    color: AppColors.cream90,
                  ),
                  const SizedBox(width: 5),
                  Text.rich(
                    TextSpan(
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: AppColors.cream90,
                      ),
                      children: [
                        const TextSpan(text: 'SPF/shade '),
                        TextSpan(
                          text:
                              '${DateFormat('h a').format(protection.$1)} - ${DateFormat('h a').format(protection.$2)}',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.cream95,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
            ],
            const Spacer(),
            // 5. 2x2 info grid
            _buildInfoGrid(),
            const Spacer(),
            // 6. UV chart with area fill
            if (hourlyUv.length >= 2) ...[
              const SizedBox(height: 4),
              SizedBox(
                width: double.infinity,
                height: 90,
                child: CustomPaint(
                  size: Size.infinite,
                  painter: _UvLinePainter(
                    uvValues: hourlyUv,
                    hours: hours,
                    now: now,
                    showAreaFill: true,
                    showLabel: true,
                  ),
                ),
              ),
            ],
          ],
        ),
      );
    }

    // Normal mode
    return CardContainer(
      backgroundIcon: WeatherIcons.day_sunny,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeaderRow(timeFmt, theme),
          const SizedBox(height: 2),
          Row(
            children: [
              const Spacer(),
              Text(
                _formatRemaining(now, isSunUp, sunrise, sunset),
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: AppColors.cream80,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'UV ${uvIndex.round()}',
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.cream,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                uvLevelLabel(uvIndex),
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.cream90,
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
                  showAreaFill: true,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildHeaderRow(DateFormat timeFmt, ThemeData theme) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Icon(
          WeatherIcons.day_sunny,
          size: 15,
          color: AppColors.cream90,
        ),
        const SizedBox(width: 4),
        Text(
          'Sun',
          style: GoogleFonts.figtree(
            fontSize: 18,
            fontWeight: FontWeight.w400,
            color: AppColors.cream,
          ),
        ),
        const Spacer(),
        Row(
          children: [
            Icon(
              isSunUp ? WeatherIcons.sunset : WeatherIcons.sunrise,
              size: 13,
              color: AppColors.cream95,
            ),
            const SizedBox(width: 4),
            Text(
              timeFmt.format(isSunUp ? sunset : sunrise),
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w800,
                fontSize: 14,
              ),
            ),
            const SizedBox(width: 14),
            Icon(
              isSunUp ? WeatherIcons.sunrise : WeatherIcons.sunset,
              size: 13,
              color: AppColors.cream95,
            ),
            const SizedBox(width: 4),
            Text(
              // When the sun is currently up, `sunrise` is today's (already
              // past). The "after the next event" slot should show the next
              // morning's sunrise instead.
              timeFmt.format(isSunUp ? (tomorrowSunrise ?? sunrise) : sunset),
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w800,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoGrid() {
    final timeFmt = DateFormat('h:mm a');
    final hourFmt = DateFormat('h a');
    final noon = _solarNoon(sunrise, sunset);
    final peak = _peakUv(hourlyUv, hours);
    final golden = _goldenHour(sunset);

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: InfoChip(
                icon: WeatherIcons.day_sunny,
                label: 'Solar noon',
                value: timeFmt.format(noon),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: InfoChip(
                icon: WeatherIcons.day_haze,
                label: 'Visibility',
                value: _formatVisibility(visibility),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: InfoChip(
                icon: WeatherIcons.hot,
                label: 'Peak UV',
                value: peak != null ? hourFmt.format(peak.$1) : '--',
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: InfoChip(
                icon: WeatherIcons.sunset,
                label: 'Golden hour',
                value: timeFmt.format(golden),
              ),
            ),
          ],
        ),
      ],
    );
  }

  static String _formatRemaining(
    DateTime? now,
    bool isSunUp,
    DateTime sunrise,
    DateTime sunset,
  ) {
    if (now == null) return '';
    final remaining = isSunUp
        ? sunset.difference(now)
        : sunrise.difference(now);
    if (remaining.isNegative) return '';
    final h = remaining.inHours;
    final m = remaining.inMinutes % 60;
    final label = isSunUp ? 'light left' : 'darkness left';
    if (h > 0) return '${h}h ${m}m $label';
    return '${m}m $label';
  }

  static DateTime _solarNoon(DateTime sunrise, DateTime sunset) {
    return sunrise.add(sunset.difference(sunrise) ~/ 2);
  }

  static (DateTime, double)? _peakUv(
    List<double> hourlyUv,
    List<DateTime> hours,
  ) {
    if (hourlyUv.isEmpty) return null;
    var maxIdx = 0;
    for (var i = 1; i < hourlyUv.length; i++) {
      if (hourlyUv[i] > hourlyUv[maxIdx]) maxIdx = i;
    }
    if (hourlyUv[maxIdx] <= 0) return null;
    return (hours[maxIdx], hourlyUv[maxIdx]);
  }

  static (DateTime, DateTime)? _uvProtectionWindow(
    List<double> hourlyUv,
    List<DateTime> hours,
  ) {
    DateTime? first;
    DateTime? last;
    for (var i = 0; i < hourlyUv.length; i++) {
      if (hourlyUv[i] >= 3) {
        first ??= hours[i];
        last = hours[i];
      }
    }
    if (first == null || last == null) return null;
    return (first, last);
  }

  static DateTime _goldenHour(DateTime sunset) {
    return sunset.subtract(const Duration(minutes: 30));
  }

  static String _formatDayDelta(int deltaMinutes) {
    if (deltaMinutes == 0) return '';
    final sign = deltaMinutes > 0 ? '+' : '';
    return ' ($sign${deltaMinutes}m tmrw)';
  }

  static String _formatVisibility(double visMiles) {
    if (visMiles >= 10) return '${visMiles.round()} mi';
    return '${visMiles.toStringAsFixed(1)} mi';
  }
}

class _UvLinePainter extends CustomPainter {
  static const _uvLabelStyle = TextStyle(
    color: AppColors.cream90,
    fontSize: 10,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.5,
  );

  static const _yLabelStyle = TextStyle(
    color: AppColors.cream95,
    fontSize: 10,
    fontWeight: FontWeight.w600,
  );

  static const _hourLabelStyle = TextStyle(
    color: AppColors.cream90,
    fontSize: 10,
    fontWeight: FontWeight.w600,
  );

  final List<double> uvValues;
  final List<DateTime> hours;
  final DateTime? now;
  final bool showAreaFill;
  final bool showLabel;

  _UvLinePainter({
    required this.uvValues,
    required this.hours,
    this.now,
    this.showAreaFill = false,
    this.showLabel = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (uvValues.length < 2) return;

    final hi = uvValues.reduce(math.max);
    final maxY = math.max(hi, 3.0);
    if (maxY == 0) return;

    final padTop = showLabel ? 24.0 : 2.0;
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

    // "UV index" chart label (top-left)
    if (showLabel) {
      final uvLabelPainter = TextPainter(
        text: const TextSpan(
          text: 'UV index',
          style: _uvLabelStyle,
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      uvLabelPainter.paint(canvas, const Offset(0, 0));
    }

    // Y-axis labels
    for (final val in [maxY, maxY / 2, 0.0]) {
      final y = padTop + graphH * (1 - val / maxY);
      final tp = TextPainter(
        text: TextSpan(text: '${val.round()}', style: _yLabelStyle),
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

    // Area fill under the curve
    if (showAreaFill) {
      final bottomY = padTop + graphH;
      final fillPath = Path()..addPath(linePath, Offset.zero);
      fillPath.lineTo(points.last.dx, bottomY);
      fillPath.lineTo(points.first.dx, bottomY);
      fillPath.close();

      final fillPaint = Paint()
        ..shader =
            LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.cream15,
                AppColors.cream03,
              ],
            ).createShader(
              Rect.fromLTRB(padLeft, padTop, padLeft + graphW, bottomY),
            )
        ..style = PaintingStyle.fill;
      canvas.drawPath(fillPath, fillPaint);
    }

    canvas.drawPath(
      linePath,
      Paint()
        ..color = AppColors.cream50
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
    for (var i = 0; i < hours.length; i++) {
      if (i % 6 != 0 && i != hours.length - 1) continue;
      final tp = TextPainter(
        text: TextSpan(
          text: DateFormat('ha').format(hours[i]).toLowerCase(),
          style: _hourLabelStyle,
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
      uvValues != old.uvValues ||
      now?.millisecondsSinceEpoch != old.now?.millisecondsSinceEpoch ||
      showAreaFill != old.showAreaFill ||
      showLabel != old.showLabel;
}

// ---------------------------------------------------------------------------
// Sun Arc Painter — semicircular arc showing sun's journey across the sky
// ---------------------------------------------------------------------------

class _SunArcPainter extends CustomPainter {
  final DateTime sunrise;
  final DateTime sunset;
  final DateTime now;
  final DateTime goldenHour;
  final DateTime? protectionStart;
  final DateTime? protectionEnd;

  _SunArcPainter({
    required this.sunrise,
    required this.sunset,
    required this.now,
    required this.goldenHour,
    this.protectionStart,
    this.protectionEnd,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    const topPad = SunCard._arcTopPad;
    const bottomGutter = SunCard._arcBottomGutter;
    final horizY = h - bottomGutter;
    final arcRadiusX = math.min(SunCard._arcRadiusXMax, (w - 32) / 2);
    final sagitta = horizY - topPad; // visible arc height
    // True circular arc via sagitta formula: R = (c² + h²) / (2h)
    // where c = half-chord (arcRadiusX) and h = sagitta.
    final circleR =
        (arcRadiusX * arcRadiusX + sagitta * sagitta) / (2 * sagitta);
    final arcCenterX = w / 2;
    // Circle center sits below the horizon since circleR > sagitta.
    final circleCenterY = horizY + circleR - sagitta;
    final circleRect = Rect.fromCenter(
      center: Offset(arcCenterX, circleCenterY),
      width: circleR * 2,
      height: circleR * 2,
    );
    // Half-angle from the top of the circle to each endpoint.
    final halfAngle = math.asin(arcRadiusX / circleR);
    // In Flutter, 3π/2 is 12 o'clock. Sweep clockwise through the top.
    final arcStartAngle = 3 * math.pi / 2 - halfAngle;
    final arcSweepAngle = 2 * halfAngle;
    final arcLeft = arcCenterX - arcRadiusX;
    final arcRight = arcCenterX + arcRadiusX;

    // Horizon line
    canvas.drawLine(
      Offset(arcLeft, horizY),
      Offset(arcRight, horizY),
      Paint()
        ..color = AppColors.cream15
        ..strokeWidth = 1,
    );

    final totalDuration = sunset.difference(sunrise).inSeconds.toDouble();
    final fraction = totalDuration > 0
        ? now.difference(sunrise).inSeconds / totalDuration
        : 0.0;
    final isDay = fraction >= 0 && fraction <= 1;

    // Upper dashed arc — full opacity during day, faded at night
    final upperArcPath = Path()
      ..addArc(circleRect, arcStartAngle, arcSweepAngle);
    _drawDashedPath(
      canvas,
      upperArcPath,
      Paint()
        ..color = isDay ? AppColors.cream30 : AppColors.cream15
        ..strokeWidth = 1.5
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );

    if (totalDuration <= 0) return;

    // Golden hour highlight (day only)
    if (isDay) {
      final goldenFraction =
          goldenHour.difference(sunrise).inSeconds / totalDuration;
      final goldenAngle =
          arcStartAngle + arcSweepAngle * goldenFraction.clamp(0.0, 1.0);
      final sunsetAngle = arcStartAngle + arcSweepAngle;
      final goldenPath = Path()
        ..addArc(circleRect, goldenAngle, sunsetAngle - goldenAngle);
      canvas.drawPath(
        goldenPath,
        Paint()
          ..color = AppColors.cream15
          ..strokeWidth = 3
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round,
      );
    }

    // Solar noon tick at top of arc
    final noonX = arcCenterX;
    final noonY = circleCenterY - circleR;
    canvas.drawLine(
      Offset(noonX, noonY - 3),
      Offset(noonX, noonY + 3),
      Paint()
        ..color = AppColors.cream40
        ..strokeWidth = 1.5
        ..strokeCap = StrokeCap.round,
    );

    if (isDay) {
      // Sun position on the upward arc
      final clampedFraction = fraction.clamp(0.0, 1.0);
      final angle = arcStartAngle + arcSweepAngle * clampedFraction;
      final sunX = arcCenterX + circleR * math.cos(angle);
      final sunY = circleCenterY + circleR * math.sin(angle);
      // Glow
      canvas.drawCircle(
        Offset(sunX, sunY),
        12,
        Paint()
          ..color = AppColors.cream12
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
      );
      // Sun dot
      canvas.drawCircle(
        Offset(sunX, sunY),
        6,
        Paint()..color = AppColors.cream90,
      );
    }
  }

  void _drawDashedPath(Canvas canvas, Path path, Paint paint) {
    const dashLength = 4.0;
    const dashGap = 3.0;
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final end = math.min(distance + dashLength, metric.length);
        final segment = metric.extractPath(distance, end);
        canvas.drawPath(segment, paint);
        distance += dashLength + dashGap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _SunArcPainter old) =>
      sunrise.millisecondsSinceEpoch != old.sunrise.millisecondsSinceEpoch ||
      sunset.millisecondsSinceEpoch != old.sunset.millisecondsSinceEpoch ||
      now.millisecondsSinceEpoch != old.now.millisecondsSinceEpoch;
}
