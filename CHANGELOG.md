## Unreleased

- Restored the full modular network inspector with search, filters, clear,
  request and response details, and redacted cURL copying.
- Added an optional core About panel for custom module compositions.
- Made diagnostic recording fail open and fixed module event-bus disposal.

## 0.1.0

- Initial public preview of GrabKit.
- Extracted current capabilities into separately installable module packages.
- Added the core module registry, event bus, storage contract, and module-driven shell.
- Added an in-app HTTP inspector backed by a Dio interceptor.
- Added environment endpoint overrides and user-provided presets.
- Added app log and socket event buffers.
- Added shareable debug reports.
- Added default redaction for common sensitive fields.
