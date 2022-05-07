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
