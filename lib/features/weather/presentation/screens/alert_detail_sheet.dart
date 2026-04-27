import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:heather/core/utils/date_formats.dart';

import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/weather_alert.dart';

/// Cached text styles to avoid repeated GoogleFonts allocations.
final _poppinsW60020Cream = GoogleFonts.poppins(
  fontSize: 20,
  fontWeight: FontWeight.w600,
  color: AppColors.cream,
);
final _quicksandW60013Cream80 = GoogleFonts.quicksand(
  fontSize: 13,
  fontWeight: FontWeight.w600,
  color: AppColors.cream80,
);
final _poppinsW60016Cream = GoogleFonts.poppins(
  fontSize: 16,
  fontWeight: FontWeight.w600,
  color: AppColors.cream,
);
final _quicksand13Cream85 = GoogleFonts.quicksand(
  fontSize: 13,
  color: AppColors.cream85,
);
final _quicksand12Cream70 = GoogleFonts.quicksand(
  fontSize: 12,
  color: AppColors.cream70,
);
final _quicksand12Cream60 = GoogleFonts.quicksand(
  fontSize: 12,
  color: AppColors.cream60,
);
final _quicksand13H15Cream80 = GoogleFonts.quicksand(
  fontSize: 13,
  height: 1.5,
  color: AppColors.cream80,
);
final _poppinsW60012Cream70 = GoogleFonts.poppins(
  fontSize: 12,
  fontWeight: FontWeight.w600,
  color: AppColors.cream70,
);
final _quicksand11Cream60 = GoogleFonts.quicksand(
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
    return GestureDetector(
      onTap: () => Navigator.of(context).pop(),
      behavior: HitTestBehavior.opaque,
      child: DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.4,
        maxChildSize: 0.95,
        builder: (context, scrollController) {
          return GestureDetector(
            onTap: () {},
            child: RepaintBoundary(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                  child: Container(
                    color: heroColor,
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
                              Text('Active Alerts', style: _poppinsW60020Cream),
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
                                  style: _quicksandW60013Cream80,
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
                            separatorBuilder: (_, _) =>
                                const SizedBox(height: 16),
                            itemBuilder: (context, index) =>
                                _AlertDetailCard(alert: alerts[index]),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _AlertDetailCard extends StatelessWidget {
  final WeatherAlert alert;

  const _AlertDetailCard({required this.alert});

  @override
  Widget build(BuildContext context) {
    final timeFormat = AppDateFormats.mmmDhmma;

    return RepaintBoundary(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            padding: const EdgeInsets.all(16),
            color: AppColors.cream12,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Severity badge + event name
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
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
                Text(alert.event, style: _poppinsW60016Cream),
                if (alert.headline.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(alert.headline, style: _quicksand13Cream85),
                ],
                const SizedBox(height: 10),
                // Time range
                Row(
                  children: [
                    const Icon(
                      Icons.schedule,
                      size: 14,
                      color: AppColors.cream70,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        '${timeFormat.format(alert.effective.toLocal())} - ${timeFormat.format(alert.expires.toLocal())}',
                        style: _quicksand12Cream70,
                      ),
                    ),
                  ],
                ),
                if (alert.senderName.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(alert.senderName, style: _quicksand12Cream60),
                ],
                if (alert.description.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(alert.description, style: _quicksand13H15Cream80),
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
                        Text('Instructions', style: _poppinsW60012Cream70),
                        const SizedBox(height: 4),
                        Text(alert.instruction, style: _quicksand13H15Cream80),
                      ],
                    ),
                  ),
                ],
                if (alert.areaDesc.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text('Areas: ${alert.areaDesc}', style: _quicksand11Cream60),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
