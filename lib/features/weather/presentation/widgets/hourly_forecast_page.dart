import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:weather_icons/weather_icons.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/weather_icon_mapper.dart';
import '../../domain/entities/hourly_weather.dart';

class HourlyForecastPage extends StatefulWidget {
  final List<HourlyWeather> hourly;
  final PageController parentPageController;

  const HourlyForecastPage({
    super.key,
    required this.hourly,
    required this.parentPageController,
  });

  @override
  State<HourlyForecastPage> createState() => _HourlyForecastPageState();
}

class _HourlyForecastPageState extends State<HourlyForecastPage> {
  final _scrollController = ScrollController();
  static const _overscrollThreshold = 60.0;
  bool _pageChanging = false;
  double _topFade = 0.0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_updateTopFade);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_updateTopFade);
    _scrollController.dispose();
    super.dispose();
  }

  void _updateTopFade() {
    final t = (_scrollController.offset / 40.0).clamp(0.0, 1.0);
    if (t != _topFade) setState(() => _topFade = t);
  }

  bool _handleScrollNotification(ScrollNotification notification) {
    if (_pageChanging) return false;

    if (notification is ScrollUpdateNotification) {
      final pos = notification.metrics;

      // At top and pulling down
      if (pos.pixels < pos.minScrollExtent - _overscrollThreshold) {
        _pageChanging = true;
        widget.parentPageController
            .previousPage(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            )
            .then((_) => _pageChanging = false);
        _scrollController.jumpTo(0);
        return true;
      }

      // At bottom and pushing up
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
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 28, right: 64),
            child: SizedBox(
              height: 62,
              child: Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'Next 24 Hours',
                  style: GoogleFonts.quicksand(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: AppColors.cream,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: ShaderMask(
              shaderCallback: (bounds) => LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.white.withValues(alpha: 1.0 - _topFade),
                  Colors.white,
                  Colors.white,
                  Colors.transparent,
                ],
                stops: const [0.0, 0.05, 0.95, 1.0],
              ).createShader(bounds),
              blendMode: BlendMode.dstIn,
              child: NotificationListener<ScrollNotification>(
                onNotification: _handleScrollNotification,
                child: ListView.builder(
                  controller: _scrollController,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  itemCount: widget.hourly.length,
                  itemBuilder: (context, index) =>
                      _HourlyRow(hourly: widget.hourly[index]),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

class _HourlyRow extends StatelessWidget {
  final HourlyWeather hourly;

  const _HourlyRow({required this.hourly});

  @override
  Widget build(BuildContext context) {
    final timeStr = DateFormat('h a').format(hourly.time);
    final style = Theme.of(
      context,
    ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600);

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.cream.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            SizedBox(width: 60, child: Text(timeStr, style: style)),
            Icon(
              conditionIcon(hourly.weatherCode),
              color: AppColors.cream.withValues(alpha: 0.8),
              size: 22,
            ),
            const SizedBox(width: 12),
            SizedBox(
              width: 50,
              child: Text(
                '${hourly.temperature.round()}°',
                style: style?.copyWith(fontWeight: FontWeight.w800),
              ),
            ),
            Icon(
              WeatherIcons.raindrop,
              size: 14,
              color: AppColors.cream.withValues(alpha: 0.7),
            ),
            const SizedBox(width: 4),
            SizedBox(
              width: 36,
              child: Text(
                '${hourly.precipitationProbability}%',
                style: style?.copyWith(fontSize: 14),
              ),
            ),
            const Spacer(),
            Text(
              '${hourly.windSpeed.round()} mph',
              style: style?.copyWith(fontSize: 14),
            ),
            const SizedBox(width: 8),
            Icon(
              WeatherIcons.windy,
              size: 14,
              color: AppColors.cream.withValues(alpha: 0.7),
            ),
          ],
        ),
      ),
    );
  }
}
