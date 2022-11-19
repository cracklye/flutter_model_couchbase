import 'dart:async';
import 'package:cbl/cbl.dart';
import 'package:flutter_model/flutter_model.dart';
import 'package:loggy/loggy.dart';

/// This provides an in memory API that can be used for testing purposes
/// The data is held within a list in the class so will be lost as soon
/// as the object is removed from memory.
abstract class CouchbaseDAO<T extends IModel> extends IModelAPI<T>
    with UiLoggy {
  final Database database;

  final List<IModelAPI>? childDaos;

  CouchbaseDAO(this.database, {this.childDaos});

  @override
  Future<dynamic> init([dynamic props]) async {
    loggy.debug("CouchbaseDAO.init");
  }

  @override
  Future<dynamic> disconnect() {
    loggy.debug("CouchbaseDAO.disconnect");
    return Future.value(true);
  }

  T createFromMap(Map<String, dynamic> values);

  @override
  Future<T> create(Map<String, dynamic> values) async {
    //Add the defaults...
    loggy.debug("CouchbaseDAO.create(${T.toString()}) $values");

    values.putIfAbsent("dbtype", () => T.toString());
    values.update("createdDate", (value) => DateTime.now().toString(),
        ifAbsent: (() => DateTime.now().toString()));
    values.update("modifiedDate", (value) => DateTime.now().toString(),
        ifAbsent: (() => DateTime.now().toString()));

    //var doc = Document("docid", data: {'name': 'John Doe'});

    final mutableDocument = MutableDocument();
    var id = mutableDocument.id;
    values.update("id", (value) => id, ifAbsent: (() => id));

    mutableDocument.setData(values);
    await database.saveDocument(mutableDocument);
    return createFromMap(values).copyWithId(id: mutableDocument.id) as T;
  }

  @override
  Future<T> createModel(T model) {
    loggy.debug("CouchbaseDAO.create (model)");
    return create(model.toJson());
  }

  @override
  Future<dynamic> update(dynamic id, Map<String, dynamic> values) async {
    loggy.debug("CouchbaseDAO.create values");
    // Read the document.
    values.update("modifiedDate", (value) => DateTime.now().toString(),
        ifAbsent: (() => DateTime.now().toString()));

    Document document = (await database.document(id))!;

    final MutableDocument mutableDocument = document.toMutable();
    //mutableDocument.setData(values);

    for (var key in values.keys) {
      mutableDocument.setValue(values[key], key: key);
    }

    await database.saveDocument(mutableDocument);
  }

  @override
  Future<dynamic> updateModel(T model) {
    loggy.debug("CouchbaseDAO.updateModel(model)");
    return update(model.id, model.toJson());
  }

  @override
  Future<dynamic> deleteByParentId(dynamic parentId) async {
    loggy.debug("CouchbaseDAO.deleteByParentId $parentId");
    loggy.error(
        "Not implemented correctly - need to delete any child entries..");

    final query = await Query.fromN1ql(
        database, "select id from _ where parentid='$parentId'");

    var rs = await query.execute();
    var ar = await rs.allResults();
    for (var r in ar) {
      var val = r["id"];
      deleteById(val.string);
    }
  }

  @override
  Future<dynamic> deleteModel(T model) async {
    return deleteById(model.id);
  }

  @override
  Future<dynamic> deleteById(dynamic id) async {
    loggy.debug("CouchbaseDAO.delete $id");
    var doc = await database.document(id);
    if (doc != null) {
      if (childDaos != null && childDaos!.isNotEmpty) {
        for (var dao in childDaos!) {
          await dao.deleteByParentId(id);
        }
      }
      database.deleteDocument(doc);
    }
  }
  
// select * from _ where dbtype!='' and ( ANY x IN tags SATISFIES x == 'No Colour' END ) and ( ANY x IN tags SATISFIES x == 'Green' END )
// select * from _default where dbtype!='' and ( ANY x IN tags SATISFIES x == 'xxx' END) or ( ANY x IN tags SATISFIES x == 'test' END)

  String buildSQL(String? parentId, String? searchText,
      List<SortOrderBy>? orderBy, List<Filter>? filters) {
    StringBuffer sb = StringBuffer();
    sb.write('select * from _ where dbtype=\'');
    sb.write(T.toString());
    sb.write('\'');
    if (parentId != null) {
      sb.write(" and parentId='$parentId'");
    }
    loggy.debug("CouchbaseDAO.buildSQL() Started");
    // handle all the filters......
    if (filters != null && filters.isNotEmpty) {
      for (var filter in filters) {
        if (filter is FilterField<T>) {
          loggy.debug("CouchbaseDAO.buildSQL() Is Filter field");
          if (filter.fieldName != "") {
            loggy.debug(
                "CouchbaseDAO.buildSQL() Fielname is not empty ${filter.comparison}");
            if (filter.comparison == FilterComparison.isin) {
              sb.write(
                  " ANY ${filter.key} IN ${filter.fieldName} SATISFIES ${filter.key} == ");
              if (filter.isString) {
                sb.write("'${filter.value}'");
              } else {
                sb.write("${filter.value}");
              }
              sb.write(" END ");
            } else {
              sb.write("and ${filter.fieldName} ");
              if (filter.comparison == FilterComparison.equals) {
                sb.write("=");
              } else if (filter.comparison == FilterComparison.notequals) {
                sb.write("!=");
              }
              if (filter.comparison == FilterComparison.greaterthan) {
                sb.write(">");
              }
              if (filter.comparison == FilterComparison.lessthan) {
                sb.write("<");
              }
              if (filter.comparison == FilterComparison.like) {
                sb.write(" LIKE ");
              }

              if (filter.isString) {
                if (filter.comparison == FilterComparison.like) {
                  sb.write("'%${filter.value}%'");
                } else {
                  sb.write("'${filter.value}'");
                }
              } else {
                sb.write("${filter.value}");
              }
            }
          }
        } else {
          loggy.warning("An unknown filter type has been provided $filter");
        }
      }
    }
    if (searchText != null && searchText != "") {
      sb.write(" and match(fti,'$searchText')");
    }
    if (orderBy != null && orderBy.isNotEmpty) {
      sb.write(" order by ");
      int i = 0;
      for (var so in orderBy) {
        if (so is SortOrderByFieldName) {
          var son = so ;
          if (son.fieldName != "") {
            if (i > 0) {
              sb.write(",");
            }
            sb.write(son.fieldName);
            if (son.ascending) {
              sb.write(" asc");
            } else {
              sb.write(" desc");
            }
          } else {
            loggy.warning(
                "An unknown sortorder by type has been provided $orderBy");
          }
        }
      }
    }
    loggy.debug("CouchbaseDAO.buildSQL() returning ${sb.toString()}");
    return sb.toString();
  }

  @override
  Future<Stream<List<T>>> list(
      {String? parentId,
      String? searchText,
      List<SortOrderBy>? orderBy,
      List<Filter>? filters}) async {
    loggy.debug("CouchbaseDAO.list($parentId, $searchText,$orderBy,$filters)");

    final query = await Query.fromN1ql(
        database, buildSQL(parentId, searchText, orderBy, filters));

    var a = query.changes();
    var b = a.asyncMap((event) => event.results.allResults());
    var c = b.map((event) => event
        .map((e) => createFromMap(e.toPlainMap()["_"] as Map<String, Object?>))
        .toList());

    // if (searchText != null && searchText != "") {
    //   //Filter based on the text as we're not handling it elsewhere....
    //   loggy.debug("CouchbaseDAO.list() filtering on search text $searchText");

    //   return c.map((event) =>
    //       event.where((element) => element.filter(searchText)).toList());
    // }
    return c;
  }

  @override
  Future<List<T>> listModels(
      {String? parentId,
      String? searchText,
      List<SortOrderBy>? orderBy,
      List<Filter>? filters}) async {
    loggy.debug("CouchbaseDAO.listModels() ");

    final query = await Query.fromN1ql(
        database, buildSQL(parentId, searchText, orderBy, filters));
    final result = await query.execute();
    final results = await result.allResults();
    var rtn = results
        .map((e) => createFromMap(e.toPlainMap()["_"] as Map<String, Object?>))
        .toList();
    // if (searchText != null && searchText != "") {
    //   //Filter based on the text as we're not handling it elsewhere....
    //   return rtn.where((element) => element.filter(searchText)).toList();
    // }
    return rtn;
  }

  @override
  Future<Stream<T?>> listById(
    dynamic id,
  ) async {
    loggy.debug("CouchbaseDAO.listById($id)");
    final document = database.documentChanges(id);
    Document? doc = await database.document(id);

    StreamController<T?> controller = StreamController<T?>();
    Stream<T?> s = controller.stream;
    controller.add(createFromMap(doc!.toPlainMap()));
   // var stream =
        document.asyncMap((event) => getById(event.documentId)).listen((event) {
      controller.add(event);
    });

    return Future.value(s);
  }

  @override
  Future<T?> getById(
    dynamic id,
  ) async {
    loggy.debug("CouchbaseDAO.getById($id)");
    final document = (await database.document(id));

    if (document == null) return null;
    loggy.debug('createFromMap ${document.toPlainMap().toString()}');
    return createFromMap(document.toPlainMap());
  }
}
