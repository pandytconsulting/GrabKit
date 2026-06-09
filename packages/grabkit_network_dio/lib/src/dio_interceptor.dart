import 'package:dio/dio.dart';
import 'package:grabkit/grabkit.dart';
import 'package:grabkit_network/grabkit_network.dart';

const _stopwatchKey = '_grabkit_network_stopwatch';

class GrabKitDioInterceptor extends Interceptor {
  GrabKitDioInterceptor({
    GrabKitNetworkStore? store,
    this.maxBodyLength = 4096,
    this.redactor = defaultGrabKitRedactor,
    this.eventBus,
  }) : store = store ?? GrabKitNetworkStore.instance {
    if (eventBus != null) this.store.eventBus = eventBus;
  }

  final GrabKitNetworkStore store;
  final int maxBodyLength;
  final GrabKitRedactor redactor;
  final GrabKitEventBus? eventBus;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.extra[_stopwatchKey] = Stopwatch()..start();
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    try {
      _record(response.requestOptions, response: response);
    } catch (_) {
      // Diagnostics must never interrupt application traffic.
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    try {
      _record(err.requestOptions, response: err.response, error: err.message);
    } catch (_) {
      // Diagnostics must never interrupt application traffic.
    }
    handler.next(err);
  }

  void _record(
    RequestOptions options, {
    Response? response,
    String? error,
  }) {
    final stopwatch = options.extra[_stopwatchKey];
    if (stopwatch is Stopwatch) stopwatch.stop();
    final headers = _map(options.headers);
    final query = _map(options.queryParameters);
    final requestBody = redactor(options.data);
    final responseBody = redactor(response?.data);
    final uri = options.uri.replace(queryParameters: query).toString();
    final record = GrabKitNetworkRecord(
      at: DateTime.now(),
      method: options.method,
      uri: uri,
      statusCode: response?.statusCode,
      duration: stopwatch is Stopwatch ? stopwatch.elapsed : null,
      requestHeaders: headers,
      requestQuery: query,
      requestBody: requestBody,
      requestSummary: 'headers: ${_trim(headers)}\nquery: ${_trim(query)}'
          '${options.data == null ? '' : '\nbody: ${_trim(requestBody)}'}',
      responseSummary: response?.data == null ? null : _trim(responseBody),
      errorMessage: error,
    );
    store.add(record);
  }

  Map<String, dynamic> _map(Map<String, dynamic> value) {
    final redacted = redactor(value);
    return redacted is Map
        ? redacted.map((key, value) => MapEntry(key.toString(), value))
        : {};
  }

  String _trim(Object? value) {
    final text = '$value';
    return text.length <= maxBodyLength
        ? text
        : '${text.substring(0, maxBodyLength)}… [truncated]';
  }
}
