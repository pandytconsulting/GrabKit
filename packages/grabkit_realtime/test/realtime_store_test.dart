import 'package:flutter_test/flutter_test.dart';
import 'package:grabkit/grabkit.dart';
import 'package:grabkit_realtime/grabkit_realtime.dart';

void main() {
  test('module declares realtime capture metadata', () {
    final metadata = GrabKitRealtimeModule().metadata;

    expect(metadata.capturesEvents, isTrue);
    expect(metadata.contributesToReports, isTrue);
    expect(metadata.dataCategories, {GrabKitDataCategory.realtime});
  });

  test('records realtime events', () {
    final store = GrabKitRealtimeStore()..add('received', 'order.updated');
    expect(store.entries.single.message, 'order.updated');
  });
}
