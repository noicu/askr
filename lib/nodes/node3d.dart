part of askr;

/// 使用3D透视投影变换其子级的节点
/// 此节点类型可用于创建3D翻转和其他类似效果
/// ```dart
/// var myNode3D = new Node3D();
/// myNode3D.rotationY = 45.0;
/// myNode3D.addChild(new Sprite(myTexture));
/// ```
class Node3D extends Node {
  double _rotationX = 0.0;

  /// 节点围绕x轴的旋转（以度为单位）
  double get rotationX => _rotationX;

  set rotationX(double rotationX) {
    _rotationX = rotationX;
    invalidateTransformMatrix();
  }

  double _rotationY = 0.0;

  /// 节点围绕y轴的旋转（以度为单位）
  double get rotationY => _rotationY;

  set rotationY(double rotationY) {
    _rotationY = rotationY;
    invalidateTransformMatrix();
  }

  double _projectionDepth = 500.0;

  /// 投影深度,默认值为500.0
  double get projectionDepth => _projectionDepth;

  set projectionDepth(double projectionDepth) {
    _projectionDepth = projectionDepth;
    invalidateTransformMatrix();
  }

  @override
  Matrix4 computeTransformMatrix() {
    // 应用普通的2D变换
    Matrix4 matrix = super.computeTransformMatrix();

    // 应用透视投影
    Matrix4 projection = new Matrix4(1.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0,
        0.0, 0.0, 1.0, -1.0 / _projectionDepth, 0.0, 0.0, 0.0, 1.0);
    matrix.multiply(projection);

    // 绕x和y轴旋转
    matrix.rotateY(radians(_rotationY));
    matrix.rotateX(radians(_rotationX));

    return matrix;
  }
}
