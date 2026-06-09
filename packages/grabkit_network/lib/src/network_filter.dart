import 'network_record.dart';

class GrabKitNetworkFilter {
  const GrabKitNetworkFilter({
    this.query = '',
    this.method,
    this.errorsOnly = false,
  });

  final String query;
  final String? method;
  final bool errorsOnly;

  bool matches(GrabKitNetworkRecord record) {
    if (method != null && record.method.toUpperCase() != method) return false;
    if (errorsOnly && !record.isError) return false;
    final normalizedQuery = query.trim().toLowerCase();
    if (normalizedQuery.isEmpty) return true;
    return record.uri.toLowerCase().contains(normalizedQuery) ||
        record.method.toLowerCase().contains(normalizedQuery) ||
        '${record.statusCode ?? ''}'.contains(normalizedQuery) ||
        (record.requestSummary?.toLowerCase().contains(normalizedQuery) ??
            false) ||
        (record.responseSummary?.toLowerCase().contains(normalizedQuery) ??
            false);
  }
}
