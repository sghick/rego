import 'dart:convert';
import 'dart:io';

import 'package:dio/adapter.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:rego/app/basic_config.dart';
import 'package:rego/cache/simple_cache.dart';
import 'package:rego/log/logger.dart';
import 'package:rego/net/cookie/cookie_manager.dart';
import 'package:rego/net/cookie/persist_cookie_jar.dart';

import 'http_exception.dart';
import 'http_time.dart';

class FlutterTransformer extends DefaultTransformer {
  FlutterTransformer() : super(jsonDecodeCallback: _parseJson);
}

_parseAndDecode(String response) {
  return jsonDecode(response);
}

_parseJson(String text) {
  return compute(_parseAndDecode, text);
}

typedef Map<String, dynamic> HttpHeaderGenerator();

class HttpParams<T> {
  static const maxRetryTimes = 3;
  final String method;
  final String url;
  final Map<String, dynamic> queries;
  final dynamic body;
  final CancelToken cancelToken;
  final T Function(Map<String, dynamic> json) jsonParser;
  final bool cacheResponse;
  final int retryTimes;
  final int customConnectTimeout;
  final int customReceiveTimeout;
  final Map<String, dynamic> customHeaders;
  final bool syncLocalTime;

  String get key {
    return url;
  }

  HttpParams(this.method, this.url,
      {this.queries,
      this.body,
      this.cancelToken,
      this.jsonParser,
      this.cacheResponse = false,
      this.retryTimes = maxRetryTimes,
      this.customHeaders,
      this.customConnectTimeout,
      this.customReceiveTimeout,
      this.syncLocalTime = false});

  factory HttpParams.get(
    url, {
    queries,
    cancelToken,
    jsonParser,
    cacheResponse = false,
    retryTimes = maxRetryTimes,
    customHeaders,
    customConnectTimeout = 5000,
    customReceiveTimeout = 5000,
  }) {
    return HttpParams(
      "GET",
      url,
      queries: queries,
      cancelToken: cancelToken,
      jsonParser: jsonParser,
      cacheResponse: cacheResponse ?? false,
      retryTimes: retryTimes,
      customHeaders: customHeaders,
      customConnectTimeout: customConnectTimeout,
      customReceiveTimeout: customReceiveTimeout,
    );
  }

  factory HttpParams.post(
    url, {
    body,
    cancelToken,
    jsonParser,
    cacheResponse = false,
    retryTimes = maxRetryTimes,
    customHeaders,
    customConnectTimeout = 5000,
    customReceiveTimeout = 5000,
  }) {
    return HttpParams(
      "POST",
      url,
      body: body,
      cancelToken: cancelToken,
      jsonParser: jsonParser,
      cacheResponse: cacheResponse ?? false,
      retryTimes: retryTimes,
      customHeaders: customHeaders,
      customConnectTimeout: customConnectTimeout,
      customReceiveTimeout: customReceiveTimeout,
    );
  }

  bool isHttpUrl() {
    return url.startsWith("http");
  }

  @override
  String toString() {
    return "HttpRequest ($method) : $url : ${queries ?? {}} , ${body ?? {}}";
  }
}

typedef Future<HttpErrorHandleResult> HttpErrorHandler(
    Exception e, StackTrace s);

class HttpErrorHandleResult {
  static HttpErrorHandleResult getDefault() {
    return HttpErrorHandleResult(
        error: unknownHttpException, shouldRetry: false);
  }

  HttpException error;
  bool shouldRetry;

  HttpErrorHandleResult({this.error, this.shouldRetry = false});
}

class HttpHelper {
  final int connectTimeout;
  final int receiveTimeout;
  final bool useCookie;
  final Map<String, dynamic> commonHeaders;
  final HttpHeaderGenerator commonHeaderGenerator;
  final int maxRetryTimes;
  final int maxRetryDuration;
  final HttpErrorHandler httpErrorHandler;
  //代理ip及端口
  final String proxyAddress;

  Dio _dio;
  String _cookieDirPath;
  PersistCookieJar _cookieJar;

