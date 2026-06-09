# GrabKit Package Map

The current features have been extracted into separately installable packages.

| Package | Install when you need |
| --- | --- |
| `grabkit` | Runtime, module contracts, event bus, storage contract, shell, and optional About panel |
| `grabkit_network` | Network records and inspector |
| `grabkit_network_dio` | Dio traffic capture |
| `grabkit_logs` | Structured app logs |
| `grabkit_realtime` | Socket and realtime event inspection |
| `grabkit_environment` | Runtime endpoint switching |
| `grabkit_export` | Combined reports and sharing |
| `grabkit_all` | All current modules and the compatibility `GrabKitScreen` |

## Custom Installation

```dart
final runtime = GrabKitRuntime(
  modules: [
    GrabKitNetworkModule(),
    GrabKitLogsModule(),
  ],
);

GrabKitShell(runtime: runtime);
```

Attach Dio separately:

```dart
dio.interceptors.add(
  GrabKitDioInterceptor(
    store: runtime.module<GrabKitNetworkModule>().store,
    eventBus: runtime.eventBus,
  ),
);
```

## Standard Bundle

Applications that want the existing all-in-one screen can install
`grabkit_all` and use `GrabKitScreen`.

During monorepo development, modules use local path dependencies so
applications can consume the complete unpublished package family. Before
publishing, release core first, replace module path dependencies with the
released core constraint, publish individual modules, then publish
`grabkit_all` with released module constraints. Module pubspecs intentionally
use `publish_to: none` until that release sequence begins.
