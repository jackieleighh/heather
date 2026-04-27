import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/weather_alert.dart';
import '../screens/alert_detail_sheet.dart';

/// Cached text styles to avoid repeated GoogleFonts allocations.
final _poppinsW60014Cream = GoogleFonts.poppins(
  fontSize: 14,
  fontWeight: FontWeight.w600,
  color: AppColors.cream,
);
final _quicksand12Cream85 = GoogleFonts.quicksand(
  fontSize: 12,
  color: AppColors.cream85,
);
final _quicksandW50011Cream70 = GoogleFonts.quicksand(
  fontSize: 11,
  fontWeight: FontWeight.w500,
  color: AppColors.cream70,
);

class AlertCard extends StatelessWidget {
  final List<WeatherAlert> alerts;
  final Color heroColor;

  const AlertCard({super.key, required this.alerts, required this.heroColor});

  @override
  Widget build(BuildContext context) {
    if (alerts.isEmpty) return const SizedBox.shrink();

    final primary = alerts.first;
    final moreCount = alerts.length - 1;

    return GestureDetector(
      onTap: () => showAlertDetailSheet(context, alerts),
      child: RepaintBoundary(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              color: AppColors.cream12,
              child: Row(
                children: [
                  Icon(
                    primary.severity.icon,
                    color: primary.severity.color,
                    size: 22,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(primary.event, style: _poppinsW60014Cream),
                        if (primary.headline.isNotEmpty)
                          Text(
                            primary.headline,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: _quicksand12Cream85,
                          ),
                        if (moreCount > 0)
                          Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Text(
                              '+$moreCount more alert${moreCount == 1 ? '' : 's'}',
                              style: _quicksandW50011Cream70,
                            ),
                          ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right,
                    color: AppColors.cream70,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
