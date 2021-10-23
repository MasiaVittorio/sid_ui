import 'package:badges/badges.dart';
import 'package:flutter/material.dart';
import 'package:sid_ui/animated/showers/animated_listed.dart';
import 'package:sid_ui/animated/splashing_colored_background.dart';
import 'models.dart';
export 'models.dart';

class RadioNavBar<T> extends StatelessWidget {
  
  //=============================================
  // Constructor
  RadioNavBar({
    required this.selectedValue,
    required this.orderedValues,
    required this.items,
    required this.onSelect,
    this.duration = const Duration(milliseconds: 250),
    this.topPadding = 0.0,
    this.tileSize = defaultTileSize,
    this.singleBackgroundColor,
    this.forceSingleColor = false,
    this.forceBrightness,
    this.accentTextColor,
    this.googleLike = false,
    this.badges,
    Key? key,
  }): shifting = RadioNavBarItem.allColoredItems(items.values) ?? false,
      assert(items.containsKey(selectedValue)),
      super(key: key);
  

  //=============================================
  // Values
  final T selectedValue;
  final List<T> orderedValues;
  final Map<T, RadioNavBarItem> items;
  final double topPadding;
  final void Function(T) onSelect;
  final bool shifting;
  final double tileSize;
  final Color? singleBackgroundColor;
  final Color? accentTextColor;
  static const double defaultTileSize = 56.0;
  final Duration duration;
  final bool forceSingleColor;
  final Brightness? forceBrightness;
  /// "white" (canvas) background, different accent color per page
  final bool googleLike;
  final Map<T, bool>? badges; // if not null, true values will show a badge over the icon


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
      color = items[selectedValue]!.color ?? theme.canvasColor;
    }

    final Brightness? _forcedBrightness = googleLike 
        ? null : this.forceBrightness;
    final Brightness colorBrightness = _forcedBrightness
        ?? ThemeData.estimateBrightnessForColor(color);

    final Color unselectedIconColor = colorBrightness == Brightness.light
      ? Colors.black.withOpacity(0.8) 
      : Colors.white.withOpacity(0.8);

    final Color _accentTextColor = (single && !googleLike && this.accentTextColor != null) 
      ? this.accentTextColor!
      : (googleLike 
        ? items[selectedValue]!.color
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
              _Tile(items[value]!, 
                badge: badges == null ? false : (badges![value] ?? false),
                accentTextColor: _accentTextColor,
                duration: duration,
                selected: value == this.selectedValue,
                onTap: () => this.onSelect(value),
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
  final double height;
  final Duration duration;
  final Color accentTextColor;
  final bool badge;
  _Tile(this.item, {
    required this.badge,
    required this.duration,
    required this.selected,
    required this.onTap,
    required this.height,
    required this.accentTextColor,
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
            Badge(
              showBadge: badge && !selected,
              badgeContent: null,
              toAnimate: false,
              shape: BadgeShape.circle,
              // alignment: Alignment.topRight,
              badgeColor: Theme.of(context).colorScheme.secondary,
              position: BadgePosition.topEnd(top: 8, end: 8),
              ignorePointer: true,
              child: _Icon(item,
                duration: duration,
                selected: selected,
                height: height,
                accentColor: accentTextColor,
              ),
            ),/// TODO: something breaks when altering the accent 
              /// on stage, seems to be here but idk wtf
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
  final double height;
  final Duration duration;
  final Color accentColor;
  _Icon(this.item, {
    required this.accentColor,
    required this.selected,
    required this.height,
    required this.duration,
  });

  static const double _defaultIconSize = 24;

  @override
  Widget build(BuildContext context) {
    final double size = item.iconSize 
    ?? IconTheme.of(context).size
    ?? _defaultIconSize;

    if(item.unselectedIcon != null){
      return Container(
        height: height,
        width: height,
        alignment: Alignment.center,
        child: Stack(
          fit: StackFit.expand,
          clipBehavior: Clip.hardEdge,
          alignment: Alignment.center,
          children: <Widget>[
            Positioned.fill(child: Center(child: SizedBox(
              height: size,
              width: size,
              child: IgnorePointer(
                ignoring: selected,
                child: AnimatedOpacity(
                  duration: duration,
                  opacity: !selected ? 1.0 : 0.0,
                  child: Icon(item.unselectedIcon!, size: size),
                ),
              ),
            ))),
            Positioned.fill(child: Center(child: SizedBox(
              height: size,
              width: size,
              child: IgnorePointer(
                ignoring: !selected,
                child: AnimatedOpacity(
                  duration: duration,
                  opacity: selected ? 1.0 : 0.0,
                  child: Icon(item.icon, color: accentColor, size: size),
                ),
              ),
            ))),
          ],
        ),
      );
    } else {
      return Container(
        height: height,
        width: height,
        alignment: Alignment.center,
        child: Icon(
          selected ? item.icon : (item.unselectedIcon ?? item.icon),
          color: selected ? accentColor : null,
          size: size,
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
    required this.duration,
    required this.selected,
    required this.height,
    required this.textStyle,
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