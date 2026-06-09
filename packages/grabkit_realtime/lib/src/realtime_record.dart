class GrabKitRealtimeRecord {
  GrabKitRealtimeRecord({
    DateTime? at,
    required this.type,
    required this.message,
    this.payload,
  }) : at = at ?? DateTime.now();

  final DateTime at;
  final String type;
  final String message;
  final Object? payload;
}

typedef SocketEventRecord = GrabKitRealtimeRecord;
