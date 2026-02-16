import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'weather_alert.freezed.dart';

enum AlertSeverity {
  extreme,
  severe,
  moderate,
  minor,
  unknown;

  factory AlertSeverity.fromString(String? value) {
    return switch (value?.toLowerCase()) {
      'extreme' => AlertSeverity.extreme,
      'severe' => AlertSeverity.severe,
      'moderate' => AlertSeverity.moderate,
      'minor' => AlertSeverity.minor,
      _ => AlertSeverity.unknown,
    };
  }

  Color get color => switch (this) {
        AlertSeverity.extreme => const Color(0xFFEF4444),
        AlertSeverity.severe => const Color(0xFFF97316),
        AlertSeverity.moderate => const Color(0xFFFBBF24),
        AlertSeverity.minor => const Color(0xFF94A3B8),
        AlertSeverity.unknown => const Color(0xFF94A3B8),
      };

  IconData get icon => switch (this) {
        AlertSeverity.extreme => Icons.crisis_alert,
        AlertSeverity.severe => Icons.warning_amber_rounded,
        AlertSeverity.moderate => Icons.info_outline,
        AlertSeverity.minor => Icons.info_outline,
        AlertSeverity.unknown => Icons.info_outline,
      };

  int get sortOrder => switch (this) {
        AlertSeverity.extreme => 0,
        AlertSeverity.severe => 1,
        AlertSeverity.moderate => 2,
        AlertSeverity.minor => 3,
        AlertSeverity.unknown => 4,
      };
}

@freezed
class WeatherAlert with _$WeatherAlert {
  const factory WeatherAlert({
    required String id,
    required String event,
    required AlertSeverity severity,
    required String headline,
    @Default('') String description,
    @Default('') String instruction,
    required DateTime effective,
    required DateTime expires,
    @Default('') String senderName,
    @Default('') String areaDesc,
  }) = _WeatherAlert;
}
