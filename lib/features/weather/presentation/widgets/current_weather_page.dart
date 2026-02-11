import 'package:flutter/material.dart';
import 'package:heather/features/weather/presentation/widgets/pulsing_dots.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

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
  final _refreshController = RefreshController();
  static const _overscrollThreshold = 60.0;
  bool _pageChanging = false;

  @override
  void dispose() {
    _scrollController.dispose();
    _refreshController.dispose();
    super.dispose();
  }

  bool _handleScrollNotification(ScrollNotification notification) {
    if (_pageChanging) return false;

    if (notification is ScrollUpdateNotification) {
      final pos = notification.metrics;

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

  Future<void> _onRefresh() async {
    final success = await widget.onRefresh();
    if (success) {
      _refreshController.refreshCompleted();
    } else {
      _refreshController.refreshFailed();
    }
  }

  @override
  Widget build(BuildContext context) {
    final weather = widget.forecast.current;
    final textStyle = Theme.of(context).textTheme.bodySmall?.copyWith(
      color: AppColors.cream.withValues(alpha: 0.7),
    );

    return SafeArea(
      child: NotificationListener<ScrollNotification>(
        onNotification: _handleScrollNotification,
        child: SmartRefresher(
          controller: _refreshController,
          enablePullDown: true,
          enablePullUp: false,
          onRefresh: _onRefresh,
          header: CustomHeader(
            completeDuration: const Duration(milliseconds: 1200),
            builder: (context, mode) {
              Widget child;
              if (mode == RefreshStatus.completed) {
                child = Text('All caught up', style: textStyle);
              } else if (mode == RefreshStatus.failed) {
                child = Text('Yikes! Couldn\'t refresh', style: textStyle);
              } else {
                child = const PulsingDots();
              }
              return SizedBox(height: 60, child: Center(child: child));
            },
          ),
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
                      TemperatureDisplay(
                        temperature: weather.temperature,
                        high: widget.forecast.daily.first.temperatureMax,
                        low: widget.forecast.daily.first.temperatureMin,
                      ),
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
      ),
    );
  }
}
