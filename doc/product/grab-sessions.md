# Grab Sessions

## Vision

A **grab** is a focused diagnostic recording made while a tester reproduces a
problem inside an application.

The experience should feel similar to a screen recorder:

1. The tester taps a floating GrabKit control.
2. GrabKit begins a session using the installed and enabled modules.
3. The tester reproduces the problem anywhere in the app.
4. The tester stops the session.
5. GrabKit presents a timeline and shareable diagnostic bundle.

The grab recorder is an optional module. Applications that only need a network
inspector or environment switcher do not install it.

## Initial Recording Scope

Version one should record diagnostic events, not video:

- Network request and response events.
- Structured app logs and breadcrumbs.
- Navigation events when the host provides an observer.
- Realtime/socket events.
- Performance markers and frame-health summaries.
- User-added notes and markers.
- Optional screenshots captured explicitly by the tester.
- App, build, device, and environment metadata at session boundaries.

Continuous video or automatic screenshot recording has significant platform,
privacy, storage, and performance costs. It should be evaluated only after the
diagnostic event recorder is stable.

## Floating Control

The floating control belongs to `grabkit_grab` and is hosted by
`GrabKitOverlay`.

Expected interactions:

- Tap while idle: start a grab.
- Tap while recording: open compact recording controls.
- Stop action: finalize the grab.
- Long press: open GrabKit settings or the full shell.
- Drag: reposition the control.
- Settings: enable or disable the control, choose its screen edge and opacity.

The control must:

- Be disabled by default in production builds.
- Avoid system gesture and safe-area regions.
- Never block critical application controls.
- Clearly indicate recording state and elapsed time.
- Be fully removable by not installing or enabling `grabkit_grab`.

## Session State Model

```text
idle -> starting -> recording -> finalizing -> ready
                    |    |
                    |    -> paused
                    -> failed
```

Only one grab may record at a time initially.

Each session contains:

- Stable session ID.
- Start and stop timestamps.
- App/build/environment metadata.
- Enabled module IDs and versions.
- Ordered redacted event timeline.
- Module-produced artifacts.
- Tester notes and markers.
- Warnings for dropped events, unavailable modules, or incomplete artifacts.

## Session Bundle

The export format should be an open, versioned archive:

```text
example.grab
  manifest.json
  timeline.jsonl
  artifacts/
    network.har
    performance.json
    screenshots/
```

The manifest declares schema version, modules, artifacts, redaction status, and
capture warnings. JSONL keeps large timelines streamable.

The first release may export a directory or ZIP while the `.grab` format is
stabilized.

## Capture Flow

1. `GrabKitGrabModule` requests a new session from the runtime.
2. Runtime snapshots enabled modules and capture policies.
3. Session contributors receive `onSessionStart`.
4. Events published by enabled sources enter the session timeline.
5. The tester can add markers or notes.
6. On stop, contributors finalize their artifacts.
7. The export module validates redaction and builds the bundle.
8. The shell opens the session review screen.

## Privacy And Safety

- Redaction occurs before events enter session storage.
- Modules declare the data categories they capture.
- The recording screen lists active modules before starting.
- Sessions are stored in app-private storage.
- Users can delete individual sessions or all GrabKit data.
- Sharing always requires an explicit user action.
- Production enablement requires explicit host configuration.
- Continuous screen/video recording is never silently enabled.

## Proposed API Direction

```dart
final runtime = GrabKitRuntime(
  configuration: GrabKitConfiguration(
    enabled: !kReleaseMode,
    redactor: appRedactor,
  ),
  modules: [
    GrabKitGrabModule(),
    GrabKitLogsModule(),
    GrabKitNetworkModule(),
    GrabKitPerformanceModule(),
    GrabKitExportModule(),
  ],
);
```

Adapters connect external systems:

```dart
dio.interceptors.add(
  GrabKitDioInterceptor(runtime.module<GrabKitNetworkModule>()),
);
```

Host applications may add navigation capture:

```dart
navigatorObservers: [
  GrabKitNavigationObserver(runtime),
],
```

These integrations are explicit because GrabKit must not silently alter app
behavior.

## First Feature Set

### Grab Recorder MVP

- Optional floating control.
- Start, stop, cancel, and review a session.
- Timeline assembled from registered event sources.
- Tester notes and manual markers.
- In-memory session with bounded event count.
- JSON export.

### Network Module MVP

- Move current HTTP inspector into protocol-neutral network records.
- Keep Dio support in a separate adapter.
- Associate network events with the active grab.
- Improve structured redaction and cURL generation.

### Logs Module MVP

- Structured log levels, messages, attributes, and errors.
- Rolling buffer and during-grab capture policies.
- Simple host API and optional `dart:developer` adapter later.

### Performance Module MVP

- Session duration.
- Flutter frame timing summary.
- Slow and janky frame markers.
- Custom span API.

### Shell And Settings MVP

- Module registry and module list.
- Enable/disable installed modules.
- Configure capture policy per module.
- Enable/disable and position floating control.
- Browse, review, export, and delete grab sessions.

