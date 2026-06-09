# grabkit_network

Protocol-neutral network records, bounded storage, and inspector UI for
GrabKit. Install `grabkit_network_dio` separately when using Dio.

The inspector includes search, method and error filters, clear controls,
request and response details, and redacted cURL copying.

## Install When

Use this package when an app needs an in-app network inspector. This package
owns the network record model, bounded store, filters, cURL formatter, and UI
panel.

It does not attach to any HTTP client by itself. Add an adapter such as
`grabkit_network_dio` to capture traffic automatically.

## Minimal Setup

```dart
import 'package:flutter/material.dart';
import 'package:grabkit/grabkit.dart';
import 'package:grabkit_network/grabkit_network.dart';

class NetworkGrabKitScreen extends StatefulWidget {
  const NetworkGrabKitScreen({super.key});

  @override
  State<NetworkGrabKitScreen> createState() => _NetworkGrabKitScreenState();
}

class _NetworkGrabKitScreenState extends State<NetworkGrabKitScreen> {
  late final GrabKitRuntime runtime;

  @override
  void initState() {
    super.initState();
    runtime = GrabKitRuntime(
      modules: [
        GrabKitNetworkModule(),
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

This renders a GrabKit shell with only the Network panel.

## Manual Records

```dart
GrabKitNetworkStore.instance.add(
  GrabKitNetworkRecord(
    at: DateTime.now(),
    method: 'GET',
    uri: 'https://api.example.com/orders',
    statusCode: 200,
    duration: const Duration(milliseconds: 124),
    responseSummary: '{"items": []}',
  ),
);
```

## Dio Capture

Install `grabkit_network_dio` and attach its interceptor:

```dart
import 'package:dio/dio.dart';
import 'package:grabkit_network_dio/grabkit_network_dio.dart';

final dio = Dio();

if (isInternalBuild) {
  dio.interceptors.add(GrabKitDioInterceptor());
}
```

For custom stores, pass the same store to the module and interceptor:

```dart
final networkStore = GrabKitNetworkStore();

final runtime = GrabKitRuntime(
  modules: [
    GrabKitNetworkModule(store: networkStore),
  ],
);

dio.interceptors.add(
  GrabKitDioInterceptor(
    store: networkStore,
    eventBus: runtime.eventBus,
  ),
);
```

## Pair With

- `grabkit_network_dio` for Dio traffic capture.
- `grabkit_export` to include recent calls in copied or shared reports.
- `grabkit_environment` to switch endpoints and inspect the result.

## Current Behavior

- Stores a bounded rolling list of network records.
- Shows search, method filter, errors-only filter, clear, details, copy URL,
  copy response, and copy redacted cURL.
- Publishes network events to the shared GrabKit event bus when configured.
- Does not yet provide status-code filters, HAR export, pretty JSON rendering,
  or non-Dio adapters.
