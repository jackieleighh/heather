import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:weather_icons/weather_icons.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/utils/weather_icon_mapper.dart';
import '../../../domain/entities/hourly_weather.dart';
import './card_container.dart';

class ConditionsCard extends StatefulWidget {
  final List<HourlyWeather> hourly;
  final bool compact;
  final DateTime? sunrise;
  final DateTime? sunset;

  const ConditionsCard({
    super.key,
    required this.hourly,
    this.compact = false,
    this.sunrise,
    this.sunset,
  });

  @override
  State<ConditionsCard> createState() => _ConditionsCardState();
}

class _ConditionsCardState extends State<ConditionsCard> {
  final _scrollController = ScrollController();
  bool _showLeftFade = false;
  bool _showRightFade = true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  bool _isHourDay(DateTime time) {
    final sunrise = widget.sunrise;
    final sunset = widget.sunset;
    if (sunrise == null || sunset == null) return true;
    final minutes = time.hour * 60 + time.minute;
    final sunriseMin = sunrise.hour * 60 + sunrise.minute;
    final sunsetMin = sunset.hour * 60 + sunset.minute;
    return minutes >= sunriseMin && minutes < sunsetMin;
  }

  void _onScroll() {
    final pos = _scrollController.position;
    final atStart = pos.pixels <= 0;
    final atEnd = pos.pixels >= pos.maxScrollExtent;

    if (_showLeftFade == atStart || _showRightFade == atEnd) {
      setState(() {
        _showLeftFade = !atStart;
        _showRightFade = !atEnd;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return CardContainer(
      backgroundIcon: WeatherIcons.cloud,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                WeatherIcons.cloud,
                size: widget.compact ? 12 : 18,
                color: AppColors.cream.withValues(alpha: 0.9),
              ),
              SizedBox(width: widget.compact ? 5 : 8),
              Text(
                'Conditions',
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          SizedBox(height: widget.compact ? 1 : 2),
          Expanded(
            child: ShaderMask(
              shaderCallback: (bounds) {
                return LinearGradient(
                  colors: [
                    if (_showLeftFade) Colors.transparent else Colors.white,
                    Colors.white,
                    Colors.white,
                    if (_showRightFade) Colors.transparent else Colors.white,
                  ],
                  stops: const [0.0, 0.1, 0.9, 1.0],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ).createShader(bounds);
              },
              blendMode: BlendMode.dstIn,
              child: ListView.builder(
                controller: _scrollController,
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: widget.hourly.length,
                itemBuilder: (context, index) {
                  final h = widget.hourly[index];
                  final hourLabel = DateFormat(
                    'ha',
                  ).format(h.time).toLowerCase();
                  return Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${h.temperature.round()}°',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            fontSize: widget.compact ? 11 : 12,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Icon(
                          conditionIcon(
                            h.weatherCode,
                            isDay: _isHourDay(h.time),
                          ),
                          color: AppColors.cream,
                          size: widget.compact ? 18 : 20,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          hourLabel,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.cream.withValues(alpha: 0.9),
                            fontSize: widget.compact ? 9 : 10,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
