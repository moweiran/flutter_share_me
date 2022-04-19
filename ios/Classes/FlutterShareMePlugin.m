#import "FlutterShareMePlugin.h"
#if __has_include(<flutter_share_me/flutter_share_me-Swift.h>)
#import <flutter_share_me/flutter_share_me-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "flutter_share_me-Swift.h"
#endif

@implementation FlutterShareMePlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    [SwiftFlutterShareMePlugin registerWithRegistrar:registrar];
}
@end
