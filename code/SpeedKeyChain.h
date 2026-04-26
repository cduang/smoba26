/* 源码由Speed提供 其他防抓包 防破解如有需求可咨询购买 */
#import <Foundation/Foundation.h>

@interface SpeedKeyChain : NSObject

+ (BOOL)setData:(id)data serviceDomain:(NSString *)serviceDomain;

+ (id)getDataWithServiceDomain:(NSString *)serviceDomain;

+ (BOOL)deleteDataWithServiceDomain:(NSString *)serviceDomain;

@end
