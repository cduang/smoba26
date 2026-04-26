//
//  YMUIViewController.m
//  ChatsNinja
//
//  Created by yiming on 2022/10/2.
//

#import "LFUIViewController.h"
#import "YMDragView.h"
#import "YMUIWindow.h"
//#import "zheshihuitu.h"
@interface LFUIViewController ()

//@property (nonatomic, strong) YMDragView *dragView;
//@property (nonatomic, strong) zheshihuitu *drawView;
@end

@implementation LFUIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setupViews];
}

#pragma mark - 视图

- (void)setupViews
{
//    __weak typeof(self) weakSelf = self;
//    _dragView = [[YMDragView alloc] initWithFrame:CGRectMake(100, 300, 50, 50)];
//    _dragView.tapBlock = ^{
//        [weakSelf showAlet];
//    };
//    [self.view addSubview:_dragView];
    
  
}

- (void)showAlet
{
    UIAlertController *alertCtrl = [UIAlertController alertControllerWithTitle:@"Ho啊啊啊ok" message:@"applicationDidFinishLaunching" preferredStyle:UIAlertControllerStyleAlert];
    
    [alertCtrl addAction:[UIAlertAction actionWithTitle:@"开绘制" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
//        绘图吧 *sni=[[绘图吧 alloc]init];
//        [sni addToWindws];
//     YMUIWindow *shuq=[[YMUIWindow alloc]init];
//            [shuq kaiqia];
        
    }]];
    
    [alertCtrl addAction:[UIAlertAction actionWithTitle:@"关绘制" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//        绘图吧 *sni=[[绘图吧 alloc]init];
//               [sni guanbi];
//        YMUIWindow *shuq=[[YMUIWindow alloc]init];
//        [shuq guann];
    }]];
    
    [alertCtrl addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:nil]];

    [self presentViewController:alertCtrl animated:YES completion:nil];
}

#pragma mark - 事件

//- (BOOL)shouldAutorotate
//{
//    // 是否自动旋转
//    return YES;
//}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    // 当前 VC 支持的屏幕方向
    return UIInterfaceOrientationMaskLandscape;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    // 优先的屏幕方向
    return UIInterfaceOrientationLandscapeRight;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
