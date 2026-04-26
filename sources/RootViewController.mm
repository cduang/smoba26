//
//  RootViewController.mm
//  TrollSpeed
//
//  Created by Lessica on 2024/1/24.
//

#import <notify.h>
#import <objc/runtime.h>

#import "HUDHelper.h"
#import "MainButton.h"
#import "MainApplication.h"
#import "HUDPresetPosition.h"
#import "RootViewController.h"
#import "UIApplication+Private.h"
#import "HUDRootViewController.h"

#define HUD_TRANSITION_DURATION 0.25

static BOOL _gShouldToggleHUDAfterLaunch = NO;
static const CGFloat _gTopButtonConstraintsConstantCompact = 46.f;
static const CGFloat _gTopButtonConstraintsConstantRegular = 28.f;
static const CGFloat _gTopButtonConstraintsConstantRegularPad = 46.f;
static const CGFloat _gAuthorLabelBottomConstraintConstantCompact = -20.f;
static const CGFloat _gAuthorLabelBottomConstraintConstantRegular = -80.f;
UITextField *inputTextField;
UILabel *messageLabel;
UIView *LoginView;
BOOL 验证状态 =true;

UILabel *summaryLabels[5];
bool 绘制总开关,方框开关,射线开关,头像开关,技能开关,野怪开关,过直播开关;
float 地图位置,地图大小;

@implementation RootViewController {
    //验证系统
    UILabel *DeviceIDLabel;
    
    //验证结束
   
    
    NSMutableDictionary *_userDefaults;
    MainButton *_mainButton;
    MainButton *_mainButton2;
    UIButton *_settingsButton;
    UIButton *_topLeftButton;
    UIButton *_topRightButton;
    UIButton *_topCenterButton;
    UIButton *_topCenterMostButton;
    UILabel *_authorLabel;
    BOOL _supportsCenterMost;
    UISwitch *mySwitch;
    NSLayoutConstraint *_topLeftConstraint;
    NSLayoutConstraint *_topRightConstraint;
    NSLayoutConstraint *_topCenterConstraint;
    NSLayoutConstraint *_authorLabelBottomConstraint;
    BOOL _isRemoteHUDActive;
    BOOL IsMaterial;
    BOOL IsPlayer;
    HUDRootViewController *_localHUDRootViewController;  // Only for debugging
    UIImpactFeedbackGenerator *_impactFeedbackGenerator;
}

+ (void)setShouldToggleHUDAfterLaunch:(BOOL)flag
{
    _gShouldToggleHUDAfterLaunch = flag;
}

+ (BOOL)shouldToggleHUDAfterLaunch
{
    return _gShouldToggleHUDAfterLaunch;
}

- (BOOL)isHUDEnabled
{
#if !NO_TROLL
    return IsHUDEnabled();
#else
    return _localHUDRootViewController != nil;
#endif
}

- (void)setHUDEnabled:(BOOL)enabled
{
#if !NO_TROLL
    SetHUDEnabled(enabled);
#else
    if (enabled && _localHUDRootViewController == nil) {
        _localHUDRootViewController = [[HUDRootViewController alloc] init];
        [self presentViewController:_localHUDRootViewController animated:YES completion:nil];
    } else {
        [_localHUDRootViewController dismissViewControllerAnimated:YES completion:nil];
        _localHUDRootViewController = nil;
    }
#endif
}

- (void)registerNotifications
{
    int token;
    notify_register_dispatch(NOTIFY_RELOAD_APP, &token, dispatch_get_main_queue(), ^(int token) {
        [self loadUserDefaults:YES];
    });
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(toggleHUDNotificationReceived:) name:kToggleHUDAfterLaunchNotificationName object:nil];
}


- (void)loadView
{
    CGRect bounds = UIScreen.mainScreen.bounds;
    
    self.view = [[UIView alloc] initWithFrame:bounds];
    self.view.backgroundColor = [UIColor colorWithRed:0.0f / 255.0f green:0.0f / 255.0f blue:0.0f / 255.0f alpha:.580f / 1.0f];  // rgba(0, 0, 0, 0.580)
 
    


    
    
    self.backgroundView = [[UIView alloc] initWithFrame:bounds];
    self.backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.backgroundView.backgroundColor = [UIColor colorWithDynamicProvider:^UIColor * _Nonnull(UITraitCollection * _Nonnull traitCollection) {
        return UIColor.clearColor;
    }];
  
    [self.view addSubview:self.backgroundView];
   
    

       
        [self EnterAPP];
    
    
   
    
 
}


