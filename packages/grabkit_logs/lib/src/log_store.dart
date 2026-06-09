import 'package:flutter/foundation.dart';
import 'package:grabkit/grabkit.dart';

import 'log_record.dart';

class GrabKitLogStore extends ChangeNotifier {
  GrabKitLogStore({this.maxEntries = 300, this.eventBus});

  static final GrabKitLogStore instance = GrabKitLogStore();

  final int maxEntries;
  GrabKitEventBus? eventBus;
  final List<GrabKitLogRecord> _entries = [];

  List<GrabKitLogRecord> get entries => List.unmodifiable(_entries);

  void add(String level, String message, {Map<String, Object?>? attributes}) {
    final record = GrabKitLogRecord(
      level: level,
      message: message,
      attributes: attributes ?? const {},
    );
    _entries.insert(0, record);
    while (_entries.length > maxEntries) {
      _entries.removeLast();
    }
    eventBus?.publish(
      GrabKitEvent(
        moduleId: 'logs',
        type: level,
        message: message,
        data: record.attributes,
      ),
    );
    notifyListeners();
  }

  void clear() {
    _entries.clear();
    notifyListeners();
  }
}

typedef GrabKitAppLogBuffer = GrabKitLogStore;
