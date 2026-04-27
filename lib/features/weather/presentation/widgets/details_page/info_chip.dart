import 'package:flutter/material.dart';
import 'package:heather/core/constants/app_colors.dart';

/// Cached text styles to avoid repeated GoogleFonts allocations.
const _poppinsW50010Cream60 = TextStyle(fontFamily: 'Poppins',
  fontSize: 10,
  fontWeight: FontWeight.w500,
  color: AppColors.cream60,
);
const _poppinsBold12 = TextStyle(fontFamily: 'Poppins',
  fontSize: 12,
  fontWeight: FontWeight.w700,
  color: AppColors.cream,
);

/// Small card used in the 2x2 info grids on expanded detail cards.
class InfoChip extends StatelessWidget {
  final IconData? icon;
  final Widget? iconWidget;
  final String label;
  final String value;

  const InfoChip({
    super.key,
    this.icon,
    this.iconWidget,
    required this.label,
    required this.value,
  }) : assert(
         icon != null || iconWidget != null,
         'Either icon or iconWidget must be provided',
       );

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.cream08,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              iconWidget ?? Icon(icon, size: 10, color: AppColors.cream60),
              const SizedBox(width: 4),
              Text(label, style: _poppinsW50010Cream60),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            value,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            style: _poppinsBold12,
          ),
        ],
      ),
    );
  }
}
