import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:heather/core/constants/app_colors.dart';
import 'package:heather/features/weather/domain/entities/weather_condition.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:weather_icons/weather_icons.dart';
import './card_container.dart';
import './card_display_mode.dart';
import './info_chip.dart';

enum PrecipType { rain, snow, mixed }

PrecipType precipTypeFromConditions(List<WeatherCondition> conditions) {
  var hasRain = false;
  var hasSnow = false;
  for (final c in conditions) {
    switch (c) {
      case WeatherCondition.snow:
      case WeatherCondition.blizzard:
        hasSnow = true;
      case WeatherCondition.drizzle:
      case WeatherCondition.rain:
      case WeatherCondition.heavyRain:
      case WeatherCondition.freezingRain:
      case WeatherCondition.thunderstorm:
      case WeatherCondition.hail:
        hasRain = true;
      default:
        break;
    }
    if (hasRain && hasSnow) return PrecipType.mixed;
  }
  if (hasSnow) return PrecipType.snow;
  return PrecipType.rain;
}

class RainCard extends StatelessWidget {
  final double precipitationIn;
  final int precipitationProbability;
  final List<int> hourlyPrecipProb;
  final List<DateTime> hours;
  final DateTime? now;
  final bool compact;
  final PrecipType precipType;
  final int humidity;
  final int cloudCover;
  final CardDisplayMode mode;
  final double dewPoint;
  final List<int> hourlyHumidity;
  final List<double> hourlyDewPoint;
  final bool flat;

  const RainCard({
    super.key,
    required this.precipitationIn,
    required this.precipitationProbability,
    required this.hourlyPrecipProb,
    required this.hours,
    this.now,
    this.compact = false,
    this.precipType = PrecipType.rain,
    this.humidity = 0,
    this.cloudCover = 0,
    this.mode = CardDisplayMode.normal,
    this.dewPoint = 0.0,
    this.hourlyHumidity = const [],
    this.hourlyDewPoint = const [],
    this.flat = false,
  });

