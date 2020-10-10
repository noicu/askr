part of askr;

typedef void PointSetterCallback(Offset value);

/// 样条曲线运动
/// https://baike.baidu.com/item/%E6%A0%B7%E6%9D%A1%E5%87%BD%E6%95%B0/5863303?fr=aladdin
class MotionSpline extends MotionInterval {
  /// 用一组点创建一个新的样条曲线运动
  ///
  /// [setter] 是用于设置位置的回调， [points] 定义样条， [duration] 是运动持续时间
  ///
  /// 可以使用 [curve] 设置运动曲线进行缓动
  /// ```dart
  /// var mySpline = MotionSpline(
  ///     (pos) => myNode.position = pos,
  ///     [Offset(0, 500), Offset(500, 500), Offset(500, 0)],
  ///     3,
  ///     Curves.fastOutSlowIn
  /// );
  /// myNode.motions.run(mySpline);
  /// ```
  MotionSpline(this.setter, this.points, double duration, [Curve curve])
      : super(duration, curve) {
    _dt = 1.0 / (points.length - 1.0);
  }

  /// 运行动作时更新点的回调
  final PointSetterCallback setter;

  /// 定义样条曲线的点列表
  final List<Offset> points;

  /// 样条的张力
  /// 定义曲线的光滑度
  double tension = 0.5;

  double _dt;

  @override
  void update(double t) {
    int p;
    double lt;

    if (t < 0.0) t = 0.0;

    if (t >= 1.0) {
      p = points.length - 1;
      lt = 1.0;
    } else {
      p = (t / _dt).floor();
      lt = (t - _dt * p) / _dt;
    }

    Offset p0 = points[(p - 1).clamp(0, points.length - 1)];
    Offset p1 = points[(p + 0).clamp(0, points.length - 1)];
    Offset p2 = points[(p + 1).clamp(0, points.length - 1)];
    Offset p3 = points[(p + 2).clamp(0, points.length - 1)];

    Offset newPos = _cardinalSplineAt(p0, p1, p2, p3, tension, lt);

    setter(newPos);
  }
}

Offset _cardinalSplineAt(
    Offset p0, Offset p1, Offset p2, Offset p3, double tension, double t) {
  double t2 = t * t;
  double t3 = t2 * t;

  double s = (1.0 - tension) / 2.0;

  double b1 = s * ((-t3 + (2.0 * t2)) - t);
  double b2 = s * (-t3 + t2) + (2.0 * t3 - 3.0 * t2 + 1.0);
  double b3 = s * (t3 - 2.0 * t2 + t) + (-2.0 * t3 + 3.0 * t2);
  double b4 = s * (t3 - t2);

  double x = p0.dx * b1 + p1.dx * b2 + p2.dx * b3 + p3.dx * b4;
  double y = p0.dy * b1 + p1.dy * b2 + p2.dy * b3 + p3.dy * b4;

  return new Offset(x, y);
}
