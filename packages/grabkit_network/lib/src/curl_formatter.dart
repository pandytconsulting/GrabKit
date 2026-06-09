import 'dart:convert';

import 'network_record.dart';

abstract final class GrabKitCurlFormatter {
  static String format(GrabKitNetworkRecord record) {
    final parts = <String>[
      'curl',
      '-X',
      _quote(record.method.toUpperCase()),
      _quote(record.uri),
    ];
    for (final entry in record.requestHeaders.entries) {
      parts
        ..add('-H')
        ..add(_quote('${entry.key}: ${entry.value}'));
    }
    if (record.requestBody != null) {
      parts
        ..add('--data-raw')
        ..add(_quote(_bodyText(record.requestBody)));
    }
    return parts.join(' ');
  }

  static String _bodyText(Object? body) {
    if (body is String) return body;
    try {
      return jsonEncode(body);
    } catch (_) {
      return '$body';
    }
  }

  static String _quote(String value) => "'${value.replaceAll("'", "'\"'\"'")}'";
}
