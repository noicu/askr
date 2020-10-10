part of askr;

/// 并行播放动作
///
/// [MotionGroup] 的持续时间是尤该组耗时最长的动作决定
class MotionGroup extends MotionInterval {
  List<Motion> _motions;

  /// 创建一个新的并行动作组
  /// ```dart
  /// var myGroup = new MotionGroup([myMotion0, myMotion1, myMotion2]);
  /// ```
  MotionGroup(this._motions) {
    for (Motion motion in _motions) {
      if (motion.duration > _duration) {
        _duration = motion.duration;
      }
    }
  }

  @override
  void update(double t) {
    if (t >= 1.0) {
      // 完成所有未完成的动作
      for (Motion motion in _motions) {
        if (!motion._finished) {
          motion.update(1.0);
          motion._finished = true;
        }
      }
    } else {
      for (Motion motion in _motions) {
        if (motion.duration == 0.0) {
          // 立即触发所有即时动作
          if (!motion._finished) {
            motion.update(1.0);
            motion._finished = true;
          }
        } else {
          // 更新子动作
          double ta = (t / (motion.duration / duration)).clamp(0.0, 1.0);
          if (ta < 1.0) {
            if (motion is MotionInterval) {
              MotionInterval motionInterval = motion;
              if (motionInterval.curve == null) {
                motion.update(ta);
              } else {
                motion.update(motionInterval.curve.transform(ta));
              }
            } else {
              motion.update(ta);
            }
          } else if (!motion._finished) {
            motion.update(1.0);
            motion._finished = true;
          }
        }
      }
    }
  }

  @override
  void _reset() {
    for (Motion motion in _motions) {
      motion._reset();
    }
  }
}