-(void)EnterAPP{

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSMutableDictionary *userDefaults;
        userDefaults = [[NSDictionary dictionaryWithContentsOfFile:USER_DEFAULTS_PATH] mutableCopy] ?: [NSMutableDictionary dictionary];
        NSNumber *野怪 = [userDefaults objectForKey: @"FGmon"];
        NSNumber *射线 = [userDefaults objectForKey: @"SheXian"];
        NSNumber *方框 = [userDefaults objectForKey: @"FGbox"];
        NSNumber *技能 = [userDefaults objectForKey: @"FGhp"];
        NSNumber *头像 = [userDefaults objectForKey: @"TouXiang"];
        NSNumber *直播 = [userDefaults objectForKey: @"ViewNeed"];
        NSNumber *位置 = [userDefaults objectForKey: @"FGmapx"];
        NSNumber *大小 = [userDefaults objectForKey: @"FGmapy"];
        
        野怪开关 =[野怪 boolValue];
        方框开关 =[方框 boolValue];
        技能开关 =[技能 boolValue];
        头像开关 =[头像 boolValue];
        地图位置 =[位置 floatValue];
        地图大小 =[大小 floatValue];
        射线开关 =[射线 boolValue];
        
        过直播开关 =[直播 boolValue];

        if(地图大小 < 10){
            地图位置 =35.9;
            地图大小 = 131.8;
            [userDefaults setObject:@(地图位置) forKey:@"FGmapx"];
            [userDefaults setObject:@(地图大小) forKey:@"FGmapy"];
            [userDefaults writeToFile:USER_DEFAULTS_PATH atomically:YES];

        }
    });
    
    
    
        UIView *TESTVIEW =  [[UIView alloc] initWithFrame:self.view.bounds];
        TESTVIEW.backgroundColor =  [UIColor colorWithRed:244/255.0 green:245/255.0 blue:248/255.0 alpha:1.0];
        [self.backgroundView addSubview:TESTVIEW];


    
    
    UILabel *Copyright = [[UILabel alloc] initWithFrame:CGRectMake(50, 60, 200, 30)];
    Copyright.text = @"Apibug巨魔绘制";
    Copyright.font = [UIFont fontWithName:@"Helvetica-Bold" size:25];
    Copyright.textColor = [UIColor blackColor];
    [TESTVIEW addSubview:Copyright];
    
    UILabel *tapHintLabel = [[UILabel alloc] initWithFrame:CGRectMake(50, 100, 200, 20)];
    tapHintLabel.text = @"点我购买本源码(www.apibug.com)";
    tapHintLabel.font = [UIFont systemFontOfSize:12];
    tapHintLabel.textColor = [UIColor blueColor];
    tapHintLabel.userInteractionEnabled = YES;
    [TESTVIEW addSubview:tapHintLabel];

    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(openURL:)];
    [tapHintLabel addGestureRecognizer:tapGesture];
    
    
    
    UIView *ActView1 =  [[UIView alloc] initWithFrame:CGRectMake(40, 130, TESTVIEW.frame.size.width-80, 80)];
    ActView1.backgroundColor = [UIColor whiteColor]; // 淡粉色背景
    ActView1.layer.cornerRadius = 5.0; // 圆角半径
    ActView1.layer.masksToBounds = YES;
    [TESTVIEW addSubview:ActView1];
    
    UIImageView *circleImageView = [[UIImageView alloc] initWithFrame:CGRectMake(20, 20, 40, 40)];
    circleImageView.image =  [UIImage systemImageNamed:@"play.circle"];
    circleImageView.layer.cornerRadius = 20;
    circleImageView.layer.masksToBounds = YES;
    [ActView1 addSubview:circleImageView];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(70, 20, 100, 30)];
    label.text = @"开关";
    label.font =[UIFont fontWithName:@"Helvetica-Bold" size:18.0];  // 使用系统粗体字体
    label.textColor = [UIColor blackColor];
    [ActView1 addSubview:label];
    
    UILabel *mlabel = [[UILabel alloc] initWithFrame:CGRectMake(70, 35, 100, 30)];
    mlabel.text = @"绘制总开关";
    mlabel.font =[UIFont fontWithName:@"HelveticaNeue-Thin" size:12.0];  // 使用系统粗体字体
    mlabel.textColor = [UIColor blackColor];
    [ActView1 addSubview:mlabel];

    mySwitch = [[UISwitch alloc] initWithFrame:CGRectMake(ActView1.frame.size.width - 60, 25, 50, 30)];
    mySwitch.tag = 1;
    CGAffineTransform transform = CGAffineTransformMakeScale(0.7, 0.7);
    mySwitch.transform = transform;
    [mySwitch addTarget:self action:@selector(switchValueChanged:) forControlEvents:UIControlEventValueChanged];
    [ActView1 addSubview:mySwitch];
    
    
    
    UIView *ActView2 =  [[UIView alloc] initWithFrame:CGRectMake(40, 130+90, TESTVIEW.frame.size.width-80, 80)];
    ActView2.backgroundColor = [UIColor whiteColor]; // 淡粉色背景
    ActView2.layer.cornerRadius = 5.0; // 圆角半径
    ActView2.layer.masksToBounds = YES;
    [TESTVIEW addSubview:ActView2];
    
    UIImageView *circleImageView2 = [[UIImageView alloc] initWithFrame:CGRectMake(20, 20, 40, 40)];
    circleImageView2.image =  [UIImage systemImageNamed:@"play.circle"];
    circleImageView2.layer.cornerRadius = 20;
    circleImageView2.layer.masksToBounds = YES;
    [ActView2 addSubview:circleImageView2];
    
    UILabel *label2 = [[UILabel alloc] initWithFrame:CGRectMake(70, 20, 100, 30)];
    label2.text = @"绘制方框";
    label2.font =[UIFont fontWithName:@"Helvetica-Bold" size:18.0];  // 使用系统粗体字体
    label2.textColor = [UIColor blackColor];
    [ActView2 addSubview:label2];
    
    UILabel *mlabel2 = [[UILabel alloc] initWithFrame:CGRectMake(70, 35, 100, 30)];
    mlabel2.text = @"大地图敌人方框";
    mlabel2.font =[UIFont fontWithName:@"HelveticaNeue-Thin" size:12.0];  // 使用系统粗体字体
    mlabel2.textColor = [UIColor blackColor];
    [ActView2 addSubview:mlabel2];

    UISwitch *switch1 = [[UISwitch alloc] initWithFrame:CGRectMake(ActView2.frame.size.width - 60, 25, 50, 30)];
    switch1.tag = 2;
    [switch1 setOn:方框开关 animated:YES];
    switch1.transform = transform;
    [switch1 addTarget:self action:@selector(switchValueChanged:) forControlEvents:UIControlEventValueChanged];
    [ActView2 addSubview:switch1];
    
    
    
    UIView *ActView3 =  [[UIView alloc] initWithFrame:CGRectMake(40, 130+90+90, TESTVIEW.frame.size.width-80, 80)];
    ActView3.backgroundColor = [UIColor whiteColor]; // 淡粉色背景
    ActView3.layer.cornerRadius = 5.0; // 圆角半径
    ActView3.layer.masksToBounds = YES;
    [TESTVIEW addSubview:ActView3];
    
    UIImageView *circleImageView3 = [[UIImageView alloc] initWithFrame:CGRectMake(20, 20, 40, 40)];
    circleImageView3.image =  [UIImage systemImageNamed:@"play.circle"];
    circleImageView3.layer.cornerRadius = 20;
    circleImageView3.layer.masksToBounds = YES;
    [ActView3 addSubview:circleImageView3];
    
    UILabel *label3 = [[UILabel alloc] initWithFrame:CGRectMake(70, 20, 100, 30)];
    label3.text = @"绘制野怪";
    label3.font =[UIFont fontWithName:@"Helvetica-Bold" size:18.0];  // 使用系统粗体字体
    label3.textColor = [UIColor blackColor];
    [ActView3 addSubview:label3];
    
    UILabel *mlabel3 = [[UILabel alloc] initWithFrame:CGRectMake(70, 35, 200, 30)];
    mlabel3.text = @"显示小地图上的存活野怪";
    mlabel3.font =[UIFont fontWithName:@"HelveticaNeue-Thin" size:12.0];  // 使用系统粗体字体
    mlabel3.textColor = [UIColor blackColor];
    [ActView3 addSubview:mlabel3];

    UISwitch *switch2 = [[UISwitch alloc] initWithFrame:CGRectMake(ActView3.frame.size.width - 60, 25, 50, 30)];
    switch2.tag = 3;
    [switch2 setOn:野怪开关 animated:YES];
    switch2.transform = transform;
    [switch2 addTarget:self action:@selector(switchValueChanged:) forControlEvents:UIControlEventValueChanged];
    [ActView3 addSubview:switch2];
    
    
    UIView *ActView4 =  [[UIView alloc] initWithFrame:CGRectMake(40, 130+90+90+90, TESTVIEW.frame.size.width-80, 80)];
    ActView4.backgroundColor = [UIColor whiteColor]; // 淡粉色背景
    ActView4.layer.cornerRadius = 5.0; // 圆角半径
    ActView4.layer.masksToBounds = YES;
    [TESTVIEW addSubview:ActView4];
    
    UIImageView *circleImageView4 = [[UIImageView alloc] initWithFrame:CGRectMake(20, 20, 40, 40)];
    circleImageView4.image =  [UIImage systemImageNamed:@"play.circle"];
    circleImageView4.layer.cornerRadius = 20;
    circleImageView4.layer.masksToBounds = YES;
    [ActView4 addSubview:circleImageView4];
    
    UILabel *label4 = [[UILabel alloc] initWithFrame:CGRectMake(70, 20, 100, 30)];
    label4.text = @"绘制技能";
    label4.font =[UIFont fontWithName:@"Helvetica-Bold" size:18.0];  // 使用系统粗体字体
    label4.textColor = [UIColor blackColor];
    [ActView4 addSubview:label4];
    
    UILabel *mlabel4 = [[UILabel alloc] initWithFrame:CGRectMake(70, 35, 200, 30)];
    mlabel4.text = @"大地图显示英雄技能CD";
    mlabel4.font =[UIFont fontWithName:@"HelveticaNeue-Thin" size:12.0];  // 使用系统粗体字体
    mlabel4.textColor = [UIColor blackColor];
    [ActView4 addSubview:mlabel4];

    UISwitch *switch3 = [[UISwitch alloc] initWithFrame:CGRectMake(ActView3.frame.size.width - 60, 25, 50, 30)];
    switch3.tag = 4;
    [switch3 setOn:技能开关 animated:YES];
    switch3.transform = transform;
    [switch3 addTarget:self action:@selector(switchValueChanged:) forControlEvents:UIControlEventValueChanged];
    [ActView4 addSubview:switch3];
    
    
    UIView *ActView6 = [[UIView alloc] initWithFrame:CGRectMake(40, 130+90+90+90+90, TESTVIEW.frame.size.width-80, 80)];
    ActView6.backgroundColor = [UIColor whiteColor]; // 设置背景色
    ActView6.layer.cornerRadius = 5.0; // 圆角设置
    ActView6.layer.masksToBounds = YES;
    [TESTVIEW addSubview:ActView6];

    UIImageView *circleImageView6 = [[UIImageView alloc] initWithFrame:CGRectMake(20, 20, 40, 40)];
    circleImageView6.image = [UIImage systemImageNamed:@"play.circle"];
    circleImageView6.layer.cornerRadius = 20;
    circleImageView6.layer.masksToBounds = YES;
    [ActView6 addSubview:circleImageView6];

    UILabel *label6 = [[UILabel alloc] initWithFrame:CGRectMake(70, 20, 100, 30)];
    label6.text = @"绘制射线";
    label6.font = [UIFont fontWithName:@"Helvetica-Bold" size:18.0];
    label6.textColor = [UIColor blackColor];
    [ActView6 addSubview:label6];

    UILabel *mlabel6 = [[UILabel alloc] initWithFrame:CGRectMake(70, 35, 200, 30)];
    mlabel6.text = @"大地图显示英雄射线";
    mlabel6.font = [UIFont fontWithName:@"HelveticaNeue-Thin" size:12.0];
    mlabel6.textColor = [UIColor blackColor];
    [ActView6 addSubview:mlabel6];

    UISwitch *switch5 = [[UISwitch alloc] initWithFrame:CGRectMake(ActView6.frame.size.width - 60, 25, 50, 30)];
    switch5.tag = 6;
    [switch5 setOn:射线开关 animated:YES];
    switch5.transform = transform;
    [switch5 addTarget:self action:@selector(switchValueChanged:) forControlEvents:UIControlEventValueChanged];
    [ActView6 addSubview:switch5];

    
    
    UIView *ActView5 =  [[UIView alloc] initWithFrame:CGRectMake(40, 130+90+90+90+90+90, TESTVIEW.frame.size.width-80, 80)];
    ActView5.backgroundColor = [UIColor whiteColor]; // 淡粉色背景
    ActView5.layer.cornerRadius = 5.0; // 圆角半径
    ActView5.layer.masksToBounds = YES;
    [TESTVIEW addSubview:ActView5];
    
    UIImageView *circleImageView5 = [[UIImageView alloc] initWithFrame:CGRectMake(20, 20, 40, 40)];
    circleImageView5.image =  [UIImage systemImageNamed:@"play.circle"];
    circleImageView5.layer.cornerRadius = 20;
    circleImageView5.layer.masksToBounds = YES;
    [ActView5 addSubview:circleImageView5];
    
    UILabel *label5 = [[UILabel alloc] initWithFrame:CGRectMake(70, 20, 100, 30)];
    label5.text = @"隐藏视频流";
    label5.font =[UIFont fontWithName:@"Helvetica-Bold" size:18.0];  // 使用系统粗体字体
    label5.textColor = [UIColor blackColor];
    [ActView5 addSubview:label5];
    
    UILabel *mlabel5 = [[UILabel alloc] initWithFrame:CGRectMake(70, 35, 200, 30)];
    mlabel5.text = @"绘制屏蔽截图录屏直播";
    mlabel5.font =[UIFont fontWithName:@"HelveticaNeue-Thin" size:12.0];  // 使用系统粗体字体
    mlabel5.textColor = [UIColor blackColor];
    [ActView5 addSubview:mlabel5];

    UISwitch *switch4 = [[UISwitch alloc] initWithFrame:CGRectMake(ActView3.frame.size.width - 60, 25, 50, 30)];
    switch4.tag = 5;
    [switch4 setOn:过直播开关 animated:YES];
    switch4.transform = transform;
    [switch4 addTarget:self action:@selector(switchValueChanged:) forControlEvents:UIControlEventValueChanged];
    [ActView5 addSubview:switch4];
    
    
    UIView *SliderView =  [[UIView alloc] initWithFrame:CGRectMake(40, 130+90+90+90+90+90+90, TESTVIEW.frame.size.width-80, 120)];
    SliderView.backgroundColor = [UIColor whiteColor]; // 淡粉色背景
    SliderView.layer.cornerRadius = 5.0; // 圆角半径
    SliderView.layer.masksToBounds = YES;
    [TESTVIEW addSubview:SliderView];
    
    UILabel *dskghqe = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, SliderView.frame.size.width, 25)];
    dskghqe.text = @"地图位置"; // 设置标签文本
    dskghqe.font = [UIFont fontWithName:@"Helvetica-Bold" size:13.0];
    dskghqe.textColor =[UIColor blackColor];
    // 将UILabel添加到UIView *h上
    [SliderView addSubview:dskghqe];
    
    UISlider *slider = [[UISlider alloc] initWithFrame:CGRectMake(10, 25, SliderView.frame.size.width -20, 40)];
    slider.minimumTrackTintColor = [UIColor blackColor];
    slider.maximumTrackTintColor = [UIColor whiteColor];
    slider.thumbTintColor = [UIColor whiteColor];
    [slider setTintColor:[UIColor blackColor]];
    [slider addTarget:self action:@selector(FGmapx:) forControlEvents:UIControlEventValueChanged];
    slider.minimumValue = -20.0;
    slider.maximumValue = 180.0;
    slider.value = 地图位置;
    [SliderView addSubview:slider];
    
    summaryLabels[0] = [[UILabel alloc] initWithFrame:CGRectMake(SliderView.frame.size.width-55, 5,50 , 40)];
    summaryLabels[0].text = [NSString stringWithFormat:@"%.1f", 地图位置];
    summaryLabels[0].font = [UIFont fontWithName:@"Helvetica-Bold" size:13.0];
    summaryLabels[0].textColor =[UIColor redColor];
    // 将UILabel添加到UIView *h上
    [SliderView addSubview:summaryLabels[0]];
    
    UILabel *dgihure = [[UILabel alloc] initWithFrame:CGRectMake(10, 60, SliderView.frame.size.width, 25)];
    dgihure.text = @"地图大小"; // 设置标签文本
    dgihure.font = [UIFont fontWithName:@"Helvetica-Bold" size:13.0];
    dgihure.textColor =[UIColor blackColor];
    // 将UILabel添加到UIView *h上
    [SliderView addSubview:dgihure];
    
    UISlider *slider2 = [[UISlider alloc] initWithFrame:CGRectMake(10, 80, SliderView.frame.size.width -20, 40)];
    slider2.minimumTrackTintColor = [UIColor blackColor];
    slider2.maximumTrackTintColor = [UIColor whiteColor];
    slider2.thumbTintColor = [UIColor whiteColor];
    [slider2 setTintColor:[UIColor blackColor]];
    [slider2 addTarget:self action:@selector(FGmapy:) forControlEvents:UIControlEventValueChanged];
    slider2.minimumValue = -20.0;
    slider2.maximumValue = 180.0;
    slider2.value = 地图大小;
    [SliderView addSubview:slider2];
    
    summaryLabels[1] = [[UILabel alloc] initWithFrame:CGRectMake(SliderView.frame.size.width-55, 60,50 , 40)];
    summaryLabels[1].text = [NSString stringWithFormat:@"%.1f", 地图大小];
    summaryLabels[1].font = [UIFont fontWithName:@"Helvetica-Bold" size:13.0];
    summaryLabels[1].textColor =[UIColor redColor];
    // 将UILabel添加到UIView *h上
    [SliderView addSubview:summaryLabels[1]];
    
    
    [self reloadModeButtonState];

