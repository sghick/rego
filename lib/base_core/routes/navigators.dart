import 'package:flutter/material.dart';
import 'navigator_observer.dart';

abstract class AppNavigator {
  GlobalKey<NavigatorState> get navigatorKey;

  NavigationHistoryObserver get navigationHistoryObserver;
}

abstract class PageRedisplayCallback {
  void onPageRedisplay(dynamic newData);
}

enum RouteMode {
  /// 默认路由，新增一个Route进入历史栈
  NORMAL,

  /// 如果存在多个命名路由X，清空最下层X之上的Route，不主动刷新X
  CLEAR_TOP,

  /// 清空当前历史栈，最新的页面成为栈内唯一页面
  CLEAR_ALL,

  /// 如果存在多个命名路由X，清空最下层X之上的Route，重新创建X
  CLEAR_AND_RECREATE,

  /// 如果存在多个命名路由X，清空最下层X之上的Route，调用X的onPageRedisplay()
  CLEAR_AND_REDISPLAY,
}

final GlobalKey<NavigatorState> globalNavigatorKey =
    GlobalKey<NavigatorState>();

Future<T?> goPush<T extends Object>(BuildContext context, Widget page) {
  return navigatorState(context)!
      .push(MaterialPageRoute(builder: (BuildContext context) {
    return page;
  }));
}

Future<T?> goPage<T extends Object>(
  String target, {
  Object? arguments,
  RouteMode mode = RouteMode.NORMAL,
  bool clearToLast = false,
  BuildContext? context,
}) {
  var nav = navigatorState(context);

  if (mode == RouteMode.CLEAR_ALL) {
    _clearRoutes(nav!, null);
    return nav.pushNamed(target, arguments: arguments);
  }

  var oldRoute = navigatorObserver.searchHistory(target);

  if (mode == RouteMode.CLEAR_TOP && oldRoute != null) {
    _clearRoutes(nav!, oldRoute);
    return Future.value();
  }

  if (mode == RouteMode.CLEAR_AND_RECREATE && oldRoute != null) {
    _clearRoutes(nav!, oldRoute);
    return nav.pushReplacementNamed(target, arguments: arguments);
  }

  if (mode == RouteMode.CLEAR_AND_REDISPLAY && oldRoute != null) {
    _clearRoutes(nav!, oldRoute);
    var currentState = navigatorObserver.currentRouteState;
    if (currentState is PageRedisplayCallback) {
      currentState.onPageRedisplay(arguments);
    }
    return Future.value();
  }

  return navigatorState(context)!.pushNamed(target, arguments: arguments);
}

void _clearRoutes(NavigatorState nav, Route? endRoute) {
  nav.popUntil((Route? route) {
    if (endRoute == null) {
      return route == null;
    }
    return route == endRoute;
  });
}

void goBack<T extends Object>({
  String? fromTarget,
  T? result,
  BuildContext? context,
}) {
  if (fromTarget != null) {
    var nav = navigatorState(context);
    if (nav == null) return;
    var oldRoute = navigatorObserver.searchHistory(fromTarget);
    _clearRoutes(nav, oldRoute);
  }
  navigatorState(context)!.pop(result);
}

NavigatorState? navigatorState(BuildContext? context) {
  if (context != null) {
    return Navigator.of(context);
  }
  return globalNavigatorKey.currentState;
}

BuildContext? get navigatorContext {
  return globalNavigatorKey.currentContext;
}
