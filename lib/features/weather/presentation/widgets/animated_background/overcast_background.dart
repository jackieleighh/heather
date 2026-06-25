import 'dart:math';

import 'package:flutter/material.dart';

import 'cloud_painter.dart';

class _CloudMass {
  final double startX;
  final double yFraction;
  final double speed;
  final double scale;
  final double alpha;
  final double wobblePhase;

  const _CloudMass({
    required this.startX,
    required this.yFraction,
    required this.speed,
    required this.scale,
    required this.alpha,
    required this.wobblePhase,
  });
}

class OvercastBackground extends StatefulWidget {
  final List<Color> gradientColors;
  final bool isActive;

  const OvercastBackground({
    super.key,
    required this.gradientColors,
    this.isActive = true,
  });

  @override
  State<OvercastBackground> createState() => _OvercastBackgroundState();
}

class _OvercastBackgroundState extends State<OvercastBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  final Random _random = Random();
  late final List<_CloudMass> _masses;

  @override
  void initState() {
    super.initState();
    _masses = _generateMasses();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    if (widget.isActive) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(OvercastBackground oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive != oldWidget.isActive) {
      if (widget.isActive) {
        _controller.repeat();
      } else {
        _controller.stop();
      }
    }
  }

  List<_CloudMass> _generateMasses() {
    const params = [
      // (yFraction, scale, speed, alpha)
      (0.08, 0.62, 0.32, 0.18),
      (0.22, 0.58, 0.36, 0.16),
      (0.38, 0.56, 0.46, 0.15),
      (0.52, 0.60, 0.34, 0.14),
      (0.66, 0.54, 0.48, 0.13),
      (0.80, 0.52, 0.38, 0.12),
    ];

    return params.map((p) {
      final (yFrac, scale, speed, alpha) = p;
      return _CloudMass(
        startX: _random.nextDouble() * 2.2,
        yFraction: yFrac,
        speed: speed,
        scale: scale,
        alpha: alpha,
        wobblePhase: _random.nextDouble() * pi * 2,
      );
    }).toList();
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
                0.45;
        return RepaintBoundary(
          child: CustomPaint(
            foregroundPainter: _OvercastPainter(time, _masses),
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

class _OvercastPainter extends CustomPainter {
  final double time;
  final List<_CloudMass> masses;

  _OvercastPainter(this.time, this.masses);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Soft sun glow high up
    final glowPaint = Paint()
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 70)
      ..color = Color.fromRGBO(255, 255, 255, 0.15 + sin(time * 0.4) * 0.03);
    canvas.drawCircle(Offset(w * 0.8, h * 0.12), 90, glowPaint);

    // Drifting cloud masses — structured stratus shapes
    for (final mass in masses) {
      final raw = mass.startX + time * mass.speed;
      final xNorm = (raw % 2.2) - 0.6;
      final centerX = xNorm * w;
      final wobble = sin(time * 0.35 + mass.wobblePhase) * h * 0.008;
      final centerY = h * mass.yFraction + wobble;
      final scale = w * mass.scale;

      drawOvercastCloud(
        canvas,
        center: Offset(centerX, centerY),
        scale: scale,
        alpha: mass.alpha,
      );
    }

    // Haze overlay
    _drawHaze(canvas, w, h);
  }

  void _drawHaze(Canvas canvas, double w, double h) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 40)
      ..color = Color.fromRGBO(255, 255, 255, 0.03 + sin(time * 0.15) * 0.01);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w * 0.5, h * 0.25),
        width: w * 2.0,
        height: h * 0.5,
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(_OvercastPainter oldDelegate) => oldDelegate.time != time;
}
