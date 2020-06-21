import 'package:flutter/material.dart';


String colorToHex(Color c){
  return 
  //"#" + 
    (
      // c.alpha  .toRadixString(16).padLeft(2,'0') +
      c.red    .toRadixString(16).padLeft(2,'0') +
      c.green  .toRadixString(16).padLeft(2,'0') +
      c.blue   .toRadixString(16).padLeft(2,'0')
    ).toUpperCase();
}