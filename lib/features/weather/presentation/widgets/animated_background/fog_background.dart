import 'dart:math';

import 'package:flutter/material.dart';

class FogBackground extends StatefulWidget {
  final List<Color> gradientColors;

  const FogBackground({super.key, required this.gradientColors});

  @override
  State<FogBackground> createState() => _FogBackgroundState();
}

class _FogBackgroundState extends State<FogBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  double _time = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();
    _controller.addListener(() {
      _time += 0.003;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          foregroundPainter: _FogPainter(_time),
          size: Size.infinite,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: widget.gradientColors,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _FogPainter extends CustomPainter {
  final double time;

  _FogPainter(this.time);

  @override
  void paint(Canvas canvas, Size size) {
    for (var i = 0; i < 6; i++) {
      final yBase = size.height * (0.1 + i * 0.15);
      final xOffset = sin(time * (0.5 + i * 0.1) + i) * 50;
      final opacity = 0.04 + sin(time * 0.3 + i * 0.8).abs() * 0.04;

      final paint = Paint()
        ..color = Colors.white.withValues(alpha: opacity)
        ..style = PaintingStyle.fill
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 60);

      final rect = RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(size.width / 2 + xOffset, yBase),
          width: size.width * 1.4,
          height: 80 + sin(time + i) * 20,
        ),
        const Radius.circular(40),
      );

      canvas.drawRRect(rect, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
