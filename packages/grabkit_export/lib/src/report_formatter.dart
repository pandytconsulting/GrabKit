import 'package:grabkit_logs/grabkit_logs.dart';
import 'package:grabkit_network/grabkit_network.dart';
import 'package:grabkit_realtime/grabkit_realtime.dart';

class GrabKitReportInput {
  const GrabKitReportInput({
    required this.environmentName,
    required this.networkCalls,
    required this.logs,
    required this.realtimeEvents,
    this.sessionSummary,
  });

  final String environmentName;
  final String? sessionSummary;
  final List<GrabKitNetworkRecord> networkCalls;
  final List<GrabKitLogRecord> logs;
  final List<GrabKitRealtimeRecord> realtimeEvents;
}

abstract final class GrabKitReportFormatter {
  static String build(GrabKitReportInput input) {
    final buffer = StringBuffer()
      ..writeln('GrabKit Debug Report')
      ..writeln('Generated: ${DateTime.now().toIso8601String()}')
      ..writeln('Environment: ${input.environmentName}');
    if (input.sessionSummary != null) {
      buffer.writeln('Session: ${input.sessionSummary}');
    }
    buffer.writeln('\nNetwork calls (${input.networkCalls.length})');
    for (final call in input.networkCalls.take(50)) {
      buffer.writeln('- ${call.method} ${call.statusCode ?? '-'} ${call.uri}');
    }
    buffer.writeln('\nRealtime events (${input.realtimeEvents.length})');
    for (final event in input.realtimeEvents.take(50)) {
      buffer.writeln('- ${event.type}: ${event.message}');
    }
    buffer.writeln('\nApp logs (${input.logs.length})');
    for (final log in input.logs.take(50)) {
      buffer.writeln('- ${log.level}: ${log.message}');
    }
    return buffer.toString();
  }
}
