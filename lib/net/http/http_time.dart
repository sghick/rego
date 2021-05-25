import 'package:ntp/ntp.dart';
import 'package:rego/log/logger.dart';

int _httpTimeOffset = 0;

int get httpTimeOffset {
  return _httpTimeOffset;
}

void updateHttpTimeOffset(DateTime httpDate) {
  if (httpDate == null) return;
  _httpTimeOffset =
      httpDate.millisecondsSinceEpoch - DateTime.now().millisecondsSinceEpoch;
}

Future<void> updateNtpTimeOffset() async {
  return NTP.getNtpOffset(lookUpAddress: 'ntp.aliyun.com').then((offset) {
    _httpTimeOffset = offset;
  }).catchError((e) {
    logE('updateNTPOffset failed: $e');
  });
}
