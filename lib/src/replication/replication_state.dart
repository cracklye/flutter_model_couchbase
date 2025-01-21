
abstract class ReplicationState {
  const ReplicationState({required this.logs});
  final List<ReplicationEventLog> logs;
}

class ReplicationStateActive extends ReplicationState {
  final String? error;
  final ReplicationChange? status;
  final double? progress;
  final bool timerActive;

  const ReplicationStateActive(
      {this.error,
      this.status,
      this.progress,
      super.logs = const [],
      this.timerActive = false});

  ReplicationStateActive copyWith(
      {String? error,
      ReplicationChange? status,
      bool clearError = false,
      List<ReplicationEventLog>? logs,
      double? progress,
      bool clearProgress = false,
      ReplicationEventLog? appendLog,
      bool? timerActive}) {
    var newLogs = logs ?? this.logs;
    if (appendLog != null) {
      newLogs = _appendLog(newLogs, appendLog);
    }

    return ReplicationStateActive(
      error: clearError ? null : (error ?? this.error),
      status: status ?? this.status,
      logs: newLogs,
      timerActive: timerActive ?? this.timerActive,
      progress: clearProgress ? null : (progress ?? this.progress),
    );
  }

  List<ReplicationEventLog> _appendLog(
      List<ReplicationEventLog> entries, ReplicationEventLog logEntry) {
    return [logEntry, ...entries];
  }

  bool get hasError => error != null && error != "";

  bool get isActive =>
      (status == ReplicationChange.connecting) ||
      (status == ReplicationChange.started) ||
      (status == ReplicationChange.busy);
}

class ReplicationStateUnavailable extends ReplicationState {
  const ReplicationStateUnavailable({super.logs = const []});
}
