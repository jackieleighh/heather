import 'dart:math';

import 'package:flutter/material.dart';

import 'particle.dart';

class SnowBackground extends StatefulWidget {
  final List<Color> gradientColors;
  final bool isActive;

  const SnowBackground({super.key, required this.gradientColors, this.isActive = true});

  @override
  State<SnowBackground> createState() => _SnowBackgroundState();
}

class _SnowBackgroundState extends State<SnowBackground>
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
  void didUpdateWidget(SnowBackground oldWidget) {
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
          foregroundPainter: _SnowPainter(_flakes, _random, time),
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

class _SnowPainter extends CustomPainter {
  final List<Particle> flakes;
  final Random random;
  final double time;

  _SnowPainter(this.flakes, this.random, this.time);

  @override
  void paint(Canvas canvas, Size size) {
    if (flakes.isEmpty) {
      for (var i = 0; i < 60; i++) {
        flakes.add(
          Particle(
            x: random.nextDouble() * size.width,
            y: random.nextDouble() * size.height,
            speed: 0.5 + random.nextDouble() * 2.0,
            size: 2.0 + random.nextDouble() * 5.0,
            opacity: 0.1 + random.nextDouble() * 0.3,
            wobble: random.nextDouble() * 2 * pi,
          ),
        );
      }
    }

    final paint = Paint()..style = PaintingStyle.fill;

    for (final flake in flakes) {
      flake.y += flake.speed;
      flake.x += sin(time * 1.5 + flake.wobble) * 0.8;

      if (flake.y > size.height + 10) {
        flake.y = -10;
        flake.x = random.nextDouble() * size.width;
      }
      if (flake.x < 0) flake.x = size.width;
      if (flake.x > size.width) flake.x = 0;

      paint.color = Color.fromRGBO(255, 255, 255, flake.opacity);
      canvas.drawCircle(Offset(flake.x, flake.y), flake.size / 2, paint);
    }
  }

  @override
  bool shouldRepaint(_SnowPainter oldDelegate) => oldDelegate.time != time;
}
