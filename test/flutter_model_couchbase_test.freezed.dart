// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target

part of 'flutter_model_couchbase_test.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

/// @nodoc
mixin _$Category {
  dynamic get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get colour => throw _privateConstructorUsedError;
  DateTime? get createdDate => throw _privateConstructorUsedError;
  DateTime? get modifiedDate => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  List<String> get tags => throw _privateConstructorUsedError;
  dynamic get hierarchyParentId => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $CategoryCopyWith<Category> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CategoryCopyWith<$Res> {
  factory $CategoryCopyWith(Category value, $Res Function(Category) then) =
      _$CategoryCopyWithImpl<$Res>;
  $Res call(
      {dynamic id,
      String name,
      String colour,
      DateTime? createdDate,
      DateTime? modifiedDate,
      String description,
      List<String> tags,
      dynamic hierarchyParentId});
}

/// @nodoc
class _$CategoryCopyWithImpl<$Res> implements $CategoryCopyWith<$Res> {
  _$CategoryCopyWithImpl(this._value, this._then);

  final Category _value;
  // ignore: unused_field
  final $Res Function(Category) _then;

  @override
  $Res call({
    Object? id = freezed,
    Object? name = freezed,
    Object? colour = freezed,
    Object? createdDate = freezed,
    Object? modifiedDate = freezed,
    Object? description = freezed,
    Object? tags = freezed,
    Object? hierarchyParentId = freezed,
  }) {
    return _then(_value.copyWith(
      id: id == freezed
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as dynamic,
      name: name == freezed
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      colour: colour == freezed
          ? _value.colour
          : colour // ignore: cast_nullable_to_non_nullable
              as String,
      createdDate: createdDate == freezed
          ? _value.createdDate
          : createdDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      modifiedDate: modifiedDate == freezed
          ? _value.modifiedDate
          : modifiedDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      description: description == freezed
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      tags: tags == freezed
          ? _value.tags
          : tags // ignore: cast_nullable_to_non_nullable
              as List<String>,
      hierarchyParentId: hierarchyParentId == freezed
          ? _value.hierarchyParentId
          : hierarchyParentId // ignore: cast_nullable_to_non_nullable
              as dynamic,
    ));
  }
}

/// @nodoc
abstract class _$$_CategoryCopyWith<$Res> implements $CategoryCopyWith<$Res> {
  factory _$$_CategoryCopyWith(
          _$_Category value, $Res Function(_$_Category) then) =
      __$$_CategoryCopyWithImpl<$Res>;
  @override
  $Res call(
      {dynamic id,
      String name,
      String colour,
      DateTime? createdDate,
      DateTime? modifiedDate,
      String description,
      List<String> tags,
      dynamic hierarchyParentId});
}

/// @nodoc
class __$$_CategoryCopyWithImpl<$Res> extends _$CategoryCopyWithImpl<$Res>
    implements _$$_CategoryCopyWith<$Res> {
  __$$_CategoryCopyWithImpl(
      _$_Category _value, $Res Function(_$_Category) _then)
      : super(_value, (v) => _then(v as _$_Category));

  @override
  _$_Category get _value => super._value as _$_Category;

  @override
  $Res call({
    Object? id = freezed,
    Object? name = freezed,
    Object? colour = freezed,
    Object? createdDate = freezed,
    Object? modifiedDate = freezed,
    Object? description = freezed,
    Object? tags = freezed,
    Object? hierarchyParentId = freezed,
  }) {
    return _then(_$_Category(
      id: id == freezed
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as dynamic,
      name: name == freezed
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      colour: colour == freezed
          ? _value.colour
          : colour // ignore: cast_nullable_to_non_nullable
              as String,
      createdDate: createdDate == freezed
          ? _value.createdDate
          : createdDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      modifiedDate: modifiedDate == freezed
          ? _value.modifiedDate
          : modifiedDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      description: description == freezed
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      tags: tags == freezed
          ? _value._tags
          : tags // ignore: cast_nullable_to_non_nullable
              as List<String>,
      hierarchyParentId: hierarchyParentId == freezed
          ? _value.hierarchyParentId
          : hierarchyParentId // ignore: cast_nullable_to_non_nullable
              as dynamic,
    ));
  }
}

/// @nodoc

class _$_Category extends _Category {
  _$_Category(
      {this.id,
      required this.name,
      this.colour = "",
      this.createdDate,
      this.modifiedDate,
      this.description = "",
      final List<String> tags = const [],
      this.hierarchyParentId})
      : _tags = tags,
        super._();

  @override
  final dynamic id;
  @override
  final String name;
  @override
  @JsonKey()
  final String colour;
  @override
  final DateTime? createdDate;
  @override
  final DateTime? modifiedDate;
  @override
  @JsonKey()
  final String description;
  final List<String> _tags;
  @override
  @JsonKey()
  List<String> get tags {
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_tags);
  }

  @override
  final dynamic hierarchyParentId;

  @override
  String toString() {
    return 'Category(id: $id, name: $name, colour: $colour, createdDate: $createdDate, modifiedDate: $modifiedDate, description: $description, tags: $tags, hierarchyParentId: $hierarchyParentId)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_Category &&
            const DeepCollectionEquality().equals(other.id, id) &&
            const DeepCollectionEquality().equals(other.name, name) &&
            const DeepCollectionEquality().equals(other.colour, colour) &&
            const DeepCollectionEquality()
                .equals(other.createdDate, createdDate) &&
            const DeepCollectionEquality()
                .equals(other.modifiedDate, modifiedDate) &&
            const DeepCollectionEquality()
                .equals(other.description, description) &&
            const DeepCollectionEquality().equals(other._tags, _tags) &&
            const DeepCollectionEquality()
                .equals(other.hierarchyParentId, hierarchyParentId));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(id),
      const DeepCollectionEquality().hash(name),
      const DeepCollectionEquality().hash(colour),
      const DeepCollectionEquality().hash(createdDate),
      const DeepCollectionEquality().hash(modifiedDate),
      const DeepCollectionEquality().hash(description),
      const DeepCollectionEquality().hash(_tags),
      const DeepCollectionEquality().hash(hierarchyParentId));

  @JsonKey(ignore: true)
  @override
  _$$_CategoryCopyWith<_$_Category> get copyWith =>
      __$$_CategoryCopyWithImpl<_$_Category>(this, _$identity);
}

abstract class _Category extends Category {
  factory _Category(
      {final dynamic id,
      required final String name,
      final String colour,
      final DateTime? createdDate,
      final DateTime? modifiedDate,
      final String description,
      final List<String> tags,
      final dynamic hierarchyParentId}) = _$_Category;
  _Category._() : super._();

  @override
  dynamic get id;
  @override
  String get name;
  @override
  String get colour;
  @override
  DateTime? get createdDate;
  @override
  DateTime? get modifiedDate;
  @override
  String get description;
  @override
  List<String> get tags;
  @override
  dynamic get hierarchyParentId;
  @override
  @JsonKey(ignore: true)
  _$$_CategoryCopyWith<_$_Category> get copyWith =>
      throw _privateConstructorUsedError;
}
