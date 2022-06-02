
import 'package:rego/base_core/db/sqlite_models.dart';

class MetaInfo {
  final CBDBMapper dbMapper;

  bool needsAlter = false;

  MetaInfo(this.dbMapper);

  MetaInfo.fromNeedsAlter(this.dbMapper, this.needsAlter);
}

MetaInfoHelper metaInfoHelper = MetaInfoHelper();

class MetaInfoHelper {
  static final MetaInfoHelper _instance = MetaInfoHelper._();

  final Map<String, MetaInfo> _infos = {};

  factory MetaInfoHelper() {
    return _instance;
  }

  MetaInfoHelper._();

  MetaInfo? getInfo(CBDBMapper dbMapper) => _infos[dbMapper.tableName];

  void setNeedsAlter(CBDBMapper dbMapper) {
    MetaInfo metaInfo = _infos[dbMapper.tableName] ?? MetaInfo(dbMapper);
    metaInfo.needsAlter = true;
    _infos[dbMapper.tableName] = metaInfo;
  }

  void setAltered(CBDBMapper dbMapper) {
    MetaInfo metaInfo = _infos[dbMapper.tableName] ?? MetaInfo(dbMapper);
    metaInfo.needsAlter = false;
    _infos[dbMapper.tableName] = metaInfo;
  }
}
