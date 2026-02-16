import 'package:flutter/material.dart';
import 'package:heather/core/constants/background_gradients.dart';
import 'package:heather/features/weather/domain/entities/temperature_tier.dart';
import 'package:heather/features/weather/domain/entities/weather_condition.dart';
import 'package:heather/features/weather/presentation/widgets/animated_background/weather_background.dart';

class GradientPreviewGallery extends StatelessWidget {
  const GradientPreviewGallery({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Weather Gradient Preview')),
      body: ListView(
        children: WeatherCondition.values.map((condition) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  '${condition.name.toUpperCase()} day',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
              SizedBox(
                height: 150,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: TemperatureTier.values.map((tier) {
                    final double temp = tier == TemperatureTier.singleDigits
                        ? 0
                        : tier == TemperatureTier.freezing
                        ? 30
                        : tier == TemperatureTier.jacketWeather
                        ? 40
                        : tier == TemperatureTier.flannelWeather
                        ? 60
                        : tier == TemperatureTier.shortsWeather
                        ? 80
                        : tier == TemperatureTier.scorcher
                        ? 90
                        : 0;
                    return Container(
                      width: 120,
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      child: WeatherBackground(
                        condition: condition,
                        isDay: true,
                        temperature: temp,
                      ),
                    );
                  }).toList(),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  '${condition.name.toUpperCase()} night',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
              SizedBox(
                height: 150,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: TemperatureTier.values.map((tier) {
                    final double temp = tier == TemperatureTier.singleDigits
                        ? 0
                        : tier == TemperatureTier.freezing
                        ? 30
                        : tier == TemperatureTier.jacketWeather
                        ? 40
                        : tier == TemperatureTier.flannelWeather
                        ? 60
                        : tier == TemperatureTier.shortsWeather
                        ? 80
                        : tier == TemperatureTier.scorcher
                        ? 90
                        : 0;
                    return Container(
                      width: 120,
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      child: WeatherBackground(
                        condition: condition,
                        isDay: false,
                        temperature: temp,
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}
