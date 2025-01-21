
import 'package:flutter_model_couchbase/src/replication/replication_model.dart';

class ReplicationEvent {
  const ReplicationEvent();
}

class ReplicationEventInit extends ReplicationEvent {
  final Map<String, dynamic>? params;
  final bool start;

  const ReplicationEventInit([this.params, this.start = false]);
}

class ReplicationEventStart extends ReplicationEvent {
  const ReplicationEventStart();
}

class ReplicationEventStop extends ReplicationEvent {
  const ReplicationEventStop();
}

class ReplicationEventInactive extends ReplicationEvent {
  const ReplicationEventInactive();
}

class ReplicationEventUpdate extends ReplicationEvent {
  final ReplicationMessage message;

  const ReplicationEventUpdate(this.message);
}

class ReplicationEventClearLog extends ReplicationEvent {
  const ReplicationEventClearLog();
}

class ReplicationEventClearError extends ReplicationEvent {
  const ReplicationEventClearError();
}

class ReplicationEventScheduleStart extends ReplicationEvent {
  const ReplicationEventScheduleStart();
}

class ReplicationEventScheduleStop extends ReplicationEvent {
  const ReplicationEventScheduleStop();
}
