import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:rego/routes/navigator_observer.dart';
import 'package:rego/routes/navigators.dart';
import 'package:rego/rego.dart';
import 'package:rego/utils/screen_utils.dart';

final RouteObserver<PageRoute> routeObserver = RouteObserver();

class CacheLimitation {
  final int maxSizeInBytes;
  final int maxFiles;

  CacheLimitation(this.maxSizeInBytes, this.maxFiles);
}

abstract class RegoApplication {
  Future<void> appInit();

  String title();

  List<Widget> globalProviders();

  Map<String, WidgetBuilder> routes();

  String initialRoute();

  /// iPhone6 module
  Size designSize() => Size(375, 667);

  ThemeData get appTheme => ThemeData(
        primarySwatch: Colors.lightBlue,
        primaryColor: Colors.blue[300],
        platform: TargetPlatform.iOS,
        scaffoldBackgroundColor: Color(0xfff5f5f5),
      );

  List<NavigatorObserver> observers() => [navigatorObserver, routeObserver];

  List<DeviceOrientation> appOrientation() => [DeviceOrientation.portraitUp];

  //TODO 根据系统内存分配MemCache
  CacheLimitation imageCacheLimitation() =>
      CacheLimitation(80 * 1024 * 1024, 100);

  void start() {
    WidgetsFlutterBinding.ensureInitialized();
    regoInit().whenComplete(() {
      Future.wait([_innerAppInit(), appInit()]).whenComplete(() {
        Widget mainContent = buildAppWidget();
        if (globalProviders() != null && globalProviders().isNotEmpty) {
          mainContent = MultiProvider(
            providers: globalProviders() ?? [],
            child: buildAppWidget(),
          );
        }
        runApp(mainContent);
      });
    });
  }

  Future<void> _innerAppInit() {
    SystemChrome.setPreferredOrientations(appOrientation());
    PaintingBinding.instance.imageCache.maximumSizeBytes =
        imageCacheLimitation().maxSizeInBytes;
    PaintingBinding.instance.imageCache.maximumSize =
        imageCacheLimitation().maxFiles;
    return Future.value();
  }

  Widget buildAppWidget() {
    return MaterialApp(
        title: title(),
        debugShowCheckedModeBanner: false,
        //国际化处理英文显示
        localizationsDelegates: [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: [
          const Locale('zh', 'CN'),
        ],
        theme: appTheme,

        /// Navigator part
        navigatorKey: globalNavigatorKey,
        navigatorObservers: observers(),
        initialRoute: initialRoute(),
        onGenerateInitialRoutes: (String routeName) {
          final Function builder = (BuildContext context) {
            _initWithContext(context);
            return routes()[routeName](context);
          };
          return [
            _generateRoute(builder, null, RouteSettings(name: routeName))
          ];
        },
        onGenerateRoute: (RouteSettings settings) {
          final String routeName = settings.name;
          final Function pageContentBuilder = routes()[routeName];
          return _generateRoute(
              pageContentBuilder, settings.arguments, settings);
        },
        builder: _routeWrapper);
  }

  Widget _routeWrapper(BuildContext context, Widget child) {
    // forbidden text scaling
    var data = MediaQuery.of(context);
    return MediaQuery(
      data: data.copyWith(textScaleFactor: 1),
      child: child,
    );
  }

  MaterialPageRoute _generateRoute(
      Function builder, dynamic arguments, RouteSettings settings) {
    if (builder == null) return null;
    return MaterialPageRoute(
        builder: (BuildContext context) {
          Widget res;
          if (arguments == null) {
            res = builder(context);
          } else {
            res = builder(context, arguments: arguments);
          }
          if (settings.name != null) {
            navigatorObserver.recordRouteWidget(settings.name, res);
          }
          return res;
        },
        settings: settings);
  }

  void _initWithContext(BuildContext context) {
    ScreenUtil.init(context, designSize: designSize() ?? Size(375, 667));
  }
}
