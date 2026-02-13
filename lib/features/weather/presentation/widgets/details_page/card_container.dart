import 'package:flutter/material.dart';
import 'package:heather/core/constants/app_colors.dart';

class CardContainer extends StatelessWidget {
  final IconData backgroundIcon;
  final Widget child;

  const CardContainer({
    super.key,
    required this.backgroundIcon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        color: AppColors.cream.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -10,
            top: -10,
            child: Icon(
              backgroundIcon,
              color: AppColors.cream.withValues(alpha: 0.12),
              size: 80,
            ),
          ),
          Padding(padding: const EdgeInsets.all(14), child: child),
        ],
      ),
    );
  }
}
