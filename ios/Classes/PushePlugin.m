#import "PushPolePlugin.h"
#import <pushpole/pushpole-Swift.h>

@implementation PushPolePlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftPushPolePlugin registerWithRegistrar:registrar];
}
@end
