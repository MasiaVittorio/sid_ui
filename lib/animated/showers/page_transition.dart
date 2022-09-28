import 'package:flutter/material.dart';
import 'animated_presented.dart';

class RadioPageTransition<A> extends StatefulWidget {

  RadioPageTransition({
    required this.page,
    required this.children,
    required this.orderedPages,
    this.backgroundColor,
    this.offset = 100,
  }) : assert(offset > 0);
  final A page;
  final List<A> orderedPages;
  final Map<A,Widget> children;
  final Color? backgroundColor;
  final double offset;

  @override
  State<RadioPageTransition<A>> createState() => _RadioPageTransitionState<A>();
}

class _RadioPageTransitionState<A> extends State<RadioPageTransition<A>> {
 
  late A previous;

  @override
  void initState() {
    super.initState();
    previous = widget.page;
  }

  @override
  void didUpdateWidget(covariant RadioPageTransition<A> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if(oldWidget.page != widget.page){
      previous = oldWidget.page;
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Material(
      color: widget.backgroundColor,
      child: Stack(fit: StackFit.expand, children: <Widget>[
        for(final entry in widget.children.entries)
          AnimatedPresented(
            slideOffset: Offset( 
              entry.key == widget.page // if this is the current page
                ? widget.orderedPages.indexOf(entry.key) < widget.orderedPages.indexOf(previous) // if this is to the left of the previous one
                  ? -widget.offset // comes from the left
                  : widget.offset // comes from the right
                : widget.orderedPages.indexOf(entry.key) < widget.orderedPages.indexOf(widget.page) // if this is to the left of the current one
                  ? -widget.offset // goes to the left
                  : widget.offset, // goes to the right
              0,
            ),
            presented: widget.page == entry.key,
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