part of askr;

/// 帧动画精灵
class FrameSprite extends Sprite {
  SpriteSheet spriteSheet;
  int _index = 0;

  int startFrame;

  /// 秒
  double speed;

  bool _stop = false;

  IndexModel indexModel;
  bool reverse;

  /// 创建帧动画精灵
  FrameSprite(
    this.spriteSheet,
    this.indexModel, {
    this.speed = 1.0 / 30,
    this.startFrame = 0,
    this.reverse,
  }) {
    if (indexModel.isAll) indexModel.onAll(spriteSheet);
    if (speed == null || speed == 0) speed = 1.0 / 30;
    this.duration = indexModel.length * speed;
    // _index = startFrame;
    texture = spriteSheet[indexModel[0]];
  }

  void stop() {
    _index = 0;
    _stop = true;
  }

  void pause() {
    _stop = true;
  }

  void play() {
    _stop = false;
  }

  @override
  void paint(Canvas canvas) {
    super.paint(canvas);
  }

  // void _reset() {
  //   _finished = false;
  // }

  // bool _finished = false;

  double duration = 0.0;

  /// 第一次滴答
  bool _firstTick = true;

  /// 流失的时间
  double _elapsed = 0.0;

  // 计算每一帧移动多少个下标
  @override
  void update(dt) {
    if (_firstTick) {
      _firstTick = false;
    } else {
      _elapsed += dt;
    }

    /// 进度 0.0 - 1.0
    double t, f;
    if (this.duration == 0.0) {
      t = 1.0;
      f = 1.0;
    } else {
      t = (_elapsed / duration).clamp(0.0, 1.0);
      f = (_index / (indexModel.length)).clamp(0.0, 1.0);
    }
    texture = spriteSheet[indexModel[_index]];
    if (t >= f + (1 / indexModel.length) && _index < indexModel.length) {
      _index++;
    }

    /// 循环播放
    if (t >= 1.0) {
      _index = 0;
      _elapsed = 0.0;
      _firstTick = true;
      // _finished = true;
    }

    super.update(dt);
  }
}

class IndexModel {
  bool isAll = false;

  List<int> _sequence = new List<int>();
  List<int> get sequence => _sequence;
  set sequence(List<int> arr) {
    assert(arr != null);
    _sequence = arr;
  }

  int get length => _sequence.length;

  IndexModel([List<int> arr]) {
    if (arr != null) {
      sequence = arr;
    } else {
      isAll = true;
    }
  }

  IndexModel.limit(int start, int end) {
    for (var i = start; i <= end; i++) {
      sequence.add(i);
    }
  }

  IndexModel.all() {
    isAll = true;
  }

  onAll(SpriteSheet spriteSheet) {
    for (var i = 0; i < spriteSheet.fileNames.length; i++) {
      sequence.add(i);
    }
  }

  int operator [](int index) => _sequence[index];
}
