import 'package:flutter/material.dart';


class AnimatedDecoratedBox extends ImplicitlyAnimatedWidget {
  AnimatedDecoratedBox({
    required this.decoration,
    this.child,
    Curve? curve,
    required Duration duration,
  })  : assert(decoration.debugAssertIsValid()),
        super(
          curve: curve ?? Curves.linear, 
          duration: duration,
        );

  final BoxDecoration decoration;
  final Widget? child;
  @override
  _DivisionAnimateState createState() => _DivisionAnimateState();
}

class _DivisionAnimateState extends AnimatedWidgetBaseState<AnimatedDecoratedBox> {
  DecorationTween? _decoration;

  @override
  void forEachTween(TweenVisitor<dynamic> visitor) {
    _decoration = visitor(
      _decoration, 
      widget.decoration,
      (dynamic value) 
        => DecorationTween(begin: value)
    ) as DecorationTween?;
  }

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      child: widget.child,
      decoration: _decoration!.evaluate(animation),
    );
  }
}
