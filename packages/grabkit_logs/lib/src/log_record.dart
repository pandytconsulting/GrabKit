class GrabKitLogRecord {
  GrabKitLogRecord({
    DateTime? at,
    required this.level,
    required this.message,
    this.attributes = const {},
  }) : at = at ?? DateTime.now();

  final DateTime at;
  final String level;
  final String message;
  final Map<String, Object?> attributes;
}

typedef AppLogRecord = GrabKitLogRecord;
