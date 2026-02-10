import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class LogoOverlay extends StatelessWidget {
  const LogoOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.sizeOf(context).height;
    return Positioned(
      left: -40,
      bottom: 0,
      child: IgnorePointer(
        child: Opacity(
          opacity: 0.12,
          child: SvgPicture.asset(
            'assets/images/heather_logo.svg',
            height: screenHeight * 0.45,
          ),
        ),
      ),
    );
  }
}
