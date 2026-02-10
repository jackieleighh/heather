import 'dart:math';

import 'package:flutter/material.dart';

import '../../../../../core/constants/app_colors.dart';
import 'particle.dart';

class RainBackground extends StatefulWidget {
  const RainBackground({super.key});

  @override
  State<RainBackground> createState() => _RainBackgroundState();
}

class _RainBackgroundState extends State<RainBackground>
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
          painter: _RainPainter(_drops, _random),
          size: Size.infinite,
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.darkTeal,
                  AppColors.deepPurple,
                  AppColors.mutedTeal,
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _RainPainter extends CustomPainter {
  final List<Particle> drops;
  final Random random;

  _RainPainter(this.drops, this.random);

  @override
  void paint(Canvas canvas, Size size) {
    if (drops.isEmpty) {
      for (var i = 0; i < 200; i++) {
        drops.add(
          Particle(
            x: random.nextDouble() * size.width,
            y: random.nextDouble() * size.height,
            speed: 4.0 + random.nextDouble() * 8.0,
            size: 1.0 + random.nextDouble() * 2.0,
            opacity: 0.2 + random.nextDouble() * 0.5,
          ),
        );
      }
    }

    final paint = Paint()..strokeCap = StrokeCap.round;

    for (final drop in drops) {
      drop.y += drop.speed;
      drop.x += 0.5;

      if (drop.y > size.height) {
        drop.y = -10;
        drop.x = random.nextDouble() * size.width;
      }
      if (drop.x > size.width) {
        drop.x = 0;
      }

      paint
        ..color = Colors.white.withValues(alpha: drop.opacity)
        ..strokeWidth = drop.size;

      canvas.drawLine(
        Offset(drop.x, drop.y),
        Offset(drop.x + 0.5, drop.y + 12 + drop.speed),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
