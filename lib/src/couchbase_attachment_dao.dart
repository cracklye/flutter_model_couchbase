import 'dart:io';
import 'dart:typed_data';

import 'package:cbl/cbl.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_model/flutter_model.dart';

class CouchbaseAttachmentDAO extends AttachmentDAO {
  final Database database;
  CouchbaseAttachmentDAO(this.database);
  @override
  Future init([String? rootPath]) async {
    AttachmentDAO.active = this;
  }

  @override
  Future<void> savePathPost(
      String fieldName, String srcPath, dynamic id, String? mimeType) async {
    var src = File(srcPath);

    Document? doc = await database.document(id);
    MutableDocument mdco = doc!.toMutable();
    Blob blob = Blob.fromData(mimeType ?? "unknown", await src.readAsBytes());
    mdco.setBlob(blob, key: "${fieldName}blob");
    mdco.setValue({"hasvalue": true, "mimeType": mimeType}, key: fieldName);
    database.saveDocument(mdco);

    // String uid =const Uuid().v4();
    // var ext = extension(srcPath);
    // String relativeURI = '$subdir\\$uid$ext';
    // String fullUri = '$_rootPath\\$relativeURI';

    // var src = File(srcPath);
    // await src.copy(fullUri);

    // return Future.value({
    //   "${fieldName}Uri": relativeURI,
    //   "${fieldName}ThumbnailUri": "/thumbnail/jpg"
    // });
  }

  @override
  Future<Map<String, dynamic>?> savePath(
      String fieldName, String srcPath, String? mimeType) async {
    return {};
    // String uid =const Uuid().v4();
    // var ext = extension(srcPath);
    // String relativeURI = '$subdir\\$uid$ext';
    // String fullUri = '$_rootPath\\$relativeURI';

    // var src = File(srcPath);
    // await src.copy(fullUri);

    // return Future.value({
    //   "${fieldName}Uri": relativeURI,
    //   "${fieldName}ThumbnailUri": "/thumbnail/jpg"
    // });
  }

  @override
  Future<ImageProvider> getImageProvider(IModel coverImage,
      Map<String, dynamic>? details, String fieldName) async {
    Document? doc = await database.document(coverImage.id);
    Blob? blob = doc!.blob("${fieldName}blob");
    var content = await blob!.content();

    var f = MemoryImage(content);
    return f;
  }

  @override
  Future<Map<String, dynamic>?> removeContentPost(
      String fieldName, dynamic id) async {
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
    Document? doc = await database.document(id);
    MutableDocument mdco = doc!.toMutable();
    Blob blob = Blob.fromData(mimeType ?? "unknown", data);
    mdco.setBlob(blob, key: "${fieldName}blob");
    mdco.setValue({"hasvalue": true, "mimeType": mimeType}, key: fieldName);

    database.saveDocument(mdco);
  }

  @override
  Future<Map<String, dynamic>?> saveContent(
      String fieldName, Uint8List data, String? ext, String? mimeType) async {
    return {};
    // String uid = const Uuid().v4();

    // String relativeURI = '$subdir\\$uid$ext';
    // String fullUri = '$_rootPath\\$relativeURI';

    // var newf = File(fullUri);
    // //var sink =
    // await newf.writeAsBytes(data);

    // return Future.value({
    //   "${fieldName}Uri": relativeURI,
    //   "${fieldName}ThumbnailUri": "/thumbnail/jpg"
    // });
  }
}
