# Example App Roadmap

The example app should prove GrabKit is useful without depending on any
private application code. It must show the public package experience clearly
enough for pub.dev visitors to understand what to install and how to wire it.

## Goals

- Demonstrate modular installation.
- Show the standard four-panel setup: Network, Environment, Export, About.
- Provide fake but realistic API, log, and realtime events.
- Make screenshots and GIFs easy to capture for README and pub.dev.
- Exercise the future grab-session workflow before real apps adopt it.

## 0.1 - Public Demo Baseline

- [x] Keep the example independent from private application code.
- [x] Use `GrabKitRuntime` and `GrabKitShell` directly.
- [ ] Add a simple home screen with actions that generate network, log, and
  realtime events.
- [ ] Add a fake Dio adapter so the network inspector always has demo traffic.
- [ ] Add a visible route/button to open GrabKit.
- [ ] Add environment presets for Local, QA, and Production-like demo values.
- [ ] Add README instructions for running the example.

## 0.2 - Visual Documentation

- [ ] Add stable demo data for screenshots.
- [ ] Capture screenshots for Network details, cURL copy, Environment, Export,
  and About.
- [ ] Add screenshots to `README.md` and pub.dev `screenshots`.
- [ ] Add a short GIF or screen recording for the network inspector workflow.

## 0.3 - Modular Recipes

- [ ] Add separate screens or examples for:
  - core + network only
  - network + environment + export
  - all-in-one `grabkit_all`
  - custom app log/realtime recording
- [ ] Add code comments that point to the relevant package imports.
- [ ] Add example storage implementations for memory and SharedPreferences.

## 0.4 - Grab Session Demo

- [ ] Add the future `grabkit_grab` module.
- [ ] Add floating control enable/disable settings.
- [ ] Add start/stop/cancel session flows.
- [ ] Add manual notes and markers.
- [ ] Export a demo `.grab` bundle.

## 0.5 - Test Harness

- [ ] Add widget tests for the example's GrabKit route.
- [ ] Add a smoke test that generates demo traffic and verifies it appears in
  the Network panel.
- [ ] Add golden or screenshot checks for public screenshots if stable enough.
- [ ] Include the example in CI after package publish configuration settles.
