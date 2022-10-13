// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'flutter_model_couchbase_test.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Category _$CategoryFromJson(Map<String, dynamic> json) => Category(
      id: json['id'],
      name: json['name'] as String,
      colour: json['colour'] as String,
      createdDate: json['createdDate'] == null
          ? null
          : DateTime.parse(json['createdDate'] as String),
      modifiedDate: json['modifiedDate'] == null
          ? null
          : DateTime.parse(json['modifiedDate'] as String),
      description: json['description'] as String,
      tags: (json['tags'] as List<dynamic>).map((e) => e as String).toList(),
      hierarchyParentId: json['hierarchyParentId'],
    );

Map<String, dynamic> _$CategoryToJson(Category instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'colour': instance.colour,
      'createdDate': instance.createdDate?.toIso8601String(),
      'modifiedDate': instance.modifiedDate?.toIso8601String(),
      'description': instance.description,
      'tags': instance.tags,
      'hierarchyParentId': instance.hierarchyParentId,
    };
