import 'package:flutter/material.dart';

import '../../domain/entities/forecast.dart';
import 'animated_background/weather_background.dart';
import 'current_weather_page.dart';
import 'hourly_forecast_page.dart';
import 'weekly_forecast_page.dart';

class VerticalForecastPager extends StatefulWidget {
  final Forecast forecast;
  final String cityName;
  final String quip;
  final VoidCallback onRefresh;
  final VoidCallback onSettings;

  const VerticalForecastPager({
    super.key,
    required this.forecast,
    required this.cityName,
    required this.quip,
    required this.onRefresh,
    required this.onSettings,
  });

  @override
  State<VerticalForecastPager> createState() => _VerticalForecastPagerState();
}

class _VerticalForecastPagerState extends State<VerticalForecastPager> {
  final _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final weather = widget.forecast.current;

    return Stack(
      fit: StackFit.expand,
      children: [
        // Animated background behind all pages
        WeatherBackground(condition: weather.condition, isDay: weather.isDay),

        // Gradient scrim for text readability
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.15),
                  Colors.black.withValues(alpha: 0.05),
                  Colors.black.withValues(alpha: 0.25),
                ],
              ),
            ),
          ),
        ),

        // Vertical PageView
        PageView(
          controller: _pageController,
          scrollDirection: Axis.vertical,
          physics: const ClampingScrollPhysics(),
          onPageChanged: (page) => setState(() => _currentPage = page),
          children: [
            CurrentWeatherPage(
              forecast: widget.forecast,
              cityName: widget.cityName,
              quip: widget.quip,
              onRefresh: widget.onRefresh,
              onSettings: widget.onSettings,
            ),
            HourlyForecastPage(
              hourly: widget.forecast.hourly,
              parentPageController: _pageController,
            ),
            WeeklyForecastPage(daily: widget.forecast.daily),
          ],
        ),

        // Page indicator dots
        Positioned(
          right: 12,
          top: 0,
          bottom: 0,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(3, (index) {
                final isActive = index == _currentPage;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 6,
                    height: isActive ? 18 : 6,
                    decoration: BoxDecoration(
                      color: isActive
                          ? Colors.white.withValues(alpha: 0.8)
                          : Colors.white.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ],
    );
  }
}
