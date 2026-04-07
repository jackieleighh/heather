import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/smooth_page_physics.dart';
import '../../domain/entities/forecast.dart';
import '../../domain/entities/weather_alert.dart';
import 'current_weather_page.dart';
import 'details_page/details_page.dart';
import 'radar_page.dart';
import 'weekly_forecast_page.dart';

class VerticalForecastPager extends StatefulWidget {
  final Forecast forecast;
  final String cityName;
  final String quip;
  final double latitude;
  final double longitude;
  final bool isUs;
  final List<WeatherAlert> alerts;
  final Future<bool> Function() onRefresh;
  final VoidCallback onSettings;

  const VerticalForecastPager({
    super.key,
    required this.forecast,
    required this.cityName,
    required this.quip,
    required this.latitude,
    required this.longitude,
    this.isUs = true,
    this.alerts = const [],
    required this.onRefresh,
    required this.onSettings,
  });

  @override
  State<VerticalForecastPager> createState() => VerticalForecastPagerState();
}

class VerticalForecastPagerState extends State<VerticalForecastPager> {
  final _pageController = PageController();

  void jumpToFirst() {
    if (_pageController.hasClients) {
      _pageController.jumpToPage(0);
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      CurrentWeatherPage(
        forecast: widget.forecast,
        cityName: widget.cityName,
        quip: widget.quip,
        latitude: widget.latitude,
        longitude: widget.longitude,
        alerts: widget.alerts,
        onRefresh: widget.onRefresh,
        onSettings: widget.onSettings,
        parentPageController: _pageController,
      ),
      DetailsPage(
        forecast: widget.forecast,
        latitude: widget.latitude,
        longitude: widget.longitude,
      ),
      WeeklyForecastPage(
        forecast: widget.forecast,
        latitude: widget.latitude,
        longitude: widget.longitude,
      ),
      if (widget.isUs)
        RadarPage(latitude: widget.latitude, longitude: widget.longitude),
    ];

    return Stack(
      fit: StackFit.expand,
      children: [
        // Vertical PageView
        RepaintBoundary(
          child: PageView.builder(
            controller: _pageController,
            scrollDirection: Axis.vertical,
            physics: const SmoothPageScrollPhysics(),
            itemCount: pages.length,
            itemBuilder: (context, index) => pages[index],
          ),
        ),

        // Page indicator dots
        Positioned(
          right: 10,
          top: 0,
          bottom: 0,
          child: Center(
            child: _VerticalPageIndicator(
              controller: _pageController,
              count: pages.length,
            ),
          ),
        ),
      ],
    );
  }
}

class _VerticalPageIndicator extends StatefulWidget {
  final PageController controller;
  final int count;

  const _VerticalPageIndicator({
    required this.controller,
    required this.count,
  });

  @override
  State<_VerticalPageIndicator> createState() => _VerticalPageIndicatorState();
}

class _VerticalPageIndicatorState extends State<_VerticalPageIndicator> {
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onPageChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onPageChanged);
    super.dispose();
  }

  void _onPageChanged() {
    final page = widget.controller.page?.round() ?? 0;
    if (page != _currentPage) {
      setState(() => _currentPage = page);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(widget.count, (index) {
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
    );
  }
}
