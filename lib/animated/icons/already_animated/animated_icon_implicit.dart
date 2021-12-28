import 'package:flutter/material.dart';

//only one animated icon, different from animated switching icon that accepts a forward animated icon and a backward one

class ImplicitlyAnimatedIcon extends ImplicitlyAnimatedWidget {
  ImplicitlyAnimatedIcon({
    required this.icon,
    required this.progress,
    this.color,
    this.size,
    Curve? curve,
    required Duration duration,
  }): super(
    curve: curve ?? Curves.linear, 
    duration: duration,
  );

  final AnimatedIconData icon;
  final double progress;
  final Color? color;
  final double? size;
  @override
  _ImplicitlyAnimatedIconState createState() => _ImplicitlyAnimatedIconState();
}

class _ImplicitlyAnimatedIconState extends AnimatedWidgetBaseState<ImplicitlyAnimatedIcon> {

  Tween<double>? _tween;

  @override
  void forEachTween(TweenVisitor<dynamic> visitor) {
    _tween = visitor(
      _tween, 
      widget.progress,
      (dynamic value) 
        => Tween<double>(begin: value)
    ) as Tween<double>;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedIcon(
      progress: AlwaysStoppedAnimation<double>(this._tween!.evaluate(animation)),
      icon: widget.icon,
      color: widget.color,
      size: widget.size,
    );
  }
}
