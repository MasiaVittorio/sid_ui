import 'package:flutter/material.dart';

class StatelessPart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text("Slider example"),),
        body: Material(child: Center(child: StateFulPart()),),
      ),
    );
  }
}

class StateFulPart extends StatefulWidget {
  @override
  _StateFulPartState createState() => _StateFulPartState();
}

class _StateFulPartState extends State<StateFulPart> {

  bool longPressed = false;

  @override
  Widget build(BuildContext _) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GestureDetector(
        onLongPress: () => setState((){
          print("LONG PRESS");
          longPressed = true;
        }),
        onLongPressUp: () => setState((){
          print("LONG UP");
          longPressed = false;
        }),
        onDoubleTap: (){
          print("double tap");
        },
        onLongPressMoveUpdate: (_){},
        onLongPressStart: (_){
          print("long start");
        },
        onLongPressEnd: (_){
          print("long end");
        },
        onPanCancel: (){
          print("pan cancel");
        },
        onPanDown: (_){
          print("pan down");
        },
        onPanEnd: (_){
          print("pan end");
        },
        onPanStart: (_){
          print("pan start");
        },
        onPanUpdate: (_){},
        onTap: (){
          print("tap");
        },
        onTapDown: (_){
          print("tap donw");
        },
        onTapCancel: (){
          print("tap cancel");
        },
        onTapUp: (_){
          print("tap up");
        },


        child: Material(
          elevation: 8,
          color: longPressed ? Colors.red : Colors.white,
          child: SizedBox(width: 200, height: 200,),
        ),
      ),
    );
  }
}