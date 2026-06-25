import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import 'cloud_painter.dart';

class PartlyCloudyBackground extends StatefulWidget {
  final List<Color> gradientColors;
  final bool isDay;
  final bool isActive;

  const PartlyCloudyBackground({
    super.key,
    required this.gradientColors,
    required this.isDay,
    this.isActive = true,
  });

  @override
  State<PartlyCloudyBackground> createState() => _PartlyCloudyBackgroundState();
}

class _PartlyCloudyBackgroundState extends State<PartlyCloudyBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  final List<_Star> _stars = [];
  final Random _random = Random();
  final _rayColors = List<Color>.filled(10, const Color(0x00FFFFFF));
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
  void didUpdateWidget(PartlyCloudyBackground oldWidget) {
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
            0.25,
            0.15,
            0.22,
            0.13,
            0.24,
            0.17,
            0.20,
            0.14,
            0.19,
            0.15,
          ];
          for (var i = 0; i < 10; i++) {
            final alpha = rayAlphas[i] + sin(time * 0.5 + i * 0.7).abs() * 0.03;
            _rayColors[i] = Color.fromRGBO(255, 255, 255, alpha);
          }
        }
        return RepaintBoundary(
          child: CustomPaint(
            foregroundPainter: widget.isDay
                ? _PartlyCloudyDayPainter(time, _rayColors)
                : _PartlyCloudyNightPainter(_stars, _random, time),
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

class _PartlyCloudyDayPainter extends CustomPainter {
  final double time;
  final List<Color> rayColors;

  _PartlyCloudyDayPainter(this.time, this.rayColors);

  static const _white0 = Color.fromRGBO(255, 255, 255, 0);

  /// Pre-allocated color pair lists for ray gradients (one per ray).
  static final _rayGradientColors = List.generate(10, (_) => [_white0, _white0]);
  static const _glowColors = [
    Color.fromRGBO(255, 255, 255, 0.38),
    Color.fromRGBO(255, 255, 255, 0.10),
    _white0,
  ];
  static const _coreColors = [
    Color.fromRGBO(255, 255, 255, 0.90),
    Color.fromRGBO(255, 255, 255, 0.50),
    _white0,
  ];
  static const _glowStops = [0.0, 0.5, 1.0];
  static const _coreStops = [0.0, 0.35, 1.0];

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Sun rays peeking through gaps
    final sunCenter = Offset(w * 0.8, h * 0.12);
    final rayPaint = Paint()
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    const rayAngles = [0.0, 0.7, 1.3, 2.0, 2.7, 3.3, 4.0, 4.7, 5.3, 5.95];
    const rayLengths = [
      200.0,
      130.0,
      180.0,
      120.0,
      190.0,
      140.0,
      170.0,
      125.0,
      160.0,
      135.0,
    ];
    const raySpreads = [
      0.05,
      0.033,
      0.045,
      0.028,
      0.05,
      0.035,
      0.045,
      0.033,
      0.04,
      0.033,
    ];
    const innerR = 18.0;
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
        ..moveTo(sunCenter.dx + cosL * innerR, sunCenter.dy + sinL * innerR)
        ..lineTo(sunCenter.dx + cosL * outerR, sunCenter.dy + sinL * outerR)
        ..lineTo(sunCenter.dx + cosR * outerR, sunCenter.dy + sinR * outerR)
        ..lineTo(sunCenter.dx + cosR * innerR, sunCenter.dy + sinR * innerR)
        ..close();

      final colors = _rayGradientColors[i];
      colors[0] = rayColors[i];
      colors[1] = _white0;
      rayPaint.shader = ui.Gradient.linear(
        Offset(sunCenter.dx + cosA * innerR, sunCenter.dy + sinA * innerR),
        Offset(sunCenter.dx + cosA * outerR, sunCenter.dy + sinA * outerR),
        colors,
      );
      canvas.drawPath(path, rayPaint);
    }

    // Glow around core
    final glowPaint = Paint()..style = PaintingStyle.fill;
    glowPaint.shader = ui.Gradient.radial(
      sunCenter,
      90,
      _glowColors,
      _glowStops,
    );
    canvas.drawRect(Offset.zero & size, glowPaint);

    // Bright core
    glowPaint.shader = ui.Gradient.radial(
      sunCenter,
      35,
      _coreColors,
      _coreStops,
    );
    canvas.drawRect(Offset.zero & size, glowPaint);

    // Cumulus clouds
    _drawClouds(canvas, w, h, time);
  }

  @override
  bool shouldRepaint(_PartlyCloudyDayPainter oldDelegate) =>
      oldDelegate.time != time;
}

class _PartlyCloudyNightPainter extends CustomPainter {
  final List<_Star> stars;
  final Random random;
  final double time;

  _PartlyCloudyNightPainter(this.stars, this.random, this.time);

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

    // Cumulus clouds (layered over stars)
    _drawClouds(canvas, w, h, time);
  }

  @override
  bool shouldRepaint(_PartlyCloudyNightPainter oldDelegate) =>
      oldDelegate.time != time;
}

/// Draws the 5 cumulus clouds shared by both day and night painters.
void _drawClouds(Canvas canvas, double w, double h, double time) {
  drawDriftingCloud(canvas, w, h, time, 0.20, 0.08, w * 0.40, 0.35, 0.12);
  drawDriftingCloud(canvas, w, h, time, 0.65, 0.20, w * 0.48, 0.38, 0.10);
  drawDriftingCloud(canvas, w, h, time, 0.10, 0.38, w * 0.42, 0.32, 0.14);
  drawDriftingCloud(canvas, w, h, time, 0.75, 0.55, w * 0.36, 0.28, 0.11);
  drawDriftingCloud(canvas, w, h, time, 0.40, 0.72, w * 0.34, 0.24, 0.13);
}
