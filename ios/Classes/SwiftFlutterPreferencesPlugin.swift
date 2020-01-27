import Flutter
import UIKit

public class SwiftFlutterPreferencesPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "flutter_preferences", binaryMessenger: registrar.messenger())
    let instance = SwiftFlutterPreferencesPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    let args = call.arguments as? [String : Any] ?? [:]
    switch call.method {
    case "getAll":
        result(getAllPrefs())
        break
    case "setBool":
        let key:String = args["key"] as! String
        let value:NSNumber = args["value"] as! NSNumber
        UserDefaults.standard.set(value.boolValue, forKey: key)
        UserDefaults.standard.synchronize()
        result(true)
        break
    case "setInt":
        let key:String = args["key"] as! String
        let value:NSNumber = args["value"] as! NSNumber
        // int type in Dart can come to native side in a variety of forms
        // It is best to store it as is and send it back when needed.
        // Platform channel will handle the conversion.
        UserDefaults.standard.set(value, forKey: key)
        UserDefaults.standard.synchronize()
        result(true);
        break
    case "setDouble":
        let key:String = args["key"] as! String
        let value:NSNumber = args["value"] as! NSNumber
        UserDefaults.standard.set(value.doubleValue, forKey: key)
        UserDefaults.standard.synchronize()
        result(true);
        break
    case "setString":
        let key:String = args["key"] as! String
        let value:String = args["value"] as! String
        UserDefaults.standard.set(value, forKey: key)
        UserDefaults.standard.synchronize()
        result(true);
        break
    case "commit":
        UserDefaults.standard.synchronize()
        // synchronize is deprecated.
        // "this method is unnecessary and shouldn't be used."
        result(true);
        break
    case "remove":
        UserDefaults.standard.removeObject(forKey: args["key"] as? String ?? "")
        UserDefaults.standard.synchronize()
        result(true);
        break
    case "clear":
        let userDefaults:UserDefaults = UserDefaults.standard
        let prefs = getAllPrefs()
        if prefs.count != 0 {
            for key in prefs {
                userDefaults.removeObject(forKey: key.key as! String );
            }
        }
        UserDefaults.standard.synchronize()
        result(true);
        break
    default:
        result(FlutterMethodNotImplemented);
    }
  }
}

fileprivate func getAllPrefs() -> NSMutableDictionary {
    let appDomain:String = Bundle.main.bundleIdentifier ?? ""
    let prefs:Dictionary<String, Any> = UserDefaults.standard.persistentDomain(forName: appDomain) ?? [:]
    let filteredPrefs = NSMutableDictionary()
    if(!prefs.isEmpty) {
        for candidateKey in prefs {
            filteredPrefs.setObject(prefs[candidateKey.key]!, forKey: candidateKey.key as NSCopying)
        }
    }
    return filteredPrefs
}
