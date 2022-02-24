import 'dart:ui';

extension ColorExt on Color {
  /// Prefixes a hash sign if [leadingHashSign] is set to `true` (default is `true`).
  String toRGBString({bool leadingHashSign = true}) =>
      '${leadingHashSign ? '#' : ''}'
      '${alpha.toRadixString(16).padLeft(2, '0')}'
      '${red.toRadixString(16).padLeft(2, '0')}'
      '${green.toRadixString(16).padLeft(2, '0')}'
      '${blue.toRadixString(16).padLeft(2, '0')}';

  static Color fromRGBValueO(int rgbValue, double opacity) {
    int alpha = ((opacity * 0xff ~/ 1) & 0xff) << 24;
    int value = alpha | rgbValue;
    return Color(value);
  }

  static Color fromRGBValue(int rgbValue) {
    return fromRGBValueO(rgbValue, 1);
  }

  static Color fromRGBStringO(String rgbString, double opacity) {
    final buffer = StringBuffer();
    buffer.write(rgbString.replaceFirst('#', ''));
    if (buffer.length == 6) {
      return fromRGBValueO(int.parse(buffer.toString(), radix: 16), opacity);
    }
    return fromRGBValueO(0, opacity);
  }

  static Color fromRGBString(String rgbString) {
    return fromRGBStringO(rgbString, 1);
  }
}
