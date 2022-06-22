class SqlEngine {
  String fillSql(String sql, Map<String, Object?> values) {
    String _sql = sql;
    values.forEach((key, value) {
      _sql.replaceAll(':$key', "'$value'");
    });
    return _sql;
  }

  String fillSqlSet(String sql, List<Map<String, Object?>> values) {
    List<String> sqlList = [];
    for (var e in values) {
      sqlList.add(fillSql(sql, e));
    }
    return sqlList.join(';');
  }
}
