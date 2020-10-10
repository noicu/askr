part of askr;

/// A sprite sheet packs a number of smaller images into a single large image.
///
/// The placement of the smaller images are defined by a json file. The larger image and json file is typically created
/// by a tool such as TexturePacker. The [SpriteSheet] class will take a reference to a larger image and a json string.
/// From the image and the string the [SpriteSheet] creates a number of [SpriteTexture] objects. The names of the frames in
/// the sprite sheet definition are used to reference the different textures.
class SpriteSheet {
  ui.Image _image;
  Map<String, SpriteTexture> _textures = new Map<String, SpriteTexture>();
  Map<String, SpriteTexture> get textures => _textures;

  List<String> _fileNames = new List<String>();
  List<String> get fileNames => _fileNames;

  /// Creates a new sprite sheet from an [_image] and a sprite sheet [jsonDefinition].
  ///
  ///     var mySpriteSheet = new SpriteSheet(myImage, jsonString);
  SpriteSheet(this._image, String jsonDefinition) {
    assert(_image != null);
    assert(jsonDefinition != null);

    JsonDecoder decoder = new JsonDecoder();
    Map<dynamic, dynamic> file = decoder.convert(jsonDefinition);
    assert(file != null);

    List<dynamic> frames = file["frames"];

    for (Map<dynamic, dynamic> frameInfo in frames) {
      String fileName = frameInfo["filename"];
      Rect frame = _readJsonRect(frameInfo["frame"]);
      bool rotated = frameInfo["rotated"];
      bool trimmed = frameInfo["trimmed"];
      Rect spriteSourceSize = _readJsonRect(frameInfo["spriteSourceSize"]);
      Size sourceSize = _readJsonSize(frameInfo["sourceSize"]);
      Offset pivot = _readJsonPoint(frameInfo["pivot"]);

      SpriteTexture texture = new SpriteTexture._fromSpriteFrame(
        _image,
        fileName,
        sourceSize,
        rotated,
        trimmed,
        frame,
        spriteSourceSize,
        pivot,
      );
      _textures[fileName] = texture;
      _fileNames.add(fileName);
    }
  }

  /// 创建帧动画精灵
  FrameSprite frameSprite(
    IndexModel indexModel, {
    double speed,
    int startFrame,
  }) {
    return FrameSprite(
      this,
      indexModel,
      speed: speed,
      startFrame: startFrame,
    );
  }

  Rect _readJsonRect(Map<dynamic, dynamic> data) {
    num x = data["x"];
    num y = data["y"];
    num w = data["w"];
    num h = data["h"];

    return new Rect.fromLTRB(
        x.toDouble(), y.toDouble(), (x + w).toDouble(), (y + h).toDouble());
  }

  Size _readJsonSize(Map<dynamic, dynamic> data) {
    num w = data["w"];
    num h = data["h"];

    return new Size(w.toDouble(), h.toDouble());
  }

  Offset _readJsonPoint(Map<dynamic, dynamic> data) {
    num x = data["x"];
    num y = data["y"];

    return new Offset(x.toDouble(), y.toDouble());
  }

  /// The image used by the sprite sheet.
  ///
  ///     var spriteSheetImage = mySpriteSheet.image;
  ui.Image get image => _image;

  /// Returns a texture by its name.
  ///
  ///     var myTexture = mySpriteSheet["example.png"];
  ///     var myTexture1 = mySpriteSheet[0];
  SpriteTexture operator [](dynamic fileName) =>
      fileName is int ? _textures[_fileNames[fileName]] : _textures[fileName];
}