//
                         [self verticalSizeClassUpdated];
                         [self reloadMainButtonState];
                         


    
}

- (void)FGmapx:(UISlider *)sender {
    float sliderValue = sender.value;
    summaryLabels[0].text = [NSString stringWithFormat:@"%.1f", sliderValue];
    地图位置 = sliderValue;
    NSMutableDictionary *userDefaults;
    userDefaults = [[NSDictionary dictionaryWithContentsOfFile:USER_DEFAULTS_PATH] mutableCopy] ?: [NSMutableDictionary dictionary];
    [userDefaults setObject:@(地图位置) forKey:@"FGmapx"];
    [userDefaults writeToFile:USER_DEFAULTS_PATH atomically:YES];
}

- (void)FGmapy:(UISlider *)sender {
    float sliderValue = sender.value;
    summaryLabels[1].text = [NSString stringWithFormat:@"%.1f", sliderValue];
    地图大小 = sliderValue;
    NSMutableDictionary *userDefaults;
    userDefaults = [[NSDictionary dictionaryWithContentsOfFile:USER_DEFAULTS_PATH] mutableCopy] ?: [NSMutableDictionary dictionary];
    [userDefaults setObject:@(地图大小) forKey:@"FGmapy"];
    [userDefaults writeToFile:USER_DEFAULTS_PATH atomically:YES];
}


