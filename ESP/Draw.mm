//
//  PUBGDrawView.m
//  ChatsNinja
//
//  Created by TianCgg on 2022/10/2.
//

#import <cstddef>
#import <cstdlib>
#import <dlfcn.h>
#import <spawn.h>
#import <unistd.h>
#import <notify.h>
#import <net/if.h>
#import <ifaddrs.h>
#import <sys/wait.h>
#import <sys/types.h>
#import <sys/sysctl.h>
#import <mach-o/dyld.h>
#import <MetalKit/MetalKit.h>
#import <vector>
#import "HeeeNoScreenShotView.h"
#import "Utilties.h"
#import "../绘制/ImGuiMTKView.h"
#define kuandu  [UIScreen mainScreen].bounds.size.width
#define gaodu [UIScreen mainScreen].bounds.size.height
#define SMOBA_NSLog(format, ...) NSLog(@"SMOBA-Apibug: " format, ##__VA_ARGS__)

//#define kWidth  [UIScreen mainScreen].bounds.size.width
//#define kHeight [UIScreen mainScreen].bounds.size.height
#define KMTLColor           MTLClearColorMake(0, 0, 0, 0)
#define KWindowBgColor      ImVec4(235.0f / 255.0f, 235.0f / 255.0f, 235.0f / 255.0f, 1.0f)
#define KTextColor          ImVec4(70.0f / 255.0f, 70.0f / 255.0f, 70.0f / 255.0f, 1.0f)
#define KScrollbarBgColor   ImVec4(35.0f / 255.0f, 35.0f / 255.0f, 35.0f / 255.0f, 0.0f)
#define iPhone8P ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1242, 2208), [[UIScreen mainScreen] currentMode].size) : NO)
#define KClearColor         [UIColor clearColor]
#define SCREEN_WIDTH            [[UIScreen mainScreen] bounds].size.width

#define KImGuiWindowFlags   ImGuiWindowFlags_NoResize | ImGuiWindowFlags_NoSavedSettings | ImGuiWindowFlags_NoScrollbar | ImGuiWindowFlags_NoScrollWithMouse | ImGuiWindowFlags_NoBackground


@interface SkillView : UIView
@property UIView* Skill1;
@property UIView* Skill2;
@property UIView* Skill3;
@property UIView* Skill4;
@end

@implementation SkillView
@end

@interface ImGuiTouchForwardingView : UIView
@property (nonatomic, weak) ImGuiMTKView *renderer;
@end

@implementation ImGuiTouchForwardingView
- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    return YES;
}
- (void)forwardTouchEvent:(UIEvent *)event {
    [self.renderer handleEvent:event view:self];
}
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self forwardTouchEvent:event];
}
- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self forwardTouchEvent:event];
}
- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self forwardTouchEvent:event];
}
- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self forwardTouchEvent:event];
}
@end

@interface 绘图吧 : UIView <ImGuiMTKViewDelegate>
@property (nonatomic, strong) NSMutableArray<CAShapeLayer *> *MonstersCircles;
@property (nonatomic, strong) UIView *imguiHostView;
@property (nonatomic, strong) MTKView *imguiMTKView;
@property (nonatomic, strong) ImGuiMTKView *imguiRenderer;
@property (nonatomic, strong) ImGuiTouchForwardingView *imguiTouchView;
@property (nonatomic, strong) HeeeNoScreenShotView *noScreenShotView;
@property (nonatomic, assign) BOOL imguiVisible;
@property (nonatomic, assign) BOOL hideInVideoStream;
@end

@implementation 绘图吧

CGSize ScreenSize;
static id _sharedInstance;
static float mapx,mapy,技能绘制x调节,技能绘制y调节,半径;
static dispatch_once_t _onceToken;
NSMutableDictionary *userDefaults;
NSString *deviceType;
Vector2 GameCanvas;
Vector2 MiniMap;
std::vector<SaveImage> NetImage;
std::vector<SaveImage> NetImage1;
std::vector<SaveImage> NetImage2;
std::vector<SaveImage> NetImage3;
std::vector<SaveImage> NetImage4;

bool 绘制方框 = false,绘制技能 = false,绘制野怪 = false,绘制头像 = false,绘制射线 = false;
static BOOL gSwitchesLoaded = NO;
static NSString * const kImGuiMenuVisibleKey = @"FGimguiMenuVisible";
static NSString * const kUsesCustomFontSizeKey = @"usesCustomFontSize";
static NSString * const kRealCustomFontSizeKey = @"realCustomFontSize";
static NSString * const kUsesCustomOffsetKey = @"usesCustomOffset";
static NSString * const kRealCustomOffsetXKey = @"realCustomOffsetX";
static NSString * const kRealCustomOffsetYKey = @"realCustomOffsetY";

SkillView* SkillTable[10];
UIImageView* HeroImage[10];
CAShapeLayer* Draw_方框;
UIBezierPath* Path_方框;

CAShapeLayer* Draw_血条背景;
CAShapeLayer* Draw_血圈;

UIBezierPath* Path_血条背景;
UIBezierPath* Path_血圈;

UIBezierPath* Path_xueRect;
UIBezierPath* Path_xuebeijingRect;

CAShapeLayer* MonstersCircle;
UILabel* warningLabels[10];

CAShapeLayer* Draw_Rect; //圆形
CAShapeLayer* Draw_Circle;
CAShapeLayer* Draw_Circle_Disable;
UIBezierPath* Path_Rect;
UIBezierPath* Path_Circle;
UIBezierPath* Path_Circle_Disable;
CAShapeLayer* HeroBloodRing[10];
SkillView* hpTable[10];


