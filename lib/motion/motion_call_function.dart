part of askr;

typedef void MotionCallback();

/// 在 [Motion] 里执行方法
class MotionCallFunction extends MotionInstant {
  MotionCallback _function;

  ///```dart
  /// var myMotion = new MotionCallFunction(() { ... });
  ///```
  MotionCallFunction(this._function);

  @override
  void fire() {
    _function();
  }
}
