import 'package:flutter_test/flutter_test.dart';
import 'package:grabkit_all/grabkit_all.dart';

void main() {
  test('all bundle exports standard modules', () {
    expect(GrabKitNetworkModule(), isA<GrabKitModule>());
    expect(GrabKitLogsModule(), isA<GrabKitModule>());
    expect(GrabKitRealtimeModule(), isA<GrabKitModule>());
  });
}
