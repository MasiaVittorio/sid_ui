import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sid_ui/decorations/up_shadower.dart';
import 'package:sid_ui/interactive/advanced_slider/advanced_slider.dart';
import 'models/color_to_hex.dart';
import 'package:sid_utils/sid_utils.dart';


class CustomColorPicker extends StatefulWidget {
  final Color? color;
  final void Function(Color?) onChanged;
  final void Function()? displayerUndescrollCallback;

  CustomColorPicker({    
    required this.color,
    required this.onChanged,
    required this.displayerUndescrollCallback,
  });

  static final double sliderHeight = 64;

  @override
  State createState() => new _CustomColorPickerState();
}



class _CustomColorPickerState extends State<CustomColorPicker> with TickerProviderStateMixin {

  Color? _color;
  bool? _rgbMode;

  late double _hue;
  late double _sat;
  late double _value;

  bool _insertMode= false; //wether youre inserting a text or not
  TextEditingController? _controller;
  // String _clipboardString;

  @override
  void initState() {
    super.initState();

    //Color stuff    
    this._rgbMode = true;
    this._insertMode = false;
    this._reset();

    //Insert stuff 
    this._insertMode = false;   
    this._controller = TextEditingController(
      text: ( 
        this._color!.red    .toRadixString(16).padLeft(2,'0') +
        this._color!.green  .toRadixString(16).padLeft(2,'0') +
        this._color!.blue   .toRadixString(16).padLeft(2,'0')
      ).toUpperCase(),
    );
    
  }


  void _reset(){
    this._color = widget.color?.withAlpha(255) 
      ?? Colors.black;
    this._updateHsvFromColor();    
  }

  @override
  void didUpdateWidget(oldWidget){
    super.didUpdateWidget(oldWidget);
    if(this.colorFromHsv != this.widget.color)
      this._reset();
  }

  void switchMode() {
    setState(() {
      this._rgbMode = this._rgbMode == false; 
    });
  }

  void copyToClipboard(){
    Clipboard.setData(ClipboardData(text: _color!.hexString));
  }

  void _updateHsvFromColor(){
    final _hsv  = HSVColor.fromColor(this._color!);

    this._hue   = _hsv.hue;
    this._sat   = _hsv.saturation;
    this._value = _hsv.value;
  }
  void _updateColorFromHsv(){    
    this._color = this.colorFromHsv;
  }
  Color get colorFromHsv => HSVColor.fromAHSV(
    this._color!.alpha/255.toDouble(),
    this._hue,
    this._sat,
    this._value,
  ).toColor();

  @override
  Widget build(BuildContext context) 
    => LayoutBuilder(builder: (context, externalConstraints) {

        final themeOfContext = Theme.of(context);
        final sliderThemeOfContext = SliderTheme.of(context);

        final bool _big = CustomColorPicker.sliderHeight * 6 + 50 <= externalConstraints.maxHeight;       

        final Color _activeColor = themeOfContext.canvasColor.contrast;

        final List<Widget> _rgbs = <Widget>[ 
          _rgbSlider("Red"),
          _rgbSlider("Green"),
          _rgbSlider("Blue"),
        ];

        final List<Widget> _hsls = <Widget>[
          _hueSlider(_activeColor, sliderThemeOfContext),
          _saturationSlider(_activeColor, sliderThemeOfContext),
          _valueSlider(_activeColor, sliderThemeOfContext),
        ];

        return Column(
          children: <Widget>[
            _displayer(_big, themeOfContext),
            UpShadower(
              child: Column(
                children: <Widget>[
                  if(_big || this._rgbMode == true  ) 
                    ..._rgbs,
                  if(_big || this._rgbMode == false ) 
                    ..._hsls,
                ],
              ),
            ),
          ],
        );
      }
    );

  bool get _scrollable => this.widget.displayerUndescrollCallback != null;

  Widget _scrollableDisplayer(BoxConstraints constraints, bool big, ThemeData themeOfContext) => Theme(
    data: themeOfContext.copyWith(
      accentColor: this._color == Colors.white 
        ? Colors.black
        : Colors.white
    ),
    child: SingleChildScrollView(
      physics: SidereusScrollPhysics(
        alwaysScrollable: true,
        bottomBounce: false,
        topBounce: _scrollable,
        topBounceCallback: this.widget.displayerUndescrollCallback,
      ),
      child: _materialDisplayer(constraints, big)
    ),
  );

