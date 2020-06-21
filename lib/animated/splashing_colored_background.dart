import 'package:flutter/material.dart';
import 'dart:math' as math;

class SplashingColoredBackground extends StatefulWidget {

  SplashingColoredBackground(this.color, {
    this.alignment = Alignment.center,
    this.child,
    this.duration = const Duration(milliseconds: 360),
  });

  final Color color;
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
      _controller.forward().then((_){
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
    // this.gradient,
    // this.gradientAxis = Axis.vertical,
    // this.gradientAxisAlignment = -1,
    // this.gradientStrenght = 0.2,
    // this.gradientOpacity = 1.0,
  }) : assert(color != null),
       assert(value != null),
       assert(alignment != null);
      //  assert(!(gradient != null && (
      //    gradientAxis == null ||
      //    gradientAxisAlignment == null ||
      //    gradientStrenght == null
      //  )));

  final Color color;
  final double value;
  final Alignment alignment;

  // final Color gradient;
  // final double gradientStrenght;
  // final double gradientOpacity;
  // final Axis gradientAxis;
  // final double gradientAxisAlignment;

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
    // if(this.gradient != null){
    //   paint = (Paint()..color = color)..shader = prefix0.Gradient.linear(
    //     Alignment(
    //       gradientAxis == Axis.horizontal ? -gradientAxisAlignment : 0,
    //       gradientAxis == Axis.vertical ? -gradientAxisAlignment : 0,
    //     ).withinRect(rect),
    //     Alignment(
    //       gradientAxis == Axis.horizontal ? gradientAxisAlignment : 0,
    //       gradientAxis == Axis.vertical ? gradientAxisAlignment : 0,
    //     ).withinRect(rect),
    //     [
    //       color, 
    //       if(gradientStrenght != 1)
    //         Color.alphaBlend(
    //           gradient.withOpacity(gradientOpacity/2), 
    //           color,
    //         ), 
    //       Color.alphaBlend(
    //         gradient.withOpacity(gradientOpacity), 
    //         color,
    //       ), 
    //     ],
    //     [
    //       0.0, 
    //       if(gradientStrenght != 1)
    //         1-gradientStrenght/2, 
    //       1.0,
    //     ],
    //   );
    // }

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

// LinearGradient _getGradient(Color color,Color gradient, Axis gradientAxis, double gradientOpacity, double gradientStrenght, double gradientAxisAlignment,){
//   return LinearGradient(
//     begin: Alignment(
//       gradientAxis == Axis.horizontal ? -gradientAxisAlignment : 0,
//       gradientAxis == Axis.vertical ? -gradientAxisAlignment : 0,
//     ),
//     end: Alignment(
//       gradientAxis == Axis.horizontal ? gradientAxisAlignment : 0,
//       gradientAxis == Axis.vertical ? gradientAxisAlignment : 0,
//     ),
//     colors: [
//       color, 
//       color,
//       Color.alphaBlend(
//         gradient.withOpacity(gradientOpacity), 
//         color,
//       ), 
//     ],
//     stops: [
//       0.0, 
//       if(gradientStrenght != 1)
//         1-gradientStrenght, 
//       1.0,
//     ],
//   );
// }