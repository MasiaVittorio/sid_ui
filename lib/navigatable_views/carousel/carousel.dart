import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:sid_ui/animated/splashing_colored_background.dart';
import 'package:sid_ui/decorations/up_shadower.dart';

export 'item_builder.dart';

typedef PositionedItemBuilder = Widget Function({
  @required BuildContext context, 
  @required int itemIndex, 
  @required double pageValue,
  @required double totalHeight,
  @required double width,
  @required CarouselController controller,
});

const Duration _kCarouselDuration = const Duration(milliseconds: 200);
const Color _kBarrier = Colors.black12;

class _Carousel extends StatefulWidget {

  const _Carousel({
    Key key,
    @required this.routeAnimationController,

    @required this.itemCount,
    @required this.initialIndex,
    @required this.positionedItemBuilder,

    @required this.widthFraction,

    @required this.backgroundColor,
    @required this.splashAnimateColor,
    @required this.animateColor,

    @required this.collapsedBuilder,
    @required this.collapsedSize,

    @required this.extendedBuilder,
    @required this.extendedSize,

    @required this.parallaxEffect,
  }): assert(positionedItemBuilder != null),
      assert(widthFraction != null),
      assert(widthFraction > 1/3 && widthFraction <= 1),
      super(key: key);
  
  final AnimationController routeAnimationController;

  final PositionedItemBuilder positionedItemBuilder;
  final int itemCount;
  final int initialIndex;

  final double widthFraction;

  final Widget Function(int, CarouselController) collapsedBuilder;
  final double collapsedSize;
  final Widget Function(int, CarouselController) extendedBuilder;
  final double extendedSize;
  final double parallaxEffect;

  final Color Function(int) backgroundColor;
  final bool animateColor;
  final bool splashAnimateColor;

  @override
  _CarouselState createState() => _CarouselState();

}

class CarouselController {
  CarouselController();

  void Function(int) _jumpTo;
  void Function(int) _animateTo;
  VoidCallback _open;
  VoidCallback _close;
  int Function() _n;
  double Function() _horizontalValue;
  double Function() _verticalValue;

  addListeners(
    void Function(int) __jumpTo,
    void Function(int) __animateTo,
    VoidCallback __open,
    VoidCallback __close,
    double Function() __horizontalValue,
    double Function() __verticalValue,
    int Function() __n,
  ){
    _jumpTo = __jumpTo;
    _animateTo = __animateTo;
    _close = __close;
    _open = __open;
    _horizontalValue = __horizontalValue;
    _verticalValue = __verticalValue;
    _n = __n;
  }

  void jumpTo(int index){
    if(_jumpTo != null) _jumpTo(index);
  }
  void animateTo(int index){
    if(_animateTo != null) _animateTo(index);
  }
  void open(){
    if(_open != null) _open();
  }
  void close(){
    if(_close != null) _close();
  }

  double horizontalValue(){
    if(_horizontalValue != null)
      return _horizontalValue();
    return null;
  }
  double verticalValue(){
    if(_verticalValue != null)
      return _verticalValue();
    return null;
  }
  int n(){
    if(_n != null) return _n();
    return null;
  }

  int currentIndex(){
    double v = horizontalValue();
    if(v == null)
      return null;
    return v.round();
  }

  void stepBy(int step){
    if(_animateTo == null)
      return;

    final int items = n();
    if(items == null)
      return;

    final int current = currentIndex(); 
    if(current == null)
      return;
    
    _animateTo((current + step).clamp(0, items - 1));
  }

  void nextItem() => stepBy(1);
  void previousItem() => stepBy(-1);

} 

class _CarouselState extends State<_Carousel> with TickerProviderStateMixin {

  AnimationController _horizontalController;
  AnimationController _verticalController;
  Color _color;
  CarouselController _carouselController;

  @override
  void initState() {
    this._resetController();
    _color = _backgroundColor(widget.initialIndex);
    _carouselController = CarouselController();
    _carouselController.addListeners(
      _jumpTo,
      _animateTo,
      _open,
      _close,
      () => _horizontalController.value,
      () => _verticalController.value,
      () => widget.itemCount,
    );
    super.initState();
  }

