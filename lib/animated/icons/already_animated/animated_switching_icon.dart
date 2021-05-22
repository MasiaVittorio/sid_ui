import 'package:flutter/material.dart';

class AnimatedSwitchingIcon extends StatefulWidget {
  final AnimatedIconData firstIcon;
  final AnimatedIconData secondIcon;
  final Animation<double?> progress;
  final Color? color;
  final double? size;
  final TextDirection? textDirection;
  final String? semanticLabel;

  AnimatedSwitchingIcon({
    required this.firstIcon,
    required this.secondIcon,
    required this.progress,
    this.color,
    this.size,
    this.textDirection,
    this.semanticLabel,
  });
  @override
  _AnimatedSwitchingIconState createState() => _AnimatedSwitchingIconState();
}

class _AnimatedSwitchingIconState extends State<AnimatedSwitchingIcon> {

  late bool first;

  void listener(){
    if(this.mounted != true)
      return;

    double? v = this.widget.progress.value;
    reactTo(v);
  }

  void reactTo(double? v){
    if(v == 0.0) 
      this.setState((){
        this.first = true;
      });

    else if(v == 1.0) 
      this.setState((){
        this.first = false;
      });
  }

  @override
  void didUpdateWidget(AnimatedSwitchingIcon oldWidget) {

    if(widget.progress is AlwaysStoppedAnimation)
      if(oldWidget.progress.value != widget.progress.value)
        reactTo(widget.progress.value);

    super.didUpdateWidget(oldWidget);
  }

  @override
  void initState() {
    this.first = true;

    this.widget.progress.addListener(listener);

    super.initState();
  }

  @override
  void dispose() {
    this.widget.progress.removeListener(listener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return AnimatedIcon(
      icon: this.first 
        ? this.widget.firstIcon 
        : this.widget.secondIcon,
      progress: this.first 
        ? this.widget.progress as Animation<double>
        : ReverseAnimation(this.widget.progress as Animation<double>),
      color: this.widget.color,
      size: this.widget.size,
      semanticLabel: this.widget.semanticLabel,
      textDirection: this.widget.textDirection,
    );
  }
}