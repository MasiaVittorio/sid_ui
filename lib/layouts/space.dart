import 'package:flutter/material.dart';


class Space extends StatelessWidget {

  const Space.vertical(this.height, {super.key}): width = 0;
  const Space.v(this.height, {super.key}): width = 0;
  const Space.horizontal(this.width, {super.key}): height = 0;
  const Space.h(this.width, {super.key}): height = 0;

  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: width,
    );
  }
}