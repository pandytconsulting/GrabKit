import 'package:flutter/foundation.dart';
import 'package:grabkit/grabkit.dart';

import 'network_record.dart';

class GrabKitNetworkStore extends ChangeNotifier {
  GrabKitNetworkStore({this.maxEntries = 300, this.eventBus});

  static final GrabKitNetworkStore instance = GrabKitNetworkStore();

  final int maxEntries;
  GrabKitEventBus? eventBus;
  final List<GrabKitNetworkRecord> _entries = [];

  List<GrabKitNetworkRecord> get entries => List.unmodifiable(_entries);

  void add(GrabKitNetworkRecord entry) {
    _entries.insert(0, entry);
    while (_entries.length > maxEntries) {
      _entries.removeLast();
    }
    eventBus?.publish(
      GrabKitEvent(
        moduleId: 'network',
        type: entry.isError ? 'error' : 'response',
        message: '${entry.method} ${entry.uri}',
        data: {'statusCode': entry.statusCode, 'error': entry.errorMessage},
      ),
    );
    notifyListeners();
  }

  void clear() {
    _entries.clear();
    notifyListeners();
  }
}

typedef GrabKitApiCallLog = GrabKitNetworkStore;
