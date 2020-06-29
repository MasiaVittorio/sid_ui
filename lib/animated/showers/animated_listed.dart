import 'package:flutter/material.dart';
import 'package:sid_utils/sid_utils.dart';

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
          curve: curve ?? Curves.ease, 
          duration: duration ?? const Duration(milliseconds: 250)
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

    final double maxSizeVal = 1/2 + overlap/2;

    final double sizeFactor = val.mapToRange(0, 1, fromMin: 0.0, fromMax: maxSizeVal);

    final double minOpacityVal = 1/2 - overlap/2;

    final double opacity = val.mapToRange(0.0, 1.0, fromMin: minOpacityVal, fromMax: 1.0);


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
