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
    toneLabel: 'Clean sarcasm',
    altToneLabel: 'Explicit & unhinged',
    toneSubtitle: 'Same sass, no swearing.',
    altToneSubtitle: "I won't hold back.",
    introLine: "I'm Heather. With the weather, I guess.",
  ),
  jade(
    displayName: 'Jade',
    initial: 'J',
    toneLabel: 'Chill af',
    altToneLabel: 'Cynical & explicit',
    toneSubtitle: 'Laid back, good energy.',
    altToneSubtitle: 'Over it, needs a joint.',
    introLine: "I'm Jade. Here with the vibes.",
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
    required this.toneSubtitle,
    required this.altToneSubtitle,
    required this.introLine,
  });

  final String displayName;
  final String initial;
  final String toneLabel;
  final String altToneLabel;
  final String toneSubtitle;
  final String altToneSubtitle;
  final String introLine;

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
      Persona.jade => isDay
          ? (altTone ? JadeQuips.cynicalQuips : JadeQuips.quips)
          : (altTone ? JadeNightQuips.cynicalQuips : JadeNightQuips.quips),
      // TODO
      // Persona.luna => altTone ? LunaQuips.sadQuips : LunaQuips.quips,
      // Persona.aurelia => altTone ? AureliaQuips.edgyQuips : AureliaQuips.quips,
    };
  }
}
