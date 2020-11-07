import 'dart:io';

import 'package:device_info/device_info.dart';
import 'package:examples/label.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(MyApp());
}

cli() async {
  try {
    var clipboardData =
        await Clipboard.getData(Clipboard.kTextPlain); //获取粘贴板中的文本
    if (clipboardData != null) {
      print(clipboardData.text); //打印内容
    }
  } catch (e) {
    print(e);
  }
}

void getDeviceInfo() async {
  DeviceInfoPlugin deviceInfo = new DeviceInfoPlugin();
  if (Platform.isIOS) {
    IosDeviceInfo iosDeviceInfo = await deviceInfo.iosInfo;
    print(iosDeviceInfo);
  } else if (Platform.isAndroid) {
    AndroidDeviceInfo androidDeviceInfo = await deviceInfo.androidInfo;
    print(androidDeviceInfo.model);
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Askr Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: "/",
      routes: {
        "/": (context) => MyHomePage(),
        '/label': (context) => LabelPage(),
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key}) : super(key: key);
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    super.initState();
    cli();
    getDeviceInfo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Askr Demo List'),
      ),
      body: ListView(
        children: <Widget>[
          ListTile(
            leading: Icon(Icons.map),
            title: Text('Label'),
            onTap: () {
              Navigator.pushNamed(context, "/label");
            },
          ),
        ],
      ),
    );
  }
}
