import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:weather_icons/weather_icons.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/utils/geo_utils.dart';
import '../../../../../core/utils/weather_icon_mapper.dart';
import '../../../domain/entities/hourly_weather.dart';
import './card_container.dart';
import './card_display_mode.dart';

class ConditionsCard extends StatefulWidget {
  final List<HourlyWeather> hourly;
  final bool compact;
  final DateTime? sunrise;
  final DateTime? sunset;
  final DateTime? now;
  final CardDisplayMode mode;
  final bool flat;
  final bool showHeader;

  const ConditionsCard({
    super.key,
    required this.hourly,
    this.compact = false,
    this.sunrise,
    this.sunset,
    this.now,
    this.mode = CardDisplayMode.normal,
    this.flat = false,
    this.showHeader = true,
  });

  @override
  State<ConditionsCard> createState() => _ConditionsCardState();
}

class _ConditionsCardState extends State<ConditionsCard> {
  final _scrollController = ScrollController();
  final _showLeftFade = ValueNotifier(false);
  final _showRightFade = ValueNotifier(true);

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _showLeftFade.dispose();
    _showRightFade.dispose();
    super.dispose();
  }

  void _onScroll() {
    final pos = _scrollController.position;
    _showLeftFade.value = pos.pixels > 0;
    _showRightFade.value = pos.pixels < pos.maxScrollExtent;
  }

  Widget _buildHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Icon(
          WeatherIcons.cloud,
          size: widget.compact ? 10 : 15,
          color: AppColors.cream.withValues(alpha: 0.9),
        ),
        SizedBox(width: widget.compact ? 3 : 4),
        Text(
          'Conditions',
          style: GoogleFonts.figtree(
            fontSize: widget.mode == CardDisplayMode.collapsed
                ? 16
                : (widget.compact ? 14 : 18),
            fontWeight: FontWeight.w400,
            color: AppColors.cream,
          ),
        ),
      ],
    );
  }

  Widget _buildHorizontalScroller() {
    return Expanded(
      child: ListenableBuilder(
        listenable: Listenable.merge([_showLeftFade, _showRightFade]),
        builder: (context, child) => ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              colors: [
                if (_showLeftFade.value) Colors.transparent else Colors.white,
                Colors.white,
                Colors.white,
                if (_showRightFade.value) Colors.transparent else Colors.white,
              ],
              stops: const [0.0, 0.1, 0.9, 1.0],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ).createShader(bounds);
          },
          blendMode: BlendMode.dstIn,
          child: child,
        ),
        child: ListView.builder(
          controller: _scrollController,
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          itemCount: widget.hourly.length,
          itemBuilder: (context, index) {
            final h = widget.hourly[index];
            final hourLabel = DateFormat('ha').format(h.time).toLowerCase();
            return Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${h.temperature.round()}\u00B0',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: widget.compact ? 11 : 12,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Icon(
                    conditionIcon(
                      h.weatherCode,
                      isDay: isDayForSunTimes(
                        h.time,
                        sunrise: widget.sunrise,
                        sunset: widget.sunset,
                      ),
                    ),
                    color: AppColors.cream,
                    size: widget.compact ? 14 : 20,
                  ),
                  const SizedBox(height: 1),
                  Text(
                    hourLabel,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
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
    );
  }

  Widget _buildExpandedGrid() {
    final hours = widget.hourly;
    if (hours.isEmpty) return const SizedBox.shrink();

    const columns = 6;
    final rows = (hours.length / columns).ceil();

    return Expanded(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final cellWidth = constraints.maxWidth / columns;
          final cellHeight = constraints.maxHeight / rows;

          return Column(
            children: List.generate(rows, (row) {
              return SizedBox(
                height: cellHeight,
                child: Row(
                  children: List.generate(columns, (col) {
                    final index = row * columns + col;
                    if (index >= hours.length) return SizedBox(width: cellWidth);

                    final h = hours[index];
                    final hourLabel =
                        DateFormat('ha').format(h.time).toLowerCase();
                    final isDay = isDayForSunTimes(
                      h.time,
                      sunrise: widget.sunrise,
                      sunset: widget.sunset,
                    );

                    return SizedBox(
                      width: cellWidth,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            hourLabel,
                            style: GoogleFonts.figtree(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.cream.withValues(alpha: 0.7),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Icon(
                            conditionIcon(h.weatherCode, isDay: isDay),
                            color: AppColors.cream.withValues(alpha: 0.85),
                            size: 30,
                          ),
                          const SizedBox(height: 3),
                          Text(
                            '${h.temperature.round()}\u00B0',
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppColors.cream.withValues(alpha: 0.7),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ),
              );
            }),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.mode == CardDisplayMode.collapsed) {
      final current = widget.hourly.isNotEmpty ? widget.hourly.first : null;
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: Row(
          children: [
            Icon(
              WeatherIcons.cloud,
              size: 14,
              color: AppColors.cream.withValues(alpha: 0.9),
            ),
            const SizedBox(width: 4),
            Text(
              'Conditions',
              style: GoogleFonts.figtree(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: AppColors.cream,
              ),
            ),
            const Spacer(),
            if (current != null)
              Icon(
                conditionIcon(
                  current.weatherCode,
                  isDay: isDayForSunTimes(
                    current.time,
                    sunrise: widget.sunrise,
                    sunset: widget.sunset,
                  ),
                ),
                size: 16,
                color: AppColors.cream,
              ),
          ],
        ),
      );
    }

    if (widget.mode == CardDisplayMode.expanded) {
      return CardContainer(
        backgroundIcon: WeatherIcons.cloud,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 8),
            _buildExpandedGrid(),
          ],
        ),
      );
    }

    // Normal mode
    return CardContainer(
      backgroundIcon: WeatherIcons.cloud,
      flat: widget.flat,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.showHeader) ...[
            _buildHeader(),
            SizedBox(height: widget.compact ? 1 : 2),
          ],
          _buildHorizontalScroller(),
        ],
      ),
    );
  }
}
