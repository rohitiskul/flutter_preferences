import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_preferences/flutter_preferences.dart';

void main() async {
  await FlutterPreferenceHelper().init(['DCC']);

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int clickCount = 0;

  @override
  void initState() {
    super.initState();
    clickCount = FlutterPreferenceHelper().named('DCC').getInt('clicked');
    if (clickCount == null) clickCount = 0;
  }

  Future setValueDCC(int value) async {
    var prefs = FlutterPreferenceHelper().named('DCC');
    prefs.setInt('clicked', value);
  }

  Future setValueDefault(String pref) async {
    var prefs = FlutterPreferenceHelper().getDefault();
    prefs.setString('name', 'rohit');
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Flutter preferences app'),
        ),
        body: Center(
            child: Column(
          children: <Widget>[
            Text('Get Value DCC: $clickCount'),
            Text(
                'Get Value default: ${FlutterPreferenceHelper().getDefault().getString('name')}'),
            RaisedButton(
              onPressed: () {
                clickCount++;
                setValueDCC(clickCount);
                setState(() {});
              },
              child: Text('Set Value DCC clicked $clickCount'),
            ),
            RaisedButton(
              onPressed: () {
                setValueDefault(null);
                setState(() {});
              },
              child: Text('Set Value Default '),
            )
          ],
        )),
      ),
    );
  }
}
