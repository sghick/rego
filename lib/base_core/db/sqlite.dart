export 'package:sqflite/sqflite.dart';
export 'package:rego/base_core/db/sql_creator.dart';
export 'package:rego/base_core/db/sqlite_models.dart';

import 'package:rego/base_core/db/sql_creator.dart';
import 'package:rego/base_core/db/sqlite_models.dart';
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

  SqlCreator get sqlCreator => SqlCreator();

  String sqlForDropTable() {
    return sqlCreator.sqlForDropTable(tableName);
  }

  String sqlForTableExist() {
    return sqlCreator.sqlForTableExist(tableName);
  }

  String sqlForGetColumns(String tableName) {
    return sqlCreator.sqlForGetColumns(tableName);
  }

  String sqlForCreateTable() {
    return sqlCreator.sqlForCreateTable(tableName, columns);
  }

  String sqlForInsert({bool replace = true, bool ignore = false}) {
    return sqlCreator.sqlForInsert(
      tableName,
      columns,
      replace: replace,
      ignore: ignore,
    );
  }

  String sqlForDelete({String? where}) {
    return sqlCreator.sqlForDelete(tableName, where: where);
  }

  String sqlForUpdate({String where = ''}) {
    return sqlCreator.sqlForUpdate(tableName, columns, where: where);
  }

  String sqlForSelect({
    String? select = '*',
    String? where,
    int? limitStart,
    int? limitLength,
  }) {
    return sqlCreator.sqlForSelect(
      tableName,
      select: select,
      where: where,
      limitStart: limitStart,
      limitLength: limitLength,
    );
  }
}