UIImageView* 小地图英雄头像视图[10];
UIImageView* 技能表英雄头像视图[10];
UIImageView* 大招图标视图[10];
UIImageView* 方框技能图标视图[10];
UIImageView* 大地图头像[10];
SkillView* 玩家技能[10];


+ (instancetype)cjDrawView
{
    return [[绘图吧 alloc] initWithFrame:[UIScreen mainScreen].bounds];
}


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
      //  GameCanvas.x = self.frame.size.width;
      //  GameCanvas.y = self.frame.size.height;
        
        self.backgroundColor = [UIColor clearColor];//背景色
        [self setUserInteractionEnabled:YES];
        self.multipleTouchEnabled = YES;

        self.noScreenShotView = [[HeeeNoScreenShotView alloc] initWithFrame:self.bounds];
        self.noScreenShotView.backgroundColor = [UIColor clearColor];
        self.noScreenShotView.userInteractionEnabled = NO;
        self.noScreenShotView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self addSubview:self.noScreenShotView];
        
        Draw_Rect = [[CAShapeLayer alloc] init];
        Draw_Rect.frame = self.frame;
        Draw_Rect.strokeColor = UIColor.greenColor.CGColor;// 方框颜色
        Draw_Rect.fillColor = UIColor.clearColor.CGColor;
        [self.noScreenShotView.layer addSublayer:Draw_Rect];
     
        for (int i=0; i<10; i++) {
            // 地图透视英雄图
            HeroImage[i] = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
            HeroImage[i].backgroundColor = [UIColor clearColor];
            HeroImage[i].layer.masksToBounds = YES;
            HeroImage[i].layer.cornerRadius = 9;
            HeroImage[i].hidden=YES;
            HeroImage[i].layer.borderColor = [UIColor redColor].CGColor;
            HeroImage[i].layer.borderWidth = 1.f;
            [self.noScreenShotView addSubview:HeroImage[i]];
            

            //回城警告
            warningLabels[i] = [[UILabel alloc] initWithFrame:CGRectZero];
            warningLabels[i].text = @"⚠️";
            warningLabels[i].textColor = [UIColor yellowColor];
            warningLabels[i].hidden = YES;
            warningLabels[i].adjustsFontSizeToFitWidth = YES;
            warningLabels[i].minimumScaleFactor = 0.2;
            warningLabels[i].textAlignment = NSTextAlignmentCenter;
            [self.noScreenShotView addSubview:warningLabels[i]];
            
            //血条
            HeroBloodRing[i] = [CAShapeLayer layer];
            HeroBloodRing[i].strokeColor = [UIColor redColor].CGColor;//血条颜色
            HeroBloodRing[i].fillColor = [UIColor clearColor].CGColor;
            HeroBloodRing[i].lineWidth = 3; // 设置边框的宽度
            [self.noScreenShotView.layer addSublayer:HeroBloodRing[i]];
            
        }
        
        //判断英雄人数当0 小于 10
        for (int i=0; i<10; i++) {
            // 创建技能UI位置大小
            SkillTable[i] = [[SkillView alloc] initWithFrame:CGRectMake(0, 0, 80, 16)];
            SkillTable[i].Skill1 = [[UIView alloc] initWithFrame:CGRectMake(2, 0, 16, 16)];
            SkillTable[i].Skill2 = [[UIView alloc] initWithFrame:CGRectMake(22, 0, 16, 16)];
            SkillTable[i].Skill3 = [[UIView alloc] initWithFrame:CGRectMake(42, 0, 16, 16)];
            SkillTable[i].Skill4 = [[UIView alloc] initWithFrame:CGRectMake(62, 0, 16, 16)];
            
            // 将四个技能加入视图列表
            [SkillTable[i] addSubview:SkillTable[i].Skill1];
            [SkillTable[i] addSubview:SkillTable[i].Skill2];
            [SkillTable[i] addSubview:SkillTable[i].Skill3];
            [SkillTable[i] addSubview:SkillTable[i].Skill4];
            
            // 技能1
            SkillTable[i].Skill1.backgroundColor = [UIColor greenColor];
            SkillTable[i].Skill1.layer.masksToBounds = YES;
            SkillTable[i].Skill1.layer.cornerRadius = 8;
            SkillTable[i].Skill1.layer.borderColor = [UIColor colorWithRed:0.52f green:0.8 blue:0.98f alpha:0.7f].CGColor;
            SkillTable[i].Skill1.layer.borderWidth = 1.f;
            
            // 技能2
            SkillTable[i].Skill2.backgroundColor = [UIColor greenColor];
            SkillTable[i].Skill2.layer.masksToBounds = YES;
            SkillTable[i].Skill2.layer.cornerRadius = 8;
            SkillTable[i].Skill2.layer.borderColor = [UIColor colorWithRed:0.52f green:0.8 blue:0.98f alpha:0.7f].CGColor;
            SkillTable[i].Skill2.layer.borderWidth = 1.f;
            
            // 技能3
            SkillTable[i].Skill3.backgroundColor = [UIColor greenColor];
            SkillTable[i].Skill3.layer.masksToBounds = YES;
            SkillTable[i].Skill3.layer.cornerRadius = 8;
            SkillTable[i].Skill3.layer.borderColor = [UIColor colorWithRed:0.52f green:0.8 blue:0.98f alpha:0.7f].CGColor;
            SkillTable[i].Skill3.layer.borderWidth = 1.f;
            
            
            // 技能4
            SkillTable[i].Skill4.backgroundColor = [UIColor greenColor];
            SkillTable[i].Skill4.layer.masksToBounds = YES;
            SkillTable[i].Skill4.layer.cornerRadius = 8;//拐角半径
            SkillTable[i].Skill4.layer.borderColor = [UIColor colorWithRed:0.52f green:0.8 blue:0.98f alpha:0.7f].CGColor;//边框颜色
            SkillTable[i].Skill4.layer.borderWidth = 1.f;//边框宽度
            
            
            SkillTable[i].backgroundColor = [UIColor clearColor];
            [SkillTable[i] setHidden:YES];
            [self.noScreenShotView addSubview:SkillTable[i]];
        }
        
