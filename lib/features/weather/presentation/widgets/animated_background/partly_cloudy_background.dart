import 'dart:math';

import 'package:flutter/material.dart';

class PartlyCloudyBackground extends StatefulWidget {
  final List<Color> gradientColors;
  final bool isDay;

  const PartlyCloudyBackground({
    super.key,
    required this.gradientColors,
    required this.isDay,
  });

  @override
  State<PartlyCloudyBackground> createState() =>
      _PartlyCloudyBackgroundState();
}

class _PartlyCloudyBackgroundState extends State<PartlyCloudyBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  double _time = 0;
  final List<_Star> _stars = [];
  final Random _random = Random();

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
          foregroundPainter: widget.isDay
              ? _PartlyCloudyDayPainter(_time)
              : _PartlyCloudyNightPainter(_stars, _random, _time),
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

class _Star {
  final double x;
  final double y;
  final double size;
  final double twinkleSpeed;
  final double phase;

  _Star({
    required this.x,
    required this.y,
    required this.size,
    required this.twinkleSpeed,
    required this.phase,
  });
}

class _PartlyCloudyDayPainter extends CustomPainter {
  final double time;

  _PartlyCloudyDayPainter(this.time);

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

    // Cumulus clouds
    _drawClouds(canvas, w, h, time);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _PartlyCloudyNightPainter extends CustomPainter {
  final List<_Star> stars;
  final Random random;
  final double time;

  _PartlyCloudyNightPainter(this.stars, this.random, this.time);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Stars
    if (stars.isEmpty) {
      for (var i = 0; i < 80; i++) {
        stars.add(
          _Star(
            x: random.nextDouble() * w,
            y: random.nextDouble() * h * 0.7,
            size: 0.5 + random.nextDouble() * 2.5,
            twinkleSpeed: 0.5 + random.nextDouble() * 2.0,
            phase: random.nextDouble() * 2 * pi,
          ),
        );
      }
    }

    final starPaint = Paint()..style = PaintingStyle.fill;

    for (final star in stars) {
      final twinkle = (sin(time * star.twinkleSpeed + star.phase) + 1) / 2;
      final opacity = 0.1 + twinkle * 0.3;

      starPaint.color = Colors.white.withValues(alpha: opacity);
      canvas.drawCircle(
        Offset(star.x, star.y),
        star.size * (0.8 + twinkle * 0.2),
        starPaint,
      );
    }

    // Moon glow
    final moonCenter = Offset(w * 0.75, h * 0.12);
    final moonPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.white.withValues(alpha: 0.15)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 25);
    canvas.drawCircle(moonCenter, 50, moonPaint);

    moonPaint
      ..color = Colors.white.withValues(alpha: 0.4)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawCircle(moonCenter, 25, moonPaint);

    // Cumulus clouds (layered over stars)
    _drawClouds(canvas, w, h, time);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

/// Draws the 5 cumulus clouds shared by both day and night painters.
void _drawClouds(Canvas canvas, double w, double h, double time) {
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
