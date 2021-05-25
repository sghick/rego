import 'dart:math';

import 'package:flutter/material.dart';
import 'package:rego/widgets/text_widgets.dart';

class IconTextButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final double iconSize;
  final Color iconColor;
  final TextStyle textStyle;
  final void Function() onPressed;

  IconTextButton({
    this.label,
    this.icon,
    this.iconSize = 24,
    this.iconColor,
    this.onPressed,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    return InkResponse(
      canRequestFocus: onPressed != null,
      onTap: onPressed,
      child: Container(
        padding: EdgeInsets.only(left: iconSize * 0.5, right: iconSize * 0.5),
        margin: EdgeInsets.only(top: 2, bottom: 2),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              icon,
              color: _iconColor(context),
              size: iconSize,
            ),
            Text(
              label,
              style: textStyle != null
                  ? textStyle
                  : Theme.of(context).primaryTextTheme.button,
            )
          ],
        ),
      ),
      focusColor: Theme.of(context).focusColor,
      hoverColor: Theme.of(context).hoverColor,
      highlightColor: Theme.of(context).highlightColor,
      splashColor: Theme.of(context).splashColor,
      radius: max(
        Material.defaultSplashRadius,
        (iconSize + 10) * 0.7,
        // x 0.5 for diameter -> radius and + 40% overflow derived from other Material apps.
      ),
    );
  }

  Color _iconColor(BuildContext context) {
    if (iconColor != null) {
      return iconColor;
    }
    if (textStyle != null && textStyle.color != null) {
      return textStyle.color;
    }
    return Theme.of(context).primaryTextTheme.button.color;
  }
}

class ImageTextButton extends StatelessWidget {
  final String label;
  final String imagePath;
  final double imageSize;
  final TextStyle textStyle;
  final void Function() onPressed;

  ImageTextButton({
    this.label,
    this.imagePath,
    this.imageSize,
    this.onPressed,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    var image = AssetImage(imagePath);

    return InkResponse(
      canRequestFocus: onPressed != null,
      splashFactory: InkRipple.splashFactory,
      onTap: onPressed,
      child: Container(
        padding: EdgeInsets.only(left: imageSize * 0.5, right: imageSize * 0.5),
        margin: EdgeInsets.only(top: 2, bottom: 2),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Image(
              image: image,
            ),
            Text(
              label,
              style: textStyle != null
                  ? textStyle
                  : Theme.of(context).primaryTextTheme.button,
            )
          ],
        ),
      ),
      focusColor: Theme.of(context).focusColor,
      hoverColor: Theme.of(context).hoverColor,
      highlightColor: Theme.of(context).highlightColor,
      splashColor: Theme.of(context).splashColor,
      radius: max(
        Material.defaultSplashRadius,
        (imageSize + 10) * 0.7,
      ),
    );
  }
}

class TextButton extends StatelessWidget {
  final String text;
  final Color color;
  final onPressed;
  final double fontSize;

  const TextButton(
      {Key key,
      this.text,
      this.color = const Color(0xff409EFF),
      this.onPressed,
      this.fontSize = 14})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Text(
        text,
        style: TextStyle(
          fontSize: fontSize,
          color: color,
          decoration: TextDecoration.underline,
        ),
      ),
    );
  }
}

class SimpleRadio<T> extends StatelessWidget {
  final String title;
  final T value;
  final T groupValue;
  final Color activeColor;
  final onChanged;
  final double labelWidth;
  final bool vertical;
  final bool reverse;

  const SimpleRadio(this.value, this.title, this.groupValue,
      {Key key,
      this.activeColor = const Color(0xFF42A5F5),
      this.onChanged,
      this.labelWidth,
      this.vertical = false,
      this.reverse = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        child: vertical ? verticalVersion(context) : horizontalVersion(context),
        onTap: () {
          onChanged(value);
        });
  }

  Widget horizontalVersion(BuildContext context) {
    List<Widget> elements;
    if (reverse) {
      elements = [radio(), text()];
    } else {
      elements = [text(), radio()];
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: elements,
    );
  }

  Widget verticalVersion(BuildContext context) {
    List<Widget> elements;
    if (reverse) {
      elements = [radio(), text()];
    } else {
      elements = [text(), radio()];
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: elements,
    );
  }

  Widget text() {
    return SimpleText(
      title,
      alignment: vertical ? Alignment.center : Alignment.centerLeft,
      width: labelWidth,
      style: TextStyle(
          color: value == groupValue ? activeColor : Colors.grey[700]),
    );
  }

  Widget radio() {
    return Radio<T>(
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      value: value,
      groupValue: groupValue,
      activeColor: activeColor,
      onChanged: onChanged,
    );
  }
}

class SimpleSwitch extends StatelessWidget {
  final bool active;
  final onChanged;
  final Color activeColor;
  final String activeLabel;
  final String inactiveLabel;

  const SimpleSwitch(
      {Key key,
      this.active,
      this.onChanged,
      this.activeColor = const Color(0xFF42A5F5),
      this.activeLabel = "",
      this.inactiveLabel = ""})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          onChanged(!active);
        },
        child: Row(
          children: <Widget>[
            Switch(
              value: active,
              onChanged: onChanged,
              activeColor: activeColor,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            text()
          ],
        ));
  }

  Widget text() {
    return SimpleText(
      active ? activeLabel : inactiveLabel,
      style: TextStyle(color: active ? activeColor : Colors.grey[700]),
    );
  }
}

class IconTextButton2 extends StatelessWidget {
  final String label;
  final IconData icon;
  final double iconSize;
  final Color iconColor;
  final TextStyle textStyle;
  final void Function() onPressed;

  IconTextButton2({
    this.label,
    this.icon,
    this.iconSize = 24,
    this.iconColor,
    this.onPressed,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              icon,
              color: _iconColor(context),
              size: iconSize,
            ),
            Container(
              height: 2,
            ),
            Text(
              label,
              style: textStyle != null
                  ? textStyle
                  : Theme.of(context).primaryTextTheme.button,
            )
          ],
        ),
      ),
    );
  }

  Color _iconColor(BuildContext context) {
    if (iconColor != null) {
      return iconColor;
    }
    if (textStyle != null && textStyle.color != null) {
      return textStyle.color;
    }
    return Theme.of(context).primaryTextTheme.button.color;
  }
}

class IconTextButton3 extends StatelessWidget {
  final onClick;

  const IconTextButton3({Key key, this.onClick}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RaisedButton(
      onPressed: onClick,
      color: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      padding: const EdgeInsets.all(0),
      child: Ink(
        padding: const EdgeInsets.all(10),
        decoration: const BoxDecoration(
          color: Colors.transparent
//          gradient: LinearGradient(
//            begin: Alignment.centerLeft,
//            end: Alignment.centerRight,
//            colors: [Color(0xffed7498), Color(0xff993c91)],
//          ),
          ,
          borderRadius: BorderRadius.all(Radius.circular(12.0)),
        ),
        child: Container(
          // min sizes for Material buttons
          alignment: Alignment.center,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(
                Icons.visibility,
                color: Colors.grey,
                size: 22,
              ),
              Container(
                height: 2,
              ),
              Text(
                '时间',
                style: TextStyle(color: Colors.grey),
              )
            ],
          ),
        ),
      ),
    );
  }
}
