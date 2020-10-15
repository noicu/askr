part of askr;

/// 使用点列表绘制一条折线
/// 如果要创建动画线，请考虑改用 [EffectLine]
class TexturedLine extends Node {
  /// 创建一个新的 [TexturedLine]
  TexturedLine(List<Offset> points, List<Color> colors, List<double> widths,
      [SpriteTexture texture, List<double> textureStops]) {
    painter =
        new TexturedLinePainter(points, colors, widths, texture, textureStops);
  }

  TexturedLinePainter painter;

  @override
  void paint(Canvas canvas) {
    painter.paint(canvas);
  }
}

/// 使用提供的 [SpriteTexture] 从点列表中绘制一条多义线至 [Canvas]
class TexturedLinePainter {
  /// 创建一个绘制带有纹理的折线的painter
  TexturedLinePainter(this._points, this.colors, this.widths,
      [SpriteTexture texture, this.textureStops]) {
    this.texture = texture;
  }

  /// 组成折线的点
  List<Offset> get points => _points;

  List<Offset> _points;

  set points(List<Offset> points) {
    _points = points;
    _calculatedTextureStops = null;
  }

  /// 折线上每个点的颜色
  /// 线的颜色将在两点之间插入
  List<Color> colors;

  /// 折线上每个点的线宽
  List<double> widths;

  /// 将使用此线条绘制纹理
  SpriteTexture get texture => _texture;

  SpriteTexture _texture;

  set texture(SpriteTexture texture) {
    _texture = texture;
    if (texture == null) {
      _cachedPaint = new Paint();
    } else {
      Matrix4 matrix = new Matrix4.identity();
      ImageShader shader = new ImageShader(
          texture.image, TileMode.repeated, TileMode.repeated, matrix.storage);

      _cachedPaint = new Paint()..shader = shader;
    }
  }

  /// 为折线上的每个点定义纹理中的位置
  List<double> textureStops;

  /// 如果没有提供明显的纹理停止点，则使用 [textureStops]
  List<double> get calculatedTextureStops {
    if (_calculatedTextureStops == null) _calculateTextureStops();
    return _calculatedTextureStops;
  }

  List<double> _calculatedTextureStops;

  double _length;

  /// 线的长度
  double get length {
    if (_calculatedTextureStops == null) _calculateTextureStops();
    return _length;
  }

  /// 线上纹理的偏移量
  double textureStopOffset = 0.0;

  /// 拉伸到的长度（以磅为单位）
  /// 如果textureLoopLength短于该线，则纹理将循环
  double get textureLoopLength => textureLoopLength;

  double _textureLoopLength;

  set textureLoopLength(double textureLoopLength) {
    _textureLoopLength = textureLoopLength;
    _calculatedTextureStops = null;
  }

  /// 如果为true，则纹理线会尝试去除折线上尖角处的伪像
  bool removeArtifacts = true;

  /// 混合模式
  BlendMode transferMode = BlendMode.srcOver;

  Paint _cachedPaint = new Paint();

  /// 将线绘制到 [canvas]
  void paint(Canvas canvas) {
    // 检查输入值
    assert(_points != null);
    if (_points.length < 2) return;

    assert(_points.length == colors.length);
    assert(_points.length == widths.length);

    _cachedPaint.blendMode = transferMode;

    List<Vector2> vectors = <Vector2>[];
    for (Offset pt in _points) {
      vectors.add(new Vector2(pt.dx, pt.dy));
    }
    List<Vector2> miters = _computeMiterList(vectors, false);

    List<Offset> vertices = <Offset>[];
    List<int> indices = <int>[];
    List<Color> verticeColors = <Color>[];
    List<Offset> textureCoordinates;
    double textureTop;
    double textureBottom;
    List<double> stops;

    // 添加第一点
    Offset lastPoint = _points[0];
    Vector2 lastMiter = miters[0];

    // 添加顶点和颜色
    _addVerticesForPoint(vertices, lastPoint, lastMiter, widths[0]);
    verticeColors.add(colors[0]);
    verticeColors.add(colors[0]);

    if (texture != null) {
      assert(texture.rotated == false);

      // 用于计算纹理坐标的设置
      textureTop = texture.frame.top;
      textureBottom = texture.frame.bottom;
      textureCoordinates = <Offset>[];

      // 使用正确的停止
      if (textureStops != null) {
        assert(_points.length == textureStops.length);
        stops = textureStops;
      } else {
        if (_calculatedTextureStops == null) _calculateTextureStops();
        stops = _calculatedTextureStops;
      }

      // 纹理坐标点
      double xPos = _xPosForStop(stops[0]);
      textureCoordinates.add(new Offset(xPos, textureTop));
      textureCoordinates.add(new Offset(xPos, textureBottom));
    }

    // 加上其余的点
    for (int i = 1; i < _points.length; i++) {
      // 添加顶点
      Offset currentPoint = _points[i];
      Vector2 currentMiter = miters[i];
      _addVerticesForPoint(vertices, currentPoint, currentMiter, widths[i]);

      // 添加对三角形的引用
      int lastIndex0 = (i - 1) * 2;
      int lastIndex1 = (i - 1) * 2 + 1;
      int currentIndex0 = i * 2;
      int currentIndex1 = i * 2 + 1;
      indices.addAll(<int>[lastIndex0, lastIndex1, currentIndex0]);
      indices.addAll(<int>[lastIndex1, currentIndex1, currentIndex0]);

      // 添加颜色
      verticeColors.add(colors[i]);
      verticeColors.add(colors[i]);

      if (texture != null) {
        // 纹理坐标点
        double xPos = _xPosForStop(stops[i]);
        textureCoordinates.add(new Offset(xPos, textureTop));
        textureCoordinates.add(new Offset(xPos, textureBottom));
      }

      // 更新最后的值
      lastPoint = currentPoint;
      lastMiter = currentMiter;
    }

    var vertexObject = ui.Vertices(
      VertexMode.triangleStrip,
      vertices,
      textureCoordinates: textureCoordinates,
      colors: verticeColors,
    );
    canvas.drawVertices(vertexObject, BlendMode.modulate, _cachedPaint);
  }

