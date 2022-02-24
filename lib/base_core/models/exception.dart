class RegoException implements Exception {
  final String? msg;
  final String? detail;
  final dynamic raw;
  final dynamic data;

  RegoException({this.msg, this.detail, this.raw, this.data});
}
