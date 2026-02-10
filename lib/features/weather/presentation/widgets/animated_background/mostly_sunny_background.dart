import 'dart:math';

import 'package:flutter/material.dart';

class MostlySunnyBackground extends StatefulWidget {
  final List<Color> gradientColors;

  const MostlySunnyBackground({super.key, required this.gradientColors});

  @override
  State<MostlySunnyBackground> createState() => _MostlySunnyBackgroundState();
}

class _MostlySunnyBackgroundState extends State<MostlySunnyBackground>
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
      _time += 0.008;
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
          painter: _MostlySunnyPainter(_time),
          size: Size.infinite,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: widget.gradientColors,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _MostlySunnyPainter extends CustomPainter {
  final double time;

  _MostlySunnyPainter(this.time);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width * 0.8, size.height * 0.12);

    // Sun glow
    final glowPaint = Paint()
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 40);

    glowPaint.color = Colors.white.withValues(alpha: 0.15 + sin(time) * 0.05);
    canvas.drawCircle(center, 110, glowPaint);

    glowPaint.color = Colors.white.withValues(alpha: 0.2 + sin(time) * 0.05);
    canvas.drawCircle(center, 65, glowPaint);

    // Sun rays
    final rayPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..color = Colors.white.withValues(alpha: 0.1);

    for (var i = 0; i < 10; i++) {
      final angle = (i * pi / 5) + time * 0.3;
      final innerRadius = 55.0 + sin(time * 2 + i) * 5;
      final outerRadius = 120.0 + sin(time + i * 0.5) * 15;

      canvas.drawLine(
        Offset(
          center.dx + cos(angle) * innerRadius,
          center.dy + sin(angle) * innerRadius,
        ),
        Offset(
          center.dx + cos(angle) * outerRadius,
          center.dy + sin(angle) * outerRadius,
        ),
        rayPaint,
      );
    }

    // A few wispy clouds
    final cloudPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.white.withValues(alpha: 0.08)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 35);

    final cx1 = size.width * 0.25 + sin(time * 0.3) * 20;
    canvas.drawCircle(Offset(cx1, size.height * 0.3), 50, cloudPaint);
    canvas.drawCircle(Offset(cx1 + 40, size.height * 0.3 + 5), 40, cloudPaint);

    final cx2 = size.width * 0.65 + sin(time * 0.25 + 2) * 25;
    canvas.drawCircle(Offset(cx2, size.height * 0.55), 45, cloudPaint);
    canvas.drawCircle(Offset(cx2 - 35, size.height * 0.55 + 8), 35, cloudPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
