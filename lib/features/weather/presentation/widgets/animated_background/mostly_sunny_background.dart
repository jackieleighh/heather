import 'dart:math';

import 'package:flutter/material.dart';

class MostlySunnyBackground extends StatefulWidget {
  final List<Color> gradientColors;

  const MostlySunnyBackground({super.key, required this.gradientColors});

  @override
  State<MostlySunnyBackground> createState() => _MostlySunnyBackgroundState();
}

class _MostlySunnyBackgroundState extends State<MostlySunnyBackground>
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
          foregroundPainter: _MostlySunnyPainter(_time),
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

class _MostlySunnyPainter extends CustomPainter {
  final double time;

  _MostlySunnyPainter(this.time);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final center = Offset(w * 0.8, h * 0.12);

    // Sun glow
    final glowPaint = Paint()
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 40);

    glowPaint.color = Colors.white.withValues(alpha: 0.15 + sin(time) * 0.05);
    canvas.drawCircle(center, 110, glowPaint);

    glowPaint.color = Colors.white.withValues(alpha: 0.2 + sin(time) * 0.05);
    canvas.drawCircle(center, 65, glowPaint);

    // Sun rays
    final rayPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..color = Colors.white.withValues(alpha: 0.1);

    for (var i = 0; i < 10; i++) {
      final angle = (i * pi / 5) + time * 0.3;
      final innerRadius = 55.0 + sin(time * 2 + i) * 5;
      final outerRadius = 120.0 + sin(time + i * 0.5) * 15;

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

    // Light cumulus clouds — visible but not dominant
    _drawCloud(
      canvas,
      center: Offset(w * 0.15 + sin(time * 0.2) * 20, h * 0.18),
      scale: w * 0.38,
      alpha: 0.30,
    );

    _drawCloud(
      canvas,
      center: Offset(w * 0.58 + sin(time * 0.17 + 1.5) * 18, h * 0.38),
      scale: w * 0.42,
      alpha: 0.28,
    );

    _drawCloud(
      canvas,
      center: Offset(w * 0.30 + sin(time * 0.14 + 3.0) * 15, h * 0.62),
      scale: w * 0.35,
      alpha: 0.22,
    );
  }

  void _drawCloud(
    Canvas canvas, {
    required Offset center,
    required double scale,
    required double alpha,
  }) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, scale * 0.06);

    // Flat base
    paint.color = Colors.white.withValues(alpha: alpha * 0.7);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(center.dx, center.dy + scale * 0.10),
        width: scale * 1.3,
        height: scale * 0.28,
      ),
      paint,
    );

    // Main lobes
    paint.color = Colors.white.withValues(alpha: alpha);
    canvas.drawCircle(
      Offset(center.dx - scale * 0.25, center.dy),
      scale * 0.24,
      paint,
    );
    canvas.drawCircle(
      Offset(center.dx, center.dy - scale * 0.08),
      scale * 0.30,
      paint,
    );
    canvas.drawCircle(
      Offset(center.dx + scale * 0.28, center.dy + scale * 0.02),
      scale * 0.22,
      paint,
    );

    // Top accent puff
    paint.color = Colors.white.withValues(alpha: alpha * 0.8);
    canvas.drawCircle(
      Offset(center.dx + scale * 0.04, center.dy - scale * 0.20),
      scale * 0.18,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
