# grabkit_network_dio

Dio interceptor adapter for `grabkit_network`. Captures redacted request,
response, timing, and error information.

## Install When

Use this package when the host app uses Dio and wants captured requests to
appear in `grabkit_network`.

This package is only the adapter. It depends on `grabkit_network`, which
depends on core `grabkit`.

## Minimal Setup

```dart
import 'package:dio/dio.dart';
import 'package:grabkit_network_dio/grabkit_network_dio.dart';

final dio = Dio();

if (isInternalBuild) {
  dio.interceptors.add(GrabKitDioInterceptor());
}
```

Then expose a GrabKit screen with `GrabKitNetworkModule`:

```dart
import 'package:grabkit/grabkit.dart';
import 'package:grabkit_network/grabkit_network.dart';

final runtime = GrabKitRuntime(
  modules: [
    GrabKitNetworkModule(),
  ],
);
```

## Custom Store And Event Bus

When you create your own network store, pass it to both the module and the
interceptor:

```dart
final networkStore = GrabKitNetworkStore(maxEntries: 500);

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

## Redaction

The interceptor applies `defaultGrabKitRedactor` before storing request and
response data. Supply a stricter app-specific redactor when needed:

```dart
dio.interceptors.add(
  GrabKitDioInterceptor(
    redactor: (value) {
      final redacted = defaultGrabKitRedactor(value);
      // Apply app-specific sanitization here.
      return redacted;
    },
  ),
);
```

## Current Behavior

- Records request method, URL, headers, query parameters, body summary,
  response summary, status code, duration, and Dio errors.
- Truncates long summaries using `maxBodyLength`.
- Fails open so diagnostics do not interrupt app traffic.
- Does not yet provide ignore filters, multipart/file metadata, binary body
  detection, or content-type based capture policies.
