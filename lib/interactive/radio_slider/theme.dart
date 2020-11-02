part of radio_slider;


class RadioSliderThemeData {
  Color selectedColor;
  Color backgroundColor;
  bool hideOpenIcons;
  double height;
  EdgeInsets margin;
  bool elevateSlider;
  RadioSliderThemeData({
    this.elevateSlider = RadioSlider._kElevateSlider,
    this.selectedColor,
    this.backgroundColor,
    this.hideOpenIcons = false,
    this.height = RadioSlider._kHeight,
    this.margin = RadioSlider._kMargin,
  });

  RadioSliderThemeData mergeWith(RadioSliderThemeData other) 
    => RadioSliderThemeData(
      elevateSlider: other?.elevateSlider ?? this.elevateSlider 
        ?? RadioSlider._kElevateSlider,
      selectedColor: other?.selectedColor ?? this.selectedColor,
      backgroundColor: other?.backgroundColor ?? this.backgroundColor,      
      hideOpenIcons: other?.hideOpenIcons ?? this.hideOpenIcons,      
      height: other?.height ?? this.height ?? RadioSlider._kHeight,      
      margin: other?.margin ?? this.margin ?? RadioSlider._kMargin,
    );
  
}

class RadioSliderTheme extends StatefulWidget {
  RadioSliderTheme({
    Key key,
    @required this.child,
    @required this.data,
  }): super(key: key);

  final Widget child;
  final RadioSliderThemeData data;

  @override
  _RadioSliderThemeState createState() => _RadioSliderThemeState();

  static RadioSliderThemeData of(BuildContext context){
    _RadioSliderThemeInherited provider = 
      context.getElementForInheritedWidgetOfExactType<_RadioSliderThemeInherited>()?.widget;
    return provider?.data;
  }

  static Widget merge({
    @required RadioSliderThemeData data,
    @required Widget child,
  }) => Builder(builder: (context) => RadioSliderTheme(
    data: RadioSliderTheme.of(context)?.mergeWith(data) ?? data,
    child: child,
  ),);

}

class _RadioSliderThemeState extends State<RadioSliderTheme>{
  
  @override
  Widget build(BuildContext context){
    return _RadioSliderThemeInherited(
      data: widget.data,
      child: widget.child,
    );
  }
}

class _RadioSliderThemeInherited extends InheritedWidget {
  _RadioSliderThemeInherited({
    Key key,
    @required Widget child,
    @required this.data,
  }) : super(key: key, child: child);

  final RadioSliderThemeData data;

  @override
  bool updateShouldNotify(_RadioSliderThemeInherited oldWidget) => false;
}