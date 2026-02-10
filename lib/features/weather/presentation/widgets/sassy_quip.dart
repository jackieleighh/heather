import 'package:flutter/material.dart';

class SassyQuip extends StatelessWidget {
  final String quip;

  const SassyQuip({super.key, required this.quip});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: BoxConstraints(
        maxWidth: MediaQuery.sizeOf(context).width * 0.85,
      ),
      child: Text(
        quip,
        style: Theme.of(
          context,
        ).textTheme.labelLarge?.copyWith(height: 1.4, shadows: _textShadows),
      ),
    );
  }

  static const _textShadows = [
    Shadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 1)),
  ];
}
