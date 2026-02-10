import 'dart:math';

import 'package:flutter/material.dart';

import 'particle.dart';

class FreezingRainBackground extends StatefulWidget {
  final List<Color> gradientColors;

  const FreezingRainBackground({super.key, required this.gradientColors});

  @override
  State<FreezingRainBackground> createState() => _FreezingRainBackgroundState();
}

class _FreezingRainBackgroundState extends State<FreezingRainBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  final List<Particle> _drops = [];
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
      _time += 0.01;
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
          foregroundPainter: _FreezingRainPainter(_drops, _random, _time),
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

class _FreezingRainPainter extends CustomPainter {
  final List<Particle> drops;
  final Random random;
  final double time;

  _FreezingRainPainter(this.drops, this.random, this.time);

  static const _icyBlue = Color(0xFFB0E0FF);

  @override
  void paint(Canvas canvas, Size size) {
    if (drops.isEmpty) {
      for (var i = 0; i < 180; i++) {
        drops.add(
          Particle(
            x: random.nextDouble() * size.width,
            y: random.nextDouble() * size.height,
            speed: 3.0 + random.nextDouble() * 7.0,
            size: 1.0 + random.nextDouble() * 2.0,
            opacity: 0.25 + random.nextDouble() * 0.5,
          ),
        );
      }
    }

    final paint = Paint()..strokeCap = StrokeCap.round;

    for (final drop in drops) {
      drop.y += drop.speed;
      drop.x += 0.6;

      if (drop.y > size.height) {
        drop.y = -10;
        drop.x = random.nextDouble() * size.width;
      }
      if (drop.x > size.width) drop.x = 0;

      // Alternate between icy blue and white drops
      final color = drop.size > 2.0 ? _icyBlue : Colors.white;
      paint
        ..color = color.withValues(alpha: drop.opacity)
        ..strokeWidth = drop.size;

      canvas.drawLine(
        Offset(drop.x, drop.y),
        Offset(drop.x + 0.6, drop.y + 10 + drop.speed),
        paint,
      );
    }

    // Icy sheen overlay — subtle frost shimmer
    final sheenPaint = Paint()
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 80);

    sheenPaint.color = _icyBlue.withValues(
      alpha: 0.04 + sin(time * 0.5) * 0.02,
    );
    canvas.drawCircle(
      Offset(size.width * 0.3, size.height * 0.7),
      size.width * 0.5,
      sheenPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
