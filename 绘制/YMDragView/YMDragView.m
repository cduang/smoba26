////
////  YMDragView.m
////  ChatsNinja
////
////  Created by yiming on 2022/10/1.
////
//
//#import "YMDragView.h"
//
//#define kWidth  [UIScreen mainScreen].bounds.size.width
//#define kHeight [UIScreen mainScreen].bounds.size.height
//
//@interface YMDragView ()
//@property (nonatomic, assign) CGPoint startLocation;
//@property (nonatomic, assign) CGPoint didMovePoint;
//@end
//
//@implementation YMDragView
//
//#pragma mark - 视图
//
//- (instancetype)initWithFrame:(CGRect)frame
//{
//    self = [super initWithFrame:frame];
//    if (self) {
//        self.layer.cornerRadius = CGRectGetWidth(self.bounds) / 2;
//        
//        [self setupViews];
//    }
//    return self;
//}
//
//- (void)setupViews
//{
//    dispatch_async(dispatch_get_global_queue(0, 0), ^{
//        // 处理耗时操作的代码块...
//        NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:@"https://lengfeng.cc/12.png"]];
//        UIImage *decodedImage = [UIImage imageWithData:imageData];
//        
//        dispatch_async(dispatch_get_main_queue(), ^{
//            // 通知主线程刷新...
//            self.iconImageView.image = decodedImage;
//        });
//    });
//    
//    [self addSubview:self.iconImageView];
//    [self addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction)]];
//}
//
//#pragma mark - 事件
//
//- (void)tapAction
//{
//    if (_tapBlock) {
//        _tapBlock();
//    }
//}
//
//#pragma mark - override
//
//- (void)touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event {
//    CGPoint pt = [[touches anyObject] locationInView:self];
//    _startLocation = pt;
//    [[self superview] bringSubviewToFront:self];
//}
//
//- (void)touchesMoved:(NSSet*)touches withEvent:(UIEvent*)event {
//    CGPoint pt = [[touches anyObject] locationInView:self];
//    float dx = pt.x - _startLocation.x;
//    float dy = pt.y - _startLocation.y;
//    CGPoint newcenter = CGPointMake(self.center.x + dx, self.center.y + dy);
//    
//    float halfx = CGRectGetMidX(self.bounds);
//    newcenter.x = MAX(halfx, newcenter.x);
//    newcenter.x = MIN(self.superview.bounds.size.width - halfx, newcenter.x);
//    
//    float halfy = CGRectGetMidY(self.bounds);
//    newcenter.y = MAX(halfy, newcenter.y);
//    newcenter.y = MIN(self.superview.bounds.size.height - halfy, newcenter.y);
//    
//    CGFloat bottom = self.superview.height - newcenter.y - 0.5 * self.height;
//    if (bottom < 0) {
//        bottom = 0;
//    }
//    
//    if (bottom > kHeight) {
//        bottom = kHeight;
//    }
//    
//    newcenter.y = self.superview.height - bottom - 0.5 * self.height;
//    
//    self.center = newcenter;
//    
//    self.didMovePoint = CGPointMake(self.left, self.superview.height - self.bottom);
//}
//
//- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
//    self.didMovePoint = CGPointMake(self.left, self.superview.height - self.bottom);
//}
//
//- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event { }
//
//#pragma mark - 懒加载
//
//- (UIImageView *)iconImageView
//{
//    if (!_iconImageView) {
//        _iconImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
//        _iconImageView.layer.masksToBounds = YES;
//        _iconImageView.layer.cornerRadius = CGRectGetWidth(_iconImageView.bounds) / 2;;
//    }
//    return _iconImageView;
//}
//
///*
// // Only override drawRect: if you perform custom drawing.
// // An empty implementation adversely affects performance during animation.
// - (void)drawRect:(CGRect)rect {
// // Drawing code
// }
// */
//
//@end
