import 'package:flutter/material.dart';
import 'package:sid_utils/sid_utils.dart';

class FullSlider extends StatefulWidget {

  final Widget leading;
  final Widget Function(double) leadingBuilder;

  final Widget title;
  final Widget Function(double) titleBuilder;

  final Widget trailing;
  final Widget Function(double) trailingBuilder; // if there is the builder, the single widget is ignored

  final double defaultValue; //if not null, a reset button will be displayed
  final double value;
  final ValueChanged<double> onChanged;
  // final ValueChanged<double> onChangeStart;
  final ValueChanged<double> onChangeEnd;

  final double min;
  final double max;

  /// number of divisions, after each gesture the value is adjusted to the nearest division
  /// tap right to += by a division, tap left to -= by a division. if null, taps are ignored
  final int divisions; 

  final double crossAxisSize;

  final Axis scrollDirection;

  final double radius;

  final Color accentColor;

  final bool enabled;

  const FullSlider({
    @required this.value,
    this.onChangeEnd,
    // this.onChangeStart,
    this.onChanged,
    this.defaultValue,
    this.min = 0.0,
    this.max = 1.0,

    this.divisions,

    this.enabled = true,

    this.leading,
    this.trailing,
    this.title,
    this.leadingBuilder,
    this.trailingBuilder,
    this.titleBuilder,

    this.accentColor,

    this.crossAxisSize = 56.0,
    this.scrollDirection = Axis.horizontal,
    this.radius = 8.0,
  }): assert(min != null),
      assert(max != null),
      assert(max > min),
      assert(crossAxisSize != null),
      assert(scrollDirection != null),
      assert(radius != null),
      
      assert(value != null);

  @override
  _FullSliderState createState() => _FullSliderState();
}


class _FullSliderState extends State<FullSlider> with SingleTickerProviderStateMixin {

  AnimationController controller;
  double _prevTapTarget;

  @override
  void initState() {
    super.initState();
    initController();
  }

