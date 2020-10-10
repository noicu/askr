part of askr;

/// 可以在一段时间间隔内更改属性的 [motion] 的抽象类，
///
/// 可使用 [Curve] 定义运动曲线
abstract class MotionInterval extends Motion {
  /// 创建一个新的 [MotionInterval]
  ///
  /// 设置 [duration] 来指定完成动作的时长
  MotionInterval([this._duration = 0.0, this.curve]);

  @override
  double get duration => _duration;
  double _duration;

  /// 运动曲线
  /// ```dart
  /// myMotion.curve = Curves.bounceOut;
  /// ```
  Curve curve;

  bool _firstTick = true;
  double _elapsed = 0.0;

  @override
  void step(double dt) {
    if (_firstTick) {
      _firstTick = false;
    } else {
      _elapsed += dt;
    }

    double t;
    if (this._duration == 0.0) {
      t = 1.0;
    } else {
      t = (_elapsed / _duration).clamp(0.0, 1.0);
    }

    if (curve == null) {
      update(t);
    } else {
      update(curve.transform(t));
    }

    if (t >= 1.0) _finished = true;
  }
}
