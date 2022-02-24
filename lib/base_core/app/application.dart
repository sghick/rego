import 'package:rego/base_core/log/logger.dart';
import 'package:flutter/material.dart';

abstract class Application {
  void start();

  Widget buildAppWidget();

  String get title;

  ThemeData get theme;

  bool get debugShowCheckedModeBanner;

  Iterable<Locale> get supportedLocales;

  Iterable<LocalizationsDelegate<dynamic>> get localizationsDelegates;

  TransitionBuilder get builder;

  CacheLimitation get imageCacheLimitation;
}

Future coreInit() async {
  loggerInit(LoggerConfig(
    showIsolate: true,
    showTime: true,
  ));

  List<Future> initTasks = [
    // 初始化core libs
  ];
  return Future.wait(initTasks);
}

class CacheLimitation {
  final int maxSizeInBytes;
  final int maxFiles;

  CacheLimitation(this.maxSizeInBytes, this.maxFiles);
}
