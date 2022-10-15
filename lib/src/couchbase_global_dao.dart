import 'dart:async';
import 'package:cbl/cbl.dart';
import 'package:flutter_model/flutter_model.dart';
import 'package:flutter_model_couchbase/flutter_model_couchbase.dart';
import 'package:loggy/loggy.dart';

/// This provides an in memory API that can be used for testing purposes
/// The data is held within a list in the class so will be lost as soon
/// as the object is removed from memory.
class CouchbaseGlobalDAO with UiLoggy {
  final Database database;

  CouchbaseGlobalDAO(this.database);

  String buildSQL(String? parentId, String? searchText,
      List<SortOrderBy>? orderBy, List<Filter>? filters, String? sql) {
    StringBuffer sb = StringBuffer();
    bool hasWhere = false;
    if (sql != null && sql != "") {
      sb.write(sql);
    } else {
      sb.write('select * from _ where dbtype!=\'');
      sb.write('\' ');
      hasWhere = true;
    }

    if (parentId != null) {
      if (!hasWhere) {
        sb.write(" where ");
        hasWhere = true;
      } else {
        sb.write(" and ");
      }

      sb.write(" parentId='$parentId'");
    }

    // handle all the filters......
    if (filters != null && filters.isNotEmpty) {
      for (var filter in filters) {
        if (filter is FilterField) {
          if (filter.fieldName != "") {
            if (!hasWhere) {
              sb.write(" where ");
              hasWhere = true;
            } else {
              sb.write(" and ");
            }

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
              sb.write("'${filter.value}'");
            } else {
              sb.write("${filter.value}");
            }
          }
        } else {
          loggy.warning("An unknown filter type has been provided $filter");
        }
      }
    }

    if (orderBy != null && orderBy.isNotEmpty) {
      sb.write(" order by ");
      int i = 0;
      for (var so in orderBy) {
        if (so is SortOrderByFieldName) {
          var son = so as SortOrderByFieldName;
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
  Future<Stream<List<ModelStub>>> list(
      {String? parentId,
      String? searchText,
      List<SortOrderBy>? orderBy,
      List<Filter>? filters,
      String? sql}) async {
    loggy.debug("CouchbaseDAO.list($parentId, $searchText,$orderBy,$filters)");

    final query = await Query.fromN1ql(
        database, buildSQL(parentId, searchText, orderBy, filters, sql));

    var a = query.changes();
    var b = a.asyncMap((event) => event.results.allResults());
    var c = b.map((event) => event
        .map((e) {
          print(e);
          return  ModelStub(e.toPlainMap()['_'] as Map<String, Object?>);} )
        .toList());


    if (searchText != null && searchText != "") {
      //Filter based on the text as we're not handling it elsewhere....
      loggy.debug("CouchbaseDAO.list() filtering on search text $searchText");

      return c.map((event) =>
          event.where((element) => element.filter(searchText)).toList());
    }
    return c;
  }

  @override
  Future<List<ModelStub>> listModels(
      {String? parentId,
      String? searchText,
      List<SortOrderBy>? orderBy,
      List<Filter>? filters,
      String? sql}) async {
    loggy.debug("CouchbaseDAO.listModels() ");

    final query = await Query.fromN1ql(
        database, buildSQL(parentId, searchText, orderBy, filters, sql));
    final result = await query.execute();
    final results = await result.allResults();
    var rtn = results
        .map((e) => ModelStub(e.toPlainMap()["_"] as Map<String, Object?>))
        .toList();
    if (searchText != null && searchText != "") {
      //Filter based on the text as we're not handling it elsewhere....
        return rtn.where((element) => element.filter(searchText)).toList();
    }
    return rtn;
  }
}
