import 'package:flutter/material.dart';

class FormTextField extends StatelessWidget {
  final validator;
  final String hintText;
  final TextStyle hintStyle;

  final IconData icon;
  final TextInputType keyboardType;
  final bool obscureText;
  final TextEditingController controller;
  final bool smallStyle;
  final Widget suffixWidget;
  final Color backgroundColor;

  FormTextField(
      {Key key,
      this.validator,
      this.hintText,
      this.hintStyle,
      this.icon,
      this.keyboardType,
      this.obscureText = false,
      this.controller,
      this.suffixWidget,
      this.backgroundColor = Colors.blue,
      this.smallStyle = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (smallStyle) {
      return createSmallTextField();
    }
    return createTextField();
  }

  TextFormField createTextField() {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        fillColor: backgroundColor,
        filled: true,
        errorStyle: TextStyle(height: 0.4, fontSize: 10, color: Colors.red),
//        helperText: '',
        errorText: '',
//        helperStyle: TextStyle(height: 1, fontSize: 12, color: Colors.red),
        hintText: hintText,
        hintStyle: hintStyle,
        contentPadding: EdgeInsets.only(top: 12, bottom: 12),
        focusedBorder: null,
        border: OutlineInputBorder(
          borderSide: BorderSide.none,
          borderRadius: BorderRadius.all(Radius.circular(6)),
        ),
        suffix: suffixWidget,
        prefixIcon: Icon(
          icon,
          color: Colors.grey[500],
          size: 22,
        ),
      ),
      style: TextStyle(fontSize: 14, color: Colors.black),
      autofocus: false,
      autocorrect: false,
      cursorColor: Colors.grey[600],
      cursorWidth: 1.3,
      keyboardType: keyboardType,
      validator: validator,
      obscureText: obscureText,
    );
  }

  Widget createSmallTextField() {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        fillColor: Colors.grey[200],
        filled: true,
        errorStyle: TextStyle(
          height: 0.5,
          fontSize: 10,
          color: Colors.red,
        ),
//        helperText: '',
        errorText: '',
//        helperStyle: TextStyle(height: 1, fontSize: 12, color: Colors.red),
        hintText: hintText,
        hintStyle: TextStyle(
          fontSize: 14,
          color: Colors.grey[400],
        ),
        contentPadding: EdgeInsets.only(top: 8, bottom: 8, left: 10, right: 10),
        isDense: true,
        focusedBorder: null,
        border: OutlineInputBorder(
          borderSide: BorderSide.none,
          borderRadius: BorderRadius.all(Radius.circular(4)),
        ),
      ),
      style: TextStyle(fontSize: 14, color: Colors.black),
      autofocus: false,
      autocorrect: false,
      cursorColor: Colors.grey[600],
      cursorWidth: 1.3,
      keyboardType: keyboardType,
      validator: validator,
      obscureText: obscureText,
    );
  }
}

class FormButton extends StatelessWidget {
  final String text;
  final onPressed;
  final bool negative;
  final Color backgroundColor;

  const FormButton(
      {Key key,
      this.text,
      this.onPressed,
      this.negative = false,
      this.backgroundColor = Colors.blue})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 48,
      decoration: BoxDecoration(),
      child: FlatButton(
        child: Text(
          text,
          style: TextStyle(
              color: negative ? Colors.grey[800] : Colors.white, fontSize: 15),
        ),
//        color: negative ? Colors.grey[300] : Color(0xff409EFF),//TODO
        color: backgroundColor,
        onPressed: onPressed,
        shape: RoundedRectangleBorder(
            side: BorderSide(
              color: negative ? Colors.grey[200] : Colors.white,
              width: 1,
            ),
            borderRadius: BorderRadius.circular(6)),
      ),
    );
  }
}

/*
* RaisedButton(
  onPressed: () { },
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(80.0)),
  padding: const EdgeInsets.all(0.0),
  child: Ink(
    decoration: const BoxDecoration(
      gradient: myGradient,
      borderRadius: BorderRadius.all(Radius.circular(80.0)),
    ),
    child: Container(
      constraints: const BoxConstraints(minWidth: 88.0, minHeight: 36.0), // min sizes for Material buttons
      alignment: Alignment.center,
      child: const Text(
        'OK',
        textAlign: TextAlign.center,
      ),
    ),
  ),
)
* */

//class FormPage extends StatelessWidget {
//  final Widget child;
//
//  const FormPage({Key key, this.child}) : super(key: key);
//
//  @override
//  Widget build(BuildContext context) {
//    var screenW = screenWidth(context);
//    var formWidth = min(360.0, screenW - 30);
//    var hPadding = max(15.0, (screenW - formWidth) / 2);
//
//    return GestureDetector(
//        behavior: HitTestBehavior.translucent,
//        onTap: () {
//          hideKeyboard(context);
//        },
//        child: LayoutBuilder(
//          builder: (BuildContext context, BoxConstraints viewportConstraints) {
//            return SingleChildScrollView(
//              padding: EdgeInsets.zero,
//              child: ConstrainedBox(
//                constraints: BoxConstraints(
//                  minHeight: viewportConstraints.maxHeight,
//                ),
//                child: IntrinsicHeight(
//                  child: Column(
//                    children: <Widget>[
//                      Expanded(
//                        child: Container(
//                          padding:
//                              EdgeInsets.fromLTRB(hPadding, 15, hPadding, 15),
//                          decoration: BoxDecoration(color: Colors.white),
//                          child: child,
//                        ),
//                      ),
//                    ],
//                  ),
//                ),
//              ),
//            );
//          },
//        ));
//  }
//}
