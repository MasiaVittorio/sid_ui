import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:sid_ui/interactive/advanced_slider/advanced_slider.dart';
import 'package:sid_ui/interactive/advanced_slider/vertical_slider.dart';
import 'package:sid_utils/sid_utils.dart';

///this takes a bit of code from another package to build 
///the saturation / value rectangle: flutter_hsvcolor_picker 

class ManualColorPicker extends StatefulWidget {

  final Color color;
  final Function(Color) onChanged;

  ManualColorPicker({
    Key? key,
    required this.color,
    required this.onChanged,
  }): super(key: key);

  @override
  _ManualColorPickerState createState() => _ManualColorPickerState();
}


class _ManualColorPickerState extends State<ManualColorPicker> {

  late double _hue;
  late double _sat;
  late double _val;

  HSVColor get color => HSVColor.fromColor(this.widget.color);

  void _reset(){
    this._hue = this.color.hue;
    this._sat = this.color.saturation;
    this._val = this.color.value;
  }

  Color get currentColor => HSVColor.fromAHSV(
    this.widget.color.alpha/255.toDouble(), 
    this._hue, 
    this._sat, 
    this._val,
  ).toColor();

  @override
  void initState(){
    super.initState();
    this._reset();
  }

  @override
  void didUpdateWidget(oldWidget){
    super.didUpdateWidget(oldWidget);
    if(this.currentColor != this.widget.color){
      this._reset();
    }
  }

  Color get themeContrast => Theme.of(context).canvasColor.contrast;

  void colorFromHsv() => super.widget.onChanged(
    HSVColor.fromAHSV(
      this.color.alpha, 
      this._hue,
      this._sat, 
      this._val,
    ).toColor()
  );
  
  List<double> _interpolate(int n, double min, double max){
    List<double> result = <double>[];
    double i = min;
    double step = (max-min)/(n-1);
    while(i <= max){
      result.add(i);
      i+=step;
    }
    return result;
  }

  //Hue
  void hueOnChange(double value) => setState(() {
    this._hue = value;
    this.colorFromHsv();
  });
  

  List<Color> get hueColors => _interpolate(360,0.0,360).map<Color>(
    (double x) => HSVColor.fromAHSV(
      1.0,
      x,
      1.0,
      1.0,
    ).toColor()
  ).toList();

  //Saturation / Value
  void saturationValueOnChange(Offset value) => setState(() {
    this._sat = value.dx;
    this._val = value.dy;
    this.colorFromHsv();
  });

  //Saturation
  List<Color> get saturationColors =>[
    Colors.white,
    HSVColor.fromAHSV(1.0, this._hue, 1.0, 1.0).toColor()
  ];

  //Value
  final List<Color> valueColors =[
    Colors.transparent,
    Colors.black
  ];

  @override
  Widget build(BuildContext context) {

    return LayoutBuilder(builder: (context, constraints){

      double _padding = 8.0;
      return Material(
        child: Row(
          children: <Widget>[
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(_padding*2),
                child: PalettePicker(
                  circleColor: ThemeData.estimateBrightnessForColor(this.color.toColor()) == Brightness.dark ? Colors.white : Colors.black,
                  width: constraints.maxWidth - _padding*2,
                  height: constraints.maxHeight - _padding*2,
                  position: Offset(this._sat, this._val),
                  onChanged: this.saturationValueOnChange,
                  leftRightColors: this.saturationColors,
                  topPosition: 1.0,
                  bottomPosition: 0.0,
                  topBottomColors: this.valueColors
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right:8.0),
              child: _hueSlider(this.themeContrast, constraints.maxHeight),
            ),
          ]
        ),
      );

    });


  }

  Widget _hueSlider(Color activeColor, double height) => SliderTheme(
    data: SliderTheme.of(context).copyWith(
      thumbColor: HSVColor.fromAHSV(
        1.0,
        this._hue,
        1.0,
        1.0,
      ).toColor(),
      thumbShape: BorderRoundSliderThumbShape(
        border: 2,
        enabledThumbRadius: 8.0,
        borderColor: activeColor,   
      ),
      trackHeight: 8,
      trackShape: ShadeRectangularSliderTrackShape(
        gradient: LinearGradient(
          colors: _interpolate(360,0.0,360).map<Color>(
            (double x) => HSVColor.fromAHSV(
              1.0,
              x,
              1.0,
              1.0,
            ).toColor(),
          ).toList()
        )
      ),
    ),
    child: VerticalSlider(
      height: height,
      width: 64,
      value: this._hue,
      max: 360.0,
      min: 0.0,
      onChanged: (double newHue) {setState(() {
        this.hueOnChange(newHue);
      });},
    )
  );


}





class PalettePicker extends StatefulWidget {

  final Offset position;
  final ValueChanged<Offset> onChanged;

  final double leftPosition;
  final double rightPosition;
  final List<Color> leftRightColors;

