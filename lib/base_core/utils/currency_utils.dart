import 'package:intl/intl.dart';

extension CBIntCurrency on int {
  String yuan({String? symbol, int? digits}) {
    int decimalDigits =
        digits ?? ((this % 10 == 0) ? ((this % 100 == 0) ? 0 : 1) : 2);
    return NumberFormat.currency(
      symbol: symbol ?? '',
      decimalDigits: decimalDigits,
    ).format(this / 100);
  }

  double get centsToYuan {
    return this / 100;
  }
}

extension CBNumCurrency on num {
  int get yuanToCents {
    return (toDouble() * 100).toInt();
  }
}

extension CBStringCurrency on String {
  int get yuanToCents {
    return isEmpty ? 0 : num.parse(this).yuanToCents;
  }
}
