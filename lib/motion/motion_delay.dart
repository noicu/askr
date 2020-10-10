part of askr;

/// 除了消耗时间，不执行任何其他动作
///
/// 通常按顺序使用此动作来隔开其他事件
/// ```dart
/// MotionSequence([
///   MotionDelay(2),
///   MotionGroup([...]),
///   MotionDelay(1),
///   MotionCallFunction(() {...})
/// ]);
/// ```
class MotionDelay extends MotionInterval {
  /// 创建指定 [delay] 的新动作
  MotionDelay(double delay) : super(delay);
}
