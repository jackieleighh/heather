import 'package:flutter/material.dart';

class LocationHeader extends StatelessWidget {
  final String cityName;

  const LocationHeader({super.key, required this.cityName});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.location_on_outlined,
          color: Colors.white.withValues(alpha: 0.9),
          size: 18,
        ),
        const SizedBox(width: 4),
        Text(
          cityName,
          style: Theme.of(
            context,
          ).textTheme.headlineMedium?.copyWith(shadows: _textShadows),
        ),
      ],
    );
  }

  static const _textShadows = [
    Shadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 2)),
  ];
}