  void initController(){
    controller?.dispose();
    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250), 
      value: widgetToAnimation(widget.value),
    );
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(FullSlider oldWidget) {
    super.didUpdateWidget(oldWidget);
    if(oldWidget.value != widget.value){
      controller.value =  widgetToAnimation(widget.value);
    }
    if(oldWidget.min != widget.min || oldWidget.max != widget.max){
      initController();
    }
  }

  double widgetToAnimation(double widgetValue) => widgetValue.mapToRange(0.0, 1.0, fromMin: widget.min, fromMax: widget.max);

  double animationToWidget(double animationValue) => animationValue.mapToRange(widget.min, widget.max);

  static const double _marginMain = 16.0;
  static const double _marginCross = 8.0; 
  EdgeInsets get margin => EdgeInsets.symmetric(
    horizontal: horizontal ? _marginMain : _marginCross, 
    vertical: vertical ? _marginMain : _marginCross, 
  );
  static const Widget _separator = SizedBox(width: _marginMain, height: _marginMain,);

  bool get horizontal => widget.scrollDirection == Axis.horizontal;
  bool get vertical => widget.scrollDirection == Axis.vertical;

  Widget buildAnimated(Widget Function(double) builder) => AnimatedBuilder(
    animation: controller, 
    builder: (_,__) => builder(this.animationToWidget(controller.value)),
  );

  bool get withTitle => widget.title != null || widget.titleBuilder != null;
  bool get withLeading => widget.leading != null || widget.leadingBuilder != null;
  bool get withTrailing => widget.trailing != null || widget.trailingBuilder != null;

  bool get disabled => !(widget.enabled ?? true);

  double get dividedControllerValue => (controller.value*widget.divisions).round()/widget.divisions;

  @override
  Widget build(BuildContext context) {
    
    final Alignment aligment = horizontal ? Alignment.centerLeft : Alignment.bottomCenter;

    final ThemeData themeData = Theme.of(context);
    final Color background = Color.alphaBlend(
      themeData.scaffoldBackgroundColor.withOpacity(0.7),
      themeData.canvasColor, // this widget is intended to be put over a material background
    );
    final Color accentColor = Color.alphaBlend(
      widget.accentColor ?? themeData.accentColor.withOpacity(disabled ? 0.17 : 0.2), 
      background,
    );
    final Color onBackgroundColor = themeData.colorScheme.onSurface.withOpacity(
      disabled ? 0.6 : 1.0,
    );
    final Color onAccentColor = accentColor.contrast.withOpacity(
      disabled ? 0.6 : 1.0,
    );

    final Widget slider = SizedBox(
      width: vertical ? widget.crossAxisSize : null,
      height: horizontal ? widget.crossAxisSize : null,
      child: LayoutBuilder(builder: (_, constraints) {

        final double delta = vertical ? constraints.maxHeight : constraints.maxWidth;

        final Widget content = ConstrainedBox(
          constraints: constraints,
          child: Flex(
            verticalDirection: VerticalDirection.up,
            direction: widget.scrollDirection,
            children: <Widget>[
              if(withLeading) Container(
                height: widget.crossAxisSize,
                width: widget.crossAxisSize,
                alignment: Alignment.center,
                child: widget.leadingBuilder != null 
                  ? buildAnimated(widget.leadingBuilder)
                  : widget.leading,
              ) else Container(),

              if(withTitle) Expanded(child: Align(
                alignment: horizontal ? Alignment.centerLeft : Alignment.bottomCenter,
                child: widget.titleBuilder != null 
                  ? buildAnimated(widget.titleBuilder)
                  : widget.title,
              ),),

              if(withTrailing) Container(
                height: widget.crossAxisSize,
                width: widget.crossAxisSize,
                alignment: Alignment.center,
                child: widget.trailingBuilder != null
                  ? buildAnimated(widget.trailingBuilder)
                  : widget.trailing,
              ) else Container()
            ].separateWith(_separator),
          ),
        );

        final Widget topContent = Container(
          color: accentColor,
          child: DefaultTextStyle.merge(
            style: TextStyle(
              color: onAccentColor,
            ),
            child: IconTheme.merge(
              data: IconThemeData(opacity: 1.0, color: onAccentColor), 
              child: content,
            ),
          ),
        );

        final Widget bottomContent = DefaultTextStyle.merge(
          style: TextStyle(
            color: onBackgroundColor,
          ),
          child: IconTheme.merge(
            data: IconThemeData(opacity: 1.0, color: onBackgroundColor), 
            child: content,
          ),
        );

        return ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: horizontal ? constraints.maxWidth : widget.crossAxisSize,
            maxHeight: vertical ? constraints.maxHeight : widget.crossAxisSize,
          ),
          child: GestureDetector(
            onHorizontalDragUpdate: disabled || vertical ? null : (details) => dragUpdate(details, delta - widget.crossAxisSize),
            onVerticalDragUpdate: disabled || horizontal ? null : (details) => dragUpdate(details, delta - widget.crossAxisSize),
            onHorizontalDragEnd: disabled || vertical ? null : (_) => dragEnd(),
            onVerticalDragEnd: disabled || horizontal ? null : (_) => dragEnd(),
            onHorizontalDragCancel: disabled || vertical || widget.divisions != null ? null : dragEnd,
            onVerticalDragCancel: disabled || horizontal || widget.divisions != null ? null : dragEnd,
            onTapUp: disabled || widget.divisions == null ? null : (d) => tap(d, constraints),
            child: Stack(children: <Widget>[
              Positioned.fill(child: Container(
                decoration: BoxDecoration(
                  color: background, 
                  // color: themeData.colorScheme.onSurface.withOpacity(0.034), 
                  borderRadius: BorderRadius.circular(widget.radius),
                ),
                child: bottomContent,
              )),
              Positioned.fill(child: Align(
                alignment: aligment,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(widget.radius),
                  child: AnimatedBuilder(
                    animation: controller, 
                    builder: (_,__) {
                      final double val = controller.value;
                      return Align(
                        alignment: aligment,
                        widthFactor: horizontal ? val.mapToRange(widget.crossAxisSize / delta, 1.0) : null,
                        heightFactor: vertical ? val.mapToRange(widget.crossAxisSize / delta, 1.0) : null,
                        child: topContent,
                      );
                    },
                  ),
                ),
              ),),
            ],),
          ),
        );
      },),
    );

    if(widget.defaultValue == null) return Padding(
      padding: margin,
      child: slider,
    );

    final Widget reset = SizedBox(
      width: widget.crossAxisSize,
      height: widget.crossAxisSize,
      child: IconButton(
        icon: Icon(Icons.restore),
        onPressed: (){
          _prevTapTarget = null;
          controller.animateTo(
            widgetToAnimation(widget.defaultValue), 
            duration: const Duration(milliseconds: 250), 
            curve: Curves.ease,
          ).then((_){
            widget.onChanged?.call(widget.defaultValue);
            widget.onChangeEnd?.call(widget.defaultValue);
          });
        },
      ),
    );

    return Padding(
      padding: margin,
      child: Flex(
        verticalDirection: VerticalDirection.up,
        direction: widget.scrollDirection,
        children: <Widget>[
          Expanded(child: slider),
          reset,
        ].separateWith(_separator),
      ),
    );
  }

  void dragUpdate(DragUpdateDetails details, double max){
    _prevTapTarget = null;
    controller.value += details.primaryDelta / max;
    widget.onChanged?.call(animationToWidget(controller.value));
  }

  void dragEnd() async {
    if(!mounted) return;

    if(widget.divisions != null) {
      await this.controller.animateTo(
        dividedControllerValue,
        duration: const Duration(milliseconds: 250),
      );
    }
    _prevTapTarget = null;
    final double widgetVal = animationToWidget(controller.value);
    widget.onChanged?.call(widgetVal);
    widget.onChangeEnd?.call(widgetVal);
  }

  void tap(TapUpDetails details, BoxConstraints constraints) async {
    final double by = 1/widget.divisions;
    final double prev = _prevTapTarget ?? controller.value;

    
    if(details.localPosition.dx > (horizontal ? constraints.maxWidth : constraints.maxHeight)/2){
      _prevTapTarget = (prev + by).clamp(0.0, 1.0);
    } else {
      _prevTapTarget = (prev - by).clamp(0.0, 1.0);
    }
    await controller.animateTo(
      _prevTapTarget,
      duration: const Duration(milliseconds: 250), 
    );
    dragEnd();
  }

}

