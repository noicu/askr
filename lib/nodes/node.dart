part of askr;

/// 将角度转换为弧度。
double convertDegrees2Radians(double degrees) => degrees * math.pi / 180.0;

/// 将弧度转换为角度。
double convertRadians2Degrees(double radians) => radians * 180.0 / math.pi;

///* 所有可以添加到精灵节点树并使用 [SpriteBox] 和 [SpriteWidget] 渲染对象的基类。
///
///* [Node] 类本身不呈现任何内容，但是提供任何类型的节点的基本功能，例如：处理变换和用户输入。
///
///* 要渲染节点树，必须将根节点添加到 [SpriteBox] 或 [SpriteWidget] 。
///
///* [Node] 的常用子类是 [Sprite]、[NodeWithSize]、以及许多其他即将到来的子类。
///
///* 节点形成一个层次树。 每个节点可以有多个子节点，含有变换（位置·旋转·缩放）以及可见性，变化也会影响其子节点。
class Node {
  Node();

  SpriteBox _spriteBox;
  Node _parent;

  Offset _position = Offset.zero;
  double _rotation = 0.0;

  Matrix4 _transformMatrix = new Matrix4.identity();
  Matrix4 _transformMatrixInverse;
  Matrix4 _transformMatrixNodeToBox;
  Matrix4 _transformMatrixBoxToNode;

  double _scaleX = 1.0;
  double _scaleY = 1.0;

  double _skewX = 0.0;
  double _skewY = 0.0;

  /// 此节点及其子节点的可见性。
  bool visible = true;

  double _zIndex = 0.0;
  int _addedOrder;
  int _childrenLastAddedOrder = 0;
  bool _childrenNeedSorting = false;

  /// 此节点及其子节点当前是否暂停。
  ///
  /// 暂停的节点不会接收任何输入事件、更新调用或运行任何动画。
  /// ```dart
  /// myNodeTree.paused = true;
  /// ```
  bool paused = false;

  bool _userInteractionEnabled = false;

  /// If set to true the node will receive multiple pointers, otherwise it will only receive events the first pointer.
  ///
  /// This property is only meaningful if [userInteractionEnabled] is set to true. Default value is false.
  ///
  /// 如果第一个节点的指针设置为true，则它将只接收多个指针。
  ///
  /// [userInteractionEnabled] 设置为true时，此属性才有意义。默认值为false。
  ///
  ///```dart
  ///class MyCustomNode extends Node {
  ///   handleMultiplePointers = true;
  ///}
  ///```
  bool handleMultiplePointers = false;
  int _handlingPointer;

  List<Node> _children = <Node>[];

  MotionController _motions;

  /// 与此节点关联的 [MotionController]
  ///```dart
  /// myNode.motions.run(myMotion);
  ///```
  MotionController get motions {
    if (_motions == null) {
      _motions = new MotionController();
      if (_spriteBox != null) _spriteBox._motionControllers = null;
    }
    return _motions;
  }

  @Deprecated('actions has been renamed to motions')
  MotionController get actions => motions;

  List<Constraint> _constraints;

  /// 将应用于节点的 [Constraint] 的 [List]
  ///
  /// 在调用 [update] 方法后应用约束
  List<Constraint> get constraints {
    return _constraints;
  }

  set constraints(List<Constraint> constraints) {
    _constraints = constraints;
    if (_spriteBox != null) _spriteBox._constrainedNodes = null;
  }

  /// 将 [constraints] 应用于节点
  ///
  /// 通常，这方法是由 [SpriteBox] 自动调用
  ///
  /// 如果需要立即应用约束，也可以手动调用
  void applyConstraints(double dt) {
    if (_constraints == null) return;

    for (Constraint constraint in _constraints) {
      constraint.constrain(this, dt);
    }
  }

  /// 此节点被添加到的 [SpriteBox] 如果当前未添加到 [SpriteBox] 则为空
  ///
  /// 对于大多数应用程序来说，不需要直接访问 [SpriteBox]
  ///
  ///  ```dart
  /// // 获取精灵盒的变换模式
  /// SpriteBoxTransformMode transformMode = myNode.spriteBox.transformMode;
  /// ```
  SpriteBox get spriteBox => _spriteBox;

