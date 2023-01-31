// import 'package:flutter/gestures.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_vector_icons/flutter_vector_icons.dart';
// import 'package:sid_utils/sid_utils.dart';
// import 'models/color_to_hex.dart';

// import 'this_double_color.dart';

// import 'dart:math' as math;

// class PaletteColorPickerNonScrollable extends StatefulWidget {
//   final Color color;
//   final Function(Color) onChanged;
//   final void Function() paletteUndescrollCallback;

//   PaletteColorPickerNonScrollable({
//     @required this.color,
//     @required this.onChanged,
//     this.paletteUndescrollCallback,
//   });

//   @override
//   State createState() => new _PaletteColorPickerNonScrollableState();
// }

// class _PaletteColorPickerNonScrollableState extends State<PaletteColorPickerNonScrollable> with TickerProviderStateMixin {

//   final List<ThisDoubleColor> _thisColors = materialPalette;

//   TabController _tabController;

//   int _secondIndex=0;

//   List<List<Color>> get allShades => this._thisColors.map<List<Color>>((ThisDoubleColor dbc){
//     return dbc.shades;
//   }).toList();

//   List<int> find(Color c){

//     int _mainIndexSearch = 0;
//     while(_mainIndexSearch < this._thisColors.length){
//       final _dblc = this._thisColors[_mainIndexSearch];
//       if(_dblc.shades.contains(c)){
//         return [_mainIndexSearch,_dblc.shades.indexOf(c)];
//       }
//       ++_mainIndexSearch;
//     }

//     return <int>[];
//   }

//   void listener(){
//     this._secondIndex = this._thisColors[this._tabController.index].defaultIndex;
//     widget.onChanged(this.currentColor);
//   }

//   @override
//   void initState() {
//     super.initState();
//     this._tabController = TabController(
//       length: this._thisColors.length,
//       vsync: this,
//     );
//     this._reset();
//   }
//   void _reset(){
//     List<int> _indexes = this.find(widget.color);
//     if(_indexes.length == 2) {
//       this._tabController.index=_indexes[0];
//       this._secondIndex = _indexes[1];
//     }
//   }

//   @override
//   void didUpdateWidget(oldWidget){
//     super.didUpdateWidget(oldWidget);
//     if(oldWidget.color != this.widget.color){
//       this._reset();
//     }
//   }


//   @override
//   void dispose(){
//     this._tabController.dispose();
//     super.dispose();
//   }
  

//   Color get currentColor => this._thisColors[this._tabController.index].shades[this._secondIndex];

//   @override
//   Widget build(BuildContext context) {
        
//     final Widget _row = Material(
//       child: Container(
//         constraints: BoxConstraints(maxHeight: 64,),
//         child: TabBar(
//           onTap: (int i) => setState(() {
//             this._secondIndex = this._thisColors[i].defaultIndex;
//             widget.onChanged(this.currentColor);
//           }),
//           isScrollable: true,
//           dragStartBehavior: DragStartBehavior.down,
//           indicatorColor: Theme.of(context).textTheme.bodyMedium?.color,
//           indicatorWeight: 3.0,
//           tabs: List.generate(this._thisColors.length, (int i){
//             return Tab(
//               text: this._thisColors[i].name,
//               icon: Icon(MaterialCommunityIcons.circle, color: this._thisColors[i].defaultColor,),
//             );
//           }),
//           controller: this._tabController,
//           unselectedLabelStyle: TextStyle(color: Colors.black, fontWeight: FontWeight.w700),
//           labelColor: Theme.of(context).textTheme.bodyMedium?.color,
//           labelStyle: TextStyle(fontWeight: FontWeight.w700),
//           unselectedLabelColor: Theme.of(context).textTheme.bodyMedium?.color != null 
//             ? Theme.of(context).textTheme.bodyMedium?.color.withOpacity(0.5)
//             : null,
//         ),
//       ),
//     );
    
//     final Widget _column = LayoutBuilder(
//       builder: (BuildContext c, BoxConstraints constraints){
//         return Container(
//           constraints: constraints,
//           child: Theme(
//             data: Theme.of(context).copyWith(accentColor: Colors.white),
//             child: ListView(
//               physics: SidereusScrollPhysics(
//                 bottomBounce: false,
//                 topBounce: this.widget.paletteUndescrollCallback != null,
//                 topBounceCallback: this.widget.paletteUndescrollCallback,
//               ),
//               children: List.generate(
//                 (this._thisColors[this._tabController.index].shades.length/2).ceil(), 
//                 (int i){
//                   return _buildTile(
//                     i2first: i*2 , 
//                     i2second: i*2+1, 
//                     len: this._thisColors[this._tabController.index].shades.length, 
//                     tabIndex: this._tabController.index,
//                     minH: 58,
//                     maxH: constraints.maxHeight,
//                   );
//                 }
//               )
//             ),
//           ),
//         );
//       }
//     );

//     final Widget _divider = Divider(height: 0.0,);

//     return Column(
//       children: <Widget>[
//         Expanded(child: _column,),
//         _divider,
//         _row,
//       ]
//     );

//   }



//   Widget _buildTile({
//     int i2first, 
//     int i2second, 
//     int len, 
//     int tabIndex,
//     double minH,
//     double maxH,
//   }){

//     int _rows = (len/2).ceil();
//     double _height = math.max(minH, maxH/_rows);

//     Widget _tile(int i2){
//       final Color _clr = this._thisColors[tabIndex].shades[i2];
//       return  Theme(
//         data: ThemeData.estimateBrightnessForColor(_clr) == Brightness.dark ? ThemeData.dark() : ThemeData.light(),
//         child:Material(
//           color: _clr,
//           child: InkWell(
//             onTap: (){
//               setState(() {
//                 this._secondIndex = i2; 
//                 widget.onChanged(this.currentColor);
//               });
//             },
//             child: Container(
//               padding: const EdgeInsets.symmetric(horizontal: 16.0),
//               height: _height,
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: <Widget>[
//                   Text(
//                     "#FF${_clr.hexString}",
//                     style: TextStyle(fontWeight: FontWeight.w700, ),
//                   ),
//                   if(this._secondIndex == i2 && this._tabController.index == tabIndex) 
//                     Icon(Icons.check),
//                 ],
//               ),
//             ),
//           )
//         )
//       );
//     }

//     return i2second >= len
//       ? _tile(i2first)
//       : Row(
//         children: <Widget>[
//           Expanded(child: _tile(i2first)),
//           Expanded(child: _tile(i2second)),
//         ],
//       );
//   }

// }
