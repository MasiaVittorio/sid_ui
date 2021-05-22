import 'package:flutter/material.dart';
import 'edited_inkresponse.dart';

class ContinuousPressInkResponse extends StatefulWidget {

  ContinuousPressInkResponse({
    this.onTap,
    this.onTapDown,
    required this.whileLongPress,
    required this.interval,
    this.child,
    this.containedInkWell = false,
  });

  final VoidCallback? onTap;
  final void Function(TapDownDetails)? onTapDown;

  final VoidCallback whileLongPress;
  final Duration interval;

  final  child;
  final bool containedInkWell;

  @override
  _ContinuousPressInkResponseState createState() => _ContinuousPressInkResponseState();

}

class _ContinuousPressInkResponseState extends State<ContinuousPressInkResponse> {

  bool _longPressed = false;

  @override
  void dispose() {
    end();
    super.dispose();
  }

  void start() async {
    _longPressed = true;
    while(_longPressed && mounted){
      widget.whileLongPress();
      await Future.delayed(widget.interval);
    }
  }

  void end(){
    _longPressed = false;
  }

  @override
  Widget build(BuildContext context) {
    InkResponse();
    ///the 
    return InkResponseWithLongPressUp(
      child: widget.child,
      onTapDown: widget.onTapDown,
      onTap: widget.onTap,
      onLongPress: start,
      onLongPressUp: end,
      containedInkWell: widget.containedInkWell,
    );
  }

}