  /// 此节点的父节点，如果没有父节点，则为null
  ///
  ///  ```dart
  /// // 隐藏父对象
  /// myNode.parent.visible = false;
  /// ```
  Node get parent => _parent;

  /// 此节点的旋转角度
  ///  ```dart
  ///myNode.rotation = 45.0;
  /// ```
  double get rotation => _rotation;

  set rotation(double rotation) {
    assert(rotation != null);

    _rotation = rotation;
    invalidateTransformMatrix();
  }

  /// 此节点相对于其父节点的位置
  /// ```dart
  /// myNode.position = new Point(42.0, 42.0);
  /// ```
  Offset get position => _position;

  set position(Offset position) {
    assert(position != null);

    _position = position;
    invalidateTransformMatrix();
  }

  /// 沿此节点的x轴的倾斜（以度为单位）
  /// ```dart
  /// myNode.skewX = 45.0;
  /// ```
  double get skewX => _skewX;

  set skewX(double skewX) {
    assert(skewX != null);
    _skewX = skewX;
    invalidateTransformMatrix();
  }

  /// 沿此节点的y轴的倾斜（以度为单位）
  /// ```dart
  /// myNode.skewY = 45.0;
  /// ```
  double get skewY => _skewY;

  set skewY(double skewY) {
    assert(skewY != null);
    _skewY = skewY;
    invalidateTransformMatrix();
  }

  /// 此节点相对于其父节点及其同级节点的绘制顺序
  ///
  /// 默认情况下，节点是按照添加到父节点的顺序绘制的
  ///
  /// 要重写此行为可以使用 [zIndex] 属性
  ///
  /// 如果使用负值，则节点将绘制在其父节点之后。
  ///
  /// 参考 css [z-index]
  /// ```dart
  /// nodeInFront.zIndex = 1.0;
  /// nodeBehind.zIndex = -1.0;
  /// ```
  double get zIndex => _zIndex;

  set zIndex(double zIndex) {
    assert(zIndex != null);
    _zIndex = zIndex;
    if (_parent != null) {
      _parent._childrenNeedSorting = true;
    }
  }

  /// 此节点相对于其父节点的比例
  ///
  /// 当 [scaleX] 和 [scaleY] 的值相等时 [scale] 属性才有效
  /// ```dart
  /// myNode.scale = 5.0;
  /// ```
  double get scale {
    assert(_scaleX == _scaleY);
    return _scaleX;
  }

  set scale(double scale) {
    assert(scale != null);

    _scaleX = _scaleY = scale;
    invalidateTransformMatrix();
  }

  /// 此节点相对于其父节点的水平比例
  /// ```dart
  /// myNode.scaleX = 5.0;
  /// ```
  double get scaleX => _scaleX;

  set scaleX(double scaleX) {
    assert(scaleX != null);

    _scaleX = scaleX;
    invalidateTransformMatrix();
  }

  /// 此节点相对于其父节点的垂直比例
  /// ```dart
  /// myNode.scaleY = 5.0;
  /// ```
  double get scaleY => _scaleY;

  set scaleY(double scaleY) {
    assert(scaleY != null);

    _scaleY = scaleY;
    invalidateTransformMatrix();
  }

  /// 此节点的子节点列表
  ///
  /// 只能使用 [addChild] 和 [removeChild] 方法修改此列表
  ///```dart
  /// // 遍历子节点
  /// for (Node child in myNode.children) {
  ///   ...
  /// }
  /// ```
  List<Node> get children {
    _sortChildren();
    return _children;
  }

  bool _assertNonCircularAssignment(Node child) {
    Node node = this;
    while (node.parent != null) {
      node = node.parent;
      assert(node != child); // indicates we are about to create a cycle
    }
    return true;
  }

  // 添加和删除子节点

  /// 将子节点添加到此节点
  ///
  /// 不能将同一节点添加到多个节点
  /// ```dart
  /// addChild(new Sprite(myImage));
  /// ```
  void addChild(Node child) {
    assert(child != null);
    assert(child._parent == null);
    assert(_assertNonCircularAssignment(child));

    _childrenNeedSorting = true;
    _children.add(child);
    child._parent = this;
    child._spriteBox = this._spriteBox;
    _childrenLastAddedOrder += 1;
    child._addedOrder = _childrenLastAddedOrder;
    if (_spriteBox != null) _spriteBox._registerNode(child);
  }

