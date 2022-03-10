export 'package:sqflite/sqflite.dart';

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

abstract class CBSqlite {
  Database? _database;

  String get dbname;

  int? get version;

  OnDatabaseConfigureFn? get onConfigure => null;

  OnDatabaseCreateFn? get onCreate => null;

  OnDatabaseVersionChangeFn? get onUpgrade => null;

  OnDatabaseVersionChangeFn? get onDowngrade => null;

  OnDatabaseOpenFn? get onOpen => null;

  Future<Database> _openSqlite() async {
    var databasesPath = await getDatabasesPath();
    String path = join(databasesPath, dbname);
    return openDatabase(path,
        version: version,
        onConfigure: onConfigure,
        onCreate: onCreate,
        onUpgrade: onUpgrade,
        onDowngrade: onDowngrade,
        onOpen: onOpen);
  }

  Future<Database> get database async {
    if (_database == null) {
      _database = await _openSqlite();
      return Future.value(_database);
    }
    return Future.value(_database);
  }
}

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

class CBDBMapper {
  final String tableName;
  final List<CBDBColumn> columns;
  final Function? fromDBValue;
  final Function? toDBValue;

  CBDBMapper(
    this.tableName,
    this.columns, {
    this.fromDBValue,
    this.toDBValue,
  });

  String sqlForDropTable() {
    return "DROP TABLE IF EXISTS '$tableName'";
  }

  String sqlForCreateTable() {
    List<String> columnItems = [];
    List<String> keyItems = [];
    for (var e in columns) {
      if (!e.isPrimaryKey) {
        columnItems.add("'${e.name}' ${e.dbType.toString()}");
      } else {
        columnItems.add("'${e.name}' ${e.dbType.toString()} NOT NULL");
        keyItems.add("'${e.name}'");
      }
    }
    String sql;
    if (columnItems.isNotEmpty) {
      if (keyItems.isEmpty) {
        sql =
            "CREATE TABLE IF NOT EXISTS '$tableName' (${columnItems.join(',')})";
      } else {
        sql =
            "CREATE TABLE IF NOT EXISTS '$tableName' (${columnItems.join(',')}, PRIMARY KEY (${keyItems.join(',')}))";
      }
    } else {
      sql = "CREATE TABLE IF NOT EXISTS '$tableName'";
    }
    return sql;
  }

  String sqlForInsert({bool replace = true, bool ignore = false}) {
    String head = replace
        ? (ignore ? "INSERT OR IGNORE" : "INSERT OR REPLACE")
        : "INSERT";
    List<String> properties = [];
    List<String> values = [];
    for (var e in columns) {
      properties.add("'${e.name}'");
      values.add(":${e.name}");
    }
    String sql = '';
    if (properties.isNotEmpty && values.isNotEmpty) {
      sql =
          "$head INTO '$tableName' (${properties.join(',')}) VALUES(${values.join(',')})";
    }
    return sql;
  }

  String sqlForDelete({String? where}) {
    String sql;
    if ((where != null) && where.isNotEmpty) {
      sql = "DELETE FROM '$tableName' ${_applyTb(where)}";
    } else {
      sql = "DELETE FROM '$tableName'";
    }
    return sql;
  }

  String sqlForUpdate({String where = ''}) {
    bool containsSet = where.toUpperCase().contains('SET');
    String sql;
    if (containsSet) {
      sql = "UPDATE '$tableName' ${_applyTb(where)}";
    } else {
      sql = _sqlFroUpdateWhere(_applyTb(where));
    }
    return sql;
  }

  String _sqlFroUpdateWhere(String where) {
    String set =
        columns.map((e) => "'${e.name}'=:${e.name}").toList().join(',');
    String sql;
    if (where.isNotEmpty) {
      sql = "UPDATE '$tableName' set $set $where";
    } else {
      sql = "UPDATE '$tableName' set $set";
    }
    return sql;
  }

  String sqlForSelect(
      {String? select = '*',
      String? where,
      int? limitStart,
      int? limitLength}) {
    String sql;
    if ((where != null) && where.isNotEmpty) {
      sql = "SELECT $select FROM '$tableName' $where";
    } else {
      sql = "SELECT $select FROM '$tableName'";
    }
    if ((limitStart != null) && (limitLength != null)) {
      sql = "$sql LIMIT $limitStart,$limitLength";
    }
    return sql;
  }

  String _applyTb(String sql) {
    if (sql.isEmpty || tableName.isEmpty) {
      return sql;
    }
    return sql.replaceAll(":tb", "'$tableName'");
  }
}

class CBDBColumn {
  // 字段类型 CBDBType
  final String dbType;

  // 字段名
  final String name;

  // 是否为主键
  final bool isPrimaryKey;

  // 指定转换器
  final Function? fromDBValue;

  // 指定转换器
  final Function? toDBValue;

  CBDBColumn(
    this.dbType,
    this.name, {
    this.isPrimaryKey = false,
    this.fromDBValue,
    this.toDBValue,
  });
}
