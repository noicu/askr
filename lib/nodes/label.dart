part of askr;

/// [Label] 用于在节点树中显示文本,对齐文本可以设置 [TextStyle] 的textAlign属性
class Label extends Node {
  /// 使用提供的 [text] 和 [textStyle] 创建一个新的Label
  Label(
    this._text, {
    TextStyle textStyle,
    TextAlign textAlign,
  })  : _textStyle = textStyle ?? const TextStyle(),
        textAlign = textAlign ?? TextAlign.left;

  /// 绘制的文本
  String get text => _text;
  String _text;
  set text(String text) {
    _text = text;
    _painter = null;
  }

  /// 绘制文本的样式
  TextStyle get textStyle => _textStyle;
  TextStyle _textStyle;
  set textStyle(TextStyle textStyle) {
    _textStyle = textStyle;
    _painter = null;
  }

  /// 对齐方式
  TextAlign textAlign;

  TextPainter _painter;
  double _width;

  Size size = Size.zero;

  @override
  void paint(Canvas canvas) {
    if (_painter == null) {
      _painter = new TextPainter(
        text: new TextSpan(style: _textStyle, text: _text),
        textDirection: TextDirection.ltr,
      )..layout();
      _width = _painter.size.width;
    }

    Offset offset = Offset.zero;
    if (textAlign == TextAlign.center) {
      offset = new Offset(-_width / 2.0, 0.0);
    } else if (textAlign == TextAlign.right) {
      offset = new Offset(-_width, 0.0);
    }

    if (debugPaintSizeEnabled) {
      canvas.drawRect(
          offset & _painter.size, new Paint()..color = const Color(0x44FF0000));
      // debugDrawing(canvas, _painter.size);
    }

    if (size != _painter.size) size = _painter.size;

    // print(size);

    _painter.paint(canvas, offset);
  }
}
