# grabkit_realtime

Protocol-neutral realtime and socket event inspection for GrabKit.

## Install When

Use this package when an app needs to inspect realtime breadcrumbs such as
WebSocket, MQTT, Socket.IO, GraphQL subscription, or custom message bus events.

This package is protocol-neutral. It stores and displays records, but it does
not attach to any socket client automatically.

## Minimal Setup

```dart
import 'package:flutter/material.dart';
import 'package:grabkit/grabkit.dart';
import 'package:grabkit_realtime/grabkit_realtime.dart';

class RealtimeGrabKitScreen extends StatefulWidget {
  const RealtimeGrabKitScreen({super.key});

  @override
  State<RealtimeGrabKitScreen> createState() => _RealtimeGrabKitScreenState();
}

class _RealtimeGrabKitScreenState extends State<RealtimeGrabKitScreen> {
  late final GrabKitRuntime runtime;

  @override
  void initState() {
    super.initState();
    runtime = GrabKitRuntime(
      modules: [
        GrabKitRealtimeModule(),
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

This renders a GrabKit shell with only the Realtime panel.

## Recording Events

```dart
GrabKitSocketEventLog.instance.add(
  'received',
  'order.updated',
  payload: {'orderId': 'example-order'},
);
```

For custom wiring, create and pass a store:

```dart
final realtimeStore = GrabKitRealtimeStore(maxEntries: 300);

final runtime = GrabKitRuntime(
  modules: [
    GrabKitRealtimeModule(store: realtimeStore),
  ],
);
```

## Pair With

- `grabkit_export` to include realtime events in debug reports.
- `grabkit_environment` when realtime endpoint overrides are useful.
- Future adapter packages such as MQTT or WebSocket adapters.

## Current Behavior

- Stores a bounded rolling list of realtime records.
- Publishes events to the shared GrabKit event bus.
- Shows event type, message, and optional payload.
- Does not yet provide built-in MQTT, WebSocket, or Socket.IO adapters.
