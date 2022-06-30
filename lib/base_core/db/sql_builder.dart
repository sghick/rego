abstract class SqlBuilder {
  String get sql => '${form.isEmpty ? '' : '$form '}$words';

  String get form;

  String get words;
}

class Sql extends SqlBuilder {
  @override
  String get form => '';

  @override
  String get words => '';

  SqlSelect select({bool? distinct, String? columns}) =>
      SqlSelect(distinct: distinct, columns: columns);

  SqlInsertInto insertInto({required String table, String? columns}) =>
      SqlInsertInto(table: table, columns: columns);

  SqlUpdate update({required String table}) => SqlUpdate(table: table);

  SqlDelete delete({String? columns}) => SqlDelete(columns: columns);
}

// SELECT column_name,column_name
// FROM table_name;
//
// SELECT * FROM table_name;
//
// SELECT DISTINCT column_name,column_name
// FROM table_name;
//
// SELECT column_name,column_name
// FROM table_name
// WHERE column_name operator value;
class SqlSelect extends SqlBuilder {
  final bool? distinct;
  final String? columns;

  SqlSelect({this.distinct, this.columns});

  @override
  String get form => '';

  @override
  String get words =>
      'SELECT${(distinct ?? false) ? ' DISTINCT' : ''} ${columns ?? '*'}';

  SqlFrom from(String table) => SqlFrom(formSelect: this, table: table);
}

// FROM table_name
class SqlFrom extends SqlBuilder {
  final String table;
  final SqlSelect? formSelect;
  final SqlDelete? formDelete;

  SqlFrom({this.formSelect, this.formDelete, required this.table});

  @override
  String get form {
    if (formSelect != null) {
      return formSelect!.sql;
    } else if (formDelete != null) {
      return formDelete!.sql;
    }
    return '';
  }

  @override
  String get words => 'FROM $table';

  SqlWhere where(String where) => SqlWhere(formFrom: this, where: where);

  SqlGroupBy groupBy(String groupBy) =>
      SqlGroupBy(formFrom: this, groupBy: groupBy);

  SqlOrderBy orderBy(String orderBy) =>
      SqlOrderBy(formFrom: this, orderBy: orderBy);
}

//  运算符	描述
//  =	等于
//  <>	不等于。注释：在 SQL 的一些版本中，该操作符可被写成 !=
//  >	大于
//  <	小于
//  >=	大于等于
//  <=	小于等于
//  BETWEEN	在某个范围内
//  LIKE	搜索某种模式
//  IN	指定针对某个列的多个可能值
//
//  OR 逻辑运算
//  AND 逻辑运算
//  NOT 逻辑运算
//  is null 空值判断
//  between ... and 在...之间的值
//  in 在集合之中
//  like 模糊查询:
//     % 表示多个字值，_ 下划线表示一个字符；
//     M% : 为能配符，正则表达式，表示的意思为模糊查询信息为 M 开头的。
//     %M% : 表示查询包含M的所有内容。
//     %M_ : 表示查询以M在倒数第二位的所有内容。
class SqlWhere extends SqlBuilder {
  final SqlFrom? formFrom;
  final SqlSet? formSet;
  final String where;

  SqlWhere({this.formFrom, this.formSet, required this.where});

  @override
  String get form {
    if (formFrom != null) {
      return formFrom!.sql;
    } else if (formSet != null) {
      return formSet!.sql;
    } else {
      return '';
    }
  }

  @override
  String get words => 'WHERE $where';

  SqlGroupBy groupBy(String groupBy) =>
      SqlGroupBy(formFrom: formFrom, formWhere: this, groupBy: groupBy);

  SqlOrderBy orderBy(String orderBy) =>
      SqlOrderBy(formFrom: formFrom, formWhere: this, orderBy: orderBy);
}

// GROUP BY column_name,column_name;
class SqlGroupBy extends SqlBuilder {
  final String groupBy;
  final SqlFrom? formFrom;
  final SqlWhere? formWhere;

  SqlGroupBy({this.formFrom, this.formWhere, required this.groupBy});

  @override
  String get form {
    if (formWhere != null) {
      return formWhere!.sql;
    } else if (formFrom != null) {
      return formFrom!.sql;
    } else {
      return '';
    }
  }

  @override
  String get words => 'GROUP BY $groupBy';

  SqlOrderBy orderBy(String orderBy) =>
      SqlOrderBy(formWhere: formWhere, fromGroupBy: this, orderBy: orderBy);
}

// ORDER BY column_name,column_name ASC|DESC;
class SqlOrderBy extends SqlBuilder {
  final String orderBy;
  final SqlFrom? formFrom;
  final SqlWhere? formWhere;
  final SqlGroupBy? fromGroupBy;

  SqlOrderBy({
    this.formFrom,
    this.formWhere,
    this.fromGroupBy,
    required this.orderBy,
  });

