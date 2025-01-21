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

  Map<String, dynamic> convertToPureMap(Map<String, dynamic> values) {
    return values;
  }

  @override
  Future<T> create(Map<String, dynamic> values) async {
    //Add the defaults...
    loggy.debug("CouchbaseDAO.create(${T.toString()})");

    values.putIfAbsent("dbtype", () => T.toString());
    values.update("createdDate", (value) => DateTime.now().toString(),
        ifAbsent: (() => DateTime.now().toString()));
    values.update("modifiedDate", (value) => DateTime.now().toString(),
        ifAbsent: (() => DateTime.now().toString()));

    //var doc = Document("docid", data: {'name': 'John Doe'});
    values = convertToPureMap(values);

    final mutableDocument = MutableDocument();
    var id = mutableDocument.id;
    values.update("id", (value) => id, ifAbsent: (() => id));

    mutableDocument.setData(values);
    await (await database.defaultCollection).saveDocument(mutableDocument);
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
    values = convertToPureMap(values);

    values.update("modifiedDate", (value) => DateTime.now().toString(),
        ifAbsent: (() => DateTime.now().toString()));

    Document document =
        (await (await database.defaultCollection).document(id))!;

    final MutableDocument mutableDocument = document.toMutable();
    //mutableDocument.setData(values);

    for (var key in values.keys) {
      mutableDocument.setValue(values[key], key: key);
    }

    await (await database.defaultCollection).saveDocument(mutableDocument);
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

    // final query = await Query.fromN1ql(
    //     database, "select id from _ where parentid='$parentId'");
    final query = await database
        .createQuery("select id from _ where parentid='$parentId'");

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
    var doc = await (await database.defaultCollection).document(id);
    if (doc != null) {
      if (childDaos != null && childDaos!.isNotEmpty) {
        for (var dao in childDaos!) {
          await dao.deleteByParentId(id);
        }
      }
      (await database.defaultCollection).deleteDocument(doc);
    }
  }

// select * from _ where dbtype!='' and ( ANY x IN tags SATISFIES x == 'No Colour' END ) and ( ANY x IN tags SATISFIES x == 'Green' END )
// select * from _default where dbtype!='' and ( ANY x IN tags SATISFIES x == 'xxx' END) or ( ANY x IN tags SATISFIES x == 'test' END)

  List<String> getDbTypes(List<Filter>? filters) {
    return [T.toString()];
  }

  String buildSQL(String? parentId, String? searchText,
      List<SortOrderBy>? orderBy, List<Filter>? filters) {
    StringBuffer sb = StringBuffer();
    sb.write('select * from _  ');

    bool hasQuery = false;

    if (parentId != null) {
      sb.write(" where ");
      sb.write(" parentId='$parentId'");
      hasQuery = true;
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
              List<dynamic> values = [];

              if (filter.value is List) {
                values = filter.value;
              } else {
                values.add(filter.value);
              }
              int iCount = 0;

              for (var val in values) {
                if (hasQuery) {
                  sb.write(" and ");
                } else {
                  sb.write(" where ");
                }
                sb.write(
                    " ANY ${filter.key}${iCount} IN ${filter.fieldName} SATISFIES ${filter.key}${iCount} == ");
                if (filter.isString) {
                  sb.write("'${val}'");
                } else {
                  sb.write("${val}");
                }
                sb.write(" END ");
                iCount += 1;
                hasQuery = true;
              }
            } else {
              sb.write(" ${filter.fieldName} ");
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
              hasQuery = true;
            }
          }
        } else {
          loggy.warning("An unknown filter type has been provided $filter");
        }
      }
    }

    if (getDbTypes(filters).isNotEmpty) {
      bool hasOne = false;
      if (hasQuery) {
        sb.write(" and ");
      } else {
        sb.write(" where ");
      }

      sb.write("(");
      for (var type in getDbTypes(filters)) {
        if (hasOne) {
          sb.write(" or ");
        }
        sb.write(' dbtype=\'');
        sb.write(type);
        sb.write('\'');
        hasOne = true;
      }
      sb.write(")");
      hasQuery = true;
    }

    if (searchText != null && searchText != "") {
      if (hasQuery) {
        sb.write(" and ");
      } else {
        sb.write(" where ");
      }
      sb.write(" match(fti,'$searchText')");
    }
    if (orderBy != null && orderBy.isNotEmpty) {
      sb.write(" order by ");
      int i = 0;
      for (var so in orderBy) {
        if (so is SortOrderByFieldName) {
          var son = so;
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
    loggy.debug("CouchbaseDAO.buildSQL() returning2 ${sb.toString()}");
    return sb.toString();
  }

  @override
  Future<Stream<List<T>>> list(
      {String? parentId,
      String? searchText,
      List<SortOrderBy>? orderBy,
      List<Filter>? filters}) async {
    loggy.debug("CouchbaseDAO.list($parentId, $searchText,$orderBy,$filters)");

    // final query = await Query.fromN1ql(
    //     database, buildSQL(parentId, searchText, orderBy, filters));

    final query = await database
        .createQuery(buildSQL(parentId, searchText, orderBy, filters));

    var a = query.changes();
    var b = a.asyncMap((event) => event.results.allResults());
    var c = b.map((event) => event
        .map((e) {
          try {
            return createFromMap(e.toPlainMap()["_"] as Map<String, Object?>);
          } catch (e) {
            loggy.error("Unable to create object from map $e");
            return null;
          }
        })
        .where((e) => e != null)
        .toList()
        .cast<T>());

    return c;
  }

  @override
  Future<List<T>> listModels(
      {String? parentId,
      String? searchText,
      List<SortOrderBy>? orderBy,
      List<Filter>? filters}) async {
    loggy.debug("CouchbaseDAO.listModels() ");
    final query = await database
        .createQuery(buildSQL(parentId, searchText, orderBy, filters));

    // final query = await Query.fromN1ql(
    //     database, buildSQL(parentId, searchText, orderBy, filters));
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
    final document = (await database.defaultCollection).documentChanges(id);
    Document? doc = await (await database.defaultCollection).document(id);

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
    final document = (await (await database.defaultCollection).document(id));

    if (document == null) return null;

    return createFromMap(document.toPlainMap());
  }
}
