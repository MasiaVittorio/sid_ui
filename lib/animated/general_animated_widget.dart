import 'package:flutter/material.dart';

class AnimatedDouble extends ImplicitlyAnimatedWidget {
  AnimatedDouble({
    required this.value,
    required this.builder,
    super.curve = Curves.ease,
    super.duration = const Duration(milliseconds: 250),
    this.animate = true, 
  });

  final double value;
  final bool animate;
  final Widget Function(BuildContext context, double) builder;
  @override
  _DivisionAnimateState createState() => _DivisionAnimateState();
}

class _DivisionAnimateState extends AnimatedWidgetBaseState<AnimatedDouble> {
  Tween<double>? _double;

  @override
  void forEachTween(TweenVisitor<dynamic> visitor) {
    _double = visitor(
      _double,
      widget.value,
      (dynamic value) => Tween<double>(begin: widget.animate ? widget.value : value),
    ) as Tween<double>;
  }

  @override
  Widget build(BuildContext context) {
    final val = _double!.evaluate(animation);

    return widget.builder(context, val);
  }
}
