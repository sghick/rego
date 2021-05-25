import 'package:flutter/material.dart';

import 'dialogs.dart';

class ProgressIndicatorToken {
  final BuildContext context;
  bool shown = false;

  ProgressIndicatorToken(this.context);

  show() {
    if (shown) {
      return;
    }
    shown = true;
    showCustomDialog(
        context: context,
        barrierDismissible: false,
        barrierColor: Color(0x00ffffff),
        builder: (context) {
          return Center(
            child: Container(
                width: 50,
                height: 50,
                child: CircularProgressIndicator(
                  backgroundColor: Colors.transparent,
                )),
          );
        });
  }

  dismiss() {
    if (!shown) {
      return;
    }
    shown = false;
    Navigator.of(context).pop();
  }
}

Future<T> wrapApiRequestIndicator<T>(
    BuildContext context, Future<T> apiRequest) {
  if (context == null || apiRequest == null) return apiRequest;
  ProgressIndicatorToken token = ProgressIndicatorToken(context);
  apiRequest.whenComplete(() {
    token.dismiss();
  });
  token.show();
  return apiRequest;
}
