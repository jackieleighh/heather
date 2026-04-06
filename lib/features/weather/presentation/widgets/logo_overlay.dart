import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class LogoOverlay extends StatelessWidget {
  final bool isDay;

  const LogoOverlay({super.key, this.isDay = true});

  static const _dayFilter = ColorFilter.mode(
    Color.fromRGBO(255, 255, 255, 0.15),
    BlendMode.modulate,
  );
  static const _nightFilter = ColorFilter.mode(
    Color.fromRGBO(255, 255, 255, 0.4),
    BlendMode.modulate,
  );

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.sizeOf(context).height;

    return Positioned(
      left: -30,
      bottom: -10,
      child: IgnorePointer(
        child: SvgPicture.asset(
          'assets/images/heather_logo.svg',
          height: screenHeight * 0.5,
          colorFilter: isDay ? _dayFilter : _nightFilter,
        ),
      ),
    );
  }
}
