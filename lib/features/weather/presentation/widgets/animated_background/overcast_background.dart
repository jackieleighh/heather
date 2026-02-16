import 'dart:math';

import 'package:flutter/material.dart';

class OvercastBackground extends StatefulWidget {
  final List<Color> gradientColors;

  const OvercastBackground({super.key, required this.gradientColors});

  @override
  State<OvercastBackground> createState() => _OvercastBackgroundState();
}

class _OvercastBackgroundState extends State<OvercastBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  double _time = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();
    _controller.addListener(() {
      _time += 0.004;
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
          foregroundPainter: _OvercastPainter(_time),
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

class _OvercastPainter extends CustomPainter {
  final double time;

  _OvercastPainter(this.time);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Soft sun glow high up
    final glowPaint = Paint()
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 70);
    glowPaint.color =
        Colors.white.withValues(alpha: 0.15 + sin(time * 0.4) * 0.03);
    canvas.drawCircle(Offset(w * 0.7, h * 0.08), 90, glowPaint);

    // Cloud sheet masses — broad filled ovals with heavy blur
    _drawCloudSheets(canvas, w, h);

    // Cirrus streaks — thin curved strokes
    final cirrusPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    // Upper sky — main cirrus band
    _drawCirrus(canvas, cirrusPaint,
      start: Offset(w * -0.1 + sin(time * 0.10) * 15, h * 0.06),
      control: Offset(w * 0.35, h * 0.04 + sin(time * 0.12) * 5),
      end: Offset(w * 0.85 + sin(time * 0.08) * 20, h * 0.10),
      strokeWidth: 3.0, alpha: 0.12,
    );
    _drawCirrus(canvas, cirrusPaint,
      start: Offset(w * 0.05 + sin(time * 0.09 + 1) * 18, h * 0.11),
      control: Offset(w * 0.50, h * 0.08 + sin(time * 0.11 + 1) * 6),
      end: Offset(w * 1.1 + sin(time * 0.07 + 1) * 15, h * 0.13),
      strokeWidth: 2.5, alpha: 0.10,
    );
    _drawCirrus(canvas, cirrusPaint,
      start: Offset(w * 0.15 + sin(time * 0.12 + 2) * 20, h * 0.16),
      control: Offset(w * 0.55, h * 0.13 + sin(time * 0.10 + 2) * 7),
      end: Offset(w * 1.05 + sin(time * 0.09 + 2) * 18, h * 0.19),
      strokeWidth: 4.0, alpha: 0.14,
    );

    // Mid-upper — lighter, thinner
    _drawCirrus(canvas, cirrusPaint,
      start: Offset(w * -0.05 + sin(time * 0.08 + 3) * 22, h * 0.24),
      control: Offset(w * 0.40, h * 0.21 + sin(time * 0.13 + 3) * 5),
      end: Offset(w * 0.90 + sin(time * 0.10 + 3) * 15, h * 0.27),
      strokeWidth: 2.0, alpha: 0.09,
    );
    _drawCirrus(canvas, cirrusPaint,
      start: Offset(w * 0.20 + sin(time * 0.11 + 4) * 16, h * 0.30),
      control: Offset(w * 0.60, h * 0.27 + sin(time * 0.09 + 4) * 6),
      end: Offset(w * 1.1 + sin(time * 0.07 + 4) * 20, h * 0.32),
      strokeWidth: 3.0, alpha: 0.11,
    );

    // Center — sparse
    _drawCirrus(canvas, cirrusPaint,
      start: Offset(w * 0.10 + sin(time * 0.10 + 5) * 18, h * 0.40),
      control: Offset(w * 0.45, h * 0.37 + sin(time * 0.11 + 5) * 4),
      end: Offset(w * 0.95 + sin(time * 0.08 + 5) * 15, h * 0.42),
      strokeWidth: 2.0, alpha: 0.07,
    );

    // Lower-mid — faint
    _drawCirrus(canvas, cirrusPaint,
      start: Offset(w * -0.05 + sin(time * 0.09 + 6) * 20, h * 0.55),
      control: Offset(w * 0.35, h * 0.52 + sin(time * 0.12 + 6) * 5),
      end: Offset(w * 0.80 + sin(time * 0.07 + 6) * 18, h * 0.57),
      strokeWidth: 2.5, alpha: 0.08,
    );
    _drawCirrus(canvas, cirrusPaint,
      start: Offset(w * 0.25 + sin(time * 0.11 + 7) * 15, h * 0.65),
      control: Offset(w * 0.55, h * 0.62 + sin(time * 0.10 + 7) * 6),
      end: Offset(w * 1.05 + sin(time * 0.08 + 7) * 20, h * 0.67),
      strokeWidth: 2.0, alpha: 0.06,
    );

    // Low — barely there
    _drawCirrus(canvas, cirrusPaint,
      start: Offset(w * 0.05 + sin(time * 0.10 + 8) * 18, h * 0.78),
      control: Offset(w * 0.40, h * 0.75 + sin(time * 0.09 + 8) * 5),
      end: Offset(w * 0.90 + sin(time * 0.07 + 8) * 15, h * 0.80),
      strokeWidth: 1.5, alpha: 0.05,
    );

    // Mare's tail hooks — shorter, curvier
    _drawCirrus(canvas, cirrusPaint,
      start: Offset(w * 0.55 + sin(time * 0.13 + 9) * 12, h * 0.09),
      control: Offset(w * 0.68, h * 0.05 + sin(time * 0.11 + 9) * 4),
      end: Offset(w * 0.78 + sin(time * 0.09 + 9) * 10, h * 0.12),
      strokeWidth: 1.5, alpha: 0.08,
    );
    _drawCirrus(canvas, cirrusPaint,
      start: Offset(w * 0.30 + sin(time * 0.12 + 10) * 14, h * 0.22),
      control: Offset(w * 0.42, h * 0.18 + sin(time * 0.10 + 10) * 5),
      end: Offset(w * 0.50 + sin(time * 0.08 + 10) * 12, h * 0.25),
      strokeWidth: 1.5, alpha: 0.07,
    );

    // Haze overlay — ties the scene together
    _drawHaze(canvas, w, h);
  }

  /// 8 broad filled ovals with heavy blur at different heights.
  /// Top-heavy distribution (denser/more opaque higher up).
  void _drawCloudSheets(Canvas canvas, double w, double h) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Each sheet: (yFraction, widthFactor, heightFactor, blur, alpha, driftPhase)
    const sheets = [
      (0.05, 1.8, 0.18, 90.0, 0.10, 0.0),
      (0.12, 1.6, 0.16, 85.0, 0.09, 1.2),
      (0.20, 1.7, 0.20, 80.0, 0.08, 2.4),
      (0.30, 1.5, 0.15, 75.0, 0.07, 3.6),
      (0.42, 1.6, 0.18, 80.0, 0.06, 4.8),
      (0.55, 1.4, 0.14, 70.0, 0.05, 6.0),
      (0.68, 1.5, 0.16, 75.0, 0.04, 7.2),
      (0.80, 1.4, 0.14, 70.0, 0.04, 8.4),
    ];

    for (final (yFrac, wFactor, hFactor, blur, alpha, phase) in sheets) {
      final drift = sin(time * 0.08 + phase) * w * 0.03;
      paint
        ..color = Colors.white.withValues(alpha: alpha)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, blur);
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(w * 0.5 + drift, h * yFrac),
          width: w * wFactor,
          height: h * hFactor,
        ),
        paint,
      );
    }
  }

  /// Two very wide, subtle blurred ovals spanning the screen.
  void _drawHaze(Canvas canvas, double w, double h) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Upper haze
    paint
      ..color = Colors.white.withValues(
        alpha: 0.03 + sin(time * 0.15) * 0.01,
      )
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 100);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w * 0.5, h * 0.25),
        width: w * 2.0,
        height: h * 0.5,
      ),
      paint,
    );

    // Lower haze
    paint.color = Colors.white.withValues(
      alpha: 0.02 + sin(time * 0.12 + 2.0) * 0.01,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w * 0.5, h * 0.65),
        width: w * 1.8,
        height: h * 0.4,
      ),
      paint,
    );
  }

  void _drawCirrus(
    Canvas canvas,
    Paint paint, {
    required Offset start,
    required Offset control,
    required Offset end,
    required double strokeWidth,
    required double alpha,
  }) {
    paint
      ..strokeWidth = strokeWidth
      ..color = Colors.white.withValues(alpha: alpha);
    final path = Path()
      ..moveTo(start.dx, start.dy)
      ..quadraticBezierTo(control.dx, control.dy, end.dx, end.dy);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
