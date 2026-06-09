import 'package:flutter_test/flutter_test.dart';
import 'package:grabkit/grabkit.dart';
import 'package:grabkit_logs/grabkit_logs.dart';

void main() {
  test('module declares log capture metadata', () {
    final metadata = GrabKitLogsModule().metadata;

    expect(metadata.capturesEvents, isTrue);
    expect(metadata.contributesToReports, isTrue);
    expect(metadata.dataCategories, {GrabKitDataCategory.logs});
  });

  test('records app logs', () {
    final store = GrabKitLogStore()..add('info', 'Started');
    expect(store.entries.single.message, 'Started');
  });
}
