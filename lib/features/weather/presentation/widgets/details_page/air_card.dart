import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:heather/core/constants/app_colors.dart';
import 'package:heather/core/utils/wind_direction.dart';
import 'package:heather/features/weather/domain/entities/air_quality.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:weather_icons/weather_icons.dart';
import './card_container.dart';
import './card_display_mode.dart';

class AirCard extends StatelessWidget {
  final AirQuality? airQuality;
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
    required this.airQuality,
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

  int? get aqi => airQuality?.aqi;

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
            if (aqi != null) ...[
              Text(
                'AQI ',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: AppColors.cream,
                ),
              ),
              Text(
                '${aqi!}',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.cream,
                ),
              ),
              const SizedBox(width: 8),
            ],
            Text(
              '${windDirectionLabel(windDirection)} ',
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: AppColors.cream,
              ),
            ),
            Text(
              '${windSpeed.round()} mph',
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
      final hasChartData = hourlyWindSpeed.length >= 2 && hours.isNotEmpty;
      final sections = <Widget>[
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildExpandedHeaderRow(),
            if (pressure > 0) _buildPressureRow(pressureDelta),
          ],
        ),
        _buildAqiStripRow(theme),
        if (airQuality != null) _buildPollutantGrid(),
        if (hasChartData)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                height: 56,
                child: CustomPaint(
                  size: Size.infinite,
                  painter: _WindLinePainter(
                    windSpeeds: hourlyWindSpeed,
                    windGusts: hourlyWindGusts,
                    hours: hours,
                    now: DateTime.now(),
                    showHourLabels: false,
                  ),
                ),
              ),
            ],
          ),
        if (hasPressureData && hours.isNotEmpty)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    Icon(
                      WeatherIcons.barometer,
                      size: 12,
                      color: AppColors.cream.withValues(alpha: 0.8),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Pressure (mb)',
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
                height: 68,
                child: CustomPaint(
                  size: Size.infinite,
                  painter: _PressureLinePainter(
                    pressures: hourlyPressure,
                    hours: hours,
                    now: DateTime.now(),
                  ),
                ),
              ),
            ],
          ),
      ];

      return CardContainer(
        backgroundIcon: WeatherIcons.smoke,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var i = 0; i < sections.length; i++) ...[
              sections[i],
              if (i < sections.length - 1) const Spacer(),
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
            height: 10,
            child: CustomPaint(
              size: Size.infinite,
              painter: _AqiScalePainter(aqi: aqi),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderRow(double? pressureDelta) {
    final maxGust = hourlyWindGusts.isNotEmpty
        ? hourlyWindGusts.reduce(math.max)
        : windGusts;
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
        if (maxGust > windSpeed) ...[
          const SizedBox(width: 4),
          Text(
            'up to ${maxGust.round()} mph',
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

  Widget _buildExpandedHeaderRow() {
    final maxGust = hourlyWindGusts.isNotEmpty
        ? hourlyWindGusts.reduce(math.max)
        : windGusts;
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
        if (maxGust > windSpeed) ...[
          const SizedBox(width: 4),
          Text(
            'up to ${maxGust.round()} mph',
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

  static String _aqiLabel(int aqi) {
    if (aqi <= 50) return 'Good';
    if (aqi <= 100) return 'Moderate';
    if (aqi <= 150) return 'Unhealthy (Sensitive)';
    if (aqi <= 200) return 'Unhealthy';
    if (aqi <= 300) return 'Very Unhealthy';
    return 'Hazardous';
  }

  Widget _buildAqiStripRow(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
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
          ],
        ),
        SizedBox(
          height: 12,
          child: CustomPaint(
            size: Size.infinite,
            painter: _AqiScalePainter(aqi: aqi),
          ),
        ),
      ],
    );
  }

  Widget _buildPollutantGrid() {
    final entries = <MapEntry<String, double>>[];
    if (airQuality!.pm25 != null) entries.add(MapEntry('PM2.5', airQuality!.pm25!));
    if (airQuality!.pm10 != null) entries.add(MapEntry('PM10', airQuality!.pm10!));
    if (airQuality!.ozone != null) entries.add(MapEntry('O\u2083', airQuality!.ozone!));
    if (airQuality!.no2 != null) entries.add(MapEntry('NO\u2082', airQuality!.no2!));
    if (airQuality!.so2 != null) entries.add(MapEntry('SO\u2082', airQuality!.so2!));
    if (airQuality!.co != null) entries.add(MapEntry('CO', airQuality!.co!));

    if (entries.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Pollutants',
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: AppColors.cream.withValues(alpha: 0.85),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                '\u00B5g/m\u00B3',
                style: GoogleFonts.poppins(
                  fontSize: 9,
                  fontWeight: FontWeight.w400,
                  color: AppColors.cream.withValues(alpha: 0.5),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var i = 0; i < entries.length; i++) ...[
                  if (i > 0) const SizedBox(width: 6),
                  Expanded(child: _PollutantTile(label: entries[i].key, value: entries[i].value)),
                ],
              ],
            ),
          ),
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

class _WindLinePainter extends CustomPainter {
  final List<double> windSpeeds;
  final List<double> windGusts;
  final List<DateTime> hours;
  final DateTime? now;
  final bool showHourLabels;

  _WindLinePainter({
    required this.windSpeeds,
    required this.hours,
    this.windGusts = const [],
    this.now,
    this.showHourLabels = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (windSpeeds.length < 2) return;

    final allValues = [...windSpeeds, ...windGusts];
    final hi = allValues.reduce(math.max);
    final maxY = (math.max(hi, 5.0) / 5).ceil() * 5.0;

    const padTop = 2.0;
    final padBottom = showHourLabels ? 14.0 : 2.0;
    const padLeft = 20.0;
    final graphH = size.height - padTop - padBottom;
    final graphW = size.width - padLeft;
    final stepX = graphW / (windSpeeds.length - 1);
    final bottom = padTop + graphH;

    // Y-axis labels
    final yLabelStyle = TextStyle(
      color: AppColors.cream.withValues(alpha: 0.95),
      fontSize: 10,
      fontWeight: FontWeight.w600,
    );
    final midY = (maxY / 2).roundToDouble();
    for (final val in [maxY, midY, 0.0]) {
      final y = padTop + graphH * (1 - val / maxY);
      final tp = TextPainter(
        text: TextSpan(text: '${val.round()}', style: yLabelStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(0, y - tp.height / 2));
    }

    // X-axis hour labels (every 6 hours + last)
    if (showHourLabels) {
      final hourLabelStyle = TextStyle(
        color: AppColors.cream.withValues(alpha: 0.9),
        fontSize: 10,
        fontWeight: FontWeight.w600,
      );
      for (var i = 0; i < hours.length; i++) {
        if (i % 6 != 0 && i != hours.length - 1) continue;
        final tp = TextPainter(
          text: TextSpan(
            text: DateFormat('ha').format(hours[i]).toLowerCase(),
            style: hourLabelStyle,
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

    // Area fill under wind line (gradient)
    final fillPath = Path.from(linePath)
      ..lineTo(points.last.dx, bottom)
      ..lineTo(points.first.dx, bottom)
      ..close();
    final fillRect = Rect.fromLTRB(
      points.first.dx,
      padTop,
      points.last.dx,
      bottom,
    );
    canvas.drawPath(
      fillPath,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.cream.withValues(alpha: 0.15),
            AppColors.cream.withValues(alpha: 0.03),
          ],
        ).createShader(fillRect)
        ..style = PaintingStyle.fill,
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

          // "Now" outline dot on the gusts line
          if (windGusts.length == windSpeeds.length) {
            final interpGust =
                windGusts[i0] + (windGusts[i0 + 1] - windGusts[i0]) * t;
            final gustNowY =
                padTop + graphH * (1 - (interpGust / maxY).clamp(0.0, 1.0));
            canvas.drawCircle(
              Offset(nowX, gustNowY),
              3.5,
              Paint()
                ..color = AppColors.cream.withValues(alpha: 0.6)
                ..style = PaintingStyle.stroke
                ..strokeWidth = 1.5,
            );
          }

          // "Now" dot on the wind line
          canvas.drawCircle(
            Offset(nowX, nowY),
            4,
            Paint()..color = AppColors.cream,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant _WindLinePainter old) =>
      windSpeeds != old.windSpeeds ||
      windGusts != old.windGusts ||
      now != old.now ||
      showHourLabels != old.showHourLabels;
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

class _PressureLinePainter extends CustomPainter {
  final List<double> pressures;
  final List<DateTime> hours;
  final DateTime? now;

  _PressureLinePainter({
    required this.pressures,
    required this.hours,
    this.now,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (pressures.length < 2) return;

    final dataLo = pressures.reduce(math.min);
    final dataHi = pressures.reduce(math.max);

    const step = 2.0; // y-axis snaps to 2 mb increments
    const minHeadroom = 1.0; // minimum gap between data and chart edge

    var lo = (dataLo / step).floor() * step;
    var hi = (dataHi / step).ceil() * step;
    if (dataLo - lo < minHeadroom) lo -= step;
    if (hi - dataHi < minHeadroom) hi += step;
    if (hi - lo == 0) hi = lo + step;

    final range = hi - lo;

    const padTop = 2.0;
    const padBottom = 14.0;
    const padLeft = 28.0;
    final graphH = size.height - padTop - padBottom;
    final graphW = size.width - padLeft;
    final stepX = graphW / (pressures.length - 1);
    final bottom = padTop + graphH;

    // Y-axis labels (hi, mid, lo)
    final yLabelStyle = TextStyle(
      color: AppColors.cream.withValues(alpha: 0.95),
      fontSize: 10,
      fontWeight: FontWeight.w600,
    );
    final mid = (lo + hi) / 2;
    for (final val in [hi, mid, lo]) {
      final y = padTop + graphH * (1 - (val - lo) / range);
      final tp = TextPainter(
        text: TextSpan(text: '${val.round()}', style: yLabelStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(0, y - tp.height / 2));
    }

    // X-axis hour labels (every 6 hours + last)
    final hourLabelStyle = TextStyle(
      color: AppColors.cream.withValues(alpha: 0.9),
      fontSize: 10,
      fontWeight: FontWeight.w600,
    );
    for (var i = 0; i < hours.length; i++) {
      if (i % 6 != 0 && i != hours.length - 1) continue;
      final tp = TextPainter(
        text: TextSpan(
          text: DateFormat('ha').format(hours[i]).toLowerCase(),
          style: hourLabelStyle,
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      final x = (padLeft + i * stepX - tp.width / 2).clamp(
        padLeft,
        size.width - tp.width,
      );
      tp.paint(canvas, Offset(x, size.height - padBottom + 2));
    }

    // Pressure points
    final points = <Offset>[];
    for (var i = 0; i < pressures.length; i++) {
      final x = padLeft + i * stepX;
      final y = padTop + graphH * (1 - (pressures[i] - lo) / range);
      points.add(Offset(x, y));
    }

    // Pressure curve path (cubic smoothing)
    final linePath = Path()..moveTo(points.first.dx, points.first.dy);
    for (var i = 1; i < points.length; i++) {
      final prev = points[i - 1];
      final curr = points[i];
      final cpx = (prev.dx + curr.dx) / 2;
      linePath.cubicTo(cpx, prev.dy, cpx, curr.dy, curr.dx, curr.dy);
    }

    // Area fill under pressure line (gradient)
    final fillPath = Path.from(linePath)
      ..lineTo(points.last.dx, bottom)
      ..lineTo(points.first.dx, bottom)
      ..close();
    final fillRect = Rect.fromLTRB(
      points.first.dx,
      padTop,
      points.last.dx,
      bottom,
    );
    canvas.drawPath(
      fillPath,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.cream.withValues(alpha: 0.15),
            AppColors.cream.withValues(alpha: 0.03),
          ],
        ).createShader(fillRect)
        ..style = PaintingStyle.fill,
    );

    // Pressure stroke
    canvas.drawPath(
      linePath,
      Paint()
        ..color = AppColors.cream.withValues(alpha: 0.5)
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );

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
          final idx = frac * (pressures.length - 1);
          final i0 = idx.floor().clamp(0, pressures.length - 2);
          final t = idx - i0;
          final interpPressure =
              pressures[i0] + (pressures[i0 + 1] - pressures[i0]) * t;
          final nowX = padLeft + graphW * frac;
          final nowY =
              padTop + graphH * (1 - (interpPressure - lo) / range);

          canvas.drawCircle(
            Offset(nowX, nowY),
            4,
            Paint()..color = AppColors.cream,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant _PressureLinePainter old) =>
      pressures != old.pressures || hours != old.hours || now != old.now;
}

class _PollutantTile extends StatelessWidget {
  final String label;
  final double value;

  const _PollutantTile({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final valueStr =
        value >= 100 ? value.round().toString() : value.toStringAsFixed(1);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.cream.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            height: 16,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.center,
              child: Text(
                label,
                maxLines: 1,
                softWrap: false,
                overflow: TextOverflow.visible,
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: FontWeight.w400,
                  color: AppColors.cream,
                ),
                strutStyle: const StrutStyle(
                  fontSize: 11,
                  height: 1.4,
                  forceStrutHeight: true,
                ),
              ),
            ),
          ),
          const SizedBox(height: 2),
          SizedBox(
            height: 18,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.center,
              child: Text(
                valueStr,
                maxLines: 1,
                softWrap: false,
                overflow: TextOverflow.visible,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.cream,
                ),
                strutStyle: const StrutStyle(
                  fontSize: 14,
                  height: 1.3,
                  forceStrutHeight: true,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
