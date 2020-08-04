import 'package:flutter/material.dart';

class AnimatedText extends StatefulWidget {

  final String text;
  final Duration duration;
  final Curve curve;
  final TextStyle style;
  final TextAlign textAlign;
  final int maxLines;
  final TextOverflow overflow;

  AnimatedText(this.text, {
    this.duration = const Duration(milliseconds: 200),
    this.style,
    this.textAlign,
    this.curve: Curves.easeIn,
    this.maxLines,
    this.overflow,
    Key key,
  }) :  assert(duration != null),
        super(key: key);

  @override
  State createState() => new AnimatedTextState();

  static List<String> stringInterpolatedSteps(String start, String end){
    String step = start;

    List<String> result = <String> [step];

    while(step != end){
      step = _nextString(step, end);
      result.add(step);
    }

    return result;
  }

  static String _nextString(String intermediate, String end){
    if (intermediate == end) 
      return end;

    final String shared = _findBestShared(intermediate, end);

    //if there is no letter to delete
    if(intermediate == shared){

      List<String> listInter = intermediate.split('');

      //find where to insert the new letter
      for(int i = 0; i<listInter.length; i++){
        if (listInter[i] != end[i]) {
          listInter.insert(i, end[i]);
          return listInter.join();
        }
      }

      //it was at the end!
      if(end.length > intermediate.length) 
        return intermediate + end[intermediate.length];
    }
    
    //if there are letters to delete
    List<String> intermediateReversed = <String>[
      ...intermediate.split("").reversed,
    ];
    List<String> sharedReversed = <String>[
      ...shared.split("").reversed,
    ];
    
    for(int i=0; i<intermediateReversed.length; i++){

      if (sharedReversed.isNotEmpty && intermediateReversed[i]==sharedReversed[0]) {
        sharedReversed.removeAt(0);
      } else {
        intermediateReversed.removeAt(i);
        break;
      }

    }
    return intermediateReversed.reversed.join();
    
  }

  static String _findBestShared(String start, String end){
    final String sharedForward = _findOrderedSharedForward(start, end);
    final String sharedBackward = _findOrderedSharedBackward(start, end);
    
    if(sharedBackward.length >= sharedForward.length) 
      return sharedBackward;
    else 
      return sharedForward;
  }

  static String _findOrderedSharedForward(String start, String end){
    if(end	.length	== 0) return '';
    if(start.length	== 0) return '';
    
    String result = '';
    List<String> obj = end.split('').toList();

    for (String x in start.split('')){
      
      for (int i=0; i<obj.length; i++){
        if(x == obj[i]) {
          result += x;
          obj = obj.sublist(i+1);
          break;
        }
      }
    }
    
    return result;
  }

  static String _findOrderedSharedBackward(String start, String end)
    => _findOrderedSharedForward(
      start.split('').reversed.join(),
      end.split('').reversed.join(),
    ).split('').reversed.join();


}



class AnimatedTextState extends State<AnimatedText> with TickerProviderStateMixin {

  AnimationController _controller;
  Animation<int> _stepIndex;
  // String _current;
  List<String> _steps = <String>[];

  String get currentText => _steps[_stepIndex.value];

  @override
  void initState() {
    // _current = widget.text;
    _steps = <String>[
      // _current
      widget.text,
    ];

    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _initStep();

    super.initState();
  }

  void _initStep(){
    _stepIndex = StepTween(begin: 0, end: _steps.length - 1)
      .animate(CurvedAnimation(
        parent: _controller, 
        curve: widget.curve,
      ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }


  @override
  void didUpdateWidget(AnimatedText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text){
    // if (_current != widget.text){
      _steps = AnimatedText.stringInterpolatedSteps(currentText, widget.text);

      _controller.reset();

      // _current = widget.text;

      _initStep();

      _controller.forward();
    }

    if(this._controller.duration != widget.duration)    
      this._controller.duration = widget.duration;
  }

  @override
  Widget build(BuildContext context) 
    => AnimatedBuilder(
      animation: _stepIndex,
      builder: (context, _) => Text(
        this.currentText,
        style: widget.style,
        maxLines: widget.maxLines,
        textAlign: widget.textAlign,
        overflow: widget.overflow,
      ),
    );
}


