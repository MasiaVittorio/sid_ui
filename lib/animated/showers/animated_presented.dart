import 'package:flutter/material.dart';
import 'package:sid_utils/sid_utils.dart';

enum PresentMode {scale,slide,}

class AnimatedPresented extends ImplicitlyAnimatedWidget {
  AnimatedPresented({
    required this.presented,
    this.child,
    this.offScale = 0.8,
    Curve? curve,
    required Duration duration,
    this.presentMode = PresentMode.scale,
    this.slideOffset = const Offset(0,200),
    this.fadeFirstFraction = 0.0,
  }) : super(
    curve: curve ?? Curves.linear, 
    duration: duration,
  );

  final double offScale;
  final bool presented;
  final Widget? child;
  final PresentMode presentMode;
  final Offset slideOffset;

  /// 1.0: the child has completely faded out at 50% of the animation 
  /// (cannot be seen along other simililarly animated children)
  /// 0.0: the child has fades out during the whole animation 
  /// (shares the visibility with any other children fading in-out the same way)
  final double fadeFirstFraction;  

  @override
  _DivisionAnimateState createState() => _DivisionAnimateState();
}

class _DivisionAnimateState extends AnimatedWidgetBaseState<AnimatedPresented> {
  Tween<double?>? _presented;

  @override
  void forEachTween(TweenVisitor<dynamic> visitor) {
    _presented = visitor(
      _presented, 
      widget.presented ? 1.0 : 0.0,
      (dynamic value) 
        => Tween<double>(begin: value)
    ) as Tween<double?>?;
  }

  @override
  Widget build(BuildContext context) {
    final double? _val = _presented!.evaluate(animation);
    return IgnorePointer(
      ignoring: !widget.presented,
      child: widget.presentMode == PresentMode.scale ? 
        Transform.scale(
          scale: _val!.mapToRange(widget.offScale, 1.0),
          alignment: Alignment.center,
          child: Opacity(
            opacity: _val,
            child: widget.child
          ),
        )
        : Transform.translate(
          offset: Offset(
            Curves.easeInOut.transform(_val!).mapToRange(widget.slideOffset.dx, 0.0),
            Curves.easeInOut.transform(_val).mapToRange(widget.slideOffset.dy, 0.0),
          ),
          child: Opacity(
            opacity: _val.mapToRange(
              0.0, 
              1.0, 
              fromMin: widget.fadeFirstFraction.mapToRange(0.0, 0.5), 
              fromMax: 1.0,
            ),
            child: widget.child,
          ),
        ),
    );
  }
}


