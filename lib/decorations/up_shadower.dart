import 'package:flutter/material.dart';

class UpShadower extends StatelessWidget{

  final Widget child;
  final Color? materyalBodyColor;
  UpShadower({
    required this.child,
    this.materyalBodyColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(boxShadow: <BoxShadow>[
        BoxShadow(
          color: Color(0x6F000000),
          spreadRadius: 0.0,
          blurRadius: 5.8,
          offset: Offset(0,2),
        )
      ]),
      child: Material(
        color: this.materyalBodyColor,
        child: this.child,
      ),
    );
  }
}