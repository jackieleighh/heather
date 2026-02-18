import 'dart:math';
import 'dart:ui' as ui;

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
    final paint = Paint()..style = PaintingStyle.fill;
    final spin = time * 0.08;

    // 1. Rays — narrow, distinct beams with varying lengths
    final rayPaint = Paint()..style = PaintingStyle.fill;
    const rayAngles = [0.0, 0.55, 1.05, 1.6, 2.15, 2.65, 3.2, 3.75, 4.3, 4.85, 5.35, 5.9];
    const rayLengths = [380.0, 240.0, 320.0, 200.0, 360.0, 260.0, 340.0, 220.0, 300.0, 250.0, 350.0, 230.0];
    const raySpreads = [0.06, 0.04, 0.055, 0.035, 0.06, 0.045, 0.055, 0.04, 0.05, 0.04, 0.06, 0.035];
    const rayAlphas = [0.40, 0.25, 0.35, 0.20, 0.38, 0.28, 0.33, 0.22, 0.30, 0.24, 0.37, 0.18];
    const innerR = 25.0;

    for (var i = 0; i < rayAngles.length; i++) {
      final angle = rayAngles[i] + spin;
      final outerR = rayLengths[i];
      final halfSpread = raySpreads[i];
      final alpha = rayAlphas[i] + sin(time * 0.5 + i * 0.7).abs() * 0.05;

      final cosA = cos(angle);
      final sinA = sin(angle);
      final cosL = cos(angle - halfSpread);
      final sinL = sin(angle - halfSpread);
      final cosR = cos(angle + halfSpread);
      final sinR = sin(angle + halfSpread);

      final path = Path()
        ..moveTo(center.dx + cosL * innerR, center.dy + sinL * innerR)
        ..lineTo(center.dx + cosL * outerR, center.dy + sinL * outerR)
        ..lineTo(center.dx + cosR * outerR, center.dy + sinR * outerR)
        ..lineTo(center.dx + cosR * innerR, center.dy + sinR * innerR)
        ..close();

      rayPaint
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6)
        ..shader = ui.Gradient.linear(
          Offset(center.dx + cosA * innerR, center.dy + sinA * innerR),
          Offset(center.dx + cosA * outerR, center.dy + sinA * outerR),
          [
            Colors.white.withValues(alpha: alpha),
            Colors.white.withValues(alpha: 0),
          ],
        );
      canvas.drawPath(path, rayPaint);
    }

    // 2. Glow around core
    paint.shader = ui.Gradient.radial(
      center,
      130,
      [
        Colors.white.withValues(alpha: 0.55),
        Colors.white.withValues(alpha: 0.15),
        Colors.white.withValues(alpha: 0.0),
      ],
      [0.0, 0.5, 1.0],
    );
    canvas.drawRect(Offset.zero & size, paint);

    // 3. Bright core
    paint.shader = ui.Gradient.radial(
      center,
      55,
      [
        Colors.white,
        Colors.white.withValues(alpha: 0.70),
        Colors.white.withValues(alpha: 0.0),
      ],
      [0.0, 0.35, 1.0],
    );
    canvas.drawRect(Offset.zero & size, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
