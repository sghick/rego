import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

DiskCache diskCache = DiskCache();

class DiskCache extends BaseCacheManager {
  static const key = "diskcache";
  static const cache_days = 30;
  static const cache_days_in_millisecond = cache_days * 24 * 60 * 60 * 1000;
  static const cache_files = 100;

  static DiskCache _instance;

  factory DiskCache() {
    if (_instance == null) {
      _instance = new DiskCache._();
    }
    return _instance;
  }

  DiskCache._()
      : super(key,
      maxAgeCacheObject: Duration(days: cache_days),
      maxNrOfCacheObjects: cache_files);

  Future<String> getFilePath() async {
    var appDir = await getApplicationDocumentsDirectory();
    return join(appDir.path, key);
  }

  @override
  FileInfo getFileFromMemory(String url) {
    return super.getFileFromMemory(url);
  }

  @override
  Future<FileInfo> getFileFromCache(String url, {bool ignoreMemCache = false}) {
    FileInfo memInfo = getFileFromMemory(url);
    if (memInfo != null) {
      return Future<FileInfo>.value(memInfo);
    }
    return super.getFileFromCache(url);
  }
}
