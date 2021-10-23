part of radio_slider;


class _VisualSlider extends StatelessWidget {

  _VisualSlider({
    required this.height,
    required this.width,
    required this.elevate,
  });

  final double height;
  final double width;
  final bool elevate;
  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    if(elevate){
      return Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          color: theme.canvasColor,
          borderRadius: BorderRadius.circular(_RadioSliderState._radius),
          boxShadow: <BoxShadow>[
            BoxShadow(
              blurRadius: 3,
              color: const Color(0x59000000),
              offset: Offset(0,0.5),
            ),
          ],
        ),
      );
    } else {
      return Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          color: theme.colorScheme.secondary.withOpacity(0.2),
          borderRadius: BorderRadius.circular(_RadioSliderState._radius),
        ),
      );
    }

  }
}

