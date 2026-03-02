import 'dart:math';

import 'package:flutter/material.dart';
import 'package:heather/core/constants/app_colors.dart';

class PulsingDots extends StatefulWidget {
  final double dotSize;
  final double bounceHeight;
  final Color color;

  const PulsingDots({
    super.key,
    this.dotSize = 6,
    this.bounceHeight = 8,
    this.color = AppColors.cream,
  });

  @override
  State<PulsingDots> createState() => _PulsingDotsState();
}

class _PulsingDotsState extends State<PulsingDots>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double _dotOffset(int index) {
    const stagger = 0.15;
    final t = (_controller.value - index * stagger) % 1.0;
    // Bounce up during the first half of the cycle, rest during the second
    if (t < 0.5) {
      return -sin(t * 2 * pi) * widget.bounceHeight;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child: Transform.translate(
                offset: Offset(0, _dotOffset(i)),
                child: Container(
                  width: widget.dotSize,
                  height: widget.dotSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: widget.color.withValues(alpha: 0.9),
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}
