
import 'package:flutter/material.dart';
import 'carousel.dart';
import 'package:sid_utils/sid_utils.dart';

PositionedItemBuilder readySidereusPositionedItemBuilder(Widget Function(int) childBuilder) 
  => ({
  required BuildContext context, 
  required int itemIndex, 
  required double pageValue,
  required double totalHeight,
  required double width,
  required CarouselController? controller,
}) => sidereusPositionedItemBuilder(
  content: childBuilder(itemIndex),
  context: context,
  controller: controller,
  pageValue: pageValue,
  totalHeight: totalHeight,
  width: width,
  itemIndex: itemIndex,
);

Widget sidereusPositionedItemBuilder({
  required BuildContext context, 
  required int itemIndex, 
  required double pageValue,
  required double totalHeight,
  required double width,
  required CarouselController? controller,

  required Widget content,
}){
  final distance = 1 - (pageValue - itemIndex).clamp(-1, 1).abs();
  final minScale = 0.95;
  final scale = minScale + distance * (1 - minScale);
  final curvedScale = Curves.easeIn.transform(scale);

  Widget child = SingleChildScrollView(
    child: Container( 
      height: totalHeight,
      width: width,
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 3.0),
      child: content,
    ),
    physics: SidereusScrollPhysics(
      callbackCondition: (over, velocity) 
        => customBounceCallbackCondition(3.0, over, velocity),
      topBounce: true,
      topBounceCallback: Navigator.of(context).pop,
      bottomBounce: true,
      bottomBounceCallback: Navigator.of(context).pop,
      alwaysScrollable: true,
    ),
  );

  return Center(
    child: Transform.scale(
      scale: curvedScale,
      alignment: pageValue > itemIndex ? Alignment.centerRight : Alignment.centerLeft,
      // alignment: Alignment.center,
      child: child,
    ),
  );
}
