#import "AdyenFlutterPlugin.h"
#import <adyen_flutter/adyen_flutter-Swift.h>

@implementation AdyenFlutterPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftAdyenFlutterPlugin registerWithRegistrar:registrar];
}
@end