  @override
  void didUpdateWidget(_Carousel oldWidget) {
    if(widget.itemCount.toDouble() != this._horizontalController.upperBound + 1)
      _resetController();
    super.didUpdateWidget(oldWidget);
  }
  void _resetController(){
    _horizontalController?.dispose();

    _horizontalController = AnimationController(
      upperBound: widget.itemCount - 1.0,
      lowerBound: 0.0,
      value: widget.initialIndex?.toDouble() ?? 0.0,
      vsync: this,
    )..addListener(() => this.setState((){}));
    
    _verticalController = AnimationController(
      value: 0.0,
      vsync: this,
    )..addListener(() => this.setState((){}));
  }
  



  //============================
  // Getters ==================
  //============================

  int get n => widget.itemCount;
  double get currentHorizontalValue => _horizontalController.value;
  int get currentIndex => (currentHorizontalValue).round();
  int get nextIndex => (currentHorizontalValue).ceil();
  int get prevIndex => (currentHorizontalValue).floor();
  Color get backgroundColor => _backgroundColor(currentIndex);
  Color _backgroundColor(int i) {
    if(widget.backgroundColor != null) 
      return widget.backgroundColor(i);
    return Colors.black54;
  }

  double get currentVerticalValue => _verticalController.value;

  double get collapsedSize => widget.collapsedSize ?? 0.0;
  double get extendedSize => widget.extendedSize ?? 0.0;

  bool get isCollapsedThere => collapsedSize != null && widget.collapsedBuilder != null;
  bool get isExtendedThere => extendedSize != null && widget.extendedBuilder != null;

  bool get isVerticalScrollable => isCollapsedThere;

  double get verticalDelta => extendedSize - collapsedSize;
  double get currentVerticalDelta => verticalDelta * currentVerticalValue;
  double get currentVerticalSize => collapsedSize + currentVerticalDelta;



  //============================
  // Builders =================
  //============================

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final width = media.size.width;
    final height = media.size.height;
    final wFrac = widget.widthFraction.clamp(1/3, 1.0);
    final fWidth = width * wFrac;

    final bottomSize = isCollapsedThere ? collapsedSize : 0.0;

