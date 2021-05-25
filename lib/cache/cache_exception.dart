import 'package:rego/models/exception.dart';

class CacheException extends RegoException {
  CacheException(String detail) : super(detail: detail);

  @override
  String toString() {
    return 'CacheException: detail=${detail ?? super.toString()}';
  }
}

final CacheException cacheMissException = CacheException("Cache miss.");
final CacheException cacheReadException = CacheException("Cache read error.");
final CacheException cacheParseException = CacheException("Cache parse error.");
final CacheException cacheWriteException = CacheException("Cache write error.");
