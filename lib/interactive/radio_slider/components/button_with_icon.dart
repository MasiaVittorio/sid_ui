part of radio_slider;

class _ButtonWithIcon extends StatelessWidget {

  _ButtonWithIcon({
    @required this.selectedColor,
    @required this.item,
    @required this.isShowing,
    @required this.duration,
    @required this.height,
    @required this.width,
  });

  final double height;
  final double width;

  final Duration duration;
  final Color selectedColor;
  final bool isShowing;
  final RadioSliderItem item;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final RadioSliderThemeData radioTheme = RadioSliderTheme.of(context);

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Container(
          height: height,
          width: height,
          alignment: Alignment.center,
          child: AnimatedCrossFade(
            crossFadeState: isShowing
              ? CrossFadeState.showFirst
              : CrossFadeState.showSecond,
            firstChild: IconTheme.merge(
              data: IconThemeData(
                color: this.selectedColor 
                  ?? radioTheme?.selectedColor,
                opacity: this.selectedColor?.opacity
                  ?? radioTheme?.selectedColor?.opacity
              ),
              child: item.selectedIcon ?? item.icon,
            ), 
            secondChild: IconTheme.merge(
              data: IconThemeData(
                color: theme?.unselectedWidgetColor,
              ),
              child: item.icon
            ),
            duration: this.duration,
          
          ),
        ),
        AnimatedListed(
          overlapSizeAndOpacity: 0.9,
          duration: this.duration,
          listed: isShowing,
          axis: Axis.horizontal,
          child: Container(
            height: height,
            width: width - height,
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.only(left: 4.0),
            child: DefaultTextStyle.merge(
              style: theme.textTheme.button.copyWith(
                color: this.selectedColor 
                  ?? radioTheme?.selectedColor
                    ?? theme?.textTheme?.bodyText2?.color,
              ),
              child: item.title
            ),
          ),
          axisAlignment: -1.0,
          curve: Curves.fastOutSlowIn,
        ),
      ],
    );
  }
}

