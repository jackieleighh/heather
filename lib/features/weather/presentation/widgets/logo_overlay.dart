import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';

class LogoOverlay extends ConsumerWidget {
  // final Persona? personaOverride;

  const LogoOverlay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // final persona =
    //     personaOverride ?? ref.watch(settingsProvider.select((s) => s.persona));
    final screenHeight = MediaQuery.sizeOf(context).height;

    return Positioned(
      left: -20,
      bottom: 0,
      child: IgnorePointer(
        child: Opacity(
          opacity: 0.2,
          child: SvgPicture.asset(
            'assets/images/heather_logo.svg',
            height: screenHeight * 0.5,
          ),
          // Persona switching commented out for now:
          // child: persona == Persona.jade
          //     ? SvgPicture.asset(
          //         'assets/images/jade_logo.svg',
          //         height: screenHeight * 0.5,
          //       )
          //     : SvgPicture.asset(
          //         'assets/images/heather_logo.svg',
          //         height: screenHeight * 0.5,
          //       ),
        ),
      ),
    );
  }
}