  double _xPosForStop(double stop) {
    if (_textureLoopLength == null) {
      return texture.frame.left +
          texture.frame.width * (stop - textureStopOffset);
    } else {
      return texture.frame.left +
          texture.frame.width *
              (stop - textureStopOffset * (_textureLoopLength / length)) *
              (length / _textureLoopLength);
    }
  }

  void _addVerticesForPoint(
      List<Offset> vertices, Offset point, Vector2 miter, double width) {
    double halfWidth = width / 2.0;

    Offset offset0 = new Offset(miter[0] * halfWidth, miter[1] * halfWidth);
    Offset offset1 = new Offset(-miter[0] * halfWidth, -miter[1] * halfWidth);

    Offset vertex0 = point + offset0;
    Offset vertex1 = point + offset1;

    int vertexCount = vertices.length;
    if (removeArtifacts && vertexCount >= 2) {
      Offset oldVertex0 = vertices[vertexCount - 2];
      Offset oldVertex1 = vertices[vertexCount - 1];

      Offset intersection =
          GameMath.lineIntersection(oldVertex0, oldVertex1, vertex0, vertex1);
      if (intersection != null) {
        if (GameMath.distanceBetweenPoints(vertex0, intersection) <
            GameMath.distanceBetweenPoints(vertex1, intersection)) {
          vertex0 = oldVertex0;
        } else {
          vertex1 = oldVertex1;
        }
      }
    }

    vertices.add(vertex0);
    vertices.add(vertex1);
  }

  void _calculateTextureStops() {
    List<double> stops = <double>[];
    double length = 0.0;

    // 添加第一站
    stops.add(0.0);

    // 计算沿线从第一个点到每个点的距离
    for (int i = 1; i < _points.length; i++) {
      Offset lastPoint = _points[i - 1];
      Offset currentPoint = _points[i];

      double dist = GameMath.distanceBetweenPoints(lastPoint, currentPoint);
      length += dist;
      stops.add(length);
    }

    // 标准化 [0.0,1.0] 范围内的值
    for (int i = 1; i < points.length; i++) {
      stops[i] = stops[i] / length;
      new Offset(512.0, 512.0);
    }

    _calculatedTextureStops = stops;
    _length = length;
  }
}

Vector2 _computeMiter(Vector2 lineA, Vector2 lineB) {
  Vector2 miter = new Vector2(-(lineA[1] + lineB[1]), lineA[0] + lineB[0]);
  miter.normalize();

  double dot = dot2(miter, new Vector2(-lineA[1], lineA[0]));
  if (dot.abs() < 0.1) {
    miter = _vectorNormal(lineA)..normalize();
    return miter;
  }

  double miterLength = 1.0 / dot;
  return miter..scale(miterLength);
}

Vector2 _vectorNormal(Vector2 v) {
  return new Vector2(-v[1], v[0]);
}

Vector2 _vectorDirection(Vector2 a, Vector2 b) {
  Vector2 result = a - b;
  return result..normalize();
}

List<Vector2> _computeMiterList(List<Vector2> points, bool closed) {
  List<Vector2> out = <Vector2>[];
  Vector2 curNormal;

  if (closed) {
    points = new List<Vector2>.from(points);
    points.add(points[0]);
  }

  int total = points.length;
  for (int i = 1; i < total; i++) {
    Vector2 last = points[i - 1];
    Vector2 cur = points[i];
    Vector2 next = (i < total - 1) ? points[i + 1] : null;

    Vector2 lineA = _vectorDirection(cur, last);
    if (curNormal == null) {
      curNormal = _vectorNormal(lineA);
    }

    if (i == 1) {
      out.add(curNormal);
    }

    if (next == null) {
      curNormal = _vectorNormal(lineA);
      out.add(curNormal);
    } else {
      Vector2 lineB = _vectorDirection(next, cur);
      Vector2 miter = _computeMiter(lineA, lineB);
      out.add(miter);
    }
  }

  return out;
}
