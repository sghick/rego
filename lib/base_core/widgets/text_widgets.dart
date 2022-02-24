import 'package:flutter/material.dart';

class SimpleText extends StatelessWidget {
  final double? height;
  final double? width;
  final Alignment? alignment;
  final String? text;
  final dynamic style;
  final TextOverflow overflow;
  final int? maxLines;
  final bool singleLine;
  final EdgeInsets? contentPadding;
  final EdgeInsets? margin;
  final Color?bkgColor;
  final Color? borderColor;
  final double borderRadius;
  final dynamic onClick;
  final double borderWidth;
  final double? maxWidth;
  final double? maxHeight;

  SimpleText(this.text,
      {Key? key,
      this.height,
      this.width,
      this.style,
      this.alignment = Alignment.center,
      this.overflow = TextOverflow.ellipsis,
      this.maxLines,
      this.singleLine = false,
      this.contentPadding,
      this.margin,
      this.bkgColor,
      this.borderColor,
      this.borderRadius = 0,
      this.onClick,
      this.borderWidth = 1,
      this.maxWidth,
      this.maxHeight})
      : assert(
            style == null || style is TextStyle || style is TextStyleBuilder),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    if (onClick == null) return coreText();
    return GestureDetector(
      onTap: onClick,
      child: coreText(),
    );
  }

  TextStyle? _getStyle() {
    if (style is TextStyle) return style;
    if (style is TextStyleBuilder) return style.build;
    return null;
  }

  Widget coreText() {
    var textStyle = _getStyle();

    TextOverflow? overflow = this.overflow;
    int? maxLines = this.maxLines;
    if (singleLine) {
      overflow = TextOverflow.ellipsis;
      maxLines = 1;
    }

    BoxDecoration? decoration;
    if (bkgColor != null || borderColor != null) {
      decoration = BoxDecoration(
          color: bkgColor,
          border: borderColor == null
              ? null
              : Border.all(color: borderColor!, width: borderWidth),
          borderRadius: BorderRadius.circular(borderRadius));
    }

    BoxConstraints? constraints;
    if (maxHeight != null || maxWidth != null) {
      constraints = BoxConstraints(
          minWidth: 0,
          minHeight: 0,
          maxWidth: maxWidth ?? double.infinity,
          maxHeight: maxHeight ?? double.infinity);
    }

    return Container(
      decoration: decoration,
      constraints: constraints,
      padding: contentPadding,
      margin: margin,
      height: height,
      width: width,
      alignment: alignment,
      child: Text(
        text!,
        style: textStyle,
        overflow: overflow,
        maxLines: maxLines,
      ),
    );
  }
}

class LinkText extends StatefulWidget {
  final double? height;
  final double? width;
  final Alignment alignment;
  final String text;
  final dynamic style;
  final dynamic pressedStyle;
  final double pressedPadding;
  final linkAction;

  LinkText(
    this.text, {
    Key? key,
    this.height,
    this.width,
    this.style,
    this.alignment = Alignment.center,
    this.linkAction,
    this.pressedStyle,
    this.pressedPadding = 0,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _LinkTextState();
  }
}

class _LinkTextState extends State<LinkText> {
  bool isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: content(),
      onTapDown: (TapDownDetails _) {
        setState(() {
          isPressed = true;
        });
      },
      onTapUp: (TapUpDetails _) {
        setState(() {
          isPressed = false;
        });
      },
      onTapCancel: () {
        isPressed = false;
      },
      onTap: widget.linkAction,
    );
  }

  Widget content() {
    if (widget.pressedPadding == 0) return coreText();
    return Container(
      color: Colors.transparent,
      padding: EdgeInsets.only(
          left: widget.pressedPadding, right: widget.pressedPadding),
      child: coreText(),
    );
  }

  Widget coreText() {
    return SimpleText(
      widget.text,
      height: widget.height,
      width: widget.width,
      style: getStyle(),
      alignment: widget.alignment,
    );
  }

  dynamic getStyle() {
    if (!isPressed)
      return widget.style;
    else
      return widget.pressedStyle ?? widget.style;
  }
}

class MutableText extends StatefulWidget {
  final double? height;
  final double? width;
  final Alignment? alignment;
  final String initText;
  final TextStyle? style;

  const MutableText(
      {Key? key,
      this.height = 0,
      this.width,
      this.alignment,
      this.initText = '',
      this.style})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return MutableTextState();
  }
}

class MutableTextState extends State<MutableText> {
  String? text;

  @override
  void initState() {
    super.initState();
    text = widget.initText;
  }

  @override
  Widget build(BuildContext context) {
    return SimpleText(
      text,
      height: widget.height,
      width: widget.width,
      style: widget.style,
      alignment: widget.alignment,
    );
  }

  onTextChanged(String str) {
    if (str == text) {
      return;
    }
    setState(() {
      text = str;
    });
  }
}

class TextStyleBuilder {
  double? _size;
  Color? _color;
  FontWeight? _weight;
  double? _height;

  TextStyleBuilder size(double size) {
    this._size = size;
    return this;
  }

  TextStyleBuilder color(dynamic color) {
    if (color is Color) {
      this._color = color;
    }
    if (color is int) {
      this._color = Color(color);
    }
    return this;
  }

  TextStyleBuilder weight(FontWeight weight) {
    this._weight = weight;
    return this;
  }

  TextStyleBuilder height(double height) {
    this._height = height;
    return this;
  }

  TextStyle get build {
    return TextStyle(
        fontSize: _size, color: _color, fontWeight: _weight, height: _height);
  }
}
