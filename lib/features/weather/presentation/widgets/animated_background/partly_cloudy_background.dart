import 'dart:math';
import 'dart:ui' as ui;

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

    // Sun rays peeking through gaps
    final sunCenter = Offset(w * 0.75, h * 0.12);
    final rayPaint = Paint()..style = PaintingStyle.fill;
    const rayAngles = [0.0, 0.7, 1.3, 2.0, 2.7, 3.3, 4.0, 4.7, 5.3, 5.95];
    const rayLengths = [200.0, 130.0, 180.0, 120.0, 190.0, 140.0, 170.0, 125.0, 160.0, 135.0];
    const raySpreads = [0.05, 0.033, 0.045, 0.028, 0.05, 0.035, 0.045, 0.033, 0.04, 0.033];
    const rayAlphas = [0.25, 0.15, 0.22, 0.13, 0.24, 0.17, 0.20, 0.14, 0.19, 0.15];
    const innerR = 18.0;
    final spin = time * 0.08;

    for (var i = 0; i < rayAngles.length; i++) {
      final angle = rayAngles[i] + spin;
      final outerR = rayLengths[i];
      final halfSpread = raySpreads[i];
      final alpha = rayAlphas[i] + sin(time * 0.5 + i * 0.7).abs() * 0.03;

      final cosA = cos(angle);
      final sinA = sin(angle);
      final cosL = cos(angle - halfSpread);
      final sinL = sin(angle - halfSpread);
      final cosR = cos(angle + halfSpread);
      final sinR = sin(angle + halfSpread);

      final path = Path()
        ..moveTo(sunCenter.dx + cosL * innerR, sunCenter.dy + sinL * innerR)
        ..lineTo(sunCenter.dx + cosL * outerR, sunCenter.dy + sinL * outerR)
        ..lineTo(sunCenter.dx + cosR * outerR, sunCenter.dy + sinR * outerR)
        ..lineTo(sunCenter.dx + cosR * innerR, sunCenter.dy + sinR * innerR)
        ..close();

      rayPaint
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4)
        ..shader = ui.Gradient.linear(
          Offset(sunCenter.dx + cosA * innerR, sunCenter.dy + sinA * innerR),
          Offset(sunCenter.dx + cosA * outerR, sunCenter.dy + sinA * outerR),
          [
            Colors.white.withValues(alpha: alpha),
            Colors.white.withValues(alpha: 0),
          ],
        );
      canvas.drawPath(path, rayPaint);
    }

    // Glow around core
    final glowPaint = Paint()..style = PaintingStyle.fill;
    glowPaint.shader = ui.Gradient.radial(
      sunCenter,
      90,
      [
        Colors.white.withValues(alpha: 0.38),
        Colors.white.withValues(alpha: 0.10),
        Colors.white.withValues(alpha: 0.0),
      ],
      [0.0, 0.5, 1.0],
    );
    canvas.drawRect(Offset.zero & size, glowPaint);

    // Bright core
    glowPaint.shader = ui.Gradient.radial(
      sunCenter,
      35,
      [
        Colors.white.withValues(alpha: 0.90),
        Colors.white.withValues(alpha: 0.50),
        Colors.white.withValues(alpha: 0.0),
      ],
      [0.0, 0.35, 1.0],
    );
    canvas.drawRect(Offset.zero & size, glowPaint);

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

/// Draws a cloud that drifts continuously across the screen and wraps around.
void _drawDriftingCloud(
  Canvas canvas,
  double w,
  double h,
  double time,
  double startXFrac,
  double yFrac,
  double scale,
  double alpha,
  double speed,
) {
  final totalWidth = w + scale * 1.5;
  final rawX = (startXFrac * w + time * w * speed) % totalWidth - scale * 0.75;
  final y = h * yFrac + sin(time * 0.3 + startXFrac * 10) * 8;

  _drawCloud(
    canvas,
    center: Offset(rawX, y),
    scale: scale,
    alpha: alpha,
  );
}

/// Draws the 5 cumulus clouds shared by both day and night painters.
void _drawClouds(Canvas canvas, double w, double h, double time) {
  _drawDriftingCloud(canvas, w, h, time, 0.20, 0.08, w * 0.40, 0.35, 0.05);
  _drawDriftingCloud(canvas, w, h, time, 0.65, 0.20, w * 0.48, 0.38, 0.035);
  _drawDriftingCloud(canvas, w, h, time, 0.10, 0.38, w * 0.42, 0.32, 0.06);
  _drawDriftingCloud(canvas, w, h, time, 0.75, 0.55, w * 0.36, 0.28, 0.045);
  _drawDriftingCloud(canvas, w, h, time, 0.40, 0.72, w * 0.34, 0.24, 0.055);
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
