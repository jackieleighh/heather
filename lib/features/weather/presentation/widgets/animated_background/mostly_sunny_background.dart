import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import 'cloud_painter.dart';

class MostlySunnyBackground extends StatefulWidget {
  final List<Color> gradientColors;
  final bool isDay;
  final bool isActive;

  const MostlySunnyBackground({
    super.key,
    required this.gradientColors,
    required this.isDay,
    this.isActive = true,
  });

  @override
  State<MostlySunnyBackground> createState() => _MostlySunnyBackgroundState();
}

class _MostlySunnyBackgroundState extends State<MostlySunnyBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  final List<_Star> _stars = [];
  final Random _random = Random();

  final _rayColors = List<Color>.filled(12, const Color(0x00FFFFFF));
  double _lastColorTime = -1;

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && !widget.isDay && _stars.isEmpty) {
        final size = context.size;
        if (size != null) _initStars(size.width, size.height);
      }
    });
  }

  void _initStars(double width, double height) {
    for (var i = 0; i < 80; i++) {
      _stars.add(
        _Star(
          x: _random.nextDouble() * width,
          y: _random.nextDouble() * height * 0.7,
          size: 0.5 + _random.nextDouble() * 2.5,
          twinkleSpeed: 0.5 + _random.nextDouble() * 2.0,
          phase: _random.nextDouble() * 2 * pi,
        ),
      );
    }
  }

  @override
  void didUpdateWidget(MostlySunnyBackground oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive != oldWidget.isActive) {
      if (widget.isActive) {
        _controller.repeat();
      } else {
        _controller.stop();
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
        final time =
            (_controller.lastElapsedDuration?.inMilliseconds ?? 0) /
                1000.0 *
                0.6;
        if (widget.isDay && (time - _lastColorTime).abs() > 0.033) {
          _lastColorTime = time;
          const rayAlphas = [
            0.22,
            0.14,
            0.20,
            0.11,
            0.21,
            0.15,
            0.18,
            0.13,
            0.17,
            0.13,
            0.21,
            0.10,
          ];
          for (var i = 0; i < 12; i++) {
            final alpha = rayAlphas[i] + sin(time * 0.5 + i * 0.7).abs() * 0.03;
            _rayColors[i] = Color.fromRGBO(255, 255, 255, alpha);
          }
        }
        return RepaintBoundary(
          child: CustomPaint(
            foregroundPainter: widget.isDay
                ? _MostlySunnyDayPainter(time, _rayColors)
                : _MostlySunnyNightPainter(_stars, _random, time),
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

class _Star {
  final double x;
  final double y;
  final double size;
  final double twinkleSpeed;
  final double phase;
  Color? cachedColor;

  _Star({
    required this.x,
    required this.y,
    required this.size,
    required this.twinkleSpeed,
    required this.phase,
  });
}

class _MostlySunnyDayPainter extends CustomPainter {
  final double time;
  final List<Color> rayColors;

  _MostlySunnyDayPainter(this.time, this.rayColors);

  static const _white0 = Color.fromRGBO(255, 255, 255, 0);

  /// Pre-allocated color pair lists for ray gradients (one per ray).
  static final _rayGradientColors = List.generate(12, (_) => [_white0, _white0]);
  static const _glowColors = [
    Color.fromRGBO(255, 255, 255, 0.30),
    Color.fromRGBO(255, 255, 255, 0.08),
    _white0,
  ];
  static const _coreColors = [
    Color.fromRGBO(255, 255, 255, 0.85),
    Color.fromRGBO(255, 255, 255, 0.40),
    _white0,
  ];
  static const _glowStops = [0.0, 0.5, 1.0];
  static const _coreStops = [0.0, 0.35, 1.0];

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final center = Offset(w * 0.8, h * 0.12);
    final paint = Paint()..style = PaintingStyle.fill;

    // 1. Rays — narrow, distinct beams with varying lengths
    final rayPaint = Paint()
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
    const rayAngles = [
      0.0,
      0.55,
      1.05,
      1.6,
      2.15,
      2.65,
      3.2,
      3.75,
      4.3,
      4.85,
      5.35,
      5.9,
    ];
    const rayLengths = [
      300.0,
      190.0,
      260.0,
      160.0,
      290.0,
      210.0,
      270.0,
      180.0,
      240.0,
      200.0,
      280.0,
      185.0,
    ];
    const raySpreads = [
      0.055,
      0.037,
      0.05,
      0.032,
      0.055,
      0.04,
      0.05,
      0.037,
      0.045,
      0.037,
      0.055,
      0.032,
    ];
    const innerR = 22.0;
    final spin = time * 0.15;

    for (var i = 0; i < rayAngles.length; i++) {
      final angle = rayAngles[i] + spin;
      final outerR = rayLengths[i];
      final halfSpread = raySpreads[i];

      final cosA = cos(angle);
      final sinA = sin(angle);
      final cosL = cos(angle - halfSpread);
      final sinL = sin(angle - halfSpread);
      final cosR = cos(angle + halfSpread);
      final sinR = sin(angle + halfSpread);

      final path = Path()
        ..moveTo(center.dx + cosL * innerR, center.dy + sinL * innerR)
        ..lineTo(center.dx + cosL * outerR, center.dy + sinL * outerR)
        ..lineTo(center.dx + cosR * outerR, center.dy + sinR * outerR)
        ..lineTo(center.dx + cosR * innerR, center.dy + sinR * innerR)
        ..close();

      final colors = _rayGradientColors[i];
      colors[0] = rayColors[i];
      colors[1] = _white0;
      rayPaint.shader = ui.Gradient.linear(
        Offset(center.dx + cosA * innerR, center.dy + sinA * innerR),
        Offset(center.dx + cosA * outerR, center.dy + sinA * outerR),
        colors,
      );
      canvas.drawPath(path, rayPaint);
    }

    // 2. Glow around core
    paint.shader = ui.Gradient.radial(center, 110, _glowColors, _glowStops);
    canvas.drawRect(Offset.zero & size, paint);

    // 3. Bright core
    paint.shader = ui.Gradient.radial(center, 45, _coreColors, _coreStops);
    canvas.drawRect(Offset.zero & size, paint);

    // Drifting cumulus clouds
    drawDriftingCloud(canvas, w, h, time, 0.15, 0.30, w * 0.38, 0.30, 0.14);
    drawDriftingCloud(canvas, w, h, time, 0.58, 0.38, w * 0.42, 0.28, 0.11);
    drawDriftingCloud(canvas, w, h, time, 0.30, 0.62, w * 0.35, 0.22, 0.12);
  }

  @override
  bool shouldRepaint(_MostlySunnyDayPainter oldDelegate) =>
      oldDelegate.time != time;
}

class _MostlySunnyNightPainter extends CustomPainter {
  final List<_Star> stars;
  final Random random;
  final double time;

  _MostlySunnyNightPainter(this.stars, this.random, this.time);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    if (stars.isEmpty) return;

    final starPaint = Paint()..style = PaintingStyle.fill;

    for (final star in stars) {
      final twinkle = (sin(time * star.twinkleSpeed + star.phase) + 1) / 2;
      final opacity = 0.1 + twinkle * 0.3;
      // Quantize to ~50 levels to reuse cached Color objects
      final quantized = (opacity * 50).roundToDouble() / 50;

      starPaint.color = cachedColor(quantized);
      canvas.drawCircle(
        Offset(star.x, star.y),
        star.size * (0.8 + twinkle * 0.2),
        starPaint,
      );
    }

    // Drifting cumulus clouds (same positions as day)
    drawDriftingCloud(canvas, w, h, time, 0.15, 0.30, w * 0.38, 0.30, 0.11);
    drawDriftingCloud(canvas, w, h, time, 0.58, 0.38, w * 0.42, 0.28, 0.085);
    drawDriftingCloud(canvas, w, h, time, 0.30, 0.62, w * 0.35, 0.22, 0.10);
  }

  @override
  bool shouldRepaint(_MostlySunnyNightPainter oldDelegate) =>
      oldDelegate.time != time;
}

