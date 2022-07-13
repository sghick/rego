import 'package:rego/base_core/db/sqlite_models.dart';

class SqlCreator {
  String sqlForTransaction(
    String sql, {
    bool foreignKeys = false,
    bool writableSchema = false,
  }) {
    String rtn = '';
    rtn += 'PRAGMA foreign_keys=${foreignKeys ? 'ON' : 'OFF'};\n';
    rtn += ' BEGIN TRANSACTION;\n';
    rtn += sql + '\n';
    rtn += 'PRAGMA writable_schema=${writableSchema ? 'ON' : 'OFF'};\n';
    rtn += 'COMMIT;\n';
    return rtn;
  }

  String sqlForSelectTables() {
    return "SELECT name FROM sqlite_master WHERE type ='table'";
  }

  String sqlForTableExist(String tableName) {
    return "SELECT count(*) AS 'count' FROM sqlite_master WHERE type='table' and name='$tableName'";
  }

  String sqlForGetColumns(String tableName) {
    return 'PRAGMA table_info([$tableName])';
  }

  String sqlForDropTable(String tableName) {
    return "DROP TABLE IF EXISTS '$tableName'";
  }

  String sqlForDeleteData(String tableName) {
    return "DELETE FROM '$tableName'";
  }

  String sqlForRename(String tableName, String toName) {
    return "ALTER TABLE '$tableName' RENAME TO '$toName'";
  }

  String sqlForCreateTable(String tableName, List<CBDBColumn> columns) {
    List<String> columnItems = [];
    List<String> keyItems = [];
    for (var e in columns) {
      if (!e.pk) {
        columnItems.add("'${e.name}' ${e.type.toString()}");
      } else {
        columnItems.add("'${e.name}' ${e.type.toString()} NOT NULL");
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

  String sqlForInsert(
    String tableName,
    List<CBDBColumn> columns, {
    bool replace = true,
    bool ignore = false,
  }) {
    String head = "INSERT";
    if (replace) {
      head = "INSERT OR REPLACE";
    }
    if (ignore) {
      head = "INSERT OR IGNORE";
    }
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

  String sqlForCopyInsert(
      String tableName, List<CBDBColumn> columns, String toTableName) {
    String fc = columns.map((e) => e.name).toList().join(',');
    return "INSERT INTO '$toTableName' ($fc) SELECT $fc FROM '$tableName'";
  }

  String sqlForDelete(String tableName, {String? where}) {
    String sql;
    if ((where != null) && where.isNotEmpty) {
      sql = "DELETE FROM '$tableName' ${_applyTb(tableName, where)}";
    } else {
      sql = "DELETE FROM '$tableName'";
    }
    return sql;
  }

  String sqlForUpdate(
    String tableName,
    List<CBDBColumn> columns, {
    String where = '',
  }) {
    bool containsSet = where.toUpperCase().contains('SET');
    String sql;
    if (containsSet) {
      sql = "UPDATE '$tableName' ${_applyTb(tableName, where)}";
    } else {
      sql = _sqlFroUpdateWhere(tableName, columns, _applyTb(tableName, where));
    }
    return sql;
  }

  String _sqlFroUpdateWhere(
    String tableName,
    List<CBDBColumn> columns,
    String where,
  ) {
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
    String tableName, {
    String? select = '*',
    String? where,
    int? limitStart,
    int? limitLength,
  }) {
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

  String _applyTb(String tableName, String sql) {
    if (sql.isEmpty || tableName.isEmpty) {
      return sql;
    }
    return sql.replaceAll(":tb", "'$tableName'");
  }
}