  @override
  Widget build(BuildContext context) {
    final precipLabel = precipitationIn < 0.01
        ? '0"'
        : '${precipitationIn.toStringAsFixed(2)}"';

    final (label, icon, bgIcon) = switch (precipType) {
      PrecipType.snow => (
        'Snow',
        WeatherIcons.snowflake_cold,
        WeatherIcons.snow,
      ),
      PrecipType.mixed => (
        'Slush',
        WeatherIcons.rain_mix,
        WeatherIcons.rain_mix,
      ),
      PrecipType.rain => ('Rain', WeatherIcons.raindrop, WeatherIcons.rain),
    };

    if (mode == CardDisplayMode.collapsed) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: Row(
          children: [
            Icon(icon, size: 14, color: AppColors.cream90),
            const SizedBox(width: 4),
            Text(
              label,
              style: GoogleFonts.figtree(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: AppColors.cream,
              ),
            ),
            const Spacer(),
            Text(
              precipLabel,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.cream,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              '$precipitationProbability%',
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: AppColors.cream90,
              ),
            ),
          ],
        ),
      );
    }

    if (mode == CardDisplayMode.expanded) {
      return CardContainer(
        backgroundIcon: bgIcon,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row — same as normal mode
            _buildHeaderRow(label, icon, precipLabel),
            if (humidity > 0)
              Row(
                children: [
                  const Spacer(),
                  Text(
                    '$humidity% humidity',
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.cream80,
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 12),
            _buildUmbrellaGauge(),
            const Spacer(),
            _build2x2InfoGrid(precipLabel, icon),
            const Spacer(),
            _ChartLabel(text: 'Chance of ${label.toLowerCase()}'),
            SizedBox(
              width: double.infinity,
              height: 70,
              child: CustomPaint(
                size: Size.infinite,
                painter: _PrecipBarPainter(
                  precipProb: hourlyPrecipProb,
                  hours: hours,
                  now: now,
                  showHourLabels: false,
                ),
              ),
            ),
            const Spacer(),
            if (hourlyHumidity.isNotEmpty) ...[
              const _ChartLabel(text: 'Humidity'),
              SizedBox(
                width: double.infinity,
                height: 70,
                child: CustomPaint(
                  size: Size.infinite,
                  painter: _HumidityLinePainter(
                    humidities: hourlyHumidity,
                    hours: hours,
                    now: now,
                    showHourLabels: true,
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
      backgroundIcon: bgIcon,
      flat: flat,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeaderRow(label, icon, precipLabel),
          if (humidity > 0 && !compact)
            Row(
              children: [
                const Spacer(),
                Text(
                  '$humidity% humidity',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.cream80,
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

  Widget _buildUmbrellaGauge() {
    final pct = precipitationProbability.clamp(0, 100);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _ChartLabel(text: 'Umbrella Meter'),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: SizedBox(
                height: 10,
                child: CustomPaint(
                  size: Size.infinite,
                  painter: _BarGaugePainter(probability: pct),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Icon(
              WeatherIcons.umbrella,
              size: 24,
              color: AppColors.cream70,
            ),
          ],
        ),
      ],
    );
  }

  Widget _build2x2InfoGrid(String precipLabel, IconData precipIcon) {
    // Peak chance: find max in hourlyPrecipProb and its time
    String peakChanceValue;
    if (hourlyPrecipProb.isNotEmpty && hours.isNotEmpty) {
      var maxIdx = 0;
      for (var i = 1; i < hourlyPrecipProb.length; i++) {
        if (hourlyPrecipProb[i] > hourlyPrecipProb[maxIdx]) maxIdx = i;
      }
      if (hourlyPrecipProb[maxIdx] == 0) {
        peakChanceValue = 'None';
      } else if (maxIdx < hours.length) {
        final h = hours[maxIdx].hour % 12 == 0 ? 12 : hours[maxIdx].hour % 12;
        final suffix = hours[maxIdx].hour >= 12 ? 'pm' : 'am';
        peakChanceValue = '$h$suffix · ${hourlyPrecipProb[maxIdx]}%';
      } else {
        peakChanceValue = '${hourlyPrecipProb[maxIdx]}%';
      }
    } else {
      peakChanceValue = precipitationProbability == 0
          ? 'None'
          : '$precipitationProbability%';
    }

    // Duration: total hours with >20% precip probability
    final precipHours = hourlyPrecipProb.where((p) => p > 20).length;
    final durationValue = precipHours == 0
        ? 'None'
        : precipHours == 1
        ? '1 hour'
        : '$precipHours hours';

    // Dew point comfort label
    String dewLabel;
    if (dewPoint < 55) {
      dewLabel = 'Dry';
    } else if (dewPoint < 60) {
      dewLabel = 'Comfy';
    } else if (dewPoint < 65) {
      dewLabel = 'Sticky';
    } else if (dewPoint < 70) {
      dewLabel = 'Muggy';
    } else {
      dewLabel = 'Oppressive';
    }
    final dewValue = '${dewPoint.round()}° $dewLabel';

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: InfoChip(
                icon: WeatherIcons.cloud,
                label: 'Cloud cover',
                value: '$cloudCover%',
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: InfoChip(
                icon: WeatherIcons.umbrella,
                label: 'Peak chance',
                value: peakChanceValue,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: InfoChip(
                icon: Icons.schedule,
                label: 'Duration',
                value: durationValue,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: InfoChip(
                icon: WeatherIcons.thermometer_exterior,
                label: 'Dew point',
                value: dewValue,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHeaderRow(String label, IconData icon, String precipLabel) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Icon(
          icon,
          size: compact ? 10 : 15,
          color: AppColors.cream90,
        ),
        SizedBox(width: compact ? 3 : 4),
        Text(
          label,
          style: GoogleFonts.figtree(
            fontSize: compact ? 14 : 18,
            fontWeight: FontWeight.w400,
            color: AppColors.cream,
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
            color: AppColors.cream90,
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Chart label used above each graph in the expanded card
// ---------------------------------------------------------------------------
class _ChartLabel extends StatelessWidget {
  final String text;

  const _ChartLabel({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: AppColors.cream80,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Precipitation Probability — vertical bars
// ---------------------------------------------------------------------------
class _PrecipBarPainter extends CustomPainter {
  static const _yLabelStyleLarge = TextStyle(
    color: AppColors.cream95,
    fontSize: 10,
    fontWeight: FontWeight.w600,
  );
  static const _yLabelStyleSmall = TextStyle(
    color: AppColors.cream95,
    fontSize: 9,
    fontWeight: FontWeight.w600,
  );
  static const _hourLabelStyle = TextStyle(
    color: AppColors.cream90,
    fontSize: 10,
    fontWeight: FontWeight.w600,
  );

  final List<int> precipProb;
  final List<DateTime> hours;
  final DateTime? now;
  final bool showHourLabels;

  _PrecipBarPainter({
    required this.precipProb,
    required this.hours,
    this.now,
    this.showHourLabels = true,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (precipProb.isEmpty) return;

    final padBottom = showHourLabels ? 14.0 : 2.0;
    const padLeft = 28.0;
    final graphH = size.height - padBottom;
    final graphW = size.width - padLeft;
    final barCount = precipProb.length;
    final barW = graphW / barCount;

    // Y-axis percentage labels
    final yLabelStyle =
        showHourLabels ? _yLabelStyleLarge : _yLabelStyleSmall;
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
        Paint()..color = AppColors.cream12,
      );
    }

    // Bars
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

    // "Now" indicator
    _drawNowLine(canvas, graphH, padLeft, graphW, hours, now);

    // Hour labels
    if (showHourLabels) {
      for (var i = 0; i < hours.length; i++) {
        if (i % 6 != 0 && i != hours.length - 1) continue;
        final tp = TextPainter(
          text: TextSpan(
            text: DateFormat('ha').format(hours[i]).toLowerCase(),
            style: _hourLabelStyle,
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
  }

  @override
  bool shouldRepaint(covariant _PrecipBarPainter old) =>
      precipProb != old.precipProb ||
      now?.millisecondsSinceEpoch != old.now?.millisecondsSinceEpoch;
}

// ---------------------------------------------------------------------------
// Smooth cubic path helper
// ---------------------------------------------------------------------------
Path _smoothPath(List<Offset> points) {
  final path = Path()..moveTo(points.first.dx, points.first.dy);
  for (var i = 1; i < points.length; i++) {
    final prev = points[i - 1];
    final curr = points[i];
    final cpx = (prev.dx + curr.dx) / 2;
    path.cubicTo(cpx, prev.dy, cpx, curr.dy, curr.dx, curr.dy);
  }
  return path;
}

// ---------------------------------------------------------------------------
// Humidity line chart — solid line on a fixed 0–100% scale
// ---------------------------------------------------------------------------
class _HumidityLinePainter extends CustomPainter {
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
  static const _gradientColors = [AppColors.cream15, AppColors.cream03];

  final List<int> humidities;
  final List<DateTime> hours;
  final DateTime? now;
  final bool showHourLabels;

  _HumidityLinePainter({
    required this.humidities,
    required this.hours,
    this.now,
    this.showHourLabels = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (humidities.length < 2) return;

    const padTop = 2.0;
    final padBottom = showHourLabels ? 14.0 : 2.0;
    const padLeft = 20.0;
    final graphH = size.height - padTop - padBottom;
    final graphW = size.width - padLeft;
    final stepX = graphW / (humidities.length - 1);

    // Y-axis labels
    for (final pct in [100, 50, 0]) {
      final y = padTop + graphH * (1 - pct / 100.0);
      final tp = TextPainter(
        text: TextSpan(text: '$pct%', style: _yLabelStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(0, y - tp.height / 2));
    }

    // Humidity curve points
    final points = <Offset>[];
    for (var i = 0; i < humidities.length; i++) {
      final x = padLeft + i * stepX;
      final y = padTop + graphH * (1 - humidities[i] / 100.0);
      points.add(Offset(x, y));
    }

    final linePath = _smoothPath(points);

    // Gradient area fill under the curve
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
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: _gradientColors,
      ).createShader(fillRect);
    canvas.drawPath(fillPath, fillPaint);

    // Line
    canvas.drawPath(
      linePath,
      Paint()
        ..color = AppColors.cream50
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );

    // "Now" dot
    _drawNowDot(
      canvas,
      hours: hours,
      now: now,
      points: points,
      valueAt: (i) => humidities[i].toDouble(),
      yForValue: (v) => padTop + graphH * (1 - v / 100.0),
    );

    // Hour labels
    if (showHourLabels) {
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
  }

  @override
  bool shouldRepaint(covariant _HumidityLinePainter old) =>
      humidities != old.humidities ||
      now?.millisecondsSinceEpoch != old.now?.millisecondsSinceEpoch ||
      showHourLabels != old.showHourLabels;
}

// ---------------------------------------------------------------------------
// Shared helper: draw "Now" vertical indicator line
// ---------------------------------------------------------------------------
void _drawNowLine(
  Canvas canvas,
  double graphH,
  double padLeft,
  double graphW,
  List<DateTime> hours,
  DateTime? now,
) {
  if (now == null || hours.length < 2) return;
  if (now.isBefore(hours.first) || now.isAfter(hours.last)) return;

  final totalMs = hours.last.difference(hours.first).inMilliseconds.toDouble();
  if (totalMs <= 0) return;

  final nowMs = now.difference(hours.first).inMilliseconds.toDouble();
  final nowX = padLeft + graphW * (nowMs / totalMs);
  canvas.drawLine(
    Offset(nowX, 0),
    Offset(nowX, graphH),
    Paint()
      ..color = AppColors.cream90
      ..strokeWidth = 1,
  );
}

// ---------------------------------------------------------------------------
// Shared helper: draw "Now" dot on a line chart
// ---------------------------------------------------------------------------
// ---------------------------------------------------------------------------
// Bar Gauge — simple horizontal progress bar
// ---------------------------------------------------------------------------
class _BarGaugePainter extends CustomPainter {
  final int probability;

  _BarGaugePainter({required this.probability});

  @override
  void paint(Canvas canvas, Size size) {
    final pct = probability.clamp(0, 100) / 100.0;
    const barH = 6.0;
    final barY = (size.height - barH) / 2;

    // Track
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, barY, size.width, barH),
        const Radius.circular(barH / 2),
      ),
      Paint()..color = AppColors.cream12,
    );

    // Fill
    if (pct > 0) {
      final fillW = size.width * pct;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(0, barY, fillW, barH),
          const Radius.circular(barH / 2),
        ),
        Paint()..color = AppColors.cream.withValues(alpha: 0.35 + 0.5 * pct),
      );
      canvas.drawCircle(
        Offset(fillW, barY + barH / 2),
        5,
        Paint()..color = AppColors.cream,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _BarGaugePainter old) =>
      probability != old.probability;
}

void _drawNowDot(
  Canvas canvas, {
  required List<DateTime> hours,
  required DateTime? now,
  required List<Offset> points,
  required double Function(int i) valueAt,
  required double Function(double v) yForValue,
}) {
  if (now == null || hours.length < 2 || points.length != hours.length) return;
  if (now.isBefore(hours.first) || now.isAfter(hours.last)) return;

  var i = 0;
  for (; i < hours.length - 1; i++) {
    if (!now.isAfter(hours[i + 1])) break;
  }
  if (i >= hours.length - 1) i = hours.length - 2;

  final bucketMs = hours[i + 1].difference(hours[i]).inMilliseconds.toDouble();
  final t = bucketMs > 0
      ? (now.difference(hours[i]).inMilliseconds.toDouble() / bucketMs).clamp(
          0.0,
          1.0,
        )
      : 0.0;

  final v0 = valueAt(i);
  final v1 = valueAt(i + 1);
  final v = v0 + (v1 - v0) * t;

  final x0 = points[i].dx;
  final x1 = points[i + 1].dx;
  final x = x0 + (x1 - x0) * t;
  final y = yForValue(v);

  canvas.drawCircle(Offset(x, y), 4, Paint()..color = AppColors.cream);
}
