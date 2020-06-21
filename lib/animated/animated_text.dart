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
    Key key,
    this.duration = const Duration(milliseconds: 200),
    this.style,
    this.textAlign,
    this.curve: Curves.easeIn,
    this.maxLines,
    this.overflow,
  }) :  assert(duration != null),
        super(key: key);

  @override
  State createState() => new AnimatedTextState();
}

List<String> stringInterpolatedSteps(String start, String end){
  String step = start + '';

  List<String> result = <String> [step];

  while(step != end){
    step = _nextString(step, end);
    result.add(step);
  }

  return result;
}

class AnimatedTextState extends State<AnimatedText> with TickerProviderStateMixin {

  AnimationController _controller;
  Animation<int> _stepIndex;
  String _current;
  List<String> _steps = <String>[];

  String get currentText => _steps[_stepIndex.value];

  @override
  void initState() {
    _current = widget.text;
    _steps = <String>[_current];

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

  void _updateText() async {
    _steps = stringInterpolatedSteps(currentText, widget.text);

    this._controller.reset();

    _current = widget.text;

    _initStep();

    _controller.forward();
  }


  @override
  void didUpdateWidget(AnimatedText oldWidget) {
    if (_current != widget.text)
      this._updateText();

    if(this._controller.duration != widget.duration)    
      this._controller.duration = widget.duration;
    
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) 
    => AnimatedBuilder(
      animation: _stepIndex,
      builder: (context, _) 
        => Text(
          this.currentText,
          style: widget.style,
          maxLines: widget.maxLines,
          textAlign: widget.textAlign,
          overflow: widget.overflow,
        ),
    );
}


List<String> _splitString(String s) => <String>[
  for(final x in s.split(''))
    x,
];
List<String> _splitStringReverse(String s) => <String>[
  for(final x in s.split('').reversed)
    x,
];

String _nextString(String intermediate, String end){
  if (intermediate == end) 
    return end + '';

  final String shared = _findBestShared(intermediate, end);

  //if there is no letter to delete
  if(intermediate == shared){

    List<String> listInter = _splitString(intermediate);

    //find where to insert the new letter
    for(int i = 0; i<listInter.length; i++){
      if (listInter[i] != end[i]) {
        listInter.insert(i,end[i]);
        return listInter.join();
      }
    }

    //it was at the end!
    if(end.length > intermediate.length) 
      return intermediate+end[intermediate.length];
  }
  
  //if there are letters to delete
  List<String> lInterRev = _splitStringReverse(intermediate);
  
  List<String> lSharedRev = _splitStringReverse(shared);
  
  for(int i=0; i<lInterRev.length; i++){
    if (lSharedRev.isNotEmpty && lInterRev[i]==lSharedRev[0]) 
      lSharedRev.removeAt(0);
    else {
      lInterRev.removeAt(i);
      break;
    }
  }
  return lInterRev.reversed.join();
  
}

String _findBestShared(String start, String end){
  final String shared1 = _findOrderedShared1(start, end);
  final String shared2 = _findOrderedShared2(start, end);
  
  if(shared2.length >= shared1.length) 
    return shared2;
  else 
    return shared1;
}

String _findOrderedShared1(String start, String end){
  if(end	.length	== 0) return '';
  if(start.length	== 0) return '';
  
  String result ='';
  List<String> obj = end.split('').toList();

  for (String x in start.split('').toList()){
    
    for (int i=0; i<obj.length;i++){
      if(x==obj[i]) {
        result+=x;
        obj = obj.sublist(i+1);
        break;
      }
    }
  }
  
  return result;
}

String _findOrderedShared2(String start, String end){
  if(end	.length	== 0) return '';
  if(start.length	== 0) return '';
  
  String ret ='';
  List<String> obj = end.split('').toList();
  List <String> robj = obj.reversed.toList();
  for (String x in start.split('').reversed){
    
    for (int i=0; i<robj.length;i++){
      if(x==robj[i]) {
        ret+=x;
        robj = robj.sublist(i+1);
        break;
      }
    }
  }
  
  return ret.split('').reversed.join();
}
