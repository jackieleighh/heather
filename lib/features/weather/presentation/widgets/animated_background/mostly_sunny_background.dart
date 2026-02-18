import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

class MostlySunnyBackground extends StatefulWidget {
  final List<Color> gradientColors;
  final bool isDay;

  const MostlySunnyBackground({
    super.key,
    required this.gradientColors,
    required this.isDay,
  });

  @override
  State<MostlySunnyBackground> createState() => _MostlySunnyBackgroundState();
}

class _MostlySunnyBackgroundState extends State<MostlySunnyBackground>
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
          foregroundPainter: widget.isDay
              ? _MostlySunnyDayPainter(_time)
              : _MostlySunnyNightPainter(_stars, _random, _time),
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

class _MostlySunnyDayPainter extends CustomPainter {
  final double time;

  _MostlySunnyDayPainter(this.time);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final center = Offset(w * 0.8, h * 0.12);
    final paint = Paint()..style = PaintingStyle.fill;

    // 1. Rays — narrow, distinct beams with varying lengths
    final rayPaint = Paint()..style = PaintingStyle.fill;
    const rayAngles = [0.0, 0.55, 1.05, 1.6, 2.15, 2.65, 3.2, 3.75, 4.3, 4.85, 5.35, 5.9];
    const rayLengths = [300.0, 190.0, 260.0, 160.0, 290.0, 210.0, 270.0, 180.0, 240.0, 200.0, 280.0, 185.0];
    const raySpreads = [0.055, 0.037, 0.05, 0.032, 0.055, 0.04, 0.05, 0.037, 0.045, 0.037, 0.055, 0.032];
    const rayAlphas = [0.32, 0.20, 0.28, 0.16, 0.30, 0.22, 0.26, 0.18, 0.24, 0.19, 0.30, 0.15];
    const innerR = 22.0;
    final spin = time * 0.08;

    for (var i = 0; i < rayAngles.length; i++) {
      final angle = rayAngles[i] + spin;
      final outerR = rayLengths[i];
      final halfSpread = raySpreads[i];
      final alpha = rayAlphas[i] + sin(time * 0.5 + i * 0.7).abs() * 0.04;

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
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5)
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
      110,
      [
        Colors.white.withValues(alpha: 0.45),
        Colors.white.withValues(alpha: 0.12),
        Colors.white.withValues(alpha: 0.0),
      ],
      [0.0, 0.5, 1.0],
    );
    canvas.drawRect(Offset.zero & size, paint);

    // 3. Bright core
    paint.shader = ui.Gradient.radial(
      center,
      45,
      [
        Colors.white.withValues(alpha: 0.95),
        Colors.white.withValues(alpha: 0.60),
        Colors.white.withValues(alpha: 0.0),
      ],
      [0.0, 0.35, 1.0],
    );
    canvas.drawRect(Offset.zero & size, paint);

    // Drifting cumulus clouds
    _drawDriftingCloud(canvas, w, h, time, 0.15, 0.30, w * 0.38, 0.30, 0.06);
    _drawDriftingCloud(canvas, w, h, time, 0.58, 0.38, w * 0.42, 0.28, 0.04);
    _drawDriftingCloud(canvas, w, h, time, 0.30, 0.62, w * 0.35, 0.22, 0.05);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _MostlySunnyNightPainter extends CustomPainter {
  final List<_Star> stars;
  final Random random;
  final double time;

  _MostlySunnyNightPainter(this.stars, this.random, this.time);

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

    // Moon
    final moonPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.white.withValues(alpha: 0.15)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 25);
    canvas.drawCircle(Offset(w * 0.8, h * 0.12), 50, moonPaint);

    moonPaint
      ..color = Colors.white.withValues(alpha: 0.4)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawCircle(Offset(w * 0.8, h * 0.12), 25, moonPaint);

    // Drifting cumulus clouds (same positions as day)
    _drawDriftingCloud(canvas, w, h, time, 0.15, 0.30, w * 0.38, 0.30, 0.04);
    _drawDriftingCloud(canvas, w, h, time, 0.58, 0.38, w * 0.42, 0.28, 0.03);
    _drawDriftingCloud(canvas, w, h, time, 0.30, 0.62, w * 0.35, 0.22, 0.035);
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
  // Continuous horizontal drift with wrap-around
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
