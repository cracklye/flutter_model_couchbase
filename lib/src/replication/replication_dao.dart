import 'dart:async';

import 'package:cbl/cbl.dart';
import 'package:loggy/loggy.dart';



//TODO https://github.com/cbl-dart/cbl-dart/pull/599  Once this is accepted then we can go back to using the normal version

class EmptyReplicationDao extends IReplicationDao {
  @override
  bool get isReplicationAvailable => false;
  @override
  addListener(Function(ReplicationMessage message)? listener) async {}

  @override
  Future<void> init(Map<String, dynamic> params) async {}

  @override
  bool isInit() {
    return false;
  }

  @override
  Future<bool> isRunning() {
    return Future.value(false);
  }

  @override
  Future<void> start() async {}

  @override
  Future<void> stop() async {}
}

abstract class IReplicationDao {
  Future<void> start();
  Future<void> stop();
  Future<void> init(Map<String, dynamic> params);
  bool isInit();
  Future<bool> isRunning();

  addListener(Function(ReplicationMessage message)? listener);
  bool get isReplicationAvailable => true;
}

class CouchbaseReplicationDao extends IReplicationDao with UiLoggy {
  final Database database;
  Replicator? _replicator;
  String? uri;

  CouchbaseReplicationDao(this.database);

  Function(ReplicationMessage message)? _listener;

  @override
  void addListener(Function(ReplicationMessage message)? listener) {
    _listener = listener;
  }

  @override
  bool isInit() {
    return _replicator != null;
  }

  @override
  Future<void> init(Map<String, dynamic> params) async {
    String port = "4984";
    String dbName = "notd_live";
    String? address = "";
    String? username = "";
    String? password = "";
    bool autoStart = true;

    if (AppEnvironment.isRelease) {
      username = "sync_gateway_user";
      password = "oi8v6i27VrC#4@QaHCPs%Q";
    } else {
      username = "sync_gateway_user";
      password = "oi8v6i27VrC#4@QaHCPs%Q";
    }

    if (params[AppSettings.prefReplicationAddress] != null &&
        params[AppSettings.prefReplicationAddress] != "") {
      address = params[AppSettings.prefReplicationAddress].toString();
    }
    if (params[AppSettings.prefReplicationDbname] != null &&
        params[AppSettings.prefReplicationDbname] != "") {
      dbName = params[AppSettings.prefReplicationDbname].toString();
    }
    if (params[AppSettings.prefReplicationUsername] != null &&
        params[AppSettings.prefReplicationUsername] != "") {
      username = params[AppSettings.prefReplicationUsername].toString();
    }
    if (params[AppSettings.prefReplicationPassword] != null &&
        params[AppSettings.prefReplicationPassword] != "") {
      password = params[AppSettings.prefReplicationPassword].toString();
    }
    try {
      autoStart = bool.parse(params[AppSettings.prefReplicationAutostart]);
    } catch (e) {
      //Don't do anything...
    }

//'ws://192.168.1.71:4984/note_live';

    if (address != "") {
      uri = 'ws://$address:$port/$dbName';
      _replicator = await Replicator.create(ReplicatorConfiguration(
        // continuous: true,
        // maxAttemptWaitTime: Duration(minutes: 2),
        // maxAttempts: 100,
        authenticator:
            BasicAuthenticator(username: username, password: password),
        //database: database,
        target: UrlEndpoint(Uri.parse(uri!)),
      )..addCollection(await database.defaultCollection));

      _listener!(ReplicationMessageLog(
          'Initialising with uri $uri and username $username'));

      _replicator!.addDocumentReplicationListener((doc) {
        loggy.debug('Document Changes :${doc.documents.toString()} ');

        if (_listener != null) {
          _listener!(ReplicationMessageDocumentUpdate(
              doc.documents.map((e) => e.id.toString()).toList()));
        }
      });

      await _replicator!.addChangeListener((change) {
        loggy.debug(
            'changeListener Replicator activity: \n activity :${change.status.activity} \n status: ${change.status} \n change: $change ');

        if (_listener != null) {
          String error = "";
          if (change.status.error != null) {
            error = change.status.error.toString();
            _listener!(ReplicationMessageError(error));
          }

          if (change.status.activity == ReplicatorActivityLevel.stopped) {
            _listener!(ReplicationMessageStatusChange(
                "Replication Stopped: $error", ReplicationChange.stopped));
          } else if (change.status.activity == ReplicatorActivityLevel.busy) {
            _listener!(ReplicationMessageStatusChange(
                "Replication Busy:  ", ReplicationChange.busy));
            _listener!(ReplicationMessageProgress(
                change.status.progress.progress,
                change.status.progress.completed));
          } else if (change.status.activity ==
              ReplicatorActivityLevel.connecting) {
            _listener!(ReplicationMessageStatusChange(
                "Replication connecting : $error",
                ReplicationChange.connecting));

            _listener!(ReplicationMessageProgress(
                change.status.progress.progress,
                change.status.progress.completed));
          } else if (change.status.activity ==
              ReplicatorActivityLevel.offline) {
            _listener!(ReplicationMessageStatusChange(
                "Offline : $error", ReplicationChange.offline));
          } else if (change.status.activity == ReplicatorActivityLevel.idle) {
            _listener!(ReplicationMessageStatusChange(
                "Idle : $error", ReplicationChange.idle));
          } else {
            _listener!(ReplicationMessageError(
                "Replication Unhandled status ${change.status.activity}"));
          }
        }
      });
      if (autoStart) {
        await start();
      }
    }
  }

  @override
  Future<bool> isRunning() async {
    if (_replicator == null) {
      return false;
    }
    return (await _replicator!.status).activity == ReplicatorActivityLevel.busy;
  }

  @override
  Future<void> stop() async {
    loggy.debug('stop() Stopping Replicator');
    _listener!(ReplicationMessageLog("Stopping Replicator"));
    if (_replicator != null) {
      await _replicator!.stop();
      var statuss = await _replicator!.status;
      loggy.debug(
          'stop() Stopped Replicator status is now: ${statuss.toString()}');
    }
    loggy.debug('stop() Stopped Replicator');
  }

  @override
  Future<void> start() async {
    loggy.debug('start() Starting Replicator $uri ');
    _listener!(ReplicationMessageLog("Starting Replicator  $uri "));

    if (_replicator == null) {
      _listener!(ReplicationMessageLog("Replication has not been configured"));
      throw Exception("Replication has not been configured");
    }
    await _replicator!.start();
    loggy.debug('start() Started Replicator $uri ');
  }
}
