part of askr;

class IconNode extends Node {
  IconNode(
    IconData icon, {
    double size,
    Color color,
  }) {
    this.icon = icon;
    this.size = size;
    this.color = color;
  }

  IconData _icon;
  IconData get icon => _icon;
  set icon(IconData icon) {
    _icon = icon;
    _painter = null;
  }

  double _size;
  get size => _size;
  set size(double size) {
    _size = size;
    _painter = null;
  }

  Color _color;
  get color => _color;
  set color(Color color) {
    _color = color;
    _painter = null;
  }

  TextPainter _painter;

  @override
  void paint(Canvas canvas) {
    if (_painter == null) {
      _painter = new TextPainter(
        text: TextSpan(
          text: String.fromCharCode(icon.codePoint),
          style: TextStyle(
            inherit: false,
            color: color,
            fontSize: size,
            fontFamily: icon.fontFamily,
            package: icon.fontPackage,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
    }
    if (debugPaintSizeEnabled)
      debugDrawing(
        canvas,
        Size(size, size),
        color: Color(0xFFFBFF00),
      );
    _painter.paint(canvas, Offset.zero);
  }
}
