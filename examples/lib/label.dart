import 'package:askr/askr.dart';
import 'package:flutter/material.dart';

class LabelPage extends StatefulWidget {
  LabelPage({Key key}) : super(key: key);

  @override
  _LabelPageState createState() => _LabelPageState();
}

class _LabelPageState extends State<LabelPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Label Page'),
      ),
      body: Container(
        // width: 100,
        height: 400,
        decoration: new BoxDecoration(color: Colors.grey[800]),
        child: new Askr(
          _RootNode(),
          SpriteBoxTransformMode.scaleToFit,
        ),
      ),
    );
  }
}

class _RootNode extends NodeWithSize {
  _RootNode() : super(Size(100, 100)) {
    var name = Label(
      'Label',
      textStyle: TextStyle(
        color: Colors.yellow,
      ),
      textAlign: TextAlign.left,
    );
    name.position = size.center(Offset.zero);
    addChild(name);
  }

  @override
  void paint(Canvas canvas) {
    Paint _paint = new Paint()..color = Color(0xFF2BFF00);
    canvas.drawLine(
      Offset(0, size.height / 2),
      Offset(size.width, size.height / 2),
      _paint,
    );
    canvas.drawLine(
      Offset(size.width / 2, 0),
      Offset(size.width / 2, size.height),
      _paint,
    );
    super.paint(canvas);
  }
}
