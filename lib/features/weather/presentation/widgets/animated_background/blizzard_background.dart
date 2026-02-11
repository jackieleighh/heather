import 'dart:math';

import 'package:flutter/material.dart';

import 'particle.dart';

class BlizzardBackground extends StatefulWidget {
  final List<Color> gradientColors;

  const BlizzardBackground({super.key, required this.gradientColors});

  @override
  State<BlizzardBackground> createState() => _BlizzardBackgroundState();
}

class _BlizzardBackgroundState extends State<BlizzardBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  final List<Particle> _flakes = [];
  final Random _random = Random();
  double _time = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();
    _controller.addListener(() {
      _time += 0.016;
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
          foregroundPainter: _BlizzardPainter(_flakes, _random, _time),
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

class _BlizzardPainter extends CustomPainter {
  final List<Particle> flakes;
  final Random random;
  final double time;

  _BlizzardPainter(this.flakes, this.random, this.time);

  @override
  void paint(Canvas canvas, Size size) {
    if (flakes.isEmpty) {
      for (var i = 0; i < 220; i++) {
        flakes.add(
          Particle(
            x: random.nextDouble() * size.width,
            y: random.nextDouble() * size.height,
            speed: 2.0 + random.nextDouble() * 5.0,
            size: 2.0 + random.nextDouble() * 6.0,
            opacity: 0.1 + random.nextDouble() * 0.3,
            wobble: random.nextDouble() * 2 * pi,
          ),
        );
      }
    }

    final paint = Paint()..style = PaintingStyle.fill;

    for (final flake in flakes) {
      flake.y += flake.speed;
      // Strong wind push
      flake.x += sin(time * 2.0 + flake.wobble) * 2.5 + 1.5;

      if (flake.y > size.height + 10) {
        flake.y = -10;
        flake.x = random.nextDouble() * size.width;
      }
      if (flake.x > size.width) flake.x = 0;
      if (flake.x < 0) flake.x = size.width;

      paint.color = Colors.white.withValues(alpha: flake.opacity);
      canvas.drawCircle(Offset(flake.x, flake.y), flake.size / 2, paint);
    }

    // Whiteout haze
    final hazePaint = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.white.withValues(alpha: 0.03 + sin(time * 0.4) * 0.015)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 80);

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), hazePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
