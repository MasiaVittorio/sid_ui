import 'package:flutter/material.dart';
import 'animated_presented.dart';

class RadioPageTransition<A> extends StatelessWidget {

  RadioPageTransition({
    required this.page,
    required this.previous,
    required this.children,
    required this.orderedPages,
    this.backgroundColor,
    this.offset = 100,
  }) : assert(offset > 0);
  final A page;
  final A previous;
  final List<A> orderedPages;
  final Map<A,Widget> children;
  final Color? backgroundColor;
  final double offset;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: backgroundColor,
      child: Stack(fit: StackFit.expand, children: <Widget>[
        for(final entry in children.entries)
          AnimatedPresented(
            slideOffset: Offset( 
              entry.key == page // if this is the current page
                ? orderedPages.indexOf(entry.key) < orderedPages.indexOf(previous) // if this is to the left of the previous one
                  ? -offset // comes from the left
                  : offset // comes from the right
                : orderedPages.indexOf(entry.key) < orderedPages.indexOf(page) // if this is to the left of the current one
                  ? -offset // goes to the left
                  : offset, // goes to the right
              0,
            ),
            presented: page == entry.key,
            child: entry.value,
            presentMode: PresentMode.slide,
            curve: Curves.easeOut,
            fadeFirstFraction: 0.55,
            duration: const Duration(milliseconds: 250),
          ),
      ],),
    );
  }
}