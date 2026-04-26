//
//  ColorTool.hpp
//  UE4
//
//  Created by yy on 2022/5/10.
//

#ifndef ColorTool_hpp
#define ColorTool_hpp

#include <stdio.h>

#pragma mark - 颜色工具

#define Colour_红色 0xFF0000FF
#define Colour_绿色 0xFF00FF00
#define Colour_粉红 0xFFCBC0FF
#define Colour_蓝色 0xFFFF0000
#define Colour_浅蓝 0xFFFACE87
#define Colour_青色 0xFFFFFF00
#define Colour_碧绿 0xFFAAFF7F
#define Colour_草绿 0xFF00FC7C
#define Colour_橙黄 0xFF00A5FF
#define Colour_橙色 0xFF0066FF
#define Colour_桃红 0xFFB9DAFF
#define Colour_珊瑚红 0xFF507FFF
#define Colour_紫色 0xFFEE677A
#define Colour_石板灰 0xFF908070
#define Colour_白色 0xFFFFFFFF
#define Colour_黑色 0xFF000000
#define Colour_绿黄 0xFFADFF2F
#define Colour_纯黄 0xFF00FFFF
#define Colour_透明红色 0x800000FF
#define Colour_透明橙黄 0x8000A5FF
#define Colour_透明绿黄 0x80ADFF2F
#define Colour_透明绿色 0x8000FF00
#define Colour_透明石板灰 0x80908070

static int BoneColos(bool b1, bool b2, bool isAi) {
    if (isAi) return b1 || b2 ? Colour_白色 : Colour_绿色;
    else return b1 || b2 ? Colour_红色 : Colour_绿色;
}

//static int LineColor(float distance, bool IsAI) {
//    if (distance <= 80)
//        return IsAI ? Colour_白色 : Colour_红色;
//    else if (distance <= 160)
//        return IsAI ? Colour_白色 : Colour_纯黄;
//    else if (distance <= 240)
//        return IsAI ? Colour_白色 : Colour_橙色;
//    return IsAI ? Colour_白色 : Colour_绿色;
//}

#endif /* ColorTool_hpp */
