part of radio_slider;

extension on _RadioSliderState {

  double indexVal(int index) => index / (n - 1);

  int get nearestIndex => (_animation!.value * (n - 1)).round();
  int get nearestIndexFloor => (_animation!.value * (n - 1)).floor();
  int get nearestIndexCeil => (_animation!.value * (n - 1)).ceil();

  // double get roundVal => indexVal(nearestIndex);
  // double get ceilVal => indexVal(nearestIndexCeil);
  // double get floorVal => indexVal(nearestIndexFloor);

  int get n => widget.items.length;

  double sliderWidth(double max) => max / n;

  double maxSpace(double max) => max - sliderWidth(max);
  double position(double max) => _animation!.value * maxSpace(max);

  // double get maxValDistanceFromIndex => 1 / (n );

  // double distanceFromIndex(int index) => (_animation.value - indexVal(index)).abs();

  // double normalizedDistanceFromIndex(int index) => math.min(
  //   1, 
  //   distanceFromIndex(index) / maxValDistanceFromIndex,
  // );

  double height(RadioSliderThemeData? radioTheme) => widget.height ?? radioTheme?.height ?? RadioSlider._kHeight;
  EdgeInsets margin(RadioSliderThemeData? radioTheme) => widget.margin ?? radioTheme?.margin ?? RadioSlider._kMargin;


}
