part of askr;

/// [Motion] 的控制器，将需要播放的动作给 [MotionController] 的 [run] 方法进行播放
///
/// [Node] 自带 [MotionController]，并由 [SpriteBox] 驱动
class MotionController {
  List<Motion> _motions = <Motion>[];

  /// 创建一个新的[MotionController]
  /// 通常使用 [Node.motions] 属性对 [MotionController] 的引用
  MotionController();

  /// 运行 [motion] 可选参数 [tag]
  ///
  /// 可以通过 [tag] 引用动作或一组动作
  /// ```dart
  /// myNode.motions.run(myMotion, "myMotionGroup");
  /// ```
  void run(Motion motion, [Object tag]) {
    assert(!motion._added);

    motion._tag = tag;
    motion._added = true;
    motion.update(0.0);
    _motions.add(motion);
  }

  /// 停止 [motion] 并从控制器中删除该动作
  /// ```dart
  /// myNode.motions.stop(myMotion);
  /// ```
  void stop(Motion motion) {
    if (_motions.remove(motion)) {
      motion._added = false;
      motion._reset();
    }
  }

  void _stopAtIndex(int i) {
    Motion motion = _motions[i];
    motion._added = false;
    motion._reset();
    _motions.removeAt(i);
  }

  /// 根据 [tag] 停止所有对应的 [motion] 并从控制器中删除这些动作
  /// ```dart
  /// myNode.motions.stopWithTag("myMotionGroup");
  /// ```
  void stopWithTag(Object tag) {
    for (int i = _motions.length - 1; i >= 0; i--) {
      Motion motion = _motions[i];
      if (motion._tag == tag) {
        _stopAtIndex(i);
      }
    }
  }

  /// 停止所有的 [motion] 并从控制器中删除所有动作
  /// ```dart
  /// myNode.motions.stopAll();
  /// ```
  void stopAll() {
    for (int i = _motions.length - 1; i >= 0; i--) {
      _stopAtIndex(i);
    }
  }

  /// 在指定的时间前移运动，通常不需要直接调用此方法
  void step(double dt) {
    for (int i = _motions.length - 1; i >= 0; i--) {
      Motion motion = _motions[i];
      motion.step(dt);

      if (motion._finished) {
        motion._added = false;
        _motions.removeAt(i);
      }
    }
  }
}
