import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/forecast.dart';
import '../../domain/entities/weather_alert.dart';
import 'alert_card.dart';
import 'location_header.dart';
import 'pulsing_dots.dart';
import 'sassy_quip.dart';
import 'temperature_display.dart';

class CurrentWeatherPage extends StatefulWidget {
  final Forecast forecast;
  final String cityName;
  final String quip;
  final double latitude;
  final double longitude;
  final List<WeatherAlert> alerts;
  final Future<bool> Function() onRefresh;
  final VoidCallback onSettings;
  final PageController parentPageController;

  const CurrentWeatherPage({
    super.key,
    required this.forecast,
    required this.cityName,
    required this.quip,
    required this.latitude,
    required this.longitude,
    this.alerts = const [],
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
  static const _overscrollThreshold = 50.0;
  bool _pageChanging = false;
  Timer? _cooldownTimer;

  @override
  void dispose() {
    _cooldownTimer?.cancel();
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
        // Just trigger the page change — don't touch the scroll position.
        // BouncingScrollPhysics will bounce back naturally and the page
        // is already sliding away, so the bounce is barely visible.
        widget.parentPageController.nextPage(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOutCubic,
        );
        _cooldownTimer?.cancel();
        _cooldownTimer = Timer(const Duration(milliseconds: 600), () {
          _pageChanging = false;
          // Reset scroll after the page transition completes
          if (_scrollController.hasClients) {
            _scrollController.jumpTo(0);
          }
        });
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
    final hasDaily = widget.forecast.daily.isNotEmpty;
    final todayHigh = hasDaily
        ? math.max(widget.forecast.todayDaily.temperatureMax, weather.temperature)
        : weather.temperature;
    final todayLow = hasDaily
        ? math.min(widget.forecast.todayDaily.temperatureMin, weather.temperature)
        : weather.temperature;
    final textStyle = Theme.of(context).textTheme.bodySmall?.copyWith(
      color: AppColors.cream.withValues(alpha: 0.85),
    );

    return MediaQuery(
      data: MediaQuery.of(context).copyWith(
        textScaler: MediaQuery.textScalerOf(context).clamp(maxScaleFactor: 1.0),
      ),
      child: SafeArea(
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
                  padding: const EdgeInsets.fromLTRB(16, 0, 26, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const SizedBox(height: 56),
                      const Spacer(flex: 3),
                      LocationHeader(
                        cityName: widget.cityName,
                        localTime: widget.forecast.locationNow,
                      ),
                      if (widget.alerts.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        AlertCard(
                          alerts: widget.alerts,
                          heroColor: AppColors.magenta,
                        ),
                      ],
                      const SizedBox(height: 8),
                      TemperatureDisplay(
                        temperature: weather.temperature,
                        high: todayHigh,
                        low: todayLow,
                      ),
                      const Spacer(flex: 1),
                      SassyQuip(quip: widget.quip),
                      const Spacer(flex: 5),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
    );
  }
}

