import 'dart:io';

import 'package:flutter/material.dart';
import 'package:rego/utils/string_utils.dart';
import 'package:rego/widgets/text_widgets.dart';

AlertDialog createAlertDialog(BuildContext context,
    {String title,
    Widget content,
    String contentStr,
    Widget customTitle,
    List<Widget> actions,
    String okButton,
    String cancelButton}) {
  Widget titleWidget = isEmptyString(title)
      ? customTitle
      : Text(
          title,
          style: TextStyle(fontSize: 16),
        );

  Widget contentWidget = content;
  if (contentWidget == null && !isEmptyString(contentStr)) {
    contentWidget = Text(
      contentStr,
      style: TextStyle(fontSize: 14, color: Colors.grey[700]),
    );
  }

  List<Widget> actionList = actions;
  if (actionList == null &&
      (!isEmptyString(okButton) || !isEmptyString(cancelButton))) {
    actionList = [];

    var buttonStyle =
        TextStyle(fontSize: 14, decoration: TextDecoration.underline);

    if (!isEmptyString(okButton)) {
      actionList.add(FlatButton(
        child: Text(
          okButton,
          style: buttonStyle,
        ),
        onPressed: () => Navigator.of(context).pop(true),
      ));
    }
    if (!isEmptyString(cancelButton)) {
      actionList.add(FlatButton(
        child: Text(
          cancelButton,
          style: buttonStyle,
        ),
        onPressed: () => Navigator.of(context).pop(false),
      ));
    }
  }

  return AlertDialog(
    title: titleWidget,
    content: contentWidget,
    actions: actionList,
    titlePadding: EdgeInsets.fromLTRB(20, 15, 20, 0),
    contentPadding: EdgeInsets.fromLTRB(20, 15, 20, 0),
    contentTextStyle: TextStyle(fontSize: 14, color: Colors.grey[700]),
  );
}

Future<bool> showSimpleConfirmDialog(
    BuildContext context, String title, String content,
    {String okButton, String cancelButton}) {
  return showDialog<bool>(
      context: context,
      builder: (context) {
        return createAlertDialog(context,
            title: title,
            contentStr: content,
            okButton: okButton,
            cancelButton: cancelButton);
      });
}

Future<T> showCustomDialog<T>({
  @required BuildContext context,
  bool barrierDismissible = true,
  Color barrierColor = const Color(0xa0000000),
  WidgetBuilder builder,
  Duration transitionDuration = Duration.zero,
  RouteTransitionsBuilder transitionBuilder,
}) async {
  final ThemeData theme = Theme.of(context);
  return showGeneralDialog(
    context: context,
    pageBuilder: (BuildContext buildContext, Animation<double> animation,
        Animation<double> secondaryAnimation) {
      final Widget pageChild = Builder(builder: builder);
      return SafeArea(
        child: Builder(builder: (BuildContext context) {
          return theme != null
              ? Theme(data: theme, child: pageChild)
              : pageChild;
        }),
      );
    },
    barrierDismissible: barrierDismissible,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    barrierColor: barrierColor,
    transitionDuration: transitionDuration,
    transitionBuilder: transitionBuilder,
  );
}

Widget _buildMaterialDialogTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child) {
  return ScaleTransition(
    scale: CurvedAnimation(
      parent: animation,
      curve: Curves.easeOut,
    ),
    child: child,
  );
}

Future<bool> showAppUpdateDialog(BuildContext context, dynamic release) {
  //TODO Release POJO
  var releaseNotes = release.releaseNote.split("\n");
  List<Widget> contentWidgets = [
    Row(
      children: <Widget>[
        SimpleText(
          '最新版本：',
          style:
              TextStyle(color: Color(0xff101010), fontWeight: FontWeight.w500),
        ),
        SimpleText(
          'V' + release.versionName,
        ),
      ],
    ),
    SimpleText(
      '新增特性：',
      height: 25,
      style: TextStyle(color: Color(0xff101010), fontWeight: FontWeight.w500),
      alignment: Alignment.centerLeft,
    ),
  ];
  for (String note in releaseNotes) {
    if (isEmptyString(note)) continue;
    contentWidgets.add(SimpleText(
      note,
      alignment: Alignment.centerLeft,
      style: TextStyle(fontSize: 12),
      height: 25,
    ));
  }

  return showCustomDialog<bool>(
      context: context,
      barrierDismissible: !release.mandatory,
      builder: (context) {
        return createAlertDialog(context,
            customTitle: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Spacer(
                  flex: 1,
                ),
                Image(
                    image: AssetImage('images/logo.png'),
                    width: 24,
                    height: 24,
                    fit: BoxFit.cover),
                SimpleText(
                  '  发现新版本',
                  style: TextStyle(fontSize: 18),
                ),
                Spacer(
                  flex: 1,
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: contentWidgets,
            ),
            actions: [
              FlatButton(
                child: SimpleText(
                  '下载安装',
                  style: TextStyle(decoration: TextDecoration.underline),
                ),
                onPressed: () {
                  if (!release.mandatory) {
                    Navigator.of(context).pop(true);
                  }
//                  downloadAPP(release.downloadUrl);
                },
              ),
              FlatButton(
                textColor: Colors.grey[700],
                hoverColor: Colors.grey[200],
                child: SimpleText(
                  release.mandatory ? '退出应用' : '稍后再说',
                  style: TextStyle(decoration: TextDecoration.underline),
                ),
                onPressed: () {
                  if (release.mandatory) {
                    exit(0);
                  } else {
                    Navigator.of(context).pop(false);
                  }
                },
              ),
            ]);
      });
}
