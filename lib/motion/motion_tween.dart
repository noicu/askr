part of askr;

typedef void SetterCallback(dynamic value);

/// 产生在两个值之间的补间值，可选使用运动曲线
///
/// [MotionTween] 是创建动作时最常用的模块之一
///
/// [MotionTween] 可用于为 [Point]，[Size]，[Rect]，[double] 或 [Color] 类型的属性设置动画
class MotionTween<T> extends MotionInterval {
  /// 创建一个新的补间动画
  ///
  /// 在 [duration] 时间内，将动画属性从 [startVal] 更新为 [endVal] 并更新调用 [setter]
  ///
  /// 可以使用 [curve] 设置运动曲线进行缓动
  /// ```dart
  /// var myTween = new MotionTween<Offset>(
  ///     (pos) => myNode.position = pos,
  ///     myNode.position,
  ///     Offset(100.0, 100.0),
  ///     1.0,
  ///     Curves.bounceOut
  /// );
  /// myNode.motions.run(myTween);
  /// ```
  MotionTween(this.setter, this.startVal, this.endVal, double duration,
      [Curve curve])
      : super(duration, curve) {
    _computeDelta();
  }

  /// 运行动作时更新属性的回调
  final SetterCallback setter;

  /// 动画的起始值
  final T startVal;

  /// 动画的最终值
  final T endVal;

  dynamic _delta;

  void _computeDelta() {
    if (startVal is Offset) {
      // 点
      double xStart = (startVal as Offset).dx;
      double yStart = (startVal as Offset).dy;
      double xEnd = (endVal as Offset).dx;
      double yEnd = (endVal as Offset).dy;
      _delta = new Offset(xEnd - xStart, yEnd - yStart);
    } else if (startVal is Size) {
      // 尺寸
      double wStart = (startVal as Size).width;
      double hStart = (startVal as Size).height;
      double wEnd = (endVal as Size).width;
      double hEnd = (endVal as Size).height;
      _delta = new Size(wEnd - wStart, hEnd - hStart);
    } else if (startVal is Rect) {
      // 矩形
      double lStart = (startVal as Rect).left;
      double tStart = (startVal as Rect).top;
      double rStart = (startVal as Rect).right;
      double bStart = (startVal as Rect).bottom;
      double lEnd = (endVal as Rect).left;
      double tEnd = (endVal as Rect).top;
      double rEnd = (endVal as Rect).right;
      double bEnd = (endVal as Rect).bottom;
      _delta = new Rect.fromLTRB(
          lEnd - lStart, tEnd - tStart, rEnd - rStart, bEnd - bStart);
    } else if (startVal is double) {
      // 浮点数
      _delta = (endVal as double) - (startVal as double);
    } else if (startVal is Color) {
      // 颜色
      int aDelta = (endVal as Color).alpha - (startVal as Color).alpha;
      int rDelta = (endVal as Color).red - (startVal as Color).red;
      int gDelta = (endVal as Color).green - (startVal as Color).green;
      int bDelta = (endVal as Color).blue - (startVal as Color).blue;
      _delta = new _ColorDiff(aDelta, rDelta, gDelta, bDelta);
    } else {
      assert(false);
    }
  }

  @override
  void update(double t) {
    dynamic newVal;

    if (startVal is Offset) {
      // 点
      double xStart = (startVal as Offset).dx;
      double yStart = (startVal as Offset).dy;
      double xDelta = _delta.dx;
      double yDelta = _delta.dy;
      newVal = new Offset(xStart + xDelta * t, yStart + yDelta * t);
    } else if (startVal is Size) {
      // 尺寸
      double wStart = (startVal as Size).width;
      double hStart = (startVal as Size).height;
      double wDelta = _delta.width;
      double hDelta = _delta.height;
      newVal = new Size(wStart + wDelta * t, hStart + hDelta * t);
    } else if (startVal is Rect) {
      // 矩形
      double lStart = (startVal as Rect).left;
      double tStart = (startVal as Rect).top;
      double rStart = (startVal as Rect).right;
      double bStart = (startVal as Rect).bottom;
      double lDelta = _delta.left;
      double tDelta = _delta.top;
      double rDelta = _delta.right;
      double bDelta = _delta.bottom;
      newVal = new Rect.fromLTRB(lStart + lDelta * t, tStart + tDelta * t,
          rStart + rDelta * t, bStart + bDelta * t);
    } else if (startVal is double) {
      // 浮点数
      newVal = (startVal as double) + _delta * t;
    } else if (startVal is Color) {
      // 颜色
      int aNew = ((startVal as Color).alpha + (_delta.alpha * t).toInt())
          .clamp(0, 255);
      int rNew =
          ((startVal as Color).red + (_delta.red * t).toInt()).clamp(0, 255);
      int gNew = ((startVal as Color).green + (_delta.green * t).toInt())
          .clamp(0, 255);
      int bNew =
          ((startVal as Color).blue + (_delta.blue * t).toInt()).clamp(0, 255);
      newVal = new Color.fromARGB(aNew, rNew, gNew, bNew);
    } else {
      assert(false);
    }

    setter(newVal);
  }
}

class _ColorDiff {
  final int alpha;
  final int red;
  final int green;
  final int blue;

  _ColorDiff(this.alpha, this.red, this.green, this.blue);
}
