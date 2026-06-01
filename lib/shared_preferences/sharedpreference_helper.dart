import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesHelper {
  SharedPreferencesHelper._privateConstructor();

  static final SharedPreferencesHelper instance =
      SharedPreferencesHelper._privateConstructor();

  static SharedPreferences? _prefs;

  /// Optional: call once at app start to warm up the instance.
  static Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  //get SharedPreferences instance
  Future<SharedPreferences> get _getPrefs async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  // Generic setter for various types
  Future<bool> setValue<T>(String key, T value) async {
    final p = await _getPrefs;

    if (value is int) return p.setInt(key, value);
    if (value is double) return p.setDouble(key, value);
    if (value is bool) return p.setBool(key, value);
    if (value is String) return p.setString(key, value);
    if (value is List<String>) return p.setStringList(key, value);

    // Fallback: try JSON encode any other value (Maps, Lists, objects with toJson())
    try {
      final encoded = jsonEncode(value);
      return p.setString(key, encoded);
    } catch (_) {
      // If encoding fails, attempt to call `toJson` dynamically then encode
      try {
        final dyn = (value as dynamic);
        final obj = dyn.toJson();
        final encoded = jsonEncode(obj);
        return p.setString(key, encoded);
      } catch (_) {
        return Future.value(false);
      }
    }
  }

  // Generic getter for various types
  Future<T?> getValue<T>(String key, {T? defaultValue}) async {
    final p = await _getPrefs;

    if (T == int) return (p.getInt(key) as T?) ?? defaultValue;
    if (T == double) return (p.getDouble(key) as T?) ?? defaultValue;
    if (T == bool) return (p.getBool(key) as T?) ?? defaultValue;
    if (T == String) return (p.getString(key) as T?) ?? defaultValue;
    if (T == List<String>) return (p.getStringList(key) as T?) ?? defaultValue;

    // Fallback: attempt to decode stored JSON string into requested type
    final stored = p.getString(key);
    if (stored == null) return defaultValue;

    try {
      final decoded = jsonDecode(stored);
      return decoded as T;
    } catch (_) {
      return defaultValue;
    }
  }

  // Remove a specific key
  Future<bool> remove(String key) async {
    final p = await _getPrefs;
    return p.remove(key);
  }

  // Clear all preferences
  Future<bool> clear() async {
    final p = await _getPrefs;
    return p.clear();
  }

  /// Clear all preferences and reset providers except authProvider.
  /// Use this when calling from within AuthNotifier to avoid
  /// "A provider cannot depend on itself" error.
  Future<bool> clearExceptAuth(Ref ref) async {
    final p = await _getPrefs;
    final result = await p.clear();

    return result;
  }

  // Check if a key exists
  Future<bool> containsKey(String key) async {
    final p = await _getPrefs;
    return p.containsKey(key);
  }
}
