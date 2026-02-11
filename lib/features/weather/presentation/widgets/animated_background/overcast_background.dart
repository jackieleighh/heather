import 'dart:math';

import 'package:flutter/material.dart';

class OvercastBackground extends StatefulWidget {
  final List<Color> gradientColors;

  const OvercastBackground({super.key, required this.gradientColors});

  @override
  State<OvercastBackground> createState() => _OvercastBackgroundState();
}

class _OvercastBackgroundState extends State<OvercastBackground>
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
      _time += 0.004;
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
          foregroundPainter: _OvercastPainter(_time),
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

class _OvercastPainter extends CustomPainter {
  final double time;

  _OvercastPainter(this.time);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Full-screen haze layers — creates a uniform cloudy base
    final hazePaint = Paint()
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 150);

    hazePaint.color = Colors.white.withValues(alpha: 0.1);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w * 0.5 + sin(time * 0.15) * 30, h * 0.25),
        width: w * 1.4,
        height: h * 0.45,
      ),
      hazePaint,
    );
    hazePaint.color = Colors.white.withValues(alpha: 0.08);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w * 0.5 + sin(time * 0.12 + 2) * 25, h * 0.6),
        width: w * 1.3,
        height: h * 0.4,
      ),
      hazePaint,
    );
    hazePaint.color = Colors.white.withValues(alpha: 0.06);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w * 0.5 + sin(time * 0.18 + 4) * 20, h * 0.85),
        width: w * 1.2,
        height: h * 0.35,
      ),
      hazePaint,
    );

    // Dense cloud masses — overlapping wide ovals
    final cloudPaint = Paint()
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 100);

    // Upper band — heaviest
    cloudPaint.color = Colors.white.withValues(alpha: 0.1);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w * 0.3 + sin(time * 0.25) * 20, h * 0.08),
        width: w * 0.8,
        height: h * 0.18,
      ),
      cloudPaint,
    );
    cloudPaint.color = Colors.white.withValues(alpha: 0.12);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w * 0.7 + sin(time * 0.2 + 1) * 25, h * 0.15),
        width: w * 0.75,
        height: h * 0.16,
      ),
      cloudPaint,
    );

    // Mid-upper band
    cloudPaint.color = Colors.white.withValues(alpha: 0.1);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w * 0.45 + sin(time * 0.3 + 2) * 22, h * 0.28),
        width: w * 0.85,
        height: h * 0.17,
      ),
      cloudPaint,
    );

    // Center band
    cloudPaint.color = Colors.white.withValues(alpha: 0.09);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w * 0.55 + sin(time * 0.22 + 3) * 18, h * 0.42),
        width: w * 0.8,
        height: h * 0.16,
      ),
      cloudPaint,
    );
    cloudPaint.color = Colors.white.withValues(alpha: 0.08);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w * 0.35 + sin(time * 0.28 + 4) * 24, h * 0.55),
        width: w * 0.75,
        height: h * 0.15,
      ),
      cloudPaint,
    );

    // Lower band
    cloudPaint.color = Colors.white.withValues(alpha: 0.07);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w * 0.6 + sin(time * 0.24 + 5) * 20, h * 0.7),
        width: w * 0.7,
        height: h * 0.14,
      ),
      cloudPaint,
    );
    cloudPaint.color = Colors.white.withValues(alpha: 0.06);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w * 0.4 + sin(time * 0.26 + 6) * 22, h * 0.85),
        width: w * 0.75,
        height: h * 0.15,
      ),
      cloudPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
