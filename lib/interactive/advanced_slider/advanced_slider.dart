import 'package:flutter/material.dart';

export 'thumb_custom.dart';
export 'track_custom.dart';

import 'dart:math' as math;

class AdvancedSlider extends StatelessWidget {

  final void Function()? onMinus;
  final void Function()? onPlus;
  final void Function(double) onChanged;
  final String name;
  final double value;
  final String annotation;
  final Color? activeColor;
  final Color? inactiveColor;
  final double max;
  final double min;

  final TextStyle? nameStyle; 
  final TextStyle? annotationStyle; 
  
  final double height;

  final double? buttonDivision;

  final bool vertical;
  
  AdvancedSlider({
    this.vertical = false,
    required this.onChanged ,
    this.onMinus ,
    this.onPlus ,
    required this.value ,
    required this.name ,
    this.buttonDivision,
    this.annotation = "",
    this.activeColor ,
    this.inactiveColor ,
    required this.max ,
    required this.min ,
    this.nameStyle,
    this.annotationStyle,
    this.height = 64,
  });
  
  @override
  Widget build(BuildContext context) {
    return Container(
      height: this.height,
      padding: const EdgeInsets.only(top:8.0),
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: <Widget>[
          Align(
            alignment: Alignment.topCenter,
            child: Text(
              '$name',
              style: this.nameStyle ?? TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
          Positioned(
            right: 24,
            top: 0,
            child: Text(
              '$annotation',
              style: this.annotationStyle != null 
                ? this.annotationStyle
                : this.nameStyle != null 
                  ? this.nameStyle!.copyWith(color: this.nameStyle!.color!.withOpacity(0.5))
                  : TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).textTheme.bodyText2?.color?.withOpacity(0.5)  
                  ),
            ),
          ),
          Row(
            children: <Widget>[
              IconButton(
                icon: Icon(Icons.remove),
                onPressed: onMinus ?? () {
                  if(this.buttonDivision != null){
                    this.onChanged(
                      math.max(this.value - this.buttonDivision!, this.min)
                    );
                  }
                },
              ),
              Expanded(
                child: Slider(
                  
                  value: value,
                  activeColor: activeColor,
                  inactiveColor: inactiveColor,
                  onChanged: onChanged,
                  min: min,
                  max: max,
                ),
              ),
              IconButton(
                icon: Icon(Icons.add),
                onPressed: onPlus ?? () {
                  if(this.buttonDivision != null){
                    this.onChanged(
                      math.min(this.value + this.buttonDivision!, this.max)
                    );
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}