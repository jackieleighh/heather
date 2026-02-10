import 'package:flutter/material.dart';

class TemperatureDisplay extends StatelessWidget {
  final double temperature;

  const TemperatureDisplay({super.key, required this.temperature});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${temperature.round()}',
          style: Theme.of(context).textTheme.displayLarge?.copyWith(
            shadows: _textShadows,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 16),
          child: Text(
            '°F',
            style: Theme.of(
              context,
            ).textTheme.headlineLarge?.copyWith(shadows: _textShadows),
          ),
        ),
      ],
    );
  }

  static const _textShadows = [
    Shadow(color: Colors.black45, blurRadius: 16, offset: Offset(0, 3)),
  ];
}
