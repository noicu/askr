part of askr;

/// 提供一个虚拟的操纵杆，可以轻松地将其添加到您的精灵场景中
class VirtualJoystick extends NodeWithSize {
  /// 创建一个新的虚拟操纵杆
  VirtualJoystick() : super(new Size(160.0, 160.0)) {
    userInteractionEnabled = true;
    handleMultiplePointers = false;
    position = new Offset(160.0, -20.0);
    pivot = new Offset(0.5, 1.0);
    _center = new Offset(size.width / 2.0, size.height / 2.0);
    _handlePos = _center;

    _paintHandle = new Paint()..color = new Color(0xffffffff);
    _paintControl = new Paint()
      ..color = new Color(0xffffffff)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;
  }

  /// 获取操纵杆的当前值 (-1.0, -1.0) 到 (1.0, 1.0) 如果操纵杆没有移动，返回（0.0，0.0）
  Offset get value => _value;
  Offset _value = Offset.zero;

  /// 如果用户当前正在触摸操纵杆，则为True
  bool get isDown => _isDown;
  bool _isDown = false;

  Offset _pointerDownAt;
  Offset _center;
  Offset _handlePos;

  Paint _paintHandle;
  Paint _paintControl;

  @override
  bool handleEvent(SpriteBoxEvent event) {
    if (event.type == PointerDownEvent) {
      _pointerDownAt = event.boxPosition;
      motions.stopAll();
      _isDown = true;
    } else if (event.type == PointerUpEvent ||
        event.type == PointerCancelEvent) {
      _pointerDownAt = null;
      _value = Offset.zero;
      MotionTween moveToCenter = new MotionTween((a) {
        _handlePos = a;
      }, _handlePos, _center, 0.4, Curves.elasticOut);
      motions.run(moveToCenter);
      _isDown = false;
    } else if (event.type == PointerMoveEvent) {
      Offset movedDist = event.boxPosition - _pointerDownAt;

      _value = new Offset((movedDist.dx / 80.0).clamp(-1.0, 1.0),
          (movedDist.dy / 80.0).clamp(-1.0, 1.0));

      _handlePos = _center + new Offset(_value.dx * 40.0, _value.dy * 40.0);
    }
    return true;
  }

  @override
  void paint(Canvas canvas) {
    applyTransformForPivot(canvas);
    canvas.drawCircle(_handlePos, 25.0, _paintHandle);
    canvas.drawCircle(_center, 40.0, _paintControl);
  }
}
