import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/weather_alert.dart';
import '../screens/alert_detail_sheet.dart';

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
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: primary.severity.color.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: primary.severity.color.withValues(alpha: 0.4),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 12,
            ),
          ],
        ),
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
                  Text(
                    primary.event,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.cream,
                    ),
                  ),
                  if (primary.headline.isNotEmpty)
                    Text(
                      primary.headline,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppColors.cream.withValues(alpha: 0.7),
                      ),
                    ),
                  if (moreCount > 0)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        '+$moreCount more alert${moreCount == 1 ? '' : 's'}',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: AppColors.cream.withValues(alpha: 0.5),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: AppColors.cream.withValues(alpha: 0.5),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
