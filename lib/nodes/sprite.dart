part of askr;

/// Sprite是一个 [Node] ，可将位图渲染到屏幕上
class Sprite extends NodeWithSize with SpritePaint {
  /// 要渲染到屏幕的纹理
  ///
  /// 如果纹理为null，则精灵将呈现为红色正方形，标记精灵的边界
  /// ```dart
  /// mySprite.texture = myTexture;
  /// ```
  SpriteTexture texture;

  /// 如果为true，则如果图像的比例与 [size] 不匹配，则通过缩小图像来限制图像的比例
  /// ```dart
  /// mySprite.constrainProportions = true;
  /// ```
  bool constrainProportions = false;

  Paint _cachedPaint = new Paint()
    ..filterQuality = FilterQuality.low
    ..isAntiAlias = false;

  /// 根据提供的 [texture] 创建一个新的精灵
  /// ```dart
  /// var mySprite = new Sprite(myTexture)
  /// ```
  Sprite([this.texture]) : super(Size.zero) {
    if (texture != null) {
      size = texture.size;
      pivot = texture.pivot;
    } else {
      pivot = new Offset(0.5, 0.5);
    }
  }

  /// 根据提供的 [image] 创建一个新的精灵
  /// ```dart
  /// var mySprite = new Sprite.fromImage(myImage);
  /// ```
  Sprite.fromImage(ui.Image image) : super(Size.zero) {
    assert(image != null);

    texture = new SpriteTexture(image);
    size = texture.size;

    pivot = new Offset(0.5, 0.5);
  }

  @override
  void paint(Canvas canvas) {
    applyTransformForPivot(canvas);

    if (texture != null) {
      double w = texture.size.width;
      double h = texture.size.height;

      if (w <= 0 || h <= 0) return;

      double scaleX = size.width / w;
      double scaleY = size.height / h;

      if (constrainProportions) {
        // 使用最小比例并通过居中图像来限制比例
        if (scaleX < scaleY) {
          canvas.translate(0.0, (size.height - scaleX * h) / 2.0);
          scaleY = scaleX;
        } else {
          canvas.translate((size.width - scaleY * w) / 2.0, 0.0);
          scaleX = scaleY;
        }
      }

      canvas.scale(scaleX, scaleY);

      // 设置绘画对象的不透明度和混合模式
      _updatePaint(_cachedPaint);

      // 实际绘制精灵
      texture.drawTexture(canvas, Offset.zero, _cachedPaint);

      // 调试
      if (debugPaintSizeEnabled) {
        canvas.drawRect(Offset.zero & texture.size,
            new Paint()..color = const Color(0x1700FFF2));
        debugDrawing(canvas, texture.size);
      }
    } else {
      // 画一个红色方块以弥补缺失的纹理
      canvas.drawRect(new Rect.fromLTRB(0.0, 0.0, size.width, size.height),
          new Paint()..color = new Color.fromARGB(255, 255, 0, 0));
    }
  }
}

/// 定义属性，例如 [opacity] 和 [transferMode]，这些属性在将纹理渲染到屏幕的 [Node] 之间共享
abstract class SpritePaint {
  double _opacity = 1.0;

  /// Sprite的不透明度在0.0到1.0的范围内
  /// ```dart
  /// mySprite.opacity = 0.5;
  /// ```
  double get opacity => _opacity;

  set opacity(double opacity) {
    assert(opacity != null);
    assert(opacity >= 0.0 && opacity <= 1.0);
    _opacity = opacity;
  }

  /// 要在精灵上方绘制的颜色，如果不使用颜色覆盖，则为null
  /// ```dart
  /// // 将精灵变红
  /// mySprite.colorOverlay = new Color(0x77ff0000);
  /// ```
  Color colorOverlay;

  /// 将精灵绘制到屏幕时使用的混合模式
  /// ```dart
  /// // 将精灵的颜色与背景颜色相加
  /// mySprite.transferMode = BlendMode.plus;
  /// ```
  BlendMode transferMode;

  void _updatePaint(Paint paint) {
    paint.color = new Color.fromARGB((255.0 * _opacity).toInt(), 255, 255, 255);

    if (colorOverlay != null) {
      paint.colorFilter = new ColorFilter.mode(colorOverlay, BlendMode.srcATop);
    }

    if (transferMode != null) {
      paint.blendMode = transferMode;
    }
  }
}
