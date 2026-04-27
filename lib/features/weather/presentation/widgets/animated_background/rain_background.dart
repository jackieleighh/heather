import 'dart:math';

import 'package:flutter/material.dart';

import 'particle.dart';

class RainBackground extends StatefulWidget {
  final List<Color> gradientColors;
  final bool isActive;

  const RainBackground({
    super.key,
    required this.gradientColors,
    this.isActive = true,
  });

  @override
  State<RainBackground> createState() => _RainBackgroundState();
}

class _RainBackgroundState extends State<RainBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  final List<Particle> _drops = [];
  final Random _random = Random();
  Duration _previousFrameTime = Duration.zero;

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
    for (var i = 0; i < 80; i++) {
      _drops.add(
        Particle(
          x: _random.nextDouble() * width,
          y: _random.nextDouble() * height,
          speed: 5.0 + _random.nextDouble() * 6.0,
          size: 0.9 + _random.nextDouble() * 1.8,
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

    final size = context.size;
    if (size == null || _drops.isEmpty) return;

    for (final drop in _drops) {
      drop.y += drop.speed * dt;
      drop.x += 0.8 * dt;

      if (drop.y > size.height) {
        drop.y = -10;
        drop.x = _random.nextDouble() * size.width;
      }
      if (drop.x > size.width) {
        drop.x = 0;
      }
    }
  }

  @override
  void didUpdateWidget(RainBackground oldWidget) {
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
            foregroundPainter: _RainPainter(_drops),
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

class _RainPainter extends CustomPainter {
  final List<Particle> drops;

  _RainPainter(this.drops);

  @override
  void paint(Canvas canvas, Size size) {
    if (drops.isEmpty) return;

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
        Offset(drop.x + 0.8, drop.y + 14 + drop.speed),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_RainPainter oldDelegate) => true;
}
