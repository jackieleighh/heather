import 'package:flutter/material.dart';
import 'package:heather/core/constants/app_colors.dart';

const _borderRadius = BorderRadius.all(Radius.circular(20));

final _cardDecoration = BoxDecoration(
  color: AppColors.cream40,
  borderRadius: _borderRadius,
  boxShadow: const [BoxShadow(color: AppColors.black12, blurRadius: 12)],
);

class CardContainer extends StatelessWidget {
  final IconData backgroundIcon;
  final Widget child;
  final bool compact;
  final bool flat;

  const CardContainer({
    super.key,
    required this.backgroundIcon,
    required this.child,
    this.compact = false,
    this.flat = false,
  });

  @override
  Widget build(BuildContext context) {
    if (flat) {
      return child;
    }
    return ClipRRect(
      borderRadius: _borderRadius,
      child: Container(
        decoration: _cardDecoration,
        child: Stack(
          children: [
            if (!compact)
              Positioned(
                right: -10,
                top: -10,
                child: Icon(backgroundIcon, color: AppColors.cream25, size: 80),
              ),
            Positioned.fill(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                child: child,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
