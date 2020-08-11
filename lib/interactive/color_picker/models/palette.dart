
import 'package:flutter/material.dart';

import 'dart:math';


extension _DistanceColor on Color{
  double distance(Color other) => sqrt(
    pow((this.red-other.red),      2)+
    pow((this.green-other.green),  2)+
    pow((this.blue-other.blue),    2)
  );
}

class PaletteTab{

  static Color findClosestMaterialColor(Color color){
    if(color == null) return Colors.red;
    Color closest = Colors.black;
    double minDistance = double.infinity;
    for(final c in PaletteTab.allColors){
      double newDistance = c.distance(color);
      if(newDistance < minDistance){
        minDistance = newDistance;
        closest = c;
      }
    }
    return closest;
  }

  static int findClosestTabIndex(List<PaletteTab> tabs, Color color){
    if(color == null) {
      if(tabs == null || tabs.isEmpty) return null;
      else return 0;
    }
    int index;
    double minDistance = double.infinity;
    for(int i=0; i<tabs.length; ++i){
      for(final c in tabs[i].shades){
        final newDistance = c.distance(color);
        if(newDistance < minDistance){
          minDistance = newDistance;
          index = i;
        }
      }
    }
    return index;
  }

  static final List<PaletteTab> allTabs = [
    PaletteTab(mains: [Colors.red, Colors.redAccent], name: 'Red'), 
    PaletteTab(mains: [Colors.pink, Colors.pinkAccent], name: 'Pink'), 
    PaletteTab(mains: [Colors.purple, Colors.purpleAccent], name: 'Purple'), 
    PaletteTab(mains: [Colors.deepPurple, Colors.deepPurpleAccent], name: 'Deep Purple'), 
    PaletteTab(mains: [Colors.indigo, Colors.indigoAccent], name: 'Indigo Blue'), 
    PaletteTab(mains: [Colors.blue, Colors.blueAccent], name: 'Blue'), 
    PaletteTab(mains: [Colors.lightBlue, Colors.lightBlueAccent], name: 'Light Blue'),
    PaletteTab(mains: [Colors.cyan, Colors.cyanAccent], name: 'Cyan'),
    PaletteTab(mains: [Colors.teal, Colors.tealAccent], name: 'Teal'),
    PaletteTab(mains: [Colors.green, Colors.greenAccent], name: 'Green'),
    PaletteTab(mains: [Colors.lightGreen, Colors.lightGreenAccent], name: 'Light Green'),
    PaletteTab(mains: [Colors.lime, Colors.limeAccent], name: 'Lime'),
    PaletteTab(mains: [Colors.yellow, Colors.yellowAccent], name: 'Yellow'),
    PaletteTab(mains: [Colors.amber, Colors.amberAccent], name: 'Amber'),
    PaletteTab(mains: [Colors.orange, Colors.orangeAccent], name: 'Orange'),
    PaletteTab(mains: [Colors.deepOrange, Colors.deepOrangeAccent], name: 'Deep Orange'),
    PaletteTab(mains: [Colors.brown], name: 'Brown'),
    PaletteTab(mains: [Colors.grey], name: 'Grey'),
    PaletteTab(mains: [Colors.blueGrey], name: 'Blue Grey'),
    PaletteTab(mains: [Colors.black, Colors.white], name: 'B&W'),
  ];

  static final  List<Color> allColors = <Color>[
    for(final x in allTabs) ...x.shades,
  ];

  PaletteTab({
    @required List<Color> mains,
    @required this.name,
  }): 
    this.colors = <_PaletteColor>[
      for(final c in mains)
        _PaletteColor(mainColor: c),
    ],
    this.shades = <Color>[
      for(final col in mains)
        ..._PaletteColor(mainColor: col).shades,
    ],
    assert(mains != null && mains.length>0);

  final List<_PaletteColor> colors;
  final String name;
  final List<Color> shades;

  Color get defaultColor => this.colors[0].defaultColor;

  int get defaultIndex => this.colors[0].defaultIndex;
}

class _PaletteColor{

  static const List<int> _greyShades 
    = <int>[50, 100, 200, 300, 350, 400, 500, 600, 700, 800, 850, 900];
  static const List<int> _materialShades 
    = <int>[50, 100, 200, 300, 400, 500, 600, 700, 800, 900];
  static const List<int> _accentShades 
    = <int>[100, 200, 400, 700];

  _PaletteColor({
    @required this.mainColor,
  }): shades = <Color>[
    if(mainColor == Colors.grey)
      for(final s in _greyShades) Colors.grey[s]

    else if(mainColor == Colors.black || mainColor == Colors.white)
      mainColor

    else if(mainColor is MaterialAccentColor)
      for(final s in _accentShades) mainColor[s]

    else if(mainColor is MaterialColor)
      for(final s in _materialShades) mainColor[s]

    else Colors.black,
  ],
  defaultIndex = mainColor == Colors.grey ? 6
    : mainColor == Colors.black || mainColor == Colors.white ? 0
    : mainColor is MaterialAccentColor ? 1
    : mainColor is MaterialColor ? 5
    : 0 ;

  final Color mainColor;
  final List<Color> shades;
  final int defaultIndex;
  
  Color get defaultColor => shades[defaultIndex];

}



