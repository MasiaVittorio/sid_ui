import 'package:flutter/material.dart';

class AnimatedListed extends ImplicitlyAnimatedWidget {
  AnimatedListed({
    @required this.listed,
    Axis axis = Axis.vertical,
    double axisAlignment = -1,
    this.child,
    Curve curve,
    Duration duration = const Duration(milliseconds: 250),
    this.overlapSizeAndOpacity = 0.0,
  })  : assert(listed != null),
        axis = axis ?? Axis.vertical,
        axisAlignment = axisAlignment ?? -1,
        super(
          curve: curve ?? Curves.linear, 
          duration: duration ?? const Duration(milliseconds: 200)
        );

  final double axisAlignment;
  final Axis axis;
  final bool listed;
  final Widget child;
  final double overlapSizeAndOpacity;
  @override
  _DivisionAnimateState createState() => _DivisionAnimateState();
}

class _DivisionAnimateState extends AnimatedWidgetBaseState<AnimatedListed> {
  Tween<double> _tween;

  @override
  void forEachTween(TweenVisitor<dynamic> visitor) {
    _tween = visitor(
      _tween, 
      widget.listed ? 1.0 : 0.0,
      (dynamic value) 
        => Tween<double>(begin: value)
    );
  }

  @override
  Widget build(BuildContext context) {
    final double overlap = widget.overlapSizeAndOpacity.clamp(0.0, 1.0);
    final double val = _tween.evaluate(animation);

    final double minSizeVal = 0.0;
    final double maxSizeVal = 1/2 + overlap/2;
    final double deltaSizeVal = maxSizeVal - minSizeVal;
    final double sizeFactor = ((val - minSizeVal) / deltaSizeVal).clamp(0.0, 1.0);

    final double minOpacityVal = 1/2 - overlap/2;
    final double maxOpacityVal = 1.0;
    final double deltaOpacityVal = maxOpacityVal - minOpacityVal;
    final double opacity = ((val - minOpacityVal) / deltaOpacityVal).clamp(0.0, 1.0);


    return ClipRect(
      child: Align(
        alignment: Alignment(
          widget.axis == Axis.horizontal ? widget.axisAlignment : 0.0,
          widget.axis == Axis.vertical ? widget.axisAlignment : 0.0,
        ),
        widthFactor: widget.axis == Axis.horizontal ? sizeFactor : 1.0,
        heightFactor: widget.axis == Axis.vertical ? sizeFactor : 1.0,
        child: Opacity(
          opacity: opacity,
          child: widget.child
        ),
      ),
    );
  }
}
