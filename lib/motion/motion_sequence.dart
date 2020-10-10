part of askr;

/// 依次播放动作
///
/// [MotionSequence] 的播放时长为传入的动作播放时长之和
class MotionSequence extends MotionInterval {
  Motion _a;
  Motion _b;
  double _split;

  /// 根据传入的动作列表创建一个依次播放的动作
  /// ```dart
  /// var mySequence = new MotionSequence([myMotion0, myMotion1, myMotion2]);
  /// ```
  MotionSequence(List<Motion> motions) {
    assert(motions.length >= 2);

    if (motions.length == 2) {
      _a = motions[0];
      _b = motions[1];
    } else {
      _a = motions[0];
      _b = new MotionSequence(motions.sublist(1));
    }

    // 计算分段和持续时间
    _duration = _a.duration + _b.duration;
    if (_duration > 0) {
      _split = _a.duration / _duration;
    } else {
      _split = 1.0;
    }
  }

  @override
  void update(double t) {
    if (t < _split) {
      // 播放第一个动作
      double ta;
      if (_split > 0.0) {
        ta = (t / _split).clamp(0.0, 1.0);
      } else {
        ta = 1.0;
      }
      _updateWithCurve(_a, ta);
    } else if (t >= 1.0) {
      // 完成所有动作
      if (!_a._finished) _finish(_a);
      if (!_b._finished) _finish(_b);
    } else {
      // 确保第一个动作完成后播放第二个动作
      if (!_a._finished) _finish(_a);
      double tb;
      if (_split < 1.0) {
        tb = (1.0 - (1.0 - t) / (1.0 - _split)).clamp(0.0, 1.0);
      } else {
        tb = 1.0;
      }
      _updateWithCurve(_b, tb);
    }
  }

  void _updateWithCurve(Motion motion, double t) {
    if (motion is MotionInterval) {
      MotionInterval motionInterval = motion;
      if (motionInterval.curve == null) {
        motion.update(t);
      } else {
        motion.update(motionInterval.curve.transform(t));
      }
    } else {
      motion.update(t);
    }

    if (t >= 1.0) {
      motion._finished = true;
    }
  }

  void _finish(Motion motion) {
    motion.update(1.0);
    motion._finished = true;
  }

  @override
  void _reset() {
    super._reset();
    _a._reset();
    _b._reset();
  }
}