  /// 从该节点删除子节点
  /// ```dart
  /// removeChild(myChildNode);
  /// ```
  void removeChild(Node child) {
    assert(child != null);
    if (_children.remove(child)) {
      child._parent = null;
      child._spriteBox = null;
      if (_spriteBox != null) _spriteBox._deregisterNode(child);
    }
  }

  /// 将此节点从其父节点中移除
  /// ```dart
  /// removeFromParent();
  /// ```
  void removeFromParent() {
    assert(_parent != null);
    _parent.removeChild(this);
  }

  /// 删除此节点的所有子节点
  /// ```dart
  /// removeAllChildren();
  /// ```
  void removeAllChildren() {
    for (Node child in _children) {
      child._parent = null;
      child._spriteBox = null;
    }
    _children = <Node>[];
    _childrenNeedSorting = false;
    if (_spriteBox != null) _spriteBox._deregisterNode(null);
  }

  void _sortChildren() {
    // 首先按zIndex对子级进行排序，其次按添加顺序排序
    if (_childrenNeedSorting) {
      _children.sort((Node a, Node b) {
        if (a._zIndex == b._zIndex) {
          return a._addedOrder - b._addedOrder;
        } else if (a._zIndex > b._zIndex) {
          return 1;
        } else {
          return -1;
        }
      });
      _childrenNeedSorting = false;
    }
  }

  // 计算变换矩阵

  /// transformMatrix描述从节点的父节点进行的转换
  ///
  /// 不能直接设置transformMatrix，而是使用 [位置] , [旋转] , [缩放] 属性
  /// ```dart
  /// Matrix4 matrix = myNode.transformMatrix;
  /// ```
  Matrix4 get transformMatrix {
    if (_transformMatrix == null) {
      _transformMatrix = computeTransformMatrix();
    }
    return _transformMatrix;
  }

  /// 计算此节点的变换矩阵
  ///
  /// 如果需要自定义矩阵，则可以重写此方法
  ///
  /// 通常不会直接调用此方法
  Matrix4 computeTransformMatrix() {
    double cx, sx, cy, sy;

    if (_rotation == 0.0) {
      cx = 1.0;
      sx = 0.0;
      cy = 1.0;
      sy = 0.0;
    } else {
      double radiansX = convertDegrees2Radians(_rotation);
      double radiansY = convertDegrees2Radians(_rotation);

      cx = math.cos(radiansX);
      sx = math.sin(radiansX);
      cy = math.cos(radiansY);
      sy = math.sin(radiansY);
    }

    // 创建缩放、位置和旋转的变换矩阵
    Matrix4 matrix = new Matrix4(
      cy * _scaleX,
      sy * _scaleX,
      0.0,
      0.0,
      -sx * _scaleY,
      cx * _scaleY,
      0.0,
      0.0,
      0.0,
      0.0,
      1.0,
      0.0,
      _position.dx,
      _position.dy,
      0.0,
      1.0,
    );

    if (_skewX != 0.0 || _skewY != 0.0) {
      // 倾斜变换
      Matrix4 skew = new Matrix4(
        1.0,
        math.tan(radians(_skewX)),
        0.0,
        0.0,
        math.tan(radians(_skewY)),
        1.0,
        0.0,
        0.0,
        0.0,
        0.0,
        1.0,
        0.0,
        0.0,
        0.0,
        0.0,
        1.0,
      );
      matrix.multiply(skew);
    }
    return matrix;
  }

  /// 使当前变换矩阵无效
  /// 如果 [computeTransformMatrix] 方法被重写，则每当影响矩阵的属性更改时都应调用此方法
  void invalidateTransformMatrix() {
    _transformMatrix = null;
    _transformMatrixInverse = null;
    _invalidateToBoxTransformMatrix();
  }

  void _invalidateToBoxTransformMatrix() {
    _transformMatrixNodeToBox = null;
    _transformMatrixBoxToNode = null;

    for (Node child in children) {
      child._invalidateToBoxTransformMatrix();
    }
  }

