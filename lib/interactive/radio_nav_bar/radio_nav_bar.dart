import 'package:flutter/material.dart';
import 'package:sid_ui/animated/showers/animated_listed.dart';
import 'package:sid_ui/animated/splashing_colored_background.dart';
import 'models.dart';
export 'models.dart';

class RadioNavBar<T> extends StatelessWidget {
  
  //=============================================
  // Constructor
  RadioNavBar({
    @required this.selectedValue,
    @required this.orderedValues,
    @required this.items,
    @required this.onSelect,
    this.duration = const Duration(milliseconds: 250),
    this.topPadding = 0.0,
    double tileSize = defaultTileSize,
    this.singleBackgroundColor,
    this.forceSingleColor = false,
    this.forceBrightness,
    this.accentTextColor,
    bool googleLike = false,
    Key key,
  }): shifting = RadioNavBarItem.allColoredItems(items.values) ?? false,
      tileSize = tileSize ?? defaultTileSize,
      googleLike = googleLike ?? false,
      super(key: key){
        assert(shifting != null);
      }

  // TODO: colored but not shifting? accent the selected text with color
  

  //=============================================
  // Values
  final T selectedValue;
  final List<T> orderedValues;
  final Map<T, RadioNavBarItem> items;
  final double topPadding;
  final void Function(T) onSelect;
  final bool shifting;
  final double tileSize;
  final Color singleBackgroundColor;
  final Color accentTextColor;
  static const double defaultTileSize = 56.0;
  final Duration duration;
  final bool forceSingleColor;
  final Brightness forceBrightness;
  /// "white" (canvas) background, different accent color per page
  final bool googleLike;


  static double bottomPaddingFromMQ(MediaQueryData mediaQuery)
    => (mediaQuery.padding.bottom - 8.0).clamp(0.0, double.infinity);

  //=============================================
  // Builders
  @override
  Widget build(BuildContext context) {
    final double bottomPadding = bottomPaddingFromMQ(MediaQuery.of(context));
    final double totalHeight = topPadding + bottomPadding + tileSize;
    final ThemeData theme = Theme.of(context);
    Alignment alignment;
    Color color;

    bool single;
    if(!shifting || forceSingleColor == true || googleLike){
      single = true;
      color = googleLike
        ? theme.canvasColor
        : singleBackgroundColor ?? theme.canvasColor;
      alignment = Alignment.center;
    } else {
      single = false;
      final barCenterVerticalOffset = topPadding + tileSize/2;
      final barCenterVerticalAlignment 
        = (barCenterVerticalOffset / totalHeight) * 2 - 1;
      final selectedIndex = orderedValues.indexOf(selectedValue);
      final splashHorizontalAlignment = 
        ((selectedIndex + 1) / (orderedValues.length + 1)) * 2 -1;
      alignment = Alignment(
        splashHorizontalAlignment, 
        barCenterVerticalAlignment,
      );
      color = items[selectedValue].color;
    }

    final Brightness _forcedBrightness = googleLike 
        ? null : this.forceBrightness;
    final Brightness colorBrightness = _forcedBrightness
        ?? ThemeData.estimateBrightnessForColor(color);

    final Color unselectedIconColor = colorBrightness == Brightness.light
      ? Colors.black.withOpacity(0.8) 
      : Colors.white.withOpacity(0.8);

    final Color _accentTextColor = (single && !googleLike && this.accentTextColor != null) 
      ? this.accentTextColor
      : (googleLike 
        ? items[selectedValue].color
        : null
      ) ?? unselectedIconColor.withOpacity(1.0);

    final Widget bar = IconTheme.merge(
      data: IconThemeData(color: unselectedIconColor, opacity: 1.0, size: 24.0),
      child: buildBar(_accentTextColor)
    );

    return SplashingColoredBackground(
      color,
      alignment: alignment,
      child: Material(
        type: MaterialType.transparency,
        child: Container(
          padding: EdgeInsets.only(top: topPadding, bottom: bottomPadding),
          height: totalHeight,
          child: bar,
        ),
      ),
    );

  }

