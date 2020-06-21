import 'package:flutter/material.dart';

class BorderRoundSliderThumbShape extends SliderComponentShape {
  /// Create a slider thumb that draws a circle.
  const BorderRoundSliderThumbShape({
    this.enabledThumbRadius = 6.0,
    this.disabledThumbRadius,
    this.border,
    this.borderColor,
  });


  final Color borderColor;
  final double border;
  /// The preferred radius of the round thumb shape when the slider is enabled.
  ///
  /// If it is not provided, then the material default is used.
  final double enabledThumbRadius;

  /// The preferred radius of the round thumb shape when the slider is disabled.
  ///
  /// If no disabledRadius is provided, then it is is derived from the enabled
  /// thumb radius and has the same ratio of enabled size to disabled size as
  /// the Material spec. The default resolves to 4, which is 2 / 3 of the
  /// default enabled thumb.
  final double disabledThumbRadius;

  double get _disabledThumbRadius =>  disabledThumbRadius ?? enabledThumbRadius * 2 / 3;

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return Size.fromRadius(isEnabled ? enabledThumbRadius : _disabledThumbRadius);
  }

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    Animation<double> activationAnimation,
    Animation<double> enableAnimation,
    bool isDiscrete,
    TextPainter labelPainter,
    RenderBox parentBox,
    SliderThemeData sliderTheme,
    TextDirection textDirection,
    double value,
  }) {
    final Canvas canvas = context.canvas;
    final Tween<double> radiusTween = Tween<double>(
      begin: _disabledThumbRadius,
      end: enabledThumbRadius,
    );
    final ColorTween colorTween = ColorTween(
      begin: sliderTheme.disabledThumbColor,
      end: sliderTheme.thumbColor,
    );
    canvas.drawCircle(
      center,
      radiusTween.evaluate(enableAnimation),
      Paint()..color = colorTween.evaluate(enableAnimation),
    );
    canvas.drawCircle(
      center,
      radiusTween.evaluate(enableAnimation),
      Paint()
        ..color = this.borderColor ?? Colors.black
        ..style = PaintingStyle.stroke
        ..strokeWidth = this.border ?? 2
    );
  }
}
