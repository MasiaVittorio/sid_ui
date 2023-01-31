import 'package:flutter/material.dart';


class ShadeRectangularSliderTrackShape extends SliderTrackShape {
  /// Create a slider track that draws 2 rectangles.
  const ShadeRectangularSliderTrackShape({ this.disabledThumbGapWidth = 2.0, this.gradient});

  final Gradient? gradient;

  /// Horizontal spacing, or gap, between the disabled thumb and the track.
  ///
  /// This is only used when the slider is disabled. There is no gap around
  /// the thumb and any part of the track when the slider is enabled. The
  /// Material spec defaults this gap width 2, which is half of the disabled
  /// thumb radius.
  final double disabledThumbGapWidth;

  @override
  Rect getPreferredRect({
    required RenderBox parentBox,
    Offset offset = Offset.zero,
    required SliderThemeData sliderTheme,
    bool isEnabled = true, /// this should be required, not default true, but the underlying flutter code is a mess idk
    bool isDiscrete = true, /// this should be required, not default true, but the underlying flutter code is a mess idk
  }) {
    final double overlayWidth = sliderTheme.overlayShape!.getPreferredSize(isEnabled, isDiscrete).width;
    final double trackHeight = sliderTheme.trackHeight!;
    assert(overlayWidth >= 0);
    assert(trackHeight >= 0);
    assert(parentBox.size.width >= overlayWidth);
    assert(parentBox.size.height >= trackHeight);

    final double trackLeft = offset.dx + overlayWidth / 2;
    final double trackTop = offset.dy + (parentBox.size.height - trackHeight) / 2;
    // c'era un todo di google
    final double trackWidth = parentBox.size.width - overlayWidth;
    return Rect.fromLTWH(trackLeft, trackTop, trackWidth, trackHeight);
  }


  @override
  void paint(
    PaintingContext context,
    Offset offset, {
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required Animation<double> enableAnimation,
    required Offset thumbCenter,
    Offset? secondaryOffset,
    bool? isEnabled,
    bool? isDiscrete,
    required TextDirection textDirection,
  }) {
    // If the slider track height is 0, then it makes no difference whether the
    // track is painted or not, therefore the painting can be a no-op.
    if (sliderTheme.trackHeight == 0) {
      return;
    }

    // Assign the track segment paints, which are left: active, right: inactive,
    // but reversed for right to left text.
    final ColorTween activeTrackColorTween = ColorTween(begin: sliderTheme.disabledActiveTrackColor , end: sliderTheme.activeTrackColor);
    final ColorTween inactiveTrackColorTween = ColorTween(begin: sliderTheme.disabledInactiveTrackColor , end: sliderTheme.inactiveTrackColor);
    final Paint activePaint = Paint()..color = activeTrackColorTween.evaluate(enableAnimation)!;
    final Paint inactivePaint = Paint()..color = inactiveTrackColorTween.evaluate(enableAnimation)!;
    late Paint leftTrackPaint;
    late Paint rightTrackPaint;
    switch (textDirection) {
      case TextDirection.ltr:
        leftTrackPaint = activePaint;
        rightTrackPaint = inactivePaint;
        break;
      case TextDirection.rtl:
        leftTrackPaint = inactivePaint;
        rightTrackPaint = activePaint;
        break;
      default: 
        leftTrackPaint = activePaint;
        rightTrackPaint = inactivePaint;
        break;
    }

    // Used to create a gap around the thumb iff the slider is disabled.
    // If the slider is enabled, the track can be drawn beneath the thumb
    // without a gap. But when the slider is disabled, the track is shortened
    // and this gap helps determine how much shorter it should be.
    // c'era un todo di google
    double horizontalAdjustment = 0.0;
    if (!isEnabled!) {
      final double disabledThumbRadius = sliderTheme.thumbShape!.getPreferredSize(false, isDiscrete!).width / 2.0;
      final double gap = disabledThumbGapWidth * (1.0 - enableAnimation.value);
      horizontalAdjustment = disabledThumbRadius + gap;
    }

    final Rect trackRect = getPreferredRect(
        parentBox: parentBox,
        offset: offset,
        sliderTheme: sliderTheme,
        isEnabled: isEnabled,
        isDiscrete: isDiscrete!,
    );

    if(this.gradient == null){
      final Rect leftTrackSegment = Rect.fromLTRB(trackRect.left, trackRect.top, thumbCenter.dx - horizontalAdjustment, trackRect.bottom);
      context.canvas.drawRect(leftTrackSegment, leftTrackPaint);
      final Rect rightTrackSegment = Rect.fromLTRB(thumbCenter.dx + horizontalAdjustment, trackRect.top, trackRect.right, trackRect.bottom);
      context.canvas.drawRect(rightTrackSegment, rightTrackPaint);
    }
    else {
      context.canvas.drawRect(trackRect, Paint()..shader = this.gradient!.createShader(trackRect));
    }
  }
}
