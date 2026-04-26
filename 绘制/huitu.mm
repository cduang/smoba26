//
//  PUBGDrawView.m
//  ChatsNinja
//
//  Created by yiming on 2022/10/2.
//
#import "imgui.h"
#import "imgui_internal.h"
#import "MsUAGameMenu.h"

#include "string"

#import "ImGuiMTKView.h"
#import "huitu.h"
#import "kuajinchengzuobiao.h"
#import "PUBGDataModel.h"
#import "image_base64.h"
#import "MsUIWindowIcon.h"
#include "ColorTool.hpp"
#import "YMUIWindow.h"
#import "WUZIView.h"

#define kWidth  [UIScreen mainScreen].bounds.size.width
#define kHeight [UIScreen mainScreen].bounds.size.height
#define kuandu  [UIScreen mainScreen].bounds.size.width
#define gaodu [UIScreen mainScreen].bounds.size.height

@interface huitu() <ImGuiMTKViewDelegate>
@property (nonatomic, strong) MTKView *mtkView;
@property (nonatomic, strong) ImGuiMTKView *renderer;
@property (nonatomic, assign) NSString *gameName;
@property (nonatomic, assign) pid_t gamePid;
@property (nonatomic, assign) mach_port_t gameTask;
@property (nonatomic, assign) uintptr_t gameBase;

@property (nonatomic, strong) NSArray *playerArray;
@property (nonatomic,  strong) NSArray *wuziArray;
@property (nonatomic,  strong) UILabel *numberLabel;
@property (nonatomic,  strong) UILabel *wenzi;
@property (nonatomic,  strong) CAShapeLayer *drawLayer;
@property (nonatomic,  strong) CAShapeLayer *drawLayer1;
@property (nonatomic,  strong) CAShapeLayer *drawLayer2;
@property (nonatomic,  strong) CAShapeLayer *drawLayer3;
@property (nonatomic,  strong) CAShapeLayer *drawLayer4;
@property (nonatomic,  strong) CAShapeLayer *drawLayer5;

@property (nonatomic,  strong) CAShapeLayer *drawLayer6;
@property (nonatomic, weak) NSTimer *timer;

@end

@implementation huitu
static huitu* view;

NSMutableDictionary *newActions;
static CATextLayer *tsLabel[100];
static CAShapeLayer *drawLayer[100];
static CAShapeLayer *drawLayer1[100];
static CAShapeLayer *drawLayer2[100];
static CAShapeLayer *drawLayer3[100];
static CAShapeLayer *drawLayer4[100];
static UIBezierPath *Path[100];

static CATextLayer *mzLabel[100];
static CATextLayer *po[100];
static CATextLayer *p[100];

CGSize ScreenSize;
static CATextLayer *m[100];
static CATextLayer *mm[100];
static CATextLayer *wuzi[100];
static CATextLayer *wuzijuli[100];
CGFloat xue;
CGFloat dis ;
using namespace std;

#pragma mark - 视图
-(void)addToWindws{
    [[YMUIWindow sharedInstance]addSubview:self];
    [YMUIWindow sharedInstance].hidden=NO;
    self.frame=[YMUIWindow sharedInstance].bounds;
    self.autoresizingMask= UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;//    [self show];
}
#pragma mark - 绘制函数
static void DrawLine(ImVec2 startPoint, ImVec2 endPoint, int color, float thicknes = 1)
{
    ImGui::GetOverlayDrawList()->AddLine(startPoint, endPoint, color, thicknes);
}

static void DrawText(string text, ImVec2 pos, bool isCentered, int color, bool outline, float fontSize)
{
    const char *str = text.c_str();
    ImVec2 vec2 = pos;
    
    if (isCentered) {
        ImFont* font = ImGui::GetFont();
        font->Scale = 20.f / font->FontSize;
        
        ImVec2 textSize = font->CalcTextSizeA(fontSize, MAXFLOAT, 0.0f, str);
        vec2.x -= textSize.x * 0.5f;
    }
    if (outline)
    {
        ImU32 outlineColor = 0xFF000000;
        ImGui::GetOverlayDrawList()->AddText(ImGui::GetFont(), fontSize, ImVec2(vec2.x + 1, vec2.y + 1), outlineColor, str);
        ImGui::GetOverlayDrawList()->AddText(ImGui::GetFont(), fontSize, ImVec2(vec2.x - 1, vec2.y - 1), outlineColor, str);
        ImGui::GetOverlayDrawList()->AddText(ImGui::GetFont(), fontSize, ImVec2(vec2.x + 1, vec2.y - 1), outlineColor, str);
        ImGui::GetOverlayDrawList()->AddText(ImGui::GetFont(), fontSize, ImVec2(vec2.x - 1, vec2.y + 1), outlineColor, str);
    }
    ImGui::GetOverlayDrawList()->AddText(ImGui::GetFont(), fontSize, vec2, color, str);
}
static void DrawText1(string text, ImVec2 pos, bool isCentered, int color, bool outline, float fontSize)
{
    const char *str = text.c_str();
    ImVec2 vec2 = pos;
    
    if (isCentered) {
        ImFont* font = ImGui::GetFont();
        font->Scale = 20.f / font->FontSize;
        
        ImVec2 textSize = font->CalcTextSizeA(fontSize, MAXFLOAT, 0.0f, str);
        vec2.x -= textSize.x * 0.5f;
    }
    if (outline)
    {
        ImU32 outlineColor = 0xFFFFFFFF;
        ImGui::GetOverlayDrawList()->AddText(ImGui::GetFont(), fontSize, ImVec2(vec2.x + 1, vec2.y + 1), outlineColor, str);
        ImGui::GetOverlayDrawList()->AddText(ImGui::GetFont(), fontSize, ImVec2(vec2.x - 1, vec2.y - 1), outlineColor, str);
        ImGui::GetOverlayDrawList()->AddText(ImGui::GetFont(), fontSize, ImVec2(vec2.x + 1, vec2.y - 1), outlineColor, str);
        ImGui::GetOverlayDrawList()->AddText(ImGui::GetFont(), fontSize, ImVec2(vec2.x - 1, vec2.y + 1), outlineColor, str);
    }
    ImGui::GetOverlayDrawList()->AddText(ImGui::GetFont(), fontSize, vec2, color, str);
}

