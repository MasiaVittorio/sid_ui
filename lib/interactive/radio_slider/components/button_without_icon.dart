part of radio_slider;


class _ButtonWithoutIcon extends StatelessWidget {

  _ButtonWithoutIcon({
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
        AnimatedCrossFade(
          duration: this.duration,
          crossFadeState: isShowing
            ? CrossFadeState.showFirst
            : CrossFadeState.showSecond,
          firstChild: Container(
            height: height,
            width: width,
            alignment: Alignment.center,
            child: DefaultTextStyle.merge(
              style: TextStyle(
                color: this.selectedColor 
                  ?? radioTheme?.selectedColor
                    ?? theme?.textTheme?.bodyText2?.color,
              ),
              child: item.title
            )
          ),
          secondChild: Container(
            height: height,
            width: width,
            alignment: Alignment.center,
            child: IconTheme.merge(
              data: IconThemeData(
                color: theme?.unselectedWidgetColor,
              ),
              child: item.icon
            ),
          ),      
        ),
      ],
    );
  }
}
