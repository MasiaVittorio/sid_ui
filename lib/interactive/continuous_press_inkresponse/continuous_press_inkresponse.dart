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

  final void Function(int ticks) whileLongPress;
  final Duration interval;

  final child;
  final bool containedInkWell;

  @override
  _ContinuousPressInkResponseState createState() => _ContinuousPressInkResponseState();
}

class _ContinuousPressInkResponseState extends State<ContinuousPressInkResponse> {
  bool _longPressed = false;
  int _ticks = 0;

  @override
  void dispose() {
    end();
    super.dispose();
  }

  void start() async {
    if (_longPressed == false) _ticks = 0;
    _longPressed = true;
    while (mounted && _longPressed) {
      ++_ticks;
      widget.whileLongPress(_ticks);
      await Future.delayed(widget.interval);
    }
  }

  void end() {
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
