import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class LogoOverlay extends StatelessWidget {
  final bool isDay;

  const LogoOverlay({super.key, this.isDay = true});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.sizeOf(context).height;

    return Positioned(
      left: -30,
      bottom: -10,
      child: IgnorePointer(
        child: Opacity(
          opacity: isDay ? 0.15 : 0.4,
          child: SvgPicture.asset(
            'assets/images/heather_logo.svg',
            height: screenHeight * 0.5,
          ),
        ),
      ),
    );
  }
}
