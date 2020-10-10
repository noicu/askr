part of askr;

/// 没有持续时间的动作
///
/// 如果覆写此类创建自定义即时运动，则应覆写 [fire] 方法
abstract class MotionInstant extends Motion {
  @override
  void step(double dt) {}

  @override
  void update(double t) {
    fire();
    _finished = true;
  }

  /// 执行运动时调用
  ///
  /// 如果要实现自己的 [MotionInstant] ，请重写此方法
  void fire();
}
