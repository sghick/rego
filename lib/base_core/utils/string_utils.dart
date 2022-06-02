import 'dart:convert';

import 'package:crypto/crypto.dart';

String md5Hex(String input) {
  return md5.convert(utf8.encode(input)).toString();
}

extension StringExt on String {
  int toInt() {
    return isEmpty ? 0 : int.parse(this);
  }
}
