import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:heather/core/constants/app_colors.dart';
import 'package:heather/core/utils/moon_phase.dart';
import 'package:intl/intl.dart';
import 'package:weather_icons/weather_icons.dart';
import './card_container.dart';

class MoonCard extends StatelessWidget {
  final DateTime now;

  const MoonCard({super.key, required this.now});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final phase = getMoonPhase(now);
    final illumination = moonIllumination(now).round();
    final nextFull = nextFullMoon(now);
    final nextNew = nextNewMoon(now);
    final dateFmt = DateFormat('MMM d');

    final fullFirst = nextFull.isBefore(nextNew);
    final first = fullFirst ? nextFull : nextNew;
    final second = fullFirst ? nextNew : nextFull;
    final firstLabel = fullFirst ? 'Full' : 'New';
    final secondLabel = fullFirst ? 'New' : 'Full';
    final firstIcon = fullFirst
        ? WeatherIcons.moon_full
        : WeatherIcons.moon_new;
    final secondIcon = fullFirst
        ? WeatherIcons.moon_new
        : WeatherIcons.moon_full;

    return CardContainer(
      backgroundIcon: moonPhaseIcon(now),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                moonPhaseIcon(now),
                size: 18,
                color: AppColors.cream.withValues(alpha: 0.9),
              ),
              const SizedBox(width: 8),
              Text(
                'Moon',
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    moonPhaseLabel(phase),
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.cream,
                    ),
                  ),
                  Text(
                    '$illumination% illuminated',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.cream.withValues(alpha: 0.9),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 2),
          Expanded(
            child: Row(
              children: [
                Icon(
                  firstIcon,
                  size: 13,
                  color: AppColors.cream.withValues(alpha: 0.95),
                ),
                const SizedBox(width: 4),
                Text(
                  _relativeLabel(firstLabel, first, now, dateFmt),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(width: 12),
                Icon(
                  secondIcon,
                  size: 13,
                  color: AppColors.cream.withValues(alpha: 0.95),
                ),
                const SizedBox(width: 4),
                Text(
                  _relativeLabel(secondLabel, second, now, dateFmt),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
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
