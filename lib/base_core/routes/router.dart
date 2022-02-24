import 'package:flutter/material.dart';

final RouteObserver<PageRoute> routeObserver = RouteObserver();

abstract class AppRouter {
  String get initialRoute;

  InitialRouteListFactory get onGenerateInitialRoutes;

  RouteFactory get onGenerateRoute;

  RouteObserver<PageRoute> get pageRouteObserver => routeObserver;
}
