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

  // Returns ("Up" | "Down", "sets 9:42pm" | "rises 12:33am" | null)
  static ({String state, String? next}) _moonVisibility(
    DateTime now,
    UsnoMoonRiseSet? riseSet,
  ) {
    if (riseSet == null) return (state: '—', next: null);
    final rise = riseSet.moonrise;
    final set = riseSet.moonset;

    // No data at all from USNO for today (high latitude / API blip)
    if (rise == null && set == null) return (state: '—', next: null);

    final timeFmt = DateFormat('h:mma');
    String fmt(DateTime d) => timeFmt.format(d).toLowerCase();

    // Both events present — figure out current state from chronological order
    if (rise != null && set != null) {
      if (rise.isBefore(set)) {
        // Standard day: down → rises → up → sets → down
        if (now.isBefore(rise)) return (state: 'Down', next: 'rises ${fmt(rise)}');
        if (now.isBefore(set)) return (state: 'Up', next: 'sets ${fmt(set)}');
        return (state: 'Down', next: null); // already set for the night
      } else {
        // Set comes before rise: up at midnight → sets → down → rises → up
        if (now.isBefore(set)) return (state: 'Up', next: 'sets ${fmt(set)}');
        if (now.isBefore(rise)) return (state: 'Down', next: 'rises ${fmt(rise)}');
        return (state: 'Up', next: null); // back up for the rest of the night
      }
    }

    // Only one of the two — moon is up or down for the whole local day
    if (rise != null) return (state: 'Up', next: 'rose ${fmt(rise)}');
    return (state: 'Down', next: 'sets ${fmt(set!)}');
  }

  // Combines cloud cover (0–100) and moon illumination (0–100) into a label.
  // Lower cloud cover and lower illumination both make stargazing better.
  static String _stargazingRating(int cloudCover, double illumPercent) {
    // 0–10 scale, 10 = pristine
    final cloudScore = (10 - (cloudCover / 10)).clamp(0.0, 10.0);
    final moonScore = (10 - (illumPercent / 10)).clamp(0.0, 10.0);
    // Weight clouds 2× more than moon — clouds matter more for visibility
    final score = (cloudScore * 2 + moonScore) / 3;
    if (score >= 8) return 'Excellent';
    if (score >= 6) return 'Good';
    if (score >= 4) return 'Fair';
    return 'Poor';
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
                const Icon(
                  WeatherIcons.moon_full,
                  size: 15,
                  color: AppColors.cream90,
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
    final illumination = usno.illuminationForDate(now).round();
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
        ref: ref,
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
            color: AppColors.cream90,
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
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: AppColors.cream,
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
    required WidgetRef ref,
    required IconData icon,
    required MoonPhase phase,
    required int illumination,
    required double fraction,
    required String phaseDatesText,
    required UsnoMoonData usno,
  }) {
    final dateFmt = DateFormat('MMM d');
    final lunarAge = usno.lunarAge(now);
    final nextFull = usno.nextFullMoon;
    final nextNew = usno.nextNewMoon;

    // Pick the next phase event (whichever comes first) and split the
    // label/date so we can bold the date in the rendered caption.
    String? nextPrefix;
    String? nextDate;
    if (nextFull != null && nextNew != null) {
      final fullFirst = nextFull.isBefore(nextNew);
      nextPrefix = fullFirst ? 'Next full: ' : 'Next new: ';
      nextDate = dateFmt.format(fullFirst ? nextFull : nextNew);
    } else if (nextFull != null) {
      nextPrefix = 'Next full: ';
      nextDate = dateFmt.format(nextFull);
    } else if (nextNew != null) {
      nextPrefix = 'Next new: ';
      nextDate = dateFmt.format(nextNew);
    }

    final hasCaption = lunarAge != null || nextPrefix != null;
    final hasAstroEvent =
        activeAstroEvent(now, nextFullMoonDate: usno.nextFullMoon) != null;

    final riseSet = ref.watch(moonRiseSetProvider((
      lat: latitude,
      lon: longitude,
      tzOffsetSeconds: utcOffsetSeconds,
    ))).valueOrNull;

    return CardContainer(
      backgroundIcon: icon,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Header row
          _buildHeader(icon, phase, illumination, phaseDatesText),
          const Spacer(),
          // 2. Phase-cycle chart hero
          SizedBox(
            height: 72,
            child: CustomPaint(
              size: Size.infinite,
              painter: _MoonCycleChartPainter(usno: usno, now: now),
            ),
          ),
          // 3. Caption: Day N · Next <full|new>: <Mon D> — directly under chart
          if (hasCaption)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Center(
                child: Text.rich(
                  TextSpan(
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: AppColors.cream80,
                    ),
                    children: [
                      if (lunarAge != null) ...[
                        const TextSpan(text: 'Day '),
                        TextSpan(
                          text: '${lunarAge.round()}',
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.cream90,
                          ),
                        ),
                      ],
                      if (lunarAge != null && nextPrefix != null)
                        const TextSpan(text: '  \u00B7  '),
                      if (nextPrefix != null) ...[
                        TextSpan(text: nextPrefix),
                        TextSpan(
                          text: nextDate,
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.cream90,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          const Spacer(),
          // 4. Tonight darkness + moonrise/moonset block (2 text lines)
          _buildExpandedDarknessRow(riseSet),
          const Spacer(),
          // 5. 2x2 InfoChip grid (4 chips)
          _buildExpandedInfoGrid(usno, riseSet),
          const Spacer(),
          // 6. Visible planets rich block
          _ExpandedVisiblePlanetsBlock(
            latitude: latitude,
            longitude: longitude,
          ),
          // 7. Astro event footer (no season) — only when an event is active
          if (hasAstroEvent) ...[
            const Spacer(),
            _AstroEventRow(
              now: now,
              nextFullMoonDate: usno.nextFullMoon,
              showSeason: false,
            ),
          ],
        ],
      ),
    );
  }

  /// Tonight darkness + moonrise/moonset row.
  Widget _buildExpandedDarknessRow(UsnoMoonRiseSet? riseSet) {
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

    final timeFmt = DateFormat('h:mma');
    String formatTime(DateTime? d) =>
        d == null ? '—' : timeFmt.format(d).toLowerCase();

    final hasRiseSet =
        riseSet != null && (riseSet.moonrise != null || riseSet.moonset != null);

    final labelStyle = GoogleFonts.poppins(
      fontSize: 11,
      fontWeight: FontWeight.w400,
      color: AppColors.cream75,
    );
    final timeStyle = GoogleFonts.poppins(
      fontSize: 11,
      fontWeight: FontWeight.w700,
      color: AppColors.cream95,
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text.rich(
              TextSpan(
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.cream95,
                ),
                children: [
                  TextSpan(
                    text: 'Tonight  \u00B7  ',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: AppColors.cream95,
                    ),
                  ),
                  TextSpan(text: '${nightH}h ${nightM}m dark'),
                  TextSpan(
                    text: deltaStr,
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
        if (hasRiseSet) ...[
          const SizedBox(height: 2),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(text: 'Moonrise ', style: labelStyle),
                    TextSpan(
                      text: formatTime(riseSet.moonrise),
                      style: timeStyle,
                    ),
                    TextSpan(text: '  \u00B7  Moonset ', style: labelStyle),
                    TextSpan(
                      text: formatTime(riseSet.moonset),
                      style: timeStyle,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  /// 2x2 InfoChip grid: Visibility, Distance, Stargazing, Zodiac.
  Widget _buildExpandedInfoGrid(UsnoMoonData usno, UsnoMoonRiseSet? riseSet) {
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
      colorFilter: const ColorFilter.mode(
        AppColors.cream60,
        BlendMode.srcIn,
      ),
    );

    final visibility = _moonVisibility(now, riseSet);
    final visibilityValue = visibility.next == null
        ? visibility.state
        : '${visibility.state} · ${visibility.next}';

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: InfoChip(
                icon: WeatherIcons.moonrise,
                label: 'Moon visibility',
                value: visibilityValue,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: InfoChip(
                icon: WeatherIcons.earthquake,
                label: 'Moon distance',
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
                label: 'Viewing rating',
                value: _stargazingRating(
                  cloudCover,
                  usno.illuminationForDate(now),
                ),
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
          const Icon(
            WeatherIcons.moon_full,
            size: 14,
            color: AppColors.cream90,
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
          color: AppColors.cream90,
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
                    color: AppColors.cream70,
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
            if (phaseDatesText.isNotEmpty)
              Text(
                phaseDatesText,
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: AppColors.cream80,
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
      ..color = AppColors.cream85
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
      ..color = AppColors.cream25
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
      height: 8,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(_phases.length, (i) {
          final isCurrent = _phases[i] == currentPhase;
          return Icon(
            _phaseIcons[i],
            size: 9,
            color: isCurrent ? AppColors.cream95 : AppColors.cream30,
          );
        }),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Supporting widgets
// ---------------------------------------------------------------------------

String _planetGlyph(String name) => switch (name) {
  'Mercury' => '\u263F',
  'Venus' => '\u2640',
  'Mars' => '\u2642',
  'Jupiter' => '\u2643',
  'Saturn' => '\u2644',
  'Uranus' => '\u2645',
  'Neptune' => '\u2646',
  _ => '',
};

String _formatPlanetName(String name) {
  final glyph = _planetGlyph(name);
  return glyph.isEmpty ? name : '$glyph $name';
}

class _VisiblePlanetsRow extends ConsumerWidget {
  final double latitude;
  final double longitude;

  const _VisiblePlanetsRow({required this.latitude, required this.longitude});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final planets = ref.watch(
      visiblePlanetsProvider((lat: latitude, lon: longitude)),
    );

    return planets.when(
      data: (data) {
        if (data.isEmpty) return const SizedBox.shrink();
        final names = data.map((p) => p.name).toList();
        return Row(
          children: [
            Text(
              'Visible planets',
              style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: AppColors.cream85,
              ),
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                names.map(_formatPlanetName).join(' \u00B7 '),
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: FontWeight.w400,
                  color: AppColors.cream85,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        );
      },
      loading: () => const SizedBox(height: 15),
      error: (_, _) => const SizedBox.shrink(),
    );
  }
}

class _ExpandedVisiblePlanetsBlock extends ConsumerWidget {
  final double latitude;
  final double longitude;

  const _ExpandedVisiblePlanetsBlock({
    required this.latitude,
    required this.longitude,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final planets = ref.watch(
      visiblePlanetsProvider((lat: latitude, lon: longitude)),
    );

    return planets.when(
      data: (data) {
        if (data.isEmpty) return const SizedBox.shrink();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              'Visible tonight',
              style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: AppColors.cream85,
              ),
            ),
            const SizedBox(height: 6),
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (var i = 0; i < data.length; i++) ...[
                    if (i > 0) const SizedBox(width: 6),
                    Expanded(child: _PlanetTile(planet: data[i])),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 8),
          ],
        );
      },
      loading: () => const SizedBox(height: 83),
      error: (_, _) => const SizedBox.shrink(),
    );
  }
}

class _PlanetTile extends StatelessWidget {
  final VisiblePlanet planet;

  const _PlanetTile({required this.planet});

  @override
  Widget build(BuildContext context) {
    final glyph = _planetGlyph(planet.name);
    final glyphStyle = GoogleFonts.poppins(
      fontSize: 16,
      fontWeight: FontWeight.w700,
      color: AppColors.cream,
    );
    final nameStyle = GoogleFonts.poppins(
      fontSize: 11,
      fontWeight: FontWeight.w600,
      color: AppColors.cream,
    );
    final altStyle = GoogleFonts.poppins(
      fontSize: 11,
      fontWeight: FontWeight.w400,
      color: AppColors.cream,
    );
    final magStyle = GoogleFonts.poppins(
      fontSize: 10,
      fontWeight: FontWeight.w500,
      color: AppColors.cream90,
    );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.cream08,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            height: 20,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.center,
              child: Text(
                glyph,
                maxLines: 1,
                softWrap: false,
                overflow: TextOverflow.visible,
                style: glyphStyle,
                strutStyle: const StrutStyle(
                  fontSize: 16,
                  height: 1.3,
                  forceStrutHeight: true,
                ),
              ),
            ),
          ),
          const SizedBox(height: 2),
          SizedBox(
            height: 16,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.center,
              child: Text(
                planet.name,
                maxLines: 1,
                softWrap: false,
                overflow: TextOverflow.visible,
                style: nameStyle,
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
            height: 14,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.center,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.arrow_upward,
                    size: 10,
                    color: AppColors.cream90,
                  ),
                  const SizedBox(width: 2),
                  Text(
                    '${planet.altitude.round()}°',
                    maxLines: 1,
                    softWrap: false,
                    overflow: TextOverflow.visible,
                    style: altStyle,
                    strutStyle: const StrutStyle(
                      fontSize: 11,
                      height: 1.3,
                      forceStrutHeight: true,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            height: 13,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.center,
              child: Text(
                'mag ${planet.magnitude.toStringAsFixed(1)}',
                maxLines: 1,
                softWrap: false,
                overflow: TextOverflow.visible,
                style: magStyle,
                strutStyle: const StrutStyle(
                  fontSize: 10,
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

class _AstroEventRow extends StatelessWidget {
  final DateTime now;
  final DateTime? nextFullMoonDate;
  final bool showSeason;

  const _AstroEventRow({
    required this.now,
    this.nextFullMoonDate,
    this.showSeason = true,
  });

  @override
  Widget build(BuildContext context) {
    final sign = currentZodiac(now);
    final event = activeAstroEvent(now, nextFullMoonDate: nextFullMoonDate);
    final style = GoogleFonts.poppins(
      fontSize: 11,
      fontWeight: FontWeight.w700,
      color: AppColors.cream90,
    );

    if (!showSeason && event == null) {
      return const SizedBox.shrink();
    }

    return Row(
      children: [
        if (showSeason) ...[
          SvgPicture.asset(
            'assets/images/zodiac/${sign.toLowerCase()}.svg',
            width: 13,
            height: 13,
            colorFilter: const ColorFilter.mode(
              AppColors.cream90,
              BlendMode.srcIn,
            ),
          ),
          const SizedBox(width: 4),
          Text('$sign season', style: style),
        ],
        if (event != null) ...[
          if (showSeason) Text('  \u00B7  ', style: style),
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
      color: AppColors.cream90,
    );
    final label = event.label;
    final untilIndex = label.indexOf(' until ');
    final isMeteorShower = event.zhr != null;

    final spans = <InlineSpan>[];
    if (isMeteorShower) {
      spans.add(
        WidgetSpan(
          alignment: PlaceholderAlignment.middle,
          child: Padding(
            padding: const EdgeInsets.only(right: 4),
            child: SvgPicture.asset(
              'assets/images/meteor.svg',
              width: 12,
              height: 12,
              colorFilter: const ColorFilter.mode(
                AppColors.cream90,
                BlendMode.srcIn,
              ),
            ),
          ),
        ),
      );
    }
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

  static const _dateLabelStyle = TextStyle(
    color: AppColors.cream75,
    fontSize: 10,
    fontWeight: FontWeight.w600,
  );

  static const _todayLabelStyle = TextStyle(
    color: AppColors.cream95,
    fontSize: 10,
    fontWeight: FontWeight.w700,
  );

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
    const padTop = 32.0;
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

    // 3. Straight horizontal baseline across the chart area
    final lineY = padTop + graphH / 2;
    const lineStartX = padLeft;
    final lineEndX = padLeft + graphW;

    // 4. Area fill under the line
    final fillPath = Path()
      ..moveTo(lineStartX, lineY)
      ..lineTo(lineEndX, lineY)
      ..lineTo(lineEndX, bottomY)
      ..lineTo(lineStartX, bottomY)
      ..close();

    final fillPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          AppColors.cream15,
          Colors.transparent,
        ],
      ).createShader(Rect.fromLTRB(
        padLeft,
        padTop,
        padLeft + graphW,
        bottomY,
      ))
      ..style = PaintingStyle.fill;
    canvas.drawPath(fillPath, fillPaint);

    // 5. Straight line stroke
    canvas.drawLine(
      Offset(lineStartX, lineY),
      Offset(lineEndX, lineY),
      Paint()
        ..color = AppColors.cream55
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );

    // 8. Today position on the line
    final nowX = xForDate(now);

    // 9. Phase-disc markers along the top of the chart area
    if (hasCycle) {
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
          text: TextSpan(text: label, style: _dateLabelStyle),
          textDirection: TextDirection.ltr,
        )..layout();
        final labelX = (cx - tp.width / 2)
            .clamp(0.0, size.width - tp.width);
        const labelY = discTop + discSize + 1;
        tp.paint(canvas, Offset(labelX, labelY));
      }
    }

    // 10. "Today" dot on the line at now
    final dotCenter = Offset(nowX, lineY);

    canvas.drawCircle(
      dotCenter,
      4,
      Paint()
        ..color = AppColors.cream95
        ..style = PaintingStyle.fill,
    );

    // 11. "u r here" label centered below the dot
    final todayLabel = TextPainter(
      text: const TextSpan(
        text: 'u r here',
        style: _todayLabelStyle,
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    var labelX = dotCenter.dx - todayLabel.width / 2;
    if (labelX < 0) labelX = 0;
    if (labelX + todayLabel.width > size.width) {
      labelX = size.width - todayLabel.width;
    }
    final labelY = dotCenter.dy + 6;
    todayLabel.paint(canvas, Offset(labelX, labelY));
  }

  @override
  bool shouldRepaint(covariant _MoonCycleChartPainter old) =>
      now.millisecondsSinceEpoch != old.now.millisecondsSinceEpoch ||
      usno != old.usno;
}
