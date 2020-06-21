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