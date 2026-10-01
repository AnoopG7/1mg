import 'dart:convert';
import 'dart:async';

import 'package:flutter/foundation.dart';

import 'package:shared_preferences/shared_preferences.dart';

import 'firestore_service.dart';

/// Thin JSON wrapper over SharedPreferences so providers stay storage-agnostic.
class StorageService {
  StorageService._(this._prefs);

  final SharedPreferences _prefs;

  static StorageService? _instance;

  /// Drops the cached instance so each test can start from a clean store.
  @visibleForTesting
  static void resetForTest() => _instance = null;

  static Future<StorageService> init() async {
    _instance ??= StorageService._(await SharedPreferences.getInstance());
    return _instance!;
  }

  static StorageService get instance {
    final i = _instance;
    if (i == null) {
      throw StateError('StorageService.init() must be awaited before use');
    }
    return i;
  }

  List<T> readList<T>(String key, T Function(Map<String, dynamic>) fromJson) {
    final raw = _prefs.getString(key);
    if (raw == null || raw.isEmpty) return <T>[];
    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded
          .whereType<Map<String, dynamic>>()
          .map(fromJson)
          .toList(growable: false);
    } catch (_) {
      return <T>[];
    }
  }

  Future<void> writeList<T>(
    String key,
    List<T> items,
    Map<String, dynamic> Function(T) toJson,
  ) async {
    final data = items.map(toJson).toList(growable: false);
    await _prefs.setString(key, jsonEncode(data));
    unawaited(FirestoreService.writeUserData(key, data));
  }

  bool readBool(String key, {bool fallback = false}) =>
      _prefs.getBool(key) ?? fallback;

  Future<void> writeBool(String key, bool value) =>
      _writeRemote('bool', key, value, () => _prefs.setBool(key, value));

  int readInt(String key, {int fallback = 0}) =>
      _prefs.getInt(key) ?? fallback;

  Future<void> writeInt(String key, int value) =>
      _writeRemote('int', key, value, () => _prefs.setInt(key, value));

  double readDouble(String key, {double fallback = 0}) =>
      _prefs.getDouble(key) ?? fallback;

  Future<void> writeDouble(String key, double value) =>
      _writeRemote('double', key, value, () => _prefs.setDouble(key, value));

  String readString(String key, {String fallback = ''}) =>
      _prefs.getString(key) ?? fallback;

  Future<void> writeString(String key, String value) =>
      _writeRemote('string', key, value, () => _prefs.setString(key, value));

  Future<void> remove(String key) async {
    await _prefs.remove(key);
    unawaited(FirestoreService.deleteUserData(key));
  }

  Future<void> _writeRemote(
    String type,
    String key,
    dynamic value,
    Future<bool> Function() writeLocal,
  ) async {
    await writeLocal();
    unawaited(FirestoreService.writeUserData(key, {'type': type, 'value': value}));
  }
}
