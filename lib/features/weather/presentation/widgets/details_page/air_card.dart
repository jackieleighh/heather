import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:heather/core/constants/app_colors.dart';
import 'package:heather/core/utils/wind_direction.dart';
import 'package:weather_icons/weather_icons.dart';
import './card_container.dart';
import './card_display_mode.dart';
import './info_chip.dart';

class AirCard extends StatelessWidget {
  final int? aqi;
  final bool isLoading;
  final double windSpeed;
  final double pressure;
  final double windGusts;
  final int windDirection;
  final List<double> hourlyPressure;
  final CardDisplayMode mode;
  final List<double> hourlyWindSpeed;
  final List<double> hourlyWindGusts;
  final List<int> hourlyWindDirection;
  final List<DateTime> hours;

  const AirCard({
    super.key,
    required this.aqi,
    required this.isLoading,
    required this.windSpeed,
    this.pressure = 0.0,
    this.windGusts = 0.0,
    this.windDirection = 0,
    this.hourlyPressure = const [],
    this.mode = CardDisplayMode.normal,
    this.hourlyWindSpeed = const [],
    this.hourlyWindGusts = const [],
    this.hourlyWindDirection = const [],
    this.hours = const [],
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

    if (mode == CardDisplayMode.collapsed) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: Row(
          children: [
            Icon(
              WeatherIcons.smoke,
              size: 14,
              color: AppColors.cream.withValues(alpha: 0.9),
            ),
            const SizedBox(width: 4),
            Text(
              'Air',
              style: GoogleFonts.figtree(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: AppColors.cream,
              ),
            ),
            const Spacer(),
            Text(
              '${windDirectionLabel(windDirection)} ${windSpeed.round()} mph',
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: AppColors.cream,
              ),
            ),
          ],
        ),
      );
    }

    if (mode == CardDisplayMode.expanded) {
      final hasChartData = hourlyWindSpeed.length >= 2 && hours.isNotEmpty;
      return CardContainer(
        backgroundIcon: WeatherIcons.smoke,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildExpandedHeaderRow(),
            const SizedBox(height: 8),
            SizedBox(
              height: 180,
              child: CustomPaint(
                size: Size.infinite,
                painter: _WindCompassPainter(
                  windDirection: windDirection,
                  windSpeed: windSpeed,
                  windGusts: windGusts,
                ),
              ),
            ),
            const SizedBox(height: 10),
            _buildAqiStripRow(theme),
            const SizedBox(height: 10),
            _build2x2InfoGrid(pressureDelta),
            const Spacer(),
            if (hasChartData) ...[
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    Container(
                      width: 16,
                      height: 2,
                      color: AppColors.cream.withValues(alpha: 0.5),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      'Wind',
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: AppColors.cream.withValues(alpha: 0.8),
                      ),
                    ),
                    if (hourlyWindGusts.isNotEmpty) ...[
                      const SizedBox(width: 14),
                      _buildDashedLegendLine(),
                      const SizedBox(width: 5),
                      Text(
                        'Gusts',
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: AppColors.cream.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              SizedBox(
                height: 90,
                child: CustomPaint(
                  size: Size.infinite,
                  painter: _WindLinePainter(
                    windSpeeds: hourlyWindSpeed,
                    windGusts: hourlyWindGusts,
                    hours: hours,
                    now: DateTime.now(),
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
      backgroundIcon: WeatherIcons.smoke,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildHeaderRow(pressureDelta),
          if (pressure > 0) _buildPressureRow(pressureDelta),
          const Spacer(),
          _buildAqiRow(theme),
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

  Widget _buildHeaderRow(double? pressureDelta) {
    return Row(
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
    );
  }

  Widget _buildPressureRow(double? pressureDelta) {
    return Row(
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
    );
  }

  Widget _buildAqiRow(ThemeData theme) {
    return Row(
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

  Widget _buildExpandedHeaderRow() {
    return Row(
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
          windDirectionLabel(windDirection),
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
      ],
    );
  }

  Widget _buildAqiStripRow(ThemeData theme) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          isLoading ? '...' : (aqi?.toString() ?? '--'),
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w800,
            fontSize: 22,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          aqi == null ? '' : _aqiLabel(aqi!),
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.cream.withValues(alpha: 0.85),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: SizedBox(
            height: 12,
            child: CustomPaint(
              size: Size.infinite,
              painter: _AqiScalePainter(aqi: aqi),
            ),
          ),
        ),
      ],
    );
  }

  Widget _build2x2InfoGrid(double? pressureDelta) {
    final pressureValue = _formatPressureValue(pressureDelta);
    final peakGust = _findPeakGust(hourlyWindGusts, hours);
    final calmest = _findCalmest(hourlyWindSpeed, hours);
    final dominantDir = _dominantDirection(hourlyWindDirection);

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: InfoChip(
                icon: WeatherIcons.barometer,
                label: 'Pressure',
                value: pressureValue,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: InfoChip(
                icon: WeatherIcons.windy,
                label: 'Peak Gust',
                value: peakGust != null
                    ? '${peakGust.$1} mph @ ${_formatHourShort(peakGust.$2)}'
                    : '--',
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: InfoChip(
                icon: WeatherIcons.windy,
                label: 'Calmest',
                value: calmest != null
                    ? '${calmest.$1} mph @ ${_formatHourShort(calmest.$2)}'
                    : '--',
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: InfoChip(
                icon: WeatherIcons.windy,
                label: 'Dominant Dir',
                value: dominantDir,
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _formatPressureValue(double? pressureDelta) {
    if (pressure <= 0) return '--';
    final base = '${pressure.round()} mb';
    if (pressureDelta == null || pressureDelta.abs() < 0.5) return base;
    final arrow = pressureDelta > 0 ? '\u2191' : '\u2193';
    final sign = pressureDelta > 0 ? '+' : '';
    return '$base $arrow $sign${pressureDelta.toStringAsFixed(1)}';
  }

  static (int, DateTime)? _findPeakGust(
    List<double> gusts,
    List<DateTime> hours,
  ) {
    if (gusts.isEmpty || hours.isEmpty || gusts.length != hours.length) {
      return null;
    }
    var maxIdx = 0;
    for (var i = 1; i < gusts.length; i++) {
      if (gusts[i] > gusts[maxIdx]) maxIdx = i;
    }
    return (gusts[maxIdx].round(), hours[maxIdx]);
  }

  static (int, DateTime)? _findCalmest(
    List<double> speeds,
    List<DateTime> hours,
  ) {
    if (speeds.isEmpty || hours.isEmpty || speeds.length != hours.length) {
      return null;
    }
    var minIdx = 0;
    for (var i = 1; i < speeds.length; i++) {
      if (speeds[i] < speeds[minIdx]) minIdx = i;
    }
    return (speeds[minIdx].round(), hours[minIdx]);
  }

  /// Buckets into 8 compass points (more meaningful than 16 over 24h).
  static String _dominantDirection(List<int> directions) {
    if (directions.isEmpty) return '--';
    const labels = ['N', 'NE', 'E', 'SE', 'S', 'SW', 'W', 'NW'];
    final counts = List<int>.filled(8, 0);
    for (final deg in directions) {
      final idx = ((deg % 360) / 45 + 0.5).floor() % 8;
      counts[idx]++;
    }
    var maxIdx = 0;
    for (var i = 1; i < 8; i++) {
      if (counts[i] > counts[maxIdx]) maxIdx = i;
    }
    return labels[maxIdx];
  }

  Widget _buildDashedLegendLine() {
    return SizedBox(
      width: 16,
      height: 2,
      child: CustomPaint(
        painter: _DashedLinePainter(
          color: AppColors.cream.withValues(alpha: 0.3),
        ),
      ),
    );
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

    final barPaint = Paint()
      ..shader = const LinearGradient(
        colors: [
          Color(0x8068BB59),
          Color(0x80B8CC40),
          Color(0x80D4A030),
          Color(0x80CC6644),
          Color(0x80994466),
          Color(0x80775588),
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

String _formatHourShort(DateTime dt) {
  final h = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
  final suffix = dt.hour >= 12 ? 'p' : 'a';
  return '$h$suffix';
}

class _WindLinePainter extends CustomPainter {
  final List<double> windSpeeds;
  final List<double> windGusts;
  final List<DateTime> hours;
  final DateTime? now;

  _WindLinePainter({
    required this.windSpeeds,
    required this.hours,
    this.windGusts = const [],
    this.now,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (windSpeeds.length < 2) return;

    final allValues = [...windSpeeds, ...windGusts];
    final hi = allValues.reduce(math.max);
    final maxY = (math.max(hi, 5.0) / 5).ceil() * 5.0;

    const padTop = 4.0;
    const padBottom = 14.0;
    const padLeft = 28.0;
    const padRight = 8.0;
    final graphH = size.height - padTop - padBottom;
    final graphW = size.width - padLeft - padRight;
    final stepX = graphW / (windSpeeds.length - 1);
    final bottom = padTop + graphH;

    final labelStyle = TextStyle(
      color: AppColors.cream.withValues(alpha: 0.4),
      fontSize: 9,
    );

    // Y-axis labels and grid lines
    final midY = (maxY / 2).roundToDouble();
    final yValues = [0.0, midY, maxY];
    for (final val in yValues) {
      final y = padTop + graphH * (1 - val / maxY);

      canvas.drawLine(
        Offset(padLeft, y),
        Offset(size.width - padRight, y),
        Paint()..color = AppColors.cream.withValues(alpha: 0.06),
      );

      final tp = TextPainter(
        text: TextSpan(text: '${val.round()}', style: labelStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(padLeft - tp.width - 4, y - tp.height / 2));
    }

    // X-axis time labels
    if (hours.isNotEmpty) {
      final labelCount = math.min(6, hours.length);
      final interval = (hours.length - 1) / (labelCount - 1);
      for (var i = 0; i < labelCount; i++) {
        final idx = (i * interval).round().clamp(0, hours.length - 1);
        final hour = hours[idx];
        final label = _formatHourShort(hour);
        final x = padLeft + idx * stepX;

        final tp = TextPainter(
          text: TextSpan(text: label, style: labelStyle),
          textDirection: TextDirection.ltr,
        )..layout();
        tp.paint(canvas, Offset(x - tp.width / 2, bottom + 2));
      }
    }

    // Wind speed points
    final points = <Offset>[];
    for (var i = 0; i < windSpeeds.length; i++) {
      final x = padLeft + i * stepX;
      final y = padTop + graphH * (1 - (windSpeeds[i] / maxY).clamp(0.0, 1.0));
      points.add(Offset(x, y));
    }

    // Wind speed curve path
    final linePath = Path()..moveTo(points.first.dx, points.first.dy);
    for (var i = 1; i < points.length; i++) {
      final prev = points[i - 1];
      final curr = points[i];
      final cpx = (prev.dx + curr.dx) / 2;
      linePath.cubicTo(cpx, prev.dy, cpx, curr.dy, curr.dx, curr.dy);
    }

    // Area fill under wind line
    final fillPath = Path.from(linePath)
      ..lineTo(points.last.dx, bottom)
      ..lineTo(points.first.dx, bottom)
      ..close();

    canvas.drawPath(
      fillPath,
      Paint()..color = AppColors.cream.withValues(alpha: 0.12),
    );

    // Wind speed stroke
    canvas.drawPath(
      linePath,
      Paint()
        ..color = AppColors.cream.withValues(alpha: 0.5)
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );

    // Gusts dashed line
    if (windGusts.length == windSpeeds.length) {
      final gustPoints = <Offset>[];
      for (var i = 0; i < windGusts.length; i++) {
        final x = padLeft + i * stepX;
        final y = padTop + graphH * (1 - (windGusts[i] / maxY).clamp(0.0, 1.0));
        gustPoints.add(Offset(x, y));
      }

      final gustPath = Path()..moveTo(gustPoints.first.dx, gustPoints.first.dy);
      for (var i = 1; i < gustPoints.length; i++) {
        final prev = gustPoints[i - 1];
        final curr = gustPoints[i];
        final cpx = (prev.dx + curr.dx) / 2;
        gustPath.cubicTo(cpx, prev.dy, cpx, curr.dy, curr.dx, curr.dy);
      }

      final dashPaint = Paint()
        ..color = AppColors.cream.withValues(alpha: 0.3)
        ..strokeWidth = 1.5
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      for (final metric in gustPath.computeMetrics()) {
        var distance = 0.0;
        while (distance < metric.length) {
          final end = math.min(distance + 6, metric.length);
          canvas.drawPath(metric.extractPath(distance, end), dashPaint);
          distance += 10;
        }
      }
    }

    // "Now" indicator
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
          final frac = nowMs / totalMs;
          final idx = frac * (windSpeeds.length - 1);
          final i0 = idx.floor().clamp(0, windSpeeds.length - 2);
          final t = idx - i0;
          final interpSpeed =
              windSpeeds[i0] + (windSpeeds[i0 + 1] - windSpeeds[i0]) * t;
          final nowX = padLeft + graphW * frac;
          final nowY =
              padTop + graphH * (1 - (interpSpeed / maxY).clamp(0.0, 1.0));

          // Vertical reference line
          canvas.drawLine(
            Offset(nowX, padTop),
            Offset(nowX, bottom),
            Paint()
              ..color = AppColors.cream.withValues(alpha: 0.4)
              ..strokeWidth = 0.5,
          );

          // Dot on the wind line
          canvas.drawCircle(
            Offset(nowX, nowY),
            4,
            Paint()..color = AppColors.cream.withValues(alpha: 0.9),
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant _WindLinePainter old) =>
      windSpeeds != old.windSpeeds ||
      windGusts != old.windGusts ||
      now != old.now;
}

class _WindCompassPainter extends CustomPainter {
  final int windDirection;
  final double windSpeed;
  final double windGusts;

  _WindCompassPainter({
    required this.windDirection,
    required this.windSpeed,
    required this.windGusts,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final radius = math.min(size.width, size.height) / 2 - 6;

    // Outer ring
    canvas.drawCircle(
      Offset(cx, cy),
      radius,
      Paint()
        ..color = AppColors.cream.withValues(alpha: 0.18)
        ..strokeWidth = 1
        ..style = PaintingStyle.stroke,
    );

    // Cardinal labels (N/E/S/W) and tick marks
    final cardinalLabels = <(String, double)>[
      ('N', -math.pi / 2),
      ('E', 0),
      ('S', math.pi / 2),
      ('W', math.pi),
    ];
    final tickPaint = Paint()
      ..color = AppColors.cream.withValues(alpha: 0.25)
      ..strokeWidth = 1;
    final labelStyle = TextStyle(
      color: AppColors.cream.withValues(alpha: 0.45),
      fontSize: 9,
      fontWeight: FontWeight.w600,
    );
    for (final (label, angle) in cardinalLabels) {
      final tickStart = Offset(
        cx + math.cos(angle) * (radius - 3),
        cy + math.sin(angle) * (radius - 3),
      );
      final tickEnd = Offset(
        cx + math.cos(angle) * radius,
        cy + math.sin(angle) * radius,
      );
      canvas.drawLine(tickStart, tickEnd, tickPaint);

      final labelPos = Offset(
        cx + math.cos(angle) * (radius - 12),
        cy + math.sin(angle) * (radius - 12),
      );
      final tp = TextPainter(
        text: TextSpan(text: label, style: labelStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(
        canvas,
        Offset(labelPos.dx - tp.width / 2, labelPos.dy - tp.height / 2),
      );
    }

    // Wind arrow (or calm dot)
    if (windSpeed >= 1) {
      // Arrow points in the direction the wind is coming FROM, matching the
      // cardinal label (e.g. SW label → arrow points to SW). 0° (from N) →
      // arrow points N (up).
      final arrowAngle = (windDirection - 90) * math.pi / 180;
      final tip = Offset(
        cx + math.cos(arrowAngle) * (radius - 14),
        cy + math.sin(arrowAngle) * (radius - 14),
      );
      final arrowPaint = Paint()
        ..color = AppColors.cream.withValues(alpha: 0.9)
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      // Shaft
      canvas.drawLine(Offset(cx, cy), tip, arrowPaint);

      // Arrowhead V (two short lines back from tip)
      const headLen = 7.0;
      final leftAngle = arrowAngle + math.pi - (math.pi / 6); // -150°
      final rightAngle = arrowAngle + math.pi + (math.pi / 6); // +150°
      canvas.drawLine(
        tip,
        Offset(
          tip.dx + math.cos(leftAngle) * headLen,
          tip.dy + math.sin(leftAngle) * headLen,
        ),
        arrowPaint,
      );
      canvas.drawLine(
        tip,
        Offset(
          tip.dx + math.cos(rightAngle) * headLen,
          tip.dy + math.sin(rightAngle) * headLen,
        ),
        arrowPaint,
      );
    } else {
      canvas.drawCircle(
        Offset(cx, cy),
        3,
        Paint()..color = AppColors.cream.withValues(alpha: 0.4),
      );
    }

    // Center text: big speed + mph + gusts subtitle
    final speedTp = TextPainter(
      text: TextSpan(
        text: '${windSpeed.round()}',
        style: GoogleFonts.poppins(
          fontSize: 52,
          fontWeight: FontWeight.w700,
          color: AppColors.cream,
          height: 1,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    final mphTp = TextPainter(
      text: TextSpan(
        text: ' mph',
        style: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: AppColors.cream.withValues(alpha: 0.7),
          height: 1,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    final centerY = cy - 14;
    final totalW = speedTp.width + mphTp.width;
    final speedX = cx - totalW / 2;
    speedTp.paint(canvas, Offset(speedX, centerY - speedTp.height / 2));
    mphTp.paint(
      canvas,
      Offset(
        speedX + speedTp.width,
        centerY - speedTp.height / 2 + (speedTp.height - mphTp.height),
      ),
    );

    if (windGusts > windSpeed + 0.5) {
      final gustTp = TextPainter(
        text: TextSpan(
          text: 'gusts to ${windGusts.round()}',
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.cream.withValues(alpha: 0.6),
            height: 1,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      gustTp.paint(
        canvas,
        Offset(cx - gustTp.width / 2, cy + 28 - gustTp.height / 2),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _WindCompassPainter old) =>
      windDirection != old.windDirection ||
      windSpeed != old.windSpeed ||
      windGusts != old.windGusts;
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
