import 'dart:math';

import 'package:flutter/material.dart';

import '../../../../../core/constants/app_colors.dart';
import 'particle.dart';

class BlizzardBackground extends StatefulWidget {
  final List<Color> gradientColors;
  final bool isActive;

  const BlizzardBackground({
    super.key,
    required this.gradientColors,
    this.isActive = true,
  });

  @override
  State<BlizzardBackground> createState() => _BlizzardBackgroundState();
}

class _BlizzardBackgroundState extends State<BlizzardBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  final List<Particle> _flakes = [];
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
      if (mounted && _flakes.isEmpty) {
        final size = context.size;
        if (size != null) _initFlakes(size.width, size.height);
      }
    });
  }

  void _initFlakes(double width, double height) {
    for (var i = 0; i < 150; i++) {
      _flakes.add(
        Particle(
          x: _random.nextDouble() * width,
          y: _random.nextDouble() * height,
          speed: 1.5 + _random.nextDouble() * 4.0,
          size: 1.5 + _random.nextDouble() * 3.5,
          opacity: 0.15 + _random.nextDouble() * 0.45,
          wobble: _random.nextDouble() * 2 * pi,
        ),
      );
    }
  }

  void _tick() {
    final now = _controller.lastElapsedDuration ?? Duration.zero;
    final dtMs = (now - _previousFrameTime).inMilliseconds;
    _previousFrameTime = now;
    final dt = (dtMs.clamp(0, 50)) / 16.667;
    _elapsedTime += (dtMs.clamp(0, 50)) / 1000.0 * 0.96;

    final size = context.size;
    if (size == null || _flakes.isEmpty) return;

    final wind = sin(_elapsedTime * 1.8) * 2.5 + 1.0;

    for (final flake in _flakes) {
      flake.y += flake.speed * dt;
      flake.x += (wind + sin(_elapsedTime * 1.8 + flake.wobble) * 1.2) * dt;

      if (flake.y > size.height + 10) {
        flake.y = -10;
        flake.x = _random.nextDouble() * size.width;
      }
      if (flake.x > size.width) flake.x = 0;
      if (flake.x < 0) flake.x = size.width;
    }
  }

  @override
  void didUpdateWidget(BlizzardBackground oldWidget) {
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
            foregroundPainter: _BlizzardPainter(_flakes, _elapsedTime),
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
        foregroundDecoration: const BoxDecoration(color: AppColors.black18),
      ),
    );
  }
}

class _BlizzardPainter extends CustomPainter {
  final List<Particle> flakes;
  final double time;

  _BlizzardPainter(this.flakes, this.time);

  @override
  void paint(Canvas canvas, Size size) {
    if (flakes.isEmpty) return;

    final paint = Paint()..style = PaintingStyle.fill;

    for (final flake in flakes) {
      paint.color = flake.cachedColor ??= Color.fromRGBO(
        255,
        255,
        255,
        flake.opacity,
      );
      canvas.drawCircle(Offset(flake.x, flake.y), flake.size / 2, paint);
    }

    // Whiteout haze
    final hazePaint = Paint()
      ..style = PaintingStyle.fill
      ..color = Color.fromRGBO(255, 255, 255, 0.06 + sin(time * 0.5) * 0.03)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 100);

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), hazePaint);
  }

  @override
  bool shouldRepaint(_BlizzardPainter oldDelegate) => true;
}
