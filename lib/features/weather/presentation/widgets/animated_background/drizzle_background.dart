import 'dart:math';

import 'package:flutter/material.dart';

import 'particle.dart';

class DrizzleBackground extends StatefulWidget {
  final List<Color> gradientColors;

  const DrizzleBackground({super.key, required this.gradientColors});

  @override
  State<DrizzleBackground> createState() => _DrizzleBackgroundState();
}

class _DrizzleBackgroundState extends State<DrizzleBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  final List<Particle> _drops = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();
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
          foregroundPainter: _DrizzlePainter(_drops, _random),
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

class _DrizzlePainter extends CustomPainter {
  final List<Particle> drops;
  final Random random;

  _DrizzlePainter(this.drops, this.random);

  @override
  void paint(Canvas canvas, Size size) {
    if (drops.isEmpty) {
      for (var i = 0; i < 80; i++) {
        drops.add(
          Particle(
            x: random.nextDouble() * size.width,
            y: random.nextDouble() * size.height,
            speed: 2.0 + random.nextDouble() * 4.0,
            size: 0.8 + random.nextDouble() * 1.2,
            opacity: 0.15 + random.nextDouble() * 0.3,
          ),
        );
      }
    }

    final paint = Paint()..strokeCap = StrokeCap.round;

    for (final drop in drops) {
      drop.y += drop.speed;
      drop.x += 0.3;

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
        Offset(drop.x + 0.3, drop.y + 8 + drop.speed),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
