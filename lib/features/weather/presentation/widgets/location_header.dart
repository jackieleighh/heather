import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_colors.dart';

class LocationHeader extends StatelessWidget {
  final String cityName;

  const LocationHeader({super.key, required this.cityName});

  @override
  Widget build(BuildContext context) {
    return Row(
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
    );
  }
}