  // 转换到其他节点
  Matrix4 _nodeToBoxMatrix() {
    assert(_spriteBox != null);
    if (_transformMatrixNodeToBox != null) {
      return _transformMatrixNodeToBox;
    }

    if (_parent == null) {
      // Base case, we are at the top
      assert(this == _spriteBox.rootNode);
      _transformMatrixNodeToBox = _spriteBox.transformMatrix.clone()
        ..multiply(transformMatrix);
    } else {
      _transformMatrixNodeToBox = _parent._nodeToBoxMatrix().clone()
        ..multiply(transformMatrix);
    }
    return _transformMatrixNodeToBox;
  }

  Matrix4 _boxToNodeMatrix() {
    assert(_spriteBox != null);

    if (_transformMatrixBoxToNode != null) {
      return _transformMatrixBoxToNode;
    }

    _transformMatrixBoxToNode = new Matrix4.copy(_nodeToBoxMatrix());
    _transformMatrixBoxToNode.invert();

    return _transformMatrixBoxToNode;
  }

  /// 此节点使用的逆变换矩阵
  Matrix4 get inverseTransformMatrix {
    if (_transformMatrixInverse == null) {
      _transformMatrixInverse = new Matrix4.copy(transformMatrix);
      _transformMatrixInverse.invert();
    }
    return _transformMatrixInverse;
  }

  /// 将点从 [SpriteBox] 的坐标系转换为节点的局部坐标系
  ///
  /// 此方法在处理指针事件和需要指针在局部坐标空间中的位置时特别有用
  /// ```dart
  /// Point localPoint = myNode.convertPointToNodeSpace(pointInBoxCoordinates);
  /// ```
  Offset convertPointToNodeSpace(Offset boxPoint) {
    assert(boxPoint != null);
    assert(_spriteBox != null);

    Vector4 v = _boxToNodeMatrix()
        .transform(new Vector4(boxPoint.dx, boxPoint.dy, 0.0, 1.0));
    return new Offset(v[0], v[1]);
  }

  /// 将点从节点的局部坐标系转换为 [SpriteBox] 的坐标系
  ///```dart
  /// Point pointInBoxCoordinates = myNode.convertPointToBoxSpace(localPoint);
  ///```
  Offset convertPointToBoxSpace(Offset nodePoint) {
    assert(nodePoint != null);
    assert(_spriteBox != null);

    Vector4 v = _nodeToBoxMatrix()
        .transform(new Vector4(nodePoint.dx, nodePoint.dy, 0.0, 1.0));
    return new Offset(v[0], v[1]);
  }

  /// 将 [point] 从另一个 [node] 的坐标系转换为该节点的局部坐标系
  /// ```dart
  /// Point pointInNodeASpace = nodeA.convertPointFromNode(pointInNodeBSpace, nodeB);
  /// ```
  Offset convertPointFromNode(Offset point, Node node) {
    assert(node != null);
    assert(point != null);
    assert(_spriteBox != null);
    assert(_spriteBox == node._spriteBox);

    Offset boxPoint = node.convertPointToBoxSpace(point);
    Offset localPoint = convertPointToNodeSpace(boxPoint);

    return localPoint;
  }

  // 命中测试

  /// 如果 [point] 在节点内，则返回true，[point] 在节点的局部坐标系中
  /// ```dart
  /// myNode.isPointInside(localPoint);
  /// ```
  /// [NodeWithSize] 为该方法提供了一个基本的边界框检查，如果需要更详细的检查，则可以重写此方法
  /// ```dart
  ///     bool isPointInside (Point nodePoint) {
  ///       double minX = -size.width * pivot.x;
  ///       double minY = -size.height * pivot.y;
  ///       double maxX = minX + size.width;
  ///       double maxY = minY + size.height;
  ///       return (nodePoint.x >= minX && nodePoint.x < maxX &&
  ///       nodePoint.y >= minY && nodePoint.y < maxY);
  ///     }
  /// ```
  bool isPointInside(Offset point) {
    assert(point != null);

    return false;
  }

  // 渲染

