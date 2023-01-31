import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:sid_utils/sid_utils.dart';
import 'models/color_to_hex.dart';

import 'models/palette.dart';

import 'dart:math' as math;

class PaletteColorPicker extends StatefulWidget {
  final Color? color;
  final Function(Color?) onChanged;
  final void Function()? paletteUndescrollCallback;

  PaletteColorPicker({
    required this.color,
    required this.onChanged,
    this.paletteUndescrollCallback,
  });

  @override
  State createState() => new _PaletteColorPickerState();
}

class _PaletteColorPickerState extends State<PaletteColorPicker> with TickerProviderStateMixin {

  final List<PaletteTab> _tabs = PaletteTab.allTabs;

  TabController? _tabController;

  int? _colorIndex;

  List<int?> find(Color? c){
    for(int tabI=0; tabI < this._tabs.length; ++tabI){
      final tab = this._tabs[tabI];
      for(int colI=0; colI<tab.shades.length; ++colI){
        if(tab.shades[colI] == c) 
          return [tabI,colI];
      }
    }
    return <int?>[null, null];
  }

  @override
  void initState() {
    super.initState();
    this._tabController = TabController(
      length: this._tabs.length,
      vsync: this,
    );
    List<int?> _indexes = this.find(widget.color);
    this._tabController!.index = _indexes[0]
      ?? PaletteTab.findClosestTabIndex(_tabs, widget.color) ?? 0;
    this._colorIndex = _indexes[1];

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
      List<int?> _indexes = this.find(widget.color);
      this._tabController!.index = _indexes[0] 
        ?? PaletteTab.findClosestTabIndex(_tabs, widget.color) ?? 0;
      this._colorIndex = _indexes[1];
    }
  }

  @override
  void dispose(){
    this._tabController?.dispose();
    super.dispose();
  }
  

  Color? get currentColor => this._colorIndex == null 
    ? null 
    : _tabs[_tabController!.index].shades[_colorIndex!];

  @override
  Widget build(BuildContext context) {
        
    final Widget _row = Material(
      child: Container(
        constraints: BoxConstraints(maxHeight: 64,),
        child: TabBar(
          onTap: (int i) => setState(() {
            this._colorIndex = this._tabs[i].defaultIndex;
            widget.onChanged(this.currentColor);
          }),
          isScrollable: true,
          dragStartBehavior: DragStartBehavior.down,
          indicatorColor: Theme.of(context).textTheme.bodyMedium?.color,
          indicatorWeight: 3.0,
          tabs: List.generate(this._tabs.length, (int i){
            return Tab(
              text: this._tabs[i].name,
              icon: Icon(MaterialCommunityIcons.circle, color: this._tabs[i].defaultColor,),
            );
          }),
          controller: this._tabController,
          unselectedLabelStyle: TextStyle(color: Colors.black, fontWeight: FontWeight.w700),
          labelColor: Theme.of(context).textTheme.bodyMedium?.color,
          labelStyle: TextStyle(fontWeight: FontWeight.w700),
          unselectedLabelColor: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.5),
        ),
      ),
    );
    
    final _theme = Theme.of(context);
    final Widget _column = Theme(
      data: _theme.copyWith(
        colorScheme: _theme.colorScheme.copyWith(
          secondary: Colors.white,
        ),
      ),
      child: LayoutBuilder(builder: (_, constraints){
        return ConstrainedBox(
          constraints: constraints,
          child: TabBarView(
            controller: this._tabController,
            children: <Widget>[
              for(int tabI = 0; tabI < this._tabs.length; ++tabI)
                ListView(
                  physics: SidereusScrollPhysics(
                    alwaysScrollable: true,
                    bottomBounce: false,
                    topBounce: this.widget.paletteUndescrollCallback != null,
                    topBounceCallback: this.widget.paletteUndescrollCallback,
                  ),
                  children: <Widget>[
                    for(final couple in <Widget>[
                      for(int colorI=0; colorI<_tabs[tabI].shades.length; ++colorI)
                        _buildTile(
                          colorIndex: colorI,
                          color: this._tabs[tabI].shades[colorI],
                          len: this._tabs[tabI].shades.length,
                          maxH: constraints.maxHeight,
                          minH: 58,
                        ),
                    ].part(2))
                      Row(children: [
                        for(final child in couple!) Expanded(child: child),
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
    required int colorIndex,
    required Color color, 
    required int len, 
    required double minH,
    required double maxH,
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
            this._colorIndex = colorIndex; 
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
                "#FF${color.hexString}",
                style: TextStyle(
                  fontWeight: FontWeight.w700, 
                  color: text,
                ),
              ),
              // TODO: nonsense, la prima volta che viene trovato il closest qua non mostra il selezionato
              Icon(Icons.check, color: check ? text : Colors.transparent),
            ],
          ),
        ),
      )
    );

  }

}
