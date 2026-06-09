import 'package:flutter/foundation.dart';
import 'package:grabkit/grabkit.dart';

import 'realtime_record.dart';

class GrabKitRealtimeStore extends ChangeNotifier {
  GrabKitRealtimeStore({this.maxEntries = 300, this.eventBus});

  static final GrabKitRealtimeStore instance = GrabKitRealtimeStore();

  final int maxEntries;
  GrabKitEventBus? eventBus;
  final List<GrabKitRealtimeRecord> _entries = [];

  List<GrabKitRealtimeRecord> get entries => List.unmodifiable(_entries);

  void add(String type, String message, {Object? payload}) {
    final record = GrabKitRealtimeRecord(
      type: type,
      message: message,
      payload: payload,
    );
    _entries.insert(0, record);
    while (_entries.length > maxEntries) {
      _entries.removeLast();
    }
    eventBus?.publish(
      GrabKitEvent(
        moduleId: 'realtime',
        type: type,
        message: message,
        data: {'payload': payload},
      ),
    );
    notifyListeners();
  }

  void clear() {
    _entries.clear();
    notifyListeners();
  }
}

typedef GrabKitSocketEventLog = GrabKitRealtimeStore;
