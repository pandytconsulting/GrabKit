# GrabKit Modular Design

## Status

The core runtime and current feature modules are implemented. Grab recording
and future modules remain proposed.

## Product Principle

GrabKit should let an application install and enable only the diagnostic
capabilities it needs.

There are two different kinds of modularity:

1. **Install-time modularity** controls which dependencies enter an app.
2. **Runtime modularity** controls which installed capabilities are enabled,
   visible, or recording.

True install-time modularity requires separate pub packages. Separate imports
inside one package do not prevent that package's dependencies from being
resolved and installed.

## Proposed Package Family

All packages should live in one GrabKit monorepo and share versioning,
documentation, CI, and examples.

| Package | Responsibility | Important dependencies |
| --- | --- | --- |
| `grabkit` | Core runtime, module registry, event model, shell, settings, redaction contracts | Flutter only where possible |
| `grabkit_grab` | Floating control and diagnostic session recording | `grabkit` |
| `grabkit_network` | Protocol-neutral network records, filters, and inspector UI | `grabkit` |
| `grabkit_network_dio` | Dio interceptor that feeds `grabkit_network` | `dio`, `grabkit_network` |
| `grabkit_logs` | Structured app logs and breadcrumbs | `grabkit` |
| `grabkit_realtime` | Protocol-neutral socket/realtime event inspector | `grabkit` |
| `grabkit_environment` | Runtime environment presets and overrides | `grabkit`, persistence adapter |
| `grabkit_performance` | Frames, app starts, memory, and custom spans | `grabkit` |
| `grabkit_export` | Session bundles, report generation, sharing, JSON/HAR export | `grabkit`, platform sharing packages |
| `grabkit_preferences` | SharedPreferences-backed settings and small-state persistence | `shared_preferences`, `grabkit` |
| `grabkit_all` | Optional convenience bundle for teams that want the standard suite | all stable modules |

Adapter packages can be added later without changing core contracts, for
example `grabkit_realtime_mqtt` or `grabkit_logs_logger`.

## What Belongs In Core

The `grabkit` package should remain small and stable. It owns:

- `GrabKitRuntime`: lifecycle and access point for installed modules.
- `GrabKitModule`: module contract.
- `GrabKitRegistry`: installed and enabled module state.
- `GrabKitEvent`: shared, timestamped diagnostic event.
- `GrabKitEventBus`: bounded event stream.
- `GrabKitRedactor`: sanitization contract applied before storage or export.
- `GrabKitStorage`: persistence abstraction.
- `GrabKitShell`: module-driven dashboard and settings UI.
- `GrabKitOverlay`: optional host for module-provided overlays.
- Common models for module state, capture policy, permissions, and errors.

Core must not know about Dio, MQTT, environment URLs, device information,
sharing, or session recording.

## Module Contract

The first contract should stay intentionally small:

```dart
abstract interface class GrabKitModule {
  String get id;
  String get displayName;

  Future<void> initialize(GrabKitModuleContext context);
  List<GrabKitPanel> buildPanels();
  List<GrabKitSetting> buildSettings();
  Future<void> dispose();
}
```

Modules may additionally implement capabilities:

```dart
abstract interface class GrabKitEventSource {
  Stream<GrabKitEvent> get events;
}

abstract interface class GrabKitSessionContributor {
  Future<void> onSessionStart(GrabKitSessionContext context);
  Future<GrabKitArtifact?> onSessionStop(GrabKitSessionContext context);
}
```

The core runtime discovers these capabilities from registered modules. This
keeps the grab recorder independent from network, logs, performance, and other
future modules.

## Runtime Module States

An installed module can have separate states:

- **Installed**: present in the app's dependency graph.
- **Enabled**: visible and allowed to collect diagnostic data.
- **Capture policy**:
  - `always`: maintain a bounded rolling buffer.
  - `duringGrab`: collect only while a grab session is recording.
  - `manual`: collect only when explicitly requested.
- **Available**: required platform permissions and host integrations exist.

The dashboard should clearly show these states and why a module is unavailable.

## Current Capability Breakdown

The current package should be separated as follows:

| Current code | Target module |
| --- | --- |
| `GrabKitDioInterceptor`, HTTP records, filters, HTTP tab | `grabkit_network` + `grabkit_network_dio` |
| `GrabKitAppLogBuffer`, `AppLogRecord` | `grabkit_logs` |
| `GrabKitSocketEventLog`, `SocketEventRecord` | `grabkit_realtime` |
| Environment presets, preference keys, environment tab | `grabkit_environment` + `grabkit_preferences` |
| Debug report formatter and report tab | `grabkit_export` |
| Package/device information in reports and About tab | `grabkit_export` or a future device-info module |
| `GrabKitScreen` and tab assembly | module-driven `GrabKitShell` in `grabkit` |
| Floating control and session recording | new `grabkit_grab` module |

## Required Refactoring Before Extraction

The current implementation uses global singletons and a screen that imports
every capability directly. Before publishing separate modules:

1. Replace concrete singleton references with injected stores and module
   registrations.
2. Introduce the shared event model and bounded event bus.
3. Make the shell render panels and settings supplied by registered modules.
4. Move report generation to consume session contributors instead of concrete
   HTTP, app-log, and socket stores.
5. Move persistence behind `GrabKitStorage`.
6. Keep temporary compatibility exports so existing applications can migrate
   incrementally.

## Host App Integration

Installing a package with `pub get` cannot safely add a route to an
application. Pub resolves dependencies; it does not modify the host app's
router, source code, or navigation policy. Flutter applications also use many
different routing systems.

The recommended integration should therefore not require a route:

```dart
final grabKit = GrabKitRuntime(
  modules: [
    GrabKitGrabModule(),
    GrabKitLogsModule(),
    GrabKitNetworkModule(),
  ],
);

MaterialApp.router(
  builder: (context, child) => GrabKitOverlay(
    runtime: grabKit,
    child: child!,
  ),
);
```

`GrabKitOverlay` can display the optional floating grab control and render the
GrabKit shell as its own full-screen overlay layer. This works with Navigator
1.0, Navigator 2.0, `go_router`, and other routers without locating or
modifying the host Navigator.

For teams that prefer explicit navigation, core should also expose:

```dart
GrabKitShell(runtime: grabKit)
```

Optional router adapters may provide helpers and observers, but they must never
modify host source during dependency installation.

## Dependency Rules

- Modules may depend on `grabkit`; core must never depend on a module.
- Modules must communicate through core contracts, not by importing each
  other's internals.
- A module must redact data before publishing it to the event bus.
- Capture must use bounded buffers by default.
- Expensive or privacy-sensitive capture must be opt-in.
- The shell must continue working when only one module is installed.

## Recommended Execution Order

Do not begin by moving files into many packages. First prove the contracts
inside the current package, then extract working modules:

1. Add the runtime, registry, event bus, storage contract, and module contract
   inside the current `grabkit` package.
2. Adapt the current network, logs, realtime, environment, and export features
   into internal modules while preserving existing public APIs.
3. Replace the fixed `GrabKitScreen` tabs with the module-driven shell.
4. Build `GrabKitOverlay` and verify the no-route integration in multiple
   router styles.
5. Build the optional grab recorder against the module contracts.
6. Extract each proven internal module into its own pub package.

This sequence avoids publishing unstable package boundaries before the runtime
contracts have been validated in real applications.
