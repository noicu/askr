part of askr;

debugDrawing(Canvas canvas, Size size, {Color color}) {
  canvas.save();
  Paint _paint = new Paint()..color = color ?? Color(0xFF2BFF00);
  // ..strokeWidth = 0.1;
  canvas.drawPoints(
    ui.PointMode.polygon,
    [
      Offset(0.0, 0.0),
      Offset(size.width, 0.0),
      Offset(size.width, size.height),
      Offset(0, size.height),
      Offset(0.0, 0.0),
    ],
    _paint,
  );
  // topLeft - bottomRight
  canvas.drawLine(
    Offset(0, 0),
    Offset(size.width, size.height),
    _paint,
  );
  // bottomLeft - topRight
  canvas.drawLine(
    Offset(0, size.height),
    Offset(size.width, 0),
    _paint,
  );
  canvas.restore();
}
