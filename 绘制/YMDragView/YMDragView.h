//
//  YMDragView.h
//  ChatsNinja
//
//  Created by yiming on 2022/10/1.
//

#import <UIKit/UIKit.h>
//#import "UIView+CGRect.h"

NS_ASSUME_NONNULL_BEGIN

@interface YMDragView : UIView
@property (nonatomic, copy) dispatch_block_t tapBlock;
@property (nonatomic, strong) UIImageView *iconImageView;

@end

NS_ASSUME_NONNULL_END