  Widget _displayer(bool big, ThemeData themeOfContext) => this._scrollable 
    ? Expanded(child: LayoutBuilder(
      builder: (context, constraints) => Container(
        constraints: constraints,
        child: _scrollableDisplayer(constraints, big, themeOfContext),
      ),
    ))
    : Expanded(child: _materialDisplayer(null, big));

  final Map<String, Color> _baseColorMap = {
    "Red"   : Colors.red,
    "Blue"  : Colors.blue,
    "Green" : Colors.green,
  };
  Widget _rgbSlider(String rgb){
    final Color _clr = this._color!;

    int _number = {
      "Red"   : _clr.red,
      "Green" : _clr.green,
      "Blue"  : _clr.blue,        
    }[rgb]!;

    Color _baseColor = _baseColorMap[rgb]!;

    return AdvancedSlider(
      height: CustomColorPicker.sliderHeight,
      name: '$rgb: $_number',
      annotation: '(${_number.toRadixString(16).padLeft(2,'0').toUpperCase()} hex)',
      value: _number.toDouble(),
      activeColor: _baseColor,
      inactiveColor: _baseColor.withOpacity(0.24),
      max: 255.0,
      min: 0.0,
      onChanged: (double nd) {
        setState(() {
          if(rgb == "Red")    this._color = _clr.withRed(   nd.round()  ); 
          if(rgb == "Green")  this._color = _clr.withGreen( nd.round()  ); 
          if(rgb == "Blue")   this._color = _clr.withBlue(  nd.round()  ); 
          this._updateHsvFromColor();
          widget.onChanged(this._color);
        });
      },
      buttonDivision: 1.0,
    );
  }

  Widget _materialDisplayer(BoxConstraints? constraints, bool big) {
    final bool darkBkg = ThemeData.estimateBrightnessForColor(this._color!) == Brightness.dark;

    return Material(
      color: this._color,
      child: Theme(
        data: darkBkg ? ThemeData.dark() : ThemeData.light(),
        child: constraints == null
          ? _center(big,darkBkg)
          : Container(
            width: constraints.maxWidth,
            height: constraints.maxHeight,
            child: _center(big, darkBkg)
          ),
      ),
    );
  }

