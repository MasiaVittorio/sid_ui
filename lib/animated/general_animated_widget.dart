import 'package:flutter/material.dart';


class AnimatedDouble extends ImplicitlyAnimatedWidget {
  AnimatedDouble({
    @required this.value,
    this.builder,
    Curve curve,
    @required Duration duration,
  })  : assert(value != null),
        super(
          curve: curve ?? Curves.linear, 
          duration: duration ?? const Duration(milliseconds: 200)
        );

  final double value;
  final Widget Function(BuildContext, double) builder;
  @override
  _DivisionAnimateState createState() => _DivisionAnimateState();
}

class _DivisionAnimateState extends AnimatedWidgetBaseState<AnimatedDouble> {
  Tween<double> _double;

  @override 
  void forEachTween(TweenVisitor<dynamic> visitor) {
    _double = visitor(
      _double, 
      widget.value,
      (dynamic value) 
        => Tween<double>(begin: value)
    );
  }

  @override
  Widget build(BuildContext context) {
    final val = _double.evaluate(animation);

    return widget.builder(context, val);
  }
}
