import 'package:json_annotation/json_annotation.dart';

class JsonModel extends JsonSerializable {
  const JsonModel() : super(fieldRename: FieldRename.none);
}