//        Draw_血条背景 = [[CAShapeLayer alloc] init];
//        Draw_血条背景.frame = self.frame;
//        Draw_血条背景.lineWidth=2.3;
//        Draw_血条背景.strokeColor = [UIColor colorWithRed:0 green:1 blue:1 alpha:0.3].CGColor;//方框颜色
//        Draw_血条背景.fillColor = UIColor.clearColor.CGColor;
//        [self.layer addSublayer:Draw_血条背景];
//        
//        Draw_血圈 = [[CAShapeLayer alloc] init];
//        Draw_血圈.frame = self.frame;
//        Draw_血圈.lineWidth=2.3;
//        Draw_血圈.strokeColor = UIColor.redColor.CGColor;//方框颜色
//        Draw_血圈.fillColor = UIColor.clearColor.CGColor;
//        [self.layer addSublayer:Draw_血圈];
//        
//        self.userInteractionEnabled = NO;
//        self.layer.allowsEdgeAntialiasing = YES;
//      
//        
//        _MonstersCircles = [NSMutableArray array];
//        for (int i = 0; i < 50; i++) {
//            CAShapeLayer* MonstersCircle = [CAShapeLayer layer];
//            [_MonstersCircles addObject:MonstersCircle];
//        }
        
        self.imguiHostView = [[UIView alloc] initWithFrame:self.bounds];
        self.imguiHostView.backgroundColor = [UIColor clearColor];
        self.imguiHostView.userInteractionEnabled = YES;
        self.imguiHostView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

        self.imguiTouchView = [[ImGuiTouchForwardingView alloc] initWithFrame:self.bounds];
        self.imguiTouchView.backgroundColor = UIColor.clearColor;
        self.imguiTouchView.userInteractionEnabled = YES;
        self.imguiTouchView.multipleTouchEnabled = YES;
        self.imguiTouchView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

        self.imguiMTKView = [[MTKView alloc] initWithFrame:self.bounds];
        self.imguiMTKView.device = MTLCreateSystemDefaultDevice();
        self.imguiMTKView.clearColor = MTLClearColorMake(0, 0, 0, 0);
        self.imguiMTKView.backgroundColor = UIColor.clearColor;
        self.imguiMTKView.opaque = NO;
        self.imguiMTKView.enableSetNeedsDisplay = NO;
        self.imguiMTKView.paused = NO;
        self.imguiMTKView.preferredFramesPerSecond = 60;
        self.imguiMTKView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self.imguiTouchView addSubview:self.imguiMTKView];
        [self.imguiHostView addSubview:self.imguiTouchView];
        [self.noScreenShotView addSubview:self.imguiHostView];
        [self.noScreenShotView bringSubviewToFront:self.imguiHostView];

        self.imguiRenderer = [[ImGuiMTKView alloc] initWithView:self.imguiMTKView];
        self.imguiRenderer.delegate = self;
        self.imguiTouchView.renderer = self.imguiRenderer;
        [self.imguiRenderer initializePlatform];
        self.imguiMTKView.delegate = self.imguiRenderer;
        self.imguiVisible = NO;
        self.hideInVideoStream = YES;
        self.imguiHostView.hidden = YES;
        self.imguiTouchView.hidden = YES;
        self.imguiMTKView.hidden = YES;

        CADisplayLink* Link = [CADisplayLink displayLinkWithTarget:self selector:@selector(huizhia)];
        Link.preferredFramesPerSecond = 60;
        [Link addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        SMOBA_NSLog(@"绘制初始化完成");
    }
    
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    CGFloat Width = CGRectGetWidth(self.frame);
    CGFloat Height = CGRectGetHeight(self.frame);
}





