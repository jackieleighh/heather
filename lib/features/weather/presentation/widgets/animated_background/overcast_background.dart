import 'dart:math';

import 'package:flutter/material.dart';

class _Blob {
  final double dx;
  final double dy;
  final double radius;

  const _Blob({required this.dx, required this.dy, required this.radius});
}

class _CloudMass {
  final double startX;
  final double yFraction;
  final double speed;
  final double scale;
  final double alpha;
  final double wobblePhase;
  final List<_Blob> blobs;

  const _CloudMass({
    required this.startX,
    required this.yFraction,
    required this.speed,
    required this.scale,
    required this.alpha,
    required this.wobblePhase,
    required this.blobs,
  });
}

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
  final Random _random = Random();
  late final List<_CloudMass> _masses;

  @override
  void initState() {
    super.initState();
    _masses = _generateMasses();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();
    _controller.addListener(() {
      _time += 0.004;
    });
  }

  List<_CloudMass> _generateMasses() {
    const params = [
      // (yFraction, scale, speed, alpha)
      (0.08, 0.55, 0.14, 0.18),
      (0.22, 0.50, 0.18, 0.16),
      (0.38, 0.48, 0.26, 0.14),
      (0.52, 0.52, 0.16, 0.13),
      (0.66, 0.45, 0.28, 0.12),
      (0.80, 0.42, 0.20, 0.10),
    ];

    return params.map((p) {
      final (yFrac, scale, speed, alpha) = p;
      final blobCount = 7 + _random.nextInt(6);
      final blobs = List.generate(blobCount, (_) {
        return _Blob(
          dx: (_random.nextDouble() - 0.5) * 1.4,
          dy: (_random.nextDouble() - 0.5) * 0.6,
          radius: 0.14 + _random.nextDouble() * 0.20,
        );
      });
      return _CloudMass(
        startX: _random.nextDouble() * 2.2,
        yFraction: yFrac,
        speed: speed,
        scale: scale,
        alpha: alpha,
        wobblePhase: _random.nextDouble() * pi * 2,
        blobs: blobs,
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
        return CustomPaint(
          foregroundPainter: _OvercastPainter(_time, _masses),
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
  final List<_CloudMass> masses;

  _OvercastPainter(this.time, this.masses);

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

    // Drifting cloud masses
    final paint = Paint()..style = PaintingStyle.fill;

    for (final mass in masses) {
      final raw = mass.startX + time * mass.speed;
      final xNorm = (raw % 2.2) - 0.6;
      final centerX = xNorm * w;
      final wobble = sin(time * 0.5 + mass.wobblePhase) * h * 0.012;
      final centerY = h * mass.yFraction + wobble;
      final scale = w * mass.scale;

      paint.maskFilter = MaskFilter.blur(BlurStyle.normal, scale * 0.12);

      for (final blob in mass.blobs) {
        paint.color = Colors.white.withValues(alpha: mass.alpha);
        canvas.drawCircle(
          Offset(centerX + blob.dx * scale, centerY + blob.dy * scale),
          blob.radius * scale,
          paint,
        );
      }
    }

    // Haze overlay
    _drawHaze(canvas, w, h);
  }

  void _drawHaze(Canvas canvas, double w, double h) {
    final paint = Paint()..style = PaintingStyle.fill;

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

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
