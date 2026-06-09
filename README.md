# GrabKit

GrabKit is a modular in-app Flutter diagnostic toolkit for debug, QA, and
internal builds. It helps teams inspect app behavior from inside the app:
network traffic, runtime environment overrides, app logs, realtime events, and
shareable debug reports.

The long-term product direction is built around **grab sessions**: a tester can
start a focused recording from a floating control, reproduce a problem, add
notes, and export a compact bundle that developers can inspect later.

> GrabKit is an early public preview. Keep it out of production builds unless
> you have reviewed your privacy, security, and support workflows.

## Why GrabKit

- Debug app issues without a desktop proxy, simulator console, or remote logs.
- Give QA and support teams a simple in-app way to capture useful evidence.
- Install only the modules your app needs.
- Keep capture tools behind your own debug, QA, or internal-build gates.
- Redact common secrets by default, with hooks for stricter app-specific
  redaction.

## Current Features

- Inspect recent Dio requests, responses, errors, timings, headers, query
  params, and redacted bodies.
- Search network calls, filter by method, filter errors, clear captures, and
  copy URL, response, or redacted cURL.
- Switch runtime API and realtime endpoints with custom presets.
- Collect lightweight app logs and realtime/socket breadcrumbs.
- Copy or share a debug report with app, device, environment, network, log, and
  realtime context.
- Include a lightweight About and safety guidance panel in custom shells.
- Use a fail-open Dio interceptor so diagnostics cannot interrupt app traffic.

## Package Map

| Package | Install when you need |
| --- | --- |
| `grabkit` | Runtime, module contracts, event bus, storage contract, shell, redaction helpers, and About panel |
| `grabkit_network` | Network records, bounded store, inspector UI, filters, and cURL formatting |
| `grabkit_network_dio` | Dio traffic capture adapter |
| `grabkit_environment` | Runtime API/realtime endpoint override UI and persisted keys |
| `grabkit_export` | Report building, clipboard copy, and share integration |
| `grabkit_logs` | Structured app log records and store |
| `grabkit_realtime` | Realtime/socket event records and store |
| `grabkit_all` | Convenience bundle for the standard all-module screen |

See [Package Map](doc/architecture/package-map.md) for release-order notes and
custom composition examples.

## Installation

Install the core plus only the modules your app needs:

```yaml
dependencies:
  grabkit: ^0.1.0
  grabkit_network: ^0.1.0
  grabkit_network_dio: ^0.1.0
  grabkit_environment: ^0.1.0
  grabkit_export: ^0.1.0
```

For the standard all-in-one experience:

```yaml
dependencies:
  grabkit_all: ^0.1.0
```

## Quick Start

Attach the Dio adapter only in internal builds:

```dart
import 'package:dio/dio.dart';
import 'package:grabkit_network_dio/grabkit_network_dio.dart';

final dio = Dio();

if (isInternalBuild) {
  dio.interceptors.add(GrabKitDioInterceptor());
}
```

Create a screen with the modules your app wants to expose:

```dart
import 'package:flutter/material.dart';
import 'package:grabkit/grabkit.dart';
import 'package:grabkit_environment/grabkit_environment.dart';
import 'package:grabkit_export/grabkit_export.dart';
import 'package:grabkit_network/grabkit_network.dart';

class AppGrabKitScreen extends StatefulWidget {
  const AppGrabKitScreen({super.key});

  @override
  State<AppGrabKitScreen> createState() => _AppGrabKitScreenState();
}

class _AppGrabKitScreenState extends State<AppGrabKitScreen> {
  late final GrabKitRuntime runtime;

  @override
  void initState() {
    super.initState();
    runtime = GrabKitRuntime(
      storage: MyGrabKitStorage(),
      modules: [
        GrabKitNetworkModule(),
        GrabKitEnvironmentModule(
          environmentName: 'qa',
          defaultBaseUrl: 'https://api.example.com',
          defaultRealtimeUrl: 'wss://realtime.example.com',
        ),
        GrabKitExportModule(environmentName: 'qa'),
        GrabKitAboutModule(),
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

Expose that screen from a route available only in debug, QA, or internal
builds.

## Recording Logs And Realtime Events

Install `grabkit_logs` and `grabkit_realtime` when you want breadcrumbs to be
included in reports or shown in custom module compositions:

```dart
GrabKitAppLogBuffer.instance.add(
  'info',
  'Checkout started',
  attributes: {'cartItems': 3},
);

GrabKitSocketEventLog.instance.add(
  'received',
  'order.updated',
  payload: {'orderId': 'example-order'},
);
```

## Environment Overrides

`grabkit_environment` persists overrides with these keys:

```dart
DevToolsPrefsKeys.baseUrlOverride;
DevToolsPrefsKeys.realtimeUrlOverride;
```

Read those values before configuring API, MQTT, WebSocket, or other clients.
The override keys intentionally preserve compatibility with earlier
internal dev-tools builds.

## Sensitive Data

`GrabKitDioInterceptor` applies `defaultGrabKitRedactor` before storing request
and response data. You can supply a stricter redactor for your application's
schema:

```dart
GrabKitDioInterceptor(
  redactor: (value) {
    // Return a sanitized copy of value.
    return defaultGrabKitRedactor(value);
  },
)
```

GrabKit cannot identify every secret automatically. Do not expose its route in
production, and verify exported reports before sharing them.

## Current Status

GrabKit has been extracted into modular packages and validated against multiple
real internal app integrations. The next work is to prepare the repo and
package family for public release, then build the first grab-session recorder
module.

Read next:

- [Roadmap](ROADMAP.md)
- [Example App Roadmap](doc/example-app-roadmap.md)
- [Modular Design](doc/architecture/modular-design.md)
- [Grab Sessions](doc/product/grab-sessions.md)
- [Package Map](doc/architecture/package-map.md)

Contributions are welcome once the public repo is open. Please read
[CONTRIBUTING.md](CONTRIBUTING.md) before opening a pull request.
