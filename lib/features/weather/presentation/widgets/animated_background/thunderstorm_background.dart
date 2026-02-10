import 'dart:math';

import 'package:flutter/material.dart';

import 'particle.dart';

class ThunderstormBackground extends StatefulWidget {
  final List<Color> gradientColors;

  const ThunderstormBackground({super.key, required this.gradientColors});

  @override
  State<ThunderstormBackground> createState() => _ThunderstormBackgroundState();
}

class _ThunderstormBackgroundState extends State<ThunderstormBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  final List<Particle> _drops = [];
  final Random _random = Random();
  double _lightningOpacity = 0;
  double _nextFlash = 2.0;

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
      _lightningOpacity = 0.6 + _random.nextDouble() * 0.4;
      _nextFlash = 2.0 + _random.nextDouble() * 5.0;
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
          foregroundPainter: _ThunderstormPainter(_drops, _random, _lightningOpacity),
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
                    _lightningOpacity * 0.15,
                  )!,
                  Color.lerp(
                    widget.gradientColors[1],
                    Colors.white,
                    _lightningOpacity * 0.1,
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

class _ThunderstormPainter extends CustomPainter {
  final List<Particle> drops;
  final Random random;
  final double lightningOpacity;

  _ThunderstormPainter(this.drops, this.random, this.lightningOpacity);

  @override
  void paint(Canvas canvas, Size size) {
    if (drops.isEmpty) {
      for (var i = 0; i < 250; i++) {
        drops.add(
          Particle(
            x: random.nextDouble() * size.width,
            y: random.nextDouble() * size.height,
            speed: 6.0 + random.nextDouble() * 10.0,
            size: 1.0 + random.nextDouble() * 1.5,
            opacity: 0.15 + random.nextDouble() * 0.35,
          ),
        );
      }
    }

    // Rain
    final paint = Paint()..strokeCap = StrokeCap.round;

    for (final drop in drops) {
      drop.y += drop.speed;
      drop.x += 1.5;

      if (drop.y > size.height) {
        drop.y = -10;
        drop.x = random.nextDouble() * size.width;
      }
      if (drop.x > size.width) drop.x = 0;

      paint
        ..color = Colors.white.withValues(alpha: drop.opacity)
        ..strokeWidth = drop.size;

      canvas.drawLine(
        Offset(drop.x, drop.y),
        Offset(drop.x + 1.5, drop.y + 15 + drop.speed),
        paint,
      );
    }

    // Lightning flash overlay
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
