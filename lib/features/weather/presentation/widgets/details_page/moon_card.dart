import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:heather/core/constants/app_colors.dart';
import 'package:heather/core/utils/astro_events.dart';
import 'package:heather/core/utils/moon_phase.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:weather_icons/weather_icons.dart';
import '../../providers/moon_data_provider.dart';
import '../../providers/visible_planets_provider.dart';
import './card_container.dart';
import './card_display_mode.dart';
import './info_chip.dart';

class MoonCard extends ConsumerWidget {
  final DateTime now;
  final double latitude;
  final double longitude;
  final CardDisplayMode mode;
  final int cloudCover;
  final DateTime sunrise;
  final DateTime sunset;
  final DateTime tomorrowSunrise;
  final DateTime tomorrowSunset;
  final int utcOffsetSeconds;

  const MoonCard({
    super.key,
    required this.now,
    required this.latitude,
    required this.longitude,
    this.mode = CardDisplayMode.normal,
    required this.cloudCover,
    required this.sunrise,
    required this.sunset,
    required this.tomorrowSunrise,
    required this.tomorrowSunset,
    required this.utcOffsetSeconds,
  });

  static String _viewingCondition(int cloudCover) {
    if (cloudCover <= 10) return 'Clear skies';
    if (cloudCover <= 40) return 'Fair viewing';
    if (cloudCover <= 70) return 'Hazy';
    return 'Overcast';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dateFmt = DateFormat('MMM d');

    final usno = ref.watch(moonDataProvider).valueOrNull;

    if (usno == null) {
      if (mode == CardDisplayMode.collapsed) {
        return _buildCollapsedFallback();
      }
      return CardContainer(
        backgroundIcon: WeatherIcons.moon_full,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Icon(
                  WeatherIcons.moon_full,
                  size: 15,
                  color: AppColors.cream.withValues(alpha: 0.9),
                ),
                const SizedBox(width: 4),
                Text(
                  'Sky',
                  style: GoogleFonts.figtree(
                    fontSize: 18,
                    fontWeight: FontWeight.w400,
                    color: AppColors.cream,
                  ),
                ),
              ],
            ),
            const Expanded(child: SizedBox.expand()),
            const SizedBox(height: 14),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _VisiblePlanetsRow(latitude: latitude, longitude: longitude),
                _AstroEventRow(now: now),
              ],
            ),
          ],
        ),
      );
    }

    final phase =
        usnoPhaseToEnum(usno.curPhase) ??
        phaseFromFraction(usno.fractionForDate(now));
    final illumination = usno.fracIllum.round();
    final fraction = usno.fractionForDate(now);

    final nextFull = usno.nextFullMoon;
    final nextNew = usno.nextNewMoon;

    String phaseDatesText = '';
    if (nextFull != null && nextNew != null) {
      final fullFirst = nextFull.isBefore(nextNew);
      final firstLabel = fullFirst ? 'Full' : 'New';
      final first = fullFirst ? nextFull : nextNew;
      final secondLabel = fullFirst ? 'New' : 'Full';
      final second = fullFirst ? nextNew : nextFull;
      final firstText = _relativeLabel(firstLabel, first, now, dateFmt);
      final secondText = _relativeLabel(secondLabel, second, now, dateFmt);
      phaseDatesText = '$firstText \u00B7 $secondText';
    }

    final icon = moonPhaseIcon(fraction);

    if (mode == CardDisplayMode.collapsed) {
      return _buildCollapsedWithData(icon, phase, illumination);
    }

    if (mode == CardDisplayMode.expanded) {
      return _buildExpanded(
        icon: icon,
        phase: phase,
        illumination: illumination,
        fraction: fraction,
        phaseDatesText: phaseDatesText,
        usno: usno,
      );
    }

    // Normal mode
    return _buildNormal(
      icon: icon,
      phase: phase,
      illumination: illumination,
      fraction: fraction,
      phaseDatesText: phaseDatesText,
      usno: usno,
    );
  }

  Widget _buildCollapsedWithData(
    IconData icon,
    MoonPhase phase,
    int illumination,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        children: [
          Icon(
            icon,
            size: 14,
            color: AppColors.cream.withValues(alpha: 0.9),
          ),
          const SizedBox(width: 4),
          Text(
            'Sky',
            style: GoogleFonts.figtree(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: AppColors.cream,
            ),
          ),
          const Spacer(),
          Text(
            '$illumination%',
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: AppColors.cream.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(width: 6),
          Text(
            moonPhaseLabel(phase),
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

  Widget _buildNormal({
    required IconData icon,
    required MoonPhase phase,
    required int illumination,
    required double fraction,
    required String phaseDatesText,
    required UsnoMoonData usno,
  }) {
    return CardContainer(
      backgroundIcon: icon,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(icon, phase, illumination, phaseDatesText),
          // Moon disc
          Expanded(
            child: Center(
              child: CustomPaint(
                painter: _MoonDiscPainter(fraction: fraction),
                size: Size.infinite,
              ),
            ),
          ),
          // Phase strip
          _PhaseStrip(currentPhase: phase),
          // Bottom: planets + astro event
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _VisiblePlanetsRow(latitude: latitude, longitude: longitude),
              _AstroEventRow(now: now, nextFullMoonDate: usno.nextFullMoon),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildExpanded({
    required IconData icon,
    required MoonPhase phase,
    required int illumination,
    required double fraction,
    required String phaseDatesText,
    required UsnoMoonData usno,
  }) {
    return CardContainer(
      backgroundIcon: icon,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Header row
          _buildHeader(icon, phase, illumination, phaseDatesText),
          // 2. Subtitle row (phase dates · Day N)
          _buildExpandedSubtitleRow(phaseDatesText, usno.lunarAge(now)),
          const SizedBox(height: 10),
          // 3. Phase-cycle chart hero
          SizedBox(
            height: 200,
            child: CustomPaint(
              size: Size.infinite,
              painter: _MoonCycleChartPainter(usno: usno, now: now),
            ),
          ),
          const SizedBox(height: 14),
          // 4. Centered darkness text
          _buildExpandedDarknessRow(),
          const SizedBox(height: 18),
          // 5. 2x2 InfoChip grid
          _buildExpandedInfoGrid(usno),
          const Spacer(),
          // 6. Astro footer (visible planets + active event)
          _VisiblePlanetsRow(latitude: latitude, longitude: longitude),
          _AstroEventRow(now: now, nextFullMoonDate: usno.nextFullMoon),
        ],
      ),
    );
  }

  /// Subtitle row under the header: "New Apr 17 · Full May 1   ·   Day 12"
  Widget _buildExpandedSubtitleRow(String phaseDatesText, double? lunarAge) {
    final parts = <String>[];
    if (phaseDatesText.isNotEmpty) parts.add(phaseDatesText);
    if (lunarAge != null) parts.add('Day ${lunarAge.round()}');
    if (parts.isEmpty) return const SizedBox(height: 18);
    return SizedBox(
      height: 18,
      child: Row(
        children: [
          const Spacer(),
          Text(
            parts.join('   \u00B7   '),
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: AppColors.cream.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }

  /// Centered darkness row: "⏱  11h 6m darkness  (+2m tmrw)"
  Widget _buildExpandedDarknessRow() {
    final todayNight =
        const Duration(hours: 24) - sunset.difference(sunrise);
    final tomorrowNight =
        const Duration(hours: 24) - tomorrowSunset.difference(tomorrowSunrise);
    final deltaMinutes = tomorrowNight.inMinutes - todayNight.inMinutes;

    final nightH = todayNight.inHours;
    final nightM = todayNight.inMinutes % 60;

    final deltaStr = deltaMinutes == 0
        ? ' (same tmrw)'
        : ' (${deltaMinutes > 0 ? '+' : ''}${deltaMinutes}m tmrw)';

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          WeatherIcons.time_3,
          size: 12,
          color: AppColors.cream.withValues(alpha: 0.95),
        ),
        const SizedBox(width: 5),
        Text.rich(
          TextSpan(
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.cream.withValues(alpha: 0.95),
            ),
            children: [
              TextSpan(text: '${nightH}h ${nightM}m darkness'),
              TextSpan(
                text: deltaStr,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: AppColors.cream.withValues(alpha: 0.75),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 2x2 InfoChip grid: Illumination, Distance, Viewing, Zodiac.
  Widget _buildExpandedInfoGrid(UsnoMoonData usno) {
    final distKm = moonDistanceKm(now);
    final distMi = (distKm * 0.621371).round();
    final distLabel = moonDistanceLabel(now);
    final numberFmt = NumberFormat('#,###');
    final distValue = distLabel != null
        ? '${numberFmt.format(distMi)} mi · $distLabel'
        : '${numberFmt.format(distMi)} mi';

    final zodiac = currentZodiac(now);
    final zodiacIcon = SvgPicture.asset(
      'assets/images/zodiac/${zodiac.toLowerCase()}.svg',
      width: 10,
      height: 10,
      colorFilter: ColorFilter.mode(
        AppColors.cream.withValues(alpha: 0.6),
        BlendMode.srcIn,
      ),
    );

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: InfoChip(
                icon: WeatherIcons.moon_full,
                label: 'Illumination',
                value: '${usno.fracIllum.round()}%',
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: InfoChip(
                icon: WeatherIcons.earthquake,
                label: 'Distance',
                value: distValue,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: InfoChip(
                icon: WeatherIcons.stars,
                label: 'Viewing',
                value: _viewingCondition(cloudCover),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: InfoChip(
                iconWidget: zodiacIcon,
                label: 'Season',
                value: zodiac,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCollapsedFallback() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        children: [
          Icon(
            WeatherIcons.moon_full,
            size: 14,
            color: AppColors.cream.withValues(alpha: 0.9),
          ),
          const SizedBox(width: 4),
          Text(
            'Sky',
            style: GoogleFonts.figtree(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: AppColors.cream,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(
    IconData icon,
    MoonPhase phase,
    int illumination,
    String phaseDatesText,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Icon(
          icon,
          size: 15,
          color: AppColors.cream.withValues(alpha: 0.9),
        ),
        const SizedBox(width: 4),
        Text(
          'Sky',
          style: GoogleFonts.figtree(
            fontSize: 18,
            fontWeight: FontWeight.w400,
            color: AppColors.cream,
          ),
        ),
        const Spacer(),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  phase == MoonPhase.fullMoon
                      ? fullMoonName(now)
                      : '$illumination%',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: AppColors.cream.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(width: 6),
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
            if (phaseDatesText.isNotEmpty && mode != CardDisplayMode.expanded)
              Text(
                phaseDatesText,
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: AppColors.cream.withValues(alpha: 0.8),
                ),
              ),
          ],
        ),
      ],
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

// ---------------------------------------------------------------------------
// Moon Disc Painter
// ---------------------------------------------------------------------------

class _MoonDiscPainter extends CustomPainter {
  final double fraction;

  _MoonDiscPainter({required this.fraction});

  @override
  void paint(Canvas canvas, Size size) {
    final radius = math.min(size.width, size.height) / 2;
    if (radius <= 0) return;
    final center = Offset(size.width / 2, size.height / 2);

    // Use saveLayer so BlendMode.clear erases to transparency
    canvas.saveLayer(Rect.fromCircle(center: center, radius: radius + 1), Paint());

    // 1. Draw base lit circle
    final litPaint = Paint()
      ..color = AppColors.cream.withValues(alpha: 0.85)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius, litPaint);

    // 2. Erase shadow portion to transparency
    final shadowPaint = Paint()
      ..blendMode = BlendMode.clear
      ..style = PaintingStyle.fill;

    if (fraction > 0.02 && fraction < 0.98) {
      final terminatorX = math.cos(2 * math.pi * fraction);
      final absTerminatorX = terminatorX.abs();

      final shadowPath = Path();
      final waxing = fraction < 0.5;

      if (waxing) {
        shadowPath.addArc(
          Rect.fromCircle(center: center, radius: radius),
          -math.pi / 2,
          -math.pi,
        );
        final terminatorRect = Rect.fromCenter(
          center: center,
          width: absTerminatorX * radius * 2,
          height: radius * 2,
        );
        if (fraction < 0.25) {
          shadowPath.addArc(terminatorRect, math.pi / 2, -math.pi);
        } else {
          shadowPath.addArc(terminatorRect, math.pi / 2, math.pi);
        }
      } else {
        shadowPath.addArc(
          Rect.fromCircle(center: center, radius: radius),
          -math.pi / 2,
          math.pi,
        );
        final terminatorRect = Rect.fromCenter(
          center: center,
          width: absTerminatorX * radius * 2,
          height: radius * 2,
        );
        if (fraction > 0.75) {
          shadowPath.addArc(terminatorRect, math.pi / 2, math.pi);
        } else {
          shadowPath.addArc(terminatorRect, math.pi / 2, -math.pi);
        }
      }

      canvas.save();
      canvas.clipPath(
        Path()..addOval(Rect.fromCircle(center: center, radius: radius)),
      );
      canvas.drawPath(shadowPath, shadowPaint);
      canvas.restore();
    } else if (fraction <= 0.02 || fraction >= 0.98) {
      canvas.drawCircle(center, radius, shadowPaint);
    }

    // 3. Subtle outline
    final outlinePaint = Paint()
      ..color = AppColors.cream.withValues(alpha: 0.25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawCircle(center, radius, outlinePaint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(_MoonDiscPainter oldDelegate) =>
      oldDelegate.fraction != fraction;
}

// ---------------------------------------------------------------------------
// Phase Strip — 8 small icons showing the full lunar cycle
// ---------------------------------------------------------------------------

class _PhaseStrip extends StatelessWidget {
  final MoonPhase currentPhase;

  const _PhaseStrip({required this.currentPhase});

  static const _phases = MoonPhase.values;

  static const _phaseIcons = [
    WeatherIcons.moon_new,
    WeatherIcons.moon_waxing_crescent_3,
    WeatherIcons.moon_first_quarter,
    WeatherIcons.moon_waxing_gibbous_3,
    WeatherIcons.moon_full,
    WeatherIcons.moon_waning_gibbous_3,
    WeatherIcons.moon_third_quarter,
    WeatherIcons.moon_waning_crescent_3,
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 14,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(_phases.length, (i) {
          final isCurrent = _phases[i] == currentPhase;
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _phaseIcons[i],
                size: 10,
                color: AppColors.cream.withValues(
                  alpha: isCurrent ? 0.95 : 0.3,
                ),
              ),
              if (isCurrent)
                Container(
                  width: 3,
                  height: 3,
                  decoration: BoxDecoration(
                    color: AppColors.cream.withValues(alpha: 0.9),
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          );
        }),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Supporting widgets
// ---------------------------------------------------------------------------

class _VisiblePlanetsRow extends ConsumerWidget {
  final double latitude;
  final double longitude;

  const _VisiblePlanetsRow({required this.latitude, required this.longitude});

  static String _planetGlyph(String name) => switch (name) {
    'Mercury' => '\u263F',
    'Venus' => '\u2640',
    'Mars' => '\u2642',
    'Jupiter' => '\u2643',
    'Saturn' => '\u2644',
    'Uranus' => '\u2645',
    'Neptune' => '\u2646',
    _ => '',
  };

  static String _formatName(String name) {
    final glyph = _planetGlyph(name);
    return glyph.isEmpty ? name : '$glyph $name';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final planets = ref.watch(
      visiblePlanetsProvider((lat: latitude, lon: longitude)),
    );

    return planets.when(
      data: (names) {
        if (names.isEmpty) return const SizedBox.shrink();
        return Padding(
          padding: const EdgeInsets.only(bottom: 1),
          child: Row(
            children: [
              Text(
                'Visible planets',
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: AppColors.cream.withValues(alpha: 0.85),
                ),
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  names.map(_formatName).join(' \u00B7 '),
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                    color: AppColors.cream.withValues(alpha: 0.85),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const SizedBox(height: 15),
      error: (_, _) => const SizedBox.shrink(),
    );
  }
}

class _AstroEventRow extends StatelessWidget {
  final DateTime now;
  final DateTime? nextFullMoonDate;

  const _AstroEventRow({required this.now, this.nextFullMoonDate});

  @override
  Widget build(BuildContext context) {
    final sign = currentZodiac(now);
    final event = activeAstroEvent(now, nextFullMoonDate: nextFullMoonDate);
    final style = GoogleFonts.poppins(
      fontSize: 11,
      fontWeight: FontWeight.w700,
      color: AppColors.cream.withValues(alpha: 0.9),
    );

    return Row(
      children: [
        SvgPicture.asset(
          'assets/images/zodiac/${sign.toLowerCase()}.svg',
          width: 13,
          height: 13,
          colorFilter: ColorFilter.mode(
            AppColors.cream.withValues(alpha: 0.9),
            BlendMode.srcIn,
          ),
        ),
        const SizedBox(width: 4),
        Text('$sign season', style: style),
        if (event != null) ...[
          Text('  \u00B7  ', style: style),
          Flexible(
            child: _buildEventLabel(event, style),
          ),
        ],
      ],
    );
  }

  Widget _buildEventLabel(AstroEvent event, TextStyle style) {
    final lightStyle = GoogleFonts.poppins(
      fontSize: 11,
      fontWeight: FontWeight.w400,
      color: AppColors.cream.withValues(alpha: 0.9),
    );
    final label = event.label;
    final untilIndex = label.indexOf(' until ');

    final spans = <TextSpan>[];
    if (untilIndex == -1) {
      spans.add(TextSpan(text: label, style: style));
    } else {
      spans.add(TextSpan(text: label.substring(0, untilIndex), style: style));
      spans.add(TextSpan(text: label.substring(untilIndex), style: lightStyle));
    }
    if (event.zhr != null) {
      spans.add(TextSpan(text: ' (~${event.zhr}/hr)', style: lightStyle));
    }

    return Text.rich(
      TextSpan(children: spans),
      overflow: TextOverflow.ellipsis,
    );
  }
}

// ---------------------------------------------------------------------------
// Moon Cycle Chart Painter — full lunar-cycle illumination curve anchored
// to the most recent New Moon, with phase-disc markers, dated labels,
// a "now" reference line, and a labeled "Today" dot.
// ---------------------------------------------------------------------------

class _MoonCycleChartPainter extends CustomPainter {
  final UsnoMoonData usno;
  final DateTime now;

  _MoonCycleChartPainter({required this.usno, required this.now});

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    // 1. Anchor on the current lunar cycle (most recent New Moon → next New
    //    Moon). Fall back to a 30-day window centered on now if either
    //    transition is missing.
    DateTime? cycleStart;
    DateTime? cycleEnd;
    for (final t in usno.transitions) {
      if (t.phase != 'New Moon') continue;
      if (!t.date.isAfter(now)) {
        cycleStart = t.date;
      } else {
        cycleEnd = t.date;
        break;
      }
    }
    final hasCycle = cycleStart != null && cycleEnd != null;
    final start = hasCycle
        ? cycleStart
        : now.subtract(const Duration(days: 15));
    final end = hasCycle
        ? cycleEnd
        : now.add(const Duration(days: 15));
    final totalSec = end.difference(start).inSeconds.toDouble();
    if (totalSec <= 0) return;

    // 2. Geometry
    const padTop = 44.0;
    const padBottom = 6.0;
    const padLeft = 16.0;
    const padRight = 16.0;
    const discSize = 22.0;
    final graphW = size.width - padLeft - padRight;
    final graphH = size.height - padTop - padBottom;
    if (graphW <= 0 || graphH <= 0) return;
    final bottomY = padTop + graphH;

    double xForDate(DateTime d) {
      final f = (d.difference(start).inSeconds / totalSec).clamp(0.0, 1.0);
      return padLeft + graphW * f;
    }

    // 3. Sample ~60 illumination values across the cycle
    const sampleCount = 60;
    final points = <Offset>[];
    for (var i = 0; i < sampleCount; i++) {
      final f = i / (sampleCount - 1);
      final sampleDate = start.add(
        Duration(seconds: (totalSec * f).round()),
      );
      final illum = usno.illuminationForDate(sampleDate); // 0..100
      final x = padLeft + graphW * f;
      final y = padTop + graphH * (1 - (illum / 100).clamp(0.0, 1.0));
      points.add(Offset(x, y));
    }

    // 4. Top-left chart title
    final titlePainter = TextPainter(
      text: TextSpan(
        text: 'Phase cycle',
        style: TextStyle(
          color: AppColors.cream.withValues(alpha: 0.9),
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    titlePainter.paint(canvas, const Offset(0, 0));

    // 5. Smoothed cubic illumination curve
    final linePath = Path()..moveTo(points.first.dx, points.first.dy);
    for (var i = 1; i < points.length; i++) {
      final prev = points[i - 1];
      final curr = points[i];
      final cpx = (prev.dx + curr.dx) / 2;
      linePath.cubicTo(cpx, prev.dy, cpx, curr.dy, curr.dx, curr.dy);
    }

    // 6. Area fill under the curve
    final fillPath = Path()..addPath(linePath, Offset.zero);
    fillPath.lineTo(points.last.dx, bottomY);
    fillPath.lineTo(points.first.dx, bottomY);
    fillPath.close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          AppColors.cream.withValues(alpha: 0.15),
          AppColors.cream.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromLTRB(
        padLeft,
        padTop,
        padLeft + graphW,
        bottomY,
      ))
      ..style = PaintingStyle.fill;
    canvas.drawPath(fillPath, fillPaint);

    // 7. Curve stroke
    canvas.drawPath(
      linePath,
      Paint()
        ..color = AppColors.cream.withValues(alpha: 0.55)
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );

    // 8. Vertical dashed "now" line
    final nowX = xForDate(now);
    final nowLinePath = Path()
      ..moveTo(nowX, padTop)
      ..lineTo(nowX, bottomY);
    _drawDashedLine(
      canvas,
      nowLinePath,
      Paint()
        ..color = AppColors.cream.withValues(alpha: 0.6)
        ..strokeWidth = 1.5
        ..style = PaintingStyle.stroke,
    );

    // 9. Phase-disc markers along the top of the chart area
    if (hasCycle) {
      final dateLabelStyle = TextStyle(
        color: AppColors.cream.withValues(alpha: 0.75),
        fontSize: 10,
        fontWeight: FontWeight.w600,
      );
      final dateFmt = DateFormat('MMM d');
      for (final t in usno.transitions) {
        if (t.date.isBefore(start) || t.date.isAfter(end)) continue;
        final markerFraction = switch (t.phase) {
          'New Moon' => 0.0,
          'First Quarter' => 0.25,
          'Full Moon' => 0.5,
          'Last Quarter' || 'Third Quarter' => 0.75,
          _ => -1.0,
        };
        if (markerFraction < 0) continue;

        final cx = xForDate(t.date);
        const discTop = 4.0;
        final discLeft = (cx - discSize / 2).clamp(
          0.0,
          size.width - discSize,
        );
        canvas.save();
        canvas.translate(discLeft, discTop);
        _MoonDiscPainter(fraction: markerFraction)
            .paint(canvas, const Size(discSize, discSize));
        canvas.restore();

        final label = dateFmt.format(t.date);
        final tp = TextPainter(
          text: TextSpan(text: label, style: dateLabelStyle),
          textDirection: TextDirection.ltr,
        )..layout();
        final labelX = (cx - tp.width / 2)
            .clamp(0.0, size.width - tp.width);
        const labelY = discTop + discSize + 1;
        tp.paint(canvas, Offset(labelX, labelY));
      }
    }

    // 10. "Today" dot on the curve at now
    final nowFracOnCycle =
        (now.difference(start).inSeconds / totalSec).clamp(0.0, 1.0);
    final nowSamplePos = nowFracOnCycle * (sampleCount - 1);
    final lowerIdx = nowSamplePos.floor().clamp(0, sampleCount - 1);
    final upperIdx = (lowerIdx + 1).clamp(0, sampleCount - 1);
    final segFrac = nowSamplePos - lowerIdx;
    final dotY = points[lowerIdx].dy +
        (points[upperIdx].dy - points[lowerIdx].dy) * segFrac;
    final dotCenter = Offset(nowX, dotY);

    canvas.drawCircle(
      dotCenter,
      4,
      Paint()
        ..color = AppColors.cream.withValues(alpha: 0.95)
        ..style = PaintingStyle.fill,
    );

    // 11. "Today N%" label next to the dot
    final todayIllum = usno.illuminationForDate(now).round();
    final todayLabel = TextPainter(
      text: TextSpan(
        text: 'Today $todayIllum%',
        style: TextStyle(
          color: AppColors.cream.withValues(alpha: 0.95),
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    // Place to the right of the dot, but flip to the left if it would clip.
    var labelX = dotCenter.dx + 8;
    if (labelX + todayLabel.width > size.width - 2) {
      labelX = dotCenter.dx - todayLabel.width - 8;
    }
    if (labelX < 0) labelX = 0;
    var labelY = dotCenter.dy - todayLabel.height / 2;
    // Keep the label inside the chart area vertically.
    if (labelY < padTop) labelY = padTop;
    if (labelY + todayLabel.height > bottomY) {
      labelY = bottomY - todayLabel.height;
    }
    todayLabel.paint(canvas, Offset(labelX, labelY));
  }

  void _drawDashedLine(Canvas canvas, Path path, Paint paint) {
    const dashLength = 3.0;
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
  bool shouldRepaint(covariant _MoonCycleChartPainter old) =>
      now != old.now || usno != old.usno;
}
