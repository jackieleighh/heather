import 'dart:math';

import 'package:flutter/material.dart';

import 'particle.dart';

class BlizzardBackground extends StatefulWidget {
  final List<Color> gradientColors;
  final bool isActive;

  const BlizzardBackground({super.key, required this.gradientColors, this.isActive = true});

  @override
  State<BlizzardBackground> createState() => _BlizzardBackgroundState();
}

class _BlizzardBackgroundState extends State<BlizzardBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  final List<Particle> _flakes = [];
  final Random _random = Random();
  final _stopwatch = Stopwatch();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    if (widget.isActive) {
      _controller.repeat();
      _stopwatch.start();
    }
  }

  @override
  void didUpdateWidget(BlizzardBackground oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive != oldWidget.isActive) {
      if (widget.isActive) {
        _controller.repeat();
        _stopwatch.start();
      } else {
        _controller.stop();
        _stopwatch.stop();
      }
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
        final time = _stopwatch.elapsedMilliseconds / 1000.0 * 0.96;
        return CustomPaint(
          foregroundPainter: _BlizzardPainter(_flakes, _random, time),
          size: Size.infinite,
          child: child,
        );
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: widget.gradientColors,
          ),
        ),
        foregroundDecoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.18),
        ),
      ),
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
      for (var i = 0; i < 150; i++) {
        flakes.add(
          Particle(
            x: random.nextDouble() * size.width,
            y: random.nextDouble() * size.height,
            speed: 1.5 + random.nextDouble() * 4.0,
            size: 1.5 + random.nextDouble() * 3.5,
            opacity: 0.15 + random.nextDouble() * 0.45,
            wobble: random.nextDouble() * 2 * pi,
          ),
        );
      }
    }

    final paint = Paint()..style = PaintingStyle.fill;

    // Pre-compute shared wind component once per frame
    final wind = sin(time * 1.8) * 2.5 + 1.0;

    for (final flake in flakes) {
      flake.y += flake.speed;
      flake.x += wind + sin(time * 1.8 + flake.wobble) * 1.2;

      if (flake.y > size.height + 10) {
        flake.y = -10;
        flake.x = random.nextDouble() * size.width;
      }
      if (flake.x > size.width) flake.x = 0;
      if (flake.x < 0) flake.x = size.width;

      paint.color = Color.fromRGBO(255, 255, 255, flake.opacity);
      canvas.drawCircle(Offset(flake.x, flake.y), flake.size / 2, paint);
    }

    // Whiteout haze
    final hazePaint = Paint()
      ..style = PaintingStyle.fill
      ..color = Color.fromRGBO(255, 255, 255, 0.06 + sin(time * 0.5) * 0.03)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 100);

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), hazePaint);
  }

  @override
  bool shouldRepaint(_BlizzardPainter oldDelegate) =>
      oldDelegate.time != time;
}
