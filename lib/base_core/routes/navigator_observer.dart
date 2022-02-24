import 'dart:async';
import 'package:built_collection/built_collection.dart';
import 'package:rego/base_core/log/logger.dart';
import 'package:flutter/widgets.dart';

NavigationHistoryObserver navigatorObserver = NavigationHistoryObserver();

class NavigationHistoryObserver extends NavigatorObserver {
  /// A list of all the past routes
  List<Route<dynamic>> _history = <Route<dynamic>>[];
  List<dynamic> _historyState = [];
  List<Route> _preBuildRouteRecord = [];

  /// Gets a clone of the navigation history as an immutable list.
  BuiltList<Route<dynamic>> get history =>
      BuiltList<Route<dynamic>>.from(_history);

  /// Gets the top route in the navigation stack.
  get top => _history.last;

  /// A list of all routes that were popped to reach the current.
  List<Route<dynamic>> _poppedRoutes = <Route<dynamic>>[];

  /// Gets a clone of the popped routes as an immutable list.
  get poppedRoutes => BuiltList<Route<dynamic>>.from(_poppedRoutes);

  /// Gets the next route in the navigation history, which is the most recently popped route.
  get next => _poppedRoutes.last;

  /// A stream that broadcasts whenever the navigation history changes.
  StreamController _historyChangeStreamController =
      StreamController.broadcast();

  /// Accessor to the history change stream.
  get historyChangeStream => _historyChangeStreamController.stream;

  static final NavigationHistoryObserver _singleton =
      NavigationHistoryObserver._internal();

  NavigationHistoryObserver._internal();

  factory NavigationHistoryObserver() {
    return _singleton;
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _poppedRoutes.add(_history.last);
    _history.removeLast();
    _historyState.removeLast();
    _preBuildRouteRecord.remove(route);

    _historyChangeStreamController.add(HistoryChange(
      action: NavigationStackAction.pop,
      newRoute: route,
      oldRoute: previousRoute,
    ));
    debugLog('didPop', route, previousRoute!);
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _history.add(route);
    _poppedRoutes.remove(route);
    _historyState.add(null); // init as null
    _preBuildRouteRecord.add(route);

    _historyChangeStreamController.add(HistoryChange(
      action: NavigationStackAction.push,
      newRoute: route,
      oldRoute: previousRoute,
    ));
    debugLog('didPush', route, previousRoute);
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    int index = _history.indexOf(route);
    _history.remove(route);
    if (index >= 0) {
      _historyState.removeAt(index);
    }
    _preBuildRouteRecord.remove(route);

    _historyChangeStreamController.add(HistoryChange(
      action: NavigationStackAction.remove,
      newRoute: route,
      oldRoute: previousRoute,
    ));
    debugLog('didRemove', route, previousRoute!);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    int oldRouteIndex = _history.indexOf(oldRoute!);
    _history.replaceRange(oldRouteIndex, oldRouteIndex + 1, [newRoute!]);
    _historyState[oldRouteIndex] = null; // init as null
    _preBuildRouteRecord.remove(oldRoute);
    _preBuildRouteRecord.add(newRoute);

    _historyChangeStreamController.add(HistoryChange(
      action: NavigationStackAction.replace,
      newRoute: newRoute,
      oldRoute: oldRoute,
    ));
    debugLog('didReplace', newRoute, oldRoute);
  }

  Route<dynamic>? searchHistory(String routeName) {
    int len = _history.length;
    for (int i = 0; i < len; i++) {
      if (_history[i].settings.name == routeName) {
        return _history[i];
      }
    }
    return null;
  }

  void recordRouteWidget(String routeName, Widget firstWidget) {
//    logD(
//        'recordRouteWidget routeName=$routeName, widget=$firstWidget(${firstWidget.hashCode})');
    int len = _preBuildRouteRecord.length;
    for (int i = len - 1; i >= 0; i--) {
      if (_preBuildRouteRecord[i].settings.name == routeName) {
        int index = _history.indexOf(_preBuildRouteRecord[i]);
        if (_historyState[index] == null)
          _historyState[index] = firstWidget.hashCode;
        return;
      }
    }
  }

  void recordRouteState(Widget firstWidget, dynamic stateIns) {
//    logD(
//        'recordRouteState widget=$firstWidget(${firstWidget.hashCode}), state=$stateIns');
    int len = _historyState.length;
    for (int i = len - 1; i >= 0; i--) {
      if (_historyState[i] == firstWidget.hashCode) {
        _historyState[i] = stateIns;
        return;
      }
    }
  }

  dynamic get currentRouteState {
    return _historyState.last;
  }

  void debugLog(String method, Route<dynamic>? r1, Route<dynamic>? r2) {
    if (!isDevMode) return;
    String name1 = r1?.settings.name ?? 'NULL';
    String name2 = r2?.settings.name ?? 'NULL';
    logD("NavigatorObserver $method, route1($name1)=$r1, route2($name2)=$r2");

    String trace = "";
    history.forEach((v) {
      trace += (v.settings.name ?? 'NULL') + ' -> ';
    });
    bool clean = _historyState.length == _history.length &&
        _history.length == _preBuildRouteRecord.length;
    logD('Navigator page history : $trace. Clean=$clean');

//    trace = "";
//    _historyState.forEach((e) {
//      trace += "$e -> ";
//    });
//    logD('Navigator page states : $trace');
  }
}

/// A class that contains all data that needs to be broadcasted through the history change stream.
class HistoryChange {
  HistoryChange({this.action, this.newRoute, this.oldRoute});

  final NavigationStackAction? action;
  final Route<dynamic>? newRoute;
  final Route<dynamic>? oldRoute;
}

enum NavigationStackAction { push, pop, remove, replace }
