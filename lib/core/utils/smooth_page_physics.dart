import 'package:flutter/widgets.dart';

class SmoothPageScrollPhysics extends PageScrollPhysics {
  const SmoothPageScrollPhysics({super.parent});

  @override
  SmoothPageScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return SmoothPageScrollPhysics(parent: buildParent(ancestor));
  }

  @override
  SpringDescription get spring => SpringDescription.withDampingRatio(
        mass: 0.4,
        stiffness: 70,
        ratio: 1.0,
      );

  @override
  double get dragStartDistanceMotionThreshold => 5.0;
}
