import 'package:flutter/material.dart';

import '../../domain/entities/temperature_tier.dart';
import '../../domain/entities/weather_condition.dart';
import '../widgets/animated_background/weather_background.dart';

/// Temporary screen for previewing all weather background combinations.
/// Delete this file and its route when done reviewing.
class WeatherGalleryScreen extends StatelessWidget {
  const WeatherGalleryScreen({super.key});

  static const _tierTemps = {
    TemperatureTier.singleDigits: 5.0,
    TemperatureTier.freezing: 20.0,
    TemperatureTier.jacketWeather: 40.0,
    TemperatureTier.flannelWeather: 60.0,
    TemperatureTier.shortsWeather: 80.0,
    TemperatureTier.scorcher: 100.0,
  };

  static const _tierLabels = {
    TemperatureTier.singleDigits: 'Single Digits',
    TemperatureTier.freezing: 'Freezing',
    TemperatureTier.jacketWeather: 'Jacket',
    TemperatureTier.flannelWeather: 'Flannel',
    TemperatureTier.shortsWeather: 'Shorts',
    TemperatureTier.scorcher: 'Scorcher',
  };

  static final _conditions = WeatherCondition.values
      .where((c) => c != WeatherCondition.unknown)
      .toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Weather Gallery'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 16),
        itemCount: _conditions.length,
        itemBuilder: (context, index) {
          final condition = _conditions[index];
          return _ConditionSection(
            condition: condition,
            tierTemps: _tierTemps,
            tierLabels: _tierLabels,
          );
        },
      ),
    );
  }
}

class _ConditionSection extends StatelessWidget {
  final WeatherCondition condition;
  final Map<TemperatureTier, double> tierTemps;
  final Map<TemperatureTier, String> tierLabels;

  const _ConditionSection({
    required this.condition,
    required this.tierTemps,
    required this.tierLabels,
  });

  String _conditionLabel(WeatherCondition c) {
    return switch (c) {
      WeatherCondition.sunny => 'Sunny',
      WeatherCondition.mostlySunny => 'Mostly Sunny',
      WeatherCondition.partlyCloudy => 'Partly Cloudy',
      WeatherCondition.overcast => 'Overcast',
      WeatherCondition.foggy => 'Foggy',
      WeatherCondition.drizzle => 'Drizzle',
      WeatherCondition.rain => 'Rain',
      WeatherCondition.heavyRain => 'Heavy Rain',
      WeatherCondition.freezingRain => 'Freezing Rain',
      WeatherCondition.snow => 'Snow',
      WeatherCondition.blizzard => 'Blizzard',
      WeatherCondition.thunderstorm => 'Thunderstorm',
      WeatherCondition.hail => 'Hail',
      WeatherCondition.unknown => 'Unknown',
    };
  }

  Widget _buildRow({required bool isDay}) {
    final tiers = tierTemps.keys.toList();
    return SizedBox(
      height: 340,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: tiers.length,
        itemBuilder: (context, index) {
          final tier = tiers[index];
          final temp = tierTemps[tier]!;
          final label = tierLabels[tier]!;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: _WeatherCell(
              condition: condition,
              temperature: temp,
              isDay: isDay,
              label: '$label\n${isDay ? "Day" : "Night"}',
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            _conditionLabel(condition),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        _buildRow(isDay: true),
        const SizedBox(height: 8),
        _buildRow(isDay: false),
        const SizedBox(height: 16),
      ],
    );
  }
}

class _WeatherCell extends StatelessWidget {
  final WeatherCondition condition;
  final double temperature;
  final bool isDay;
  final String label;

  const _WeatherCell({
    required this.condition,
    required this.temperature,
    required this.isDay,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 180,
      height: 320,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          fit: StackFit.expand,
          children: [
            WeatherBackground(
              condition: condition,
              isDay: isDay,
              temperature: temperature,
            ),
            Positioned(
              bottom: 8,
              left: 8,
              right: 8,
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  shadows: [
                    Shadow(blurRadius: 4, color: Colors.black),
                    Shadow(blurRadius: 8, color: Colors.black),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
