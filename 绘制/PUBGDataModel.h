//
//  PUBGDataModel.h
//  ChatsNinja
//
//  Created by yiming on 2022/10/2.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "PUBGTypeHeader.h"
NS_ASSUME_NONNULL_BEGIN
@interface PUBGPlayerBone : NSObject
@property (nonatomic,  assign) FVector2D  _0;
@property (nonatomic,  assign) FVector2D  _1;
@property (nonatomic,  assign) FVector2D  _2;
@property (nonatomic,  assign) FVector2D  _3;
@property (nonatomic,  assign) FVector2D  _4;
@property (nonatomic,  assign) FVector2D  _5;
@property (nonatomic,  assign) FVector2D  _6;
@property (nonatomic,  assign) FVector2D  _7;
@property (nonatomic,  assign) FVector2D  _8;
@property (nonatomic,  assign) FVector2D  _9;
@property (nonatomic,  assign) FVector2D  _10;
@property (nonatomic,  assign) FVector2D  _11;
@property (nonatomic,  assign) FVector2D  _12;
@property (nonatomic,  assign) FVector2D  _13;
@property (nonatomic,  assign) FVector2D  _14;
@property (nonatomic,  assign) FVector2D  _15;
@property (nonatomic,  assign) FVector2D  _16;
@property (nonatomic,  assign) FVector2D  _17;
@property (nonatomic,  assign) FVector2D  root;
@end

@interface PUBGPlayerModel : NSObject
/// 编号
@property (nonatomic,  assign) NSInteger TeamID;
@property (nonatomic,  assign) int chiqiang;
/// 名称
@property (nonatomic,    copy) NSString *PlayerName;
/// 距离
@property (nonatomic,  assign) CGFloat  Distance;
@property (nonatomic,  assign) CGFloat  wuzimi;
/// 血量
@property (nonatomic,  assign) CGFloat  Health;

/// 载具血量
@property (nonatomic,  assign) CGFloat  zaijuxue;
/// 载具油量
@property (nonatomic,  assign) CGFloat  zaijuyou;

@property (nonatomic,  assign) BOOL  zaijuid;

/// 方框
@property (nonatomic,  assign) CGRect  rect;
@property (nonatomic,  assign) CGRect  wuzi;
@property (nonatomic,  assign) CGRect  data1;
@property (nonatomic,  assign) CGRect  data2;
@property (nonatomic,  assign) CGRect  data3;
@property (nonatomic,  assign) CGRect  data4;
@property (nonatomic,  assign) CGRect  data5;
@property (nonatomic,  assign) CGRect  data6;
@property (nonatomic,  assign) CGRect  data7;
@property (nonatomic,  assign) CGRect  data8;
/// AI，1是人机，0是真人
@property (nonatomic,  assign) BOOL  isAI;
@property (nonatomic,  assign) NSInteger flag;
//骨骼骨架
@property (nonatomic,  strong) PUBGPlayerBone *bone;
@end

NS_ASSUME_NONNULL_END
