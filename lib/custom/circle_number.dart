import 'package:flutter/material.dart';

// import 'dart:math';


class CircleNumber extends StatefulWidget {
  final Duration duration;
  final bool open;

  final double size;
  final double borderRadiusFraction;
  final int value;
  final int increment;

  final Color color;

  final double numberOpacity;

  final TextStyle style;


  CircleNumber({
    @required this.duration,
    @required this.open,
    @required this.numberOpacity,
    @required this.size,
    @required this.borderRadiusFraction,
    @required this.value,
    @required this.increment,
    @required this.color,
    @required this.style,
    Key key,
  }):super(key: key);

  @override
  State createState() => new _CircleNumberState();
}

class _CircleNumberState extends State<CircleNumber> with TickerProviderStateMixin {

  Animation<double> _moveStep;
  Animation<double> _sizeStep;
  AnimationController _moveController;
  AnimationController _sizeController;

  int _lastValue;
  int _prevValue;

  @override
  void initState() {
    super.initState();

    this._lastValue = widget.value;
    this._prevValue = this._lastValue;

    this._moveController = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    this._sizeController = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    this._moveStep = Tween(begin: 0.0, end: 1.0)
      .animate(
        CurvedAnimation(
          parent: this._moveController, 
          curve: Curves.linear,
        ),
      );
    this._sizeStep = Tween(begin: 1/3, end: 1.0)
      .animate(
        CurvedAnimation(
          parent: this._sizeController, 
          curve: Curves.linear,
        ),
      );

  }

  @override
  void dispose() {
    this._sizeController.dispose();
    this._moveController.dispose();
    super.dispose();
  }

  void logic(){
    if(widget.value != this._lastValue){
      this._moveController.forward().then((void v){
        this._moveController.reset();
      });
    }
    if(widget.open == true)
      this._sizeController.forward();
    else
      this._sizeController.reverse();
    
    this._prevValue = this._lastValue;
    this._lastValue = widget.value;
  }

  @override
  Widget build(BuildContext context) {
    
    this.logic();

    double size = widget.size;
    
    return Container(
      height: size,
      child: SizeTransition(
        axisAlignment: -1,
        axis: Axis.horizontal,
        sizeFactor: this._sizeStep,
        child: Container(
          width: size*3,
          height: size,
          constraints: BoxConstraints(
            minWidth: size*3,
            maxWidth: size*3,
            minHeight: size,
            maxHeight: size,
          ),
          child: Center(
            child: Stack(
              // alignment: Alignment.centerLeft,
              children: <Widget>[
                Positioned(
                  left: 0,
                  child: AnimatedContainer(
                    duration: widget.duration,
                    decoration: BoxDecoration(
                      color: widget.color,
                      borderRadius: BorderRadius.circular(widget.size*widget.borderRadiusFraction),
                    ),
                    height: widget.size,
                    width: widget.open ? widget.size*3 : widget.size,
                  ),
                ),
                Positioned(
                  left: 0,
                  child: AnimatedBuilder(
                    animation: _moveStep,
                    builder: (BuildContext context, Widget chb) {
                      double ms = _moveStep.value;
                      int _inc = _moveStep.status == AnimationStatus.forward ?
                        widget.value - this._prevValue
                        : widget.increment;
                      int _val = _moveStep.status ==AnimationStatus.forward ?
                        this._prevValue : widget.value;
                      
                      final Widget _text = AnimatedOpacity(
                        duration: widget.duration,
                        opacity: widget.numberOpacity,
                        child: SizedBox(
                          width: size*3,
                          height: size,
                          child: Stack(children: <Widget>[
                            Positioned(
                              left: 0,
                              child: SizedBox(
                                width: size,
                                height: size,
                                child: Center(
                                  child: Text(
                                    '$_val',
                                    style: widget.style,
                                  )
                                ),
                              ),
                            ),
                            Center(
                              child: SizedBox(
                                width: size*3,
                                height: size,
                                child: Center(
                                  child: Text(
                                    _inc < 0 ?
                                    '- ${-_inc} ='
                                    : '+ $_inc =',
                                    style: widget.style,
                                  )
                                ),
                              ),
                            ),
                            Positioned(
                              right: 0,
                              child: SizedBox(
                                width: size,
                                height: size,
                                child: Center(
                                  child: Text(
                                    '${widget.value + widget.increment}',
                                    style: widget.style,
                                  )
                                ),
                              ),
                            ),
                          ],),
                        ),
                      );
                    
                      return Container(
                        width: size*3,
                        height: size,
                        constraints: BoxConstraints(
                          minWidth: size*3,
                          maxWidth: size*3,
                          minHeight: size,
                          maxHeight: size,
                        ),
                        child: Stack(children: <Widget>[
                          Positioned(
                            left: 0 - ms * size*2,
                            child: _text,
                          )
                        ],),
                      );
                    }
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


class RectClipper extends CustomClipper<Rect> {
  RectClipper({this.center, this.height, this.width});

  final Offset center;
  final double height;
  final double width;

  @override
  Rect getClip(Size size) {
    var rect = Rect.fromLTWH(
      this.center.dx,
      this.center.dy,
      this.width,
      this.height,
    );

    return rect;
  }

  @override
  bool shouldReclip(RectClipper oldClipper) 
    => oldClipper.center != this.center 
    || oldClipper.height != this.height 
    || oldClipper.width != this.width;
}


