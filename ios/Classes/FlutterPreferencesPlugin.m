#import "FlutterPreferencesPlugin.h"
#import <flutter_preferences/flutter_preferences-Swift.h>

@implementation FlutterPreferencesPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftFlutterPreferencesPlugin registerWithRegistrar:registrar];
}
@end
