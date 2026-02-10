import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';

class LocationHeader extends StatelessWidget {
  final String cityName;

  const LocationHeader({super.key, required this.cityName});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(
          Icons.location_on_outlined,
          color: AppColors.cream,
          size: 18,
        ),
        const SizedBox(width: 4),
        Text(cityName, style: Theme.of(context).textTheme.headlineMedium),
      ],
    );
  }
}
