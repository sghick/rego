import 'package:flutter/material.dart';

class Line extends StatelessWidget {
  final bool vertical;
  final double padding;
  final double crossPadding;
  final Color color;
  final double thickness;
  final double length;

  const Line(
      {Key key,
      this.vertical = false,
      this.padding = 0,
      this.color = const Color(0xFFE0E0E0),
      this.thickness = 0.5,
      this.length = 0,
      this.crossPadding = 0})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (vertical) {
      double height = length > 0 ? length : null;
      return Container(
        color: color,
        margin: EdgeInsets.only(
            top: padding,
            bottom: padding,
            left: crossPadding,
            right: crossPadding),
        width: thickness,
        height: height,
      );
    }

    double width = length > 0 ? length : null;
    return Container(
      color: color,
      margin: EdgeInsets.only(
          left: padding,
          right: padding,
          top: crossPadding,
          bottom: crossPadding),
      height: thickness,
      width: width,
    );
  }
}
