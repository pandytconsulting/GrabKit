# grabkit_export

Combined GrabKit debug reports, clipboard export, and sharing.

## Install When

Use this package when QA, support, or internal testers need to copy or share a
debug report from inside the app.

The current report can include app/package information, device information,
environment name, network calls, app logs, and realtime events.

## Minimal Setup

```dart
import 'package:flutter/material.dart';
import 'package:grabkit/grabkit.dart';
import 'package:grabkit_export/grabkit_export.dart';

final runtime = GrabKitRuntime(
  modules: [
    GrabKitExportModule(environmentName: 'qa'),
  ],
);

GrabKitShell(runtime: runtime);
```

This renders a GrabKit shell with only the Export panel. The report will still
include app and device context, but network/log/realtime sections will be empty
unless those modules or stores are also wired.

## With Captured Data

```dart
import 'package:grabkit_logs/grabkit_logs.dart';
import 'package:grabkit_network/grabkit_network.dart';
import 'package:grabkit_realtime/grabkit_realtime.dart';

final networkStore = GrabKitNetworkStore();
final logStore = GrabKitLogStore();
final realtimeStore = GrabKitRealtimeStore();

final runtime = GrabKitRuntime(
  modules: [
    GrabKitNetworkModule(store: networkStore),
    GrabKitLogsModule(store: logStore),
    GrabKitRealtimeModule(store: realtimeStore),
    GrabKitExportModule(
      environmentName: 'qa',
      networkStore: networkStore,
      logStore: logStore,
      realtimeStore: realtimeStore,
    ),
  ],
);
```

## Pair With

- `grabkit_network` for recent API calls.
- `grabkit_logs` for app breadcrumbs.
- `grabkit_realtime` for socket/realtime events.
- Future `grabkit_grab` for session bundles.

## Current Behavior

- Builds a plain-text report.
- Copies reports to the clipboard.
- Shares reports through `share_plus`.
- Includes package and device data through `package_info_plus` and
  `device_info_plus`.
- Currently reads known stores directly. A future version should let modules
  contribute their own report sections and JSON artifacts.
