import 'package:rego/models/exception.dart';

class HttpException extends RegoException {
  HttpException({msg, detail, raw}) : super(msg: msg, detail: detail, raw: raw);

  @override
  String toString() {
    return 'HttpException: msg=$msg, detail=$detail';
  }
}

final HttpException timeoutHttpException = HttpException(msg: "请求超时，请检查网络后重试～");
final HttpException unknownHttpException = HttpException(msg: "请求失败，请您稍后再试～");
final HttpException serverHttpException = HttpException(msg: "服务器开小差了，请您稍后再试～");
final HttpException cancelHttpException =
    HttpException(detail: 'Canceled By User.');
final HttpException hostInvalidException =
    new HttpException(msg: "请求失败，请下载最新版APP～");
