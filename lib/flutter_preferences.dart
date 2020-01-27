import 'dart:async';

import 'package:flutter/services.dart';

class FlutterPreferenceHelper {
  Map<String, _FlutterPreferences> _preferenceMap;

  static final FlutterPreferenceHelper _instance = FlutterPreferenceHelper._();

  factory FlutterPreferenceHelper() => _instance;

  FlutterPreferenceHelper._();

  Future init(List<String> prefs) async {
    _preferenceMap = Map<String, _FlutterPreferences>();
    prefs.add('default');
    for (String pref in prefs) {
      _preferenceMap[pref] = await _FlutterPreferences.getInstance(
        prefName: pref,
      );
    }
  }

  _FlutterPreferences named(String prefName) {
    if (prefName == null) {
      prefName = 'default';
    }
    if (_preferenceMap.containsKey(prefName)) {
      var prefs = _preferenceMap[prefName];
      return prefs;
    }
    throw Exception(
        'Init preferences using FlutterPreferenceHelper.init([$prefName])');
  }

  _FlutterPreferences getDefault() {
    return named(null);
  }
}

class _FlutterPreferences {
  final String _prefName;
  final Map<String, Object> _preferenceCache;

  _FlutterPreferences._(this._prefName, this._preferenceCache);

  static const MethodChannel _channel =
      const MethodChannel('flutter_preferences');

  static Future<_FlutterPreferences> getInstance({String prefName}) async {
    if (prefName == null || prefName.isEmpty || prefName == 'default') {
      prefName = null;
    }
    var map = await _channel.invokeMethod('getAll', <String, dynamic>{
      'pref_name': prefName,
    });
    map = new Map<String, dynamic>.from(map);
    return _FlutterPreferences._(prefName, map);
  }

  /// The cache that holds all preferences.
  ///
  /// It is instantiated to the current state of the SharedPreferences or
  /// NSUserDefaults object and then kept in sync via setter methods in this
  /// class.
  ///
  /// It is NOT guaranteed that this cache and the device prefs will remain
  /// in sync since the setter method might fail for any reason.

  /// Returns all keys in the persistent storage.
  Set<String> getKeys() => Set<String>.from(_preferenceCache.keys);

  /// Reads a value of any type from persistent storage.
  dynamic get(String key) => _preferenceCache[key];

  /// Reads a value from persistent storage, throwing an exception if it's not a
  /// bool.
  bool getBool(String key) => _preferenceCache[key];

  /// Reads a value from persistent storage, throwing an exception if it's not
  /// an int.
  int getInt(String key) => _preferenceCache[key];

  /// Reads a value from persistent storage, throwing an exception if it's not
  /// an double.
  double getDouble(String key) => _preferenceCache[key];

  /// Reads a value from persistent storage, throwing an exception if it's not a
  /// String.
  String getString(String key) => _preferenceCache[key];

  /// Returns true if persistent storage the contains the given [key].
  bool containsKey(String key) => _preferenceCache.containsKey(key);

  /// Saves a boolean [value] to persistent storage in the background.
  ///
  /// If [value] is null, this is equivalent to calling [remove()] on the [key].
  Future<bool> setBool(String key, bool value) => _setValue('Bool', key, value);

  /// Saves an integer [value] to persistent storage in the background.
  ///
  /// If [value] is null, this is equivalent to calling [remove()] on the [key].
  Future<bool> setInt(String key, int value) => _setValue('Int', key, value);

  /// Saves an double [value] to persistent storage in the background.
  ///
  /// If [value] is null, this is equivalent to calling [remove()] on the [key].
  Future<bool> setDouble(String key, double value) =>
      _setValue('Double', key, value);

  /// Saves a string [value] to persistent storage in the background.
  ///
  /// If [value] is null, this is equivalent to calling [remove()] on the [key].
  Future<bool> setString(String key, String value) =>
      _setValue('String', key, value);

  /// Removes an entry from persistent storage.
  Future<bool> remove(String key) => _setValue(null, key, null);

  Future<bool> _setValue(String valueType, String key, Object value) {
    final Map<String, dynamic> params = <String, dynamic>{
      'key': '$key',
    };
    if (value == null) {
      _preferenceCache.remove(key);
      return _channel
          .invokeMethod<bool>('remove', params)
          .then<bool>((dynamic result) => result);
    } else {
      _preferenceCache[key] = value;

      params['value'] = value;
      params['pref_name'] = _prefName;
      return _channel
          .invokeMethod<bool>('set$valueType', params)
          .then<bool>((dynamic result) => result);
    }
  }

  /// Always returns true.
  /// On iOS, synchronize is marked deprecated. On Android, we commit every set.
  @deprecated
  Future<bool> commit() async => await _channel.invokeMethod<bool>('commit');

  /// Completes with true once the user preferences for the app has been cleared.
  Future<bool> clear() async {
    _preferenceCache.clear();
    return await _channel.invokeMethod<bool>('clear');
  }

  /// Fetches the latest values from the host platform.
  ///
  /// Use this method to observe modifications that were made in native code
  /// (without using the plugin) while the app is running.
  Future<void> reload() async {
    final Map<String, Object> preferences = await _getSPMap();
    _preferenceCache.clear();
    _preferenceCache.addAll(preferences);
  }

  Future<Map<String, Object>> _getSPMap() async {
    final Map<String, Object> fromSystem =
        await _channel.invokeMapMethod('getAll', <String, dynamic>{
      'pref_name': _prefName,
    });
    assert(fromSystem != null);
    // Strip the flutter. prefix from the returned preferences.
    final Map<String, Object> preferencesMap = <String, Object>{};
    for (String key in fromSystem.keys) {
      preferencesMap[key] = fromSystem[key];
    }
    return preferencesMap;
  }
}
