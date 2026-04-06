import 'dart:math';

import 'package:flutter/material.dart';

import 'particle.dart';

class FreezingRainBackground extends StatefulWidget {
  final List<Color> gradientColors;
  final bool isActive;

  const FreezingRainBackground({super.key, required this.gradientColors, this.isActive = true});

  @override
  State<FreezingRainBackground> createState() => _FreezingRainBackgroundState();
}

class _FreezingRainBackgroundState extends State<FreezingRainBackground>
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
  void didUpdateWidget(FreezingRainBackground oldWidget) {
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
        final time = _stopwatch.elapsedMilliseconds / 1000.0 * 0.6;
        return CustomPaint(
          foregroundPainter: _FreezingRainPainter(_drops, _random, time),
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

class _FreezingRainPainter extends CustomPainter {
  final List<Particle> drops;
  final Random random;
  final double time;

  _FreezingRainPainter(this.drops, this.random, this.time);

  @override
  void paint(Canvas canvas, Size size) {
    if (drops.isEmpty) {
      for (var i = 0; i < 90; i++) {
        drops.add(
          Particle(
            x: random.nextDouble() * size.width,
            y: random.nextDouble() * size.height,
            speed: 3.0 + random.nextDouble() * 7.0,
            size: 1.0 + random.nextDouble() * 2.0,
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
      drop.x += 0.6;

      if (drop.y > size.height) {
        drop.y = -10;
        drop.x = random.nextDouble() * size.width;
      }
      if (drop.x > size.width) drop.x = 0;

      // Alternate between icy blue and white drops
      paint
        ..color = drop.size > 2.0
            ? Color.fromRGBO(176, 224, 255, drop.opacity)
            : Color.fromRGBO(255, 255, 255, drop.opacity)
        ..strokeWidth = drop.size;

      canvas.drawLine(
        Offset(drop.x, drop.y),
        Offset(drop.x + 0.6, drop.y + 10 + drop.speed),
        paint,
      );
    }

    // Icy sheen overlay — subtle frost shimmer
    final sheenAlpha = 0.04 + sin(time * 0.5) * 0.02;
    final sheenPaint = Paint()
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 80)
      ..color = Color.fromRGBO(176, 224, 255, sheenAlpha);

    canvas.drawCircle(
      Offset(size.width * 0.3, size.height * 0.7),
      size.width * 0.5,
      sheenPaint,
    );
  }

  @override
  bool shouldRepaint(_FreezingRainPainter oldDelegate) =>
      oldDelegate.time != time;
}
