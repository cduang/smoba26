#import <Foundation/Foundation.h>
//#import "HTTPServer.h"
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SpeedUDIDHelper : NSObject
//@property (nonatomic, strong) HTTPServer *httpServer;
@property (nonatomic) UIBackgroundTaskIdentifier backgroundTask;
@property (nonatomic, copy) void(^completion)(NSString *udid);
+ (instancetype)shared;
- (void)getUDIDCompletion: (void (^ __nullable)(NSString *udid))completion;
@end

NS_ASSUME_NONNULL_END
