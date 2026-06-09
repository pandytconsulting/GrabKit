import 'package:flutter/material.dart';
import 'package:grabkit/grabkit.dart';

import 'network_panel.dart';
import 'network_store.dart';

class GrabKitNetworkModule extends GrabKitModule {
  GrabKitNetworkModule({GrabKitNetworkStore? store})
      : store = store ?? GrabKitNetworkStore.instance;

  final GrabKitNetworkStore store;
  GrabKitEventBus? _eventBus;

  @override
  String get id => 'network';

  @override
  String get displayName => 'Network';

  @override
  GrabKitModuleMetadata get metadata => const GrabKitModuleMetadata(
        capturesEvents: true,
        contributesToReports: true,
        dataCategories: {GrabKitDataCategory.network},
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
          id: 'network.inspector',
          title: 'Network',
          icon: Icons.http,
          builder: (_) => GrabKitNetworkPanel(store: store),
        ),
      ];
}
