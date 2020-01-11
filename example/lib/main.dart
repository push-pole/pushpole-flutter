import 'pushpole_sample.dart';
import 'package:flutter/material.dart';

void main() => runApp(PushPoleSampleApp());

class PushPoleSampleApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PushPole sample',
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
      ),
      home: PushPoleSampleWidget()
    );
  }
}
