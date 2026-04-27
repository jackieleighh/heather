import 'dart:math';

import 'package:flutter/material.dart';

import 'particle.dart';

class HailBackground extends StatefulWidget {
  final List<Color> gradientColors;
  final bool isActive;

  const HailBackground({
    super.key,
    required this.gradientColors,
    this.isActive = true,
  });

  @override
  State<HailBackground> createState() => _HailBackgroundState();
}

class _HailBackgroundState extends State<HailBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  final List<Particle> _drops = [];
  final List<Particle> _hailStones = [];
  final Random _random = Random();
  double _lightningOpacity = 0;
  double _nextFlash = 3.0;
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
    _controller.addListener(_updateLightning);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _hailStones.isEmpty) {
        final size = context.size;
        if (size != null) _initHailStones(size.width, size.height);
      }
    });
  }

  void _initHailStones(double width, double height) {
    for (var i = 0; i < 60; i++) {
      _hailStones.add(
        Particle(
          x: _random.nextDouble() * width,
          y: _random.nextDouble() * height,
          speed: 4.0 + _random.nextDouble() * 8.0,
          size: 2.0 + _random.nextDouble() * 4.0,
          opacity: 0.1 + _random.nextDouble() * 0.3,
        ),
      );
    }
  }

  @override
  void didUpdateWidget(HailBackground oldWidget) {
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

  void _updateLightning() {
    if (_lightningOpacity > 0) {
      _lightningOpacity -= 0.08;
      if (_lightningOpacity < 0) _lightningOpacity = 0;
    }

    _nextFlash -= 0.016;
    if (_nextFlash <= 0) {
      _lightningOpacity = 0.5 + _random.nextDouble() * 0.4;
      _nextFlash = 2.5 + _random.nextDouble() * 5.0;
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
          foregroundPainter: _HailPainter(
            _drops,
            _hailStones,
            _random,
            _lightningOpacity,
            time,
          ),
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

class _HailPainter extends CustomPainter {
  final List<Particle> drops;
  final List<Particle> hailStones;
  final Random random;
  final double lightningOpacity;
  final double time;

  _HailPainter(
    this.drops,
    this.hailStones,
    this.random,
    this.lightningOpacity,
    this.time,
  );

  @override
  void paint(Canvas canvas, Size size) {
    if (hailStones.isEmpty) return;

    final paint = Paint()
      ..style = PaintingStyle.fill
      ..blendMode = BlendMode.plus;

    for (final stone in hailStones) {
      stone.y += stone.speed;
      stone.x += 0.5;

      if (stone.y > size.height) {
        stone.y = -10;
        stone.x = random.nextDouble() * size.width;
      }
      if (stone.x > size.width) stone.x = 0;

      paint.color = stone.cachedColor ??= Color.fromRGBO(
        255,
        255,
        255,
        stone.opacity,
      );
      canvas.drawCircle(Offset(stone.x, stone.y), stone.size / 2, paint);
    }

    // Lightning flash
    if (lightningOpacity > 0) {
      final flashPaint = Paint()
        ..color = Color.fromRGBO(255, 255, 255, lightningOpacity * 0.22)
        ..style = PaintingStyle.fill;
      canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), flashPaint);
    }
  }

  @override
  bool shouldRepaint(_HailPainter oldDelegate) =>
      oldDelegate.time != time ||
      oldDelegate.lightningOpacity != lightningOpacity;
}