  @override
  String get form {
    if (fromGroupBy != null) {
      return fromGroupBy!.sql;
    } else if (formWhere != null) {
      return formWhere!.sql;
    } else if (formFrom != null) {
      return formFrom!.sql;
    } else {
      return '';
    }
  }

  @override
  String get words => 'ORDER BY $orderBy';
}

// INSERT INTO table_name
// VALUES (value1,value2,value3,...);
//
// INSERT INTO table_name (column1,column2,column3,...)
// VALUES (value1,value2,value3,...);
class SqlInsertInto extends SqlBuilder {
  final String table;
  final String? columns;

  SqlInsertInto({required this.table, this.columns});

  @override
  String get form => '';

  @override
  String get words {
    if (columns != null) {
      return 'INSERT INTO $table ($columns)';
    } else {
      return 'INSERT INTO $table';
    }
  }

  SqlValue values(String values) =>
      SqlValue(formInsertInto: this, values: values);
}

// VALUES (value1,value2,value3,...)
class SqlValue extends SqlBuilder {
  final SqlInsertInto formInsertInto;
  final String values;

  SqlValue({required this.formInsertInto, required this.values});

  @override
  String get form => formInsertInto.sql;

  @override
  String get words => 'VALUES ($values)';
}

// UPDATE table_name
// SET column1=value1,column2=value2,...
// WHERE some_column=some_value;
class SqlUpdate extends SqlBuilder {
  final String table;

  SqlUpdate({required this.table});

  @override
  String get form => '';

  @override
  String get words => 'UPDATE $table';

  SqlSet set(String set) => SqlSet(formUpdate: this, set: set);
}

// SET column1=value1,column2=value2,...
class SqlSet extends SqlBuilder {
  final SqlUpdate formUpdate;
  final String set;

  SqlSet({required this.formUpdate, required this.set});

  @override
  String get form => formUpdate.sql;

  @override
  String get words => 'SET $set';

  SqlWhere where(String where) => SqlWhere(formSet: this, where: where);
}

// DELETE FROM table_name
// WHERE some_column=some_value;
//
// DELETE FROM table_name;
//
// DELETE * FROM table_name;
class SqlDelete extends SqlBuilder {
  final String? columns;

  SqlDelete({this.columns});

  @override
  String get form => '';

  @override
  String get words => 'DELETE ${columns ?? '*'}';

  SqlFrom from(String table) => SqlFrom(formDelete: this, table: table);
}

// void test() {
//   _test001();
//   _test002();
//   _test003();
//   _test004();
//   _test005();
// }
//
// void _test001() {
//   String sql1 = Sql()
//       .select(distinct: true, columns: 'name,id')
//       .from('table1')
//       .where('age=12')
//       .groupBy('age,class')
//       .orderBy('age,level')
//       .sql;
//   String sql2 = Sql()
//       .select(distinct: false, columns: 'name,id')
//       .from('table2')
//       .where('where')
//       .groupBy('age,class')
//       .orderBy('age,level')
//       .sql;
//   String sql3 = Sql()
//       .select(columns: 'name,id')
//       .from('table3')
//       .where('where')
//       .orderBy('age,level')
//       .sql;
//   String sql4 = Sql()
//       .select(distinct: true, columns: 'name,id')
//       .from('table4')
//       .groupBy('age,class')
//       .orderBy('age,level')
//       .sql;
//   String sql5 = Sql()
//       .select(distinct: true, columns: 'name,id')
//       .from('table5')
//       .orderBy('age,level')
//       .sql;
//   logD(sql1);
//   logD(sql2);
//   logD(sql3);
//   logD(sql4);
//   logD(sql5);
// }
//
// void _test002() {
//   String sql1 = Sql()
//       .insertInto(table: 'table1', columns: 'age,name,id')
//       .values("12, 'XiaoMing','c001'")
//       .sql;
//   String sql2 =
//       Sql().insertInto(table: 'table2').values("12, 'XiaoMing','c001'").sql;
//   logD(sql1);
//   logD(sql2);
// }
//
// void _test003() {
//   String sql1 = Sql()
//       .update(table: 'table1')
//       .set("age=12,name='ZhaoGang',id='c001'")
//       .where('class=100')
//       .sql;
//   String sql2 = Sql()
//       .update(table: 'table2')
//       .set("age=12,name='ZhaoGang',id='c001'")
//       .where('class=100')
//       .sql;
//   logD(sql1);
//   logD(sql2);
// }
//
// void _test004() {
//   String sql1 = Sql()
//       .delete(columns: 'age,name,id')
//       .from('table1')
//       .where("age=1 AND name='XiaoGang'")
//       .sql;
//   String sql2 =
//       Sql().delete().from('table2').where("age=1 AND name='XiaoGang'").sql;
//   String sql3 = Sql().delete().from('table3').sql;
//   logD(sql1);
//   logD(sql2);
//   logD(sql3);
// }
//
// void _test005() {}