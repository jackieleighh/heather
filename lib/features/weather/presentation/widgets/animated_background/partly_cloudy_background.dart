import 'dart:math';

import 'package:flutter/material.dart';

class PartlyCloudyBackground extends StatefulWidget {
  final List<Color> gradientColors;

  const PartlyCloudyBackground({super.key, required this.gradientColors});

  @override
  State<PartlyCloudyBackground> createState() => _PartlyCloudyBackgroundState();
}

class _PartlyCloudyBackgroundState extends State<PartlyCloudyBackground>
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
      _time += 0.005;
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
          foregroundPainter: _PartlyCloudyPainter(_time),
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

class _PartlyCloudyPainter extends CustomPainter {
  final double time;

  _PartlyCloudyPainter(this.time);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Sun glow peeking through
    final sunCenter = Offset(w * 0.75, h * 0.12);
    final glowPaint = Paint()
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 55);

    glowPaint.color = Colors.white.withValues(alpha: 0.08 + sin(time) * 0.02);
    canvas.drawCircle(sunCenter, 90, glowPaint);

    glowPaint.color = Colors.white.withValues(alpha: 0.12);
    glowPaint.maskFilter = const MaskFilter.blur(BlurStyle.normal, 22);
    canvas.drawCircle(sunCenter, 40, glowPaint);

    // Base haze — very large, very diffuse to unify the cloud layer
    final hazePaint = Paint()
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 120);

    hazePaint.color = Colors.white.withValues(alpha: 0.06);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w * 0.4 + sin(time * 0.2) * 30, h * 0.2),
        width: w * 1.2,
        height: h * 0.35,
      ),
      hazePaint,
    );
    hazePaint.color = Colors.white.withValues(alpha: 0.05);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w * 0.5 + sin(time * 0.15 + 1) * 25, h * 0.55),
        width: w * 1.0,
        height: h * 0.3,
      ),
      hazePaint,
    );

    // Cloud masses — large overlapping ovals with heavy blur
    final cloudPaint = Paint()
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 80);

    // Upper cloud band
    cloudPaint.color = Colors.white.withValues(alpha: 0.08);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w * 0.25 + sin(time * 0.3) * 20, h * 0.12),
        width: w * 0.6,
        height: h * 0.15,
      ),
      cloudPaint,
    );
    cloudPaint.color = Colors.white.withValues(alpha: 0.09);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w * 0.65 + sin(time * 0.25 + 1) * 25, h * 0.18),
        width: w * 0.55,
        height: h * 0.14,
      ),
      cloudPaint,
    );

    // Middle cloud band
    cloudPaint.color = Colors.white.withValues(alpha: 0.07);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w * 0.4 + sin(time * 0.35 + 2) * 18, h * 0.38),
        width: w * 0.7,
        height: h * 0.16,
      ),
      cloudPaint,
    );

    // Lower clouds — lighter
    cloudPaint.color = Colors.white.withValues(alpha: 0.05);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w * 0.55 + sin(time * 0.28 + 3) * 22, h * 0.65),
        width: w * 0.6,
        height: h * 0.14,
      ),
      cloudPaint,
    );
    cloudPaint.color = Colors.white.withValues(alpha: 0.04);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w * 0.3 + sin(time * 0.32 + 4) * 20, h * 0.82),
        width: w * 0.5,
        height: h * 0.12,
      ),
      cloudPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
