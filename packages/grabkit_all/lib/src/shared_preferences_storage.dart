import 'package:grabkit/grabkit.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GrabKitSharedPreferencesStorage implements GrabKitStorage {
  @override
  Future<String?> read(String key) async =>
      (await SharedPreferences.getInstance()).getString(key);

  @override
  Future<void> remove(String key) async =>
      (await SharedPreferences.getInstance()).remove(key);

  @override
  Future<void> write(String key, String value) async =>
      (await SharedPreferences.getInstance()).setString(key, value);
}
