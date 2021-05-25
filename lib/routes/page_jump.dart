import 'package:rego/log/logger.dart';
import 'package:rego/routes/navigators.dart';

typedef CheckLoginCallback = void Function();
typedef CheckLogin = void Function(
    {CheckLoginCallback onPassed, CheckLoginCallback onCanceled});

abstract class AppPageJumper {
  void initAppPageJump() {
    PageJump.sharedInstance.appScheme = appScheme;
    PageJump.sharedInstance.webJumpHandler = webJumpHandler;
    PageJump.sharedInstance.jumpHandlers = jumpHandlers;
    PageJump.sharedInstance.unhandledJumpHandler = unhandledJumpHandler;
    PageJump.sharedInstance.checkLoginHandler = checkLoginHandler;
    logD('初始化AppPageJump');
  }

  String get appScheme;

  PageJumpHandler get webJumpHandler;

  Map<String, PageJumpHandler> get jumpHandlers;

  CheckLogin get checkLoginHandler;

  PageJumpHandler get unhandledJumpHandler => null;
}

abstract class PageJumper {
  String appScheme;
  PageJumpHandler webJumpHandler;
  Map<String, PageJumpHandler> jumpHandlers;
  PageJumpHandler unhandledJumpHandler;
  CheckLogin checkLoginHandler;
}

class PageJump with PageJumper {
  static PageJump _instance;

  static PageJump get sharedInstance {
    if (_instance == null) {
      _instance = PageJump();
    }
    return _instance;
  }

  void jump(String url) {
    if (url == null || url.isEmpty) {
      return;
    }
    Uri uri = Uri.parse(url);
    String scheme = uri.scheme;
    if (scheme.startsWith(appScheme)) {
      _bdsToJump(url, uri);
    } else if (scheme.startsWith('http') || scheme.startsWith('https')) {
      _bdsToHttp(url, uri);
    }
  }

  _bdsToJump(String url, Uri uri) {
    PageJumpHandler handler = jumpHandlers[uri.host] ?? unhandledJumpHandler;
    try {
      if (handler != null) {
        logD('jump:$url');
        handler.activeGoPage(url, uri);
      } else {
        logD('未定义handler:$url');
      }
    } catch (e) {
      logD('未定义handler:$url');
    }
  }

  _bdsToHttp(String url, Uri uri) {
    PageJumpHandler handler = webJumpHandler ?? unhandledJumpHandler;
    try {
      if (handler != null) {
        logD('web jump:$url');
        handler.activeGoPage(url, uri);
      } else {
        logD('未定义handler:$url');
      }
    } catch (e) {
      logD('未定义handler:$url');
    }
  }
}

typedef PageJumpParser = dynamic Function(
    String url, Map<String, dynamic> parameters);

String parseString(Map<String, dynamic> parameters, String name) {
  if ((parameters is Map) && parameters.containsKey(name)) {
    return parameters[name]?.toString();
  }
  return null;
}

int parseInt(Map<String, dynamic> parameters, String name) {
  if ((parameters is Map) && parameters.containsKey(name)) {
    return int.parse(parameters[name]);
  }
  return null;
}

bool parseBool(Map<String, dynamic> parameters, String name) {
  if ((parameters is Map) && parameters.containsKey(name)) {
    return int.parse(parameters[name]) != 0;
  }
  return null;
}

typedef PageJumpGoPageAction = dynamic Function(
    String url, Object arguments, RouteMode mode);

class PageJumpHandler {
  final String target;
  final RouteMode mode;
  final PageJumpParser parser;
  final PageJumpGoPageAction action;
  final bool loginRequired;

  PageJumpHandler(this.target, {
    this.mode = RouteMode.NORMAL,
    this.parser,
    this.action,
    this.loginRequired = false,
  });

  Future<T> activeGoPage<T extends Object>(String url, Uri uri) async {
    PageJumpParser parser = this.parser ?? _defaultParser;
    PageJumpGoPageAction action = this.action ?? _defaultAction;
    Map parameters =
    (uri.queryParameters.length != 0) ? uri.queryParameters : null;
    if (loginRequired) {
      if (PageJump.sharedInstance.checkLoginHandler != null) {
        PageJump.sharedInstance.checkLoginHandler(onPassed: () {
          action(url, parser(url, parameters), mode);
        }, onCanceled: () {
          logD('jump requires login');
        });
      }
      return Future.value();
    } else {
      return action(url, parser(url, parameters), mode);
    }
  }

  PageJumpParser get _defaultParser => (url, parameters) => parameters;

  PageJumpGoPageAction get _defaultAction {
    return (url, arguments, mode) {
      if (arguments != null) {
        return goPage(target, arguments: arguments, mode: mode);
      } else {
        return goPage(target, mode: mode);
      }
    };
  }
}
