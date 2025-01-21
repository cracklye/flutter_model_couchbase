import 'dart:async';

import 'package:cbl/cbl.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:loggy/loggy.dart';

abstract class CbEvent {
  const CbEvent();
}

/// This class is designed for use when you wish to
/// select a model in this state.
class CBEventRebuildIndexes extends CbEvent {
  const CBEventRebuildIndexes();
}

class CBEventInit extends CbEvent {
  const CBEventInit();
}

abstract class CBState {}

class CBStateLoaded extends CBState {
  final String name;
  final int count;
  final List<String> indexes;
  final String? path;
  final DatabaseConfiguration config;

  CBStateLoaded(this.name, this.count, this.indexes, this.path, this.config);
}

class CBStateNotLoaded extends CBState {
  CBStateNotLoaded();
}

class CbDatabaseBloc extends Bloc<CbEvent, CBState> with UiLoggy {
  final Database database;

  CbDatabaseBloc(
      {required this.database,
      //required this.rebuildIndex,
      CBState? initialState})
      : super(initialState ?? CBStateNotLoaded()) {
    on<CBEventRebuildIndexes>(_onCBEventRebuildIndexes);
    on<CBEventInit>(_onCBEventInit);
  }

  /// Initialises the bloc and refreshes the state from the database.
  Future _onCBEventInit(CBEventInit event, Emitter<CBState> emit) async {
    loggy.debug("_onCBEventInit started }");
    //await _refreshState(emit);
    add(const CBEventRebuildIndexes());
  }

  /// this method will refresh the state as required.
  Future _refreshState(Emitter<CBState> emit) async {
    var count = await (await database.defaultCollection).count;
    var indexes = await (await database.defaultCollection).indexes;

    emit(CBStateLoaded(
      database.name,
      count,
      indexes,
      database.path,
      database.config,
    ));
  }

  /// Will rebuild the indexes of the database and refresh the state
  void _onCBEventRebuildIndexes(
      CBEventRebuildIndexes event, Emitter<CBState> emit) async {
    loggy.debug("_onCBEventRebuildIndexes started }");
    await createFTIndexes(database);
    await _refreshState(emit);
    loggy.debug("_onCBEventRebuildIndexes Complete }");
  }
}

/// This is the method that creates the indexes required by this application
/// It should be called when starting the application, but can also
/// be called via the bloc if that is required.
Future<void> createFTIndexes(Database database) async {
  var fti = FullTextIndexConfiguration([
    "name",
    "title",
    "content",
    "description",
    "tags",
    "text",
    "label",
    "properties"
  ], language: FullTextLanguage.english);
  await (await database.defaultCollection).deleteIndex("fti");
  await (await database.defaultCollection).createIndex("fti", fti);
}
