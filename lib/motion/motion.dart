part of askr;

/// [Motion] 用于对节点或任何其他类型的对象的属性进行动画处理
///
/// 这些动作由通常与 [Node] 关联的 [MotionController] 驱动
///
/// 最常用的运动是 [MotionTween]
/// 它会随着时间在两个值之间插入值，形成过渡
///
/// 动作可以用不同的方式嵌套
/// 使用 [MotionSequence] 顺序播放，或使用 [MotionRepeat] 循环播放
///
/// 通常，不应直接覆写此类
/// 如果需要创建新的动作类，则应覆写 [MotionInterval] 或 [MotionInstant]
abstract class Motion {
  Object _tag;
  bool _finished = false;
  bool _added = false;

  /// 移至动作的下一个时间步
  /// [dt] 是上一个时间步到现在的增量时间（以秒为单位）
  /// 通常此方法尤 [MotionController] 调用
  void step(double dt);

  /// [t] 是消逝时间转换为 0.0到1.0 的值
  void update(double t) {}

  void _reset() {
    _finished = false;
  }

  /// 完成动作所需总时间，以秒为单位
  double get duration => 0.0;
}