- (void)openURL:(UITapGestureRecognizer *)gesture {
    NSString *urlString = @"https://www.apibug.com";
    NSURL *url = [NSURL URLWithString:urlString];
    if ([[UIApplication sharedApplication] canOpenURL:url]) {
        [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
    }
}


- (void)switchValueChanged:(UISwitch *)sender {
    NSMutableDictionary *userDefaults;
    userDefaults = [[NSDictionary dictionaryWithContentsOfFile:USER_DEFAULTS_PATH] mutableCopy] ?: [NSMutableDictionary dictionary];
    
    switch (sender.tag) {
        case 1:
            [self LoadDraw];
            break;
        case 2:
            方框开关 = [sender isOn];
            [userDefaults setObject:@([sender isOn]) forKey:@"FGbox"];
            [userDefaults writeToFile:USER_DEFAULTS_PATH atomically:YES];
            break;
        case 3:
            野怪开关 = [sender isOn];
            [userDefaults setObject:@([sender isOn]) forKey:@"FGmon"];
            [userDefaults writeToFile:USER_DEFAULTS_PATH atomically:YES];
            break;
        case 4:
            技能开关 = [sender isOn];
            [userDefaults setObject:@([sender isOn]) forKey:@"FGhp"];
            [userDefaults writeToFile:USER_DEFAULTS_PATH atomically:YES];
            break;
        case 5:
            过直播开关 = [sender isOn];
            [userDefaults setObject:@([sender isOn]) forKey:@"ViewNeed"];
            [userDefaults writeToFile:USER_DEFAULTS_PATH atomically:YES];
         //   [self ViewTS];
            break;
        case 6:
            头像开关 = [sender isOn];
            [userDefaults setObject:@([sender isOn]) forKey:@"TouXiang"];
            [userDefaults writeToFile:USER_DEFAULTS_PATH atomically:YES];
         //   [self ViewTS];
            break;
        case 7:
            射线开关 = [sender isOn];
            [userDefaults setObject:@([sender isOn]) forKey:@"SheXian"];
            [userDefaults writeToFile:USER_DEFAULTS_PATH atomically:YES];
         //   [self ViewTS];
            break;
        default:
            break;
    }
}

- (void)LoadDraw
{
  
    
    BOOL isNowEnabled = [self isHUDEnabled];
    [self setHUDEnabled:!isNowEnabled];
    isNowEnabled = !isNowEnabled;
    
    if (isNowEnabled)
    {
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
        
        [_impactFeedbackGenerator prepare];
        int anyToken;
        __weak typeof(self) weakSelf = self;
        notify_register_dispatch(NOTIFY_LAUNCHED_HUD, &anyToken, dispatch_get_main_queue(), ^(int token) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            notify_cancel(token);
            [strongSelf->_impactFeedbackGenerator impactOccurred];
            dispatch_semaphore_signal(semaphore);
        });
        
        [self.backgroundView setUserInteractionEnabled:NO];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_global_queue(QOS_CLASS_UTILITY, 0), ^{
            intptr_t timedOut = dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5.0 * NSEC_PER_SEC)));
            dispatch_async(dispatch_get_main_queue(), ^{
                if (timedOut) {
                    log_error(OS_LOG_DEFAULT, "等待 HUD 启动超时");
                }
                [self reloadMainButtonState];
                [self.backgroundView setUserInteractionEnabled:YES];
            });
        });
    }
    else
    {
        [self.backgroundView setUserInteractionEnabled:NO];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self reloadMainButtonState];
            [self.backgroundView setUserInteractionEnabled:YES];
        });
    }
}


- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    _supportsCenterMost = CGRectGetMinY(self.view.window.safeAreaLayoutGuide.layoutFrame) >= 51;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _impactFeedbackGenerator = [[UIImpactFeedbackGenerator alloc] initWithStyle:UIImpactFeedbackStyleMedium];
    
    [self registerNotifications];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self toggleHUDAfterLaunch];
}

- (void)toggleHUDNotificationReceived:(NSNotification *)notification {
    NSString *toggleAction = notification.userInfo[kToggleHUDAfterLaunchNotificationActionKey];
    if (!toggleAction) {
        [self toggleHUDAfterLaunch];
    } else if ([toggleAction isEqualToString:kToggleHUDAfterLaunchNotificationActionToggleOn]) {
        [self toggleOnHUDAfterLaunch];
    } else if ([toggleAction isEqualToString:kToggleHUDAfterLaunchNotificationActionToggleOff]) {
        [self toggleOffHUDAfterLaunch];
    }
}

- (void)toggleHUDAfterLaunch {
    if ([RootViewController shouldToggleHUDAfterLaunch]) {
        [RootViewController setShouldToggleHUDAfterLaunch:NO];
        [self tapMainButton:_mainButton];
        [self tapMainButton:_mainButton2];
        [[UIApplication sharedApplication] suspend];
    }
}

- (void)toggleOnHUDAfterLaunch {
    if ([RootViewController shouldToggleHUDAfterLaunch]) {
        [RootViewController setShouldToggleHUDAfterLaunch:NO];
        if (!_isRemoteHUDActive) {
            [self tapMainButton:_mainButton];
            [self tapMainButton:_mainButton2];
            
        }
        [[UIApplication sharedApplication] suspend];
    }
}

- (void)toggleOffHUDAfterLaunch {
    if ([RootViewController shouldToggleHUDAfterLaunch]) {
        [RootViewController setShouldToggleHUDAfterLaunch:NO];
        if (_isRemoteHUDActive) {
            [self tapMainButton:_mainButton];
            [self tapMainButton:_mainButton2];
            
        }
        [[UIApplication sharedApplication] suspend];
    }
}

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event {
    if (motion == UIEventSubtypeMotionShake) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Developer Area", nil) message:NSLocalizedString(@"Choose an action below.", nil) preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Dismiss", nil) style:UIAlertActionStyleCancel handler:nil]];
        [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Reset Settings", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self resetUserDefaults];
        }]];
#if DEBUG && !NO_TROLL
        [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Memory Pressure", nil) style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            SimulateMemoryPressure();
        }]];
#endif
        [self presentViewController:alertController animated:YES completion:nil];
    }
}

- (void)resetUserDefaults
{
#if !NO_TROLL
    // Reset user defaults
    NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
    if (bundleIdentifier) {
        [GetStandardUserDefaults() removePersistentDomainForName:bundleIdentifier];
        [GetStandardUserDefaults() synchronize];
    }
#endif
    
    // Reset custom user defaults
    BOOL removed = [[NSFileManager defaultManager] removeItemAtPath:(ROOT_PATH_NS_VAR(USER_DEFAULTS_PATH)) error:nil];
    if (removed)
    {
        // Terminate HUD
        [self setHUDEnabled:NO];
        
        // Terminate App
        [[UIApplication sharedApplication] terminateWithSuccess];
    }
}

- (void)loadUserDefaults:(BOOL)forceReload
{
    if (forceReload || !_userDefaults) {
        _userDefaults = [[NSDictionary dictionaryWithContentsOfFile:(ROOT_PATH_NS_VAR(USER_DEFAULTS_PATH))] mutableCopy] ?: [NSMutableDictionary dictionary];
    }
}

- (void)saveUserDefaults
{
    [_userDefaults writeToFile:(ROOT_PATH_NS_VAR(USER_DEFAULTS_PATH)) atomically:YES];
    notify_post(NOTIFY_RELOAD_HUD);
}

