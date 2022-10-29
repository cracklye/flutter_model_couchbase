import 'package:flutter_model/flutter_model.dart';

/// ModelStub provudes basic information about a mix of 
/// multiple different types of models.
class ModelStub extends IModel {

  /// the content of the model 
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


  get dbtype => values["dbtype"];

  @override
  DateTime? get modifiedDate => values["modifiedDate"];

  @override
  Map<String, dynamic> toJson() {
    return values;
  }
}



