import 'package:flutter/material.dart';


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

  AnimationController moveController;

  int _lastValue;
  int _prevValue;

  @override
  void initState() {
    super.initState();

    this._lastValue = widget.value;

    this.moveController = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

  }

  @override
  void dispose() {
    this.moveController.dispose();
    super.dispose();
  }


  @override
  void didUpdateWidget(CircleNumber oldWidget) {
    super.didUpdateWidget(oldWidget);
    if(widget.value != this._lastValue){
      setState(() { 
        this._prevValue = this._lastValue;
        this._lastValue = widget.value;
      });
      this.moveController.animateTo(1.0, curve: curve).then((void v){
        this.moveController.reset();
        if(mounted)
          setState(() { 
            this._prevValue = null;
          });
      });
    }
  }

  static const Curve curve = Curves.ease;

  Widget get text {
    final double size = widget.size;

    int _inc = this._prevValue != null ?
      widget.value - this._prevValue
      : widget.increment;
    int _val = this._prevValue != null ?
      this._prevValue : widget.value;
    
    return AnimatedOpacity(
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
  }


  @override
  Widget build(BuildContext context) {

    double size = widget.size;

    final Widget content = AnimatedBuilder(
      animation: this.moveController,
      child: text,
      builder: (BuildContext context, Widget child) {
        return Stack(
          fit: StackFit.expand,
          alignment: Alignment.centerLeft,
          children: <Widget>[
            Positioned(
              top: 0.0,
              bottom: 0.0,
              left: 0.0 - moveController.value * size * 2,
              width: size * 3.0,
              child: child,
            ),
          ],
        );
      },
    );


    return AnimatedContainer(
      duration: widget.duration,
      decoration: BoxDecoration(
        color: widget.color,
        borderRadius: BorderRadius.circular(widget.size*widget.borderRadiusFraction),
      ),
      height: widget.size,
      width: widget.open ? widget.size * 3.0 : widget.size,
      curve: curve,
      child: content,
    );
  }
}


