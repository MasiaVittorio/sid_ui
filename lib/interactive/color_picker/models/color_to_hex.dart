import 'package:flutter/material.dart';

extension ColorToHex on Color {
  static String _pad(int val) => val.toRadixString(16).padLeft(2,'0');
  String get hexString => "${_pad(red)}${_pad(green)}${_pad(blue)}"
    .toUpperCase();
  String get alphaHexString => "${_pad(alpha)}$hexString"
    .toUpperCase();
}
