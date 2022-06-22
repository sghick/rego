export 'package:sqflite/sqflite.dart';
export 'package:rego/base_core/db/sql_creator.dart';
export 'package:rego/base_core/db/sqlite_models.dart';

import 'package:rego/base_core/db/sql_creator.dart';
import 'package:rego/base_core/db/sql_engine.dart';
import 'package:rego/base_core/db/sqlite_alter.dart';
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

extension AlterExt on CBSqlite {
  Future<Database> doOptions(CBDBMapper dbMapper) {
    return database.then((db) {
      return alterCheck(db, dbMapper).then((_) => db);
    });
  }

  Map<String, Object?> toDBValue(CBDBMapper dbMapper, Object obj) {
    try {
      return (dbMapper.toDBValue != null)
          ? dbMapper.toDBValue!(obj)
          : (throw Exception('请指定数据序列化方法:toDBValue'));
    } catch (e) {
      throw Exception(e);
    }
  }

  List<T> fromDBValue<T extends Object>(
      CBDBMapper dbMapper, List<Map<String, Object?>> maps) {
    try {
      return (dbMapper.fromDBValue != null)
          ? maps.map((e) => dbMapper.fromDBValue!(e) as T).toList()
          : (throw Exception('请指定数据反序列化方法:fromDBValue'));
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<int> insert(
    CBDBMapper dbMapper,
    dynamic obj, {
    String? nullColumnHack,
    ConflictAlgorithm? conflictAlgorithm = ConflictAlgorithm.replace,
  }) {
    return doOptions(dbMapper).then((db) {
      var dbValue = toDBValue(dbMapper, obj);
      return db.insert(
        dbMapper.tableName,
        dbValue,
        nullColumnHack: nullColumnHack,
        conflictAlgorithm: conflictAlgorithm,
      );
    });
  }

  Future<int> insertList(
    CBDBMapper dbMapper,
    List obj, {
    ConflictAlgorithm? conflictAlgorithm = ConflictAlgorithm.replace,
  }) {
    return doOptions(dbMapper).then((db) {
      List values = obj.map((e) => toDBValue(dbMapper, e)).toList();
      bool ignore = (conflictAlgorithm == ConflictAlgorithm.ignore);
      bool replace = (conflictAlgorithm == ConflictAlgorithm.replace);
      String sql = SqlCreator().sqlForInsert(
          dbMapper.tableName, dbMapper.columns,
          replace: replace, ignore: ignore);
      String sqlList =
          SqlEngine().fillSqlSet(sql, values as List<Map<String, Object?>>);
      return db.rawInsert(sqlList);
    });
  }

  Future<int> delete(
    CBDBMapper dbMapper, {
    String? where,
    List<Object?>? whereArgs,
  }) {
    return doOptions(dbMapper).then((db) {
      return db.delete(
        dbMapper.tableName,
        where: where,
        whereArgs: whereArgs,
      );
    });
  }

  Future<int> update(
    CBDBMapper dbMapper,
    Object obj, {
    String? where,
    List<Object?>? whereArgs,
    ConflictAlgorithm? conflictAlgorithm,
  }) {
    return doOptions(dbMapper).then((db) {
      var dbValue = toDBValue(dbMapper, obj);
      return db.update(
        dbMapper.tableName,
        dbValue,
        where: where,
        whereArgs: whereArgs,
        conflictAlgorithm: conflictAlgorithm,
      );
    });
  }

  Future<List<T>?> select<T extends Object>(
    CBDBMapper dbMapper, {
    bool? distinct,
    List<String>? columns,
    String? where,
    List<Object?>? whereArgs,
    String? groupBy,
    String? having,
    String? orderBy,
    int? limit,
    int? offset,
  }) {
    return doOptions(dbMapper).then((db) {
      return db
          .query(
        dbMapper.tableName,
        distinct: distinct,
        columns: columns,
        where: where,
        whereArgs: whereArgs,
        groupBy: groupBy,
        having: having,
        orderBy: orderBy,
        limit: limit,
        offset: offset,
      )
          .then((maps) {
        if (maps.isEmpty) {
          return Future.value();
        }
        List<T> list = fromDBValue(dbMapper, maps);
        return Future.value(list);
      });
    });
  }

  Future<T?> selectFirst<T extends Object>(
    CBDBMapper dbMapper, {
    bool? distinct,
    List<String>? columns,
    String? where,
    List<Object?>? whereArgs,
    String? groupBy,
    String? having,
    String? orderBy,
    int? limit,
    int? offset,
  }) {
    return select<T>(
      dbMapper,
      distinct: distinct,
      columns: columns,
      where: where,
      whereArgs: whereArgs,
      groupBy: groupBy,
      having: having,
      orderBy: orderBy,
      limit: limit,
      offset: offset,
    ).then((value) => value?.first);
  }
}
