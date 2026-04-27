import 'dart:math';

import 'package:flutter/material.dart';

import 'particle.dart';

class FreezingRainBackground extends StatefulWidget {
  final List<Color> gradientColors;
  final bool isActive;

  const FreezingRainBackground({
    super.key,
    required this.gradientColors,
    this.isActive = true,
  });

  @override
  State<FreezingRainBackground> createState() => _FreezingRainBackgroundState();
}

class _FreezingRainBackgroundState extends State<FreezingRainBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  final List<Particle> _drops = [];
  final Random _random = Random();
  Duration _previousFrameTime = Duration.zero;
  double _elapsedTime = 0;

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
    for (var i = 0; i < 90; i++) {
      _drops.add(
        Particle(
          x: _random.nextDouble() * width,
          y: _random.nextDouble() * height,
          speed: 3.0 + _random.nextDouble() * 7.0,
          size: 1.0 + _random.nextDouble() * 2.0,
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
    _elapsedTime += (dtMs.clamp(0, 50)) / 1000.0 * 0.6;

    final size = context.size;
    if (size == null || _drops.isEmpty) return;

    for (final drop in _drops) {
      drop.y += drop.speed * dt;
      drop.x += 0.6 * dt;

      if (drop.y > size.height) {
        drop.y = -10;
        drop.x = _random.nextDouble() * size.width;
      }
      if (drop.x > size.width) drop.x = 0;
    }
  }

  @override
  void didUpdateWidget(FreezingRainBackground oldWidget) {
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
            foregroundPainter: _FreezingRainPainter(_drops, _elapsedTime),
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

class _FreezingRainPainter extends CustomPainter {
  final List<Particle> drops;
  final double time;

  _FreezingRainPainter(this.drops, this.time);

  @override
  void paint(Canvas canvas, Size size) {
    if (drops.isEmpty) return;

    final paint = Paint()
      ..strokeCap = StrokeCap.butt
      ..blendMode = BlendMode.plus;

    for (final drop in drops) {
      // Alternate between icy blue and white drops (size is fixed per particle)
      paint
        ..color = (drop.cachedColor ??= drop.size > 2.0
            ? Color.fromRGBO(176, 224, 255, drop.opacity)
            : Color.fromRGBO(255, 255, 255, drop.opacity))
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
  bool shouldRepaint(_FreezingRainPainter oldDelegate) => true;
}
