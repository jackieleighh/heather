import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';

import '../../../../core/constants/persona.dart';
import '../providers/settings_provider.dart';

class LogoOverlay extends ConsumerWidget {
  const LogoOverlay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final persona = ref.watch(settingsProvider.select((s) => s.persona));
    final screenHeight = MediaQuery.sizeOf(context).height;

    return Positioned(
      left: -80,
      bottom: 0,
      child: IgnorePointer(
        child: Opacity(
          opacity: 0.3,
          child: persona == Persona.luna
              ? SvgPicture.asset(
                  'assets/images/luna_logo.svg',
                  height: screenHeight * 0.5,
                )
              : persona == Persona.jade
              ? SvgPicture.asset(
                  'assets/images/jade_logo.svg',
                  height: screenHeight * 0.5,
                )
              : persona == Persona.aurelia
              ? SvgPicture.asset(
                  'assets/images/aurelia_logo.svg',
                  height: screenHeight * 0.5,
                )
              : SvgPicture.asset(
                  'assets/images/heather_logo.svg',
                  height: screenHeight * 0.5,
                ),
        ),
      ),
    );
  }
}
