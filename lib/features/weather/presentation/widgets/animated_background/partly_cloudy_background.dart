import 'dart:math';

import 'package:flutter/material.dart';

class PartlyCloudyBackground extends StatefulWidget {
  final List<Color> gradientColors;

  const PartlyCloudyBackground({super.key, required this.gradientColors});

  @override
  State<PartlyCloudyBackground> createState() =>
      _PartlyCloudyBackgroundState();
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

    // Sun glow peeking through gaps
    final sunCenter = Offset(w * 0.75, h * 0.12);
    final glowPaint = Paint()
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 40);

    glowPaint.color =
        Colors.white.withValues(alpha: 0.18 + sin(time * 0.8) * 0.04);
    canvas.drawCircle(sunCenter, 80, glowPaint);

    glowPaint.color = Colors.white.withValues(alpha: 0.22);
    glowPaint.maskFilter = const MaskFilter.blur(BlurStyle.normal, 16);
    canvas.drawCircle(sunCenter, 35, glowPaint);

    // Cumulus clouds — each built from overlapping circles
    _drawCloud(
      canvas,
      center: Offset(w * 0.2 + sin(time * 0.18) * 25, h * 0.08),
      scale: w * 0.40,
      alpha: 0.35,
    );

    _drawCloud(
      canvas,
      center: Offset(w * 0.65 + sin(time * 0.15 + 1.2) * 20, h * 0.20),
      scale: w * 0.48,
      alpha: 0.38,
    );

    _drawCloud(
      canvas,
      center: Offset(w * 0.10 + sin(time * 0.12 + 2.5) * 30, h * 0.38),
      scale: w * 0.42,
      alpha: 0.32,
    );

    _drawCloud(
      canvas,
      center: Offset(w * 0.75 + sin(time * 0.14 + 3.8) * 18, h * 0.55),
      scale: w * 0.36,
      alpha: 0.28,
    );

    _drawCloud(
      canvas,
      center: Offset(w * 0.40 + sin(time * 0.16 + 5.0) * 22, h * 0.72),
      scale: w * 0.34,
      alpha: 0.24,
    );
  }

  /// Draws a single cumulus cloud as a cluster of overlapping soft circles.
  void _drawCloud(
    Canvas canvas, {
    required Offset center,
    required double scale,
    required double alpha,
  }) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, scale * 0.06);

    // Flat base — wide oval anchoring the bottom
    paint.color = Colors.white.withValues(alpha: alpha * 0.75);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(center.dx, center.dy + scale * 0.12),
        width: scale * 1.4,
        height: scale * 0.35,
      ),
      paint,
    );

    // Main body — overlapping circles that form the puffy top
    paint.color = Colors.white.withValues(alpha: alpha);

    // Left lobe
    canvas.drawCircle(
      Offset(center.dx - scale * 0.30, center.dy),
      scale * 0.30,
      paint,
    );

    // Center lobe (tallest)
    canvas.drawCircle(
      Offset(center.dx, center.dy - scale * 0.12),
      scale * 0.36,
      paint,
    );

    // Right lobe
    canvas.drawCircle(
      Offset(center.dx + scale * 0.32, center.dy + scale * 0.02),
      scale * 0.28,
      paint,
    );

    // Small accent puff — top center for height
    paint.color = Colors.white.withValues(alpha: alpha * 0.85);
    canvas.drawCircle(
      Offset(center.dx + scale * 0.05, center.dy - scale * 0.24),
      scale * 0.22,
      paint,
    );

    // Small accent puff — right shoulder
    canvas.drawCircle(
      Offset(center.dx + scale * 0.44, center.dy + scale * 0.05),
      scale * 0.18,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
