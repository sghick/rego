

import 'package:intl/intl.dart';

/// 格式化成日期字符串
String formatDateTime(String pattern, int dateInSeconds) {
  DateTime date = DateTime.fromMillisecondsSinceEpoch(dateInSeconds * 1000);
  return DateFormat(pattern).format(date);
}

String formatTime(int dateInSeconds) {
  DateTime date = DateTime.fromMillisecondsSinceEpoch(dateInSeconds * 1000);
  String y = _fourDigits(date.year);
  String m = _twoDigits(date.month);
  String d = _twoDigits(date.day);
  String h = _twoDigits(date.hour);
  String min = _twoDigits(date.minute);
  String sec = _twoDigits(date.second);
  return "$y-$m-$d $h:$min:$sec";
}

String formatTimeCN(int dateInSeconds) {
  DateTime date = DateTime.fromMillisecondsSinceEpoch(dateInSeconds * 1000);
  String y = _fourDigits(date.year);
  String m = _twoDigits(date.month);
  String d = _twoDigits(date.day);
  String h = _twoDigits(date.hour);
  String min = _twoDigits(date.minute);
  String sec = _twoDigits(date.second);
  return "$y年$m月$d日 $h:$min:$sec";
}

String formatDate(int dateInSeconds) {
  DateTime date = DateTime.fromMillisecondsSinceEpoch(dateInSeconds * 1000);
  String y = _fourDigits(date.year);
  String m = _twoDigits(date.month);
  String d = _twoDigits(date.day);
  return "$y-$m-$d";
}

String formatDateCN(int dateInSeconds) {
  DateTime date = DateTime.fromMillisecondsSinceEpoch(dateInSeconds * 1000);
  String y = _fourDigits(date.year);
  String m = _twoDigits(date.month);
  String d = _twoDigits(date.day);
  return "$y年$m月$d日";
}

String _fourDigits(int n) {
  int absN = n.abs();
  String sign = n < 0 ? "-" : "";
  if (absN >= 1000) return "$n";
  if (absN >= 100) return "${sign}0$absN";
  if (absN >= 10) return "${sign}00$absN";
  return "${sign}000$absN";
}

String _sixDigits(int n) {
  assert(n < -9999 || n > 9999);
  int absN = n.abs();
  String sign = n < 0 ? "-" : "+";
  if (absN >= 100000) return "$sign$absN";
  return "${sign}0$absN";
}

String _threeDigits(int n) {
  if (n >= 100) return "$n";
  if (n >= 10) return "0$n";
  return "00$n";
}

String _twoDigits(int n) {
  if (n >= 10) return "$n";
  return "0$n";
}

String formatBytesAsGB(int bytes,
    {int digits = 0, bool suffix = true, bool space = false}) {
  return (bytes.toDouble() / 1073741824).toStringAsFixed(digits) +
      (space ? " " : "") +
      (suffix ? "GB" : "");
}

String formatBytesAsMB(int bytes,
    {int digits = 0, bool suffix = true, bool space = false}) {
  return (bytes.toDouble() / 1048576).toStringAsFixed(digits) +
      (space ? " " : "") +
      (suffix ? "MB" : "");
}

String formatBytesAsKB(int bytes,
    {int digits = 0, bool suffix = true, bool space = false}) {
  return (bytes.toDouble() / 1024).toStringAsFixed(digits) +
      (space ? " " : "") +
      (suffix ? "KB" : "");
}

String formatBytes(int bytes,
    {int digits = 0, bool suffix = true, bool space = false}) {
  if (bytes >= 1024 ^ 3) {
    return formatBytesAsGB(bytes, digits: digits, suffix: suffix, space: space);
  }
  if (bytes >= 1024 ^ 2) {
    return formatBytesAsMB(bytes, digits: digits, suffix: suffix, space: space);
  }
  if (bytes >= 1024) {
    return formatBytesAsKB(bytes, digits: digits, suffix: suffix, space: space);
  }
  return space ? '0 KB' : '0KB';
}

String formatMoney(int cents, {int digits = 2}) {
  return (cents / 100).toDouble().toStringAsFixed(digits);
}