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

    // Diffuse sun glow — barely visible through the blanket
    final glowPaint = Paint()
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 50);
    glowPaint.color =
        Colors.white.withValues(alpha: 0.14 + sin(time * 0.6) * 0.03);
    canvas.drawCircle(Offset(w * 0.75, h * 0.12), 100, glowPaint);

    // Base haze — full-width blanket that unifies the cloud layer
    final hazePaint = Paint()
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 55);

    hazePaint.color = Colors.white.withValues(alpha: 0.22);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w * 0.5 + sin(time * 0.15) * 30, h * 0.22),
        width: w * 1.5,
        height: h * 0.45,
      ),
      hazePaint,
    );
    hazePaint.color = Colors.white.withValues(alpha: 0.20);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w * 0.5 + sin(time * 0.12 + 2) * 25, h * 0.58),
        width: w * 1.4,
        height: h * 0.40,
      ),
      hazePaint,
    );
    hazePaint.color = Colors.white.withValues(alpha: 0.18);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w * 0.5 + sin(time * 0.18 + 4) * 20, h * 0.85),
        width: w * 1.3,
        height: h * 0.35,
      ),
      hazePaint,
    );

    // Dense cloud masses — overlapping wide ovals
    final cloudPaint = Paint()
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 40);

    // Upper band — heaviest
    cloudPaint.color = Colors.white.withValues(alpha: 0.28);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w * 0.3 + sin(time * 0.25) * 20, h * 0.10),
        width: w * 0.8,
        height: h * 0.18,
      ),
      cloudPaint,
    );
    cloudPaint.color = Colors.white.withValues(alpha: 0.30);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w * 0.7 + sin(time * 0.2 + 1) * 25, h * 0.16),
        width: w * 0.75,
        height: h * 0.16,
      ),
      cloudPaint,
    );

    // Mid-upper band
    cloudPaint.color = Colors.white.withValues(alpha: 0.25);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w * 0.45 + sin(time * 0.3 + 2) * 22, h * 0.30),
        width: w * 0.85,
        height: h * 0.17,
      ),
      cloudPaint,
    );

    // Center band
    cloudPaint.color = Colors.white.withValues(alpha: 0.22);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w * 0.55 + sin(time * 0.22 + 3) * 18, h * 0.45),
        width: w * 0.80,
        height: h * 0.16,
      ),
      cloudPaint,
    );
    cloudPaint.color = Colors.white.withValues(alpha: 0.20);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w * 0.35 + sin(time * 0.28 + 4) * 24, h * 0.58),
        width: w * 0.75,
        height: h * 0.15,
      ),
      cloudPaint,
    );

    // Lower band
    cloudPaint.color = Colors.white.withValues(alpha: 0.18);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w * 0.6 + sin(time * 0.24 + 5) * 20, h * 0.72),
        width: w * 0.70,
        height: h * 0.14,
      ),
      cloudPaint,
    );
    cloudPaint.color = Colors.white.withValues(alpha: 0.16);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w * 0.4 + sin(time * 0.26 + 6) * 22, h * 0.88),
        width: w * 0.75,
        height: h * 0.15,
      ),
      cloudPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
