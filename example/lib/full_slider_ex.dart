import 'package:flutter/material.dart';
import 'package:sid_ui/sid_ui.dart';

class StateFulPart extends StatefulWidget {
  @override
  _StateFulPartState createState() => _StateFulPartState();
}

class _StateFulPartState extends State<StateFulPart> {

  double value = 17.0;

  double value2 = 50;

  String get s2 => value2.toStringAsFixed(2);
  String get s1 => value.toStringAsFixed(2);

  @override
  Widget build(BuildContext _) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text("Slider example"),),
        body: Material(
          type: MaterialType.canvas,
          color: Colors.white,
          child: Column(children: <Widget>[
            ListTile(title: Text("value 1: $s1"),),
            ListTile(title: Text("value 2: $s2"),),
            FullSlider(
              tapToEditBy: 1,
              scrollDirection: Axis.horizontal,
              value: value,
              onChanged: (newValue) => setState((){
                value = newValue;
              }),
              leading: Icon(Icons.close),
              radius: 56/2,
              title: Text("title 1"),
              trailing: Icon(Icons.check),
              min: 15,
              max: 30,
            ),
            FullSlider(
              defaultValue: 20,
              value: value2,
              tapToEditBy: 10,
              divisions: 20,
              titleBuilder: (v) => Text("val: ${v.toStringAsFixed(2)}"),
              leading: Icon(Icons.ac_unit),
              onChangeEnd: (newValue) => setState((){
                value2 = newValue;
              }),
              min: 0,
              max: 100,
            ),
          ],),
        ),
      ),
    );
  }
}