package com.flutter_preferences;

import android.content.Context;
import android.content.SharedPreferences;
import android.preference.PreferenceManager;
import android.util.Log;

import java.util.HashMap;
import java.util.Map;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;

/**
 * FlutterPreferencesPlugin
 */
public class FlutterPreferencesPlugin implements MethodCallHandler {
  private final Context context;

  private FlutterPreferencesPlugin(Context context) {
    this.context = context;
  }

  /**
   * Plugin registration.
   */
  public static void registerWith(Registrar registrar) {
    final MethodChannel channel = new MethodChannel(registrar.messenger(), "flutter_preferences");
    channel.setMethodCallHandler(new FlutterPreferencesPlugin(registrar.context()));
  }

  @Override
  public void onMethodCall(MethodCall call, Result result) {
    String pref_name = call.argument("pref_name");
    SharedPreferences preferences;
    if (pref_name == null) {
      preferences = PreferenceManager.getDefaultSharedPreferences(context);
    } else {
      preferences = context.getSharedPreferences(pref_name, Context.MODE_PRIVATE);
    }
    String key = call.argument("key");
    try {
      switch (call.method) {
        case "setBool":
          preferences.edit().putBoolean(key, (boolean) call.argument("value")).apply();
          result.success(true);
          break;
        case "setInt":
          Number number = call.argument("value");
          preferences.edit().putLong(key, number.longValue()).apply();
          result.success(true);
          break;
        case "setLong":
          long longValue = ((Number) call.argument("value")).longValue();
          preferences.edit().putLong(key, longValue).apply();
          result.success(true);
          break;
        case "setDouble":
          float floatValue = ((Number) call.argument("value")).floatValue();
          preferences.edit().putFloat(key, floatValue).apply();
          result.success(true);
          break;
        case "setString":
          String value = (String) call.argument("value");
          preferences.edit().putString(key, value).apply();
          result.success(true);
          break;
        case "commit":
          // We've been committing the whole time.
          result.success(true);
          break;
        case "getAll":
          result.success(getAllPrefs(preferences));
          return;
        case "remove":
          preferences.edit().remove(key).apply();
          result.success(true);
          break;
        case "clear":
          preferences.edit().clear().apply();
          result.success(true);
          break;
        default:
          result.notImplemented();
          break;
      }
    } catch (Exception e) {
      result.error("IOException encountered", call.method, e);
    }
  }

  // Filter preferences to only those set by the flutter app.
  private Map<String, Object> getAllPrefs(SharedPreferences preferences) {
    Map<String, ?> allPrefs = preferences.getAll();
    Map<String, Object> filteredPrefs = new HashMap<>();
    for (String key : allPrefs.keySet()) {
      Object value = allPrefs.get(key);
      filteredPrefs.put(key, value);
    }
    return filteredPrefs;
  }
}
