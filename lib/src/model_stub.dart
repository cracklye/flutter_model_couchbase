import 'package:flutter_model/flutter_model.dart';

class ModelStub extends IModel {
  final Map<String, dynamic> values;
  ModelStub(this.values);

  @override
  IModel copyWithId({id, DateTime? createdDate, DateTime? modifiedDate}) {
    throw UnimplementedError("The model stub is not editable");
  }

  @override
  DateTime? get createdDate => values["createdDate"];

  @override
  String get displayLabel =>
      values["title"] ?? values["label"] ?? values["name"] ?? "No Title Provided2 $values";

  @override
  get id => values["id"];

  @override
  DateTime? get modifiedDate => values["modifiedDate"];

  @override
  Map<String, dynamic> toJson() {
    return values;
  }
}

