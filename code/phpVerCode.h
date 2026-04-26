
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface phpVerCode : NSObject

+ (NSString *)dictionaryToJson:(NSDictionary *)dic;

+ (void)showAlertView;

+ (NSString *)getuuidStr;

+ (NSString *)UUID;

+(void)verCodeF;

@end

NS_ASSUME_NONNULL_END
