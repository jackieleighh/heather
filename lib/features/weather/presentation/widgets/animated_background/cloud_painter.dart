import 'dart:math';
import 'dart:ui';

/// File-level caches to avoid per-frame allocations.
final _blurCache = <double, MaskFilter>{};
final _colorCache = <double, Color>{};

MaskFilter cachedBlur(double scale) {
  final key = scale * 0.06;
  return _blurCache.putIfAbsent(
    key,
    () => MaskFilter.blur(BlurStyle.normal, key),
  );
}

Color cachedColor(double alpha) {
  return _colorCache.putIfAbsent(
    alpha,
    () => Color.fromRGBO(255, 255, 255, alpha),
  );
}

/// Draws a cloud that drifts continuously across the screen and wraps around.
void drawDriftingCloud(
  Canvas canvas,
  double w,
  double h,
  double time,
  double startXFrac,
  double yFrac,
  double scale,
  double alpha,
  double speed,
) {
  final totalWidth = w + scale * 1.5;
  final rawX = (startXFrac * w + time * w * speed) % totalWidth - scale * 0.75;
  final y = h * yFrac + sin(time * 0.25 + startXFrac * 10) * 6;

  drawCloud(canvas, center: Offset(rawX, y), scale: scale, alpha: alpha);
}

/// Draws a single cumulus cloud as a cluster of overlapping soft shapes.
///
/// Structure: 1 oval base + 3 circle lobes + 2 accent puffs.
void drawCloud(
  Canvas canvas, {
  required Offset center,
  required double scale,
  required double alpha,
}) {
  final paint = Paint()
    ..style = PaintingStyle.fill
    ..maskFilter = cachedBlur(scale);

  final baseColor = cachedColor(alpha * 0.75);
  final mainColor = cachedColor(alpha);
  final accentColor = cachedColor(alpha * 0.85);

  // Flat base — wide oval anchoring the bottom
  paint.color = baseColor;
  canvas.drawOval(
    Rect.fromCenter(
      center: Offset(center.dx, center.dy + scale * 0.12),
      width: scale * 1.4,
      height: scale * 0.35,
    ),
    paint,
  );

  // Main body — overlapping circles that form the puffy top
  paint.color = mainColor;

  // Left lobe
  canvas.drawCircle(
    Offset(center.dx - scale * 0.30, center.dy),
    scale * 0.30,
    paint,
  );

  // Center lobe (tallest)
  canvas.drawCircle(
    Offset(center.dx, center.dy - scale * 0.12),
    scale * 0.36,
    paint,
  );

  // Right lobe
  canvas.drawCircle(
    Offset(center.dx + scale * 0.32, center.dy + scale * 0.02),
    scale * 0.28,
    paint,
  );

  // Small accent puff — top center for height
  paint.color = accentColor;
  canvas.drawCircle(
    Offset(center.dx + scale * 0.05, center.dy - scale * 0.24),
    scale * 0.22,
    paint,
  );

  // Small accent puff — right shoulder
  canvas.drawCircle(
    Offset(center.dx + scale * 0.44, center.dy + scale * 0.05),
    scale * 0.18,
    paint,
  );
}

/// Draws a wide, flat stratus-style cloud suited for dense overcast coverage.
///
/// Uses all ovals for a layered, stretched appearance that merges well when
/// multiple masses overlap. No dependency on blur-merging random circles.
void drawOvercastCloud(
  Canvas canvas, {
  required Offset center,
  required double scale,
  required double alpha,
}) {
  final paint = Paint()
    ..style = PaintingStyle.fill
    ..maskFilter = cachedBlur(scale);

  final baseColor = cachedColor(alpha * 0.7);
  final mainColor = cachedColor(alpha);
  final accentColor = cachedColor(alpha * 0.85);

  // Wide flat base — extra wide for stratus look
  paint.color = baseColor;
  canvas.drawOval(
    Rect.fromCenter(
      center: Offset(center.dx, center.dy + scale * 0.08),
      width: scale * 1.8,
      height: scale * 0.30,
    ),
    paint,
  );

  // Left lobe — compressed oval
  paint.color = mainColor;
  canvas.drawOval(
    Rect.fromCenter(
      center: Offset(center.dx - scale * 0.40, center.dy),
      width: scale * 0.55,
      height: scale * 0.38,
    ),
    paint,
  );

  // Center lobe — widest, slightly raised
  canvas.drawOval(
    Rect.fromCenter(
      center: Offset(center.dx, center.dy - scale * 0.06),
      width: scale * 0.70,
      height: scale * 0.44,
    ),
    paint,
  );

  // Right lobe
  canvas.drawOval(
    Rect.fromCenter(
      center: Offset(center.dx + scale * 0.42, center.dy + scale * 0.02),
      width: scale * 0.50,
      height: scale * 0.36,
    ),
    paint,
  );

  // Top accent — subtle height
  paint.color = accentColor;
  canvas.drawOval(
    Rect.fromCenter(
      center: Offset(center.dx + scale * 0.05, center.dy - scale * 0.16),
      width: scale * 0.45,
      height: scale * 0.28,
    ),
    paint,
  );
}