-(void)drawUI
{
    if (!gSwitchesLoaded) {
        userDefaults = [[NSDictionary dictionaryWithContentsOfFile:USER_DEFAULTS_PATH] mutableCopy] ?: [NSMutableDictionary dictionary];
        绘制野怪 = [[userDefaults objectForKey:@"FGmon"] boolValue];
        绘制方框 = [[userDefaults objectForKey:@"FGbox"] boolValue];
        绘制技能 = [[userDefaults objectForKey:@"FGhp"] boolValue];
        绘制头像 = [[userDefaults objectForKey:@"TouXiang"] boolValue];
        绘制射线 = [[userDefaults objectForKey:@"SheXian"] boolValue];
        MiniMap.x = [[userDefaults objectForKey:@"FGmapx"] floatValue];
        MiniMap.y = [[userDefaults objectForKey:@"FGmapy"] floatValue];
        self.hideInVideoStream = [[userDefaults objectForKey:@"FGhideVideo"] boolValue];
        if (![[userDefaults objectForKey:@"FGhideVideo"] isKindOfClass:[NSNumber class]]) {
            self.hideInVideoStream = YES;
        }
        NSNumber *menuVisible = [userDefaults objectForKey:kImGuiMenuVisibleKey];
        NSNumber *enabled = [userDefaults objectForKey:@"FGimguiEnabled"];
        if (!enabled && !menuVisible) {
            self.imguiVisible = YES;
            userDefaults[@"FGimguiEnabled"] = @(YES);
            userDefaults[kImGuiMenuVisibleKey] = @(YES);
            [userDefaults writeToFile:USER_DEFAULTS_PATH atomically:YES];
        } else {
            self.imguiVisible = enabled ? enabled.boolValue : (menuVisible ? menuVisible.boolValue : NO);
        }
        gSwitchesLoaded = YES;
    }

    if (!self.imguiVisible) {
        self.imguiHostView.hidden = YES;
        self.imguiTouchView.hidden = YES;
        self.imguiMTKView.hidden = YES;
        return;
    }
    self.imguiHostView.hidden = NO;
    self.imguiTouchView.hidden = NO;
    self.imguiMTKView.hidden = NO;

    static bool lastLandscape = false;
    static ImVec2 savedWindowPos = ImVec2(18.0f, 18.0f);
    static ImVec2 savedWindowSize = ImVec2(220.0f, 240.0f);
    static bool hasSavedWindowState = false;

    const bool isLandscape = UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation);
    const ImVec2 targetWindowSize = isLandscape ? ImVec2(240.0f, 300.0f) : ImVec2(220.0f, 320.0f);

    if (!hasSavedWindowState) {
        savedWindowSize = targetWindowSize;
        savedWindowPos = isLandscape ? ImVec2(18.0f, 18.0f) : ImVec2(12.0f, 12.0f);
        hasSavedWindowState = true;
    } else if (lastLandscape != isLandscape) {
        const float oldWidth = savedWindowSize.x > 1.0f ? savedWindowSize.x : targetWindowSize.x;
        const float oldHeight = savedWindowSize.y > 1.0f ? savedWindowSize.y : targetWindowSize.y;
        const float oldCenterX = savedWindowPos.x + oldWidth * 0.5f;
        const float oldCenterY = savedWindowPos.y + oldHeight * 0.5f;
        const float oldScreenWidth = lastLandscape ? gaodu : kuandu;
        const float oldScreenHeight = lastLandscape ? kuandu : gaodu;
        const float newScreenWidth = isLandscape ? gaodu : kuandu;
        const float newScreenHeight = isLandscape ? kuandu : gaodu;
        const float centerRatioX = oldScreenWidth > 1.0f ? oldCenterX / oldScreenWidth : 0.1f;
        const float centerRatioY = oldScreenHeight > 1.0f ? oldCenterY / oldScreenHeight : 0.1f;
        const float newCenterX = centerRatioX * newScreenWidth;
        const float newCenterY = centerRatioY * newScreenHeight;
        savedWindowPos = ImVec2(fmaxf(0.0f, newCenterX - targetWindowSize.x * 0.5f), fmaxf(0.0f, newCenterY - targetWindowSize.y * 0.5f));
        savedWindowSize = targetWindowSize;
    }

    lastLandscape = isLandscape;

    ImGui::SetNextWindowSize(targetWindowSize, ImGuiCond_Always);
    ImGui::SetNextWindowPos(savedWindowPos, ImGuiCond_Always);
    ImGui::SetNextWindowBgAlpha(0.82f);

    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.locale = [NSLocale localeWithLocaleIdentifier:@"zh_CN"];
    formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    NSString *title = [formatter stringFromDate:[NSDate date]];

    bool imguiWindowVisible = self.imguiVisible;
    ImGui::Begin(title.UTF8String, &imguiWindowVisible, KImGuiWindowFlags);
    self.imguiVisible = imguiWindowVisible;
    userDefaults[kImGuiMenuVisibleKey] = @(self.imguiVisible);

    self.noScreenShotView.hidden = NO;
    self.imguiHostView.hidden = NO;
    self.imguiTouchView.hidden = NO;
    self.imguiMTKView.hidden = NO;

    ImGui::Text("菜单状态");
    bool menuVisible = self.imguiVisible;
    if (ImGui::Checkbox("总开关", &menuVisible)) {
        self.imguiVisible = menuVisible;
        userDefaults[@"FGimguiEnabled"] = @(self.imguiVisible);
        userDefaults[kImGuiMenuVisibleKey] = @(self.imguiVisible);
    }

    ImGui::Separator();
    bool videoStreamHidden = self.hideInVideoStream;
    if (ImGui::Checkbox("视频流隐藏", &videoStreamHidden)) {
        self.hideInVideoStream = videoStreamHidden;
        userDefaults[@"FGhideVideo"] = @(self.hideInVideoStream);
    }

    ImGui::Separator();
    if (ImGui::Checkbox("方框", &绘制方框)) { userDefaults[@"FGbox"] = @(绘制方框); }
    if (ImGui::Checkbox("技能", &绘制技能)) { userDefaults[@"FGhp"] = @(绘制技能); }
    if (ImGui::Checkbox("野怪", &绘制野怪)) { userDefaults[@"FGmon"] = @(绘制野怪); }
    if (ImGui::Checkbox("头像", &绘制头像)) { userDefaults[@"TouXiang"] = @(绘制头像); }
    if (ImGui::Checkbox("射线", &绘制射线)) { userDefaults[@"SheXian"] = @(绘制射线); }

    ImGui::Spacing();
    ImGui::Text("小地图参数");
    if (ImGui::SliderFloat("MiniMap X", &MiniMap.x, 0.0f, 1000.0f)) { userDefaults[@"FGmapx"] = @(MiniMap.x); }
    if (ImGui::SliderFloat("MiniMap Y", &MiniMap.y, 0.0f, 1000.0f)) { userDefaults[@"FGmapy"] = @(MiniMap.y); }

    ImGui::Spacing();
    ImGui::Text("TIPA主页滑块");
    bool useCustomFontSize = [[userDefaults objectForKey:kUsesCustomFontSizeKey] boolValue];
    bool useCustomOffset = [[userDefaults objectForKey:kUsesCustomOffsetKey] boolValue];
    float customFontSize = [[userDefaults objectForKey:kRealCustomFontSizeKey] floatValue];
    float customOffsetX = [[userDefaults objectForKey:kRealCustomOffsetXKey] floatValue];
    float customOffsetY = [[userDefaults objectForKey:kRealCustomOffsetYKey] floatValue];

    if (ImGui::Checkbox("使用自定义字体大小", &useCustomFontSize)) {
        userDefaults[kUsesCustomFontSizeKey] = @(useCustomFontSize);
    }
    if (ImGui::SliderFloat("字体大小", &customFontSize, 8.0f, 12.0f, "%.1f")) {
        userDefaults[kRealCustomFontSizeKey] = @(customFontSize);
    }
    if (ImGui::Checkbox("使用自定义偏移", &useCustomOffset)) {
        userDefaults[kUsesCustomOffsetKey] = @(useCustomOffset);
    }
    if (ImGui::SliderFloat("偏移 X", &customOffsetX, -100.0f, 100.0f, "%.1f")) {
        userDefaults[kRealCustomOffsetXKey] = @(customOffsetX);
    }
    if (ImGui::SliderFloat("偏移 Y", &customOffsetY, -100.0f, 100.0f, "%.1f")) {
        userDefaults[kRealCustomOffsetYKey] = @(customOffsetY);
    }

    ImGui::Spacing();
    if (ImGui::Button("保存配置", ImVec2(-1, 32))) {
        [userDefaults writeToFile:USER_DEFAULTS_PATH atomically:YES];
    }
    userDefaults[@"FGimguiEnabled"] = @(self.imguiVisible);
    userDefaults[kImGuiMenuVisibleKey] = @(self.imguiVisible);

    ImGui::End();

    ImGuiIO &io = ImGui::GetIO();
    if (io.WantCaptureMouse || io.WantCaptureKeyboard) {
        savedWindowPos = ImGui::GetWindowPos();
        savedWindowSize = ImGui::GetWindowSize();
    }
}

