import 'package:hive/hive.dart';

class HiveService {
  HiveService._internal();
  static final HiveService instance = HiveService._internal();

  static const loginKey = 'login';
  static const isUserLoggedIn = 'isUserLoggedIn';
  static const loginToken = 'token';
  static const refreshToken = 'refresh_token';

  late Box _box;

  Future<void> init() async {
    _box = Hive.box('appBox');
  }

  Future<void> save(dynamic pin, String key) async {
    await _box.put(key, pin);
  }

  String? getString(String key) {
    return _box.get(key);
  }

  bool? getBool(String key) {
    return _box.get(key);
  }

  Future<void> delete(String key) async {
    await _box.delete(key);
  }

  Future<void> clear() async {
    await _box.clear();
  }
}
