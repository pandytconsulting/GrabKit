/// Persistence abstraction used by optional GrabKit modules.
abstract interface class GrabKitStorage {
  Future<String?> read(String key);
  Future<void> write(String key, String value);
  Future<void> remove(String key);
}

/// In-memory storage suitable for tests and non-persistent installations.
class GrabKitMemoryStorage implements GrabKitStorage {
  final Map<String, String> _values = {};

  @override
  Future<String?> read(String key) async => _values[key];

  @override
  Future<void> remove(String key) async => _values.remove(key);

  @override
  Future<void> write(String key, String value) async => _values[key] = value;
}
