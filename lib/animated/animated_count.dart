import 'package:flutter/material.dart';


class AnimatedCount extends ImplicitlyAnimatedWidget {
  final int count;
  final TextStyle style;

  AnimatedCount({
    Key? key,
    required this.count,
    required this.style,
    required Duration duration,
    Curve curve = Curves.easeIn
  }) : super(duration: duration, curve: curve, key: key);

  @override
  ImplicitlyAnimatedWidgetState<ImplicitlyAnimatedWidget> createState() => _AnimatedCountState();
}

class _AnimatedCountState extends AnimatedWidgetBaseState<AnimatedCount> {
  IntTween? _count;

  @override  
  Widget build(BuildContext context) {
    return new Text(
      _count!.evaluate(animation).toString(),
      style: widget.style
    );
  }

  @override
  void forEachTween(visitor) {
    _count = visitor(
      _count, 
      widget.count, 
      (dynamic value) => IntTween(begin: value),
    ) as IntTween?;
  }
}


//propText(
//  startingStyle: MyStyles.playerLife,
//  referencePixel: popSizes[PopSize.op3tHeight],
//  truePixel: widget.referenceHeight,
//),