  final double topPosition;
  final double bottomPosition;
  final List<Color> topBottomColors;

  final double width;
  final double height;

  final Color circleColor;

  PalettePicker({
    Key? key,

    required this.width,
    required this.height,
    required this.position,
    required this.onChanged,
    this.circleColor = Colors.black,
    this.leftPosition=0.0,
    this.rightPosition=1.0,
    required this.leftRightColors,

    this.topPosition=0.0,
    this.bottomPosition=1.0,
    required this.topBottomColors
  }):  super(key: key);

  @override
  _PalettePickerState createState() => _PalettePickerState();
}

class _PalettePickerState extends State<PalettePicker> {

  final GlobalKey paletteKey = GlobalKey();

  @override
  void initState(){
    super.initState();
  }


  Offset get position => widget.position;
  double get leftPosition => widget.leftPosition;
  double get rightPosition => widget.rightPosition;
  double get topPosition => widget.topPosition;
  double get bottomPosition => widget.bottomPosition;


  /// Position(min, max) > Ratio(0, 1)
  Offset positionToRatio(){
    double ratioX = this.leftPosition < this.rightPosition
      ?       this.positionToRatio2( this.position.dx, this.leftPosition, this.rightPosition )
      : 1.0 - this.positionToRatio2( this.position.dx, this.rightPosition, this.leftPosition );

    double ratioY = this.topPosition < this.bottomPosition
      ?       this.positionToRatio2( this.position.dy, this.topPosition, this.bottomPosition )
      : 1.0 - this.positionToRatio2( this.position.dy, this.bottomPosition, this.topPosition );

    return Offset(ratioX, ratioY);
  }
  double positionToRatio2(double postiton, double minPostition, double maxPostition){
    if(postiton < minPostition) return 0.0;
    if(postiton > maxPostition) return 1.0;
    return (postiton - minPostition) / (maxPostition - minPostition);
  }

  /// Ratio(0, 1) > Position(min, max)
  void ratioToPosition(Offset ratio){
    RenderBox renderBox = this.paletteKey.currentContext!.findRenderObject() as RenderBox;
    Offset startposition = renderBox.localToGlobal(Offset.zero);
    Size size = renderBox.size;
    Offset updateOffset= ratio-startposition;

    double ratioX = updateOffset.dx / size.width;
    double ratioY = updateOffset.dy / size.height;

    double positionX = this.leftPosition < this.rightPosition?
    this.ratioToPosition2(ratioX, this.leftPosition, this.rightPosition):
    this.ratioToPosition2(1.0 - ratioX, this.rightPosition, this.leftPosition);

    double positionY= this.topPosition < this.bottomPosition?
    this.ratioToPosition2(ratioY, this.topPosition, this.bottomPosition):
    this.ratioToPosition2(1.0 - ratioY, this.bottomPosition, this.topPosition);

    Offset position = Offset(positionX, positionY);
    super.widget.onChanged(position);
  }
  double ratioToPosition2(double ratio, double minposition, double maxposition){
    if(ratio < 0.0) return minposition;
    if(ratio > 1.0) return maxposition;
    return  ratio * maxposition + (1.0 - ratio) * minposition;
  }


  Widget buildLeftRightColors() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: super.widget.leftRightColors
        )
      )
    );
  }

  Widget buildTopBottomColors() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: super.widget.topBottomColors
        )
      )
    );
  }

  Widget buildGestureDetector() {
    void _update(details) => this.ratioToPosition(details.globalPosition);
    return GestureDetector(
      onPanStart: _update,
      onPanDown: _update,
      onPanUpdate: _update,

      onTapDown: _update,

      //To override eventual outer vertical lists' / sheets' gestures
      onVerticalDragDown: _update,
      onVerticalDragUpdate: _update,
      onVerticalDragStart: _update,

      child: SizedBox(
        key: this.paletteKey,
        width: this.widget.width,
        height: this.widget.height,
        child: CustomPaint(
          painter: _PalettePainter(ratio: this.positionToRatio(), circleColor: this.widget.circleColor)
        )
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        this.buildLeftRightColors(),
        this.buildTopBottomColors(),
        this.buildGestureDetector(),
      ]
    );
  }

}




class _PalettePainter extends CustomPainter{

  final Offset? ratio;
  final Color? circleColor;
  _PalettePainter({this.ratio, this.circleColor}):super();

  @override
  void paint(Canvas canvas, Size size) {

    final Paint paintBlack = Paint()
      ..color=this.circleColor ?? Colors.black
      ..strokeWidth=2
      ..style=PaintingStyle.stroke;

    Offset offset=Offset(size.width * this.ratio!.dx, size.height * this.ratio!.dy);
    canvas.drawCircle(offset, 8, paintBlack);
  }

  @override
  bool shouldRepaint(_PalettePainter other) => true;
}


