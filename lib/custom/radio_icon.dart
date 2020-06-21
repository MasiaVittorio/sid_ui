import 'package:flutter/material.dart';
import 'dart:math';


class RadioIcon extends ImplicitlyAnimatedWidget {
  final bool value;
  final Color activeColor;
  final Color inactiveColor;
  final IconData inactiveIcon;
  final IconData activeIcon;
  final Duration duration;
  final double size;
  final EdgeInsets padding;

  RadioIcon({
    Key key,
    @required this.value,
    @required this.activeColor,
    this.inactiveColor,
    this.size = 24.0,
    @required this.activeIcon,
    @required this.inactiveIcon,
    this.padding = const EdgeInsets.all(12),
    this.duration = const Duration(milliseconds: 200),
    Curve curve = Curves.easeIn
  }) : super(duration: duration, curve: curve, key: key);

  @override
  ImplicitlyAnimatedWidgetState<ImplicitlyAnimatedWidget> createState() => _RadioIconState();
}

class _RadioIconState extends AnimatedWidgetBaseState<RadioIcon> {
  Tween<double> _count;
  
  @override  
  Widget build(BuildContext context) {
    double ev = _count.evaluate(animation);
    return IconTheme.merge(
      data: IconThemeData(opacity: 1.0),
      child: Padding(
        padding: widget.padding,
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            Transform.scale(
              scale: 1.0 - ev*0.1,
              child: Icon(
                widget.inactiveIcon,
                color: widget.inactiveColor,
                size: widget.size,
              ),
            ),
            ClipOval(
              child: Icon(
                widget.activeIcon,
                color: widget.activeColor,
                size: widget.size,
              ),
              clipper: _CircleClipper(
                center: Offset(widget.size / 2, widget.size / 2),
                radius: ev*widget.size*sqrt(2)/2
              )
            ),
          ],
        ),
      ),
    );
  }

  @override
  void forEachTween(TweenVisitor visitor) {
    _count = visitor(_count, widget.value ? 1.0 : 0.0, (dynamic value) => new Tween<double>(begin: value));
  }
}

class _CircleClipper extends CustomClipper<Rect> {
  _CircleClipper({this.center, this.radius});

  final Offset center;
  final double radius;

  @override
  Rect getClip(Size size) {
    var rect = Rect.fromCircle(radius: radius, center: center);

    return rect;
  }

  @override
  bool shouldReclip(CustomClipper<Rect> oldClipper) => true;
}
