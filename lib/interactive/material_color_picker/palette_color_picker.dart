import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:sid_utils/sid_utils.dart';
import 'color_to_hex.dart';

import 'this_double_color.dart';

import 'dart:math' as math;

class PaletteColorPicker extends StatefulWidget {
  final Color color;
  final Function(Color) onChanged;
  final void Function() paletteUndescrollCallback;

  PaletteColorPicker({
    @required this.color,
    @required this.onChanged,
    this.paletteUndescrollCallback,
  });

  @override
  State createState() => new _PaletteColorPickerState();
}

class _PaletteColorPickerState extends State<PaletteColorPicker> with TickerProviderStateMixin {

  final List<ThisDoubleColor> _thisColors = materialPalette;

  TabController _tabController;

  int _secondIndex = 0;

  List<List<Color>> get allShades => <List<Color>>[
    for(final dbc in _thisColors)
      dbc.shades,
  ];

  List<int> find(Color c){
    for(int i=0; i < this._thisColors.length; ++i){
      final _dblc = this._thisColors[i];
      if(_dblc.shades.contains(c)){
        return [i,_dblc.shades.indexOf(c)];
      }
    }
    return <int>[];
  }

  @override
  void initState() {
    super.initState();
    this._tabController = TabController(
      length: this._thisColors.length,
      vsync: this,
    );
    List<int> _indexes = this.find(widget.color);
    if(_indexes.length == 2) {
      this._tabController.index = _indexes[0];
      this._secondIndex = _indexes[1];
    }

    /// NOT REALLY SURE WHY IT WAS NEEDED, ON  TAP SHOULD TAKE CARE OF THIS
    // this._tabController.addListener((){
    //   this._secondIndex = this._thisColors[this._tabController.index].defaultIndex;
    //   widget.onChanged(this.currentColor);
    // });
    /// NOT REALLY SURE WHY IT WAS NEEDED, ON  TAP SHOULD TAKE CARE OF THIS

  }

  @override
  void didUpdateWidget(PaletteColorPicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if(oldWidget.color != widget.color){
      List<int> _indexes = this.find(widget.color);
      if(_indexes.length == 2) {
        this._tabController.index = _indexes[0];
        this._secondIndex = _indexes[1];
      }
    }
  }

  @override
  void dispose(){
    this._tabController?.dispose();
    super.dispose();
  }
  

  Color get currentColor => this._thisColors[this._tabController.index].shades[this._secondIndex];

  @override
  Widget build(BuildContext context) {
        
    final Widget _row = Material(
      child: Container(
        constraints: BoxConstraints(maxHeight: 64,),
        child: TabBar(
          onTap: (int i) => setState(() {
            this._secondIndex = this._thisColors[i].defaultIndex;
            widget.onChanged(this.currentColor);
          }),
          isScrollable: true,
          dragStartBehavior: DragStartBehavior.down,
          indicatorColor: Theme.of(context).textTheme.bodyText2.color,
          indicatorWeight: 3.0,
          tabs: List.generate(this._thisColors.length, (int i){
            return Tab(
              text: this._thisColors[i].name,
              icon: Icon(MaterialCommunityIcons.circle, color: this._thisColors[i].defaultColor,),
            );
          }),
          controller: this._tabController,
          unselectedLabelStyle: TextStyle(color: Colors.black, fontWeight: FontWeight.w700),
          labelColor: Theme.of(context).textTheme.bodyText2.color,
          labelStyle: TextStyle(fontWeight: FontWeight.w700),
          unselectedLabelColor: Theme.of(context).textTheme.bodyText2.color != null 
            ? Theme.of(context).textTheme.bodyText2.color.withOpacity(0.5)
            : null,
        ),
      ),
    );
    
    final Widget _column = Theme(
      data: Theme.of(context).copyWith(accentColor: Colors.white),
      child: LayoutBuilder(builder: (_, constraints){
        return ConstrainedBox(
          constraints: constraints,
          child: TabBarView(
            controller: this._tabController,
            children: <Widget>[
              for(int tabI = 0; tabI < this._thisColors.length; ++tabI)
                ListView(
                  physics: SidereusScrollPhysics(
                    alwaysScrollable: true,
                    bottomBounce: false,
                    topBounce: this.widget.paletteUndescrollCallback != null,
                    topBounceCallback: this.widget.paletteUndescrollCallback,
                  ),
                  children: <Widget>[
                    for(final couple in <Widget>[
                      for(int colorI=0; colorI<_thisColors[tabI].shades.length; ++colorI)
                        _buildTile(
                          colorIndex: colorI,
                          color: this._thisColors[tabI].shades[colorI],
                          len: this._thisColors[tabI].shades.length,
                          maxH: constraints.maxHeight,
                          minH: 58,
                        ),
                    ].part(2))
                      Row(children: [
                        for(final child in couple) Expanded(child: child),
                      ],),
                  ],
                ),
            ],
          ),
        );
      },),
    );

    final Widget _divider = Divider(height: 0.0,);

    return Column(
      children: <Widget>[
        Expanded(child: _column,),
        _divider,
        _row,
      ]
    );

  }



  Widget _buildTile({
    @required int colorIndex,
    @required Color color, 
    @required int len, 
    @required double minH,
    @required double maxH,
  }){

    int _rows = (len/2).ceil();
    double _height = math.max(minH, maxH/_rows);

    final bool check = this.currentColor == color;
    final Color text = color.contrast;

    return Material(
      color: color,
      child: InkWell(
        onTap: (){
          setState(() {
            this._secondIndex = colorIndex; 
            widget.onChanged(this.currentColor);
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          height: _height,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                "#FF${colorToHex(color)}",
                style: TextStyle(
                  fontWeight: FontWeight.w700, 
                  color: text,
                ),
              ),
              // TODO: nonsense, la prima volta che viene trovato il closest qua va non mostra il selezionato
              Icon(Icons.check, color: check ? text : Colors.transparent),
            ],
          ),
        ),
      )
    );

  }

}