    return SizedBox.expand(
      child: Stack(
        children: <Widget>[
          background(),
          pageView(fWidth, width, height - bottomSize),
          if(isVerticalScrollable)
            verticalScrollBackground,
          if(isCollapsedThere)
            bottom,
        ],
      ),
    );
  }

  Widget background() => Positioned.fill(
    child: AnimatedBuilder(
      animation: widget.routeAnimationController,
      child: SplashingColoredBackground(_color, duration: const Duration(milliseconds: 550),),
      builder: (context, child) => Opacity(
        opacity: widget.routeAnimationController.value,
        child: child,
      ),
    ),
  );




  //============================
  // Horizontal View ==========
  //============================

  Widget pageView(double fWidth, double width, double height) 
    => AnimatedBuilder(
      animation: widget.routeAnimationController,
      child: pageViewChild(fWidth, width, height),
      builder: (context, child) => Positioned(
        left: 0.0,
        right: 0.0,
        top: height * (1 - Curves.fastOutSlowIn.transform(
          widget.routeAnimationController.value
        )),
        height: height,
        child: child,
      ),
    );

  Widget pageViewChild(double fWidth, double width, double height){
    final int minIndex = (currentIndex-1).clamp(0, n-1);
    final int maxIndex = (currentIndex+1).clamp(0, n-1);
    final List<int> indexes = [
      for(int i = minIndex; i <= maxIndex; ++i)
        i,
    ];
    return GestureDetector(
      onHorizontalDragUpdate: (details) => onHorizontalDragUpdate(details, width),
      onHorizontalDragEnd: onHorizontalDragEnd,
      child: Container(
        color: Colors.transparent,
        width: width,
        height: height,
        child: CustomMultiChildLayout(
          delegate: _CarouselLayoutDelegate(
            indexes: indexes,
            value: currentHorizontalValue,
            parallax: - currentVerticalValue * verticalDelta * (widget.parallaxEffect ?? 0.3),
          ),
          children: [
            for(final i in indexes)
              LayoutId(
                key: Key("carousel_child_number_$i"),
                id: '$_kLayoutId$i',
                child: buildItem(i, fWidth, height)
              ),
          ],
        )
      )
    );
  }

  Widget buildItem(int i, double fWidth, double height){
    return SizedBox(
      width: fWidth,
      height: height,
      child: widget.positionedItemBuilder(
        controller: _carouselController,
        context: context, 
        itemIndex: i, 
        pageValue: currentHorizontalValue, 
        totalHeight: height,
        width: fWidth,
      ),
    );
  }




  //============================
  // Horizontal View ==========
  //============================

  Widget get bottom{
    if(!isCollapsedThere) 
      return SizedBox();
    
    final scrollable = isVerticalScrollable;

    return Positioned(
      bottom: 0.0,
      left: 0.0,
      right: 0.0,
      height: scrollable 
        ? currentVerticalSize 
        : collapsedSize,
      child: GestureDetector(
        onVerticalDragUpdate: scrollable ? onVerticalDragUpdate : null,
        onVerticalDragEnd: scrollable ? onVerticalDragEnd : null,
        child: UpShadower(
          child: Stack(
            fit: StackFit.expand,
            alignment: Alignment.topCenter,
            children: <Widget>[
              if(isExtendedThere)
                Positioned(
                  top: 0.0,
                  right: 0.0,
                  left: 0.0,
                  height: extendedSize,
                  child: widget.extendedBuilder(currentIndex, _carouselController),
                ),
              Positioned(
                top: 0.0,
                right: 0.0,
                left: 0.0,
                height: collapsedSize,
                child: Opacity(
                  opacity: 1 - currentVerticalValue,
                  child: IgnorePointer(
                    ignoring: currentVerticalValue != 0.0,
                    child: widget.collapsedBuilder(currentIndex, _carouselController),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget get verticalScrollBackground => Positioned.fill(
    child: IgnorePointer(
      ignoring: currentVerticalValue == 0.0,
      child: GestureDetector(
        onTap: _close,
        child: Container(
          color: _color.withOpacity(
            0.4 * currentVerticalValue
          ),
        ),
      ),
    ),
  );


  //============================
  // Horizontal Drag ==========
  //============================

  void onHorizontalDragUpdate(DragUpdateDetails details, double width){
    _horizontalController.value -= details.primaryDelta / width;
  }
  void onHorizontalDragEnd(DragEndDetails details){
    final double vel = details.velocity.pixelsPerSecond.dx;
    final _m = _minFlingVelocityHorizontal;

    int i;

    if(vel > _m)        i = prevIndex;
    else if(vel < - _m) i = nextIndex;
    else                i = currentIndex;

    _animateTo(i);
  }

  void _animateTo(int i){

    _color = _backgroundColor(i);
    if(_horizontalController.isAnimating)
      return;
    _horizontalController.animateTo(
      i.toDouble(), 
      duration:_flingDuration,
      curve: Curves.easeOut,
    );
  }
  static const _minFlingVelocityHorizontal = 400;
  static const _flingDuration = Duration(milliseconds: 250);

  void _jumpTo(int i){
    _color = _backgroundColor(i);
    _horizontalController.value = i.toDouble();
  }





  //============================
  // Vertical Drag ============
  //============================

  void onVerticalDragUpdate(DragUpdateDetails details){
    _verticalController.value -= details.primaryDelta / verticalDelta;
  }
  void onVerticalDragEnd(DragEndDetails details){
    final double vel = details.velocity.pixelsPerSecond.dy;

    if(vel > _minFlingVelocityVertical)        
      _close();
    else if(vel < - _minFlingVelocityVertical) 
      _open();
    else {
      if(currentVerticalValue > 0.5) 
        _open();
      else 
        _close();
    }
  }
  static const _minFlingVelocityVertical = 800;


  void _open(){
    _verticalController.fling(velocity: 1.0);
  }
  void _close(){
    _verticalController.fling(velocity: -1.0);
  }

}




//===========================
// Layout Delegate =========
//===========================

const String _kLayoutId= 'CarouselLayoutId';

class _CarouselLayoutDelegate extends MultiChildLayoutDelegate {
  final List<int> indexes;
  final double value;
  final double parallax;
 
  _CarouselLayoutDelegate({
    @required this.indexes,
    @required this.value,
    @required this.parallax,
  });

  @override
  void performLayout(Size size) {
    final viewW = size.width;
    for (final i in indexes) { 
      final String childId = '$_kLayoutId$i'; 
      if (hasChild(childId)) { 
        final Size childSize = layoutChild(childId, BoxConstraints.loose(size)); 
        final childW = childSize.width;
        final wPadding = (viewW - childW) / 2;
        final double distance = (i - value).toDouble(); 
        positionChild( 
          childId, 
          Offset( 
            wPadding + childW * (distance), 
            distance.abs() < 1 ? parallax : 0.0,
          ), 
        ); 
      }
    }
  } 

  @override 
  bool shouldRelayout(_CarouselLayoutDelegate oldDelegate) {
    if(value != oldDelegate.value) 
      return true;
    if(parallax != oldDelegate.parallax)
      return true;
    if(indexes.length != oldDelegate.indexes.length) 
      return true;
    for(int i = 0; i < indexes.length; ++i)
      if(indexes[i] != oldDelegate.indexes[i])
        return true;
    return false;
  }
}














class _ModalBottomSheetRoute<T> extends PopupRoute<T> {
  _ModalBottomSheetRoute({
    @required this.theme,
    @required this.barrierLabel,

    @required this.itemCount,
    @required this.initialIndex,
    @required this.positionedItemBuilder,
    @required this.widthFraction,

    @required this.collapsedBuilder,
    @required this.collapsedSize,
    @required this.extendedBuilder,
    @required this.extendedSize,
    @required this.parallaxEffect,

    @required this.backgroundColor,
    @required this.animateColor,
    @required this.splashAnimateColor,

    RouteSettings settings,
  }) : super(settings: settings);

  final ThemeData theme;

  final PositionedItemBuilder positionedItemBuilder;
  final int itemCount;
  final int initialIndex;

  final double widthFraction;

  final Widget Function(int, CarouselController) collapsedBuilder;
  final double collapsedSize;
  final Widget Function(int, CarouselController) extendedBuilder;
  final double extendedSize;
  final double parallaxEffect;

  final Color Function(int) backgroundColor;
  final bool animateColor;
  final bool splashAnimateColor;


  @override
  Duration get transitionDuration => _kCarouselDuration;

  @override
  bool get barrierDismissible => false;

  @override
  final String barrierLabel;

  @override
  Color get barrierColor => _kBarrier;

  AnimationController _animationController;

  @override
  AnimationController createAnimationController() {
    assert(_animationController == null);
    _animationController = AnimationController(
      vsync: navigator.overlay,
      debugLabel: 'carousel',
      duration: _kCarouselDuration,
    ); 
    return _animationController; 
  }

  @override
  Widget buildPage(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) {
    Widget carousel =_Carousel(
      routeAnimationController: _animationController,

      initialIndex: initialIndex,
      itemCount: itemCount,
      positionedItemBuilder: positionedItemBuilder,

      widthFraction: widthFraction ?? 1.0,

      collapsedBuilder: collapsedBuilder,
      collapsedSize: collapsedSize,

      extendedBuilder: extendedBuilder,
      extendedSize: extendedSize,

      parallaxEffect: parallaxEffect,

      backgroundColor: backgroundColor ?? (i) => _kBarrier,
      animateColor: animateColor ?? true,
      splashAnimateColor: splashAnimateColor ?? true,
    );
    if (theme != null)
      carousel = Theme(data: theme, child: carousel);
    return carousel;
  }
}

Future<T> showCarousel<T>({
  @required BuildContext context,
  @required int itemCount,
  @required PositionedItemBuilder positionedItemBuilder,

  int initialIndex = 0,
  Color Function(int) backgroundColor,

  Widget Function(int, CarouselController) collapsedBuilder,
  double collapsedSize,
  Widget Function(int, CarouselController) extendedBuilder,
  double extendedSize,
  double parallaxEffect = 0.3,

  double widthFraction = 1.0,
  bool animateColor = true,
  bool splashAnimateColor = true,

  bool forcePortrait = true,
}) {
  assert(context != null);

  if(forcePortrait == true)
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  return Navigator.push(context, _ModalBottomSheetRoute<T>(
    theme: Theme.of(context, shadowThemeOnly: true),
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    backgroundColor: backgroundColor,
    positionedItemBuilder: positionedItemBuilder,
    collapsedBuilder: collapsedBuilder,
    collapsedSize: collapsedSize,
    extendedBuilder: extendedBuilder,
    extendedSize: extendedSize,
    parallaxEffect: parallaxEffect ?? 0.3,
    widthFraction: widthFraction ?? 1.0,
    itemCount: itemCount,
    initialIndex: initialIndex ?? 0,
    animateColor: animateColor ?? true,
    splashAnimateColor: splashAnimateColor ?? true,
  )).then<void>((_) => SystemChrome.setPreferredOrientations(
    DeviceOrientation.values.toList()
  ));
  
}
