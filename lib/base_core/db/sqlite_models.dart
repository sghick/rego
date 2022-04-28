class CBDBType {
  static const String text = 'TEXT';
  static const String blob = 'BLOB';
  static const String date = 'DATE';
  static const String real = 'REAL';
  static const String integer = 'INTEGER';
  static const String float = 'FLOAT';
  static const String double = 'DOUBLE';
  static const String boolean = 'BOOLEAN';
  static const String smallint = 'Smallint';
  static const String currency = 'Currency';
  static const String varchar = 'Varchar';
  static const String binary = 'Binary';
  static const String time = 'Time';
  static const String timestamp = 'Timestamp';
}

enum CBType {
  value, // 数值
  json, // JSON
}

class CBDBColumn {
  // 字段类型 CBDBType
  final String type;

  // 字段名
  final String name;

  // 是否为主键
  final bool pk;

  // 指定转换器
  final Function? fromDBValue;

  // 指定转换器
  final Function? toDBValue;

  CBDBColumn(
    this.type,
    this.name, {
    this.pk = false,
    this.fromDBValue,
    this.toDBValue,
  });
}
