//
//  YMUIWindow.m
//  ChatsNinja
//
//  Created by yiming on 2022/10/2.
//

#import "YMUIWindow.h"
//- (BOOL)_ignoresHitTest {
//    return YES;
//}
@interface YMUIWindow()
@property BOOL touchableAll;
@property CGRect touchableRect;
@end

@implementation YMUIWindow
static id _sharedInstance;
static dispatch_once_t _onceToken;
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.userInteractionEnabled = NO;
        self.windowLevel = UIWindowLevelStatusBar+9999;
        self.clipsToBounds = YES;
        
        [self setHidden:NO];
        [self setAlpha:1.0];
        [self setBackgroundColor:[UIColor clearColor]];
        
        //          self.touchableAll = YES;
        //
        //        [self _setSecure:YES];
    }
    return self;
}

//- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
//{
//    return NO;
//}
//
-(void)guann{
    
    [self setHidden:YES];
    
}
-(void)kaiqia{
    
    
    
    [self setHidden:NO];
    
    
}
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    UIView *view = [super hitTest:point withEvent:event];
    if (view == self.rootViewController.view) {
        return nil;
    }
    NSLog(@"aaaa%s",__func__);
    return view;
}
-(void)update{
    NSLog(@"aaadasdasdafafaa");
}
//如果希望严谨一点，可以将上面if语句及里面代码替换成如下代码 //UIView *view = [_redButton hitTest: redBtnPoint withEvent: event]; //if (view) return view; return [super hitTest:point withEvent:event]; }

//- (BOOL)pointInside:(CGPoint)point withEvent:(nullable UIEvent *)event;
//{
//    //NSLog(@"touchtest floatwin pointInside=%@, %@", NSStringFromCGPoint(point), event);
//    int count = (int)self.subviews.count;
//    for (int i = count - 1; i >= 0;i-- ) {
//        UIView *childV = self.subviews[i];
//        // 把当前坐标系上的点转换成子控件坐标系上的点.
//        CGPoint childP = [self convertPoint:point toView:childV];
//        UIView *fitView = [childV hitTest:childP withEvent:event];
//        if(fitView) {
//            NSLog(@"FloatWindow pointInside=%@", fitView);
//            return NO;
//        }
//    }
//    return NO;
//}


- (BOOL)_ignoresHitTest {
    
    return YES;
    
}
+ (BOOL)_isSecure
{
    return YES;
}

//-(UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event{
//
//    //1.判断自己能否接收事件
//    if(self.userInteractionEnabled == NO || self.hidden == YES || self.alpha <= 0.01) {
//        return nil;
//    }
//    //2.判断当前点在不在当前View.
//    if (![self pointInside:point withEvent:event]) {
//        return nil;
//    }
//    //3.从后往前遍历自己的子控件.让子控件重复前两步操作,(把事件传递给,让子控件调用hitTest)
//    int count = (int)self.subviews.count;
//    for (int i = count - 1; i >= 0; i--) {
//        //取出每一个子控件
//        UIView *chileV =  self.subviews[i];
//        //把当前的点转换成子控件坐标系上的点.
//        CGPoint childP = [self convertPoint:point toView:chileV];
//        UIView *fitView = [chileV hitTest:childP withEvent:event];
//        //判断有没有找到最适合的View
//        if(fitView){
//            return fitView;
//        }
//    }
//
//    //4.没有找到比它自己更适合的View.那么它自己就是最适合的View
//    return self;
//
//}


//作用:判断当前点在不在它调用View,(谁调用pointInside,这个View就是谁)
//什么时候调用:它是在hitTest方法当中调用的.
//注意:point点必须得要跟它方法调用者在同一个坐标系里面
+ (instancetype)sharedInstance
{
    dispatch_once(&_onceToken, ^{
        _sharedInstance = [[self alloc] initWithFrame:[UIScreen mainScreen].bounds];
    });
    return _sharedInstance;
}




@end
