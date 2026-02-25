import 'package:flutter/material.dart';

class SassyQuip extends StatelessWidget {
  final String quip;

  const SassyQuip({super.key, required this.quip});

  @override
  Widget build(BuildContext context) {
    final length = quip.length;
    final fontSize = length > 120 ? 22.0 : length > 80 ? 26.0 : 30.0;

    return Container(
      width: double.infinity,
      constraints: BoxConstraints(
        maxWidth: MediaQuery.sizeOf(context).width * 0.92,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            quip,
            textAlign: TextAlign.right,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              height: 1.1,
              fontSize: fontSize,
            ),
          ),
        ],
      ),
    );
  }
}
