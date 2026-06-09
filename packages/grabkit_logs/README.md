# grabkit_logs

Structured application logs and a log inspector panel for GrabKit.

## Install When

Use this package when an app needs an in-app breadcrumb or log viewer without
requiring a desktop console, remote logging backend, or network inspector.

`grabkit_logs` depends on the core `grabkit` package, but it does not install
network, environment, export, or realtime modules.

## Minimal Setup

```dart
import 'package:flutter/material.dart';
import 'package:grabkit/grabkit.dart';
import 'package:grabkit_logs/grabkit_logs.dart';

class LogsOnlyGrabKitScreen extends StatefulWidget {
  const LogsOnlyGrabKitScreen({super.key});

  @override
  State<LogsOnlyGrabKitScreen> createState() =>
      _LogsOnlyGrabKitScreenState();
}

class _LogsOnlyGrabKitScreenState extends State<LogsOnlyGrabKitScreen> {
  late final GrabKitRuntime runtime;

  @override
  void initState() {
    super.initState();
    runtime = GrabKitRuntime(
      modules: [
        GrabKitLogsModule(),
      ],
    );
  }

  @override
  void dispose() {
    runtime.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => GrabKitShell(runtime: runtime);
}
```

This renders a GrabKit shell with only the Logs panel.

## Recording Logs

```dart
GrabKitAppLogBuffer.instance.add(
  'info',
  'Checkout started',
  attributes: {'cartItems': 3},
);
```

You can also pass your own store:

```dart
final logStore = GrabKitLogStore(maxEntries: 500);

final runtime = GrabKitRuntime(
  modules: [
    GrabKitLogsModule(store: logStore),
  ],
);

logStore.add(
  'warning',
  'Payment retry scheduled',
  attributes: {'attempt': 2},
);
```

## Pair With

- `grabkit_export` to include logs in copied or shared debug reports.
- `grabkit_realtime` when app breadcrumbs should sit beside socket events.
- `grabkit_all` when you want the standard all-module screen.

## Current Behavior

- Stores a bounded rolling list of structured log records.
- Publishes redacted log events to the shared GrabKit event bus.
- Shows a Logs panel when registered with `GrabKitRuntime`.
- Does not automatically capture `dart:developer`, `package:logging`, or other
  logger output yet. Wire those manually by calling the store API.