  Widget _center(bool big, bool darkBkg) => Row(
    children: <Widget>[
      Expanded(child: this._insertMode 
        ? IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => setState(() {
            this._controller!.clear();
            this._insertMode = false;
          }),
        )
        : switcher(big),
      ),
      Expanded(child: _realCenter(darkBkg)),
      Expanded(child: this._insertMode 
        // ? IconButton(
        //   icon: const Icon(Icons.content_paste),
        //   onPressed: _clipboardString != null ? () async{
        //     await this._getClipboardAndCheck();

        //     if(this._clipboardString == null) return;

        //     setState(() {
        //       this._controller.text = this._clipboardString+'';
        //     });
        //   } : null
        // )
        ? InkWell(
          onTap: this.confirmInsert,
          child: Center(
            child: const Icon(Icons.check),
          ),
        )
        : InkWell(
          onTap: this.copyToClipboard,
          child: Center(
            child: Icon(Icons.content_copy),
          ),
        ),
      ),
    ],
  );

  Widget switcher(bool big) => big ? Container() : InkWell(
    onTap:  this.switchMode,
    child:Center(
      child: Icon(Icons.swap_horiz),
    ),
  );

  Widget _realCenter(bool darkBkg) {
    String _errorString = checkForHexString(this._controller!.text) == false ? "Error" : "";
    bool _error = _errorString != '';

    return this._insertMode 
      ? Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: TextField(
            keyboardType: TextInputType.text,
            autofocus: true,
            textAlign: TextAlign.start,
            maxLength: 6,
            controller: this._controller,
            textCapitalization: TextCapitalization.characters,
            style: TextStyle(
              fontSize: 18.0,
              fontWeight: _error ? null : FontWeight.w600,
            ),
            onChanged: (String ts) => setState(() {}),
            decoration: InputDecoration(
              prefixText: "#FF ",
              prefixStyle: TextStyle(
                inherit: true,
                color: darkBkg ? const Color(0x88FFFFFF) : const Color(0x88000000),
                fontSize: 18.0,
                fontWeight: FontWeight.w600,
              ),
              errorText: _error ? _errorString : null,
            ),
          ),
        )
      )
      : InkWell(
        onTap: () => this.setState((){
          this._insertMode = true;
        }),
        child: Center(
          child: Text(
            "#FF ${_color!.hexString}",
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700, 
              color: ThemeData.estimateBrightnessForColor(this._color!) == Brightness.dark 
                ? Colors.white 
                : Colors.black
            ),
          ),
        ),
      );
  }

  void confirmInsert() => setState(() {
    this._color = hexToColor(this._controller!.text);
    this._updateHsvFromColor();
    widget.onChanged(this._color);
    this._insertMode = false;
  });

  final double _hsvSliderHeight = 6;
  Widget _hueSlider(Color activeColor, SliderThemeData sliderThemeOfContext) => SliderTheme(
    data: sliderThemeOfContext.copyWith(
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
      trackHeight: _hsvSliderHeight,
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
    child: AdvancedSlider(
      height: CustomColorPicker.sliderHeight,
      name: 'Hue: ${this._hue.toInt()}°',
      value: this._hue,
      max: 360.0,
      min: 0.0,
      onChanged: (double newHue) {setState(() {
        this._hue = newHue;
        this._updateColorFromHsv();
        this.widget.onChanged(this._color);
      });},
      buttonDivision: 1.0,
    )
  );

  
  Widget _saturationSlider(Color activeColor, SliderThemeData sliderThemeOfContext) => SliderTheme(
    data: sliderThemeOfContext.copyWith(
      thumbColor: this._color,
      thumbShape: BorderRoundSliderThumbShape(
        border: 2,
        enabledThumbRadius: 8.0,
        borderColor: activeColor,   
      ),
      trackHeight: _hsvSliderHeight,
      trackShape: ShadeRectangularSliderTrackShape(
        gradient: LinearGradient(
          colors: _interpolate(100,0.0,1.0).map<Color>(
            (double x) => HSVColor.fromAHSV(
              1.0,
              this._hue,
              x,
              this._value,
            ).toColor(),
          ).toList()
        )
      ),
    ),
    child: AdvancedSlider(
      height: CustomColorPicker.sliderHeight,
      name: 'Saturation: ${(this._sat*100).toInt()} %',
      value: this._sat,
      max: 1.0,
      min: 0.0,
      onChanged: (double newSat) {setState(() {
        this._sat = newSat;
        this._updateColorFromHsv();
        this.widget.onChanged(this._color);
      });},
      buttonDivision: 0.01,
    ),
  );

  Widget _valueSlider(Color activeColor, SliderThemeData sliderThemeOfContext) => SliderTheme(
    data: sliderThemeOfContext.copyWith(
      thumbColor: this._color,
      thumbShape: BorderRoundSliderThumbShape(
        border: 2,
        enabledThumbRadius: 8.0,
        borderColor: activeColor,   
      ),
      trackHeight: _hsvSliderHeight,
      trackShape: ShadeRectangularSliderTrackShape(
        gradient: LinearGradient(
          colors: _interpolate(100,0.0,1.0).map<Color>(
            (double x) => HSVColor.fromAHSV(
              1.0,
              this._hue,
              this._sat,
              x,
            ).toColor(),
          ).toList()
        )
      ),
    ),
    child: AdvancedSlider(
      height: CustomColorPicker.sliderHeight,
      name: 'Value: ${(this._value*100).toInt()} %',
      value: this._value,
      max: 1.0,
      min: 0.0,
      onChanged: (double newValue) {setState(() {
        this._value = newValue;
        this._updateColorFromHsv();
        this.widget.onChanged(this._color);
      });},
      buttonDivision: 0.01,
    ),
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
}


bool checkForHexString(String input){
  RegExp _hexcolor = new RegExp(r'^#?([0-9a-fA-F]{3}|[0-9a-fA-F]{6})$');

  bool errorFound = false;
  try {
    hexToColor(input);
  } catch (e) {
    errorFound = true;
  }
  if(errorFound == true) return false;

  return _hexcolor.hasMatch(input);
}

/// Construct a color from a hex code string, of the format RRGGBB.
Color hexToColor(String hexCode) {
  return new Color(int.parse(hexCode.substring(0, 6), radix: 16) + 0xFF000000);
}
