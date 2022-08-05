import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:sid_ui/animated/showers/animated_clipper.dart';

const double _kBottomMargin = 8.0;

const Duration _myDuration = Duration(milliseconds: 200);
const double _tileSize = 48.0;

class SimpleNavBar extends StatelessWidget {
  SimpleNavBar({
    Key? key,
    required this.items,
    this.onTap,
    this.currentIndex = 0,
    this.iconSize = 24.0,
    this.duration = _myDuration,
    this.titleStyle,
    this.iconColor,
    this.inactiveIconColor,
    this.height = kBottomNavigationBarHeight,
  }): assert(items.length >= 2),
      assert(
        items.every(
          (SimpleItem item) => item.title != null
        ),
        'Every item must have a non-null title',
      ),
      assert(0 <= currentIndex && currentIndex < items.length),
      super(key: key);

  final List<SimpleItem> items;
  final ValueChanged<int>? onTap; //stream ? or listener ? callbacks dude
  final int   currentIndex;
  final double iconSize;
  final Duration duration;

  final TextStyle? titleStyle;
  final Color? iconColor;
  final Color? inactiveIconColor;
  final double height;

  @override
  Widget build(BuildContext context) {
    final double additionalBottomPadding = math.max(
      MediaQuery.of(context).padding.bottom - _kBottomMargin, 
      0.0,
    );

    return Padding(
      padding: EdgeInsets.only(
        right: 10,
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
            minHeight: this.height + additionalBottomPadding),
        child: Material(
          type: MaterialType.transparency,
          child: Padding(
            padding: EdgeInsets.only(
              bottom: additionalBottomPadding,
            ),
            child: MediaQuery.removePadding(
              context: context,
              removeBottom: true,
              child: _createContainer(_createTiles()),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _createTiles() {
    final List<Widget> children = <Widget>[];

    for (int i = 0; i < this.items.length; i += 1) {

      bool _selI = i == this.currentIndex;

      void Function() _onTapI =  () {
        if (this.onTap != null) this.onTap!(i);
      };
      void Function() _onTapPrev =  () {
        if (this.onTap != null) {
          if(_selI) this.onTap!(i == 0 ? i : i-1);
          else this.onTap!(i);
        }
      };
      void Function() _onTapNext =  () {
        if (this.onTap != null) {
          if(_selI) this.onTap!(i == this.items.length-1 ? i : i+1);
          else this.onTap!(i);
        }
      };
      children.add(Expanded(child: InkResponse(
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        onTap: _onTapPrev,
      )));
      children.add(
        _SimpleTile(
          this.items[i],
          this.iconSize,
          titleStyle: this.titleStyle,
          duration: this.duration,
          onTap: _onTapI,
          iconColor: this.iconColor,
          selected: _selI,
          inactiveIconColor: this.inactiveIconColor,
          height: this.height,
        ),
      );
      children.add(Expanded(child: InkResponse(
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        onTap: _onTapNext,
      )));
    }
    return children;
  }

  Widget _createContainer(List<Widget> tiles) {
    return DefaultTextStyle.merge(
      overflow: TextOverflow.ellipsis,
      child: Container(
        constraints: BoxConstraints(maxHeight: this.height),
        child: Row(
          children: tiles,
        ),
      ),
    );
  }

}



class _SimpleTile extends StatelessWidget {
  const _SimpleTile(
    this.item,
    this.iconSize, 
    {
      this.onTap,
      this.selected = false,
      // ignore: unused_element
      this.indexLabel,
      this.titleStyle,
      required this.duration,
      required this.height,
      required this.iconColor,
      required this.inactiveIconColor,
    }
  );

  final double height;
  final TextStyle? titleStyle;
  final Duration duration;
  final SimpleItem item;
  final double iconSize;
  final VoidCallback? onTap;
  final bool selected;
  final String? indexLabel;
  final Color? iconColor;
  final Color? inactiveIconColor;

  @override
  Widget build(BuildContext context) {

    final Widget _label = Text(
      item.title!,
      style: this.titleStyle?.copyWith(color: item.color),
    );

    return Semantics(
      container: true,
      header: true,
      selected: selected,
      child: InkResponse(
        // splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        containedInkWell: false,
        onTap: onTap,
        child: Container(
          height: this.height,
          color: Colors.transparent,
          alignment: Alignment.center,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              _TileIcon(
                duration: duration,
                iconSize: iconSize,
                selected: selected,
                iconColor: this.iconColor,
                inactiveIconColor: this.inactiveIconColor,
                item: item,
              ),
              AnimatedClipper(
                alsoFade: true,
                childAlignment: Alignment.centerLeft,
                child: _label,
                clip: !selected,
                axis: Axis.horizontal,
                axisAlignment: -1.0,
                duration: duration,
                curve: Curves.fastOutSlowIn,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TileIcon extends StatelessWidget {
  const _TileIcon({
    Key? key,
    required this.iconSize,
    required this.selected,
    required this.item,
    required this.duration,
    required this.iconColor,
    required this.inactiveIconColor,
  }) : super(key: key);

  final Duration duration;
  final double iconSize;
  final bool selected;
  final SimpleItem item;
  final Color? iconColor;
  final Color? inactiveIconColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: _tileSize,
      width: _tileSize,
      child: Center(
        child: IconTheme(
          data: IconThemeData(
            size: iconSize,
          ),
          child: AnimatedCrossFade(
            firstChild: Icon(item.activeIcon, color: item.color ),
            secondChild: Icon(item.icon, color: this.inactiveIconColor),
            crossFadeState: selected ? CrossFadeState.showFirst : CrossFadeState.showSecond,
            duration: this.duration 
          ),
        ),
      ),
    );
  }
}


class SimpleItem {
  const SimpleItem({
    required this.icon,
    this.title,
    IconData? activeIcon,
    required this.color,
  }): activeIcon = activeIcon ?? icon;
  
  final IconData icon;
  final IconData activeIcon;
  final String? title;
  final Color color;
}