- (BOOL)isLandscapeOrientation
{
    UIInterfaceOrientation orientation;
    orientation = self.view.window.windowScene.interfaceOrientation;
    BOOL isLandscape;
    if (orientation == UIInterfaceOrientationUnknown) {
        isLandscape = CGRectGetWidth(self.view.bounds) > CGRectGetHeight(self.view.bounds);
    } else {
        isLandscape = UIInterfaceOrientationIsLandscape(orientation);
    }
    return isLandscape;
}

- (HUDUserDefaultsKey)selectedModeKeyForCurrentOrientation
{
    return [self isLandscapeOrientation] ? HUDUserDefaultsKeySelectedModeLandscape : HUDUserDefaultsKeySelectedMode;
}

- (HUDPresetPosition)selectedModeForCurrentOrientation
{
    [self loadUserDefaults:NO];
    NSNumber *mode = [_userDefaults objectForKey:[self selectedModeKeyForCurrentOrientation]];
    return mode != nil ? (HUDPresetPosition)[mode integerValue] : HUDPresetPositionTopCenter;
}

- (void)setSelectedModeForCurrentOrientation:(HUDPresetPosition)selectedMode
{
    [self loadUserDefaults:NO];
    // Remove some keys that are not persistent
    if ([self isLandscapeOrientation]) {
        [_userDefaults removeObjectForKey:HUDUserDefaultsKeyCurrentLandscapePositionY];
    } else {
        [_userDefaults removeObjectForKey:HUDUserDefaultsKeyCurrentPositionY];
    }
    [_userDefaults setObject:@(selectedMode) forKey:[self selectedModeKeyForCurrentOrientation]];
    [self saveUserDefaults];
}

- (BOOL)passthroughMode
{
    [self loadUserDefaults:NO];
    NSNumber *mode = [_userDefaults objectForKey:HUDUserDefaultsKeyPassthroughMode];
    return mode != nil ? [mode boolValue] : NO;
}

- (void)setPassthroughMode:(BOOL)passthroughMode
{
    [self loadUserDefaults:NO];
    [_userDefaults setObject:@(passthroughMode) forKey:HUDUserDefaultsKeyPassthroughMode];
    [self saveUserDefaults];
}

- (BOOL)singleLineMode
{
    [self loadUserDefaults:NO];
    NSNumber *mode = [_userDefaults objectForKey:HUDUserDefaultsKeySingleLineMode];
    return mode != nil ? [mode boolValue] : NO;
}

- (void)setSingleLineMode:(BOOL)singleLineMode
{
    [self loadUserDefaults:NO];
    [_userDefaults setObject:@(singleLineMode) forKey:HUDUserDefaultsKeySingleLineMode];
    [self saveUserDefaults];
}

- (BOOL)usesBitrate
{
    [self loadUserDefaults:NO];
    NSNumber *mode = [_userDefaults objectForKey:HUDUserDefaultsKeyUsesBitrate];
    return mode != nil ? [mode boolValue] : NO;
}

- (void)setUsesBitrate:(BOOL)usesBitrate
{
    [self loadUserDefaults:NO];
    [_userDefaults setObject:@(usesBitrate) forKey:HUDUserDefaultsKeyUsesBitrate];
    [self saveUserDefaults];
}

- (BOOL)usesArrowPrefixes
{
    [self loadUserDefaults:NO];
    NSNumber *mode = [_userDefaults objectForKey:HUDUserDefaultsKeyUsesArrowPrefixes];
    return mode != nil ? [mode boolValue] : NO;
}

- (void)setUsesArrowPrefixes:(BOOL)usesArrowPrefixes
{
    [self loadUserDefaults:NO];
    [_userDefaults setObject:@(usesArrowPrefixes) forKey:HUDUserDefaultsKeyUsesArrowPrefixes];
    [self saveUserDefaults];
}

- (BOOL)usesLargeFont
{
    [self loadUserDefaults:NO];
    NSNumber *mode = [_userDefaults objectForKey:HUDUserDefaultsKeyUsesLargeFont];
    return mode != nil ? [mode boolValue] : NO;
}

- (void)setUsesLargeFont:(BOOL)usesLargeFont
{
    [self loadUserDefaults:NO];
    [_userDefaults setObject:@(usesLargeFont) forKey:HUDUserDefaultsKeyUsesLargeFont];
    [self saveUserDefaults];
}

- (BOOL)usesRotation
{
    [self loadUserDefaults:NO];
    NSNumber *mode = [_userDefaults objectForKey:HUDUserDefaultsKeyUsesRotation];
    return mode != nil ? [mode boolValue] : NO;
}

- (void)setUsesRotation:(BOOL)usesRotation
{
    [self loadUserDefaults:NO];
    [_userDefaults setObject:@(usesRotation) forKey:HUDUserDefaultsKeyUsesRotation];
    [self saveUserDefaults];
}

- (BOOL)usesInvertedColor
{
    [self loadUserDefaults:NO];
    NSNumber *mode = [_userDefaults objectForKey:HUDUserDefaultsKeyUsesInvertedColor];
    return mode != nil ? [mode boolValue] : NO;
}

- (void)setUsesInvertedColor:(BOOL)usesInvertedColor
{
    [self loadUserDefaults:NO];
    [_userDefaults setObject:@(usesInvertedColor) forKey:HUDUserDefaultsKeyUsesInvertedColor];
    [self saveUserDefaults];
}

- (BOOL)keepInPlace
{
    [self loadUserDefaults:NO];
    NSNumber *mode = [_userDefaults objectForKey:HUDUserDefaultsKeyKeepInPlace];
    return mode != nil ? [mode boolValue] : NO;
}

- (void)setKeepInPlace:(BOOL)keepInPlace
{
    [self loadUserDefaults:NO];
    [_userDefaults setObject:@(keepInPlace) forKey:HUDUserDefaultsKeyKeepInPlace];
    [self saveUserDefaults];
}

- (BOOL)hideAtSnapshot
{
    [self loadUserDefaults:NO];
    NSNumber *mode = [_userDefaults objectForKey:HUDUserDefaultsKeyHideAtSnapshot];
    return mode != nil ? [mode boolValue] : NO;
}

