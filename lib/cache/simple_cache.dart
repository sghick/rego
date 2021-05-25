import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:quiver/cache.dart';
import 'package:rego/log/logger.dart';

import 'cache_exception.dart';
import 'disk_cache.dart';

SimpleCache simpleCache = SimpleCache();

class CachedData<T> {
  static final int freshTimeLimitInMilliseconds = 60 * 60 * 1000; //60 min
  final int createTime;
  final T data;

  CachedData(this.data, this.createTime);

  bool isFresh() {
    return DateTime.now().millisecondsSinceEpoch - createTime <=
        freshTimeLimitInMilliseconds;
  }

  @override
  String toString() {
    return "CachedData: ($createTime) $data";
  }
}

class SimpleCache {
  static SimpleCache _ins;
  static final int maxCacheObjectsNum = 100;

  factory SimpleCache() {
    if (_ins == null) {
      _ins = new SimpleCache._();
    }
    return _ins;
  }

  SimpleCache._();

  MapCache<String, CachedData> memCache =
      MapCache.lru(maximumSize: maxCacheObjectsNum);

  Future<CachedData<T>> get<T>(
      String key, T Function(Map<String, dynamic> json) jsonParser) async {
    CachedData m = await memCache.get(key);
    if (m != null && (m.data is T) && (m is CachedData<T>)) {
      logV("Memory cache hit. Key=$key, Value=$m");
      return Future<CachedData<T>>.value(m);
    }

    var res = compute(_readCacheFileAndParse,
            CacheArgus(key: key, jsonParser: jsonParser))
        .then((v) {
      if (v != null) {
        try {
          memCache.set(key, v);
        } catch (e, s) {
          logD('Cache store data from mem to disk failed: ', e, s);
        }
      }
    });

    return res;
  }

  Future<void> put<T>(String key, T data) {
    memCache.set(
        key, CachedData<T>(data, DateTime.now().millisecondsSinceEpoch));
    return compute(_writeToCacheFile, CacheArgus(key: key, data: data));
  }

  Future<void> remove<T>(String key) {
    memCache.invalidate(key);
    return diskCache.removeFile(key);
  }
}

class CacheArgus<T> {
  String key;
  T data;
  T Function(Map<String, dynamic> json) jsonParser;

  CacheArgus({this.key, this.data, this.jsonParser});
}

Future<CachedData<T>> _readCacheFileAndParse<T>(CacheArgus argus) async {
  FileInfo info = await diskCache.getFileFromCache(argus.key);
  if (info == null || info.file == null || !info.file.existsSync()) {
    logV("Disk cache miss. Key=${argus.key}");
    return Future.error(cacheMissException);
  }

  String content = "";
  try {
    content = info.file.readAsStringSync(encoding: utf8);
    logV(() => "Disk cache hit. Key=${argus.key}, data=$content");
  } catch (e, s) {
    logD("Disk cache read error: ", e, s);
    return Future.error(cacheReadException);
  }

  try {
    T data = argus.jsonParser(jsonDecode(content));
    int createTime = info.validTill.millisecondsSinceEpoch -
        DiskCache.cache_days_in_millisecond;
    var res = CachedData<T>(data, createTime);
    return Future.value(res);
  } catch (e, s) {
    logD("Disk read data parse error:", e, s);
    return Future.error(cacheParseException);
  }
}

Future<void> _writeToCacheFile<T>(CacheArgus argus) async {
  Uint8List bytes;
  try {
    String json = jsonEncode(argus.data);
    List<int> list = utf8.encode(json);
    bytes = Uint8List.fromList(list);
  } catch (e, s) {
    logD("Disk write data parse error: ", e, s);
    return Future.error(cacheParseException);
  }

  try {
    await diskCache.putFile(argus.key, bytes);
  } catch (e, s) {
    logD("Disk cache write error: ", e, s);
    return Future.error(cacheWriteException);
  }
}
