import 'dart:async';

import 'event.dart';

/// A bounded stream and rolling buffer of GrabKit events.
class GrabKitEventBus {
  GrabKitEventBus({this.maxEntries = 500});

  final int maxEntries;
  final List<GrabKitEvent> _entries = [];
  final StreamController<GrabKitEvent> _controller =
      StreamController<GrabKitEvent>.broadcast();
  bool _disposed = false;

  List<GrabKitEvent> get entries => List.unmodifiable(_entries);
  Stream<GrabKitEvent> get events => _controller.stream;
  bool get disposed => _disposed;

  void publish(GrabKitEvent event) {
    if (_disposed) return;
    _entries.insert(0, event);
    while (_entries.length > maxEntries) {
      _entries.removeLast();
    }
    _controller.add(event);
  }

  void clear() => _entries.clear();

  Future<void> dispose() async {
    if (_disposed) return;
    _disposed = true;
    await _controller.close();
  }
}
