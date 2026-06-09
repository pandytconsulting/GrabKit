import 'package:flutter/material.dart';
import 'package:grabkit/grabkit.dart';

import 'realtime_store.dart';

class GrabKitRealtimeModule extends GrabKitModule {
  GrabKitRealtimeModule({GrabKitRealtimeStore? store})
      : store = store ?? GrabKitRealtimeStore.instance;

  final GrabKitRealtimeStore store;
  GrabKitEventBus? _eventBus;

  @override
  String get id => 'realtime';

  @override
  String get displayName => 'Realtime';

  @override
  GrabKitModuleMetadata get metadata => const GrabKitModuleMetadata(
        capturesEvents: true,
        contributesToReports: true,
        dataCategories: {GrabKitDataCategory.realtime},
      );

  @override
  Future<void> initialize(GrabKitRuntime runtime) async {
    _eventBus = runtime.eventBus;
    store.eventBus = _eventBus;
  }

  @override
  Future<void> dispose() async {
    if (identical(store.eventBus, _eventBus)) {
      store.eventBus = null;
    }
    _eventBus = null;
  }

  @override
  List<GrabKitPanel> buildPanels() => [
        GrabKitPanel(
          id: 'realtime.events',
          title: 'Realtime',
          icon: Icons.swap_vert,
          builder: (_) => _RealtimePanel(store: store),
        ),
      ];
}

class _RealtimePanel extends StatelessWidget {
  const _RealtimePanel({required this.store});

  final GrabKitRealtimeStore store;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: store,
      builder: (context, _) => store.entries.isEmpty
          ? const Center(child: Text('No realtime events captured.'))
          : ListView.builder(
              itemCount: store.entries.length,
              itemBuilder: (context, index) {
                final event = store.entries[index];
                return ListTile(
                  title: Text('${event.type} · ${event.message}'),
                  subtitle: event.payload == null
                      ? null
                      : SelectableText('${event.payload}'),
                );
              },
            ),
    );
  }
}
