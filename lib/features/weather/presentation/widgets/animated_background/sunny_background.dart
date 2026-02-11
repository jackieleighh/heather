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
          foregroundPainter: _SunnyPainter(_time),
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

    glowPaint.color = Colors.white.withValues(alpha: 0.3 + sin(time) * 0.05);
    canvas.drawCircle(center, 120, glowPaint);

    glowPaint.color = Colors.white.withValues(alpha: 0.45 + sin(time) * 0.05);
    canvas.drawCircle(center, 70, glowPaint);

    // Sun rays — soft, varied, organic
    final rayPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);

    for (var i = 0; i < 10; i++) {
      final baseAngle = i * pi / 5;
      // Each ray drifts at its own speed
      final angle = baseAngle + time * (0.12 + i * 0.008);
      // Breathing inner/outer radii per ray
      final innerRadius = 65.0 + sin(time * 0.8 + i * 1.1) * 8;
      final outerRadius = 135.0 + sin(time * 0.5 + i * 0.7) * 25;
      final width = 6.0 + sin(time * 0.6 + i * 2.0) * 2.5;
      final opacity = 0.18 + sin(time * 0.4 + i * 1.5).abs() * 0.12;

      rayPaint
        ..strokeWidth = width
        ..color = Colors.white.withValues(alpha: opacity);

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
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
