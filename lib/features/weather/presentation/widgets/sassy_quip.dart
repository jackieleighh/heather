import 'package:flutter/material.dart';

class SassyQuip extends StatelessWidget {
  final String quip;

  const SassyQuip({super.key, required this.quip});

  @override
  Widget build(BuildContext context) {
    final length = quip.length;
    final fontSize = length > 100
        ? 26.0
        : length > 80
        ? 30.0
        : 34.0;

    return FractionallySizedBox(
      widthFactor: 0.9,
      child: Text(
        quip,
        textAlign: TextAlign.right,
        style: Theme.of(
          context,
        ).textTheme.labelLarge?.copyWith(height: 1.1, fontSize: fontSize),
      ),
    );
  }
}
