import 'dart:math';

import 'package:flutter/material.dart';

import 'particle.dart';

class HailBackground extends StatefulWidget {
  final List<Color> gradientColors;

  const HailBackground({super.key, required this.gradientColors});

  @override
  State<HailBackground> createState() => _HailBackgroundState();
}

class _HailBackgroundState extends State<HailBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  final List<Particle> _drops = [];
  final List<Particle> _hailStones = [];
  final Random _random = Random();
  double _lightningOpacity = 0;
  double _nextFlash = 3.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();
    _controller.addListener(_updateLightning);
  }

  void _updateLightning() {
    if (_lightningOpacity > 0) {
      _lightningOpacity -= 0.08;
      if (_lightningOpacity < 0) _lightningOpacity = 0;
    }

    _nextFlash -= 0.016;
    if (_nextFlash <= 0) {
      _lightningOpacity = 0.5 + _random.nextDouble() * 0.4;
      _nextFlash = 2.5 + _random.nextDouble() * 5.0;
    }
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
          foregroundPainter: _HailPainter(
            _drops,
            _hailStones,
            _random,
            _lightningOpacity,
          ),
          size: Size.infinite,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color.lerp(
                    widget.gradientColors[0],
                    Colors.white,
                    _lightningOpacity * 0.12,
                  )!,
                  Color.lerp(
                    widget.gradientColors[1],
                    Colors.white,
                    _lightningOpacity * 0.08,
                  )!,
                  widget.gradientColors[2],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _HailPainter extends CustomPainter {
  final List<Particle> drops;
  final List<Particle> hailStones;
  final Random random;
  final double lightningOpacity;

  _HailPainter(this.drops, this.hailStones, this.random, this.lightningOpacity);

  @override
  void paint(Canvas canvas, Size size) {
    // Rain drops
    if (drops.isEmpty) {
      for (var i = 0; i < 200; i++) {
        drops.add(
          Particle(
            x: random.nextDouble() * size.width,
            y: random.nextDouble() * size.height,
            speed: 6.0 + random.nextDouble() * 8.0,
            size: 1.0 + random.nextDouble() * 1.5,
            opacity: 0.15 + random.nextDouble() * 0.3,
          ),
        );
      }
    }

    // Hail stones
    if (hailStones.isEmpty) {
      for (var i = 0; i < 40; i++) {
        hailStones.add(
          Particle(
            x: random.nextDouble() * size.width,
            y: random.nextDouble() * size.height,
            speed: 5.0 + random.nextDouble() * 8.0,
            size: 3.0 + random.nextDouble() * 5.0,
            opacity: 0.5 + random.nextDouble() * 0.5,
            wobble: random.nextDouble() * 2 * pi,
          ),
        );
      }
    }

    // Draw rain
    final rainPaint = Paint()..strokeCap = StrokeCap.round;

    for (final drop in drops) {
      drop.y += drop.speed;
      drop.x += 1.2;

      if (drop.y > size.height) {
        drop.y = -10;
        drop.x = random.nextDouble() * size.width;
      }
      if (drop.x > size.width) drop.x = 0;

      rainPaint
        ..color = Colors.white.withValues(alpha: drop.opacity)
        ..strokeWidth = drop.size;

      canvas.drawLine(
        Offset(drop.x, drop.y),
        Offset(drop.x + 1.2, drop.y + 14 + drop.speed),
        rainPaint,
      );
    }

    // Draw hail stones
    final hailPaint = Paint()..style = PaintingStyle.fill;
    final hailBorderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    for (final stone in hailStones) {
      stone.y += stone.speed;
      stone.x += 0.8;

      if (stone.y > size.height) {
        stone.y = -10;
        stone.x = random.nextDouble() * size.width;
      }
      if (stone.x > size.width) stone.x = 0;

      hailPaint.color = Colors.white.withValues(alpha: stone.opacity * 0.6);
      hailBorderPaint.color = Colors.white.withValues(
        alpha: stone.opacity * 0.8,
      );

      canvas.drawCircle(Offset(stone.x, stone.y), stone.size / 2, hailPaint);
      canvas.drawCircle(
        Offset(stone.x, stone.y),
        stone.size / 2,
        hailBorderPaint,
      );
    }

    // Lightning flash
    if (lightningOpacity > 0) {
      final flashPaint = Paint()
        ..color = Colors.white.withValues(alpha: lightningOpacity * 0.15)
        ..style = PaintingStyle.fill;
      canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), flashPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
