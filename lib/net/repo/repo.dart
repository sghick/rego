import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:rego/cache/simple_cache.dart';
import 'package:rego/log/logger.dart';
import 'package:rego/net/http/http_helper.dart';

abstract class Repo<T> with ChangeNotifier {
  Future<void> clear();
}

abstract class APIRepo<T> extends Repo<T> {
  HttpParams<T> createAPIParams();

  T Function(Map<String, dynamic> json) createParser();

  HttpHelper apiHelper();

  bool beforeDataChanged(T newData) => true;

  T _data;
  bool _isFromCache;
  int _updateTime = 0;

  T get data {
    return _data;
  }

  Future<HttpParams<T>> createAPIParamsAsync() async {
    return null;
  }

  Future<T> updateWithInterval(
      {int seconds = 5, bool withCache = false}) async {
    final int now = DateTime.now().millisecondsSinceEpoch;
    if (now - _updateTime < seconds * 1000) return Future.value(null);
    return update(withCache: withCache);
  }

  Future<T> update({bool withCache = false, bool lazyLoad = false}) async {
    var params = createAPIParams();
    if (params == null) {
      params = await createAPIParamsAsync();
    }
    assert(params != null);

    if (_data == null && withCache) {
      simpleCache.get(params.key, createParser()).then((v) {
        if (_data == null && v.data != null) {
          updateMemData(v.data, true);
        }
      }).catchError((e, s) {
        logD("Repo get cache for ${params.key} failed: ", e, s);
      });
    }

    if (_data != null && !_isFromCache && lazyLoad) {
      // the data won't update so no need to notify listeners.
      return Future<T>.value(_data);
    }

    var request = apiHelper().request<T>(params);
    request.then((data) {
      logV(() {
        var res = data == null ? 'null' : jsonEncode(data);
        return "Repo update success. Params=$params, Data=$res";
      });
      _updateTime = DateTime.now().millisecondsSinceEpoch;
      updateMemData(data, false);
    });
    return request;
  }

  Future<void> clear() {
    final params = createAPIParams();
    assert(params != null);

    var res = simpleCache.remove(params.key);
    updateMemData(null, false);
    return res;
  }

  void updateMemData(T newData, bool isFromCache) {
    if (!beforeDataChanged(newData)) return;
    _data = newData;
    _isFromCache = isFromCache;
    notifyListeners();
  }
}
