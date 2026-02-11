import 'dart:math';

class Particle {
  double x;
  double y;
  double speed;
  double size;
  double opacity;
  double wobble;

  Particle({
    required this.x,
    required this.y,
    required this.speed,
    required this.size,
    this.opacity = 1.0,
    this.wobble = 0.0,
  });

  factory Particle.random(Random random, double maxWidth, double maxHeight) {
    return Particle(
      x: random.nextDouble() * maxWidth,
      y: random.nextDouble() * maxHeight,
      speed: 1.0 + random.nextDouble() * 3.0,
      size: 2.0 + random.nextDouble() * 4.0,
      opacity: 0.3 + random.nextDouble() * 0.7,
      wobble: random.nextDouble() * 2 * pi,
    );
  }
}
