import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/forecast.dart';
import 'current_weather_page.dart';
import 'details_page/details_page.dart';
import 'hourly_forecast_page.dart';
import 'radar_page.dart';
import 'weekly_forecast_page.dart';

class VerticalForecastPager extends StatefulWidget {
  final Forecast forecast;
  final String cityName;
  final String quip;
  final double latitude;
  final double longitude;
  final Future<bool> Function() onRefresh;
  final VoidCallback onSettings;

  const VerticalForecastPager({
    super.key,
    required this.forecast,
    required this.cityName,
    required this.quip,
    required this.latitude,
    required this.longitude,
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
    return Stack(
      fit: StackFit.expand,
      children: [
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
              parentPageController: _pageController,
            ),
            DetailsPage(
              forecast: widget.forecast,
              latitude: widget.latitude,
              longitude: widget.longitude,
            ),
            HourlyForecastPage(
              hourly: widget.forecast.hourly,
              parentPageController: _pageController,
            ),
            WeeklyForecastPage(
              daily: widget.forecast.daily,
              utcOffsetSeconds: widget.forecast.utcOffsetSeconds,
            ),
            RadarPage(latitude: widget.latitude, longitude: widget.longitude),
          ],
        ),

        // Page indicator dots
        Positioned(
          right: 10,
          top: 0,
          bottom: 0,
          child: Center(
            child: Container(
              padding: const EdgeInsets.only(left: 10),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(5, (index) {
                  final isActive = index == _currentPage;
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 3),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 6,
                      height: isActive ? 18 : 6,
                      decoration: BoxDecoration(
                        color: isActive
                            ? AppColors.cream.withValues(alpha: 0.9)
                            : AppColors.cream.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
