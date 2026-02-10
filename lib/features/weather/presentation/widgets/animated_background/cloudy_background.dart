import 'dart:math';

import 'package:flutter/material.dart';

import '../../../../../core/constants/app_colors.dart';

class CloudyBackground extends StatefulWidget {
  const CloudyBackground({super.key});

  @override
  State<CloudyBackground> createState() => _CloudyBackgroundState();
}

class _CloudyBackgroundState extends State<CloudyBackground>
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
          painter: _CloudyPainter(_time),
          size: Size.infinite,
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.mutedTeal,
                  AppColors.fogSilver,
                  AppColors.palePurple,
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _CloudyPainter extends CustomPainter {
  final double time;

  _CloudyPainter(this.time);

  @override
  void paint(Canvas canvas, Size size) {
    _drawCloud(canvas, size, size.width * 0.2 + sin(time * 0.4) * 30,
        size.height * 0.1, 80, 0.12);
    _drawCloud(canvas, size, size.width * 0.75 + sin(time * 0.3 + 1) * 25,
        size.height * 0.2, 70, 0.1);
    _drawCloud(canvas, size, size.width * 0.4 + sin(time * 0.5 + 2) * 20,
        size.height * 0.38, 90, 0.14);
    _drawCloud(canvas, size, size.width * 0.85 + sin(time * 0.35 + 3) * 35,
        size.height * 0.55, 65, 0.08);
    _drawCloud(canvas, size, size.width * 0.15 + sin(time * 0.45 + 4) * 28,
        size.height * 0.68, 75, 0.1);
    _drawCloud(canvas, size, size.width * 0.55 + sin(time * 0.38 + 5) * 22,
        size.height * 0.82, 85, 0.09);
  }

  void _drawCloud(
    Canvas canvas,
    Size size,
    double cx,
    double cy,
    double scale,
    double opacity,
  ) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.white.withValues(alpha: opacity)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 40);

    canvas.drawCircle(Offset(cx, cy), scale, paint);
    canvas.drawCircle(Offset(cx - scale * 0.7, cy + 10), scale * 0.75, paint);
    canvas.drawCircle(Offset(cx + scale * 0.8, cy + 5), scale * 0.85, paint);
    canvas.drawCircle(Offset(cx + scale * 0.3, cy - 18), scale * 0.6, paint);
    canvas.drawCircle(Offset(cx - scale * 0.3, cy + 22), scale * 0.7, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
