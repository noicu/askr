part of askr;

/// 触发时将提供的节点从其父节点移除
class MotionRemoveNode extends MotionInstant {
  Node _node;

  /// 触发时将提供的节点从其父节点移除
  /// ```dart
  /// var myMotion = new MotionRemoveNode(myNode);
  /// ```
  MotionRemoveNode(this._node);

  @override
  void fire() {
    _node.removeFromParent();
  }
}
