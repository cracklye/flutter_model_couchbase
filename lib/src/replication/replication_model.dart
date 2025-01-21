
enum ReplicationChange {
  started,
  stopped,
  error,
  offline,
  connecting,
  busy,
  idle,
}

class ReplicationMessage {}

class ReplicationMessageProgress extends ReplicationMessage {
  final double progress;
  final int docsProcessed;
  ReplicationMessageProgress(this.progress, this.docsProcessed);
}

class ReplicationMessageError extends ReplicationMessage {
  final String message;
  ReplicationMessageError(this.message);
}

class ReplicationMessageLog extends ReplicationMessage {
  final String message;
  ReplicationMessageLog(this.message);
}

class ReplicationMessageDocumentUpdate extends ReplicationMessage {
  final List<String> documentTitles;
  ReplicationMessageDocumentUpdate(this.documentTitles);
}


class ReplicationMessageStatusChange extends ReplicationMessage {
  final String message;
  final ReplicationChange change;
  ReplicationMessageStatusChange(this.message, this.change);
}
