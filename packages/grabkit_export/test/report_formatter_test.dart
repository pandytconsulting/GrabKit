import 'package:flutter_test/flutter_test.dart';
import 'package:grabkit/grabkit.dart';
import 'package:grabkit_export/grabkit_export.dart';

void main() {
  test('module declares report data metadata', () {
    final metadata = GrabKitExportModule(environmentName: 'qa').metadata;

    expect(metadata.capturesEvents, isFalse);
    expect(metadata.contributesToReports, isTrue);
    expect(
      metadata.dataCategories,
      containsAll({
        GrabKitDataCategory.appInfo,
        GrabKitDataCategory.deviceInfo,
        GrabKitDataCategory.environment,
        GrabKitDataCategory.network,
        GrabKitDataCategory.logs,
        GrabKitDataCategory.realtime,
      }),
    );
  });

  test('builds an empty report', () {
    final report = GrabKitReportFormatter.build(
      const GrabKitReportInput(
        environmentName: 'qa',
        networkCalls: [],
        logs: [],
        realtimeEvents: [],
      ),
    );
    expect(report, contains('Environment: qa'));
  });
}
