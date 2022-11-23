class MathUtil {
  static num calculateAddition(String expression) {
    if (!expression.contains('+')) return 0;
    var cmp = expression.split('+');
    num a = num.parse(cmp.first);
    num b = num.parse(cmp.last);
    return a + b;
  }
}
