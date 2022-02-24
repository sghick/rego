import 'package:wellcomeback/base_core/log/logger.dart';
import 'package:wellcomeback/base_core/routes/navigators.dart';
import 'package:url_launcher/url_launcher.dart';

typedef CheckingCallback = void Function();
typedef Checking = void Function({
CheckingCallback? onPassed,
CheckingCallback? onCanceled,
dynamic checkingType,
});

dynamic jumpGoPage(PageJumpGoPageEvent event) {
  return PageJump.sharedInstance.pageJumpGoPageHandler(event);
}

abstract class AppPageJumper {
  void initAppPageJump() {
    PageJump.sharedInstance.appScheme = appScheme;
    PageJump.sharedInstance.webJumpHandler = webJumpHandler;
    PageJump.sharedInstance.jumpHandlers = jumpHandlers;
    PageJump.sharedInstance.unhandledJumpHandler = unhandledJumpHandler;
    PageJump.sharedInstance.pageJumpGoPageHandler = pageJumpGoPageHandler;
    PageJump.sharedInstance.checkingHandler = checkingHandler;
  }

  String get appScheme;

  PageJumpHandler get webJumpHandler;

  Map<String, PageJumpHandler> get jumpHandlers;

  Checking get checkingHandler;

  PageJumpGoPageAction get pageJumpGoPageHandler => (event) {
    if (event.arguments != null) {
      return goPage(event.target,
          arguments: event.arguments, mode: event.mode);
    } else {
      return goPage(event.target, mode: event.mode);
    }
  };

  PageJumpHandler? get unhandledJumpHandler => null;
}

abstract class PageJumper {
  late String appScheme;
  PageJumpHandler? webJumpHandler;
  late Map<String, PageJumpHandler> jumpHandlers;
  PageJumpHandler? unhandledJumpHandler;
  late PageJumpGoPageAction pageJumpGoPageHandler;
  Checking? checkingHandler;
}

class PageJump with PageJumper {
  static PageJump? _instance;

  static PageJump get sharedInstance {
    if (_instance == null) {
      _instance = PageJump();
    }
    return _instance!;
  }

  void jump(String? url, {dynamic object}) {
    if (url == null || url.isEmpty) {
      return;
    }
    Uri uri = Uri.parse(url);
    String scheme = uri.scheme;
    if (scheme.startsWith(appScheme)) {
      _bdsToJump(url, uri, object);
    } else if (scheme.startsWith('http') || scheme.startsWith('https')) {
      _bdsToHttp(url, uri, object);
    } else {
      launch(url);
    }
  }

  _bdsToJump(String url, Uri uri, dynamic object) {
    PageJumpHandler? handler = jumpHandlers[uri.host] ?? unhandledJumpHandler;
    try {
      if (handler != null) {
        logD('jump:$url');
        handler.activeGoPage(url, uri, object);
      } else {
        logD('未定义handler:$url');
      }
    } catch (e) {
      logD('未定义handler:$url');
    }
  }

  _bdsToHttp(String url, Uri uri, dynamic object) {
    PageJumpHandler? handler = webJumpHandler ?? unhandledJumpHandler;
    try {
      if (handler != null) {
        logD('web jump:$url');
        handler.activeGoPage(url, uri, object);
      } else {
        logD('未定义handler:$url');
      }
    } catch (e) {
      logD('未定义handler:$url');
    }
  }
}

typedef PageJumpParser = dynamic Function(
    String url, Map<String, dynamic>? parameters);

String? parseString(Object? parameters, String name) {
  if ((parameters is Map) && parameters.containsKey(name)) {
    return parameters[name]?.toString();
  }
  return null;
}

int? parseInt(Object? parameters, String name) {
  if ((parameters is Map) && parameters.containsKey(name)) {
    return int.parse(parameters[name]);
  }
  return null;
}

bool? parseBool(Object? parameters, String name) {
  if ((parameters is Map) && parameters.containsKey(name)) {
    return int.parse(parameters[name]) != 0;
  }
  return null;
}

class PageJumpGoPageEvent {
  final String url;
  final String target;
  final RouteMode mode;
  final dynamic arguments;
  final dynamic object;

  PageJumpGoPageEvent(
      this.url, this.target, this.mode, this.arguments, this.object);

  PageJumpGoPageEvent redirect({
    String? url,
    String? target,
    RouteMode? mode,
    dynamic arguments,
    dynamic object,
  }) =>
      PageJumpGoPageEvent(
          url ?? this.url,
          target ?? this.target,
          mode ?? this.mode,
          arguments ?? this.arguments,
          object ?? this.object);
}

typedef PageJumpGoPageAction = dynamic Function(PageJumpGoPageEvent event);

class PageJumpHandler {
  final String target;
  final RouteMode mode;
  final PageJumpParser? parser;
  final PageJumpGoPageAction? action;
  final dynamic checkingType; // 如果为null,则不会调用checkingHandler

  PageJumpHandler(
      this.target, {
        this.mode = RouteMode.NORMAL,
        this.parser,
        this.action,
        this.checkingType,
      });

  Future<T?> activeGoPage<T extends Object>(
      String url, Uri uri, dynamic object) async {
    PageJumpParser parser = this.parser ?? _defaultParser;
    PageJumpGoPageAction action =
        this.action ?? PageJump.sharedInstance.pageJumpGoPageHandler;
    Map? parameters =
    (uri.queryParameters.length != 0) ? uri.queryParameters : null;
    if (this.checkingType != null) {
      if (PageJump.sharedInstance.checkingHandler != null) {
        PageJump.sharedInstance.checkingHandler!(
          onPassed: () {
            PageJumpGoPageEvent event = PageJumpGoPageEvent(
              url,
              target,
              mode,
              parser(url, parameters as Map<String, dynamic>?),
              object,
            );
            action(event);
          },
          onCanceled: () {
            logD('jump requires login');
          },
          checkingType: this.checkingType,
        );
      }
      return Future.value();
    } else {
      PageJumpGoPageEvent event = PageJumpGoPageEvent(
        url,
        target,
        mode,
        parser(url, parameters as Map<String, dynamic>?),
        object,
      );
      return action(event);
    }
  }

  PageJumpParser get _defaultParser => (url, parameters) => parameters;
}
