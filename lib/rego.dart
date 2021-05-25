library rego;

import 'package:rego/app/basic_config.dart';
import 'package:rego/log/logger.dart';

Future<void> regoInit() async {
  loggerInit(LoggerConfig(
    showIsolate: true,
    showTime: true,
  ));

  List<Future> initTasks = [
    basicConfig.init(),
  ];

  return Future.wait(initTasks);
}
