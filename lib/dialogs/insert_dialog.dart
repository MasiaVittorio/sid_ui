import 'package:flutter/material.dart';
import 'package:flutter/services.dart';



class InsertDialog extends StatefulWidget {
  InsertDialog({
    required this.onConfirm,
    required this.hintText,
    required this.labelText,
    required this.inputType,
    required this.checker,
    required this.maxLenght,
    this.title = "",
    this.pasteChecker,
  });

  final String? Function(String)? pasteChecker;

  final String title;

  final String hintText;
  final String labelText;
  final void Function(String) onConfirm;
  final TextInputType inputType;
  
  /// checker has to return a string representing the error in an
  /// input. if it returns an empty string, there is no error
  final String Function(String) checker;
  final int maxLenght;

  @override
  _InsertDialogState createState() => _InsertDialogState();
}

class _InsertDialogState extends State<InsertDialog> {

  TextEditingController? _controller;

  String? _clipboardString;

  bool? _pastable;

  @override
  void initState() {
    super.initState();
    
    this._controller = TextEditingController(
      text: this.widget.hintText,
    );
    
    this._pastable = this.widget.pasteChecker != null;

    this._clipboardString = null;
    this._getClipboardAndCheck();
  }

  Future<void> _getClipboardAndCheck() async {
    final cbd = await Clipboard.getData("text/plain");
    setState(() {
      this._clipboardString = this._pasteChecker(cbd!.text);
    });
    return;
  }

  String? _pasteChecker(String? input){
    if(input == null) return null;

    String? output;

    if(this.widget.pasteChecker == null)
      output = input;
    else 
      output = this.widget.pasteChecker!(input);
    
    if(output == null) return null;

    return output.length > this.widget.maxLenght
      ? output.substring(0,this.widget.maxLenght)
      : output;
  }

  @override
  void dispose() {
    this._controller!.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {

    String _errorString = this.widget.checker(this._controller!.text);
    bool _error = _errorString != '';

    final Color? themeTextColor = Theme.of(context).textTheme.bodyText2?.color;

    final Widget _expanded = TextField(
      keyboardType: widget.inputType,
      autofocus: true,
      textAlign: TextAlign.start,
      maxLength: this.widget.maxLenght,
      controller: this._controller,
      textCapitalization: TextCapitalization.characters,
      style: Theme.of(context).textTheme.bodyText2?.copyWith(
        fontSize: 18.0,
        fontWeight: _error ? null : FontWeight.w600,
      ),
      onChanged: (String ts) => setState(() {}),
      decoration: InputDecoration(
        prefixText: "#FF ",
        prefixStyle: TextStyle(
          fontSize: 18.0,
          color: themeTextColor?.withOpacity(0.5),
          fontWeight: FontWeight.w600,
        ),
        errorText: _error ? _errorString : null,
        // hintText: this.widget.hintText,
        labelText: this.widget.labelText,
      ),
    );

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 24,
      title: Text(
        this.widget.title,
        style: TextStyle(
          fontWeight: FontWeight.w700, 
          color: themeTextColor?.withOpacity(0.7)
        ),
      ),
      content: Row(
        children: <Widget>[
          IconButton(
            icon: Icon(
              Icons.close,
            ),
            onPressed: () => setState(() {
              this._controller!.clear();
            }),
          ),
          Expanded(
            child: _expanded
          ),
          IconButton(
            icon: Icon(
              Icons.content_paste,
              color: this._pastable!
                ? this._clipboardString != null
                  ? null
                  : IconTheme.of(context).color != null
                    ? IconTheme.of(context).color!.withOpacity(0.5)
                    : null
                : Colors.transparent
            ),
            onPressed: _pastable! && _clipboardString != null
              ? () async{
                await this._getClipboardAndCheck();

                if(this._pastable == false) return;
                if(this._clipboardString == null) return;

                setState(() {
                  this._controller!.text = this._clipboardString!+'';
                });
              }
              : null
          ),
        ],
      ),
      actions: <Widget>[
        TextButton(
          child: Text("Cancel"),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        TextButton(
          child: Text("Confirm"),
          
          onPressed: _error ? null : () {
            if(this.widget.checker(this._controller!.text) == ''){
              Navigator.pop(context);
              this.widget.onConfirm(this._controller!.text);
            }
          },
        ),
      ],
    );
  }
}

