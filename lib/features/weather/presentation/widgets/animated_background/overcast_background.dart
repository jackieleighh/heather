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
    // Dense cloud cover — more clouds, heavier opacity
    _drawCloud(
      canvas,
      size.width * 0.15 + sin(time * 0.35) * 20,
      size.height * 0.08,
      90,
      0.14,
    );
    _drawCloud(
      canvas,
      size.width * 0.6 + sin(time * 0.3 + 1) * 25,
      size.height * 0.12,
      100,
      0.16,
    );
    _drawCloud(
      canvas,
      size.width * 0.35 + sin(time * 0.4 + 2) * 18,
      size.height * 0.28,
      95,
      0.15,
    );
    _drawCloud(
      canvas,
      size.width * 0.8 + sin(time * 0.28 + 3) * 30,
      size.height * 0.38,
      80,
      0.12,
    );
    _drawCloud(
      canvas,
      size.width * 0.1 + sin(time * 0.45 + 4) * 22,
      size.height * 0.52,
      85,
      0.13,
    );
    _drawCloud(
      canvas,
      size.width * 0.55 + sin(time * 0.32 + 5) * 20,
      size.height * 0.65,
      90,
      0.11,
    );
    _drawCloud(
      canvas,
      size.width * 0.3 + sin(time * 0.38 + 6) * 24,
      size.height * 0.78,
      75,
      0.1,
    );
    _drawCloud(
      canvas,
      size.width * 0.75 + sin(time * 0.42 + 7) * 18,
      size.height * 0.88,
      85,
      0.12,
    );
  }

  void _drawCloud(
    Canvas canvas,
    double cx,
    double cy,
    double scale,
    double opacity,
  ) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.white.withValues(alpha: opacity)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 45);

    canvas.drawCircle(Offset(cx, cy), scale, paint);
    canvas.drawCircle(Offset(cx - scale * 0.7, cy + 10), scale * 0.75, paint);
    canvas.drawCircle(Offset(cx + scale * 0.8, cy + 5), scale * 0.85, paint);
    canvas.drawCircle(Offset(cx + scale * 0.3, cy - 18), scale * 0.6, paint);
    canvas.drawCircle(Offset(cx - scale * 0.4, cy + 20), scale * 0.7, paint);
    canvas.drawCircle(Offset(cx + scale * 0.5, cy + 18), scale * 0.65, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
