# grabkit_all

Convenience bundle containing all current GrabKit modules and the familiar
`GrabKitScreen` integration.

Use individual GrabKit module packages when install-time modularity matters.

## Install When

Use this package when you want the standard all-in-one GrabKit screen with the
current module family:

- Network
- Logs
- Realtime
- Environment
- Export
- About

If you need the smallest possible dependency graph, install individual module
packages instead.

## Minimal Setup

```dart
import 'package:flutter/material.dart';
import 'package:grabkit_all/grabkit_all.dart';

class InternalDiagnosticsRoute extends StatelessWidget {
  const InternalDiagnosticsRoute({super.key});

  @override
  Widget build(BuildContext context) {
    return GrabKitScreen(
      compileTimeEnv: 'qa',
      compileTimeBaseUrl: 'https://qa-api.example.com',
      compileTimeMqttUrl: 'wss://qa-realtime.example.com',
      environmentPresets: const [
        GrabKitEnvironmentPreset(
          label: 'Local',
          baseUrl: 'http://localhost:8080',
          realtimeUrl: 'ws://localhost:8081',
        ),
      ],
    );
  }
}
```

Expose this route only in debug, QA, or internal builds.

## Dio Capture

`grabkit_all` includes the Network panel, but Dio capture still needs an
interceptor:

```dart
import 'package:dio/dio.dart';
import 'package:grabkit_network_dio/grabkit_network_dio.dart';

final dio = Dio();

if (isInternalBuild) {
  dio.interceptors.add(GrabKitDioInterceptor());
}
```

## Prefer Individual Packages When

- The app only needs one module, such as logs-only or network-only.
- You want to avoid `share_plus`, device info, or other dependencies.
- You are building a custom shell or product-specific diagnostics screen.
- You need stricter control over which data categories can be captured.

## Current Behavior

- Creates a `GrabKitRuntime` with the standard modules.
- Uses SharedPreferences-backed storage for environment overrides.
- Provides the compatibility route name `/dev-tools`.
- Does not automatically register routes or install Dio interceptors.
