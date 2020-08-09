import 'package:flutter/material.dart';
import 'dart:math' as math;

class SplashingColoredBackground extends StatefulWidget {

  SplashingColoredBackground(this.color, {
    this.alignment = Alignment.center,
    this.child,
    this.curve,
    this.duration = const Duration(milliseconds: 360),
  });

  final Color color;
  final Curve curve;
  final Alignment alignment;
  final Duration duration;
  final Widget child;


  @override
  _SplashingColoredBackgroundState createState() => _SplashingColoredBackgroundState();
}

class _SplashingColoredBackgroundState extends State<SplashingColoredBackground> with TickerProviderStateMixin {
  Color _color;
  Color _circleColor;

  AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _color = widget.color;
    _circleColor = widget.color;

    _resetController();
  }

  void _resetController(){
    _controller?.dispose();

    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _pushCircle() {
    if (widget.color != null) {
      _color = _circleColor;
      _controller.value = 0.0;
      _circleColor = widget.color;
      _controller.animateTo(
        1.0, 
        curve: widget.curve ?? Curves.linear
      ).then((_){
        this.setState((){
          _color = _circleColor;
        });
      });
    }
  }

  @override
  void didUpdateWidget(SplashingColoredBackground oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_circleColor != widget.color) {
      _pushCircle();
    } 
    if(widget.duration != _controller.duration){
      _resetController();
    }
  }


  @override
  Widget build(BuildContext context) {
    return Container(
      color: _color,
      child: AnimatedBuilder(
        animation: _controller,
        child: widget.child ?? Container(),
        builder: (context, child) => CustomPaint(
          painter: _RadialPainter(
            alignment: widget.alignment,
            color: _circleColor,
            value: Curves.easeOut.transform(_controller.value),
          ),
          child: child,
        ),
      ),
    );
  }
}




// Paints the animating color splash circles.
class _RadialPainter extends CustomPainter {
  _RadialPainter({
    @required this.color,
    @required this.value,
    @required this.alignment,
  }) : assert(color != null),
       assert(value != null),
       assert(alignment != null);

  final Color color;
  final double value;
  final Alignment alignment;


  // Computes the maximum radius attainable such that at least one of the
  // bounding rectangle's corners touches the edge of the circle. Drawing a
  // circle larger than this radius is not needed, since there is no perceivable
  // difference within the cropped rectangle.
  static double _maxRadius(Offset center, Size size) {
    final double maxX = math.max(center.dx, size.width - center.dx);
    final double maxY = math.max(center.dy, size.height - center.dy);
    return math.sqrt(maxX * maxX + maxY * maxY)*1.1;
  }

  @override
  bool shouldRepaint(_RadialPainter oldPainter) {
    if (color != oldPainter.color)
      return true;
    
    if (alignment != oldPainter.alignment)
      return true;

    if(value != oldPainter.value) 
      return true;

    return false;
  }

  @override
  void paint(Canvas canvas, Size size) {

    final Rect rect = Rect.fromLTWH(0.0, 0.0, size.width, size.height);
    Paint paint = Paint()..color = color;

    canvas.clipRect(rect);

    final Offset center = Offset(
      (size.width / 2) * (1 + alignment.x), 
      (size.height / 2) * (1 + alignment.y),
    );

    final Tween<double> radiusTween = Tween<double>(
      begin: 0.0,
      end: _maxRadius(center, size),
    );
    canvas.drawCircle(
      center,
      radiusTween.transform(value),
      paint,
    );
  }
}


