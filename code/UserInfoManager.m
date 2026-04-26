#import "UserInfoManager.h"
static UserInfoManager *manager = nil;
@implementation UserInfoManager
+ (UserInfoManager *)__attribute__((optnone))shareUserInfoManager{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[UserInfoManager alloc]init];
    });
    return manager;
}
@end
