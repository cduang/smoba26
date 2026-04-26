//
//  PUBGDrawDataFactory.h
//  ChatsNinja
//
//  Created by yiming on 2022/10/2.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#include <mach/mach.h>
#include <mach/vm_map.h>
#include <mach-o/dyld.h>
#include <mach-o/getsect.h>
#include <mach-o/dyld_images.h>
#include <sys/sysctl.h>
#include <dlfcn.h>

#import "PUBGTypeHeader.h"

#define kAddrMax 0xFFFFFFFFF

NS_ASSUME_NONNULL_BEGIN

typedef void (^PUBGDrawDataFactoryFetchDataBlock)(NSArray *playerArray);

@interface kuajinchengzuobiao : NSObject

+ (instancetype)factory;

/// 获取内存
- (pid_t)getProcesses:(NSString *)name;
- (mach_port_t)getTask:(int)pid;
- (vm_map_offset_t)getBaseAddress:(mach_port_t)task;
#pragma mark - 物资开关
//extern bool zaiju;
//extern bool qiangxie;
//extern bool hujia;
//extern bool beijing;
//extern bool peijian;
//extern bool zidan;
//extern bool yaoping;
//extern bool hezi;
//extern bool kongtou;
//extern bool xinghaoqiang;
//extern bool shoulei;
/// 
- (void)fetchData:(GameInfo)gameInfo block:(PUBGDrawDataFactoryFetchDataBlock)block;

@end

NS_ASSUME_NONNULL_END
