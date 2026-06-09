class GrabKitNetworkRecord {
  GrabKitNetworkRecord({
    required this.at,
    required this.method,
    required this.uri,
    this.statusCode,
    this.duration,
    this.requestHeaders = const {},
    this.requestQuery = const {},
    this.requestBody,
    this.requestSummary,
    this.responseSummary,
    this.errorMessage,
  });

  final DateTime at;
  final String method;
  final String uri;
  final int? statusCode;
  final Duration? duration;
  final Map<String, dynamic> requestHeaders;
  final Map<String, dynamic> requestQuery;
  final Object? requestBody;
  final String? requestSummary;
  final String? responseSummary;
  final String? errorMessage;

  bool get isError =>
      errorMessage != null || (statusCode != null && statusCode! >= 400);
}

typedef ApiCallRecord = GrabKitNetworkRecord;
