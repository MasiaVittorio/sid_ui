
import 'package:flutter/material.dart';

import 'dart:math';

Color findClosest(Color color){
  Color closest = Colors.black;
  double minDistance = double.infinity;
  for(final c in allMaterialPalette){
    double newDistance = c.distance(color);
    if(newDistance < minDistance){
      minDistance = newDistance;
      closest = c;
    }
  }
  return closest;
}

extension _DistanceColor on Color{
  double distance(Color other) => sqrt(
    pow((this.red-other.red),      2)+
    pow((this.green-other.green),  2)+
    pow((this.blue-other.blue),    2)
  );
}







class ThisDoubleColor{
  ThisDoubleColor({
    @required List<Color> mains,
    @required this.name,
  }): 
    this.colors = mains.map<ThisColor>((Color c) => ThisColor(mainColor: c)).toList(),
    assert(mains != null && mains.length>0);

  final List<ThisColor> colors;
  final String name;

  Color get defaultColor => this.colors[0].defaultColor;

  int get defaultIndex => this.colors[0].defaultIndex;

  List<Color> get shades => this._shades();

  List<Color> _shades(){
    List<Color> ret = <Color>[];
    for(ThisColor tc in this.colors){
      ret.addAll(
        tc.shades
      );
    }
    return ret;
  }

}

class ThisColor{
  ThisColor({
    @required this.mainColor,
  });
  
  final Color mainColor;
 
  List<Color> get shades => this._shades();

  Color get defaultColor => this._default();

  Color _default(){

    if (this.mainColor == Colors.grey) {
      return this.shades[6];
    } else if (this.mainColor == Colors.black || this.mainColor == Colors.white) {
      return this.mainColor;
    } else if (this.mainColor is MaterialAccentColor) {
      return this.shades[1];
    } else if (this.mainColor is MaterialColor) {
      return this.shades[5];
    } else {
      return Colors.black;
    }

  }

  int get defaultIndex => this._defaultIndex();

  int _defaultIndex(){

    if (this.mainColor == Colors.grey) {
      return 6;
    } else if (this.mainColor == Colors.black || this.mainColor == Colors.white) {
      return 0;
    } else if (this.mainColor is MaterialAccentColor) {
      return 1;
    } else if (this.mainColor is MaterialColor) {
      return 5;
    } else {
      return 0;
    }

  }


  List<Color> _shades(){
    List<Color> result = [];

    if (this.mainColor == Colors.grey) {
      result.addAll([
        50,
        100,
        200,
        300,
        350,
        400,
        500,
        600,
        700,
        800,
        850,
        900
      ].map((int shade) {
        return Colors.grey[shade];
      }).toList());
    } else if (this.mainColor == Colors.black || this.mainColor == Colors.white) {
      result.add(this.mainColor);
    } else if (this.mainColor is MaterialAccentColor) {
      MaterialAccentColor mc = this.mainColor;
      result.addAll([100, 200, 400, 700].map<Color>((int shade) {
        return mc[shade];
      }).toList());
    } else if (this.mainColor is MaterialColor) {
      MaterialColor mc = this.mainColor;
      result.addAll(
          [50, 100, 200, 300, 400, 500, 600, 700, 800, 900].map<Color>((int shade) {
        return mc[shade];
      }).toList());
    } else {
      result.add(Color(0));
    }

    return result;
  
  }
}

final List<ThisDoubleColor> materialPalette = [
  ThisDoubleColor(mains: [Colors.red, Colors.redAccent], name: 'Red'), 
  ThisDoubleColor(mains: [Colors.pink, Colors.pinkAccent], name: 'Pink'), 
  ThisDoubleColor(mains: [Colors.purple, Colors.purpleAccent], name: 'Purple'), 
  ThisDoubleColor(mains: [Colors.deepPurple, Colors.deepPurpleAccent], name: 'Deep Purple'), 
  ThisDoubleColor(mains: [Colors.indigo, Colors.indigoAccent], name: 'Indigo Blue'), 
  ThisDoubleColor(mains: [Colors.blue, Colors.blueAccent], name: 'Blue'), 
  ThisDoubleColor(mains: [Colors.lightBlue, Colors.lightBlueAccent], name: 'Light Blue'),
  ThisDoubleColor(mains: [Colors.cyan, Colors.cyanAccent], name: 'Cyan'),
  ThisDoubleColor(mains: [Colors.teal, Colors.tealAccent], name: 'Teal'),
  ThisDoubleColor(mains: [Colors.green, Colors.greenAccent], name: 'Green'),
  ThisDoubleColor(mains: [Colors.lightGreen, Colors.lightGreenAccent], name: 'Light Green'),
  ThisDoubleColor(mains: [Colors.lime, Colors.limeAccent], name: 'Lime'),
  ThisDoubleColor(mains: [Colors.yellow, Colors.yellowAccent], name: 'Yellow'),
  ThisDoubleColor(mains: [Colors.amber, Colors.amberAccent], name: 'Amber'),
  ThisDoubleColor(mains: [Colors.orange, Colors.orangeAccent], name: 'Orange'),
  ThisDoubleColor(mains: [Colors.deepOrange, Colors.deepOrangeAccent], name: 'Deep Orange'),
  ThisDoubleColor(mains: [Colors.brown], name: 'Brown'),
  ThisDoubleColor(mains: [Colors.grey], name: 'Grey'),
  ThisDoubleColor(mains: [Colors.blueGrey], name: 'Blue Grey'),
  ThisDoubleColor(mains: [Colors.black, Colors.white], name: 'B&W'),
];

List<Color> get allMaterialPalette {
  List<Color> result = <Color>[];
  for(final x in materialPalette) result.addAll(x.shades);
  return result;
}