-(void)huizhia{
   /// if(绘制总开关){
    ///
    if (!userDefaults) {
        userDefaults = [[NSDictionary dictionaryWithContentsOfFile:USER_DEFAULTS_PATH] mutableCopy] ?: [NSMutableDictionary dictionary];
    }

    for (int i=0; i<10; i++) {
        //移除过期的绘图
        [HeroImage[i] setHidden:YES];
        [SkillTable[i] setHidden:YES];
        HeroBloodRing[i].path = nil;
        [warningLabels[i] setHidden:YES];
        [HeroImage[i].layer removeAnimationForKey:@"flashingAnimation"];
    }
    

   // NSLog(@"地址X获取 %f 地图Y获取 %f",获取地图位置(),获取地图大小());
        GameCanvas.x = CGRectGetHeight(self.frame);
        GameCanvas.y = CGRectGetWidth(self.frame);
      
        
        Path_Rect = [[UIBezierPath alloc] init];  //分布画图空间
        Path_xueRect = [[UIBezierPath alloc] init];
        Path_xuebeijingRect = [[UIBezierPath alloc] init];
        for (int i=0; i<10; i++) {
            [HeroImage[i] setHidden:YES];
        }
    [Path_方框 appendPath:[UIBezierPath bezierPathWithRect:CGRectMake(MiniMap.x, 0, MiniMap.y, MiniMap.y)]];
    
        if(Gameinitialization()){//启动游戏
            SMOBA_NSLog(@"SMOBA-Apibug 启动游戏");
            //小地图地图切割弧度
            UIBezierPath* path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(MiniMap.x, 0, MiniMap.y, MiniMap.y)
                                                       byRoundingCorners:UIRectCornerBottomRight cornerRadii:CGSizeMake(30, 30)];//
            path.lineWidth     = 10.f;
            path.lineCapStyle  = kCGLineCapRound;
            [Path_Rect appendPath:path];

            userDefaults[@"FGmon"] = @(绘制野怪);
            userDefaults[@"FGbox"] = @(绘制方框);
            userDefaults[@"FGhp"] = @(绘制技能);
            userDefaults[@"TouXiang"] = @(绘制头像);
            userDefaults[@"SheXian"] = @(绘制射线);
            userDefaults[@"FGmapx"] = @(MiniMap.x);
            userDefaults[@"FGmapy"] = @(MiniMap.y);
            userDefaults[@"FGhideVideo"] = @(self.hideInVideoStream);

            if(RefreshMatrix()){//进入对局
                SMOBA_NSLog(@"SMOBA-Apibug 刷新矩阵");
                
                std::vector<SmobaHeroData> heroData;
                GetPlayers(&heroData);
                if (heroData.size() > 0)
                {
                    for (int i=0; i<heroData.size(); i++) {
                        Vector2 BoxPos;
                        if (!heroData[i].Dead)
                        {
                            if (ToScreen(GameCanvas,heroData[i].Pos,&BoxPos))
                            {
                                
                                //方框
                                if (绘制方框) {
                                    [Path_Rect appendPath:[UIBezierPath bezierPathWithRect:CGRectMake(BoxPos.x-20, BoxPos.y-48, 40, 48)]];
                                }
                                
                                
                                if (绘制射线) {
                                    UIBezierPath *bezierPath = [UIBezierPath bezierPath];
                                    [bezierPath moveToPoint:CGPointMake(gaodu/2, kuandu/2)];
                                    [bezierPath addLineToPoint:CGPointMake(BoxPos.x-20, BoxPos.y-48)];
                                    [Path_Rect appendPath:bezierPath];
                                }
                                
                                if (绘制技能)
                                {
                                    SkillTable[i].center = CGPointMake(BoxPos.x, BoxPos.y + 10);
                                    [SkillTable[i] setHidden:NO];
                                    NSLog(@"正在处理技能表[%d]", i);
                                    // 设置技能1
                                    if (heroData[i].Skill1) {
                                        NSLog(@"技能1有效: %@", heroData[i].Skill1);
                                        SkillTable[i].Skill1.backgroundColor = [UIColor orangeColor];
                                        UIImage *skillImage1 = GetHeroImage1(heroData[i].HeroID, heroData[i].Skill1);
                                        if (skillImage1) {
                                            UIImageView *skillImageView1 = [[UIImageView alloc] initWithImage:skillImage1];
                                            skillImageView1.frame = SkillTable[i].Skill1.bounds;
                                            [SkillTable[i].Skill1 addSubview:skillImageView1];
                                        } else {
                                            SkillTable[i].Skill1.backgroundColor = [UIColor colorWithWhite:0.4f alpha:1.f];
                                            [[SkillTable[i].Skill1 subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
                                        }
                                    } else {
                                        SkillTable[i].Skill1.backgroundColor = [UIColor colorWithWhite:0.4f alpha:1.f];
                                        [[SkillTable[i].Skill1 subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
                                    }

                                    // 设置技能2
                                    if (heroData[i].Skill2) {
                                        NSLog(@"技能2有效: %@", heroData[i].Skill1);
                                        SkillTable[i].Skill2.backgroundColor = [UIColor orangeColor];
                                        UIImage *skillImage2 = GetHeroImage1(heroData[i].HeroID, heroData[i].Skill2);
                                        if (skillImage2) {
                                            UIImageView *skillImageView2 = [[UIImageView alloc] initWithImage:skillImage2];
                                            skillImageView2.frame = SkillTable[i].Skill2.bounds;
                                            [SkillTable[i].Skill2 addSubview:skillImageView2];
                                        } else {
                                            SkillTable[i].Skill2.backgroundColor = [UIColor colorWithWhite:0.4f alpha:1.f];
                                            [[SkillTable[i].Skill2 subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
                                        }
                                    } else {
                                        SkillTable[i].Skill2.backgroundColor = [UIColor colorWithWhite:0.4f alpha:1.f];
                                        [[SkillTable[i].Skill2 subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
                                    }

                                    // 设置技能3
                                    if (heroData[i].Skill3) {
                                        NSLog(@"技能3有效: %@", heroData[i].Skill1);
                                        SkillTable[i].Skill3.backgroundColor = [UIColor orangeColor];
                                        UIImage *skillImage3 = GetHeroImage2(heroData[i].HeroID, heroData[i].Skill3);
                                        if (skillImage3) {
                                            UIImageView *skillImageView3 = [[UIImageView alloc] initWithImage:skillImage3];
                                            skillImageView3.frame = SkillTable[i].Skill3.bounds;
                                            [SkillTable[i].Skill3 addSubview:skillImageView3];
                                        } else {
                                            SkillTable[i].Skill3.backgroundColor = [UIColor colorWithWhite:0.4f alpha:1.f];
                                            [[SkillTable[i].Skill3 subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
                                        }
                                    } else {
                                        SkillTable[i].Skill3.backgroundColor = [UIColor colorWithWhite:0.4f alpha:1.f];
                                        [[SkillTable[i].Skill3 subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
                                    }

                                    // 设置技能4
                                    if (heroData[i].Skill4) {
                                        NSLog(@"技能4有效: %@", heroData[i].Skill1);
                                        SkillTable[i].Skill4.backgroundColor = [UIColor orangeColor];
                                        UIImage *skillImage4 = GetHeroImage3(heroData[i].HeroID, heroData[i].Skill4);
                                        if (skillImage4) {
                                            UIImageView *skillImageView4 = [[UIImageView alloc] initWithImage:skillImage4];
                                            skillImageView4.frame = SkillTable[i].Skill4.bounds;
                                            [SkillTable[i].Skill4 addSubview:skillImageView4];
                                        } else {
                                            SkillTable[i].Skill4.backgroundColor = [UIColor colorWithWhite:0.4f alpha:1.f];
                                            [[SkillTable[i].Skill4 subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
                                        }
                                    } else {
                                        SkillTable[i].Skill4.backgroundColor = [UIColor colorWithWhite:0.4f alpha:1.f];
                                        [[SkillTable[i].Skill4 subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
                                    }
                                }
                                
                                //透视
                                if (绘制头像)
                                {
                                    Vector2 MiniPos = ToMiniMap(MiniMap, heroData[i].Pos);
                                    float R=MiniMap.y/16;
                                    float labelSize = R * 2 * 0.5;
                                    warningLabels[i].frame = CGRectMake(0, 0, labelSize, labelSize);
                                    HeroImage[i].image = GetHeroImage(heroData[i].HeroID);
                                    [HeroImage[i] setHidden:NO];
                                    [HeroImage[i] setFrame:CGRectMake(MiniPos.x-R, MiniPos.y-R, R*2, R*2)];
                                    HeroImage[i].layer.cornerRadius = R;
                                    
                                    
                                    // 动态更新血量边框
                                    float bloodPercentage = heroData[i].HeroHP;
                                    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(MiniPos.x, MiniPos.y)
                                                                                        radius:R + 2 // 血条和英雄图像的距离
                                                                                    startAngle:-M_PI_2
                                                                                      endAngle:(-M_PI_2) + 2 * M_PI * bloodPercentage
                                                                                     clockwise:YES];
                                    HeroBloodRing[i].path = path.CGPath;
                                    
                                    
                                    // 检查英雄是否正在回城
                                    if (heroData[i].GoBack) {
                                        
                                        warningLabels[i].center = CGPointMake(MiniPos.x, MiniPos.y);
                                        warningLabels[i].hidden = NO;
                                        
                                        
                                        CABasicAnimation *flashAnimation = [CABasicAnimation animationWithKeyPath:@"borderColor"];
                                        flashAnimation.fromValue = (id)[UIColor blueColor].CGColor;
                                        flashAnimation.toValue = (id)[UIColor clearColor].CGColor;
                                        flashAnimation.duration = 0.5;
                                        flashAnimation.repeatCount = HUGE_VALF;
                                        flashAnimation.autoreverses = YES;
                                        
                                        [HeroImage[i].layer addAnimation:flashAnimation forKey:@"flashingAnimation"];
                                    } else {
                                        
                                        warningLabels[i].hidden = YES;
                                        
                                        
                                        [HeroImage[i].layer removeAnimationForKey:@"flashingAnimation"];
                                        HeroImage[i].layer.borderColor = [UIColor yellowColor].CGColor;
                                    }
                                    
                                    
                                }
                                
                            }
                            
                            
                        }
                        
                    }
                }
                
//                if (野怪) {
//                    Vector2 MonsterScreen;
//                    std::vector<SmobaMonsterData> 野怪数据;
//                    GetMonster(&野怪数据);
//                    NSLog(@"野怪数据=%ld",野怪数据.size());
//                    for (int i= 0; i < 野怪数据.size(); i++) {
//                        
//                        if (野怪数据[i].野怪当前血量 > 0) {
//                            if (ToScreen(GameCanvas, 野怪数据[i].MonsterPos, &MonsterScreen)) {
//                                Vector2 小地图;
//                                小地图.x = MiniMap.x;
//                                小地图.y = MiniMap.y;
//
//                                // 小地图野怪
//                                Vector2 MiniMonsterPos = ToMiniMap(小地图, 野怪数据[i].MonsterPos);
//
//                                // 使用 CAShapeLayer 绘制野怪背景
//                                UIBezierPath *backgroundPath = [UIBezierPath bezierPathWithArcCenter:CGPointMake(MiniMonsterPos.x, MiniMonsterPos.y)
//                                                                                              radius:4
//                                                                                          startAngle:0
//                                                                                            endAngle:2 * M_PI
//                                                                                           clockwise:YES];
//                                CAShapeLayer *backgroundLayer = [CAShapeLayer layer];
//                                backgroundLayer.path = backgroundPath.CGPath;
//                                backgroundLayer.fillColor = [UIColor blackColor].CGColor; // 黑色背景
//                                [self.layer addSublayer:backgroundLayer];
//
//                                // 根据血量绘制小地图血条
//                                float healthPercentage = 野怪数据[i].野怪当前血量 / 野怪数据[i].野怪最大血量;
//                                UIBezierPath *healthPath = [UIBezierPath bezierPathWithArcCenter:CGPointMake(MiniMonsterPos.x, MiniMonsterPos.y)
//                                                                                          radius:4
//                                                                                      startAngle:0
//                                                                                        endAngle:2 * M_PI * healthPercentage
//                                                                                       clockwise:YES];
//                                CAShapeLayer *healthLayer = [CAShapeLayer layer];
//                                healthLayer.path = healthPath.CGPath;
//                                healthLayer.fillColor = [UIColor redColor].CGColor; // 红色血条
//                                [self.layer addSublayer:healthLayer];
//
//                                // 大地图野怪
//                                CGRect monsterRect = CGRectMake(MonsterScreen.x - 20, MonsterScreen.y, 40, 10);
//                                CAShapeLayer *rectLayer = [CAShapeLayer layer];
//                                rectLayer.path = [UIBezierPath bezierPathWithRect:monsterRect].CGPath;
//                                rectLayer.strokeColor = [UIColor whiteColor].CGColor;  // 方框颜色
//                                rectLayer.fillColor = [UIColor clearColor].CGColor;
//                                [self.layer addSublayer:rectLayer];
//
//                                // 绘制大地图血条
//                                CGRect healthRect = CGRectMake(MonsterScreen.x - 20, MonsterScreen.y, 40 * healthPercentage, 10);
//                                CAShapeLayer *healthRectLayer = [CAShapeLayer layer];
//                                healthRectLayer.path = [UIBezierPath bezierPathWithRect:healthRect].CGPath;
//                                healthRectLayer.fillColor = [UIColor redColor].CGColor; // 血条颜色
//                                [self.layer addSublayer:healthRectLayer];
//
//                                // 添加野怪的方框
//                                CGRect monsterBorderRect = CGRectMake(MonsterScreen.x - 20, MonsterScreen.y - 50, 40, 60);  // 根据MsDrawList的AddRect的参数
//                                CAShapeLayer *monsterBorderLayer = [CAShapeLayer layer];
//                                monsterBorderLayer.path = [UIBezierPath bezierPathWithRect:monsterBorderRect].CGPath;
//                                monsterBorderLayer.strokeColor = [UIColor greenColor].CGColor;  // 自定义的方框颜色
//                                monsterBorderLayer.fillColor = [UIColor clearColor].CGColor;  // 只需要边框，无填充
//                                monsterBorderLayer.lineWidth = 2.0;  // 设置边框的线宽
//                                [self.layer addSublayer:monsterBorderLayer];
//                            }
//                        }
//                    }
//                    // 获取野怪倒计时数据
//                    std::vector<SmobaMonsterTime> 野怪倒计时数据;
//                    GetMonsterTime(&野怪倒计时数据);
//
//                    for (int i = 0; i < 野怪倒计时数据.size(); i++) {
//                        // 使用 MiniMap 赋值
//                        Vector2 小地图;
//                        小地图.x = MiniMap.x;  // 使用 MiniMap 的 X 坐标
//                        小地图.y = MiniMap.y;  // 使用 MiniMap 的 Y 坐标
//
//                        // 将野怪位置转换为小地图坐标
//                        Vector2 MiniMonsterPos = ToMiniMap(小地图, 野怪倒计时数据[i].MonsterPos);
//
//                        // 倒计时文字
//                        NSString *倒计时文字 = [NSString stringWithFormat:@"%d", (int)野怪倒计时数据[i].野怪倒计时];
//                        NSLog(@"读取野怪倒计时数据=%@ %f %f", 倒计时文字, MiniMonsterPos.x, MiniMonsterPos.y);
//
//                        // 在小地图上显示倒计时文字
//                        UILabel *monsterTimerLabel = [[UILabel alloc] initWithFrame:CGRectMake(MiniMonsterPos.x, MiniMonsterPos.y, 30, 20)];
//                        monsterTimerLabel.text = 倒计时文字;
//                        monsterTimerLabel.textColor = [UIColor redColor];  // 设置文字颜色
//                        monsterTimerLabel.font = [UIFont systemFontOfSize:15];  // 设置字体大小
//                        monsterTimerLabel.textAlignment = NSTextAlignmentCenter;  // 居中对齐
//
//                        [self addSubview:monsterTimerLabel];
//                    }
//
//                    }

                    
                }
                    }
                    
                    
            Draw_Rect.path = Path_Rect.CGPath;
           /// }
        }

#pragma mark 内存函数
static void NetGetHeroImage(int HeroID)
{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://game.gtimg.cn/images/yxzj/img201606/heroimg/%d/%d.jpg",HeroID,HeroID]];
    NSData *data = [NSData dataWithContentsOfURL:url];
    if (data.length < 1000)
    {
        for (int i=0; i<50; i++) {
            data = [NSData dataWithContentsOfURL:url];
            if (data.length > 1000) break;
        }
    }
    
    SaveImage Temp;
    Temp.HeroID = HeroID;
    Temp.Image = [UIImage imageWithData:data];
    NetImage.push_back(Temp);
}

static UIImage* GetHeroImage(int HeroID)
{
    for (int i=0;i<NetImage.size();i++)
    {
        if (NetImage[i].HeroID == HeroID) return NetImage[i].Image;
    }
    NetGetHeroImage(HeroID);
    return NetImage[NetImage.size()-1].Image;
}
static void NetGetHeroImage1(int HeroID,int skillID)
{
    NSLog(@"sbwmcq--heroid=%d ; skillid=%d",HeroID,skillID);
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://game.gtimg.cn/images/yxzj/img201606/heroimg/%d/%d.png",HeroID,skillID]];
    NSData *data = [NSData dataWithContentsOfURL:url];
    if (data.length < 1000)
    {
        for (int i=0; i<50; i++) {
            data = [NSData dataWithContentsOfURL:url];
            if (data.length > 1000) break;
        }
    }
    SaveImage Temp;
    Temp.HeroID = HeroID;
    Temp.Image = [UIImage imageWithData:data];
    NetImage1.push_back(Temp);
}
static UIImage* GetHeroImage1(int HeroID,int skillID)
{
    for (int i=0;i<NetImage1.size();i++)
    {if (NetImage1[i].HeroID == HeroID) return NetImage1[i].Image;}
    NetGetHeroImage1(HeroID,skillID);
    return NetImage1[NetImage1.size()-1].Image;
}
//技能2
static void NetGetHeroImage2(int HeroID,int skillID)
{
    NSLog(@"sbwmcq--heroid=%d ; skillid=%d",HeroID,skillID);
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://game.gtimg.cn/images/yxzj/img201606/heroimg/%d/%d.png",HeroID,skillID]];
    NSData *data = [NSData dataWithContentsOfURL:url];
    if (data.length < 1000)
    {
        for (int i=0; i<50; i++) {
            data = [NSData dataWithContentsOfURL:url];
            if (data.length > 1000) break;
        }
    }
    SaveImage Temp;
    Temp.HeroID = HeroID;
    Temp.Image = [UIImage imageWithData:data];
    NetImage2.push_back(Temp);
}
static UIImage* GetHeroImage2(int HeroID,int skillID)
{
    for (int i=0;i<NetImage2.size();i++)
    {if (NetImage2[i].HeroID == HeroID) return NetImage2[i].Image;}
    NetGetHeroImage2(HeroID,skillID);
    return NetImage2[NetImage2.size()-1].Image;
}
//技能3
static void NetGetHeroImage3(int HeroID,int skillID)
{
    NSLog(@"sbwmcq--heroid=%d ; skillid=%d",HeroID,skillID);
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://game.gtimg.cn/images/yxzj/img201606/heroimg/%d/%d.png",HeroID,skillID]];
    NSData *data = [NSData dataWithContentsOfURL:url];
    if (data.length < 1000)
    {
        for (int i=0; i<50; i++) {
            data = [NSData dataWithContentsOfURL:url];
            if (data.length > 1000) break;
        }
    }
    SaveImage Temp;
    Temp.HeroID = HeroID;
    Temp.Image = [UIImage imageWithData:data];
    NetImage3.push_back(Temp);
}
static UIImage* GetHeroImage3(int HeroID,int skillID)
{
    for (int i=0;i<NetImage3.size();i++)
    {if (NetImage3[i].HeroID == HeroID) return NetImage3[i].Image;}
    NetGetHeroImage3(HeroID,skillID);
    return NetImage3[NetImage3.size()-1].Image;
}


@end