  Widget buildBar(Color _accentTextColor){
    return SizedBox(
      height: this.tileSize,
      child: Row(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          for(final T value in this.orderedValues)
            ...[
              Expanded(child: InkResponse(
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                onTap: () {
                  final i = this.orderedValues.indexOf(value);
                  this.onSelect(this.orderedValues[
                    (value == this.selectedValue)
                      ? (i-1).clamp(0,this.orderedValues.length-1)
                      : i
                  ]);
                },
              )),
              _Tile(items[value], 
                accentTextColor: _accentTextColor,
                duration: duration,
                selected: value == this.selectedValue,
                onTap: () => this.onSelect(value),
                animatedIcon: !shifting,
                height: this.tileSize,
              ),
              Expanded(child: InkResponse(
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                onTap: (){
                  final i = this.orderedValues.indexOf(value);
                  this.onSelect(this.orderedValues[
                    (value == this.selectedValue)
                      ? (i+1).clamp(0,this.orderedValues.length-1)
                      : i
                  ]);
                },
              )),
            ]
        ],
      ),
    ); 
  }

}

class _Tile extends StatelessWidget {
  final RadioNavBarItem item;
  final bool selected;
  final VoidCallback onTap;
  final bool animatedIcon;
  final double height;
  final Duration duration;
  final Color accentTextColor;
  _Tile(this.item, {
    @required this.duration,
    @required this.selected,
    @required this.onTap,
    @required this.animatedIcon,
    @required this.height,
    @required this.accentTextColor,
  });

  @override
  Widget build(BuildContext context) {
    return InkResponse(
      onTap: onTap,
      containedInkWell: false,
      // radius: 60,
      highlightColor: Colors.transparent,
      child: SizedBox(
        height: height,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            _Icon(item,
              duration: duration,
              animated: animatedIcon,
              selected: selected,
              height: height,
              accentTextColor: accentTextColor,
            ),
            _Label(item,
              duration: duration,
              selected: selected,
              height: height,
              textStyle: TextStyle(
                color: accentTextColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Icon extends StatelessWidget {
  final RadioNavBarItem item;
  final bool selected;
  final bool animated;
  final double height;
  final Duration duration;
  final Color accentTextColor;
  _Icon(this.item, {
    @required this.accentTextColor,
    @required this.selected,
    @required this.animated,
    @required this.height,
    @required this.duration,
  });

  @override
  Widget build(BuildContext context) {
    if(animated && item.unselectedIcon != null){
      return Container(
        height: height,
        width: height,
        child: Stack(
          fit: StackFit.expand,
          alignment: Alignment.center,
          children: <Widget>[
            AnimatedOpacity(
              duration: duration,
              opacity: !selected ? 1.0 : 0.0,
              child: Icon(item.unselectedIcon, size: item.iconSize),
            ),
            AnimatedOpacity(
              duration: duration,
              opacity: selected ? 1.0 : 0.0,
              child: Icon(item.icon, color: accentTextColor, size: item.iconSize),
            ),
          ],
        ),
      );
    } else {
      return Container(
        height: height,
        width: height,
        child: Icon(
          selected ? item.icon : (item.unselectedIcon ?? item.icon),
          color: selected ? accentTextColor : null,
          size: item.iconSize,
        ),
      );
    }
  }
}


class _Label extends StatelessWidget {
  final RadioNavBarItem item;
  final bool selected;
  final double height;
  final Duration duration;
  final TextStyle textStyle;
  _Label(this.item, {
    @required this.duration,
    @required this.selected,
    @required this.height,
    @required this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedListed(
      duration: duration,
      listed: selected,
      overlapSizeAndOpacity: 1.0,
      curve: Curves.easeInOut,
      axis: Axis.horizontal,
      axisAlignment: -1,
      child: Padding(
        padding: const EdgeInsets.only(right: 16.0),
        child: Text(item.title, style: textStyle,),
      ),
    );
  }
}