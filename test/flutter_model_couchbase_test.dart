@Timeout(Duration(seconds: 10))

import 'dart:io';

import 'package:cbl/cbl.dart';
import 'package:flutter_model/flutter_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_model_couchbase/flutter_model_couchbase.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cbl_dart/cbl_dart.dart';
import 'dart:async';

part 'flutter_model_couchbase_test.freezed.dart';
part 'flutter_model_couchbase_test.g.dart';

void main() async {
  final filesDir = await Directory.systemTemp.createTemp();
  await CouchbaseLiteDart.init(
    edition: Edition.community,
    filesDir: filesDir.path,
  );

  group("Couchbase DAO", () {
    late Database database;

    setUp(() async => database = await Database.openAsync('test1'));
    tearDown(() => database.delete());

//     test('Stream works as expected', () async{
//       expect(reverseCounter.countStream(3),emitsInOrder([
//             3,2,1,0
//          ]));

//     });
//  test('should always emit 0  at the end', (){
//          expect(reverseCounter.countStream(3),emitsInOrder([
//             emitsThrough(0),
//             emitsDone
//          ]));
//       });
//           test("shouldn't emit negative numbers",(){
//          expect(reverseCounter.countStream(3),neverEmits(isNegative));
//       });

// test(
//       'should always emit numbers within the range(upperBound,0) inclusively',
//       () {
//         int upperBound = 3;
//         reverseCounter.countStream(upperBound).listen(
//               expectAsync1(
//                   (value) => expect(
//                         value,
//                         inInclusiveRange(0, upperBound),
//                       ),
//                   count: upperBound + 1),
//             );
//       },
//     );
    test('Stream emits empty list', () async {
      CategoryDAO dao = CategoryDAO(database);
      dao.init();
      expect((await dao.list()), emitsInOrder([[]]));
    });
    test('Stream emits updated list', () async {
      CategoryDAO dao = CategoryDAO(database);
      dao.init();

      (await dao.list()).listen((event) {
        //print("An event has happened $event");
      });

      var stream = await dao.list();

      expect(stream, emitsInOrder([[], isNotNull]));

      await dao.createModel(Category(
          name: "Test1",
          colour: "#202045",
          description: "This is the description to add for test1",
          tags: ["Tag1", "Tag2", "Tag3"]));

      // (await dao.list()).listen((event) {print("An event has happened2 $event");});
    });

    test('Stream emits updated by id', () async {
      CategoryDAO dao = CategoryDAO(database);
      dao.init();

      var result = await dao.createModel(Category(
          name: "Test1",
          colour: "#202045",
          description: "This is the description to add for test1",
          tags: ["Tag1", "Tag2", "Tag3"]));

      var stream = await dao.listById(result.id);
      (await dao.listById(result.id)).listen(
        (event) {} // print("Change")
        ,
      );

      expect(stream, emitsInOrder([isNotNull, isNotNull]));
      var new1 = result.copyWith(name: "Change 1");
      await dao.updateModel(new1);

      var new2 = result.copyWith(name: "Change 2");
      await dao.updateModel(new2);

      // (await dao.list()).listen((event) {print("An event has happened2 $event");});
    });

    test('stream example', () {
      final stream = Stream.fromIterable([
        'Ready.',
        'Loading took 5 seconds',
        'Succeeded!',
      ]);
      expect(
        stream,
        emitsInOrder(['Ready.', 'Loading took 5 seconds', 'Succeeded!']),
      );
    });

    test('DAO - CRUD Operations Work', () async {
      //var config = DatabaseConfiguration(directory: "./test/");

      CategoryDAO dao = CategoryDAO(database);
      dao.init();
      var rtn1 = await dao.createModel(Category(
          name: "Test1",
          colour: "#202045",
          description: "This is the description to add for test1",
          tags: ["Tag1", "Tag2", "Tag3"]));
      expect(rtn1, isNotNull);
      var list = await dao.listModels();

      expect(list, isNotNull);
      expect(list.length, 1);
      expect(list[0].id, rtn1.id);

      var rtn2 = await dao.createModel(Category(
        name: "Test2",
        colour: "#202045",
        description: "This is the description to add for test 2",
        tags: ["Tag1", "Tag2", "Tag3"],
      ));
      expect(rtn2, isNotNull);
      list = await dao.listModels();
      expect(list, isNotNull);
      expect(list.length, 2);

      var rtn3 = await dao.create({
        "name": "The name created",
        "colour": "#FF4422",
        "description": "this is the third description",
        "tags": []
      });
      expect(rtn3, isNotNull);
      list = await dao.listModels();
      expect(list, isNotNull);
      expect(list.length, 3);

      await dao.deleteModel(rtn3);
      list = await dao.listModels();
      expect(list, isNotNull);
      expect(list.length, 2);

      var rtn5 = await dao.getById(rtn3.id);
      expect(rtn5, isNull);

      var rtn4 = await dao.getById(rtn2.id);
      expect(rtn4, rtn2);
    });
  });
}

class CategoryDAO extends CouchbaseDAO<Category> {
  CategoryDAO(super.database);

  @override
  Category createFromMap(Map<String, dynamic> values) {
    // print('Map: $values');
    return Category.fromJson(values);
  }

  @override
  Category createNewModel<S>({String? parentId}) {
    return Category(name: "New Category");
  }

  // @override
  // IModel createNewModel<S>({String? parentId}) {
  //   return Category(name:"New Category");
  // }
}

@JsonSerializable()
@freezed
class Category extends IModel with _$Category implements IHierarchy {
   Category._();

  factory Category({
    dynamic id,
    required String name,
    @Default("") String colour,
    DateTime? createdDate,
    DateTime? modifiedDate,
    @Default("") String description,
    @Default([]) List<String> tags,
    dynamic hierarchyParentId,
  }) = _Category;

  @override
  Map<String, dynamic> toJson() {
    return _$CategoryToJson(this);
  }

  static Category fromJson(Map<String, dynamic> json) =>
      _$CategoryFromJson(json);

  @override
  String get displayLabel => name;

  @override
  IModel copyWithId(
      {dynamic id, DateTime? createdDate, DateTime? modifiedDate}) {
    Category t = this;
    if (id != null) {
      t = t.copyWith(id: id);
    } else if (modifiedDate != null) {
      t = t.copyWith(modifiedDate: modifiedDate);
    } else if (createdDate != null) {
      t = t.copyWith(createdDate: createdDate);
    }
    return t;
  }
}
