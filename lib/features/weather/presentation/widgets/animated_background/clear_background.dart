import 'dart:math';

import 'package:flutter/material.dart';

class ClearBackground extends StatefulWidget {
  final bool isDay;
  final List<Color> gradientColors;

  const ClearBackground({
    super.key,
    required this.isDay,
    required this.gradientColors,
  });

  @override
  State<ClearBackground> createState() => _ClearBackgroundState();
}

class _ClearBackgroundState extends State<ClearBackground>
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
      _time += 0.01;
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
              ? _DayClearPainter(_time)
              : _NightClearPainter(_stars, _random, _time),
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

class _DayClearPainter extends CustomPainter {
  final double time;

  _DayClearPainter(this.time);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width * 0.75, size.height * 0.1);

    final glowPaint = Paint()
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 50);

    glowPaint.color = Colors.white.withValues(alpha: 0.1 + sin(time) * 0.03);
    canvas.drawCircle(center, 130, glowPaint);

    glowPaint.color = Colors.white.withValues(alpha: 0.15 + sin(time) * 0.03);
    canvas.drawCircle(center, 80, glowPaint);

    glowPaint.color = Colors.white.withValues(alpha: 0.25);
    glowPaint.maskFilter = const MaskFilter.blur(BlurStyle.normal, 20);
    canvas.drawCircle(center, 40, glowPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _NightClearPainter extends CustomPainter {
  final List<_Star> stars;
  final Random random;
  final double time;

  _NightClearPainter(this.stars, this.random, this.time);

  @override
  void paint(Canvas canvas, Size size) {
    if (stars.isEmpty) {
      for (var i = 0; i < 80; i++) {
        stars.add(
          _Star(
            x: random.nextDouble() * size.width,
            y: random.nextDouble() * size.height * 0.7,
            size: 0.5 + random.nextDouble() * 2.5,
            twinkleSpeed: 0.5 + random.nextDouble() * 2.0,
            phase: random.nextDouble() * 2 * pi,
          ),
        );
      }
    }

    final paint = Paint()..style = PaintingStyle.fill;

    for (final star in stars) {
      final twinkle = (sin(time * star.twinkleSpeed + star.phase) + 1) / 2;
      final opacity = 0.1 + twinkle * 0.3;

      paint.color = Colors.white.withValues(alpha: opacity);
      canvas.drawCircle(
        Offset(star.x, star.y),
        star.size * (0.8 + twinkle * 0.2),
        paint,
      );
    }

    // Moon
    final moonPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.white.withValues(alpha: 0.15)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 25);
    canvas.drawCircle(
      Offset(size.width * 0.8, size.height * 0.12),
      50,
      moonPaint,
    );

    moonPaint
      ..color = Colors.white.withValues(alpha: 0.4)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawCircle(
      Offset(size.width * 0.8, size.height * 0.12),
      25,
      moonPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
