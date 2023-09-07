// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';

class Pad extends StatelessWidget {

  const Pad({
    this.top = 0,
    this.bottom = 0,
    this.left = 0,
    this.right = 0,
    this.horizontal = 0,
    this.vertical = 0,
    this.all = 0,
    this.child,
    super.key,
  });

  final double top;
  final double bottom;
  final double left;
  final double right;
  final double horizontal;
  final double vertical;
  final double all;

  final Widget? child;

  const Pad.horizontal12({
    this.top = 0,
    this.bottom = 0,
    this.left = 0,
    this.right = 0,
    this.horizontal = 12,
    this.vertical = 0,
    this.all = 0,
    this.child,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        top: all + vertical + top,
        bottom: all + vertical + bottom,
        right: all + horizontal + right,
        left: all + horizontal + left,
      ),
      child: child,
    );
  }
}

class Al extends StatelessWidget {

  const Al({
    super.key,
    required this.alignment,
    required this.child,
  });
  const Al.center({
    required this.child,
    super.key,
  }): alignment = Alignment.center;
  const Al.centerLeft({
    required this.child,
    super.key,
  }): alignment = Alignment.centerLeft;
  const Al.centerRight({
    required this.child,
    super.key,
  }): alignment = Alignment.centerRight;
  const Al.topCenter({
    required this.child,
    super.key,
  }): alignment = Alignment.topCenter;
  const Al.bottomCenter({
    required this.child,
    super.key,
  }): alignment = Alignment.bottomCenter;
  const Al.topLeft({
    required this.child,
    super.key,
  }): alignment = Alignment.topLeft;
  const Al.bottomLeft({
    required this.child,
    super.key,
  }): alignment = Alignment.bottomLeft;
  const Al.topRight({
    required this.child,
    super.key,
  }): alignment = Alignment.topRight;
  const Al.bottomRight({
    required this.child,
    super.key,
  }): alignment = Alignment.bottomRight;

  final Alignment alignment;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: child,
    );
  }
}