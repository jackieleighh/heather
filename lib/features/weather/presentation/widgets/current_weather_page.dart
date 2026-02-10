import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/forecast.dart';
import 'location_header.dart';
import 'sassy_quip.dart';
import 'temperature_display.dart';
import 'weather_details.dart';

class CurrentWeatherPage extends StatefulWidget {
  final Forecast forecast;
  final String cityName;
  final String quip;
  final Future<bool> Function() onRefresh;
  final VoidCallback onSettings;
  final PageController parentPageController;

  const CurrentWeatherPage({
    super.key,
    required this.forecast,
    required this.cityName,
    required this.quip,
    required this.onRefresh,
    required this.onSettings,
    required this.parentPageController,
  });

  @override
  State<CurrentWeatherPage> createState() => _CurrentWeatherPageState();
}

class _CurrentWeatherPageState extends State<CurrentWeatherPage> {
  final _scrollController = ScrollController();
  static const _overscrollThreshold = 60.0;
  bool _pageChanging = false;
  bool _refreshing = false;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  bool _handleScrollNotification(ScrollNotification notification) {
    if (_pageChanging || _refreshing) return false;

    if (notification is ScrollUpdateNotification) {
      final pos = notification.metrics;

      // At top and pulling down → refresh
      if (pos.pixels < pos.minScrollExtent - _overscrollThreshold) {
        _refreshing = true;
        _scrollController.jumpTo(0);
        widget.onRefresh().then((_) {
          _refreshing = false;
        });
        return true;
      }

      // At bottom and swiping up → next page
      if (pos.pixels > pos.maxScrollExtent + _overscrollThreshold) {
        _pageChanging = true;
        widget.parentPageController
            .nextPage(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            )
            .then((_) => _pageChanging = false);
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
        return true;
      }
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    final weather = widget.forecast.current;

    return SafeArea(
      child: NotificationListener<ScrollNotification>(
        onNotification: _handleScrollNotification,
        child: CustomScrollView(
          controller: _scrollController,
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverFillRemaining(
              hasScrollBody: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const SizedBox(height: 56),
                    const Spacer(flex: 2),
                    LocationHeader(cityName: widget.cityName),
                    const SizedBox(height: 4),
                    TemperatureDisplay(temperature: weather.temperature),
                    const SizedBox(height: 24),
                    Align(
                      alignment: Alignment.centerRight,
                      child: SassyQuip(quip: widget.quip),
                    ),
                    const SizedBox(height: 28),
                    WeatherDetails(weather: weather),
                    const Spacer(flex: 5),
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
