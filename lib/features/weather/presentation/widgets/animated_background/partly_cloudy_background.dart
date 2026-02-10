import 'dart:math';

import 'package:flutter/material.dart';

class PartlyCloudyBackground extends StatefulWidget {
  final List<Color> gradientColors;

  const PartlyCloudyBackground({super.key, required this.gradientColors});

  @override
  State<PartlyCloudyBackground> createState() => _PartlyCloudyBackgroundState();
}

class _PartlyCloudyBackgroundState extends State<PartlyCloudyBackground>
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
      _time += 0.005;
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
          foregroundPainter: _PartlyCloudyPainter(_time),
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

class _PartlyCloudyPainter extends CustomPainter {
  final double time;

  _PartlyCloudyPainter(this.time);

  @override
  void paint(Canvas canvas, Size size) {
    // Sun glow peeking through
    final sunCenter = Offset(size.width * 0.75, size.height * 0.12);
    final glowPaint = Paint()
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 45);

    glowPaint.color = Colors.white.withValues(alpha: 0.1 + sin(time) * 0.03);
    canvas.drawCircle(sunCenter, 100, glowPaint);

    glowPaint.color = Colors.white.withValues(alpha: 0.15);
    glowPaint.maskFilter = const MaskFilter.blur(BlurStyle.normal, 20);
    canvas.drawCircle(sunCenter, 45, glowPaint);

    // Clouds
    _drawCloud(
      canvas,
      size.width * 0.2 + sin(time * 0.4) * 25,
      size.height * 0.12,
      75,
      0.12,
    );
    _drawCloud(
      canvas,
      size.width * 0.7 + sin(time * 0.3 + 1) * 20,
      size.height * 0.25,
      65,
      0.1,
    );
    _drawCloud(
      canvas,
      size.width * 0.4 + sin(time * 0.5 + 2) * 18,
      size.height * 0.42,
      80,
      0.13,
    );
    _drawCloud(
      canvas,
      size.width * 0.15 + sin(time * 0.35 + 3) * 22,
      size.height * 0.62,
      60,
      0.08,
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
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 35);

    canvas.drawCircle(Offset(cx, cy), scale, paint);
    canvas.drawCircle(Offset(cx - scale * 0.65, cy + 8), scale * 0.7, paint);
    canvas.drawCircle(Offset(cx + scale * 0.7, cy + 5), scale * 0.8, paint);
    canvas.drawCircle(Offset(cx + scale * 0.25, cy - 15), scale * 0.55, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
