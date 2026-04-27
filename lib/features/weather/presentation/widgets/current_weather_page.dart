import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/forecast.dart';
import '../../domain/entities/minutely_weather.dart';
import '../../domain/entities/weather_alert.dart';
import 'alert_card.dart';
import 'location_header.dart';
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
  static const _overscrollThreshold = 50.0;
  bool _pageChanging = false;
  Timer? _cooldownTimer;

  @override
  void dispose() {
    _cooldownTimer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  bool _handleScrollNotification(ScrollNotification notification) {
    if (_pageChanging) return false;

    if (notification is ScrollUpdateNotification) {
      final pos = notification.metrics;

      // At bottom and swiping up → next page
      if (pos.pixels > pos.maxScrollExtent + _overscrollThreshold) {
        _pageChanging = true;
        widget.parentPageController.nextPage(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOutCubic,
        );
        _cooldownTimer?.cancel();
        _cooldownTimer = Timer(const Duration(milliseconds: 600), () {
          _pageChanging = false;
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
    await widget.onRefresh();
  }

  String? _precipLabel() {
    final forecast = widget.forecast;
    final isRaining = precipConditions.contains(forecast.current.condition);

    // Try minutely_15 data first (most precise, ~1 hour window)
    final minutelyLabel = formatPrecipLabel(
      analyzePrecipitation(
        minutely15: forecast.minutely15,
        locationNow: forecast.locationNow,
        isCurrentlyRaining: isRaining,
      ),
    );
    if (minutelyLabel != null) return minutelyLabel;

    // Fall back to hourly data (transition/stop labels)
    final hourlyLabel = hourlyPrecipLabel(
      hourly: forecast.hourly,
      currentCondition: forecast.current.condition,
      locationNow: forecast.locationNow,
      daily: forecast.daily,
    );
    if (hourlyLabel != null) return hourlyLabel;

    // Nighttime fallback — tomorrow's precipitation
    if (!forecast.isCurrentlyDay) {
      return tomorrowPrecipLabel(
        daily: forecast.daily,
        locationNow: forecast.locationNow,
      );
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    final weather = widget.forecast.current;
    final hasDaily = widget.forecast.daily.isNotEmpty;
    final todayHigh = hasDaily
        ? math.max(
            widget.forecast.todayDaily.temperatureMax,
            weather.temperature,
          )
        : weather.temperature;
    final todayLow = hasDaily
        ? math.min(
            widget.forecast.todayDaily.temperatureMin,
            weather.temperature,
          )
        : weather.temperature;

    final precipLabel = _precipLabel();

    return MediaQuery(
      data: MediaQuery.of(context).copyWith(
        textScaler: MediaQuery.textScalerOf(context).clamp(maxScaleFactor: 1.0),
      ),
      child: SafeArea(
        child: NotificationListener<ScrollNotification>(
          onNotification: _handleScrollNotification,
          child: RefreshIndicator(
            onRefresh: _onRefresh,
            color: AppColors.cream,
            backgroundColor: Colors.transparent,
            elevation: 0,
            child: CustomScrollView(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
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
                          feelsLike: weather.feelsLike,
                          precipLabel: precipLabel,
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
