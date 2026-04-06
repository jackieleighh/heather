import 'dart:math';

import 'package:flutter/material.dart';

import 'particle.dart';

class DrizzleBackground extends StatefulWidget {
  final List<Color> gradientColors;
  final bool isActive;

  const DrizzleBackground({super.key, required this.gradientColors, this.isActive = true});

  @override
  State<DrizzleBackground> createState() => _DrizzleBackgroundState();
}

class _DrizzleBackgroundState extends State<DrizzleBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  final List<Particle> _drops = [];
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
  void didUpdateWidget(DrizzleBackground oldWidget) {
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
          foregroundPainter: _DrizzlePainter(_drops, _random, time),
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
      ),
    );
  }
}

class _DrizzlePainter extends CustomPainter {
  final List<Particle> drops;
  final Random random;
  final double time;

  _DrizzlePainter(this.drops, this.random, this.time);

  @override
  void paint(Canvas canvas, Size size) {
    if (drops.isEmpty) {
      for (var i = 0; i < 50; i++) {
        drops.add(
          Particle(
            x: random.nextDouble() * size.width,
            y: random.nextDouble() * size.height,
            speed: 1.8 + random.nextDouble() * 2.7,
            size: 0.5 + random.nextDouble() * 0.9,
            opacity: 0.08 + random.nextDouble() * 0.18,
          ),
        );
      }
    }

    final paint = Paint()
      ..strokeCap = StrokeCap.butt
      ..blendMode = BlendMode.plus;

    for (final drop in drops) {
      drop.y += drop.speed;
      drop.x += 0.2;

      if (drop.y > size.height) {
        drop.y = -10;
        drop.x = random.nextDouble() * size.width;
      }
      if (drop.x > size.width) drop.x = 0;

      paint
        ..color = Color.fromRGBO(255, 255, 255, drop.opacity)
        ..strokeWidth = drop.size;

      canvas.drawLine(
        Offset(drop.x, drop.y),
        Offset(drop.x + 0.2, drop.y + 6 + drop.speed),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_DrizzlePainter oldDelegate) => oldDelegate.time != time;
}
