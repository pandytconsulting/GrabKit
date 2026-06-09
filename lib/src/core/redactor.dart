const String grabKitRedactedValue = '[REDACTED]';

/// Replaces sensitive values before GrabKit stores or displays them.
typedef GrabKitRedactor = Object? Function(Object? value);

/// Redacts common secret fields from maps and nested collections.
Object? defaultGrabKitRedactor(Object? value) {
  if (value is Map) {
    return value.map((key, nestedValue) {
      final normalizedKey = key.toString().toLowerCase();
      final isSensitive = const {
        'authorization',
        'cookie',
        'set-cookie',
        'x-api-key',
        'api-key',
        'apikey',
        'access_token',
        'access-token',
        'accesstoken',
        'refresh_token',
        'refresh-token',
        'refreshtoken',
        'password',
        'passcode',
        'pin',
        'otp',
        'secret',
      }.contains(normalizedKey);
      return MapEntry(
        key,
        isSensitive
            ? grabKitRedactedValue
            : defaultGrabKitRedactor(nestedValue),
      );
    });
  }
  if (value is Iterable) {
    return value.map(defaultGrabKitRedactor).toList(growable: false);
  }
  return value;
}