  HttpHelper(
      {this.connectTimeout = 5 * 1000,
      this.receiveTimeout = 5 * 1000,
      this.useCookie = false,
      this.commonHeaders,
      this.commonHeaderGenerator,
      this.maxRetryTimes = 3,
      this.maxRetryDuration = 20 * 1000,
      this.httpErrorHandler,
      this.proxyAddress}) {
    _dio = Dio(BaseOptions(
        connectTimeout: connectTimeout,
        receiveTimeout: receiveTimeout,
        headers: _headers()));
    // 设置代理用来调试应用
    if(proxyAddress!=null && proxyAddress.isNotEmpty){
      (_dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
          (client) {
        client.findProxy = (Uri) {
          // 用1个开关设置是否开启代理
          return 'PROXY $proxyAddress';
        };
        client.badCertificateCallback =
            (X509Certificate cert, String host, int port) => true;
        // ignore: unnecessary_statements
      };
    }
    _dio.transformer = new FlutterTransformer();
    if (useCookie) {
      _cookieDirPath = basicConfig.appDirectory.path + "/.cookies/";
      _cookieJar = PersistCookieJar(dir: _cookieDirPath);
      _dio.interceptors.add(CookieManager(_cookieJar));
    }
    _dio.interceptors.add(LoggerInterceptor());
  }

  Map<String, dynamic> _headers() {
    if (commonHeaderGenerator == null) {
      return commonHeaders;
    }
    Map<String, dynamic> headers = {};
    if (commonHeaders != null) {
      headers.addAll(commonHeaders);
    }
    if (commonHeaderGenerator != null) {
      var genHeaders = commonHeaderGenerator();
      if (genHeaders != null) headers.addAll(genHeaders);
    }
    return headers;
  }

  Future<T> request<T>(HttpParams params) async {
    if (!params.isHttpUrl()) {
      return Future<T>.error(hostInvalidException);
    }
    var retryCounter = 0;
    var retryStartTime = DateTime.now().millisecondsSinceEpoch;
    Response resp;

    while (retryCounter++ < maxRetryTimes) {
      try {
        logV("Send Http Request($retryCounter)：$params");
        RequestOptions customOptions = RequestOptions(
            method: params.method,
            headers: params.customHeaders,
            connectTimeout: params.customConnectTimeout,
            receiveTimeout: params.customReceiveTimeout);
        resp = await _dio.request(params.url,
            options: customOptions,
            queryParameters: params.queries,
            data: params.body,
            cancelToken: params.cancelToken);
        logV(
            "Receive Http Response($retryCounter)：Code=${resp?.statusCode}, Data=${resp?.data}, Headers=${resp.headers}");

        if (params.syncLocalTime) {
          _syncLocalTime(resp);
        }

        return new Future<T>(() {
          if (params.jsonParser == null) {
            //No need the response.
            return null;
          }
          try {
            T data = params.jsonParser(resp.data);
            if (params.cacheResponse) {
              _updateCache(params.key, data);
            }
            return data;
          } catch (e) {
            logI("HttpHelper parse json object failed: $e");
            return Future<T>.error(e);
          }
        });
      } catch (e, s) {
        if (params.syncLocalTime && e is DioError) {
          _syncLocalTime(e.response);
        }

        HttpErrorHandleResult res;
        if (httpErrorHandler != null) {
          res = await httpErrorHandler(e, s);
        } else {
          res = _defaultHttpErrorHandler(e, s);
        }
        var now = DateTime.now().millisecondsSinceEpoch;
        if (!res.shouldRetry ||
            now - retryStartTime > maxRetryDuration ||
            retryCounter >= maxRetryTimes) {
          logV('Http request finish retry loop after $retryCounter times.');
          return Future<T>.error(res.error);
        }
      }
    }
    // This should not happen.
    logE('HttpHelper retry loop not produce certain result.');
    return Future<T>.error(unknownHttpException);
  }

  HttpErrorHandleResult _defaultHttpErrorHandler(Exception e, StackTrace s) {
    Exception error = unknownHttpException;
    bool shouldRetry = false;
    if (e is DioError) {
      logV(
        'HttpHelper get DioError. Type=${e.type}, Response=${e.response}',
        e,
      );
      switch (e.type) {
        case DioErrorType.RESPONSE:
          if (e.response != null && e.response.statusCode / 100 == 5) {
            error = serverHttpException;
          }
          break;
        case DioErrorType.CANCEL:
          error = cancelHttpException;
          break;
        default:
          break;
      }
    } else {
      logE("HttpHelper found Non-DioError: ", e, s);
    }
    return HttpErrorHandleResult(error: error, shouldRetry: shouldRetry);
  }

  void _updateCache<T>(String key, T data) {
    if (key == null || key.isEmpty) {
      logD("HttpHelper save cache failed: empty key.");
      return;
    }
    simpleCache.put(key, data).then((v) {
      logV("HttpHelper save cache successfully. key=$key");
    }).catchError((e, s) {
      logD("HttpHelper save cache failed. key=$key, $e,$s");
    });
  }

  Future<void> clearCookie(String host) async {
    return Future<void>(() {
      if (host != null) {
        _cookieJar.delete(Uri.parse(host), true);
      }
      logV("Clear cookie for $host.");
    });
  }

  void _syncLocalTime(Response resp) {
    String dateStr = resp?.headers?.value('Date');
    if (dateStr != null) {
      try {
        updateHttpTimeOffset(HttpDate.parse(dateStr));
      } catch (e) {
        logE('_syncLocalTime failed. http date=$dateStr');
      }
    }
  }
}

class LoggerInterceptor extends Interceptor {
  //TODO
  @override
  Future onRequest(RequestOptions options) {
    logV("Send Http Request：Request Headers=${options.headers}");
    return super.onRequest(options);
  }

  @override
  Future onResponse(Response response) {
    return super.onResponse(response);
  }

  @override
  Future onError(DioError err) {
    return super.onError(err);
  }
}
