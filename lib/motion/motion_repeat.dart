part of askr;

/// 重复动作固定的次数
class MotionRepeat extends MotionInterval {
  /// 重复 [Motion] 的次数
  final int numRepeats;

  /// 重复的动作
  final MotionInterval motion;

  /// 最后完成的
  int _lastFinishedRepeat = -1;

  /// 重复动作固定的次数
  /// ```dart
  /// var myLoop = new MotionRepeat(myMotion,10);
  /// ```
  MotionRepeat(this.motion, this.numRepeats) {
    _duration = motion.duration * numRepeats;
  }

  @override
  void update(double t) {
    // 当前重复
    int currentRepeat = math.min(
      (t * numRepeats.toDouble()).toInt(),
      numRepeats - 1,
    );

    for (int i = math.max(_lastFinishedRepeat, 0); i < currentRepeat; i++) {
      // 校准
      if (!motion._finished) motion.update(1.0);
      // 上一个重复完成后状态回到初始
      motion._reset();
    }

    _lastFinishedRepeat = currentRepeat;

    // 当前重复动作的时间轴位置
    double ta = (t * numRepeats.toDouble()) % 1.0; // 取模
    // 更新动作
    motion.update(ta);

    // 所有重复结束
    if (t >= 1.0) {
      motion.update(1.0);
      motion._finished = true;
    }
  }
}
