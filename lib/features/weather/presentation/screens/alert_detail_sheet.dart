import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:heather/core/utils/date_formats.dart';

import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/weather_alert.dart';

/// Cached text styles to avoid repeated GoogleFonts allocations.
final _poppinsW600_20_cream = GoogleFonts.poppins(
  fontSize: 20,
  fontWeight: FontWeight.w600,
  color: AppColors.cream,
);
final _quicksandW600_13_cream80 = GoogleFonts.quicksand(
  fontSize: 13,
  fontWeight: FontWeight.w600,
  color: AppColors.cream80,
);
final _poppinsW600_16_cream = GoogleFonts.poppins(
  fontSize: 16,
  fontWeight: FontWeight.w600,
  color: AppColors.cream,
);
final _quicksand13_cream85 = GoogleFonts.quicksand(
  fontSize: 13,
  color: AppColors.cream85,
);
final _quicksand12_cream70 = GoogleFonts.quicksand(
  fontSize: 12,
  color: AppColors.cream70,
);
final _quicksand12_cream60 = GoogleFonts.quicksand(
  fontSize: 12,
  color: AppColors.cream60,
);
final _quicksand13_h15_cream80 = GoogleFonts.quicksand(
  fontSize: 13,
  height: 1.5,
  color: AppColors.cream80,
);
final _poppinsW600_12_cream70 = GoogleFonts.poppins(
  fontSize: 12,
  fontWeight: FontWeight.w600,
  color: AppColors.cream70,
);
final _quicksand11_cream60 = GoogleFonts.quicksand(
  fontSize: 11,
  color: AppColors.cream60,
);

void showAlertDetailSheet(BuildContext context, List<WeatherAlert> alerts) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => AlertDetailSheet(alerts: alerts),
  );
}

class AlertDetailSheet extends ConsumerWidget {
  final List<WeatherAlert> alerts;

  const AlertDetailSheet({super.key, required this.alerts});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const heroColor = AppColors.magenta;
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: heroColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
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
                    color: AppColors.cream30,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              // Title
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    Text(
                      'Active Alerts',
                      style: _poppinsW600_20_cream,
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.cream15,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${alerts.length}',
                        style: _quicksandW600_13_cream80,
                      ),
                    ),
                  ],
                ),
              ),
              // Alert list
              Expanded(
                child: ListView.separated(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 8,
                  ),
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
    final timeFormat = AppDateFormats.mmmDhmma;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: alert.severity.color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: alert.severity.color.withValues(alpha: 0.3),
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
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: alert.severity.color.withValues(alpha: 0.3),
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
                      style: GoogleFonts.quicksand(
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
            style: _poppinsW600_16_cream,
          ),
          if (alert.headline.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              alert.headline,
              style: _quicksand13_cream85,
            ),
          ],
          const SizedBox(height: 10),
          // Time range
          Row(
            children: [
              Icon(
                Icons.schedule,
                size: 14,
                color: AppColors.cream70,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  '${timeFormat.format(alert.effective.toLocal())} - ${timeFormat.format(alert.expires.toLocal())}',
                  style: _quicksand12_cream70,
                ),
              ),
            ],
          ),
          if (alert.senderName.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              alert.senderName,
              style: _quicksand12_cream60,
            ),
          ],
          if (alert.description.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              alert.description,
              style: _quicksand13_h15_cream80,
            ),
          ],
          if (alert.instruction.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.cream06,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Instructions',
                    style: _poppinsW600_12_cream70,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    alert.instruction,
                    style: _quicksand13_h15_cream80,
                  ),
                ],
              ),
            ),
          ],
          if (alert.areaDesc.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'Areas: ${alert.areaDesc}',
              style: _quicksand11_cream60,
            ),
          ],
        ],
      ),
    );
  }
}
