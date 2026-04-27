import 'dart:math';

import 'package:flutter/material.dart';

import 'particle.dart';

class ThunderstormBackground extends StatefulWidget {
  final List<Color> gradientColors;
  final bool isActive;

  const ThunderstormBackground({
    super.key,
    required this.gradientColors,
    this.isActive = true,
  });

  @override
  State<ThunderstormBackground> createState() => _ThunderstormBackgroundState();
}

class _ThunderstormBackgroundState extends State<ThunderstormBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  final List<Particle> _drops = [];
  final Random _random = Random();
  Duration _previousFrameTime = Duration.zero;
  double _lightningOpacity = 0;
  double _nextFlash = 2.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    if (widget.isActive) {
      _controller.repeat();
    }
    _controller.addListener(_tick);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _drops.isEmpty) {
        final size = context.size;
        if (size != null) _initDrops(size.width, size.height);
      }
    });
  }

  void _initDrops(double width, double height) {
    for (var i = 0; i < 120; i++) {
      _drops.add(
        Particle(
          x: _random.nextDouble() * width,
          y: _random.nextDouble() * height,
          speed: 6.0 + _random.nextDouble() * 10.0,
          size: 1.0 + _random.nextDouble() * 1.5,
          opacity: 0.1 + _random.nextDouble() * 0.3,
        ),
      );
    }
  }

  void _tick() {
    final now = _controller.lastElapsedDuration ?? Duration.zero;
    final dtMs = (now - _previousFrameTime).inMilliseconds;
    _previousFrameTime = now;
    final dt = (dtMs.clamp(0, 50)) / 16.667;

    // Lightning
    if (_lightningOpacity > 0) {
      _lightningOpacity -= 0.08;
      if (_lightningOpacity < 0) _lightningOpacity = 0;
    }
    _nextFlash -= 0.016;
    if (_nextFlash <= 0) {
      _lightningOpacity = 0.6 + _random.nextDouble() * 0.4;
      _nextFlash = 2.0 + _random.nextDouble() * 5.0;
    }

    // Rain drops
    final size = context.size;
    if (size == null || _drops.isEmpty) return;

    for (final drop in _drops) {
      drop.y += drop.speed * dt;
      drop.x += 1.5 * dt;

      if (drop.y > size.height) {
        drop.y = -10;
        drop.x = _random.nextDouble() * size.width;
      }
      if (drop.x > size.width) drop.x = 0;
    }
  }

  @override
  void didUpdateWidget(ThunderstormBackground oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive != oldWidget.isActive) {
      if (widget.isActive) {
        _previousFrameTime = _controller.lastElapsedDuration ?? Duration.zero;
        _controller.repeat();
      } else {
        _controller.stop();
      }
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_tick);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return RepaintBoundary(
          child: CustomPaint(
            foregroundPainter: _ThunderstormPainter(
              _drops,
              _lightningOpacity,
            ),
            size: Size.infinite,
            child: child,
          ),
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

class _ThunderstormPainter extends CustomPainter {
  final List<Particle> drops;
  final double lightningOpacity;

  _ThunderstormPainter(this.drops, this.lightningOpacity);

  @override
  void paint(Canvas canvas, Size size) {
    if (drops.isEmpty) return;

    // Rain
    final paint = Paint()
      ..strokeCap = StrokeCap.butt
      ..blendMode = BlendMode.plus;

    for (final drop in drops) {
      paint
        ..color = (drop.cachedColor ??= Color.fromRGBO(
          255,
          255,
          255,
          drop.opacity,
        ))
        ..strokeWidth = drop.size;

      canvas.drawLine(
        Offset(drop.x, drop.y),
        Offset(drop.x + 1.5, drop.y + 15 + drop.speed),
        paint,
      );
    }

    // Lightning flash overlay
    if (lightningOpacity > 0) {
      final flashPaint = Paint()
        ..color = Color.fromRGBO(255, 255, 255, lightningOpacity * 0.22)
        ..style = PaintingStyle.fill;
      canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), flashPaint);
    }
  }

  @override
  bool shouldRepaint(_ThunderstormPainter oldDelegate) => true;
}
