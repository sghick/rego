import 'dart:io';

import 'package:device_info/device_info.dart';
import 'package:package_info/package_info.dart';
import 'package:path_provider/path_provider.dart';

BasicConfig basicConfig = BasicConfig();

class BasicConfig {
  Directory appDirectory;
  String appName;
  String versionName;
  int versionCode;
  String os;
  String osVersion;
  String phoneBrand;
  String phoneModel;

  Future<void> init() async {
    appDirectory = await getApplicationDocumentsDirectory();
    var pInfo = await PackageInfo.fromPlatform();
    appName = pInfo.packageName;
    versionName = pInfo.version;
    versionCode = _versionCode(versionName);

    DeviceInfoPlugin dv = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      var info = await dv.androidInfo;
      phoneBrand = info.brand;
      phoneModel = info.model;
      os = "Android";
      osVersion = info.version.sdkInt?.toString();
    } else {
      var info = await dv.iosInfo;
      os = info.systemName;
      osVersion = info.systemVersion;
      phoneBrand = "iPhone";
      phoneModel = info.model;
    }
    return Future.value();
  }

  static final BasicConfig _ins = BasicConfig._internal();

  factory BasicConfig() {
    return _ins;
  }

  BasicConfig._internal();
}

int _versionCode(String versionName) {
  List<String> versionCmp = versionName.split('.');
  String code = '';
  for(int i = 0; i < versionCmp.length; i++) {
    if(versionCmp[i].length == 1) {
      code = code + '0' + versionCmp[i];
    } else {
      code = code + versionCmp[i];
    }
  }
  return int.tryParse(code) ?? 0;
}