static void DrawText2(string text, ImVec2 pos, bool isCentered, int color, bool outline, float fontSize)
{
    const char *str = text.c_str();
    ImVec2 vec2 = pos;
    
    if (isCentered) {
        ImFont* font = ImGui::GetFont();
        font->Scale = 20.f / font->FontSize;
        
        ImVec2 textSize = font->CalcTextSizeA(fontSize, MAXFLOAT, 0.0f, str);
        vec2.x -= textSize.x * 0.5f;
    }
    if (outline)
    {
        ImU32 outlineColor = 0xFF0000FF;
        ImGui::GetOverlayDrawList()->AddText(ImGui::GetFont(), fontSize, ImVec2(vec2.x + 1, vec2.y + 1), outlineColor, str);
        ImGui::GetOverlayDrawList()->AddText(ImGui::GetFont(), fontSize, ImVec2(vec2.x - 1, vec2.y - 1), outlineColor, str);
        ImGui::GetOverlayDrawList()->AddText(ImGui::GetFont(), fontSize, ImVec2(vec2.x + 1, vec2.y - 1), outlineColor, str);
        ImGui::GetOverlayDrawList()->AddText(ImGui::GetFont(), fontSize, ImVec2(vec2.x - 1, vec2.y + 1), outlineColor, str);
    }
    ImGui::GetOverlayDrawList()->AddText(ImGui::GetFont(), fontSize, vec2, color, str);
}
#pragma mark - 绘制结束
-(void)guanbi{
    self.hidden=YES;
    [YMUIWindow sharedInstance].hidden=YES;
//    [self removeFromSuperview];
}
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.userInteractionEnabled = NO;
        self.layer.allowsEdgeAntialiasing = YES;
        self.backgroundColor=[UIColor clearColor];
        //
        [self addSubview:self.numberLabel];
        [self.layer addSublayer:self.drawLayer];
        [self.layer addSublayer:self.drawLayer1];
        [self.layer addSublayer:self.drawLayer2];
        [self.layer addSublayer:self.drawLayer3];
        [self.layer addSublayer:self.drawLayer4];
        [self.layer addSublayer:self.drawLayer5];
        [self.layer addSublayer:self.drawLayer6];
        
        [self setupUI];
        
        self.gameName = @"";
        self.gamePid = -1;
        self.gameTask = 0;
        self.gameBase = 0;

    }
    return self;
}
- (void)setupUI
{//
    
    self.mtkView = [[MTKView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.mtkView.backgroundColor = [UIColor clearColor];
    [self addSubview:self.mtkView];
    
    self.mtkView.device = MTLCreateSystemDefaultDevice();
    if (!self.mtkView.device) return;
    
    self.renderer = [[ImGuiMTKView alloc] initWithView:self.mtkView];
    self.renderer.delegate = self;
    self.mtkView.delegate = self.renderer;
    
    [self.renderer initializePlatform];
    
}

- (void)layoutSubviews
{
    [super layoutSubviews];
}

#pragma mark - 事件

- (void)show
{
    _gameName = @"ShadowTrackerExt";
    _gamePid = [[kuajinchengzuobiao factory] getProcesses:_gameName];
    
    NSLog(@"Pid%d",_gamePid);
    NSLog(@"Task%u",_gameTask);
    if (_gamePid != -1) {
        _gameTask = [[kuajinchengzuobiao factory] getTask:_gamePid];
        if (_gameTask) {
            _gameBase = [[kuajinchengzuobiao factory] getBaseAddress:_gameTask];
            if (_gameBase) {
                NSLog(@"[yiming] %s: 获取游戏进程成功！", __func__);
                //                self.hidden = NO;
                //                self.timer.fireDate = [NSDate distantPast];
            }
        }
    } else {
        NSLog(@"[yiming] %s: 获取游戏进程失败！", __func__);
    }
}

- (void)hide
{
    self.hidden = YES;
}

- (void)doTheJob
{
    GameInfo gameinfo;
    gameinfo.name = _gameName;
    gameinfo.pid  = _gamePid;
    gameinfo.task = _gameTask;
    gameinfo.base = _gameBase;
    if(_gamePid==-1 && !_gameBase) return;//判断游戏进程存在 并且正常获取地址才执行读取内存数据
    [[kuajinchengzuobiao factory] fetchData:gameinfo block:^(NSArray * _Nonnull playerArray) {
        [self configWithData:playerArray];
    }];
}

- (void)configWithData:(NSArray *)playerArray
{
    _playerArray = playerArray;
    // 物资数据
    NSArray *wuzi = [_playerArray filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(PUBGPlayerModel *model, NSDictionary<NSString *,id> * _Nullable bindings) {
        if (model.flag > 1) {
            return YES;
        }
        return NO;
    }]];
    _wuziArray = wuzi;
    
    // 其他数据
    if (wuzi.count > 0) {
        NSMutableArray *marr = [NSMutableArray arrayWithArray:playerArray];
        [marr removeObjectsInArray:wuzi];
        _playerArray = marr;
    }
    
    // 人物
    if (_playerArray.count == 0) {
        [_playerArray enumerateObjectsUsingBlock:^(UIView *obj, NSUInteger idx, BOOL * _Nonnull stop) {
            obj.hidden = YES;
        }];
    }
    
    // 物资
    if (_wuziArray.count == 0) {
        
    }
    //人物数量
    if (_playerArray.count == 0) {
        char* ii = (char*) [[NSString stringWithFormat:@"安全"] cStringUsingEncoding:NSUTF8StringEncoding];
        DrawText1(ii, ImVec2(kWidth/2, 30), true, Colour_红色, true, 30);
    }else{
        char* ii = (char*) [[NSString stringWithFormat:@"%d",(int)_playerArray.count] cStringUsingEncoding:NSUTF8StringEncoding];
        DrawText1(ii, ImVec2(kWidth/2, 30), true, Colour_红色, true, 30);
    }
    [self drawAction];
}

- (void)drawAction
{
    
    for (NSInteger i = 0; i < _playerArray.count; i++) {
        PUBGPlayerModel *model = _playerArray[i];
        
        float xd = model.rect.origin.x;//人物X坐标
        float yd = model.rect.origin.y;//人物Y坐标
        CGFloat w = model.rect.size.width;
        CGFloat h = model.rect.size.height;
        CGFloat x = model.rect.origin.x;
        CGFloat y = model.rect.origin.y;
        if(xd>kWidth||yd>kHeight){
            if(射线开关){
                DrawLine(ImVec2(self.bounds.size.width/2, 20), ImVec2(xd+5, model.rect.origin.y),0xFFFFFFFF);
            }
        }else{
            if(射线开关){
                if(model.isAI==1){
                    DrawLine(ImVec2(self.bounds.size.width/2, 20), ImVec2(xd+5, model.rect.origin.y),0xFFFFFFFF);
                }else{
                    if ((int)model.Distance<20) {
                        DrawLine(ImVec2(self.bounds.size.width/2, 20), ImVec2(xd+5, model.rect.origin.y),Colour_粉红,0.5);
                    }
                    else if((int)model.Distance>20 && (int)model.Distance<80){
                        //射线
                        DrawLine(ImVec2(self.bounds.size.width/2, 20), ImVec2(xd+5, model.rect.origin.y),Colour_橙黄,0.5);
                    }
                    else if((int)model.Distance>80 && (int)model.Distance<160){
                        //射线
                        DrawLine(ImVec2(self.bounds.size.width/2, 20), ImVec2(xd+5, model.rect.origin.y),Colour_碧绿,0.5);
                    }
                    else if((int)model.Distance>160 && (int)model.Distance<250){
                        //射线
                        DrawLine(ImVec2(self.bounds.size.width/2, 20), ImVec2(xd+5, model.rect.origin.y),Colour_珊瑚红,0.5);
                    }
                    else if((int)model.Distance>250 && (int)model.Distance<400){
                        //射线
                        DrawLine(ImVec2(self.bounds.size.width/2, 20), ImVec2(xd+5, model.rect.origin.y),Colour_橙色,0.5);
                    }
                }
            }
            
            if(血量开关){
                float dw = 73;
                float lineHeight = 1.8;
                float spaceHeight = 1.0;
                float rectHeight = lineHeight * 2 + spaceHeight;
                float dx = x + w * 0.5 - dw * 0.5;
                float dy = y - rectHeight * 2;
                float HealthRatio = model.Health;
                float percent = dw * HealthRatio;
                //敌人血量
                if(model.isAI==1){
                    DrawLine(ImVec2(dx, dy+lineHeight), ImVec2(dx+percent, dy+lineHeight), Colour_绿色, lineHeight);
                }else{
                    DrawLine(ImVec2(dx, dy+lineHeight), ImVec2(dx+percent, dy+lineHeight), Colour_红色, lineHeight);
                }
                //名字背景
                if(model.TeamID==1){
                    ImGui::GetOverlayDrawList()->AddQuadFilled(ImVec2(dx, dy+1.5), ImVec2(dx+6, dy-10.5),ImVec2(dx+24, dy-10.5),ImVec2(dx+18, dy+1.5),0xFFDC143C);
                    ImGui::GetBackgroundDrawList()-> AddQuadFilled(ImVec2(dx+19, dy+1.5), ImVec2(dx+25, dy-10.5),ImVec2(dx+80, dy-10.5),ImVec2(dx+74, dy+1.5),0xCCDC143C);//信息
                }
                if(model.TeamID==2){
                    ImGui::GetOverlayDrawList()->AddQuadFilled(ImVec2(dx, dy+1.5), ImVec2(dx+6, dy-10.5),ImVec2(dx+24, dy-10.5),ImVec2(dx+18, dy+1.5),0xFF3C14DC);
                    ImGui::GetBackgroundDrawList()-> AddQuadFilled(ImVec2(dx+19, dy+1.5), ImVec2(dx+25, dy-10.5),ImVec2(dx+80, dy-10.5),ImVec2(dx+74, dy+1.5),0xCC3C14DC);//信息
                }
                if(model.TeamID==3){
                    ImGui::GetOverlayDrawList()->AddQuadFilled(ImVec2(dx, dy+1.5), ImVec2(dx+6, dy-10.5),ImVec2(dx+24, dy-10.5),ImVec2(dx+18, dy+1.5),0xFF8ace87);
                    ImGui::GetBackgroundDrawList()-> AddQuadFilled(ImVec2(dx+19, dy+1.5), ImVec2(dx+25, dy-10.5),ImVec2(dx+80, dy-10.5),ImVec2(dx+74, dy+1.5),0xCC8ace87);//信息
                }
                if(model.TeamID==4){
                    ImGui::GetOverlayDrawList()->AddQuadFilled(ImVec2(dx, dy+1.5), ImVec2(dx+6, dy-10.5),ImVec2(dx+24, dy-10.5),ImVec2(dx+18, dy+1.5),0xFFFACE87);
                    ImGui::GetBackgroundDrawList()-> AddQuadFilled(ImVec2(dx+19, dy+1.5), ImVec2(dx+25, dy-10.5),ImVec2(dx+80, dy-10.5),ImVec2(dx+74, dy+1.5),0xCCFACE87);//信息
                }
                if(model.TeamID==5){
                    ImGui::GetOverlayDrawList()->AddQuadFilled(ImVec2(dx, dy+1.5), ImVec2(dx+6, dy-10.5),ImVec2(dx+24, dy-10.5),ImVec2(dx+18, dy+1.5),0xFF9AFA00);
                    ImGui::GetBackgroundDrawList()-> AddQuadFilled(ImVec2(dx+19, dy+1.5), ImVec2(dx+25, dy-10.5),ImVec2(dx+80, dy-10.5),ImVec2(dx+74, dy+1.5),0xCC9AFA00);//信息
                }
                if(model.TeamID==6){
                    ImGui::GetOverlayDrawList()->AddQuadFilled(ImVec2(dx, dy+1.5), ImVec2(dx+6, dy-10.5),ImVec2(dx+24, dy-10.5),ImVec2(dx+18, dy+1.5),0xFF999933);
                    ImGui::GetBackgroundDrawList()-> AddQuadFilled(ImVec2(dx+19, dy+1.5), ImVec2(dx+25, dy-10.5),ImVec2(dx+80, dy-10.5),ImVec2(dx+74, dy+1.5),0xCC999933);//信息
                }
                if(model.TeamID==7){
                    ImGui::GetOverlayDrawList()->AddQuadFilled(ImVec2(dx, dy+1.5), ImVec2(dx+6, dy-10.5),ImVec2(dx+24, dy-10.5),ImVec2(dx+18, dy+1.5),0xFF00ff00);
                    ImGui::GetBackgroundDrawList()-> AddQuadFilled(ImVec2(dx+19, dy+1.5), ImVec2(dx+25, dy-10.5),ImVec2(dx+80, dy-10.5),ImVec2(dx+74, dy+1.5),0xCC00ff00);//信息
                }
                if(model.TeamID==8){
                    ImGui::GetOverlayDrawList()->AddQuadFilled(ImVec2(dx, dy+1.5), ImVec2(dx+6, dy-10.5),ImVec2(dx+24, dy-10.5),ImVec2(dx+18, dy+1.5),0xFF998833);
                    ImGui::GetBackgroundDrawList()-> AddQuadFilled(ImVec2(dx+19, dy+1.5), ImVec2(dx+25, dy-10.5),ImVec2(dx+80, dy-10.5),ImVec2(dx+74, dy+1.5),0xCC998833);//信息
                }
                if(model.TeamID==9){
                    ImGui::GetOverlayDrawList()->AddQuadFilled(ImVec2(dx, dy+1.5), ImVec2(dx+6, dy-10.5),ImVec2(dx+24, dy-10.5),ImVec2(dx+18, dy+1.5),0xFF709933);
                    ImGui::GetBackgroundDrawList()-> AddQuadFilled(ImVec2(dx+19, dy+1.5), ImVec2(dx+25, dy-10.5),ImVec2(dx+80, dy-10.5),ImVec2(dx+74, dy+1.5),0xCC709933);//信息
                }
                if(model.TeamID==10){
                    ImGui::GetOverlayDrawList()->AddQuadFilled(ImVec2(dx, dy+1.5), ImVec2(dx+6, dy-10.5),ImVec2(dx+24, dy-10.5),ImVec2(dx+18, dy+1.5),0xFF70FFCC);
                    ImGui::GetBackgroundDrawList()-> AddQuadFilled(ImVec2(dx+19, dy+1.5), ImVec2(dx+25, dy-10.5),ImVec2(dx+80, dy-10.5),ImVec2(dx+74, dy+1.5),0xCC70FFCC);//信息
                }
                if(model.TeamID==11){
                    ImGui::GetOverlayDrawList()->AddQuadFilled(ImVec2(dx, dy+1.5), ImVec2(dx+6, dy-10.5),ImVec2(dx+24, dy-10.5),ImVec2(dx+18, dy+1.5),0xFF8FFCCC);
                    ImGui::GetBackgroundDrawList()-> AddQuadFilled(ImVec2(dx+19, dy+1.5), ImVec2(dx+25, dy-10.5),ImVec2(dx+80, dy-10.5),ImVec2(dx+74, dy+1.5),0xCC8FFCCC);//信息
                }
                if(model.TeamID==12){
                    ImGui::GetOverlayDrawList()->AddQuadFilled(ImVec2(dx, dy+1.5), ImVec2(dx+6, dy-10.5),ImVec2(dx+24, dy-10.5),ImVec2(dx+18, dy+1.5),0xFF9999CC);
                    ImGui::GetBackgroundDrawList()-> AddQuadFilled(ImVec2(dx+19, dy+1.5), ImVec2(dx+25, dy-10.5),ImVec2(dx+80, dy-10.5),ImVec2(dx+74, dy+1.5),0xCC9999CC);//信息
                }
                if(model.TeamID==13){
                    ImGui::GetOverlayDrawList()->AddQuadFilled(ImVec2(dx, dy+1.5), ImVec2(dx+6, dy-10.5),ImVec2(dx+24, dy-10.5),ImVec2(dx+18, dy+1.5),0xFF9c5bef);
                    ImGui::GetBackgroundDrawList()-> AddQuadFilled(ImVec2(dx+19, dy+1.5), ImVec2(dx+25, dy-10.5),ImVec2(dx+80, dy-10.5),ImVec2(dx+74, dy+1.5),0xCC9c5bef);//信息
                }
                if(model.TeamID==14){
                    ImGui::GetOverlayDrawList()->AddQuadFilled(ImVec2(dx, dy+1.5), ImVec2(dx+6, dy-10.5),ImVec2(dx+24, dy-10.5),ImVec2(dx+18, dy+1.5),0xFFbcaefc);
                    ImGui::GetBackgroundDrawList()-> AddQuadFilled(ImVec2(dx+19, dy+1.5), ImVec2(dx+25, dy-10.5),ImVec2(dx+80, dy-10.5),ImVec2(dx+74, dy+1.5),0xCCbcaefc);//信息
                }
                if(model.TeamID==15){
                    ImGui::GetOverlayDrawList()->AddQuadFilled(ImVec2(dx, dy+1.5), ImVec2(dx+6, dy-10.5),ImVec2(dx+24, dy-10.5),ImVec2(dx+18, dy+1.5),0xFF62cfa3);
                    ImGui::GetBackgroundDrawList()-> AddQuadFilled(ImVec2(dx+19, dy+1.5), ImVec2(dx+25, dy-10.5),ImVec2(dx+80, dy-10.5),ImVec2(dx+74, dy+1.5),0xCC62cfa3);//信息
                }
                if(model.TeamID==16){
                    ImGui::GetOverlayDrawList()->AddQuadFilled(ImVec2(dx, dy+1.5), ImVec2(dx+6, dy-10.5),ImVec2(dx+24, dy-10.5),ImVec2(dx+18, dy+1.5),0xFFecd790);
                    ImGui::GetBackgroundDrawList()-> AddQuadFilled(ImVec2(dx+19, dy+1.5), ImVec2(dx+25, dy-10.5),ImVec2(dx+80, dy-10.5),ImVec2(dx+74, dy+1.5),0xCCecd790);//信息
                }
                if(model.TeamID==17){
                    ImGui::GetOverlayDrawList()->AddQuadFilled(ImVec2(dx, dy+1.5), ImVec2(dx+6, dy-10.5),ImVec2(dx+24, dy-10.5),ImVec2(dx+18, dy+1.5),0xFF2082f5);
                    ImGui::GetBackgroundDrawList()-> AddQuadFilled(ImVec2(dx+19, dy+1.5), ImVec2(dx+25, dy-10.5),ImVec2(dx+80, dy-10.5),ImVec2(dx+74, dy+1.5),0xCC2082f5);//信息
                }
                if(model.TeamID==18){
                    ImGui::GetOverlayDrawList()->AddQuadFilled(ImVec2(dx, dy+1.5), ImVec2(dx+6, dy-10.5),ImVec2(dx+24, dy-10.5),ImVec2(dx+18, dy+1.5),0xFF225af1);
                    ImGui::GetBackgroundDrawList()-> AddQuadFilled(ImVec2(dx+19, dy+1.5), ImVec2(dx+25, dy-10.5),ImVec2(dx+80, dy-10.5),ImVec2(dx+74, dy+1.5),0xCC225af1);//信息
                }
                if(model.TeamID==19){
                    ImGui::GetOverlayDrawList()->AddQuadFilled(ImVec2(dx, dy+1.5), ImVec2(dx+6, dy-10.5),ImVec2(dx+24, dy-10.5),ImVec2(dx+18, dy+1.5),0xFFab82ff);
                    ImGui::GetBackgroundDrawList()-> AddQuadFilled(ImVec2(dx+19, dy+1.5), ImVec2(dx+25, dy-10.5),ImVec2(dx+80, dy-10.5),ImVec2(dx+74, dy+1.5),0xCCab82ff);//信息
                }
                if(model.TeamID==20){
                    ImGui::GetOverlayDrawList()->AddQuadFilled(ImVec2(dx, dy+1.5), ImVec2(dx+6, dy-10.5),ImVec2(dx+24, dy-10.5),ImVec2(dx+18, dy+1.5),0xFF9ead00);
                    ImGui::GetBackgroundDrawList()-> AddQuadFilled(ImVec2(dx+19, dy+1.5), ImVec2(dx+25, dy-10.5),ImVec2(dx+80, dy-10.5),ImVec2(dx+74, dy+1.5),0xCC9ead00);//信息
                }
                if(model.TeamID==21){
                    ImGui::GetOverlayDrawList()->AddQuadFilled(ImVec2(dx, dy+1.5), ImVec2(dx+6, dy-10.5),ImVec2(dx+24, dy-10.5),ImVec2(dx+18, dy+1.5),0xFFd69a00);
                    ImGui::GetBackgroundDrawList()-> AddQuadFilled(ImVec2(dx+19, dy+1.5), ImVec2(dx+25, dy-10.5),ImVec2(dx+80, dy-10.5),ImVec2(dx+74, dy+1.5),0xCCd69a00);//信息
                }
                if(model.TeamID==22){
                    ImGui::GetOverlayDrawList()->AddQuadFilled(ImVec2(dx, dy+1.5), ImVec2(dx+6, dy-10.5),ImVec2(dx+24, dy-10.5),ImVec2(dx+18, dy+1.5),0xFFd69a00);
                    ImGui::GetBackgroundDrawList()-> AddQuadFilled(ImVec2(dx+19, dy+1.5), ImVec2(dx+25, dy-10.5),ImVec2(dx+80, dy-10.5),ImVec2(dx+74, dy+1.5),0xCCd69a00);//信息
                }
                if(model.TeamID==23){
                    ImGui::GetOverlayDrawList()->AddQuadFilled(ImVec2(dx, dy+1.5), ImVec2(dx+6, dy-10.5),ImVec2(dx+24, dy-10.5),ImVec2(dx+18, dy+1.5),0xFF7cb945);
                    ImGui::GetBackgroundDrawList()-> AddQuadFilled(ImVec2(dx+19, dy+1.5), ImVec2(dx+25, dy-10.5),ImVec2(dx+80, dy-10.5),ImVec2(dx+74, dy+1.5),0xCC7cb945);//信息
                }
                if(model.TeamID==24){
                    ImGui::GetOverlayDrawList()->AddQuadFilled(ImVec2(dx, dy+1.5), ImVec2(dx+6, dy-10.5),ImVec2(dx+24, dy-10.5),ImVec2(dx+18, dy+1.5),0xFF546c00);
                    ImGui::GetBackgroundDrawList()-> AddQuadFilled(ImVec2(dx+19, dy+1.5), ImVec2(dx+25, dy-10.5),ImVec2(dx+80, dy-10.5),ImVec2(dx+74, dy+1.5),0xCC546c00);//信息
                }
                if(model.TeamID==25){
                    ImGui::GetOverlayDrawList()->AddQuadFilled(ImVec2(dx, dy+1.5), ImVec2(dx+6, dy-10.5),ImVec2(dx+24, dy-10.5),ImVec2(dx+18, dy+1.5),0xFFff3377);
                    ImGui::GetBackgroundDrawList()-> AddQuadFilled(ImVec2(dx+19, dy+1.5), ImVec2(dx+25, dy-10.5),ImVec2(dx+80, dy-10.5),ImVec2(dx+74, dy+1.5),0xCCff3377);//信息
                }
                if(model.TeamID==26){
                    ImGui::GetOverlayDrawList()->AddQuadFilled(ImVec2(dx, dy+1.5), ImVec2(dx+6, dy-10.5),ImVec2(dx+24, dy-10.5),ImVec2(dx+18, dy+1.5),0xFF9afa00);
                    ImGui::GetBackgroundDrawList()-> AddQuadFilled(ImVec2(dx+19, dy+1.5), ImVec2(dx+25, dy-10.5),ImVec2(dx+80, dy-10.5),ImVec2(dx+74, dy+1.5),0xCC9afa00);//信息
                }

            }
            
            if (信息开关) {
                float dw = 73;
                float lineHeight = 1.8;
                float spaceHeight = 1.0;
                float rectHeight = lineHeight * 2 + spaceHeight;
                float dx = x + w * 0.5 - dw * 0.5;
                float dy = y - rectHeight * 2;
                
                if (model.Health==0){
                    //敌人倒地
                    char* ii = (char*) [[NSString stringWithFormat:@"倒地"]
                                        cStringUsingEncoding:NSUTF8StringEncoding];
                    DrawText(ii, ImVec2(dx+40, dy+手持y), true, Colour_白色, true, 9);
                }

                
                if(信息开关){
                    //队伍分辨
                    char* ii = (char*) [[NSString stringWithFormat:@"%d",(int)model.TeamID] cStringUsingEncoding:NSUTF8StringEncoding];
                    if(model.isAI==1){
                        DrawText(ii, ImVec2(dx+12 , dy-9), true, Colour_白色, true, 9);
                    }else{
                        DrawText(ii, ImVec2(dx+12 , dy-9), true, Colour_纯黄, true, 9);
                    }
                }
                //敌人名字
                char* ii = (char*) [[NSString stringWithFormat:@"%@",model.PlayerName] cStringUsingEncoding:NSUTF8StringEncoding];
                //判断人机
                if(model.isAI==1){
                    char* ii = (char*) [[NSString stringWithFormat:@"人机"] cStringUsingEncoding:NSUTF8StringEncoding];
                    DrawText(ii, ImVec2(dx+47 , dy-8), true, Colour_白色, true, 8);
                }else{
                    DrawText(ii, ImVec2(dx+47 , dy-8), true, Colour_纯黄, true, 8);
                }
                if(信息开关){
                    //敌人距离
                    char* ii = (char*) [[NSString stringWithFormat:@"%dm",(int)model.Distance] cStringUsingEncoding:NSUTF8StringEncoding];
                    //判断人机
                    if(model.isAI==1){
                        DrawText(ii, ImVec2(dx+40, dy-18), true, Colour_白色, true, 9);
                    }else{
                        DrawText(ii, ImVec2(dx+40, dy-18), true, Colour_纯黄, true, 9);
                    }
                }
            }
            
            if(方框开关){
                if(model.isAI==1){
                    DrawLine(ImVec2(x, y), ImVec2(x-w/2,y), Colour_绿色,1);
                    DrawLine(ImVec2(x-w/2, y), ImVec2(x-w/2, y+h/4), Colour_绿色,1);
                    //右上角
                    DrawLine(ImVec2(x+w*0.75, y), ImVec2(x+w*1.25, y), Colour_绿色,1);
                    DrawLine(ImVec2(x+w*1.25, y), ImVec2(x+w*1.25, y+h/4), Colour_绿色,1);
                    //左下角
                    DrawLine(ImVec2(x, y+h+4), ImVec2(x-w/2,y+h+4), Colour_绿色,1);
                    DrawLine(ImVec2(x-w/2, y+h+4), ImVec2(x-w/2, y+(h+4)*0.75), Colour_绿色,1);
                    //右下角
                    DrawLine(ImVec2(x+w*0.75, y+h+4), ImVec2(x+w*1.25, y+h+4), Colour_绿色,1);
                    DrawLine(ImVec2(x+w*1.25, y+h+4), ImVec2(x+w*1.25, y+(h+4)*0.75), Colour_绿色,1);
                }else{
                    DrawLine(ImVec2(x, y), ImVec2(x-w/2,y), Colour_红色,1);
                    DrawLine(ImVec2(x-w/2, y), ImVec2(x-w/2, y+h/4), Colour_红色,1);
                    //右上角
                    DrawLine(ImVec2(x+w*0.75, y), ImVec2(x+w*1.25, y), Colour_红色,1);
                    DrawLine(ImVec2(x+w*1.25, y), ImVec2(x+w*1.25, y+h/4), Colour_红色,1);
                    //左下角
                    DrawLine(ImVec2(x, y+h+4), ImVec2(x-w/2,y+h+4), Colour_红色,1);
                    DrawLine(ImVec2(x-w/2, y+h+4), ImVec2(x-w/2, y+(h+4)*0.75), Colour_红色,1);
                    //右下角
                    DrawLine(ImVec2(x+w*0.75, y+h+4), ImVec2(x+w*1.25, y+h+4), Colour_红色,1);
                    DrawLine(ImVec2(x+w*1.25, y+h+4), ImVec2(x+w*1.25, y+(h+4)*0.75), Colour_红色,1);
                }
            }
            if(骨骼开关){
                
                DrawLine(ImVec2(model.bone._0.X, model.bone._0.Y), ImVec2(model.bone._1.X, model.bone._1.Y),0xFFFFFFFF);//头到脖子
                DrawLine(ImVec2(model.bone._1.X, model.bone._1.Y), ImVec2(model.bone._2.X, model.bone._2.Y),0xFFFFFFFF);//脖子到胸
                DrawLine(ImVec2(model.bone._2.X, model.bone._2.Y), ImVec2(model.bone._3.X, model.bone._3.Y),0xFFFFFFFF);//胸到腰
                DrawLine(ImVec2(model.bone._3.X, model.bone._3.Y), ImVec2(model.bone._4.X, model.bone._4.Y),0xFFFFFFFF);//腰到脊柱
                DrawLine(ImVec2(model.bone._4.X, model.bone._4.Y), ImVec2(model.bone._5.X, model.bone._5.Y),0xFFFFFFFF);//脊柱到盆骨
                
                
                DrawLine(ImVec2(model.bone._2.X, model.bone._2.Y), ImVec2(model.bone._3.X, model.bone._3.Y),0xFFFFFFFF);//胸-左肩膀
                DrawLine(ImVec2(model.bone._3.X, model.bone._3.Y), ImVec2(model.bone._4.X, model.bone._4.Y),0xFFFFFFFF);//左肩膀-左肘
                DrawLine(ImVec2(model.bone._4.X, model.bone._4.Y), ImVec2(model.bone._5.X, model.bone._5.Y),0xFFFFFFFF);//左肘-左手
                
                DrawLine(ImVec2(model.bone._2.X, model.bone._2.Y), ImVec2(model.bone._6.X, model.bone._6.Y),0xFFFFFFFF);//胸-右肩膀
                DrawLine(ImVec2(model.bone._6.X, model.bone._6.Y), ImVec2(model.bone._7.X, model.bone._7.Y),0xFFFFFFFF);//有肩膀-右肘
                DrawLine(ImVec2(model.bone._7.X, model.bone._7.Y), ImVec2(model.bone._8.X, model.bone._8.Y),0xFFFFFFFF);//右肘-右手
                
                DrawLine(ImVec2(model.bone._2.X, model.bone._2.Y), ImVec2(model.bone._9.X, model.bone._9.Y),0xFFFFFFFF);//盆骨-左盆骨
                DrawLine(ImVec2(model.bone._9.X, model.bone._9.Y), ImVec2(model.bone._10.X, model.bone._10.Y),0xFFFFFFFF);//左盆骨-左膝盖
                DrawLine(ImVec2(model.bone._10.X, model.bone._10.Y), ImVec2(model.bone._11.X, model.bone._1.Y),0xFFFFFFFF);//左膝盖-左脚
                
                DrawLine(ImVec2(model.bone._5.X, model.bone._5.Y), ImVec2(model.bone._13.X, model.bone._13.Y),0xFFFFFFFF);//盆骨-左盆骨
                DrawLine(ImVec2(model.bone._13.X, model.bone._13.Y), ImVec2(model.bone._14.X, model.bone._14.Y),0xFFFFFFFF);//左盆骨-左膝盖
                DrawLine(ImVec2(model.bone._14.X, model.bone._14.Y), ImVec2(model.bone._15.X, model.bone._15.Y),0xFFFFFFFF);//左膝盖-左脚
                
                DrawLine(ImVec2(model.bone._5.X, model.bone._5.Y), ImVec2(model.bone._15.X, model.bone._15.Y),0xFFFFFFFF);//盆骨-右盆骨
                DrawLine(ImVec2(model.bone._15.X, model.bone._15.Y), ImVec2(model.bone._16.X, model.bone._16.Y),0xFFFFFFFF);//右盆骨-右膝盖
                DrawLine(ImVec2(model.bone._16.X, model.bone._16.Y), ImVec2(model.bone._17.X, model.bone._17.Y),0xFFFFFFFF);//右膝盖-右脚
                
                
                
            }
            NSString *namea = @"";
            switch (model.chiqiang) {
                case 0: {
                    namea = @"拳头";
                    //     ImGui::GetOverlayDrawList()->AddImage((__bridge ImTextureID) UMP9Texture, ImVec2(dx-25 - scWidth+1, dy+50- scHeight+1), ImVec2(dx-25 - scWidth+1  , dy+50- scHeight+1 ), ImVec2(0.0f, 0.0f), ImVec2(1.0f, 1.0f));
                    break;
                }
                case 101001: {
                    namea = @"AKM";
                    break;
                }
                case 101002: {
                    namea = @"M16A-4";
                    //    ImGui::GetOverlayDrawList()->AddImage((__bridge ImTextureID) countTexture, ImVec2(dx-25 - scWidth+1, dy-50- scHeight+1), ImVec2(dx-25 - scWidth+1  , dy-50- scHeight+1 ), ImVec2(0.0f, 0.0f), ImVec2(1.0f, 1.0f));
                    break;
                }
                case 101003: {
                    namea = @"SCAR-L";
                    
                    break;
                }
                case 101004: {
                    namea = @"M416";
                    //   ImGui::GetOverlayDrawList()->AddImage((__bridge ImTextureID) countTexture, ImVec2(dx-160 - scWidth+1, dy-50- scHeight+1), ImVec2(dx-160 - scWidth+1  , dy-50- scHeight+1 ), ImVec2(0.0f, 0.0f), ImVec2(1.0f, 1.0f));
                    break;
                }
                case 101005: {
                    namea = @"Groza";
                    //   ImGui::GetOverlayDrawList()->AddImage((__bridge ImTextureID) countTexture, ImVec2(dx-25 - scWidth+1, dy-50- scHeight+1), ImVec2(dx-25 - scWidth+1  , dy+50- scHeight+1 ), ImVec2(0.0f, 0.0f), ImVec2(1.0f, 1.0f));
                    break;
                }
                case 101006: {
                    namea = @"AUG";
                    break;
                }
                case 101007: {
                    namea = @"QBZ";
                    break;
                }
                case 101008: {
                    namea = @"M762";
                    break;
                }
                case 101009: {
                    namea = @"Mk47";
                    break;
                }
                case 101010: {
                    namea = @"C36C";
                    break;
                }
                case 101011: {
                    namea = @"AC-VAL";
                    break;
                }
                case 101012: {
                    namea = @"突击枪";
                    break;
                }
                case 103001: {
                    namea = @"Kar98k";
                    break;
                }
                case 103002: {
                    namea = @"M24";
                    break;
                }
                case 103003: {
                    namea = @"AWM";
                    break;
                }
                case 103004: {
                    namea = @"SKS";
                    break;
                }
                case 103005: {
                    namea = @"VSS";
                    break;
                }
                case 103006: {
                    namea = @"Mini14";
                    break;
                }
                case 103007: {
                    namea = @"MK-14";
                    break;
                }
                case 103008: {
                    namea = @"Win94";
                    break;
                }
                case 103009: {
                    namea = @"SLR";
                    break;
                }
                case 103010: {
                    namea = @"QBU";
                    break;
                }
                case 103011: {
                    namea = @"莫辛纳甘";
                    break;
                }
                case 103012: {
                    namea = @"AMR";
                    break;
                }
                case 103013: {
                    namea = @"M417";
                    break;
                }
                case 103014: {
                    namea = @"MK20";
                    break;
                }
                case 102001: {
                    namea = @"Uzi";
                    break;
                }
                case 102105: {
                    namea = @"P90";
                    break;
                }
                case 102002: {
                    namea = @"UMP9";
                    break;
                }
                case 102003: {
                    namea = @"Vector";
                    break;
                }
                case 102004: {
                    namea = @"TommyGun";
                    break;
                }
                case 102005: {
                    namea = @"野牛";
                    break;
                }
                case 102007: {
                    namea = @"MP5K";
                    break;
                }
                case 104001: {
                    namea = @"S686";
                    break;
                }
                case 104002: {
                    namea = @"S1897";
                    break;
                }
                case 104003: {
                    namea = @"S12K";
                    break;
                }
                case 104004: {
                    namea = @"DBS";
                    break;
                }
                case 104006: {
                    namea = @"SawedOff";
                    break;
                }
                case 104100: {
                    namea = @"SPAS-12";
                    break;
                }
                case 106001: {
                    namea = @"P92";
                    break;
                }
                case 106002: {
                    namea = @"P1911";
                    break;
                }
                case 106003: {
                    namea = @"R1895";
                    break;
                }
                case 106004: {
                    namea = @"P18C";
                    break;
                }
                case 106005: {
                    namea = @"R45";
                    break;
                }
                    
                case 106010: {
                    namea = @"沙漠之鹰";
                    break;
                }
                default:
                    break;
            }
            
            
            if(手持开关){
                char* ii = (char*) [[NSString stringWithFormat:@" %@",namea] cStringUsingEncoding:NSUTF8StringEncoding];
                DrawText2(ii, ImVec2(xd+8, yd-37), true, Colour_白色, true, 10.5);
            }
#pragma mark - 载具属性
        }
    }
#pragma mark - 物资熟悉
    for (NSInteger i = 0; i < _wuziArray.count; i++) {
        PUBGPlayerModel *model = _wuziArray[i];
        float xx = model.wuzi.origin.x + model.wuzi.size.width/2;
        float yy = model.wuzi.origin.y;
        
        NSString *nameaa = @"";
        
        switch (model.flag) {
#pragma mark - 物资熟悉
                
            case 1: {
                nameaa = @"小绵羊";
                
                break;
            }
            case 2: {
                nameaa = @"摩托车";
                
                break;
            }
            case 3: {
                nameaa = @"太君摩托";
                
                break;
            }
            case 4: {
                nameaa = @"三轮摩托";
                
                break;
            }
            case 5: {
                nameaa = @"蹦蹦";
                
                break;
            }
            case 6: {
                nameaa = @"皮卡";
                
                break;
            }
            case 7: {
                nameaa = @"跑车";
                
                break;
            }
            case 8: {
                nameaa = @"轿车";
                
                break;
            }
            case 9: {
                nameaa = @"冲锋艇";
                
                break;
            }
            case 10: {
                nameaa = @"CoupeRB";
                
                break;
            }
            case 11: {
                nameaa = @"大巴车";
                
                break;
            }
            case 12: {
                nameaa = @"装甲车";
                
                break;
            }
            case 13: {
                nameaa = @"吉普";
                
                break;
            }
            case 14: {
                nameaa = @"自行车";
                
                break;
            }
                
                
#pragma mark - 枪械
            case 15: {
                nameaa = @"VAL";
                
                break;
            }
            case 16: {
                nameaa = @"MP5K";
                
                break;
            }
            case 17: {
                nameaa = @"p90";
                
                break;
            }
            case 18: {
                nameaa = @"pp19";
                
                break;
            }
            case 19: {
                nameaa = @"TommyGun";
                
                break;
            }
            case 20: {
                nameaa = @"UMP45";
                
                break;
            }
            case 21: {
                nameaa = @"UziPro";
                
                break;
            }
            case 22: {
                nameaa = @"Vector";
                
                break;
            }
            case 23: {
                nameaa = @"Mini14";
                
                break;
            }
            case 24: {
                nameaa = @"MK12";
                
                break;
            }
            case 25: {
                nameaa = @"MK14";
                
                break;
            }
            case 26: {
                nameaa = @"QBU";
                
                break;
            }
            case 27: {
                nameaa = @"SKS";
                
                break;
            }
            case 28: {
                nameaa = @"SLR";
                
                break;
            }
            case 29: {
                nameaa = @"VSS";
                
                break;
            }
            case 30: {
                nameaa = @"AWM";
                
                break;
            }
            case 31: {
                nameaa = @"M24";
                
                break;
            }
            case 32: {
                nameaa = @"AKM";
                
                break;
            }
            case 33: {
                nameaa = @"M416";
                
                break;
            }
            case 34: {
                nameaa = @"AUG";
                
                break;
            }
            case 35: {
                nameaa = @"G36C";
                
                break;
            }
            case 36: {
                nameaa = @"Groza";
                
                break;
            }
            case 37: {
                nameaa = @"M16A4";
                
                break;
            }
            case 38: {
                nameaa = @"M762";
                
                break;
            }
            case 39: {
                nameaa = @"Mk47";
                
                break;
            }
            case 40: {
                nameaa = @"DP28";
                
                break;
            }
            case 41: {
                nameaa = @"M249";
                
                break;
            }
            case 42: {
                nameaa = @"SCAR-L";
                
                break;
            }
            case 43: {
                nameaa = @"QBZ";
                
                break;
            }
            case 44: {
                nameaa = @"Kar98k";
                
                break;
            }
#pragma mark - 护具
            case 45: {
                nameaa = @"一级头";
                
                break;
            }
            case 46: {
                nameaa = @"一级头";
                
                break;
            }
            case 47: {
                nameaa = @"一级甲";
                
                break;
            }
            case 48: {
                nameaa = @"一级包";
                
                break;
            }
            case 49: {
                nameaa = @"二级头";
                
                break;
            }
            case 50: {
                nameaa = @"二级甲";
                
                break;
            }
            case 51: {
                nameaa = @"二级包";
                
                break;
            }
            case 52: {
                nameaa = @"三级头";
                
                break;
            }
            case 53: {
                nameaa = @"三级甲";
                
                break;
            }
            case 54: {
                nameaa = @"三级包";
                
                break;
            }
#pragma mark - 背景
            case 55: {
                nameaa = @"3倍瞄准镜";
                
                break;
            }
            case 56: {
                nameaa = @"2倍瞄准镜";
                
                break;
            }
            case 57: {
                nameaa = @"8倍瞄准镜";
                
                break;
            }
            case 58: {
                nameaa = @"4倍瞄准镜";
                
                break;
            }
            case 59: {
                nameaa = @"6倍瞄准镜";
                
                break;
            }
#pragma mark - 配件
            case 60: {
                nameaa = @"冲锋枪补偿器";
                
                break;
            }
            case 61: {
                nameaa = @"步枪补偿器";
                
                break;
            }
            case 62: {
                nameaa = @"UZI枪托";
                
                break;
            }
            case 63: {
                nameaa = @"战术枪托";
                
                break;
            }
            case 64: {
                nameaa = @"轻型握把";
                
                break;
            }
            case 65: {
                nameaa = @"撬棍";
                
                break;
            }
            case 66: {
                nameaa = @"大砍刀";
                
                break;
            }
            case 67: {
                nameaa = @"平底锅";
                
                break;
            }
            case 68: {
                nameaa = @"镰刀";
                
                break;
            }
#pragma mark - 子弹
            case 69: {
                nameaa = @"[子弹]762";
                
                break;
            }
            case 70: {
                nameaa = @"[子弹]556";
                
                break;
            }
            case 71: {
                nameaa = @"[子弹].45";
                
                break;
            }
            case 72: {
                nameaa = @"[子弹].12";
                
                break;
            }
            case 73: {
                nameaa = @"[子弹]40mm";
                
                break;
            }
            case 74: {
                nameaa = @"[子弹]9mm";
                
                break;
            }
#pragma mark - 药品
            case 75: {
                nameaa = @"肾上腺素";
                
                break;
            }
            case 76: {
                nameaa = @"急救包";
                
                break;
            }
            case 77: {
                nameaa = @"止痛药";
                
                break;
            }
            case 78: {
                nameaa = @"能量饮料";
                
                break;
            }
            case 79: {
                nameaa = @"绷带";
                
                break;
            }
            case 80: {
                nameaa = @"医疗箱";
                
                break;
            }
#pragma mark - 盒子
            case 81: {
                nameaa = @"骨灰盒子";
                
                break;
            }
#pragma mark - 空投
            case 82: {
                nameaa = @"空投";
                
                break;
            }
#pragma mark -信号枪
            case 83: {
                nameaa = @"信号枪";
                
                break;
            }
#pragma mark - 投掷物
            case 84: {
                nameaa = @"⚠️小心手雷！！！";
                
                break;
            }
            case 85: {
                nameaa = @"⚠️小心闪光弹！！！";
                
                break;
            }
            case 86: {
                nameaa = @"⚠️小心燃烧瓶！！！";
                
                break;
            }
            default:
                break;
        }
        if (物资开关) {
            char* ii = (char*) [[NSString stringWithFormat:@" %@",nameaa] cStringUsingEncoding:NSUTF8StringEncoding];
            
            DrawText2(ii, ImVec2(xx, yy), true, Colour_白色, true, 8);
            
            char* iiq = (char*) [[NSString stringWithFormat:@"%dm",(int)model.wuzimi] cStringUsingEncoding:NSUTF8StringEncoding];
            
            DrawText2(iiq, ImVec2(xx, yy+8), true, Colour_白色, true, 8);
        }
    }
}

#pragma mark - 懒加载

- (void)draw
{
    [self doTheJob];
}
@end
