import 'dart:math';

import 'package:flutter/material.dart';

import 'particle.dart';

class DrizzleBackground extends StatefulWidget {
  final List<Color> gradientColors;
  final bool isActive;

  const DrizzleBackground({
    super.key,
    required this.gradientColors,
    this.isActive = true,
  });

  @override
  State<DrizzleBackground> createState() => _DrizzleBackgroundState();
}

class _DrizzleBackgroundState extends State<DrizzleBackground>
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
    for (var i = 0; i < 75; i++) {
      _drops.add(
        Particle(
          x: _random.nextDouble() * width,
          y: _random.nextDouble() * height,
          speed: 2.5 + _random.nextDouble() * 2.5,
          size: 0.5 + _random.nextDouble() * 0.9,
          opacity: 0.06 + _random.nextDouble() * 0.19,
        ),
      );
    }
  }

  void _tick() {
    final now = _controller.lastElapsedDuration ?? Duration.zero;
    final dtMs = (now - _previousFrameTime).inMilliseconds;
    _previousFrameTime = now;

    // Clamp to avoid huge jumps after app resume or debugger pause
    final dt = (dtMs.clamp(0, 50)) / 16.667; // normalize: 1.0 at 60fps

    final size = context.size;
    if (size == null || _drops.isEmpty) return;

    for (final drop in _drops) {
      drop.y += drop.speed * dt;
      drop.x += 0.3 * dt;

      if (drop.y > size.height) {
        drop.y = -10;
        drop.x = _random.nextDouble() * size.width;
      }
      if (drop.x > size.width) drop.x = 0;
    }
  }

  @override
  void didUpdateWidget(DrizzleBackground oldWidget) {
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
            foregroundPainter: _DrizzlePainter(_drops),
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

class _DrizzlePainter extends CustomPainter {
  final List<Particle> drops;

  _DrizzlePainter(this.drops);

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
        Offset(drop.x + 0.3, drop.y + 5 + drop.speed * 0.8),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_DrizzlePainter oldDelegate) => true;
}
