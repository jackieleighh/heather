import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';

class LocationHeader extends StatelessWidget {
  final String cityName;
  final DateTime localTime;

  const LocationHeader({
    super.key,
    required this.cityName,
    required this.localTime,
  });

  @override
  Widget build(BuildContext context) {
    final timeString = DateFormat('h:mm a').format(localTime);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          timeString,
          style: GoogleFonts.quicksand(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: AppColors.cream.withValues(alpha: 0.6),
          ),
        ),
        const SizedBox(height: 2),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.location_on_outlined,
              color: AppColors.cream,
              size: 20,
            ),
            const SizedBox(width: 4),
            Text(
              cityName,
              style: GoogleFonts.quicksand(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppColors.cream,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
