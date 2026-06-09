import 'package:flutter_test/flutter_test.dart';
import 'package:grabkit/grabkit.dart';

void main() {
  group('defaultGrabKitRedactor', () {
    test('redacts common sensitive fields recursively', () {
      final result = defaultGrabKitRedactor({
        'authorization': 'Bearer secret',
        'profile': {
          'name': 'Example',
          'password': 'secret',
        },
        'events': [
          {'otp': '123456'},
        ],
      });

      expect(
        result,
        equals({
          'authorization': '[REDACTED]',
          'profile': {
            'name': 'Example',
            'password': '[REDACTED]',
          },
          'events': [
            {'otp': '[REDACTED]'},
          ],
        }),
      );
    });

    test('preserves non-sensitive values', () {
      expect(
        defaultGrabKitRedactor({
          'requestId': 'example-id',
          'count': 2,
          'enabled': true,
        }),
        equals({'requestId': 'example-id', 'count': 2, 'enabled': true}),
      );
    });
  });
}
