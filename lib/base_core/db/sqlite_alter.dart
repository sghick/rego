import 'package:rego/base_core/db/meta_info.dart';
import 'package:rego/base_core/db/sqlite.dart';
import 'package:rego/base_core/log/logger.dart';
import 'package:rego/base_core/utils/list_utils.dart';

class CBPragma {
  final String name;
  final String type;
  final bool pk;

  CBPragma(this.name, this.type, this.pk);

  factory CBPragma.fromJson(Map<String, dynamic> json) => CBPragma(
        json['name'] as String,
        json['type'] as String,
        (json['pk'] > 0) as bool,
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
        'name': name,
        'type': type,
        'pk': pk,
      };
}

Future<bool> alterCheck(Database db, CBDBMapper dbMapper) {
  MetaInfo? metaInfo = metaInfoHelper.getInfo(dbMapper);
  // metaInfo不存在时,自动走一次alter逻辑
  if (metaInfo != null && !metaInfo.needsAlter) return Future.value(false);
  return _createOrAlterTable(db, dbMapper).whenComplete(() {
    metaInfoHelper.setAltered(dbMapper);
  });
}

Future<bool> _createOrAlterTable(Database db, CBDBMapper dbMapper) {
  return _isTableExist(db, dbMapper).then((exist) {
    if (!exist) {
      return _createTableIfNotExist(db, dbMapper);
    } else {
      return _recreateOrAlterTable(db, dbMapper);
    }
  });
}

Future<bool> _recreateOrAlterTable(Database db, CBDBMapper dbMapper) async {
  List<CBPragma> dbColumns = await _columns(db, dbMapper);
  bool pkChanged = await _isPrimaryKeysChanged(dbColumns, dbMapper);
  if (pkChanged) {
    return _dropTableIfExist(db, dbMapper).then((success) {
      return _createTableIfNotExist(db, dbMapper);
    });
  }
  List<CBDBColumn>? needsKeepColumns = _needsKeepColumns(dbColumns, dbMapper);
  if (needsKeepColumns == null || needsKeepColumns.isEmpty) {
    // 没有变化
    return false;
  } else {
    return _recreateTable(db, dbMapper, needsKeepColumns);
  }
}

Future<bool> _isPrimaryKeysChanged(
    List<CBPragma> dbColumns, CBDBMapper dbMapper) {
  List<String> dbPks = dbColumns.filter((obj) => (obj.pk ? obj.name : null));
  List<String> pks =
      dbMapper.columns.filter((obj) => (obj.pk ? obj.name : null));
  bool changed = !_isEqualList(dbPks, pks);
  return Future.value(changed);
}

List<CBDBColumn>? _needsKeepColumns(
    List<CBPragma> dbColumns, CBDBMapper dbMapper) {
  List<String> dbClm = dbColumns.map((e) => e.name).toList();
  List<String> clm = dbMapper.columns.map((e) => e.name).toList();
  if (!_isEqualList(dbClm, clm)) {
    List<CBDBColumn> keepColumns = dbMapper.columns
        .filter((obj) => ((dbClm.contains(obj.name)) ? obj : null));
    return keepColumns;
  } else {
    return null;
  }
}

/**
 * sql options
 */

Future<bool> _isTableExist(Database db, CBDBMapper dbMapper) {
  String sql = dbMapper.sqlForTableExist();
  return db.rawQuery(sql).then((maps) {
    var result = (maps.map((e) => e['count'])).toList().first as int;
    return (result > 0);
  });
}

Future<bool> _createTableIfNotExist(Database db, CBDBMapper dbMapper) {
  String sql = dbMapper.sqlForCreateTable();
  return db.execute(sql).then((maps) {
    return Future.value(true);
  });
}

Future<bool> _dropTableIfExist(Database db, CBDBMapper dbMapper) {
  String sql = dbMapper.sqlForDropTable();
  return db.execute(sql).then((maps) {
    return Future.value(true);
  });
}

Future<List<CBPragma>> _columns(Database db, CBDBMapper dbMapper) {
  String sql = dbMapper.sqlForGetColumns();
  return db.rawQuery(sql).then((maps) {
    var result = maps.map((e) => CBPragma.fromJson(e)).toList();
    return Future.value(result);
  });
}

Future<bool> _recreateTable(
  Database db,
  CBDBMapper dbMapper,
  List<CBDBColumn> needsKeepColumns,
) {
  String toName = '__cb_${dbMapper.tableName}';
  String drop = SqlCreator().sqlForDropTable(toName);
  String createSql = SqlCreator().sqlForCreateTable(toName, dbMapper.columns);
  String copySql = SqlCreator()
      .sqlForCopyInsert(dbMapper.tableName, needsKeepColumns, toName);
  String dropSql = SqlCreator().sqlForDropTable(dbMapper.tableName);
  String renameSql = SqlCreator().sqlForRename(toName, dbMapper.tableName);
  logD(drop);
  logD(createSql);
  logD(copySql);
  logD(dropSql);
  logD(renameSql);
  String sql = [drop, createSql, copySql, dropSql, renameSql].join(';');
  logD(sql);
  return db.execute(sql).then((maps) {
    return Future.value(true);
  });
}

bool _isEqualList(List<String> list1, List<String> list2) {
  if (list1.isEmpty && list2.isEmpty) {
    return true;
  }

  if (list1.length != list2.length) {
    return false;
  } else {
    for (int i = 0; i < list2.length; i++) {
      var e = list1[i];
      if (!list2.contains(e)) {
        return false;
      }
    }
    return true;
  }
}
