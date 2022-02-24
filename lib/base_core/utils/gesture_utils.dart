import 'package:flutter/cupertino.dart';

void hideKeyboard(BuildContext context) {
  FocusScope.of(context).requestFocus(FocusNode());
}

void endEdit(BuildContext context) {
  FocusScope.of(context).requestFocus(FocusNode());
}
