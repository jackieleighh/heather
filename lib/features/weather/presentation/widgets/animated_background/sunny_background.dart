import 'dart:math';

import 'package:flutter/material.dart';

class SunnyBackground extends StatefulWidget {
  final List<Color> gradientColors;

  const SunnyBackground({super.key, required this.gradientColors});

  @override
  State<SunnyBackground> createState() => _SunnyBackgroundState();
}

class _SunnyBackgroundState extends State<SunnyBackground>
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
      _time += 0.008;
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
          painter: _SunnyPainter(_time),
          size: Size.infinite,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: widget.gradientColors,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _SunnyPainter extends CustomPainter {
  final double time;

  _SunnyPainter(this.time);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width * 0.8, size.height * 0.12);

    // Sun glow
    final glowPaint = Paint()
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 40);

    glowPaint.color = Colors.white.withValues(alpha: 0.15 + sin(time) * 0.05);
    canvas.drawCircle(center, 120, glowPaint);

    glowPaint.color = Colors.white.withValues(alpha: 0.2 + sin(time) * 0.05);
    canvas.drawCircle(center, 70, glowPaint);

    // Sun rays
    final rayPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..color = Colors.white.withValues(alpha: 0.12);

    for (var i = 0; i < 12; i++) {
      final angle = (i * pi / 6) + time * 0.3;
      final innerRadius = 60.0 + sin(time * 2 + i) * 5;
      final outerRadius = 140.0 + sin(time + i * 0.5) * 20;

      canvas.drawLine(
        Offset(
          center.dx + cos(angle) * innerRadius,
          center.dy + sin(angle) * innerRadius,
        ),
        Offset(
          center.dx + cos(angle) * outerRadius,
          center.dy + sin(angle) * outerRadius,
        ),
        rayPaint,
      );
    }

    // Shimmer particles
    final shimmerPaint = Paint()..style = PaintingStyle.fill;
    for (var i = 0; i < 20; i++) {
      final px = (sin(time * 0.5 + i * 1.3) * 0.5 + 0.5) * size.width;
      final py = (cos(time * 0.3 + i * 1.7) * 0.5 + 0.5) * size.height;
      final opacity = (sin(time * 2 + i) * 0.5 + 0.5) * 0.15;

      shimmerPaint.color = Colors.white.withValues(alpha: opacity);
      canvas.drawCircle(Offset(px, py), 2, shimmerPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
