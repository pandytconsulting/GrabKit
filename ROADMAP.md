# GrabKit Roadmap

GrabKit is becoming a modular diagnostic toolkit built around optional
**grab sessions**: focused recordings made while reproducing an app problem.

This roadmap is intentionally split into small parts so each release can be
shipped, tested in real apps, and documented before the next layer is added.

See:

- [Modular design](doc/architecture/modular-design.md)
- [Grab sessions](doc/product/grab-sessions.md)
- [Example app roadmap](doc/example-app-roadmap.md)

## Integration Execution Plan

Use this sequence to integrate the current module improvements without
destabilizing the package boundaries.

1. **Public package clarity**
   - Keep each package README focused on standalone setup, companion packages,
     and current limitations.
   - Make the example app generate stable demo network, log, and realtime data.
   - Capture screenshots and GIFs after the example flows are stable.
2. **Core modularity**
   - Persist module enable/disable state through `GrabKitStorage`.
   - Add typed module metadata for capture, export, settings, and privacy data
     categories.
   - Add shell settings for installed modules and capture policy visibility.
3. **Visible module polish**
   - Upgrade Network filters, sorting, slow-call highlighting, and JSON display.
   - Add search/filter/clear/copy affordances to Logs and Realtime.
   - Add URL validation, reset defaults, and clearer apply/restart states to
     Environment.
4. **Export architecture**
   - Move reports toward module-contributed sections and artifacts.
   - Add JSON export, safe filenames, configurable section limits, and redaction
     summaries.
5. **Overlay and grab sessions**
   - Add `GrabKitOverlay` as the no-route host integration.
   - Build `grabkit_grab` on top of the event bus and module capability
     metadata.
   - Export a versioned JSON session before stabilizing the `.grab` archive.

## Public Repo Readiness

Complete these before opening the public GitHub repo and publishing the first
package set.

- [x] Rename and remove application-specific internal naming from the package
  API.
- [x] Extract the monolith into modular packages.
- [x] Restore parity for the original inspector surface: Network,
  Environment, Export, and About.
- [x] Restore network search, filters, clear, details, response copy, and cURL
  copy.
- [x] Make diagnostic capture fail open so it cannot break app traffic.
- [x] Validate modular integration in multiple real internal apps.
- [ ] Decide public GitHub organization/repository URL and update every
  package `repository`, `homepage`, and `issue_tracker`.
- [ ] Finalize license, contribution guide, code of conduct, security policy,
  and issue templates.
- [ ] Add screenshots/GIFs from the example app.
- [ ] Add public API documentation comments for exported classes and typedefs.
- [ ] Add `dart pub publish --dry-run` checks for every package.
- [ ] Replace monorepo path dependencies with hosted constraints during the
  release sequence.
- [ ] Tag the first public release and publish in dependency order:
  `grabkit`, modules, then `grabkit_all`.

## 0.1 - Public Foundation

- [x] Remove application-specific naming and endpoints.
- [x] Provide a generic public API.
- [x] Redact common sensitive values by default.
- [x] Add documentation, an example, tests, and CI.
- [x] Validate integration in multiple real internal applications.
- [ ] Add public screenshots and a stronger example walkthrough.
- [ ] Finish pub.dev metadata and package dry runs.

## 0.2 - Modular Core

- [x] Introduce `GrabKitRuntime`, module registry, and module lifecycle.
- [x] Introduce a shared redacted event model and bounded event bus.
- [x] Replace the fixed four-tab screen with a module-driven shell.
- [x] Replace global singleton UI coupling with injected module stores.
- [x] Add storage and redaction contracts.
- [x] Preserve a compatibility layer for current adopters.
- [x] Add module enable/disable persistence.
- [ ] Add module ordering and grouping controls.
- [x] Add typed module metadata for capture support, export support, and
  optional settings.

## 0.3 - Extract Current Modules

- [x] Extract network records and inspector UI into `grabkit_network`.
- [x] Move Dio integration into `grabkit_network_dio`.
- [x] Extract app logs into `grabkit_logs`.
- [x] Extract socket events into `grabkit_realtime`.
- [x] Extract environment switching into `grabkit_environment`.
- [x] Extract reports and sharing into `grabkit_export`.
- [x] Add `grabkit_all` as an optional convenience bundle.
- [x] Add optional `GrabKitAboutModule` in core.
- [x] Add a first-class package README for every module with install and usage
  snippets.
- [ ] Add compatibility migration guide from the legacy internal dev-tools
  package.

## 0.4 - Network Inspector Upgrade

- [x] Search and filter network calls.
- [x] Copy redacted cURL.
- [x] Copy URL and response body.
- [x] Clear captured calls.
- [ ] Add status-code range filters.
- [ ] Add duration sorting and slow-call highlighting.
- [ ] Add request/response pretty JSON formatting.
- [ ] Add HAR export.
- [ ] Add pluggable network adapters beyond Dio.
- [ ] Add streaming/file download metadata without storing large bodies.

## 0.5 - Grab Recorder MVP

- [ ] Add optional `grabkit_grab` module.
- [ ] Add overlay-hosted floating control with persisted settings.
- [ ] Add a settings route/panel where users can enable the floating control.
- [ ] Investigate route auto-registration options and document the recommended
  integration for `go_router`, Navigator 1.0, and custom routers.
- [ ] Start, stop, cancel, and review diagnostic sessions.
- [ ] Record enabled module events into a shared timeline.
- [ ] Add tester notes and manual markers.
- [ ] Export a versioned JSON session bundle.
- [ ] Add session replay/review screen inside GrabKit.

## 0.6 - Performance And App Behavior

- [ ] Add `grabkit_performance` with frame timing, jank markers, and custom
  spans.
- [ ] Add app lifecycle breadcrumbs.
- [ ] Add route/navigation observer helpers.
- [ ] Add memory pressure and low-storage breadcrumbs where platform APIs
  allow it.
- [ ] Add custom counters and gauges for app-specific telemetry.

## 0.7 - Realtime And Messaging

- [ ] Add first-class MQTT adapter.
- [ ] Add WebSocket adapter.
- [ ] Add topic/channel filters.
- [ ] Add inbound/outbound payload redaction hooks.
- [ ] Add connection state timeline and reconnect diagnostics.

## 0.8 - Export, Privacy, And Team Workflows

- [ ] Define and document the `.grab` bundle format.
- [ ] Add JSON export/import for sessions.
- [ ] Add share targets with safe filename conventions.
- [ ] Add configurable retention limits.
- [ ] Add privacy checklist and app-store/internal-release guidance.
- [ ] Add support-bundle templates for QA/support handoff.

## 0.9 - Theming, Extensibility, And Polish

- [ ] Add theme configuration for host apps.
- [ ] Add compact/tablet layouts.
- [ ] Add keyboard shortcuts for desktop/web debug builds.
- [ ] Add module authoring guide.
- [ ] Add extension points for custom panels, report sections, and session
  artifacts.
- [ ] Add localization hooks for host apps.

## 1.0 - Stable Modular Toolkit

- [ ] Stable module, event, session, storage, and redaction contracts.
- [ ] Open and documented `.grab` bundle format.
- [ ] Broad unit, widget, integration, and platform test coverage.
- [ ] Validated privacy, performance, and memory behavior for long QA sessions.
- [ ] Real app validation across multiple integration styles and at least one
  standalone sample app.
- [ ] Public docs with screenshots, migration guide, and module authoring guide.
