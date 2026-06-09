import 'package:flutter/material.dart';
import 'package:grabkit/grabkit.dart';

import 'log_store.dart';

class GrabKitLogsModule extends GrabKitModule {
  GrabKitLogsModule({GrabKitLogStore? store})
      : store = store ?? GrabKitLogStore.instance;

  final GrabKitLogStore store;
  GrabKitEventBus? _eventBus;

  @override
  String get id => 'logs';

  @override
  String get displayName => 'Logs';

  @override
  GrabKitModuleMetadata get metadata => const GrabKitModuleMetadata(
        capturesEvents: true,
        contributesToReports: true,
        dataCategories: {GrabKitDataCategory.logs},
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
          id: 'logs.list',
          title: 'Logs',
          icon: Icons.notes,
          builder: (_) => _LogsPanel(store: store),
        ),
      ];
}

class _LogsPanel extends StatelessWidget {
  const _LogsPanel({required this.store});

  final GrabKitLogStore store;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: store,
      builder: (context, _) => store.entries.isEmpty
          ? const Center(child: Text('No app logs captured.'))
          : ListView.builder(
              itemCount: store.entries.length,
              itemBuilder: (context, index) {
                final entry = store.entries[index];
                return ListTile(
                  title:
                      Text('${entry.level.toUpperCase()} · ${entry.message}'),
                  subtitle: entry.attributes.isEmpty
                      ? null
                      : SelectableText('${entry.attributes}'),
                );
              },
            ),
    );
  }
}
