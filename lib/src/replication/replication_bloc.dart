import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_model/bloc/preferences/preferences_bloc.dart';
import 'package:loggy/loggy.dart';
import 'package:notd/app/app_settings.dart';

class ReplicationEventLog {
  final DateTime time;
  final String message;
  final int? progress;
  final int? count;

  ReplicationEventLog(this.message, {DateTime? time, this.progress, this.count})
      : time = time ?? DateTime.now();
}

class ReplicationBloc extends Bloc<ReplicationEvent, ReplicationState>
    with UiLoggy {
  final IReplicationDao dao;
  final PreferencesBloc<AppSettings> preferences;

  late StreamSubscription preferenceSub;

  ReplicationBloc(this.dao, this.preferences,
      [super.initialState = const ReplicationStateUnavailable(logs: [])]) {
    on<ReplicationEventInit>(_onReplicationEventInit);
    on<ReplicationEventClearLog>(_onReplicationEventClearLog);

    on<ReplicationEventStart>(_onReplicationEventStart);
    on<ReplicationEventUpdate>(_onReplicationEventUpdate);
    on<ReplicationEventStop>(_onReplicationEventStop);
    on<ReplicationEventClearError>(_onReplicationEventClearError);

    on<ReplicationEventScheduleStart>(_onReplicationEventScheduleStart);
    on<ReplicationEventScheduleStop>(_onReplicationEventScheduleStop);

    dao.addListener((message) => add(ReplicationEventUpdate(message)));

    preferenceSub = preferences.stream.listen((stateAuth) {
      //here is my problem because stateAuth, even is AuthenticationAuthenticated it return always false.
      if (stateAuth is PreferencesLoaded) {
        add(ReplicationEventInit(stateAuth.pref.values));
      }
    });
  }

  Timer? _timer;

  Timer scheduleTimeout([int seconds = 60]) =>
      Timer.periodic(Duration(seconds: seconds), handleRequestReplication);

  void handleRequestReplication(Timer timer) {
    loggy.debug("handleRequestReplication - starting request to start");
    if (state is ReplicationStateActive) {
      ReplicationStateActive newState = (state as ReplicationStateActive);
      if (!newState.isActive) {
        add(const ReplicationEventStart());
      }
    }
  }

  FutureOr<void> _onReplicationEventScheduleStart(
      ReplicationEventScheduleStart event,
      Emitter<ReplicationState> emit) async {
    if (state is ReplicationStateActive) {
      if (_timer == null) {
        ReplicationStateActive newState = (state as ReplicationStateActive);
        _timer = scheduleTimeout(60);
        emit(newState.copyWith(timerActive: true));
      }
    }
  }

  FutureOr<void> _onReplicationEventScheduleStop(
      ReplicationEventScheduleStop event,
      Emitter<ReplicationState> emit) async {
    if (_timer != null) {
      _timer!.cancel();
      _timer = null;
      emit((state as ReplicationStateActive).copyWith(timerActive: false));
      //emit((state as ReplicationStateActive).copyWith(clearError: true));
    }
  }

  FutureOr<void> _onReplicationEventClearError(
      ReplicationEventClearError event, Emitter<ReplicationState> emit) async {
    if (state is ReplicationStateActive) {
      emit((state as ReplicationStateActive).copyWith(clearError: true));
    } else {
      emit(ReplicationStateUnavailable(logs: state.logs));
    }
  }

  FutureOr<void> _onReplicationEventClearLog(
      ReplicationEventClearLog event, Emitter<ReplicationState> emit) async {
    if (state is ReplicationStateActive) {
      emit((state as ReplicationStateActive).copyWith(logs: []));
    } else {
      emit(const ReplicationStateUnavailable());
    }
  }

  FutureOr<void> _onReplicationEventStart(
      ReplicationEventStart event, Emitter<ReplicationState> emit) async {
    if (await dao.isRunning()) {
      // Don't do anything if it is already running...
      return;
    }

    if (!dao.isInit()) {
      await dao.init({});
    }

    await dao.start();
  }

  FutureOr<void> _onReplicationEventUpdate(
      ReplicationEventUpdate event, Emitter<ReplicationState> emit) async {
    ReplicationStateActive? activeState = state is ReplicationStateActive
        ? (state as ReplicationStateActive)
        : ReplicationStateActive(logs: state.logs);

    var message = event.message;

    if (message is ReplicationMessageError) {
      activeState = activeState.copyWith(
          error: message.message,
          appendLog: ReplicationEventLog(message.message));
    } else if (message is ReplicationMessageLog) {
      activeState =
          activeState.copyWith(appendLog: ReplicationEventLog(message.message));
    } else if (message is ReplicationMessageProgress) {
      activeState = activeState.copyWith(
          progress: message.progress,
          appendLog: ReplicationEventLog("Replicating",
              progress: ((message.progress * 100).toInt() ),
              count: message.docsProcessed));
    } else if (message is ReplicationMessageStatusChange) {
      // if (activeState.status != message.change) {
      activeState = activeState.copyWith(
          status: message.change,
          appendLog: ReplicationEventLog("Changed status ${message.change}"));
      // } else {
      //   activeState = null;
      // }
    } else if (message is ReplicationMessageDocumentUpdate) {
      activeState = activeState.copyWith(
          appendLog: ReplicationEventLog(
              "Documents Replicated: ${message.documentTitles}",
              count: message.documentTitles.length));
    } else {
      activeState.copyWith(
          appendLog: ReplicationEventLog("Unknown log ${message.toString()}"));
    }
    emit(activeState);
    }

  FutureOr<void> _onReplicationEventStop(
      ReplicationEventStop event, Emitter<ReplicationState> emit) async {
    await dao.stop();
  }

  Future<void> _doInit(Map<String, dynamic> params) async {
    await dao.init(params);
  }

  FutureOr<void> _onReplicationEventInit(
      ReplicationEventInit event, Emitter<ReplicationState> emit) async {
    if (dao.isReplicationAvailable) {
      await dao.stop();
      emit(ReplicationStateActive(
          status: ReplicationChange.stopped, logs: state.logs));
      Map<String, dynamic>? params =
          event.params ?? preferences.state.pref.values;
      // if (params != null) {
      _doInit(params);
      // }
      // await dao.stop();
      // emit(ReplicationStateActive(
      //     status: ReplicationChange.stopped, logs: state.logs));

      // await dao.init(event.params);
      if (event.start) {
        //Now start the replication.....
        _onReplicationEventScheduleStart(
            const ReplicationEventScheduleStart(), emit);
      }
    } else {
      emit(ReplicationStateUnavailable(logs: state.logs));
    }
  }
}
