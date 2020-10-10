part of askr;

class _Atan2Constants {
  _Atan2Constants() {
    for (int i = 0; i <= size; i++) {
      double f = i.toDouble() / size.toDouble();
      ppy[i] = math.atan(f) * stretch / math.pi;
      ppx[i] = stretch * 0.5 - ppy[i];
      pny[i] = -ppy[i];
      pnx[i] = ppy[i] - stretch * 0.5;
      npy[i] = stretch - ppy[i];
      npx[i] = ppy[i] + stretch * 0.5;
      nny[i] = ppy[i] - stretch;
      nnx[i] = -stretch * 0.5 - ppy[i];
    }
  }

  static const int size = 1024;
  static const double stretch = math.pi;

  static const int ezis = -size;

  final Float64List ppy = new Float64List(size + 1);
  final Float64List ppx = new Float64List(size + 1);
  final Float64List pny = new Float64List(size + 1);
  final Float64List pnx = new Float64List(size + 1);
  final Float64List npy = new Float64List(size + 1);
  final Float64List npx = new Float64List(size + 1);
  final Float64List nny = new Float64List(size + 1);
  final Float64List nnx = new Float64List(size + 1);
}

/// 为图形中经常执行的计算提供方便的方法。
/// 有些方法返回近似值。
class GameMath {
  static final _Atan2Constants _atan2 = new _Atan2Constants();

  /// 返回方位角
  /// 结果不如标准数学库中的atan2函数准确
  static double atan2(double y, double x) {
    if (x >= 0) {
      if (y >= 0) {
        if (x >= y)
          return _atan2.ppy[(_Atan2Constants.size * y / x + 0.5).toInt()];
        else
          return _atan2.ppx[(_Atan2Constants.size * x / y + 0.5).toInt()];
      } else {
        if (x >= -y)
          return _atan2.pny[(_Atan2Constants.ezis * y / x + 0.5).toInt()];
        else
          return _atan2.pnx[(_Atan2Constants.ezis * x / y + 0.5).toInt()];
      }
    } else {
      if (y >= 0) {
        if (-x >= y)
          return _atan2.npy[(_Atan2Constants.ezis * y / x + 0.5).toInt()];
        else
          return _atan2.npx[(_Atan2Constants.ezis * x / y + 0.5).toInt()];
      } else {
        if (x <= y)
          return _atan2.nny[(_Atan2Constants.size * y / x + 0.5).toInt()];
        else
          return _atan2.nnx[(_Atan2Constants.size * x / y + 0.5).toInt()];
      }
    }
  }

  /// 两点之间的近似距离
  /// 在最坏的情况下，返回值最多错误6％
  static double distanceBetweenPoints(Offset a, Offset b) {
    double dx = a.dx - b.dx;
    double dy = a.dy - b.dy;
    if (dx < 0.0) dx = -dx;
    if (dy < 0.0) dy = -dy;
    if (dx > dy) {
      return dx + dy / 2.0;
    } else {
      return dy + dx / 2.0;
    }
  }

  /// 根据 [filterFactor] 在 [a] 和 [b] 之间插入[double]值
  /// 该值应在 0.0 到 1.0 的范围内
  static double filter(double a, double b, double filterFactor) {
    return (a * (1 - filterFactor)) + b * filterFactor;
  }

  /// 根据 [filterFactor] 在 [a] 和 [b] 之间插入 [Point]
  /// 该点应在 0.0 到 1.0 的范围内
  static Offset filterPoint(Offset a, Offset b, double filterFactor) {
    return new Offset(
      filter(a.dx, b.dx, filterFactor),
      filter(a.dy, b.dy, filterFactor),
    );
  }

  /// 返回由 p0,p1 和 q0,q1 两根线段之间的交点
  /// 如果行不相交，则返回 null
  static Offset lineIntersection(Offset p0, Offset p1, Offset q0, Offset q1) {
    double epsilon = 1e-10;

    Vector2 r = new Vector2(p1.dx - p0.dx, p1.dy - p0.dy);
    Vector2 s = new Vector2(q1.dx - q0.dx, q1.dy - q0.dy);
    Vector2 qp = new Vector2(q0.dx - p0.dx, q0.dy - p0.dy);

    double rxs = cross2(r, s);

    if (rxs.abs() < epsilon) {
      // 线是线性或共线的
      return null;
    }

    double t = cross2(qp, s) / rxs;
    double u = cross2(qp, r) / rxs;

    if ((0.0 <= t && t <= 1.0) && (0.0 <= u && u <= 1.0)) {
      return new Offset(p0.dx + t * r.x, p0.dy + t * r.y);
    }

    // 线之间没有相交
    return null;
  }
}
