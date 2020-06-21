import 'package:flutter/material.dart';

//  import 'dart:math' as math;


class AutoSwappingIcon extends StatefulWidget {
  final IconData icon;
  final Color color;
  final double size;
  final Duration duration;
  final double opacity;

  AutoSwappingIcon({
    Key key,
    @required this.icon,
    this.color,
    this.size,
    this.opacity,
    this.duration = const Duration(milliseconds: 200),
  }) : super(key: key);

  @override
  State createState() => new AutoSwappingIconState();
}

class AutoSwappingIconState extends State<AutoSwappingIcon> with TickerProviderStateMixin{

  Animation<double> _step;
  AnimationController _controller;
  bool _current;
  IconData _firstData;
  IconData _secondData;

  @override
  void initState() {
    _current = true;
    _firstData = widget.icon;
    _secondData = widget.icon;
    
    this._controller = AnimationController(
      duration: Duration(milliseconds: widget.duration.inMilliseconds~/2),
      vsync: this,
    );

    this._step = Tween(begin: 1.0, end: 0.7)
      .animate(
        CurvedAnimation(
          parent: this._controller, 
          curve: Curves.linear,
        ),
      );

    super.initState();
  }

  @override
  void dispose() {
    this._controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(AutoSwappingIcon oldWidget) {
    if(oldWidget.icon != widget.icon){
      if(_current){
        _secondData = widget.icon;
      }
      else{
        _firstData = widget.icon;
      }
      _current = !_current;
      this._controller.forward().then((void v) => this._controller.reverse());
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {

    final iconTheme = IconTheme.of(context);

    final _placeHolder = Container(
      width: widget.size ?? iconTheme.size,
      height: widget.size ?? iconTheme.size,
      color: Colors.transparent,
    );

    Widget firstIcon = _firstData != null
      ? Icon(
        _firstData,
        size: widget.size ?? iconTheme.size,
        color: widget.color ?? iconTheme.color,
      )
      : _placeHolder;

    Widget secondIcon = _secondData != null
      ? Icon(
        _secondData,
        size: widget.size ?? iconTheme.size,
        color: widget.color ?? iconTheme.color,
      )
      : _placeHolder;

    return IconTheme(
      data: IconThemeData(opacity: widget.opacity),
      child: AnimatedBuilder(
        animation: _step,
        child: AnimatedCrossFade(
          alignment: Alignment.center,
          firstChild: firstIcon,
          secondChild: secondIcon,
          duration: widget.duration,
          crossFadeState: _current ? CrossFadeState.showFirst : CrossFadeState.showSecond,
        ),
        builder: (context, childA){
          return Transform.scale(
            alignment: Alignment.center,
            scale: _step.value,
            child: childA,
          );
        },
      ),
    );

  }
}


