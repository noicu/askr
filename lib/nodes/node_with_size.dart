part of askr;

/// 具有尺寸节点的超级类。
///
/// NodeWithSize增加了节点尺寸和轴心点
class NodeWithSize extends Node {
  /// 节点尺寸
  Size size;

  /// ![](https://github.com/tovi-cn/askr/blob/master/lib/extra/pivot.png?raw=true)
  Offset pivot;

  /// 默认 [size] 为零，默认 [pivot] 点为原点。子类可能会更改默认值。
  NodeWithSize([this.size]) {
    if (size == null) size = Size.zero;
    pivot = Offset.zero;
  }

  /// 如果希望图形的原点是节点边界框的左上角，请在[paint]方法中调用此方法。
  ///
  /// 如果使用此方法，则需要在[paint]方法的开始和结束时保存和恢复画布。
  ///
  /// ```dart
  /// void paint(Canvas canvas) {
  ///   canvas.save();
  ///   applyTransformForPivot(canvas);
  ///   ...
  ///   canvas.restore();
  /// }
  /// ```
  void applyTransformForPivot(Canvas canvas) {
    if (pivot.dx != 0 || pivot.dy != 0) {
      double pivotInPointsX = size.width * pivot.dx;
      double pivotInPointsY = size.height * pivot.dy;
      canvas.translate(-pivotInPointsX, -pivotInPointsY);

      if (debugPaintSizeEnabled) debugDrawing(canvas, size);
    }
  }

  @override
  bool isPointInside(Offset nodePoint) {
    double minX = -size.width * pivot.dx;
    double minY = -size.height * pivot.dy;
    double maxX = minX + size.width;
    double maxY = minY + size.height;
    return (nodePoint.dx >= minX &&
        nodePoint.dx < maxX &&
        nodePoint.dy >= minY &&
        nodePoint.dy < maxY);
  }
}
