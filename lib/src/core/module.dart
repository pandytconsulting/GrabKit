import 'package:flutter/widgets.dart';

import 'runtime.dart';

/// Capture behavior requested for an installed module.
enum GrabKitCapturePolicy { always, duringGrab, manual }

/// Broad privacy/data categories a module can capture or expose.
enum GrabKitDataCategory {
  appInfo,
  deviceInfo,
  environment,
  logs,
  network,
  realtime,
}

/// Capability and privacy metadata declared by a GrabKit module.
class GrabKitModuleMetadata {
  const GrabKitModuleMetadata({
    this.capturesEvents = false,
    this.contributesToReports = false,
    this.hasSettings = false,
    this.dataCategories = const {},
  });

  final bool capturesEvents;
  final bool contributesToReports;
  final bool hasSettings;
  final Set<GrabKitDataCategory> dataCategories;
}

/// A screen supplied by a GrabKit module.
class GrabKitPanel {
  const GrabKitPanel({
    required this.id,
    required this.title,
    required this.builder,
    this.icon,
  });

  final String id;
  final String title;
  final IconData? icon;
  final WidgetBuilder builder;
}

/// Contract implemented by separately installable GrabKit modules.
abstract class GrabKitModule {
  String get id;
  String get displayName;
  bool get enabledByDefault => true;
  GrabKitCapturePolicy get defaultCapturePolicy => GrabKitCapturePolicy.always;
  GrabKitModuleMetadata get metadata => const GrabKitModuleMetadata();

  Future<void> initialize(GrabKitRuntime runtime);
  List<GrabKitPanel> buildPanels();
  Future<void> dispose();
}
