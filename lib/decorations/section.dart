import 'package:flutter/material.dart';
import 'package:sid_utils/sid_utils.dart';
import 'package:sid_ui/animated/animated_text.dart';

class Section extends StatelessWidget {
  final List<Widget> children;
  final bool last;
  final bool stretch;
  final DecorationImage? image;
  final Color? backgroundColor;

  const Section(this.children, {
    this.last = false,
    this.stretch = false,
    this.image,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: last ? 0.0 : 14.0),
      child: Container(
        decoration: BoxDecoration(
          image: image,
          color: backgroundColor ?? Theme.of(context).canvasColor,
          boxShadow: [BoxShadow(
            blurRadius: 0.15,
            color: Color(0x65000000)
          )],
        ), 
        child: Material(
          type: MaterialType.transparency,
          child: Column(
            mainAxisSize: MainAxisSize.min, 
            crossAxisAlignment: stretch ? CrossAxisAlignment.stretch: CrossAxisAlignment.start,
            children: this.children,
          ),
        ),
      ),
    );
  }
}


class SectionTitle extends StatelessWidget {
  final String title;
  final bool animated;
  final Color? overrideColor;
  const SectionTitle(this.title, {
    this.animated = false,
    this.overrideColor,
  });


  @override
  Widget build(BuildContext context) {
    final textStyle = DefaultTextStyle.of(context).style;
    final style = textStyle.copyWith(
      color: overrideColor ?? RightContrast(
        Theme.of(context), 
        fallbackOnTextTheme: true
      ).onCanvas,
      fontWeight: textStyle.fontWeight?.increment,
    );
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 8.0),
      child: animated
        ? AnimatedText(title, style: style)
        : Text(title, style: style),
    );
  }
  
}

