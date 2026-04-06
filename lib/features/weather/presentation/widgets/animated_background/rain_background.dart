import 'dart:math';

import 'package:flutter/material.dart';

import 'particle.dart';

class RainBackground extends StatefulWidget {
  final List<Color> gradientColors;
  final bool isActive;

  const RainBackground({super.key, required this.gradientColors, this.isActive = true});

  @override
  State<RainBackground> createState() => _RainBackgroundState();
}

class _RainBackgroundState extends State<RainBackground>
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
  void didUpdateWidget(RainBackground oldWidget) {
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
          foregroundPainter: _RainPainter(_drops, _random, time),
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

class _RainPainter extends CustomPainter {
  final List<Particle> drops;
  final Random random;
  final double time;

  _RainPainter(this.drops, this.random, this.time);

  @override
  void paint(Canvas canvas, Size size) {
    if (drops.isEmpty) {
      for (var i = 0; i < 80; i++) {
        drops.add(
          Particle(
            x: random.nextDouble() * size.width,
            y: random.nextDouble() * size.height,
            speed: 5.0 + random.nextDouble() * 6.0,
            size: 0.9 + random.nextDouble() * 1.8,
            opacity: 0.1 + random.nextDouble() * 0.3,
          ),
        );
      }
    }

    final paint = Paint()
      ..strokeCap = StrokeCap.butt
      ..blendMode = BlendMode.plus;

    for (final drop in drops) {
      drop.y += drop.speed;
      drop.x += 0.8;

      if (drop.y > size.height) {
        drop.y = -10;
        drop.x = random.nextDouble() * size.width;
      }
      if (drop.x > size.width) {
        drop.x = 0;
      }

      paint
        ..color = Color.fromRGBO(255, 255, 255, drop.opacity)
        ..strokeWidth = drop.size;

      canvas.drawLine(
        Offset(drop.x, drop.y),
        Offset(drop.x + 0.8, drop.y + 14 + drop.speed),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_RainPainter oldDelegate) => oldDelegate.time != time;
}
