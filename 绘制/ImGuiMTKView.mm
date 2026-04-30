//
//  ImGuiMTKView.m
//  IOSPUBG
//
//  Created by yy on 2022/5/2.
//

#import "ImGuiMTKView.h"
#import "baidu_font.h"
//#import "jijia.h"
#import "huitu.h"
#define iPhone8P ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1242, 2208), [[UIScreen mainScreen] currentMode].size) : NO)
#define IPAD129 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(2732,2048), [[UIScreen mainScreen] currentMode].size) : NO)

//2732x2048
@interface ImGuiMTKView ()
@property (nonatomic, strong) id <MTLDevice> device;
@property (nonatomic, strong) id <MTLCommandQueue> commandQueue;
@property (nonatomic, strong) MTKTextureLoader *loader;
@end

@implementation ImGuiMTKView

- (nonnull instancetype)initWithView:(nonnull MTKView *)view;
{
    self = [super init];
    if(self)
    {
        view.preferredFramesPerSecond = 120;
        
        _device = view.device;
        _commandQueue = [_device newCommandQueue];
        _loader = [[MTKTextureLoader alloc] initWithDevice: _device];
        
        IMGUI_CHECKVERSION();
        ImGui::CreateContext();
        ImGui::StyleColorsLight();

        ImGuiIO &io = ImGui::GetIO();
        io.ConfigFlags |= ImGuiConfigFlags_NavEnableKeyboard;
        io.BackendFlags |= ImGuiBackendFlags_HasMouseCursors;

        ImGuiStyle &style = ImGui::GetStyle();
        style.WindowRounding = 8.0f;
        style.FrameRounding = 6.0f;
        style.GrabRounding = 6.0f;
        style.WindowPadding = ImVec2(10.0f, 10.0f);
        style.FramePadding = ImVec2(8.0f, 4.0f);
        style.ItemSpacing = ImVec2(8.0f, 6.0f);
        style.ScrollbarSize = 12.0f;
        style.WindowMinSize = ImVec2(160.0f, 120.0f);

        ImFontConfig config;
        config.FontDataOwnedByAtlas = false;
        io.Fonts->Clear();
        io.Fonts->AddFontFromMemoryTTF((void *)baidu_font_data, baidu_font_size, 18.0f, &config, io.Fonts->GetGlyphRangesChineseFull());
        io.FontGlobalScale = 1.0f;
    }

    return self;
}

- (void)drawInMTKView:(MTKView *)view {
    ImGuiIO &io = ImGui::GetIO();
    io.DisplaySize = ImVec2(view.bounds.size.width, view.bounds.size.height);

#if TARGET_OS_OSX
    CGFloat framebufferScale = view.window.screen.backingScaleFactor ?: NSScreen.mainScreen.backingScaleFactor;
#else
    CGFloat framebufferScale = view.window.screen.scale ?: UIScreen.mainScreen.scale;
#endif
    io.DisplayFramebufferScale = ImVec2(framebufferScale, framebufferScale);

    io.DeltaTime = 1.0f / float(view.preferredFramesPerSecond > 0 ? view.preferredFramesPerSecond : 60);

    id<MTLCommandBuffer> commandBuffer = [self.commandQueue commandBuffer];

    static float clear_color[4] = { 0.0f, 0.0f, 0.0f, 0.0f };
    
    view.clearColor = MTLClearColorMake(clear_color[0], clear_color[1], clear_color[2], clear_color[3]);
    
    MTLRenderPassDescriptor *renderPassDescriptor = view.currentRenderPassDescriptor;
    if (renderPassDescriptor != nil)
    {
        id <MTLRenderCommandEncoder> renderEncoder = [commandBuffer renderCommandEncoderWithDescriptor:renderPassDescriptor];
        [renderEncoder pushDebugGroup:@"SwiftGUI"];

        // Start the Dear ImGui frame
        ImGui_ImplMetal_NewFrame(renderPassDescriptor);
        ImGui::NewFrame();

        if (self.delegate) {
            if ([self.delegate respondsToSelector:@selector(draw)]) {
                [self.delegate draw];
            }
            if ([self.delegate respondsToSelector:@selector(drawUI)]) {
                [self.delegate drawUI];
            }
        }

        // Rendering
        ImGui::Render();
        ImDrawData *drawData = ImGui::GetDrawData();
        ImGui_ImplMetal_RenderDrawData(drawData, commandBuffer, renderEncoder);

        [renderEncoder popDebugGroup];
        [renderEncoder endEncoding];

        [commandBuffer presentDrawable:view.currentDrawable];
    }

    [commandBuffer commit];
}

- (void)mtkView:(MTKView *)view drawableSizeWillChange:(CGSize)size {
}

- (void)initializePlatform {
    ImGui_ImplMetal_Init(_device);
}

- (void)handleEvent:(UIEvent *_Nullable)event view:(UIView *_Nullable)view {
    if (event.type != UIEventTypeTouches) {
        return;
    }

    UITouch *anyTouch = event.allTouches.anyObject;
    if (!anyTouch) {
        return;
    }

    CGPoint touchLocation = [anyTouch locationInView:view];
    ImGuiIO &io = ImGui::GetIO();
    io.MousePos = ImVec2(touchLocation.x, touchLocation.y);

    BOOL hasActiveTouch = NO;
    for (UITouch *touch in event.allTouches) {
        if (touch.phase != UITouchPhaseEnded && touch.phase != UITouchPhaseCancelled) {
            hasActiveTouch = YES;
            break;
        }
    }
    io.MouseDown[0] = hasActiveTouch;
    io.MouseWheel = 0.0f;
    io.MouseWheelH = 0.0f;
}

-(id<MTLTexture>)loadTextureWithURL:(NSURL *)url {

    id<MTLTexture> texture = [self.loader newTextureWithContentsOfURL:url options:nil error:nil];
    
    if(!texture)
    {
        NSLog(@"Failed to create the texture from %@", url.absoluteString);
        return nil;
    }
    return texture;
}

-(id<MTLTexture>)loadTextureWithName:(NSString *)name {

    id<MTLTexture> texture = [self.loader newTextureWithName:name scaleFactor:1.0 bundle:nil options:nil error:nil];

    if(!texture)
    {
        NSLog(@"Failed to create the texture from %@", name);
        return nil;
    }
    return texture;
}
@end
