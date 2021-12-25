import 'package:flutter/material.dart';
import 'package:sid_ui/dialogs/insert_dialog.dart';

class InsertHexDialog extends StatelessWidget {

  final String startingString;
  final void Function(String) onConfirm;

  InsertHexDialog({
    required this.startingString,
    required this.onConfirm,
  });


  @override
  Widget build(BuildContext context) {
    return InsertDialog(
      title: "Hex Color",
      hintText: this.startingString,
      onConfirm: this.onConfirm,
      maxLenght: 6,
      inputType: TextInputType.text,
      checker: (String s) => checkForHexString(s) == false ? "Error" : "",
      labelText: "",
      pasteChecker: this._pasteChecker,
    );
    
  }

  String? _pasteChecker(String input){
    if(input.length < 6) input = input.padLeft(6, '0');
    else if(input.length > 6) input = input.substring(input.length-6);

    if(checkForHexString(input)) 
      return input;
    else 
      return null;
  }
}


bool checkForHexString(String input){
  RegExp _hexcolor = new RegExp(r'^#?([0-9a-fA-F]{3}|[0-9a-fA-F]{6})$');

  bool errorFound = false;
  try {
    hexToColor(input);
  } catch (e) {
    errorFound = true;
  }
  if(errorFound == true) return false;

  return _hexcolor.hasMatch(input);
}

/// Construct a color from a hex code string, of the format RRGGBB.
Color hexToColor(String hexCode) {
  return new Color(int.parse(hexCode.substring(0, 6), radix: 16) + 0xFF000000);
}
