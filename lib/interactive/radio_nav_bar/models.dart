import 'package:flutter/material.dart';

class RadioNavBarItem {
  final Color? color;
  final String title;
  final IconData icon;
  final IconData? unselectedIcon;
  final double? iconSize;

  const RadioNavBarItem({
    required this.title,
    required this.icon,
    this.unselectedIcon,
    this.color,
    this.iconSize,
  });
  
  //true if all colored, false if all non colored, null if mixed
  static bool? allColoredItems(Iterable<RadioNavBarItem> items){
    bool uncolored = false;
    bool colored = false;
    for(final item in items){
      if(item.color == null){
        uncolored = true;
      } else {
        colored = true;
      }

      if(uncolored && colored){
        return null;
      }
    }
    return colored;
  }
}
