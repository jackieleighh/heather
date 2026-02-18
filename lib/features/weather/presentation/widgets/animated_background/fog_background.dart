import 'dart:math';

import 'package:flutter/material.dart';

class _FogWisp {
  final double startX;
  final double yFraction;
  final double speed;
  final double width;
  final double height;
  final double blur;
  final double alpha;
  final double wobblePhase;

  const _FogWisp({
    required this.startX,
    required this.yFraction,
    required this.speed,
    required this.width,
    required this.height,
    required this.blur,
    required this.alpha,
    required this.wobblePhase,
  });
}

class FogBackground extends StatefulWidget {
  final List<Color> gradientColors;

  const FogBackground({super.key, required this.gradientColors});

  @override
  State<FogBackground> createState() => _FogBackgroundState();
}

class _FogBackgroundState extends State<FogBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  double _time = 0;
  final Random _random = Random();
  late final List<_FogWisp> _wisps;

  @override
  void initState() {
    super.initState();
    _wisps = _generateWisps();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();
    _controller.addListener(() {
      _time += 0.004;
    });
  }

  List<_FogWisp> _generateWisps() {
    return List.generate(14, (_) {
      final yRaw = _random.nextDouble();
      final yBiased = yRaw * yRaw;
      final yFraction = 0.05 + yBiased * 0.85;
      final height = 50.0 + _random.nextDouble() * 70.0;

      return _FogWisp(
        startX: _random.nextDouble() * 2.4,
        yFraction: yFraction,
        speed: 0.08 + _random.nextDouble() * 0.14,
        width: 0.4 + _random.nextDouble() * 0.6,
        height: height,
        blur: height * 0.16 + _random.nextDouble() * 6.0,
        alpha: 0.13 + _random.nextDouble() * 0.12,
        wobblePhase: _random.nextDouble() * pi * 2,
      );
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
          foregroundPainter: _FogPainter(_time, _wisps),
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

class _FogPainter extends CustomPainter {
  final double time;
  final List<_FogWisp> wisps;

  _FogPainter(this.time, this.wisps);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Atmospheric haze base layer
    _drawHaze(canvas, w, h);

    // Drifting fog wisps
    final paint = Paint()..style = PaintingStyle.fill;

    for (final wisp in wisps) {
      final raw = wisp.startX + time * wisp.speed;
      final xNorm = (raw % 2.4) - 1.0;
      final x = xNorm * w;

      final wobble = sin(time * 0.7 + wisp.wobblePhase) * h * 0.012;
      final y = h * wisp.yFraction + wobble;

      paint
        ..color = Colors.white.withValues(alpha: wisp.alpha)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, wisp.blur);

      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(x, y),
          width: wisp.width * w,
          height: wisp.height,
        ),
        paint,
      );
    }
  }

  void _drawHaze(Canvas canvas, double w, double h) {
    final paint = Paint()..style = PaintingStyle.fill;

    paint
      ..color = Colors.white.withValues(
        alpha: 0.12 + sin(time * 0.2) * 0.03,
      )
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 80);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w * 0.5, h * 0.3),
        width: w * 2.2,
        height: h * 0.7,
      ),
      paint,
    );

    paint.color = Colors.white.withValues(
      alpha: 0.10 + sin(time * 0.15 + 1.5) * 0.02,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w * 0.5, h * 0.7),
        width: w * 1.8,
        height: h * 0.5,
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
