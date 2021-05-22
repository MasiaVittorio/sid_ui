import 'package:flutter/material.dart';
import 'dart:math' as math;


class AnimatedClipper extends StatefulWidget {
  final bool clip;
  final Duration duration;
  final Widget child;
  final Axis axis;
  final double axisAlignment;
  final Alignment childAlignment;
  final Curve curve;
  final bool alsoFade;

  AnimatedClipper({
    Key? key,
    required this.clip,
    required this.child,
    this.alsoFade = false,
    this.axis = Axis.horizontal,
    this.childAlignment = Alignment.center,
    this.axisAlignment = 0.0,
    required this.duration,
    this.curve = Curves.easeIn
  });

  @override
  State createState() => _AnimatedClipperState();
}


class _AnimatedClipperState extends State<AnimatedClipper> with TickerProviderStateMixin {

  late AnimationController _controller;
  bool? _bool;

  @override
  void initState(){
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this
    );
    _bool = widget.clip;
    this.go();
    super.initState();
  }

  void go(){
    if(_bool!)
      _controller.animateTo(0.0, curve: widget.curve);
    else
      _controller.animateTo(1.0, curve: widget.curve);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(AnimatedClipper oldWidget) {
    if(widget.clip != _bool){
      this._bool = widget.clip;
      this.go();      
    }

    if(_controller.duration != widget.duration){
      final _valReset = _controller.value;
      _controller.dispose();
      _controller = AnimationController(
        duration: widget.duration,
        vsync: this,
        value: _valReset,
      );
    }

    super.didUpdateWidget(oldWidget);
  }
  
  @override  
  Widget build(BuildContext context) {
    return Container(
      child: FadeAndSizeTransition(
        axisAlignment: widget.axisAlignment,
        axis: widget.axis,
        sizeFactor: _controller,
        alsoFade: widget.alsoFade,
        child: Align(
          alignment: widget.childAlignment, 
          child: widget.child
        ),
      ),
    );
  }

}



class FadeAndSizeTransition extends AnimatedWidget {

  const FadeAndSizeTransition({
    Key? key,
    this.axis = Axis.vertical,
    required Animation<double> sizeFactor,
    this.axisAlignment = 0.0,
    this.child,
    this.alsoFade = true,
  }) : super(key: key, listenable: sizeFactor);

  final Axis axis;

  final bool alsoFade;

  Animation<double> get sizeFactor => listenable as Animation<double>;

  final double axisAlignment;

  /// The widget below this widget in the tree.
  ///
  /// {@macro flutter.widgets.child}
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    AlignmentDirectional alignment;
    if (axis == Axis.vertical)
      alignment = AlignmentDirectional(-1.0, axisAlignment);
    else
      alignment = AlignmentDirectional(axisAlignment, -1.0);
    return ClipRect(
      child: Align(
        alignment: alignment,
        heightFactor: axis == Axis.vertical ? math.max(sizeFactor.value, 0.0) : null,
        widthFactor: axis == Axis.horizontal ? math.max(sizeFactor.value, 0.0) : null,
        child: alsoFade
          ? Opacity(opacity: sizeFactor.value, child: child)
          : child,
      ),
    );
  }
}


