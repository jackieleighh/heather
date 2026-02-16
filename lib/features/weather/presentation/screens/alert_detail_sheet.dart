import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/weather_alert.dart';

void showAlertDetailSheet(BuildContext context, List<WeatherAlert> alerts) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => AlertDetailSheet(alerts: alerts),
  );
}

class AlertDetailSheet extends StatelessWidget {
  final List<WeatherAlert> alerts;

  const AlertDetailSheet({super.key, required this.alerts});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFF1A1A2E),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // Handle bar
              Padding(
                padding: const EdgeInsets.only(top: 12, bottom: 8),
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.cream.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              // Title
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Row(
                  children: [
                    Text(
                      'Active Alerts',
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: AppColors.cream,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.cream.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${alerts.length}',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.cream.withValues(alpha: 0.8),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Alert list
              Expanded(
                child: ListView.separated(
                  controller: scrollController,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  itemCount: alerts.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 16),
                  itemBuilder: (context, index) =>
                      _AlertDetailCard(alert: alerts[index]),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _AlertDetailCard extends StatelessWidget {
  final WeatherAlert alert;

  const _AlertDetailCard({required this.alert});

  @override
  Widget build(BuildContext context) {
    final timeFormat = DateFormat('MMM d, h:mm a');

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: alert.severity.color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: alert.severity.color.withValues(alpha: 0.25),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Severity badge + event name
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: alert.severity.color.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      alert.severity.icon,
                      color: alert.severity.color,
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      alert.severity.name.toUpperCase(),
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: alert.severity.color,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            alert.event,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.cream,
            ),
          ),
          if (alert.headline.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              alert.headline,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: AppColors.cream.withValues(alpha: 0.7),
              ),
            ),
          ],
          const SizedBox(height: 10),
          // Time range
          Row(
            children: [
              Icon(
                Icons.schedule,
                size: 14,
                color: AppColors.cream.withValues(alpha: 0.5),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  '${timeFormat.format(alert.effective.toLocal())} - ${timeFormat.format(alert.expires.toLocal())}',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppColors.cream.withValues(alpha: 0.5),
                  ),
                ),
              ),
            ],
          ),
          if (alert.senderName.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              alert.senderName,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: AppColors.cream.withValues(alpha: 0.4),
              ),
            ),
          ],
          if (alert.description.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              alert.description,
              style: GoogleFonts.inter(
                fontSize: 13,
                height: 1.5,
                color: AppColors.cream.withValues(alpha: 0.8),
              ),
            ),
          ],
          if (alert.instruction.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.cream.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Instructions',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.cream.withValues(alpha: 0.6),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    alert.instruction,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      height: 1.5,
                      color: AppColors.cream.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (alert.areaDesc.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'Areas: ${alert.areaDesc}',
              style: GoogleFonts.inter(
                fontSize: 11,
                color: AppColors.cream.withValues(alpha: 0.4),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
