class EmptyUtils {
  static bool isEmptyList(List? obj) {
    if (obj == null) return true;
    if (obj is List) return obj.isEmpty;
    return false;
  }

  static bool isEmptyString(String? obj) {
    if (obj == null) return true;
    if (obj is String) return obj.isEmpty;
    return false;
  }
}
