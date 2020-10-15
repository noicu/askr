part of askr;

/// 绘制纹理图像的矩形区域，通常用于在屏幕上绘制精灵
///
/// 可以从 [SpriteSheet] 中获得纹理，但也可以使用 [Image] 创建一个纹理。
class SpriteTexture {
  /// 使用 [Image] 对象创建新纹理。
  /// ```dart
  /// var myTexture = new SpriteTexture(myImage);
  /// ```
  SpriteTexture(ui.Image image)
      : size = new Size(image.width.toDouble(), image.height.toDouble()),
        image = image,
        trimmed = false,
        rotated = false,
        frame = new Rect.fromLTRB(
            0.0, 0.0, image.width.toDouble(), image.height.toDouble()),
        spriteSourceSize = new Rect.fromLTRB(
            0.0, 0.0, image.width.toDouble(), image.height.toDouble()),
        pivot = new Offset(0.5, 0.5);

  SpriteTexture._fromSpriteFrame(this.image, this.name, this.size, this.rotated,
      this.trimmed, this.frame, this.spriteSourceSize, this.pivot);

  /// 此纹理所属的图像
  /// ```dart
  /// var textureImage = myTexture.image;
  /// ```
  final ui.Image image;

  /// 纹理的逻辑大小，然后由纹理打包器修整
  /// ```dart
  /// var textureSize = myTexture.size;
  /// ```
  final Size size;

  /// 图像名称,引用时用作标签
  /// ```dart
  /// myTexture.name = "new_texture_name";
  /// ```
  String name;

  /// 当包装到精灵表中时，将纹理旋转90度
  /// ```dart
  /// if (myTexture.rotated) drawRotated();
  /// ```
  final bool rotated;

  /// 当包装到精灵表中时，对纹理进行修剪。
  /// ```dart
  /// bool trimmed = myTexture.trimmed
  /// ```
  final bool trimmed;

  /// 图像内修剪纹理的框架
  /// ```dart
  /// Rect frame = myTexture.frame;
  /// ```
  final Rect frame;

  /// 图像内修剪纹理的偏移量和大小
  ///
  /// 矩形的尺寸是修剪后纹理的尺寸。
  /// ```dart
  /// Rect spriteSourceSize = myTexture.spriteSourceSize;
  /// ```
  final Rect spriteSourceSize;

  /// 此纹理的默认枢轴点。 从纹理创建 [Sprite] 时要使用的枢轴点
  /// ```dart
  /// myTexture.pivot = new Point(0.5, 0.5);
  /// ```
  /// ![](https://github.com/tovi-cn/askr/blob/master/lib/extra/pivot.png?raw=true)
  Offset pivot;

  /// 从当前纹理的一部分,创建一个新的纹理
  SpriteTexture textureFromRect(Rect rect, [String name]) {
    assert(rect != null);
    assert(!rotated);
    Rect srcFrame = new Rect.fromLTWH(rect.left + frame.left,
        rect.top + frame.top, rect.size.width, rect.size.height);
    Rect dstFrame =
        new Rect.fromLTWH(0.0, 0.0, rect.size.width, rect.size.height);
    return new SpriteTexture._fromSpriteFrame(image, name, rect.size, false,
        false, srcFrame, dstFrame, new Offset(0.5, 0.5));
  }

  /// 在 [position] 使用 [paint] 将纹理绘制到 [Canvas]
  void drawTexture(Canvas canvas, Offset position, Paint paint) {
    // 获取图纸位置
    double x = position.dx;
    double y = position.dy;

    // 绘制纹理
    if (rotated) {
      bool translate = (x != 0 || y != 0);
      if (translate) {
        canvas.translate(x, y);
      }

      // 计算旋转的帧和spriteSourceSize
      Size originalFrameSize = frame.size;
      Rect rotatedFrame = frame.topLeft &
          new Size(originalFrameSize.height, originalFrameSize.width);
      Offset rotatedSpriteSourcePoint = new Offset(
          -spriteSourceSize.top -
              (spriteSourceSize.bottom - spriteSourceSize.top),
          spriteSourceSize.left);
      Rect rotatedSpriteSourceSize = rotatedSpriteSourcePoint &
          new Size(originalFrameSize.height, originalFrameSize.width);

      // 绘制旋转的精灵
      canvas.rotate(-math.pi / 2.0);
      canvas.drawImageRect(image, rotatedFrame, rotatedSpriteSourceSize, paint);
      canvas.rotate(math.pi / 2.0);

      if (translate) {
        canvas.translate(-x, -y);
      }
    } else {
      // 绘制精灵
      Rect dstRect = new Rect.fromLTWH(
          x + spriteSourceSize.left,
          y + spriteSourceSize.top,
          spriteSourceSize.width,
          spriteSourceSize.height);
      canvas.drawImageRect(image, frame, dstRect, paint);
    }
  }
}
