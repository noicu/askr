part of askr;

/// 在 [Sprite] 渲染树中提供渲染图层的 [Node]
/// [Layer] 可用于更改不透明度，颜色或将效果应用于一组节点
/// 所有属于 [Layer] 的子节点都将渲染到图层中
/// 如果知道所绘制的子级区域，则应设置 [layerRect] 属性，可以提高性能
class Layer extends Node with SpritePaint {
  /// [Layer] 的子级占据的区域
  /// 该值被视为对渲染系统的隐射，在某些情况下可能会被忽略
  /// 如果区域未知，可以将layerRect设置为 [null]
  /// ```dart
  /// myLayer.layerRect = new Rect.fromLTRB(0.0, 0.0, 200.0, 100.0);
  /// ```
  Rect layerRect;

  /// 创建一个新层
  ///
  /// 可以设置 [layerRect] 参数
  /// ```dart
  /// var myLayer = new Layer();
  /// ```
  Layer([this.layerRect]);

  Paint _cachedPaint = new Paint()
    ..filterQuality = FilterQuality.low
    ..isAntiAlias = false;

  @override
  void _prePaint(Canvas canvas) {
    super._prePaint(canvas);

    _updatePaint(_cachedPaint);
    canvas.saveLayer(layerRect, _cachedPaint);
  }

  @override
  void _postPaint(Canvas canvas) {
    canvas.restore();
    super._postPaint(canvas);
  }
}
