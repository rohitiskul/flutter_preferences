import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_preferences/flutter_preferences.dart';

void main() async {  
  WidgetsFlutterBinding.ensureInitialized();
  await FlutterPreferenceHelper().init(['Named_Pref']);

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
    clickCount = FlutterPreferenceHelper().named('Named_Pref').getInt('some_int');
    if (clickCount == null) clickCount = 0;
  }

  Future setValueDCC(int value) async {
    var prefs = FlutterPreferenceHelper().named('Named_Pref');
    prefs.setInt('some_int', value);
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
            Text('Get Value from Named_Pref: $clickCount'),
            Text(
                'Get Value default: ${FlutterPreferenceHelper().getDefault().getString('name')}'),
            RaisedButton(
              onPressed: () {
                clickCount++;
                setValueDCC(clickCount);
                setState(() {});
              },
              child: Text('Set Value Named_Pref clicked ${FlutterPreferenceHelper().named('Named_Pref').getInt('some_int')}'),
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