- (void)setHideAtSnapshot:(BOOL)hideAtSnapshot
{
    [self loadUserDefaults:NO];
    [_userDefaults setObject:@(hideAtSnapshot) forKey:HUDUserDefaultsKeyHideAtSnapshot];
    [self saveUserDefaults];
}
//ESP
- (BOOL)Line
{
    [self loadUserDefaults:NO];
    NSNumber *mode = [_userDefaults objectForKey:HUDUserDefaultsKeyPlayerLine];
    return mode != nil ? [mode boolValue] : NO;
}
- (BOOL)Bone
{
    [self loadUserDefaults:NO];
    NSNumber *mode = [_userDefaults objectForKey:HUDUserDefaultsKeyPlayerBone];
    return mode != nil ? [mode boolValue] : NO;
}
- (BOOL)Info
{
    [self loadUserDefaults:NO];
    NSNumber *mode = [_userDefaults objectForKey:HUDUserDefaultsKeyPlayerInfo];
    return mode != nil ? [mode boolValue] : NO;
}
- (BOOL)HP
{
    [self loadUserDefaults:NO];
    NSNumber *mode = [_userDefaults objectForKey:HUDUserDefaultsKeyPlayerHP];
    return mode != nil ? [mode boolValue] : NO;
}



- (void)reloadMainButtonState
{
    _isRemoteHUDActive = [self isHUDEnabled];
    
    static NSAttributedString *hintAttributedString = nil;
    static NSAttributedString *creditsAttributedString = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSDictionary *defaultAttributes = @{
            NSForegroundColorAttributeName: [UIColor whiteColor],
            NSFontAttributeName: [UIFont systemFontOfSize:14],
        };
        
        NSMutableParagraphStyle *creditsParaStyle = [[NSMutableParagraphStyle alloc] init];
        creditsParaStyle.lineHeightMultiple = 1.2;
        creditsParaStyle.alignment = NSTextAlignmentCenter;
        
        NSDictionary *creditsAttributes = @{
            NSForegroundColorAttributeName: [UIColor whiteColor],
            NSFontAttributeName: [UIFont systemFontOfSize:14],
            NSParagraphStyleAttributeName: creditsParaStyle,
        };
        
        NSString *hintText = @"已运行绘图";
        hintAttributedString = [[NSAttributedString alloc] initWithString:hintText attributes:defaultAttributes];
        
        NSTextAttachment *githubIcon = [NSTextAttachment textAttachmentWithImage:[UIImage imageNamed:@"github-mark-white"]];
        [githubIcon setBounds:CGRectMake(0, 0, 14, 14)];
        
        NSTextAttachment *i18nIcon = [NSTextAttachment textAttachmentWithImage:[UIImage systemImageNamed:@"character.bubble.fill"]];
        [i18nIcon setBounds:CGRectMake(0, 0, 14, 14)];
        
        NSAttributedString *githubIconText = [NSAttributedString attributedStringWithAttachment:githubIcon];
        NSMutableAttributedString *githubIconTextFull = [[NSMutableAttributedString alloc] initWithAttributedString:githubIconText];
        [githubIconTextFull appendAttributedString:[[NSAttributedString alloc] initWithString:@" " attributes:creditsAttributes]];
        
        NSAttributedString *i18nIconText = [NSAttributedString attributedStringWithAttachment:i18nIcon];
        NSMutableAttributedString *i18nIconTextFull = [[NSMutableAttributedString alloc] initWithAttributedString:i18nIconText];
        [i18nIconTextFull appendAttributedString:[[NSAttributedString alloc] initWithString:@" " attributes:creditsAttributes]];
        
        NSString *creditsText = @"未运行绘图";
        NSMutableAttributedString *creditsAttributedText = [[NSMutableAttributedString alloc] initWithString:creditsText attributes:creditsAttributes];
        
        // replace all "@GITHUB@" with github icon
        NSRange atRange;
        
        atRange = [creditsAttributedText.string rangeOfString:@"@GITHUB@"];
        while (atRange.location != NSNotFound) {
            [creditsAttributedText replaceCharactersInRange:atRange withAttributedString:githubIconTextFull];
            atRange = [creditsAttributedText.string rangeOfString:@"@GITHUB@"];
        }
        
        // replace all "@TRANSLATION@" with character bubble
        atRange = [creditsAttributedText.string rangeOfString:@"@TRANSLATION@"];
        while (atRange.location != NSNotFound) {
            [creditsAttributedText replaceCharactersInRange:atRange withAttributedString:i18nIconTextFull];
            atRange = [creditsAttributedText.string rangeOfString:@"@TRANSLATION@"];
        }
        
        creditsAttributedString = creditsAttributedText;
    });
    
    __weak typeof(self) weakSelf = self;
    [UIView transitionWithView:self.backgroundView duration:HUD_TRANSITION_DURATION options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        
        [strongSelf->mySwitch setOn:strongSelf->_isRemoteHUDActive animated:YES];
        [strongSelf->_authorLabel setAttributedText:(strongSelf->_isRemoteHUDActive ? hintAttributedString : creditsAttributedString)];
    } completion:nil];
    
  
    
}

- (void)presentTopCenterMostHints
{
    if (!_isRemoteHUDActive) {
        return;
    }
    [_authorLabel setText:NSLocalizedString(@"Tap that button on the center again,\nto toggle ON/OFF “Dynamic Island” mode.", nil)];
}

- (BOOL)settingHighlightedWithKey:(NSString * _Nonnull)key
{
    [self loadUserDefaults:NO];
    NSNumber *mode = [_userDefaults objectForKey:key];
    return mode != nil ? [mode boolValue] : NO;
}

- (void)settingDidSelectWithKey:(NSString * _Nonnull)key
{
    BOOL highlighted = [self settingHighlightedWithKey:key];
    [_userDefaults setObject:@(!highlighted) forKey:key];
    [self saveUserDefaults];
}

- (void)reloadModeButtonState
{
    HUDPresetPosition selectedMode = [self selectedModeForCurrentOrientation];
    BOOL isCentered = (selectedMode == HUDPresetPositionTopCenter || selectedMode == HUDPresetPositionTopCenterMost);
    BOOL isCenteredMost = (selectedMode == HUDPresetPositionTopCenterMost);
    [_topLeftButton setSelected:(selectedMode == HUDPresetPositionTopLeft)];
    [_topCenterButton setSelected:isCentered];
    [_topRightButton setSelected:(selectedMode == HUDPresetPositionTopRight)];
    UIImage *topCenterImage = (isCenteredMost ? [UIImage systemImageNamed:@"arrow.up.to.line"] : [UIImage systemImageNamed:@"arrow.up"]);
    [_topCenterButton setImage:topCenterImage forState:UIControlStateNormal];
}

