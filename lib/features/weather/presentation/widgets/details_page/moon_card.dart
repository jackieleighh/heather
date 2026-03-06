import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:heather/core/constants/app_colors.dart';
import 'package:heather/core/utils/astro_events.dart';
import 'package:heather/core/utils/moon_phase.dart';
import 'package:intl/intl.dart';
import 'package:weather_icons/weather_icons.dart';
import '../../providers/moon_data_provider.dart';
import '../../providers/visible_planets_provider.dart';
import './card_container.dart';

class MoonCard extends ConsumerWidget {
  final DateTime now;
  final double latitude;
  final double longitude;
  final int utcOffsetSeconds;

  const MoonCard({
    super.key,
    required this.now,
    required this.latitude,
    required this.longitude,
    required this.utcOffsetSeconds,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final dateFmt = DateFormat('MMM d');

    final usno = ref
        .watch(
          moonDataProvider((
            lat: latitude,
            lon: longitude,
            utcOffsetSeconds: utcOffsetSeconds,
          )),
        )
        .valueOrNull;

    if (usno == null) {
      return CardContainer(
        backgroundIcon: WeatherIcons.moon_full,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
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
                    shadows: [
                      const Shadow(color: Color(0x28000000), blurRadius: 6),
                    ],
                  ),
                ),
              ],
            ),
            const Spacer(),
            _VisiblePlanetsRow(latitude: latitude, longitude: longitude),
            _AstroEventRow(now: now),
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

    return CardContainer(
      backgroundIcon: icon,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(
                icon,
                size: 18,
                color: AppColors.cream.withValues(alpha: 0.9),
              ),
              const SizedBox(width: 8),
              Text(
                'Sky',
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
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
                  if (phaseDatesText.isNotEmpty)
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
          ),
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

    // 1. Draw base lit circle
    final litPaint = Paint()
      ..color = AppColors.cream.withValues(alpha: 0.85)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius, litPaint);

    // 2. Draw shadow
    // fraction: 0 = new moon (full shadow), 0.5 = full moon (no shadow)
    // Near full moon — skip shadow entirely
    if (fraction > 0.02 && fraction < 0.98) {
      // terminatorX: +1 at new moon, 0 at quarters, -1 at full moon
      final terminatorX = math.cos(2 * math.pi * fraction);
      final absTerminatorX = terminatorX.abs();

      final shadowPath = Path();
      final waxing = fraction < 0.5;

      if (waxing) {
        // Shadow on the left side
        // Semicircular arc along left edge (from top to bottom)
        shadowPath.addArc(
          Rect.fromCircle(center: center, radius: radius),
          -math.pi / 2, // start at top
          -math.pi, // sweep left semicircle (top -> left -> bottom)
        );
        // Elliptical terminator arc connecting bottom back to top
        final terminatorRect = Rect.fromCenter(
          center: center,
          width: absTerminatorX * radius * 2,
          height: radius * 2,
        );
        if (fraction < 0.25) {
          // Crescent: terminator bulges left (same side as shadow)
          shadowPath.addArc(terminatorRect, math.pi / 2, -math.pi);
        } else {
          // Gibbous: terminator bulges right (opposite side)
          shadowPath.addArc(terminatorRect, math.pi / 2, math.pi);
        }
      } else {
        // Waning: shadow on the right side
        // Semicircular arc along right edge (from top to bottom)
        shadowPath.addArc(
          Rect.fromCircle(center: center, radius: radius),
          -math.pi / 2, // start at top
          math.pi, // sweep right semicircle (top -> right -> bottom)
        );
        // Elliptical terminator arc connecting bottom back to top
        final terminatorRect = Rect.fromCenter(
          center: center,
          width: absTerminatorX * radius * 2,
          height: radius * 2,
        );
        if (fraction > 0.75) {
          // Crescent: terminator bulges right (same side as shadow)
          shadowPath.addArc(terminatorRect, math.pi / 2, math.pi);
        } else {
          // Gibbous: terminator bulges left (opposite side)
          shadowPath.addArc(terminatorRect, math.pi / 2, -math.pi);
        }
      }

      final shadowPaint = Paint()
        ..color = Colors.black.withValues(alpha: 0.6)
        ..style = PaintingStyle.fill;

      // Clip to circle to avoid overflow
      canvas.save();
      canvas.clipPath(
        Path()..addOval(Rect.fromCircle(center: center, radius: radius)),
      );
      canvas.drawPath(shadowPath, shadowPaint);
      canvas.restore();
    } else if (fraction <= 0.02 || fraction >= 0.98) {
      // Near new moon — full shadow
      final shadowPaint = Paint()
        ..color = Colors.black.withValues(alpha: 0.6)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(center, radius, shadowPaint);
    }

    // 3. Subtle outline
    final outlinePaint = Paint()
      ..color = AppColors.cream.withValues(alpha: 0.25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawCircle(center, radius, outlinePaint);
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
// Supporting widgets (unchanged)
// ---------------------------------------------------------------------------

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
                  names.join(' \u00B7 '),
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
      loading: () => const SizedBox.shrink(),
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
            child: _buildEventLabel(event.label, style),
          ),
        ],
      ],
    );
  }

  Widget _buildEventLabel(String label, TextStyle style) {
    final untilIndex = label.indexOf(' until ');
    if (untilIndex == -1) {
      return Text(label, style: style, overflow: TextOverflow.ellipsis);
    }
    final boldPart = label.substring(0, untilIndex);
    final lightPart = label.substring(untilIndex);
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(text: boldPart, style: style),
          TextSpan(
            text: lightPart,
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.w400,
              color: AppColors.cream.withValues(alpha: 0.9),
            ),
          ),
        ],
      ),
      overflow: TextOverflow.ellipsis,
    );
  }
}
