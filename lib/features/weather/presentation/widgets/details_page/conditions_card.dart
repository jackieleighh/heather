import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:weather_icons/weather_icons.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/utils/weather_icon_mapper.dart';
import '../../../domain/entities/hourly_weather.dart';
import './card_container.dart';

class ConditionsCard extends StatefulWidget {
  final List<HourlyWeather> hourly;

  const ConditionsCard({super.key, required this.hourly});

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
                size: 18,
                color: AppColors.cream.withValues(alpha: 0.8),
              ),
              const SizedBox(width: 8),
              Text(
                'Conditions',
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
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
                    padding: const EdgeInsets.only(right: 14),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${h.temperature.round()}°',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Icon(
                          conditionIcon(h.weatherCode),
                          color: AppColors.cream,
                          size: 20,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          hourLabel,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.cream.withValues(alpha: 0.8),
                            fontSize: 10,
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
