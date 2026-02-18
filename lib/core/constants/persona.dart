import 'dart:ui';

import 'package:heather/core/constants/aurelia_quips.dart';

import 'app_colors.dart';
import 'heather_night_quips.dart';
import 'jade_night_quips.dart';
import 'jade_quips.dart';
import 'luna_quips.dart';
import 'heather_quips.dart';
import '../../features/weather/domain/entities/temperature_tier.dart';
import '../../features/weather/domain/entities/weather_condition.dart';

enum Persona {
  heather(
    displayName: 'Heather',
    initial: 'H',
    toneLabel: 'Clean sass',
    altToneLabel: 'Explicit & unhinged',
  ),
  jade(
    displayName: 'Jade',
    initial: 'J',
    toneLabel: 'Chill af',
    altToneLabel: 'Cynical & explicit',
  );
  // TODO - add back
  // luna(
  //   displayName: 'Luna',
  //   initial: 'L',
  //   toneLabel: 'Happy & quirky',
  //   altToneLabel: 'Sad & spacey',
  //   toneSubtitle: 'Spacey, funny, accidentally wise.',
  //   altToneSubtitle: 'Still weird, just having an off day.',
  //   introLine: "I'm Luna. Did you see that UFO?",
  // ),
  // aurelia(
  //   displayName: 'Aurelia',
  //   initial: 'A',
  //   toneLabel: 'Witchy & cool',
  //   altToneLabel: 'Edgy af',
  //   toneSubtitle: 'Witchy, earthy, and chill.',
  //   altToneSubtitle: 'Ready to hex someone.',
  //   introLine: "I'm Aurelia. The stars are my besties.",
  // );

  const Persona({
    required this.displayName,
    required this.initial,
    required this.toneLabel,
    required this.altToneLabel,
  });

  final String displayName;
  final String initial;
  final String toneLabel;
  final String altToneLabel;

  Color get heroColor => switch (this) {
    Persona.heather => AppColors.magenta,
    Persona.jade => AppColors.teal,
    // TODO
    // Persona.luna => AppColors.chartreuse,
    // Persona.aurelia => AppColors.vibrantPurple,
  };

  /// Returns the correct local quip map for this persona and tone.
  Map<WeatherCondition, Map<TemperatureTier, List<String>>> quipMap({
    required bool altTone,
    required bool isDay,
  }) {
    return switch (this) {
      Persona.heather =>
        isDay
            ? (altTone ? HeatherQuips.explicitQuips : HeatherQuips.quips)
            : (altTone
                  ? HeatherNightQuips.explicitQuips
                  : HeatherNightQuips.quips),
      Persona.jade =>
        isDay
            ? (altTone ? JadeQuips.cynicalQuips : JadeQuips.quips)
            : (altTone ? JadeNightQuips.cynicalQuips : JadeNightQuips.quips),
      // TODO
      // Persona.luna => altTone ? LunaQuips.sadQuips : LunaQuips.quips,
      // Persona.aurelia => altTone ? AureliaQuips.edgyQuips : AureliaQuips.quips,
    };
  }
}