- (void)tapAuthorLabel:(UITapGestureRecognizer *)sender
{
    if (_isRemoteHUDActive) {
        return;
    }
    NSString *repoURLString = @"https://trollspeed.app";
    NSURL *repoURL = [NSURL URLWithString:repoURLString];
    [[UIApplication sharedApplication] openURL:repoURL options:@{} completionHandler:nil];
}

- (void)tapTopLeftButton:(UIButton *)sender
{
    log_debug(OS_LOG_DEFAULT, "- [RootViewController tapTopLeftButton:%{public}@]", sender);
    [self setSelectedModeForCurrentOrientation:HUDPresetPositionTopLeft];
    [self reloadModeButtonState];
}

- (void)tapTopRightButton:(UIButton *)sender
{
    log_debug(OS_LOG_DEFAULT, "- [RootViewController tapTopRightButton:%{public}@]", sender);
    [self setSelectedModeForCurrentOrientation:HUDPresetPositionTopRight];
    [self reloadModeButtonState];
}

- (void)tapTopCenterButton:(UIButton *)sender
{
    log_debug(OS_LOG_DEFAULT, "- [RootViewController tapTopCenterButton:%{public}@]", sender);
    HUDPresetPosition selectedMode = [self selectedModeForCurrentOrientation];
    BOOL isCenteredMost = (selectedMode == HUDPresetPositionTopCenterMost);
    if (!sender.isSelected || !_supportsCenterMost) {
        [self setSelectedModeForCurrentOrientation:HUDPresetPositionTopCenter];
        if (_supportsCenterMost) {
            [self presentTopCenterMostHints];
        }
    } else {
        if (isCenteredMost) {
            [self setSelectedModeForCurrentOrientation:HUDPresetPositionTopCenter];
        } else {
            [self setSelectedModeForCurrentOrientation:HUDPresetPositionTopCenterMost];
        }
    }
    [self reloadModeButtonState];
}

- (void)tapMainButton:(UIButton *)sender
{
    log_debug(OS_LOG_DEFAULT, "- [RootViewController tapMainButton:%{public}@]", sender);
    
    BOOL isNowEnabled = [self isHUDEnabled];
    [self setHUDEnabled:!isNowEnabled];
    isNowEnabled = !isNowEnabled;
    
    if (isNowEnabled)
    {
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
        
        [_impactFeedbackGenerator prepare];
        int anyToken;
        __weak typeof(self) weakSelf = self;
        notify_register_dispatch(NOTIFY_LAUNCHED_HUD, &anyToken, dispatch_get_main_queue(), ^(int token) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            notify_cancel(token);
            [strongSelf->_impactFeedbackGenerator impactOccurred];
            dispatch_semaphore_signal(semaphore);
        });
        
        [self.backgroundView setUserInteractionEnabled:NO];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_global_queue(QOS_CLASS_UTILITY, 0), ^{
            intptr_t timedOut = dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5.0 * NSEC_PER_SEC)));
            dispatch_async(dispatch_get_main_queue(), ^{
                if (timedOut) {
                    log_error(OS_LOG_DEFAULT, "Timed out waiting for HUD to launch");
                }
                [self reloadMainButtonState];
                [self.backgroundView setUserInteractionEnabled:YES];
            });
        });
    }
    else
    {
        [self.backgroundView setUserInteractionEnabled:NO];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self reloadMainButtonState];
            [self.backgroundView setUserInteractionEnabled:YES];
        });
    }
}
- (void)tapMainButton2:(UIButton *)sender{
    
    
}
- (void)tapSettingsButton:(UIButton *)sender
{
    if (![_mainButton isEnabled]) return;
    log_debug(OS_LOG_DEFAULT, "- [RootViewController tapSettingsButton:%{public}@]", sender);
    
    TSSettingsController *settingsViewController = [[TSSettingsController alloc] init];
    settingsViewController.delegate = self;
    settingsViewController.alreadyLaunched = _isRemoteHUDActive;
    
    SPLarkTransitioningDelegate *transitioningDelegate = [[SPLarkTransitioningDelegate alloc] init];
    settingsViewController.transitioningDelegate = transitioningDelegate;
    settingsViewController.modalPresentationStyle = UIModalPresentationCustom;
    settingsViewController.modalPresentationCapturesStatusBarAppearance = YES;
    [self presentViewController:settingsViewController animated:YES completion:nil];
}

- (void)verticalSizeClassUpdated
{
    UIUserInterfaceSizeClass verticalClass = self.traitCollection.verticalSizeClass;
    BOOL isPad = ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad);
    if (verticalClass == UIUserInterfaceSizeClassCompact) {
        CGFloat topConstant = _gTopButtonConstraintsConstantCompact;
        [_settingsButton setHidden:YES];
        [_authorLabelBottomConstraint setConstant:_gAuthorLabelBottomConstraintConstantCompact];
        [_topLeftConstraint setConstant:topConstant];
        [_topRightConstraint setConstant:topConstant];
        [_topCenterConstraint setConstant:topConstant];
    } else {
        CGFloat topConstant = isPad ? _gTopButtonConstraintsConstantRegularPad : _gTopButtonConstraintsConstantRegular;
        [_settingsButton setHidden:NO];
        [_authorLabelBottomConstraint setConstant:_gAuthorLabelBottomConstraintConstantRegular];
        [_topLeftConstraint setConstant:topConstant];
        [_topRightConstraint setConstant:topConstant];
        [_topCenterConstraint setConstant:topConstant];
    }
}

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection
{
    [self verticalSizeClassUpdated];
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
        [self reloadModeButtonState];
    } completion:nil];
}
+ (NSString *)getuuidStr {
    
    NSFileManager *fileManager=[NSFileManager defaultManager];
    NSData *data=[fileManager contentsAtPath:@"/var/mobile/Library/Logs/AppleSupport/general.log"];
    NSMutableString *string = [[NSMutableString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSString *regex = @"serial\":\"(.*?)\"";
    NSError *error = nil;
    NSRegularExpression *re = [NSRegularExpression regularExpressionWithPattern:regex options:NSRegularExpressionCaseInsensitive error:&error];
    NSArray *result = [re matchesInString:string options:0 range:NSMakeRange(0, string.length)];
    for (NSTextCheckingResult *match in result) {
        NSString *serial = [string substringWithRange:[match rangeAtIndex:1]];
        NSLog(@"serial:%@",serial);
      return serial;
    }
    return NULL;
}

@end
