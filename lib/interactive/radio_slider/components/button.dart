part of radio_slider;


class _Button extends StatelessWidget {

  _Button({
    @required this.withIcon,
    @required this.selectedColor,
    @required this.item,
    @required this.isShowing,
    @required this.duration,
    @required this.height,
    @required this.width,
  });

  final bool withIcon;

  final double height;
  final double width;

  final Duration duration;
  final Color selectedColor;
  final bool isShowing;
  final RadioSliderItem item;

  @override
  Widget build(BuildContext context) {
    if(withIcon){
      return _ButtonWithIcon(
        selectedColor: selectedColor, 
        item: item, 
        isShowing: isShowing, 
        duration: duration, 
        height: height, 
        width: width,
      );
    } else {
      return _ButtonWithoutIcon(
        selectedColor: selectedColor, 
        item: item, 
        isShowing: isShowing, 
        duration: duration, 
        height: height, 
        width: width,
      );
    }
  }
}

