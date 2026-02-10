import 'package:flutter/material.dart';

import '../../domain/entities/forecast.dart';
import 'location_header.dart';
import 'sassy_quip.dart';
import 'temperature_display.dart';
import 'weather_details.dart';

class CurrentWeatherPage extends StatelessWidget {
  final Forecast forecast;
  final String cityName;
  final String quip;
  final VoidCallback onRefresh;
  final VoidCallback onSettings;

  const CurrentWeatherPage({
    super.key,
    required this.forecast,
    required this.cityName,
    required this.quip,
    required this.onRefresh,
    required this.onSettings,
  });

  @override
  Widget build(BuildContext context) {
    final weather = forecast.current;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Top bar: refresh + settings
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  onPressed: onSettings,
                  icon: Icon(
                    Icons.settings_outlined,
                    color: Colors.white.withValues(alpha: 0.7),
                    size: 26,
                  ),
                ),
              ],
            ),
            const Spacer(flex: 2),
            LocationHeader(cityName: cityName),
            const SizedBox(height: 4),
            TemperatureDisplay(temperature: weather.temperature),
            const SizedBox(height: 24),
            Align(
              alignment: Alignment.centerRight,
              child: SassyQuip(quip: quip),
            ),
            const SizedBox(height: 28),
            WeatherDetails(weather: weather),
            const Spacer(flex: 5),
            // Swipe-up hint
            Center(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Icon(
                  Icons.keyboard_arrow_up,
                  color: Colors.white.withValues(alpha: 0.4),
                  size: 28,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
