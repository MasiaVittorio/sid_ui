import 'package:flutter/material.dart';

import 'dart:math' as math;

class CircularLayout extends StatelessWidget {
  final List<Widget> children;
  final List<Widget> labels;
  final double startingAngle;
  final bool clockWise;
  final double labelPadding;

  CircularLayout(this.children, {
    this.startingAngle = -90, 
    this.labels,
    this.clockWise = true,
    this.labelPadding = 8.0,
  }): assert(children != null),
      assert(clockWise != null),
      assert(labelPadding != null),
      assert(children.isNotEmpty),
      assert((labels == null) || (labels.length == children.length));

  @override
  Widget build(BuildContext context) {
    final bool alsoLabels = labels != null && labels.isNotEmpty;
    return CustomMultiChildLayout(
      delegate: _CircularLayoutDelegate(
        itemCount: children.length,
        startAngle: this.startingAngle ?? -90,
        alsoLabels: alsoLabels,
        clockWise: this.clockWise,
        labelPadding: this.labelPadding,
      ),
      children: [
        for(int i = 0; i < children.length; ++i)
          LayoutId(
            id: '$_kLayoutId$i',
            child: children[i],
          ),
        if(alsoLabels)
          for(int i = 0; i < labels.length; ++i)
            LayoutId(
              id: '$_kLayoutIdLabel$i',
              child: labels[i],
            ),
      ],
    );
  }
}

const String _kLayoutId= 'ÇircularLayoutId';
const String _kLayoutIdLabel= 'ÇircularLayoutIdLabel';

class _CircularLayoutDelegate extends MultiChildLayoutDelegate {
  final int itemCount;
  final double startAngle;
  final bool alsoLabels;
  final double labelPadding;
  final bool clockWise;
 
  _CircularLayoutDelegate({
    @required this.itemCount,
    this.startAngle = -90,
    this.alsoLabels = false,
    this.labelPadding = 8.0,
    this.clockWise,
  }): assert(alsoLabels != null),
      assert(clockWise != null),
      assert((!alsoLabels) || (labelPadding!=null)), 
      assert(startAngle != null),
      assert(itemCount != null);

  // @override
  // Size getSize(BoxConstraints constraints) {
  //   final l = math.min(constraints.maxHeight, constraints.maxWidth);

  //   return super.getSize(BoxConstraints(
  //     maxHeight: l,
  //     maxWidth: l,
  //   ));
  // }

  static double offsetX(Offset center, Size childSize, double radius, double itemAngle) 
    => (center.dx - childSize.width / 2) + (radius - childSize.width/2) * math.cos(itemAngle);
  static double offsetY(Offset center, Size childSize, double radius, double itemAngle) 
    => (center.dy - childSize.height / 2) + (radius - childSize.height/2) * math.sin(itemAngle);

  Offset offsetChild(Offset center, Size childSize, double radius, double itemAngle) 
    => Offset(
      offsetX(center, childSize, radius, itemAngle), 
      offsetY(center, childSize, radius, itemAngle),
    );

  String getChildId(int i) => '$_kLayoutId$i';
  String getLabelId(int i) => '$_kLayoutIdLabel$i';
 
  @override
  void performLayout(Size size) {

    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;

    for (int i = 0; i < itemCount; i++) { 

      final String childId = getChildId(i); 

      if (hasChild(childId)) { 
        final Size childSize = layoutChild(childId, BoxConstraints.loose(size)); 
        final double itemAngle = _radPerDeg * ((startAngle + (clockWise ? i : - i) * _itemSpacing) % 360);
        //% 360 means that 370 is equivalent to 10
        final childOffset = offsetChild(center, childSize, radius, itemAngle);

        positionChild( 
          childId,
          childOffset,
        );

        if(alsoLabels){
          final String labelId = getLabelId(i);
          if(hasChild(labelId)){
            final Size labelSize = layoutChild(labelId, BoxConstraints.loose(size)); 
            final bool right = itemAngle < math.pi/2 || itemAngle >= math.pi * 3/2;
            positionChild(
              labelId, 
              childOffset + Offset(
                right 
                  ? (childSize.width + labelPadding) 
                  : (- labelSize.width - labelPadding),
                (childSize.height - labelSize.height) / 2
              ),
            );
          }
        } 

      }

    }

  } 

  double get _itemSpacing => 360 / itemCount;

  @override 
  bool shouldRelayout(_CircularLayoutDelegate oldDelegate) =>
      itemCount != oldDelegate.itemCount  
    ||startAngle != oldDelegate.startAngle
    ||alsoLabels != oldDelegate.alsoLabels
    ||labelPadding != oldDelegate.labelPadding;
}

const double _radPerDeg = math.pi / 180;
