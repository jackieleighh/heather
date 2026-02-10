import 'package:flutter/material.dart';

class SassyQuip extends StatelessWidget {
  final String quip;

  const SassyQuip({super.key, required this.quip});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: BoxConstraints(
        maxWidth: MediaQuery.sizeOf(context).width * 0.70,
      ),
      child: Text(
        quip,
        textAlign: TextAlign.right,
        style: Theme.of(
          context,
        ).textTheme.labelLarge?.copyWith(height: 1.4),
      ),
    );
  }
}
