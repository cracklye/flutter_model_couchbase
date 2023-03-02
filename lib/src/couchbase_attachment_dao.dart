import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:cbl/cbl.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_model/flutter_model.dart';
import 'package:loggy/loggy.dart';

///
class CouchbaseAttachmentDAO extends AttachmentDAO with UiLoggy {
  final Database database;
  CouchbaseAttachmentDAO(this.database);

  @override
  Future init([String? rootPath]) async {
    AttachmentDAO.active = this;
  }

  @override
  Future<void> savePathPost(
      String fieldName, String srcPath, dynamic id, String? mimeType) async {
    loggy.debug(
        "savePathPost started fieldName: $fieldName id= $id  srcPath= $srcPath");

    var src = File(srcPath);

    Document? doc = await database.document(id);
    loggy.debug("savePathPost Have document ${doc!.toJson()}");

    MutableDocument mdco = doc.toMutable();
    Blob blob = Blob.fromData(mimeType ?? "unknown", await src.readAsBytes());
    mdco.setBlob(blob, key: "${fieldName}blob");
    mdco.setValue({"hasvalue": true, "mimeType": mimeType}, key: fieldName);
    loggy.debug("savePathPost Saving the document");
    database.saveDocument(mdco);
  }

  @override
  Future<Map<String, dynamic>?> savePath(
      String fieldName, String srcPath, String? mimeType) async {
    loggy.debug("savePath started $fieldName returning empty");
    return {};
  }

  @override
  Future<ImageProvider> getImageProvider(
      IModel coverImage, Map<String, dynamic>? details, String field) async {
    Document? doc = await database.document(coverImage.id);
    Blob? blob = doc!.blob("${field}blob");

    if (blob != null) {
      var content = await blob.content();

      var f = MemoryImage(content);
      return f;
    }
    Uint8List blankBytes = const Base64Codec().decode(
        //"data:image/gif;base64,R0lGODlhAQABAIAAAAAAAP///yH5BAEAAAAALAAAAAABAAEAAAIBRAA7");
        "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg==");
    // return Image.network('https://flutter.github.io/assets-for-api-docs/assets/widgets/owl-2.jpg')
    return MemoryImage(blankBytes);
  }

  @override
  Future<Map<String, dynamic>?> removeContentPost(
      String fieldName, dynamic id) async {
    loggy.debug("removeContentPost started $fieldName");

    //Delete it and return null;
    Document? doc = await database.document(id);
    MutableDocument mdco = doc!.toMutable();
    mdco.setBlob(null, key: "${fieldName}blob");
    //mdco.setValue({"hasvalue": true}, key: fieldName);
    mdco.removeValue(fieldName);

    database.saveDocument(mdco);
    return null;
  }

  @override
  Future<Map<String, dynamic>?> saveContentPost(String fieldName,
      Uint8List data, String? ext, dynamic id, String? mimeType) async {
    loggy.debug("saveContentPost started update for field $fieldName");

    Document? doc = await database.document(id);
    MutableDocument mdco = doc!.toMutable();
    Blob blob = Blob.fromData(mimeType ?? "unknown", data);
    mdco.setBlob(blob, key: "${fieldName}blob");
    mdco.setValue({"hasvalue": true, "mimeType": mimeType}, key: fieldName);

    loggy.debug("saveContentPost saved document with id $id");
    database.saveDocument(mdco);

    return null;
  }

  @override
  Future<Map<String, dynamic>?> saveContent(
      String fieldName, Uint8List data, String? ext, String? mimeType) async {
    loggy.debug("saveContent started $fieldName");
    return {};
  }
}
