import 'dart:math';

extension IntExt on int {
  int between(int minLimit, int maxLimit) {
    return min(max(this, minLimit), maxLimit);
  }
}
