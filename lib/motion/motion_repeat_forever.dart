part of askr;

/// 用于无限次重复动作
class MotionRepeatForever extends Motion {
  /// 无限重复的动作
  final MotionInterval motion;
  double _elapsedInMotion = 0.0;

  /// 创建一个新的无限运动
  /// ```dart
  /// var myInifiniteLoop = new MotionRepeatForever(myMotion);
  /// ```
  MotionRepeatForever(this.motion);

  @override
  void step(double dt) {
    _elapsedInMotion += dt;
    while (_elapsedInMotion > motion.duration) {
      _elapsedInMotion -= motion.duration;
      if (!motion._finished) motion.update(1.0);
      motion._reset();
    }
    _elapsedInMotion = math.max(_elapsedInMotion, 0.0);

    double t;
    if (motion._duration == 0.0) {
      t = 1.0;
    } else {
      t = (_elapsedInMotion / motion._duration).clamp(0.0, 1.0);
    }

    motion.update(t);
  }
}
