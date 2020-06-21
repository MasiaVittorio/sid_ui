part of radio_slider;



class RadioSliderItem {

  final Widget title;
  final Widget icon;
  final Widget selectedIcon;
  const RadioSliderItem({
    @required this.title,
    @required this.icon,
    this.selectedIcon,
  });

}


class RadioSlider extends StatefulWidget{
  final List<RadioSliderItem> items;
  final int selectedIndex;
  final void Function(int) onTap;

  final Duration duration;

  final Widget title;

  final Color selectedColor;
  final Color backgroundColor;
  final bool hideOpenIcons;
  final bool elevateSlider;
  static const bool _kElevateSlider = false;

  final EdgeInsets margin;
  static const EdgeInsets _kMargin = EdgeInsets.all(10.0);
  final double height;
  static const double _kHeight = 56.0;

  RadioSlider({
    @required this.items,
    @required this.selectedIndex,
    @required this.onTap,
    this.duration = const Duration(milliseconds: 250),
    this.title,
    this.elevateSlider,
    this.margin,
    this.height,
    this.selectedColor,
    this.backgroundColor,
    this.hideOpenIcons,
  }): 
    assert(duration != null),
    assert(items != null);

  @override
  _RadioSliderState createState() => _RadioSliderState();
}

class _RadioSliderState extends State<RadioSlider> with TickerProviderStateMixin{
  static const double _radius = 8.0;

  //================================
  // State
  AnimationController _animation;
  int _index;
  bool _sliding = false;

  @override
  void initState() {
    super.initState();
    initController();
    _index = widget.selectedIndex;
  }

  @override
  void dispose() {
    _animation?.dispose();
    super.dispose();
  }

  void initController(){
    _animation?.dispose();
    _animation = null;
    _animation = AnimationController(
      vsync: this,
      value: indexVal(widget.selectedIndex),
      duration: widget.duration,
    )..addListener((){
      this.setState((){});
    });
  }

  @override
  void didUpdateWidget(RadioSlider oldWidget) {
    super.didUpdateWidget(oldWidget);
    if(this._index != widget.selectedIndex){
      goToIndex(widget.selectedIndex);
    }
    if(widget.duration != this._animation.duration){
      this.initController();
    }
  }


  //================================
  // Logic
  void tap(int index) {
    this.widget.onTap(index);
  }

  void goToIndex(int index) {
    this._index = index;
    this._animation.animateTo(indexVal(index), curve: Curves.easeOut);
  }

  void snapToIndex(int index) {
    this._index = index;
    this._animation.animateTo(indexVal(index), duration: Duration(milliseconds: 90));
  }

  void onDragUpdate(DragUpdateDetails details, double max){
    this._animation.value += details.primaryDelta / maxSpace(max);
    _sliding = true;
  }

  void endDragToIndex(int index){
    this.setState((){
      _sliding = false;
    });
    snapToIndex(index);
    tap(index);
  }

  void onDragEnd(DragEndDetails details){
    double vel = details.velocity.pixelsPerSecond.dx;

    if(vel.abs() >= 330){
      endDragToIndex(vel >= 0 ? nearestIndexCeil : nearestIndexFloor);
    } else {
      endDragToIndex(this.nearestIndex);
    }
  }



  //================================
  // Widgets

  bool _isShowing(int index) => index == widget.selectedIndex && !_sliding;
   
  @override
  Widget build(BuildContext context) {
    final RadioSliderThemeData radioTheme = RadioSliderTheme.of(context);
    final double _height = height(radioTheme);

    Widget result = SizedBox(
      height: _height,
      child: LayoutBuilder(
        builder:(context, constraints) => Stack(children: <Widget>[ 

          Positioned.fill(
            child: _Background(widget.backgroundColor), 
          ),

          Positioned(
            left: position(constraints.maxWidth),
            child: _VisualSlider(
              height: height(radioTheme), 
              width: sliderWidth(constraints.maxWidth),
              elevate: widget.elevateSlider ?? radioTheme?.elevateSlider ?? RadioSlider._kElevateSlider,
            ),
          ),

          Positioned.fill(child: Row(children: <Widget>[
            for(int i = 0; i < widget.items.length; i++)
              Expanded(child: Material(
                type: MaterialType.transparency,
                child: InkWell(
                  borderRadius: BorderRadius.circular(_radius),
                  onTap: () {
                    goToIndex(i);
                    tap(i);
                  },
                  child: _Button(
                    withIcon: !(widget.hideOpenIcons ?? radioTheme?.hideOpenIcons ?? false),
                    selectedColor: widget.selectedColor, 
                    item: widget.items[i], 
                    isShowing: _isShowing(i), 
                    duration: widget.duration, 
                    height: _height, 
                    width: sliderWidth(constraints.maxWidth),
                  ), 
                ),
              ),),
          ],),),

          Positioned(
            left: position(constraints.maxWidth),
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onHorizontalDragUpdate: (details) => this.onDragUpdate(details, constraints.maxWidth),
              onHorizontalDragEnd: (details) => this.onDragEnd(details),
              onHorizontalDragCancel: () => this.endDragToIndex(this.nearestIndex),
              child: Container(
                height: _height,
                width: constraints.maxWidth / n,
                color: Colors.transparent,
              ),
            ),
          ),
        ],),
      ),
    );

    if(widget.title != null){
      result = Row(children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(right: 10),
          child: widget.title,
        ),
        Expanded(child: result),
      ]);
    }
    
    return Padding(
      padding: margin(radioTheme),
      child: result,
    );
  }

}
