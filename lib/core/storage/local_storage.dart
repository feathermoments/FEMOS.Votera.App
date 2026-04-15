import 'package:hive_flutter/hive_flutter.dart';

/// Hive-based local cache for offline support.
class LocalStorageService {
  static const _prefsBox = 'preferences';
  static const _cacheBox = 'cache';

  Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox<dynamic>(_prefsBox);
    await Hive.openBox<dynamic>(_cacheBox);
  }

  // ── Preferences ──────────────────────────────────
  Box<dynamic> get _prefs => Hive.box(_prefsBox);

  String get themeMode =>
      _prefs.get('themeMode', defaultValue: 'system') as String;
  set themeMode(String mode) => _prefs.put('themeMode', mode);

  bool get notificationsEnabled =>
      _prefs.get('notificationsEnabled', defaultValue: true) as bool;
  set notificationsEnabled(bool value) =>
      _prefs.put('notificationsEnabled', value);

  int get selectedFamilyMember =>
      _prefs.get('selectedFamilyMember', defaultValue: 0) as int;
  set selectedFamilyMember(int index) =>
      _prefs.put('selectedFamilyMember', index);

  // ── Cache ────────────────────────────────────────
  Box<dynamic> get _cache => Hive.box(_cacheBox);

  Future<void> cacheData(String key, dynamic data) => _cache.put(key, data);

  dynamic getCachedData(String key) => _cache.get(key);

  Future<void> clearCache() => _cache.clear();
}
