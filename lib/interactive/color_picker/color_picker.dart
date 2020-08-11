import 'package:flutter/material.dart';
import 'color_picker_manual.dart';

import 'package:tinycolor/tinycolor.dart';

import 'models/palette.dart';
import 'color_picker_custom.dart';
import 'color_picker_palette.dart';
import 'components/simple_nav_bar.dart';

enum ColorPickerMode{
  palette,
  manual,
  custom,
}

class MaterialColorPicker extends StatefulWidget {
  final Color color;
  final Function(Color) onSubmitted;

  final void Function() underscrollCallback;

  final Widget Function({
    BuildContext context,
    void Function(ColorPickerMode) toggleMode,
    void Function() onSubmitted,
    ColorPickerMode currentMode,
    Color currentColor,
    Color currentContrast,
  }) navigatorAndSaveBuilder;

  MaterialColorPicker({
    @required this.color,
    @required this.onSubmitted,
    this.navigatorAndSaveBuilder,
    this.underscrollCallback,
  });

  @override
  State createState() => new _MaterialColorPickerState();
}

class _MaterialColorPickerState extends State<MaterialColorPicker> with TickerProviderStateMixin {

  Color _color;
  ColorPickerMode _mode = ColorPickerMode.custom;
  Widget Function({
    BuildContext context,
    void Function(ColorPickerMode) toggleMode,
    void Function() onSubmitted,
    ColorPickerMode currentMode,
    Color currentColor,
    Color currentContrast,
  }) _navigatorAndSaveBuilder;

  @override
  void initState() {
    super.initState();

    if(widget.navigatorAndSaveBuilder == null)
      this._navigatorAndSaveBuilder = defaultNavigatorAndSaveBuilder;
    else 
      this._navigatorAndSaveBuilder = widget.navigatorAndSaveBuilder;

    if(this.widget.color == null)
      this._color = Colors.red.shade500;
    else
      this._color = widget.color;
    
    if(PaletteTab.allColors.contains(this._color))
      this._mode = ColorPickerMode.palette;
    else 
      this._mode = ColorPickerMode.manual;
  }

  void toggleMode(ColorPickerMode newMode) => setState(() {
    this._mode = newMode;
    if(this._mode == ColorPickerMode.palette){
      if(PaletteTab.allColors.contains(this._color) == false){
        this._color = PaletteTab.findClosestMaterialColor(_color);
      }
    }      
  });

  void onColor(Color c) {
    setState(() {
      this._color = c;               
    });
  }

  @override
  Widget build(BuildContext context) {

    final Widget _divider = Divider(height: 0.0,);

    final Map<ColorPickerMode, Widget> _child = {
      ColorPickerMode.manual : ManualColorPicker(
        onChanged: this.onColor,
        color: this._color,
      ),
      ColorPickerMode.custom : CustomColorPicker(
        displayerUndescrollCallback: this.widget.underscrollCallback,
        color: this._color,
        onChanged: this.onColor,
      ),
      ColorPickerMode.palette : PaletteColorPicker(
        color: this._color,
        onChanged: this.onColor,
        paletteUndescrollCallback: this.widget.underscrollCallback,
      ),
    };

    return Column(
      children: <Widget>[
        Expanded(
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              return Container(
                constraints: constraints,
                child: _child[this._mode],
              );
            }
          ),
        ),
        _divider,
        this._navigatorAndSaveBuilder(
          context: context,
          toggleMode: (ColorPickerMode cm) => this.toggleMode(cm),
          onSubmitted: () => this.widget.onSubmitted(this._color),
          currentMode: this._mode,
          currentColor: this._color,
          currentContrast: ThemeData.estimateBrightnessForColor(this._color) == Brightness.dark 
            ? Colors.white 
            : Colors.black
        )
      ],
    );

  }

}

Widget defaultNavigatorAndSaveBuilder({
  BuildContext context,
  void Function(ColorPickerMode) toggleMode,
  void Function() onSubmitted,
  ColorPickerMode currentMode,
  Color currentColor,
  Color currentContrast,
}){

  Color _iconColor = TinyColor(Theme.of(context).canvasColor).isDark() ? Colors.white : Colors.black;
  Color _inactiveIconColor = _iconColor.withOpacity(0.6);

  return Material(
    child: Row(children: <Widget>[
      Expanded(child: SimpleNavBar(
        currentIndex: {
          ColorPickerMode.manual : 0,
          ColorPickerMode.custom : 1,
          ColorPickerMode.palette : 2,
        }[currentMode],
        onTap: (int i){
          toggleMode({
            0 : ColorPickerMode.manual,
            1 : ColorPickerMode.custom,
            2 : ColorPickerMode.palette,
          }[i]);
        },
        items: <SimpleItem>[
          SimpleItem(
            color: _iconColor,
            title: "Manual",
            icon: Icons.format_color_fill,
          ),
          SimpleItem(
            color: _iconColor,
            title: "Custom",
            icon: Icons.short_text,
          ),
          SimpleItem(
            color: _iconColor,
            title: "Palette",
            icon: Icons.palette
          ),
        ],
        titleStyle: TextStyle(fontWeight: FontWeight.w700),
        iconColor: _iconColor,
        inactiveIconColor: _inactiveIconColor,
      )),
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: FloatingActionButton(
          onPressed: onSubmitted,
          backgroundColor: currentColor,
          child: Icon(Icons.save, color: currentContrast,)
        ),
      ),
    ],),
  );
}
