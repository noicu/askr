// http://melonjs.github.io/melonJS/docs/me.Sprite.html
library askr;

import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui show Image, Vertices, PointMode;

import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
// import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';
import 'package:vector_math/vector_math_64.dart';

part 'debug.dart';

part 'motion/motion.dart';
part 'motion/motion_spline.dart';
part 'motion/motion_instant.dart';
part 'motion/motion_interval.dart';
part 'motion/motion_repeat.dart';
part 'motion/motion_sequence.dart';
part 'motion/motion_tween.dart';
part 'motion/motion_remove_node.dart';
part 'motion/motion_repeat_forever.dart';
part 'motion/motion_group.dart';
part 'motion/motion_delay.dart';
part 'motion/motion_controller.dart';
part 'motion/motion_call_function.dart';

part 'constraint/constraint.dart';

part 'nodes/effect_line.dart';
part 'nodes/label.dart';
part 'nodes/layer.dart';
part 'nodes/nine_slice_sprite.dart';
part 'nodes/node.dart';
part 'nodes/node3d.dart';
part 'nodes/icon_node.dart';
part 'nodes/node_with_size.dart';
part 'nodes/particle_system.dart';
part 'nodes/sprite.dart';
part 'nodes/frame_sprite.dart';
part 'nodes/virtual_joystick.dart';
part 'nodes/textured_line.dart';

part 'supply/color_sequence.dart';
part 'supply/image_map.dart';
part 'supply/sprite_box.dart';
part 'supply/spritesheet.dart';
part 'supply/sprite_texture.dart';
part 'util/random.dart';
part 'util/game_math.dart';

/// 使用 [SpriteBox] 将精灵节点树渲染到屏幕的组件。
class Askr extends SingleChildRenderObjectWidget {
  /// 精灵节点树的rootNode。
  /// ```dart
  /// var node = myaskr.rootNode;
  /// ```
  final NodeWithSize rootNode;

  /// 变换方式，使子节点树匹配窗口小部件的尺寸
  final SpriteBoxTransformMode transformMode;

  /// 组件窗口使用 [rootNode] 的尺寸结合 [transformMode] 为节点树设置坐标空间
  ///
  /// 默认使用 [SpriteBoxTransformMode.letterbox] 变换模式
  ///
  /// 将设置精灵节点的常用类 [NodeWithSize] 传递给 [askr]
  ///
  /// 在自定义子类中，可以构建节点图，制作动画和处理用户事件
  /// ```dart
  /// var mySpriteTree = new MyCustomNodeWithSize();
  /// var myaskrWidget = new askr(mySpriteTree, SpriteBoxTransformMode.fixedHeight);
  /// ```
  Askr(this.rootNode, [this.transformMode = SpriteBoxTransformMode.letterbox]);

  @override
  SpriteBox createRenderObject(BuildContext context) =>
      new SpriteBox(rootNode, transformMode);

  @override
  void updateRenderObject(BuildContext context, SpriteBox renderObject) {
    renderObject
      ..rootNode = rootNode
      ..transformMode = transformMode;
  }
}