  void _visit(Canvas canvas) {
    assert(canvas != null);
    if (!visible) return;

    _prePaint(canvas);
    _visitChildren(canvas);
    _postPaint(canvas);
  }

  @mustCallSuper
  void _prePaint(Canvas canvas) {
    canvas
      ..save()
      ..transform(transformMatrix.storage);
  }

  /// 将该节点绘制到画布上
  ///
  /// 子类如 [Sprite] 重写此方法来实现绘制节点
  ///
  /// 要执行自定义绘图，请重写此方法并调用 [canvas] 对象
  ///
  /// 所有绘图都是在节点的局部坐标系中完成的，相对于节点的位置
  ///
  /// 如果要使绘图相对于节点的边框原点，请在调用绘图之前重写 [NodeWithSize] 并调用 [applyTransformForPivot] 方法
  /// ```dart
  ///     void paint(Canvas canvas) {
  ///       canvas.save();
  ///       applyTransformForPivot(canvas);
  ///       // 在这里绘制
  ///       canvas.restore();
  ///     }
  /// ```
  void paint(Canvas canvas) {}

  void _visitChildren(Canvas canvas) {
    // 根据需要对子项进行排序
    _sortChildren();

    int i = 0;
    // 访问此节点后面的子节点
    while (i < _children.length) {
      Node child = _children[i];
      if (child.zIndex >= 0.0) break;
      child._visit(canvas);
      i++;
    }

    // 绘制此节点
    paint(canvas);

    // 访问此节点前面的子节点
    while (i < _children.length) {
      Node child = _children[i];
      child._visit(canvas);
      i++;
    }
  }

  @mustCallSuper
  void _postPaint(Canvas canvas) {
    canvas.restore();
  }

  // 接收更新调用

  /// 在绘制帧之前调用
  ///
  /// 重写此方法以在将节点或节点树绘制到屏幕之前对其进行任何更新
  /// ```dart
  /// // 使节点以固定速度旋转
  /// void update(double dt) {
  ///   rotation = rotation * 10.0 * dt;
  /// }
  /// ```
  void update(double dt) {}

  /// 每当 [SpriteBox] 被修改或调整大小，或设备旋转时调用
  ///
  /// 重写此方法以执行任何必要的更新，以便使用 [SpriteBox] 的新布局正确显示节点或节点树
  /// ```dart
  /// void spriteBoxPerformedLayout() {
  /// ...
  /// }
  /// ```
  void spriteBoxPerformedLayout() {}

  // 处理用户交互

  /// 节点将接收用户交互，例如指针（触摸或鼠标）事件
  /// ```dart
  ///     class MyCustomNode extends NodeWithSize {
  ///       userInteractionEnabled = true;
  ///     }
  /// ```
  bool get userInteractionEnabled => _userInteractionEnabled;

  set userInteractionEnabled(bool userInteractionEnabled) {
    _userInteractionEnabled = userInteractionEnabled;
    if (_spriteBox != null) _spriteBox._eventTargets = null;
  }

  /// 处理事件，例如指针（触摸或鼠标）事件
  ///
  /// 重写此方法以处理事件
  ///
  /// 只有在 [userInteractionEnabled] 属性为设置为true，[isPointInside] 方法为指针向下事件的位置返回true（默认行为由 [NodeWithSize] 提供）
  ///
  /// 除非 [handleMultiplePointers] 设置为true，否则节点将只接收第一个指针关闭的事件
  ///
  /// 如果节点已使用事件，则返回true；如果事件已使用，则不会将其传递到当前节点后面的节点
  /// ```dart
  ///     // MyTouchySprite gets transparent when we touch it
  ///     class MyTouchySprite extends Sprite {
  ///
  ///       MyTouchySprite(Image img) : super (img) {
  ///         userInteractionEnabled = true;
  ///       }
  ///
  ///       bool handleEvent(SpriteBoxEvent event) {
  ///         if (event.type == PointerDownEvent) {
  ///           opacity = 0.5;
  ///         }
  ///         else if (event.type == PointerUpEvent) {
  ///           opacity = 1.0;
  ///         }
  ///         return true;
  ///       }
  ///     }
  /// ```
  bool handleEvent(SpriteBoxEvent event) {
    return false;
  }
}
