# grabkit_environment

Runtime endpoint presets and overrides for GrabKit. Persistence is supplied
through the core `GrabKitStorage` contract.

## Install When

Use this package when QA, support, or internal builds need to switch API and
realtime endpoints from inside the app.

The module only stores override values. The host app remains responsible for
reading those values before constructing API, MQTT, WebSocket, or other
clients.

## Minimal Setup

```dart
import 'package:flutter/material.dart';
import 'package:grabkit/grabkit.dart';
import 'package:grabkit_environment/grabkit_environment.dart';

final runtime = GrabKitRuntime(
  storage: MyGrabKitStorage(),
  modules: [
    GrabKitEnvironmentModule(
      environmentName: 'qa',
      defaultBaseUrl: 'https://api.example.com',
      defaultRealtimeUrl: 'wss://realtime.example.com',
      presets: const [
        GrabKitEnvironmentPreset(
          label: 'Local',
          baseUrl: 'http://localhost:8080',
          realtimeUrl: 'ws://localhost:8081',
        ),
        GrabKitEnvironmentPreset(
          label: 'QA',
          baseUrl: 'https://qa-api.example.com',
          realtimeUrl: 'wss://qa-realtime.example.com',
        ),
      ],
    ),
  ],
);

GrabKitShell(runtime: runtime);
```

## Reading Overrides

Read these keys before configuring your clients:

```dart
final baseUrl = await storage.read(
      GrabKitEnvironmentKeys.baseUrlOverride,
    ) ??
    compileTimeBaseUrl;

final realtimeUrl = await storage.read(
      GrabKitEnvironmentKeys.realtimeUrlOverride,
    ) ??
    compileTimeRealtimeUrl;
```

The keys intentionally preserve compatibility with earlier internal dev-tools
builds:

```dart
DevToolsPrefsKeys.baseUrlOverride;
DevToolsPrefsKeys.realtimeUrlOverride;
```

## Pair With

- `grabkit_network` and `grabkit_network_dio` to inspect traffic after an
  endpoint switch.
- `grabkit_export` to include the selected environment in debug reports.
- `grabkit_all` for the standard all-in-one screen.

## Current Behavior

- Shows API and realtime endpoint text fields.
- Supports preset chips.
- Persists overrides through `GrabKitStorage`.
- Calls `onOverridesPersisted` after saving so the host app can restart,
  rebuild clients, or show its own message.
- Does not yet validate URLs or persist the selected preset label.
