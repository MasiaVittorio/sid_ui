import 'package:flutter/material.dart';


class AnimatedScale extends ImplicitlyAnimatedWidget {
  AnimatedScale({
    required this.scale,
    this.child,
    Curve? curve,
    required Duration duration,
    this.alsoAlign = false,
  }): super(
    curve: curve ?? Curves.linear, 
    duration: duration
  );

  final double scale;
  final Widget? child;
  final bool alsoAlign;
  @override
  _DivisionAnimateState createState() => _DivisionAnimateState();
}

class _DivisionAnimateState extends AnimatedWidgetBaseState<AnimatedScale> {
  Tween<double?>? _scale;

  @override 
  void forEachTween(TweenVisitor<dynamic> visitor) {
    _scale = visitor(
      _scale, 
      widget.scale,
      (dynamic value) 
        => Tween<double>(begin: value)
    ) as Tween<double?>?;
  }

  @override
  Widget build(BuildContext context) {
    final val = _scale!.evaluate(animation)!;
    final result = Transform.scale(
      child: widget.child,
      scale: val,
      alignment: Alignment.center,
    );
    if(widget.alsoAlign == true)
      return Align(
        heightFactor: val,
        widthFactor: val,
        alignment: Alignment.center,
        child: result,
      );
    
    return result;
  }
}
