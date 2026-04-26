//
//  PUBGDrawView.h
//  ChatsNinja
//
//  Created by yiming on 2022/10/2.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface huitu : UIView

+ (instancetype)drawView:(CGRect)frame;
-(void)addToWindws;
-(void)guanbi;
- (void)show;
- (void)hide;
- (void)drawAction;
@end

NS_ASSUME_NONNULL_END
