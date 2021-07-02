import 'package:flutter/material.dart';
import 'animated_switching_icon.dart';

class ImplicitlySwitchingIcon extends ImplicitlyAnimatedWidget {
  ImplicitlySwitchingIcon({
    required this.firstIcon,
    required this.secondIcon,
    required this.progress,
    this.color,
    this.size,
    this.semanticLabel,
    this.textDirection,
    Curve? curve,
    required Duration duration,
  }): super(
    curve: curve ?? Curves.linear, 
    duration: duration,
  );

  final AnimatedIconData firstIcon;
  final AnimatedIconData secondIcon;
  final double progress;

  final Color? color;
  final double? size;
  final TextDirection? textDirection;
  final String? semanticLabel;

  @override
  _ImplicitlySwitchingIconState createState() => _ImplicitlySwitchingIconState();
}

class _ImplicitlySwitchingIconState extends AnimatedWidgetBaseState<ImplicitlySwitchingIcon> {

  Tween<double>? _tween;

  @override
  void forEachTween(TweenVisitor<dynamic> visitor) {
    _tween = visitor(
      _tween, 
      widget.progress,
      (dynamic value) 
        => Tween<double>(begin: value)
    ) as Tween<double>?;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitchingIcon(
      progress: AlwaysStoppedAnimation<double>(this._tween!.evaluate(animation)),
      firstIcon: widget.firstIcon,
      secondIcon: widget.secondIcon,
      color: widget.color,
      size: widget.size,
      semanticLabel: widget.semanticLabel,
      textDirection: widget.textDirection,
    );
  }
}
