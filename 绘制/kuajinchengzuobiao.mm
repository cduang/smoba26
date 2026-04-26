
#import "kuajinchengzuobiao.h"
#import "PUBGDataModel.h"
#include "string"
#import "WUZIView.h"

#define kScreenWidth  [UIScreen mainScreen].bounds.size.width
#define kScreenHeight [UIScreen mainScreen].bounds.size.height
@interface kuajinchengzuobiao()
@property (nonatomic,  assign) GameInfo gameInfo;

@property (nonatomic,  assign) uintptr_t gworldPtr;
@property (nonatomic,  assign) uintptr_t gnamePtr;

@property (nonatomic,  assign) FVector2D canvas;
@property (nonatomic,  assign) FMinimalViewInfo POV;
@end

@implementation kuajinchengzuobiao
int chi=0;

#pragma mark - 物资开关
//bool zaiju =NO;
//bool qiangxie =NO;
//bool hujia =NO;
//bool beijing =NO;
//bool peijian =NO;
//bool zidan =NO;
//bool yaoping =NO;
//bool hezi =NO;
//bool kongtou =NO;
//bool xinghaoqiang =NO;
//bool shoulei =NO;

struct ObjectName{
    const char data[64];
};
+ (instancetype)factory
{
    static kuajinchengzuobiao *fact;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        fact = [[kuajinchengzuobiao alloc] init];
    });
    return fact;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _gworldPtr = 0;
        _gnamePtr = 0;
        
        _canvas.X = [UIScreen mainScreen].bounds.size.width;
        _canvas.Y = [UIScreen mainScreen].bounds.size.height;
    }
    return self;
}

#pragma mark - 内存读写

extern "C" kern_return_t
mach_vm_region_recurse(
                       vm_map_t                 map,
                       mach_vm_address_t        *address,
                       mach_vm_size_t           *size,
                       uint32_t                 *depth,
                       vm_region_recurse_info_t info,
                       mach_msg_type_number_t   *infoCnt);

extern "C" kern_return_t
mach_vm_read_overwrite(
                       vm_map_t           target_task,
                       mach_vm_address_t  address,
                       mach_vm_size_t     size,
                       mach_vm_address_t  data,
                       mach_vm_size_t     *outsize);

extern "C" kern_return_t
mach_vm_write(
              vm_map_t                          map,
              mach_vm_address_t                 address,
              pointer_t                         data,
              __unused mach_msg_type_number_t   size);

- (pid_t)getProcesses:(NSString *)name
{
    size_t length = 0;
    static const int mib[] = {CTL_KERN, KERN_PROC, KERN_PROC_ALL, 0};
    int err = sysctl((int *)mib, (sizeof(mib) / sizeof(*mib)) - 1, NULL, &length, NULL, 0);
    if (err == -1) {
        err = errno;
    }
    
    if (err == 0) {
        struct kinfo_proc *procBuffer = (struct kinfo_proc *)malloc(length);
        if(procBuffer == NULL) {
            return -1;
        }
        
        sysctl( (int *)mib, (sizeof(mib) / sizeof(*mib)) - 1, procBuffer, &length, NULL, 0);
        
        int count = (int)length / sizeof(struct kinfo_proc);
        for (int i = 0; i < count; ++i) {
            const char *procname = procBuffer[i].kp_proc.p_comm;
            if (strstr(procname, name.UTF8String)) {
                return procBuffer[i].kp_proc.p_pid;
            }
        }
    }
    return -1;
}

- (mach_port_t)getTask:(int)pid
{
    mach_port_t task;
    task_for_pid(mach_task_self(), pid, &task);
    return task;
}

- (vm_map_offset_t)getBaseAddress:(mach_port_t)task
{
    vm_map_offset_t vmoffset = 0;
    vm_map_size_t vmsize = 0;
    uint32_t nesting_depth = 0;
    struct vm_region_submap_info_64 vbr;
    mach_msg_type_number_t vbrcount = 16;
    kern_return_t kret = mach_vm_region_recurse(task, &vmoffset, &vmsize, &nesting_depth, (vm_region_recurse_info_t)&vbr, &vbrcount);
    if (kret == KERN_SUCCESS) {
        NSLog(@"[yiming] %s : %016llX %lld bytes.", __func__, vmoffset, vmsize);
    } else {
        NSLog(@"[yiming] %s : FAIL.", __func__);
    }
    
    return vmoffset;
}

- (BOOL)isValidAddress:(uintptr_t)address
{
    return address && address > 0x100000000 && address < kAddrMax;
}

- (BOOL)readMemory:(uintptr_t)address size:(size_t)size buffer:(void *)buffer
{
    if (![self isValidAddress:address]) {
        return NO;
    }
    
    mach_vm_size_t otu_size = 0;
    kern_return_t error = mach_vm_read_overwrite((vm_map_t)_gameInfo.task, (mach_vm_address_t)address, (mach_vm_size_t)size, (mach_vm_address_t)buffer, &otu_size);
    if (error != KERN_SUCCESS || otu_size != size) {
        return NO;
    }
    return YES;
}
static kern_return_t read_mem(mach_port_t task, vm_map_offset_t address, mach_vm_size_t size, mach_vm_size_t buffer_bytes, void *buffer)
{
    kern_return_t kert = mach_vm_read_overwrite(task, address, size, (mach_vm_address_t)(buffer), &buffer_bytes); // AAR in Kernel
    return kert;
}

template<typename T> T Read(mach_port_t g_task, long address)
{
    T data;
    read_mem(g_task, address, sizeof(T), sizeof(T), reinterpret_cast<void *>(&data));
    return data;
}
- (BOOL)writeMemory1:(uintptr_t)address size:(int)size buffer:(void *)buffer
{
    if (![self isValidAddress:address]) {
        return NO;
    }
    
    kern_return_t error = mach_vm_write((vm_map_t)_gameInfo.task, (mach_vm_address_t)address, (vm_offset_t)buffer, (mach_msg_type_number_t)size);
    if(error != KERN_SUCCESS) {
        return NO;
    }
    
    return YES;
}


- (BOOL)WriteMemory:(uintptr_t)address size:(size_t)size buffer:(void *)buffer
{
    
    if (address <= 0x100000000 || address >= 0x200000000)
        return false;
    
    kern_return_t kret = mach_vm_write((vm_map_t)_gameInfo.task, (mach_vm_address_t)address, (mach_vm_size_t)size,  (mach_vm_address_t)buffer);
    if (kret != KERN_SUCCESS) {
        task_resume(_gameInfo.task);
        return NO;
        
    }
    return YES;
}


- (uintptr_t)readPtr:(uintptr_t)address
{
    uintptr_t value = 0;
    [self readMemory:address size:8 buffer:&value];
    return value;
}

- (int)readInt:(uintptr_t)address
{
    int value = 0;
    [self readMemory:address size:4 buffer:&value];
    return value;
}

- (BOOL)readBool:(uintptr_t)address
{
    BOOL value = NO;
    [self readMemory:address size:sizeof(BOOL) buffer:&value];
    return value;
}
- (float)readFloat:(uintptr_t)address
{
    float value = 0;
    [self readMemory:address size:sizeof(float) buffer:&value];
    return value;
}
- (float)WriteFloat:(uintptr_t)address data:(float*)data
{
    float value = 0;
    [self WriteMemory:address size:sizeof(float) buffer:&value];
    return value;
}
- (float)readlong:(uintptr_t)address
{
    float value = 0;
    [self readMemory:address size:sizeof(long) buffer:&value];
    return value;
}

- (int)readShort:(uintptr_t)address
{
    int value = 0;
    [self readMemory:address size:2 buffer:&value];
    return value;
}

- (FVector3D)readFVector:(uintptr_t)address
{
    FVector3D value;
    [self readMemory:address size:sizeof(FVector3D) buffer:&value];
    return value;
}

#pragma mark - 坐标转换

- (FVector3D)minusTheVector:(FVector3D)first second:(FVector3D)second
{
    FVector3D ret;
    ret.X = first.X - second.X;
    ret.Y = first.Y - second.Y;
    ret.Z = first.Z - second.Z;
    return ret;
}

- (float)theDot:(FVector3D)v1 v2:(FVector3D)v2
{
    return v1.X * v2.X + v1.Y * v2.Y + v1.Z * v2.Z;
}

- (float)getDistance:(FVector3D)a b:(FVector3D)b
{
    FVector3D ret;
    ret.X = a.X - b.X;
    ret.Y = a.Y - b.Y;
    ret.Z = a.Z - b.Z;
    return sqrt(ret.X * ret.X + ret.Y * ret.Y + ret.Z * ret.Z);
}

- (D3DXMATRIX)toMATRIX:(FRotator)rot
{
    float RadPitch, RadYaw, RadRoll, SP, CP, SY, CY, SR, CR;
    D3DXMATRIX M;
    
    RadPitch = rot.Pitch * M_PI / 180;
    RadYaw = rot.Yaw * M_PI / 180;
    RadRoll = rot.Roll * M_PI / 180;
    
    SP = sin(RadPitch);
    CP = cos(RadPitch);
    SY = sin(RadYaw);
    CY = cos(RadYaw);
    SR = sin(RadRoll);
    CR = cos(RadRoll);
    
    M._11 = CP * CY;
    M._12 = CP * SY;
    M._13 = SP;
    M._14 = 0.f;
    
    M._21 = SR * SP * CY - CR * SY;
    M._22 = SR * SP * SY + CR * CY;
    M._23 = -SR * CP;
    M._24 = 0.f;
    
    M._31 = -(CR * SP * CY + SR * SY);
    M._32 = CY * SR - CR * SP * SY;
    M._33 = CR * CP;
    M._34 = 0.f;
    
    M._41 = 0.f;
    M._42 = 0.f;
    M._43 = 0.f;
    M._44 = 1.f;
    
    return M;
}
static bool IsValidAddress(uintptr_t address) {
    return address && address > 0x100000000 && address < 0x2000000000;
}
- (void)getTheAxes:(FRotator)rot x:(FVector3D *)x y:(FVector3D *)y z:(FVector3D *)z
{
    D3DXMATRIX M = [self toMATRIX:rot];
    
    x->X = M._11;
    x->Y = M._12;
    x->Z = M._13;
    
    y->X = M._21;
    y->Y = M._22;
    y->Z = M._23;
    
    z->X = M._31;
    z->Y = M._32;
    z->Z = M._33;
}

- (FVector2D)worldToScreen:(FVector3D)worldLocation camViewInfo:(FMinimalViewInfo)camViewInfo canvas:(FVector2D)canvas
{
    FVector2D Screenlocation;
    
    FVector3D vAxisX, vAxisY, vAxisZ;
    [self getTheAxes:camViewInfo.Rotation x:&vAxisX y:&vAxisY z:&vAxisZ];
    
    FVector3D vDelta = [self minusTheVector:worldLocation second:camViewInfo.Location];
    FVector3D vTransformed;
    vTransformed.X = [self theDot:vDelta v2:vAxisY];
    vTransformed.Y = [self theDot:vDelta v2:vAxisZ];
    vTransformed.Z = [self theDot:vDelta v2:vAxisX];
    
    if (vTransformed.Z < 1.0f) {
        vTransformed.Z = 1.0f;
    }
    
    float FOV = camViewInfo.FOV;
    float ScreenCenterX = canvas.X / 2;
    float ScreenCenterY = canvas.Y / 2;
    
    Screenlocation.X = ScreenCenterX + vTransformed.X * (ScreenCenterX / tanf(FOV * (float)M_PI / 360.f)) / vTransformed.Z;
    Screenlocation.Y = ScreenCenterY - vTransformed.Y * (ScreenCenterX / tanf(FOV * (float)M_PI / 360.f)) / vTransformed.Z;
    
    return Screenlocation;
}

- (BOOL)worldToScreenForRect:(FVector3D)Pos camViewInfo:(FMinimalViewInfo)camViewInfo canvas:(FVector2D)canvas outRect:(FVectorRect *)outRect
{
    FVector3D Pos2 = Pos;
    Pos2.Z += 90.f;
    
    FVector2D CalcPos = [self worldToScreen:Pos camViewInfo:camViewInfo canvas:canvas];
    FVector2D CalcPos2 = [self worldToScreen:Pos2 camViewInfo:camViewInfo canvas:canvas];
    
    outRect->H = CalcPos.Y - CalcPos2.Y;
    outRect->W = outRect->H / 2.5;
    outRect->X = CalcPos.X - outRect->W;
    outRect->Y = CalcPos2.Y;
    outRect->W = outRect->W * 2;
    outRect->H = outRect->H * 2;
    
    return YES;
}

#pragma mark - 游戏数据


- (NSString *)getFNameFromID:(int)classId
{
    NSString *FName;
    if (classId > 0 && classId < 2000000) {
        char *buf = (char *)malloc(64);
        int page = classId / 16384;
        int index = classId % 16384;
        uintptr_t pageAddr = [self readPtr:self.gnamePtr + page * sizeof(uintptr_t)];
        uintptr_t nameAddr = [self readPtr:pageAddr + index * sizeof(uintptr_t)] + 0xE;
        [self readMemory:nameAddr size:64 buffer:buf];
        FName = [NSString stringWithUTF8String:buf];
        free(buf);
    }
    return FName;
}

- (NSString *)getPlayerName:(uintptr_t)player
{
    char Name[128];
    unsigned short buf16[16] = {0};
    uintptr_t PlayerName = [self readPtr:player + 0xb50];//Class: UAECharacter.Character.Pawn.Actor.Object//FString PlayerName
    if (![self isValidAddress:PlayerName]) {
        return @"";
    }
    
    if (![self readMemory:PlayerName size:28 buffer:buf16]) {
        return @"";
    }
    
    unsigned short *tempbuf16 = buf16;
    char *tempbuf8 = Name;
    char *buf8 = tempbuf8 + 32;
    while (tempbuf16 < tempbuf16 + 28) {
        if (*tempbuf16 <= 0x007F && tempbuf8 + 1 < buf8) {
            *tempbuf8++ = (char) *tempbuf16;
        } else if (*tempbuf16 >= 0x0080 && *tempbuf16 <= 0x07FF && tempbuf8 + 2 < buf8) {
            *tempbuf8++ = (*tempbuf16 >> 6) | 0xC0;
            *tempbuf8++ = (*tempbuf16 & 0x3F) | 0x80;
        } else if (*tempbuf16 >= 0x0800 && *tempbuf16 <= 0xFFFF && tempbuf8 + 3 < buf8) {
            *tempbuf8++ = (*tempbuf16 >> 12) | 0xE0;
            *tempbuf8++ = ((*tempbuf16 >> 6) & 0x3F) | 0x80;
            *tempbuf8++ = (*tempbuf16 & 0x3F) | 0x80;
        } else {
            break;
        }
        tempbuf16++;
    }
    
    return [NSString stringWithUTF8String:Name];
}

- (FVector3D)getRelativeLocation:(uintptr_t)actor
{
    uintptr_t RootComponent = [self readPtr:actor + 0x270];//Class: Actor.Object//SceneComponent* RootComponent
    return [self readFVector:RootComponent + 0x1d0];//Vector4[] OcclusionCullingVertex
}
#pragma mark - 骨骼相关
- (FTransform)getMatrixConversion:(uintptr_t)address
{
    FTransform ret;
    [self readMemory:address size:sizeof(float) buffer:&ret.Rotation.X];
    [self readMemory:address + 4 size:sizeof(float) buffer:&ret.Rotation.Y];
    [self readMemory:address + 8 size:sizeof(float) buffer:&ret.Rotation.Z];
    [self readMemory:address + 12 size:sizeof(float) buffer:&ret.Rotation.W];
    
    [self readMemory:address + 16 size:sizeof(float) buffer:&ret.Translation.X];
    [self readMemory:address + 20 size:sizeof(float) buffer:&ret.Translation.Y];
    [self readMemory:address + 24 size:sizeof(float) buffer:&ret.Translation.Z];
    
    [self readMemory:address + 32 size:sizeof(float) buffer:&ret.Scale3D.X];
    [self readMemory:address + 36 size:sizeof(float) buffer:&ret.Scale3D.Y];
    [self readMemory:address + 40 size:sizeof(float) buffer:&ret.Scale3D.Z];
    
    return ret;
}
- (D3DXMATRIX)toMatrixWithScale:(FVector4D)rotation
                    translation:(FVector3D)translation
                        scale3D:(FVector3D)scale3D
{
    D3DXMATRIX ret;
    
    float x2, y2, z2, xx2, yy2, zz2, yz2, wx2, xy2, wz2, xz2, wy2 = 0.f;
    ret._41 = translation.X;
    ret._42 = translation.Y;
    ret._43 = translation.Z;
    
    x2 = rotation.X * 2;
    y2 = rotation.Y * 2;
    z2 = rotation.Z * 2;
    
    xx2 = rotation.X * x2;
    yy2 = rotation.Y * y2;
    zz2 = rotation.Z * z2;
    
    ret._11 = (1 - (yy2 + zz2)) * scale3D.X;
    ret._22 = (1 - (xx2 + zz2)) * scale3D.Y;
    ret._33 = (1 - (xx2 + yy2)) * scale3D.Z;
    
    yz2 = rotation.Y * z2;
    wx2 = rotation.W * x2;
    ret._32 = (yz2 - wx2) * scale3D.Z;
    ret._23 = (yz2 + wx2) * scale3D.Y;
    
    xy2 = rotation.X * y2;
    wz2 = rotation.W * z2;
    ret._21 = (xy2 - wz2) * scale3D.Y;
    ret._12 = (xy2 + wz2) * scale3D.X;
    
    xz2 = rotation.X * z2;
    wy2 = rotation.W * y2;
    ret._31 = (xz2 + wy2) * scale3D.Z;
    ret._13 = (xz2 - wy2) * scale3D.X;
    
    ret._14 = 0.f;
    ret._24 = 0.f;
    ret._34 = 0.f;
    ret._44 = 1.f;
    
    return ret;
}
- (struct D3DXMATRIX)matrixMultiplication:(struct D3DXMATRIX)M1 M2:(struct D3DXMATRIX)M2
{
    struct D3DXMATRIX ret;
    ret._11 = M1._11 * M2._11 + M1._12 * M2._21 + M1._13 * M2._31 + M1._14 * M2._41;
    ret._12 = M1._11 * M2._12 + M1._12 * M2._22 + M1._13 * M2._32 + M1._14 * M2._42;
    ret._13 = M1._11 * M2._13 + M1._12 * M2._23 + M1._13 * M2._33 + M1._14 * M2._43;
    ret._14 = M1._11 * M2._14 + M1._12 * M2._24 + M1._13 * M2._34 + M1._14 * M2._44;
    ret._21 = M1._21 * M2._11 + M1._22 * M2._21 + M1._23 * M2._31 + M1._24 * M2._41;
    ret._22 = M1._21 * M2._12 + M1._22 * M2._22 + M1._23 * M2._32 + M1._24 * M2._42;
    ret._23 = M1._21 * M2._13 + M1._22 * M2._23 + M1._23 * M2._33 + M1._24 * M2._43;
    ret._24 = M1._21 * M2._14 + M1._22 * M2._24 + M1._23 * M2._34 + M1._24 * M2._44;
    ret._31 = M1._31 * M2._11 + M1._32 * M2._21 + M1._33 * M2._31 + M1._34 * M2._41;
    ret._32 = M1._31 * M2._12 + M1._32 * M2._22 + M1._33 * M2._32 + M1._34 * M2._42;
    ret._33 = M1._31 * M2._13 + M1._32 * M2._23 + M1._33 * M2._33 + M1._34 * M2._43;
    ret._34 = M1._31 * M2._14 + M1._32 * M2._24 + M1._33 * M2._34 + M1._34 * M2._44;
    ret._41 = M1._41 * M2._11 + M1._42 * M2._21 + M1._43 * M2._31 + M1._44 * M2._41;
    ret._42 = M1._41 * M2._12 + M1._42 * M2._22 + M1._43 * M2._32 + M1._44 * M2._42;
    ret._43 = M1._41 * M2._13 + M1._42 * M2._23 + M1._43 * M2._33 + M1._44 * M2._43;
    ret._44 = M1._41 * M2._14 + M1._42 * M2._24 + M1._43 * M2._34 + M1._44 * M2._44;
    //    ret._32=M1._42;
    return ret;
}
- (FVector3D)getBoneWithRotation:(uintptr_t)mesh ID:(int)Id publicObj:(FTransform)publicObj
{
    FTransform BoneMatrix;
    FVector3D output = {0, 0, 0};
    
    uintptr_t addr;
    if (![self readMemory:mesh + 0x6f0 size:sizeof(uintptr_t) buffer:&addr]) {
        return output;
    }
    BoneMatrix = [self getMatrixConversion:addr + Id * 0x30];
    
    D3DXMATRIX LocalSkeletonMatrix = [self toMatrixWithScale:BoneMatrix.Rotation
                                                 translation:BoneMatrix.Translation
                                                     scale3D:BoneMatrix.Scale3D];
    
    D3DXMATRIX PartTotheWorld = [self toMatrixWithScale:publicObj.Rotation
                                            translation:publicObj.Translation
                                                scale3D:publicObj.Scale3D];
    
    D3DXMATRIX NewMatrix = [self matrixMultiplication:LocalSkeletonMatrix
                                                   M2:PartTotheWorld];
    
    FVector3D BoneCoordinates;
    BoneCoordinates.X = NewMatrix._41;
    BoneCoordinates.Y = NewMatrix._42;
    BoneCoordinates.Z = NewMatrix._43;
    
    return BoneCoordinates;
}
- (void)fetchData:(GameInfo)gameInfo block:(PUBGDrawDataFactoryFetchDataBlock)block
{
    NSMutableArray *playerArray = @[].mutableCopy;
    
    self.gameInfo = gameInfo;
    if (!self.gameInfo.base) {
        return;
    }
    if (self.gameInfo.task==-1) {
        return;
    }
    
    NSLog(@"[yiming] name: %@ / pid: %d / task: %d / base: %lu", gameInfo.name, gameInfo.pid, gameInfo.task, gameInfo.base);
    
    self.gnamePtr = [self readPtr:self.gameInfo.base + 0xA733268];
    if (![self isValidAddress:self.gnamePtr]) {
        return;
    }
    
    self.gworldPtr = [self readPtr:self.gameInfo.base + 0xAAB00C0];
    if (![self isValidAddress:self.gworldPtr]) {
        return;
    }
    
    uintptr_t NetDriver = [self readPtr:self.gworldPtr + 0x98];//Class: World.Object//NetDriver* NetDriver
    if (![self isValidAddress:NetDriver]) {
        return;
    }
    
    uintptr_t ServerConnection = [self readPtr:NetDriver + 0x88];//Class: NetDriver.Object//NetConnection* ServerConnection
    if (![self isValidAddress:ServerConnection]) {
        return;
    }
    
    uintptr_t PlayerController = [self readPtr:ServerConnection + 0x98];//Class: World.Object
    if (![self isValidAddress:PlayerController]) {
        PlayerController = [self readPtr:ServerConnection + 0x30];//Class: World.Object
    }
    if (![self isValidAddress:PlayerController]) {
        return;
    }
    
    uintptr_t PlayerCameraManager = [self readPtr:PlayerController + 0x758];//Class: PlayerController.Controller.Actor.Object//PlayerCameraManager* PlayerCameraManager
    if (![self isValidAddress:PlayerCameraManager]) {
        return;
    }
    
    FMinimalViewInfo POV;
    //Class: PlayerCameraManager.Actor.Object//TViewTarget ViewTarget
    if (![self readMemory:PlayerCameraManager + 0x12e0 + 0x10 size:sizeof(FMinimalViewInfo) buffer:&POV]) {
        return;
    }
    
    uintptr_t Character = [self readPtr:PlayerController + 0x6d0];//Class: Controller.Actor.Object//Character* Character
//    if (![self isValidAddress:Character]) {
//        Character = [self readPtr:PlayerController + 0x6e0];//Class: Controller.Actor.Object//Character* Character
//    }
//    if (![self isValidAddress:Character]) {
//        return;
//    }
    
    uintptr_t PersistentLevel = [self readPtr:self.gworldPtr + 0x90];//Level* PersistentLevel
    if (![self isValidAddress:PersistentLevel]) {
        return;
    }
    
    uintptr_t actorList = [self readPtr:PersistentLevel + 0xA0];
    if (![self isValidAddress:actorList]) {
        return;
    }
    
    uintptr_t WeaponManagerComponent =Read<uintptr_t>(_gameInfo.task, Character+ 0x24e0);//CharacterWeaponManagerComponent* WeaponManagerComponent
    
    uintptr_t CurrentWeaponReplicated =Read<uintptr_t>(_gameInfo.task, WeaponManagerComponent+ 0x728);//STExtraWeapon* CurrentWeaponReplicated
    
    uintptr_t ShootWeaponEntityComp=Read<uintptr_t>(_gameInfo.task, CurrentWeaponReplicated+ 0x12f8);//ShootWeaponEntity* ShootWeaponEntityComp
    
    // 枪支无后座力
        if(无后开关){
    float RecoilKickADS = 0.04;
    [self writeMemory1:ShootWeaponEntityComp + 0x16b0 size:sizeof(float) buffer:&RecoilKickADS];
        }
        if (聚点开关) {
            float RecoilKickADS = 0.001;
    [self writeMemory1:ShootWeaponEntityComp + 0x16fc size:sizeof(float) buffer:&RecoilKickADS];
    [self writeMemory1:ShootWeaponEntityComp + 0x1700 size:sizeof(float) buffer:&RecoilKickADS];
    [self writeMemory1:ShootWeaponEntityComp + 0x1704 size:sizeof(float) buffer:&RecoilKickADS];
    [self writeMemory1:ShootWeaponEntityComp + 0x1708 size:sizeof(float) buffer:&RecoilKickADS];
        }
    
    
    int actorCount = [self readInt:PersistentLevel + 0xA8];
    if (actorCount > 0 && actorCount < 50000) {
        for (int i = 0; i < actorCount; i++) {
            
            uintptr_t actor = [self readPtr:actorList + i * 8];
            uintptr_t player = actor;
            //排除自己
            if (player == Character) {
                continue;
            }
            //排除自己
            int FNameID = [self readInt:actor + 0x18];
            NSString *ClassName = [self getFNameFromID:FNameID];
            
            long VehicleCommonComponent=[self readlong:actor+0x9f0];//Class: STExtraVehicleBase.Pawn.Actor.Object//VehicleCommonComponent* VehicleCommon
            float VehicleHP = [self readFloat:VehicleCommonComponent + 0x1E0];//Class: VehicleCommonComponent.VehicleComponent.ActorComponent.Object//float HP
            float VehicleFuelMax = [self readFloat:VehicleCommonComponent + 0x1fc];//Class: VehicleCommonComponent.VehicleComponent.ActorComponent.Object//float FuelMax
            float VehicleFuel = [self readFloat:VehicleCommonComponent + 0x200];//Class: VehicleCommonComponent.VehicleComponent.ActorComponent.Object//float Fuel
            
            VehicleFuel= 100 * VehicleFuel / VehicleFuelMax;
            
            BOOL zaijuidaa=[self readBool:actor+0x60c];//Class: UAEGameMode.GameMode.GameModeBase.Info.Actor.Object//bool bEnableClimbing
            
            
            float Health = [self readFloat:player + 0xec8];//Class: STExtraCharacter.UAECharacter.Character.Pawn.Actor.Object//float Health
            float HealthMax = [self readFloat:player + 0xed0];//Class: STExtraCharacter.UAECharacter.Character.Pawn.Actor.Object//float HealthMax
            
            FVector3D WorldLocation = [self getRelativeLocation:player];
            
            //
            float distance = [self getDistance:WorldLocation b:POV.Location] / 100;
            if (distance > 600) {
                continue;
            }
            float wuzijuli = [self getDistance:WorldLocation b:POV.Location] / 100;
            if (distance > 600) {
                continue;
            }
            if ([ClassName containsString:@"PlayerPawn"]) {
                
                //Class: STExtraCharacter.UAECharacter.Character.Pawn.Actor.Object//bool bDead
                bool bDead = [self readBool:player + 0xf30] & 1;
                if (bDead) {
                    continue;
                }
                
                //Class: UAECharacter.Character.Pawn.Actor.Object//int TeamID
                int TeamID = [self readInt:player + 0xbc0];
                
                int MyTeamID = [self readInt:PlayerController + 0xb00];
                if (TeamID == MyTeamID) {
                    continue;
                }
                uintptr_t MyShootWeaponEntityComp = 0;
                //        uintptr_t statusAddr = Read<long>(Character + I64("0xf70"));
                //        if(statusAddr==147){
                //        setspeed(PlayerController,jiasua1);
                //        }
                
                uintptr_t WeaponManagerComponent = [self readPtr:player+0x24e0];//CharacterWeaponManagerComponent* WeaponManagerComponent
                
                int WeaponId2 = 0;
                if (IsValidAddress(WeaponManagerComponent)) {
                    
                    uintptr_t CurrentWeaponReplicated = [self readPtr:WeaponManagerComponent+0x728];//STExtraWeapon* CurrentWeaponReplicated
                    
                    if (IsValidAddress(CurrentWeaponReplicated)) {
                        
                        MyShootWeaponEntityComp = [self readPtr:CurrentWeaponReplicated+0x12f8];//ShootWeaponEntity* ShootWeaponEntityComp
                        
                        if (IsValidAddress(MyShootWeaponEntityComp)) {
                            WeaponId2= [self readInt:MyShootWeaponEntityComp+0x148];//Class: WeaponEntity.WeaponLogicBaseComponent.ActorComponent.Object//int WeaponID
                            
                            
                            
                        }
                    }
                }
                
                //Class: UAECharacter.Character.Pawn.Actor.Object//bool bIsAI
                BOOL bIsAI = [self readBool:player + 0xbdc] != 0;
                
                //
                FVectorRect rect;
                [self worldToScreenForRect:WorldLocation camViewInfo:POV canvas:self.canvas outRect:&rect];
                
                
                //
                PUBGPlayerModel *model = [[PUBGPlayerModel alloc] init];
                model.TeamID = TeamID;
                model.Health = (Health / HealthMax * 100) / 100;
                model.Distance = distance;
                model.zaijuxue=VehicleHP;
                //                model.zaijuyou=VehicleFuel;
                model.zaijuid=zaijuidaa;
                
                model.chiqiang=WeaponId2;
                model.isAI = bIsAI;
                model.PlayerName = [self getPlayerName:player];
                model.rect = CGRectMake(rect.X, rect.Y, rect.W, rect.H);
                //获取骨骼数据
                uintptr_t Mesh = [self readPtr:player + 0x750];
                   if (![self isValidAddress:Mesh]) {
                    return;
                }
                FTransform RelativeScale3D = [self getMatrixConversion:Mesh + 0x1C0];//查一下 是否改变
                
                int Bones[18] = {6,5,4,3,2,1,12,13,14,33,34,35,53,54,55,57,58,59};
                
                FVector2D Bones_Pos[18];
                FVector3D Hitpart[18];
                
                for (int i = 0; i < 18; i++) {
                    FVector3D boneWorldLocation = [self getBoneWithRotation:Mesh ID:Bones[i] publicObj:RelativeScale3D];
                    Hitpart[i] = boneWorldLocation;
                    Bones_Pos[i] = [self worldToScreen:boneWorldLocation camViewInfo:POV canvas:self.canvas];
                }
                //骨骼模型
                PUBGPlayerBone *bone = [[PUBGPlayerBone alloc] init];
                bone._0 = Bones_Pos[0];
                bone._1 = Bones_Pos[1];
                bone._2 = Bones_Pos[2];
                bone._3 = Bones_Pos[3];
                bone._4 = Bones_Pos[4];
                bone._5 = Bones_Pos[5];
                bone._6 = Bones_Pos[6];
                bone._7 = Bones_Pos[7];
                bone._8 = Bones_Pos[8];
                bone._9 = Bones_Pos[9];
                bone._10 = Bones_Pos[10];
                bone._11 = Bones_Pos[11];
                bone._12 = Bones_Pos[12];
                bone._13 = Bones_Pos[13];
                bone._14 = Bones_Pos[14];
                bone._15 = Bones_Pos[15];
                bone._16 = Bones_Pos[16];
                bone._17 = Bones_Pos[17];
                model.bone = bone;
                
                //模型添加到数组
                [playerArray addObject:model];
                
                
                
            }
#pragma mark - 车辆
            if (载具开关) {
                if ([ClassName containsString:@"VH_Scooter_"]) {
                    if (wuzijuli > 2 && wuzijuli <= 600) {
                        
                        FVectorRect rect;
                        [self worldToScreenForRect:WorldLocation camViewInfo:POV canvas:self.canvas outRect:&rect];
                        if (rect.X > kScreenWidth)
                            continue;
                        
                        float height = rect.Y - rect.Y;
                        float width  = height / 2;
                        
                        float originX = rect.X - width / 2;
                        float originY = rect.Y;
                        
                        
                        PUBGPlayerModel *model = [[PUBGPlayerModel alloc] init];
                        model.flag = 1;
                        model.wuzimi = wuzijuli;
                        model.wuzi = CGRectMake(originX, originY, width, height);
                        [playerArray addObject:model];
                    }
                    
                }  if ([ClassName containsString:@"VH_Motorcycle_"]) {
                    if (wuzijuli > 2 && wuzijuli <= 600) {
                        
                        FVectorRect rect;
                        [self worldToScreenForRect:WorldLocation camViewInfo:POV canvas:self.canvas outRect:&rect];
                        if (rect.X > kScreenWidth)
                            continue;
                        
                        float height = rect.Y - rect.Y;
                        float width  = height / 2;
                        
                        float originX = rect.X - width / 2;
                        float originY = rect.Y;
                        
                        
                        PUBGPlayerModel *model = [[PUBGPlayerModel alloc] init];
                        model.flag = 2;
                        model.wuzimi = wuzijuli;
                        model.wuzi = CGRectMake(originX, originY, width, height);
                        [playerArray addObject:model];
                    }
                } if ([ClassName containsString:@"VH_MotorcycleCart_"]) {
                    if (wuzijuli > 2 && wuzijuli <= 600) {
                        
                        FVectorRect rect;
                        [self worldToScreenForRect:WorldLocation camViewInfo:POV canvas:self.canvas outRect:&rect];
                        if (rect.X > kScreenWidth)
                            continue;
                        
                        float height = rect.Y - rect.Y;
                        float width  = height / 2;
                        
                        float originX = rect.X - width / 2;
                        float originY = rect.Y;
                        
                        
                        PUBGPlayerModel *model = [[PUBGPlayerModel alloc] init];
                        model.flag = 3;
                        model.wuzimi = wuzijuli;
                        model.wuzi = CGRectMake(originX, originY, width, height);
                        [playerArray addObject:model];
                    }
                }
                if ([ClassName containsString:@"BP_VH_Tuk_"]) {
                    if (wuzijuli > 2 && wuzijuli <= 600) {
                        
                        FVectorRect rect;
                        [self worldToScreenForRect:WorldLocation camViewInfo:POV canvas:self.canvas outRect:&rect];
                        if (rect.X > kScreenWidth)
                            continue;
                        
                        float height = rect.Y - rect.Y;
                        float width  = height / 2;
                        
                        float originX = rect.X - width / 2;
                        float originY = rect.Y;
                        
                        
                        PUBGPlayerModel *model = [[PUBGPlayerModel alloc] init];
                        model.flag = 4;
                        model.wuzimi = wuzijuli;
                        model.wuzi = CGRectMake(originX, originY, width, height);
                        [playerArray addObject:model];
                    }
                }
                if ([ClassName containsString:@"BP_VH_Buggy_"]) {
                    if (wuzijuli > 2 && wuzijuli <= 600) {
                        
                        FVectorRect rect;
                        [self worldToScreenForRect:WorldLocation camViewInfo:POV canvas:self.canvas outRect:&rect];
                        if (rect.X > kScreenWidth)
                            continue;
                        
                        float height = rect.Y - rect.Y;
                        float width  = height / 2;
                        
                        float originX = rect.X - width / 2;
                        float originY = rect.Y;
                        
                        
                        PUBGPlayerModel *model = [[PUBGPlayerModel alloc] init];
                        model.flag = 5;
                        model.wuzimi = wuzijuli;
                        model.wuzi = CGRectMake(originX, originY, width, height);
                        [playerArray addObject:model];
                    }
                }
                if ([ClassName containsString:@"PickUp_0"]) {
                    if (wuzijuli > 2 && wuzijuli <= 600) {
                        
                        FVectorRect rect;
                        [self worldToScreenForRect:WorldLocation camViewInfo:POV canvas:self.canvas outRect:&rect];
                        if (rect.X > kScreenWidth)
                            continue;
                        
                        float height = rect.Y - rect.Y;
                        float width  = height / 2;
                        
                        float originX = rect.X - width / 2;
                        float originY = rect.Y;
                        
                        
                        PUBGPlayerModel *model = [[PUBGPlayerModel alloc] init];
                        model.flag = 6;
                        model.wuzimi = wuzijuli;
                        model.wuzi = CGRectMake(originX, originY, width, height);
                        [playerArray addObject:model];
                    }
                }
                if ([ClassName containsString:@"Mirado_"]) {
                    if (wuzijuli > 2 && wuzijuli <= 600) {
                        
                        FVectorRect rect;
                        [self worldToScreenForRect:WorldLocation camViewInfo:POV canvas:self.canvas outRect:&rect];
                        if (rect.X > kScreenWidth)
                            continue;
                        
                        float height = rect.Y - rect.Y;
                        float width  = height / 2;
                        
                        float originX = rect.X - width / 2;
                        float originY = rect.Y;
                        
                        
                        PUBGPlayerModel *model = [[PUBGPlayerModel alloc] init];
                        model.flag = 7;
                        model.wuzimi = wuzijuli;
                        model.wuzi = CGRectMake(originX, originY, width, height);
                        [playerArray addObject:model];
                    }
                }
                if ([ClassName containsString:@"VH_Dacia_"]) {
                    if (wuzijuli > 2 && wuzijuli <= 600) {
                        
                        FVectorRect rect;
                        [self worldToScreenForRect:WorldLocation camViewInfo:POV canvas:self.canvas outRect:&rect];
                        if (rect.X > kScreenWidth)
                            continue;
                        
                        float height = rect.Y - rect.Y;
                        float width  = height / 2;
                        
                        float originX = rect.X - width / 2;
                        float originY = rect.Y;
                        
                        
                        PUBGPlayerModel *model = [[PUBGPlayerModel alloc] init];
                        model.flag = 8;
                        model.wuzimi = wuzijuli;
                        model.wuzi = CGRectMake(originX, originY, width, height);
                        [playerArray addObject:model];
                    }
                }
                if ([ClassName containsString:@"AquaRail_"]) {
                    if (wuzijuli > 2 && wuzijuli <= 600) {
                        
                        FVectorRect rect;
                        [self worldToScreenForRect:WorldLocation camViewInfo:POV canvas:self.canvas outRect:&rect];
                        if (rect.X > kScreenWidth)
                            continue;
                        
                        float height = rect.Y - rect.Y;
                        float width  = height / 2;
                        
                        float originX = rect.X - width / 2;
                        float originY = rect.Y;
                        
                        
                        PUBGPlayerModel *model = [[PUBGPlayerModel alloc] init];
                        model.flag = 9;
                        model.wuzimi = wuzijuli;
                        model.wuzi = CGRectMake(originX, originY, width, height);
                        [playerArray addObject:model];
                    }
                }
                if ([ClassName containsString:@"BP_VH_CoupeRB_"]) {
                    if (wuzijuli > 2 && wuzijuli <= 600) {
                        
                        FVectorRect rect;
                        [self worldToScreenForRect:WorldLocation camViewInfo:POV canvas:self.canvas outRect:&rect];
                        if (rect.X > kScreenWidth)
                            continue;
                        
                        float height = rect.Y - rect.Y;
                        float width  = height / 2;
                        
                        float originX = rect.X - width / 2;
                        float originY = rect.Y;
                        
                        
                        PUBGPlayerModel *model = [[PUBGPlayerModel alloc] init];
                        model.flag = 10;
                        model.wuzimi = wuzijuli;
                        model.wuzi = CGRectMake(originX, originY, width, height);
                        [playerArray addObject:model];
                    }
                }
                if ([ClassName containsString:@"VH_MiniBus_"]) {
                    if (wuzijuli > 2 && wuzijuli <= 600) {
                        
                        FVectorRect rect;
                        [self worldToScreenForRect:WorldLocation camViewInfo:POV canvas:self.canvas outRect:&rect];
                        if (rect.X > kScreenWidth)
                            continue;
                        
                        float height = rect.Y - rect.Y;
                        float width  = height / 2;
                        
                        float originX = rect.X - width / 2;
                        float originY = rect.Y;
                        
                        
                        PUBGPlayerModel *model = [[PUBGPlayerModel alloc] init];
                        model.flag = 11;
                        model.wuzimi = wuzijuli;
                        model.wuzi = CGRectMake(originX, originY, width, height);
                        [playerArray addObject:model];
                    }
                }
                if ([ClassName containsString:@"VH_BRDM_"]) {
                    if (wuzijuli > 2 && wuzijuli <= 600) {
                        
                        FVectorRect rect;
                        [self worldToScreenForRect:WorldLocation camViewInfo:POV canvas:self.canvas outRect:&rect];
                        if (rect.X > kScreenWidth)
                            continue;
                        
                        float height = rect.Y - rect.Y;
                        float width  = height / 2;
                        
                        float originX = rect.X - width / 2;
                        float originY = rect.Y;
                        
                        
                        PUBGPlayerModel *model = [[PUBGPlayerModel alloc] init];
                        model.flag = 12;
                        model.wuzimi = wuzijuli;
                        model.wuzi = CGRectMake(originX, originY, width, height);
                        [playerArray addObject:model];
                    }
                }
                if ([ClassName containsString:@"VH_UAZ"]) {
                    if (wuzijuli > 2 && wuzijuli <= 600) {
                        
                        FVectorRect rect;
                        [self worldToScreenForRect:WorldLocation camViewInfo:POV canvas:self.canvas outRect:&rect];
                        if (rect.X > kScreenWidth)
                            continue;
                        
                        float height = rect.Y - rect.Y;
                        float width  = height / 2;
                        
                        float originX = rect.X - width / 2;
                        float originY = rect.Y;
                        
                        
                        PUBGPlayerModel *model = [[PUBGPlayerModel alloc] init];
                        model.flag = 13;
                        model.wuzimi = wuzijuli;
                        model.wuzi = CGRectMake(originX, originY, width, height);
                        [playerArray addObject:model];
                    }
                }
                if ([ClassName containsString:@"VH_Mountainbike_Training_C"]) {
                    if (wuzijuli > 2 && wuzijuli <= 600) {
                        
                        FVectorRect rect;
                        [self worldToScreenForRect:WorldLocation camViewInfo:POV canvas:self.canvas outRect:&rect];
                        if (rect.X > kScreenWidth)
                            continue;
                        
                        float height = rect.Y - rect.Y;
                        float width  = height / 2;
                        
                        float originX = rect.X - width / 2;
                        float originY = rect.Y;
                        
                        
                        PUBGPlayerModel *model = [[PUBGPlayerModel alloc] init];
                        model.flag = 14;
                        model.wuzimi = wuzijuli;
                        model.wuzi = CGRectMake(originX, originY, width, height);
                        [playerArray addObject:model];
                    }
                }
            }
#pragma mark - 枪械
            if (枪械开关) {
                if ([ClassName containsString:@"BP_Rifle_VAL_Wrapper_C"]) {
                    if (wuzijuli > 2 && wuzijuli <= 50) {
                        
                        FVectorRect rect;
                        [self worldToScreenForRect:WorldLocation camViewInfo:POV canvas:self.canvas outRect:&rect];
                        if (rect.X > kScreenWidth)
                            continue;
                        
                        float height = rect.Y - rect.Y;
                        float width  = height / 2;
                        
                        float originX = rect.X - width / 2;
                        float originY = rect.Y;
                        
                        
                        PUBGPlayerModel *model = [[PUBGPlayerModel alloc] init];
                        model.flag = 15;
                        model.wuzimi = wuzijuli;
                        model.wuzi = CGRectMake(originX, originY, width, height);
                        [playerArray addObject:model];
                    }
                }
                if ([ClassName containsString:@"BP_MachineGun_MP5K_Wrapper"]) {
                    if (wuzijuli > 2 && wuzijuli <= 50) {
                        
                        FVectorRect rect;
                        [self worldToScreenForRect:WorldLocation camViewInfo:POV canvas:self.canvas outRect:&rect];
                        if (rect.X > kScreenWidth)
                            continue;
                        
                        float height = rect.Y - rect.Y;
                        float width  = height / 2;
                        
                        float originX = rect.X - width / 2;
                        float originY = rect.Y;
                        
                        
                        PUBGPlayerModel *model = [[PUBGPlayerModel alloc] init];
                        model.flag = 16;
                        model.wuzimi = wuzijuli;
                        model.wuzi = CGRectMake(originX, originY, width, height);
                        [playerArray addObject:model];
                    }
                }
                if ([ClassName containsString:@"BP_MachineGun_P90_Wrapper"]) {
                    if (wuzijuli > 2 && wuzijuli <= 50) {
                        
                        FVectorRect rect;
                        [self worldToScreenForRect:WorldLocation camViewInfo:POV canvas:self.canvas outRect:&rect];
                        if (rect.X > kScreenWidth)
                            continue;
                        
                        float height = rect.Y - rect.Y;
                        float width  = height / 2;
                        
                        float originX = rect.X - width / 2;
                        float originY = rect.Y;
                        
                        
                        PUBGPlayerModel *model = [[PUBGPlayerModel alloc] init];
                        model.flag = 17;
                        model.wuzimi = wuzijuli;
                        model.wuzi = CGRectMake(originX, originY, width, height);
                        [playerArray addObject:model];
                    }
                }
                if ([ClassName containsString:@"BP_MachineGun_pp19_Wrapper"]) {
                    if (wuzijuli > 2 && wuzijuli <= 50) {
                        
                        FVectorRect rect;
                        [self worldToScreenForRect:WorldLocation camViewInfo:POV canvas:self.canvas outRect:&rect];
                        if (rect.X > kScreenWidth)
                            continue;
                        
                        float height = rect.Y - rect.Y;
                        float width  = height / 2;
                        
                        float originX = rect.X - width / 2;
                        float originY = rect.Y;
                        
                        
                        PUBGPlayerModel *model = [[PUBGPlayerModel alloc] init];
                        model.flag = 18;
                        model.wuzimi = wuzijuli;
                        model.wuzi = CGRectMake(originX, originY, width, height);
                        [playerArray addObject:model];
                    }
                }
                if ([ClassName containsString:@"BP_MachineGun_TommyGun_Wrapper"]) {
                    if (wuzijuli > 2 && wuzijuli <= 50) {
                        
                        FVectorRect rect;
                        [self worldToScreenForRect:WorldLocation camViewInfo:POV canvas:self.canvas outRect:&rect];
                        if (rect.X > kScreenWidth)
                            continue;
                        
                        float height = rect.Y - rect.Y;
                        float width  = height / 2;
                        
                        float originX = rect.X - width / 2;
                        float originY = rect.Y;
                        
                        
                        PUBGPlayerModel *model = [[PUBGPlayerModel alloc] init];
                        model.flag = 19;
                        model.wuzimi = wuzijuli;
                        model.wuzi = CGRectMake(originX, originY, width, height);
                        [playerArray addObject:model];
                    }
                }
                if ([ClassName containsString:@"BP_MachineGun_UMP9_Wrapper"]) {
                    if (wuzijuli > 2 && wuzijuli <= 50) {
                        
                        FVectorRect rect;
                        [self worldToScreenForRect:WorldLocation camViewInfo:POV canvas:self.canvas outRect:&rect];
                        if (rect.X > kScreenWidth)
                            continue;
                        
                        float height = rect.Y - rect.Y;
                        float width  = height / 2;
                        
                        float originX = rect.X - width / 2;
                        float originY = rect.Y;
                        
                        
                        PUBGPlayerModel *model = [[PUBGPlayerModel alloc] init];
                        model.flag = 20;
                        model.wuzimi = wuzijuli;
                        model.wuzi = CGRectMake(originX, originY, width, height);
                        [playerArray addObject:model];
                    }
                }
                if ([ClassName containsString:@"BP_MachineGun_Uzi_Wrapper"]) {
                    if (wuzijuli > 2 && wuzijuli <= 50) {
                        
                        FVectorRect rect;
                        [self worldToScreenForRect:WorldLocation camViewInfo:POV canvas:self.canvas outRect:&rect];
                        if (rect.X > kScreenWidth)
                            continue;
                        
                        float height = rect.Y - rect.Y;
                        float width  = height / 2;
                        
                        float originX = rect.X - width / 2;
                        float originY = rect.Y;
                        
                        
                        PUBGPlayerModel *model = [[PUBGPlayerModel alloc] init];
                        model.flag = 21;
                        model.wuzimi = wuzijuli;
                        model.wuzi = CGRectMake(originX, originY, width, height);
                        [playerArray addObject:model];
                    }
                }
                if ([ClassName containsString:@"BP_MachineGun_Vector_Wrapper"]) {
                    if (wuzijuli > 2 && wuzijuli <= 50) {
                        
                        FVectorRect rect;
                        [self worldToScreenForRect:WorldLocation camViewInfo:POV canvas:self.canvas outRect:&rect];
                        if (rect.X > kScreenWidth)
                            continue;
                        
                        float height = rect.Y - rect.Y;
                        float width  = height / 2;
                        
                        float originX = rect.X - width / 2;
                        float originY = rect.Y;
                        
                        
                        PUBGPlayerModel *model = [[PUBGPlayerModel alloc] init];
                        model.flag = 22;
                        model.wuzimi = wuzijuli;
                        model.wuzi = CGRectMake(originX, originY, width, height);
                        [playerArray addObject:model];
                    }
                }
                if ([ClassName containsString:@"BP_Sniper_Mini14_Wrapper"]) {
                    if (wuzijuli > 2 && wuzijuli <= 50) {
                        
                        FVectorRect rect;
                        [self worldToScreenForRect:WorldLocation camViewInfo:POV canvas:self.canvas outRect:&rect];
                        if (rect.X > kScreenWidth)
                            continue;
                        
                        float height = rect.Y - rect.Y;
                        float width  = height / 2;
                        
                        float originX = rect.X - width / 2;
                        float originY = rect.Y;
                        
                        
                        PUBGPlayerModel *model = [[PUBGPlayerModel alloc] init];
                        model.flag = 23;
                        model.wuzimi = wuzijuli;
                        model.wuzi = CGRectMake(originX, originY, width, height);
                        [playerArray addObject:model];
                    }
                }
                if ([ClassName containsString:@"BP_Sniper_MK12_Wrapper"]) {
                    if (wuzijuli > 2 && wuzijuli <= 50) {
                        
                        FVectorRect rect;
                        [self worldToScreenForRect:WorldLocation camViewInfo:POV canvas:self.canvas outRect:&rect];
                        if (rect.X > kScreenWidth)
                            continue;
                        
                        float height = rect.Y - rect.Y;
                        float width  = height / 2;
                        
                        float originX = rect.X - width / 2;
                        float originY = rect.Y;
                        
                        
                        PUBGPlayerModel *model = [[PUBGPlayerModel alloc] init];
                        model.flag = 24;
                        model.wuzimi = wuzijuli;
                        model.wuzi = CGRectMake(originX, originY, width, height);
                        [playerArray addObject:model];
                    }
                }
                if ([ClassName containsString:@"BP_Sniper_MK14_Wrapper"]) {
                    if (wuzijuli > 2 && wuzijuli <= 50) {
                        
                        FVectorRect rect;
                        [self worldToScreenForRect:WorldLocation camViewInfo:POV canvas:self.canvas outRect:&rect];
                        if (rect.X > kScreenWidth)
                            continue;
                        
                        float height = rect.Y - rect.Y;
                        float width  = height / 2;
                        
                        float originX = rect.X - width / 2;
                        float originY = rect.Y;
                        
                        
                        PUBGPlayerModel *model = [[PUBGPlayerModel alloc] init];
                        model.flag = 25;
                        model.wuzimi = wuzijuli;
                        model.wuzi = CGRectMake(originX, originY, width, height);
                        [playerArray addObject:model];
                    }
                }
                if ([ClassName containsString:@"BP_Sniper_QBU_Wrapper"]) {
                    if (wuzijuli > 2 && wuzijuli <= 50) {
                        
                        FVectorRect rect;
                        [self worldToScreenForRect:WorldLocation camViewInfo:POV canvas:self.canvas outRect:&rect];
                        if (rect.X > kScreenWidth)
                            continue;
                        
                        float height = rect.Y - rect.Y;
                        float width  = height / 2;
                        
                        float originX = rect.X - width / 2;
                        float originY = rect.Y;
                        
                        
                        PUBGPlayerModel *model = [[PUBGPlayerModel alloc] init];
                        model.flag = 26;
                        model.wuzimi = wuzijuli;
                        model.wuzi = CGRectMake(originX, originY, width, height);
                        [playerArray addObject:model];
                    }
                }
                if ([ClassName containsString:@"BP_Sniper_SKS_Wrapper"]) {
                    if (wuzijuli > 2 && wuzijuli <= 50) {
                        
                        FVectorRect rect;
                        [self worldToScreenForRect:WorldLocation camViewInfo:POV canvas:self.canvas outRect:&rect];
                        if (rect.X > kScreenWidth)
                            continue;
                        
                        float height = rect.Y - rect.Y;
                        float width  = height / 2;
                        
                        float originX = rect.X - width / 2;
                        float originY = rect.Y;
                        
                        
                        PUBGPlayerModel *model = [[PUBGPlayerModel alloc] init];
                        model.flag = 27;
                        model.wuzimi = wuzijuli;
                        model.wuzi = CGRectMake(originX, originY, width, height);
                        [playerArray addObject:model];
                    }
                }
                if ([ClassName containsString:@"BP_Sniper_SLR_Wrapper"]) {
                    if (wuzijuli > 2 && wuzijuli <= 50) {
                        
                        FVectorRect rect;
                        [self worldToScreenForRect:WorldLocation camViewInfo:POV canvas:self.canvas outRect:&rect];
                        if (rect.X > kScreenWidth)
                            continue;
                        
                        float height = rect.Y - rect.Y;
                        float width  = height / 2;
                        
                        float originX = rect.X - width / 2;
                        float originY = rect.Y;
                        
                        
                        PUBGPlayerModel *model = [[PUBGPlayerModel alloc] init];
                        model.flag = 28;
                        model.wuzimi = wuzijuli;
                        model.wuzi = CGRectMake(originX, originY, width, height);
                        [playerArray addObject:model];
                    }
                }
                if ([ClassName containsString:@"BP_Sniper_VSS_Wrapper"]) {
                    if (wuzijuli > 2 && wuzijuli <= 50) {
                        
                        FVectorRect rect;
                        [self worldToScreenForRect:WorldLocation camViewInfo:POV canvas:self.canvas outRect:&rect];
                        if (rect.X > kScreenWidth)
                            continue;
                        
                        float height = rect.Y - rect.Y;
                        float width  = height / 2;
                        
                        float originX = rect.X - width / 2;
                        float originY = rect.Y;
                        
                        
                        PUBGPlayerModel *model = [[PUBGPlayerModel alloc] init];
                        model.flag = 29;
                        model.wuzimi = wuzijuli;
                        model.wuzi = CGRectMake(originX, originY, width, height);
                        [playerArray addObject:model];
                    }
                }
                if ([ClassName containsString:@"BP_Sniper_AWM_Wrapper"]) {
                    if (wuzijuli > 2 && wuzijuli <= 50) {
                        
                        FVectorRect rect;
                        [self worldToScreenForRect:WorldLocation camViewInfo:POV canvas:self.canvas outRect:&rect];
                        if (rect.X > kScreenWidth)
                            continue;
                        
                        float height = rect.Y - rect.Y;
                        float width  = height / 2;
                        
                        float originX = rect.X - width / 2;
                        float originY = rect.Y;
                        
                        
                        PUBGPlayerModel *model = [[PUBGPlayerModel alloc] init];
                        model.flag = 30;
                        model.wuzimi = wuzijuli;
                        model.wuzi = CGRectMake(originX, originY, width, height);
                        [playerArray addObject:model];
                    }
                }
                if ([ClassName containsString:@"BP_Sniper_M24_Wrapper"]) {
                    if (wuzijuli > 2 && wuzijuli <= 50) {
                        
                        FVectorRect rect;
                        [self worldToScreenForRect:WorldLocation camViewInfo:POV canvas:self.canvas outRect:&rect];
                        if (rect.X > kScreenWidth)
                            continue;
                        
                        float height = rect.Y - rect.Y;
                        float width  = height / 2;
                        
                        float originX = rect.X - width / 2;
                        float originY = rect.Y;
                        
                        
                        PUBGPlayerModel *model = [[PUBGPlayerModel alloc] init];
                        model.flag = 31;
                        model.wuzimi = wuzijuli;
                        model.wuzi = CGRectMake(originX, originY, width, height);
                        [playerArray addObject:model];
                    }
                }
                if ([ClassName containsString:@"BP_Rifle_AKM_Wrapper_C"]) {
                    if (wuzijuli > 2 && wuzijuli <= 50) {
                        
                        FVectorRect rect;
                        [self worldToScreenForRect:WorldLocation camViewInfo:POV canvas:self.canvas outRect:&rect];
                        if (rect.X > kScreenWidth)
                            continue;
                        
                        float height = rect.Y - rect.Y;
                        float width  = height / 2;
                        
                        float originX = rect.X - width / 2;
                        float originY = rect.Y;
                        
                        
                        PUBGPlayerModel *model = [[PUBGPlayerModel alloc] init];
                        model.flag = 32;
                        model.wuzimi = wuzijuli;
                        model.wuzi = CGRectMake(originX, originY, width, height);
                        [playerArray addObject:model];
                    }
                }
                if ([ClassName containsString:@"BP_Rifle_M416_Wrapper_C"]) {
                    if (wuzijuli > 2 && wuzijuli <= 50) {
                        
                        FVectorRect rect;
                        [self worldToScreenForRect:WorldLocation camViewInfo:POV canvas:self.canvas outRect:&rect];
                        if (rect.X > kScreenWidth)
                            continue;
                        
                        float height = rect.Y - rect.Y;
                        float width  = height / 2;
                        
                        float originX = rect.X - width / 2;
                        float originY = rect.Y;
                        
                        
                        PUBGPlayerModel *model = [[PUBGPlayerModel alloc] init];
                        model.flag = 33;
                        model.wuzimi = wuzijuli;
                        model.wuzi = CGRectMake(originX, originY, width, height);
                        [playerArray addObject:model];
                    }
                }
                if ([ClassName containsString:@"BP_Rifle_AUG_Wrapper_C"]) {
                    if (wuzijuli > 2 && wuzijuli <= 600) {
                        
                        FVectorRect rect;
                        [self worldToScreenForRect:WorldLocation camViewInfo:POV canvas:self.canvas outRect:&rect];
                        if (rect.X > kScreenWidth)
                            continue;
                        
                        float height = rect.Y - rect.Y;
                        float width  = height / 2;
                        
                        float originX = rect.X - width / 2;
                        float originY = rect.Y;
                        
                        
                        PUBGPlayerModel *model = [[PUBGPlayerModel alloc] init];
                        model.flag = 34;
                        model.wuzimi = wuzijuli;
                        model.wuzi = CGRectMake(originX, originY, width, height);
                        [playerArray addObject:model];
                    }
                }
                if ([ClassName containsString:@"BP_Rifle_G36_Wrapper_C"]) {
                    if (wuzijuli > 2 && wuzijuli <= 50) {
                        
                        FVectorRect rect;
                        [self worldToScreenForRect:WorldLocation camViewInfo:POV canvas:self.canvas outRect:&rect];
                        if (rect.X > kScreenWidth)
                            continue;
                        
                        float height = rect.Y - rect.Y;
                        float width  = height / 2;
                        
                        float originX = rect.X - width / 2;
                        float originY = rect.Y;
                        
                        
                        PUBGPlayerModel *model = [[PUBGPlayerModel alloc] init];
                        model.flag = 35;
                        model.wuzimi = wuzijuli;
                        model.wuzi = CGRectMake(originX, originY, width, height);
                        [playerArray addObject:model];
                    }
                }
                if ([ClassName containsString:@"BP_Rifle_Groza_Wrapper_C"]) {
                    if (wuzijuli > 2 && wuzijuli <= 50) {
                        
                        FVectorRect rect;
                        [self worldToScreenForRect:WorldLocation camViewInfo:POV canvas:self.canvas outRect:&rect];
                        if (rect.X > kScreenWidth)
                            continue;
                        
                        float height = rect.Y - rect.Y;
                        float width  = height / 2;
                        
                        float originX = rect.X - width / 2;
                        float originY = rect.Y;
                        
                        
                        PUBGPlayerModel *model = [[PUBGPlayerModel alloc] init];
                        model.flag = 36;
                        model.wuzimi = wuzijuli;
                        model.wuzi = CGRectMake(originX, originY, width, height);
                        [playerArray addObject:model];
                    }
                }
                if ([ClassName containsString:@"BP_Rifle_M16A4_Wrapper_C"]) {
                    if (wuzijuli > 2 && wuzijuli <= 50) {
                        
                        FVectorRect rect;
                        [self worldToScreenForRect:WorldLocation camViewInfo:POV canvas:self.canvas outRect:&rect];
                        if (rect.X > kScreenWidth)
                            continue;
                        
                        float height = rect.Y - rect.Y;
                        float width  = height / 2;
                        
                        float originX = rect.X - width / 2;
                        float originY = rect.Y;
                        
                        
                        PUBGPlayerModel *model = [[PUBGPlayerModel alloc] init];
                        model.flag = 37;
                        model.wuzimi = wuzijuli;
                        model.wuzi = CGRectMake(originX, originY, width, height);
                        [playerArray addObject:model];
                    }
                }
                if ([ClassName containsString:@"BP_Rifle_M762_Wrapper_C"]) {
                    if (wuzijuli > 2 && wuzijuli <= 50) {
                        
                        FVectorRect rect;
                        [self worldToScreenForRect:WorldLocation camViewInfo:POV canvas:self.canvas outRect:&rect];
                        if (rect.X > kScreenWidth)
                            continue;
                        
                        float height = rect.Y - rect.Y;
                        float width  = height / 2;
                        
                        float originX = rect.X - width / 2;
                        float originY = rect.Y;
                        
                        
                        PUBGPlayerModel *model = [[PUBGPlayerModel alloc] init];
                        model.flag = 38;
                        model.wuzimi = wuzijuli;
                        model.wuzi = CGRectMake(originX, originY, width, height);
                        [playerArray addObject:model];
                    }
                }
                if ([ClassName containsString:@"BP_Rifle_Mk47_Wrapper_C"]) {
                    if (wuzijuli > 2 && wuzijuli <= 50) {
                        
                        FVectorRect rect;
                        [self worldToScreenForRect:WorldLocation camViewInfo:POV canvas:self.canvas outRect:&rect];
                        if (rect.X > kScreenWidth)
                            continue;
                        
                        float height = rect.Y - rect.Y;
                        float width  = height / 2;
                        
                        float originX = rect.X - width / 2;
                        float originY = rect.Y;
                        
                        
                        PUBGPlayerModel *model = [[PUBGPlayerModel alloc] init];
                        model.flag = 39;
                        model.wuzimi = wuzijuli;
                        model.wuzi = CGRectMake(originX, originY, width, height);
                        [playerArray addObject:model];
                    }
                }
                if ([ClassName containsString:@"BP_Rifle_DP28_Wrapper_C"]) {
                    if (wuzijuli > 2 && wuzijuli <= 50) {
                        
                        FVectorRect rect;
                        [self worldToScreenForRect:WorldLocation camViewInfo:POV canvas:self.canvas outRect:&rect];
                        if (rect.X > kScreenWidth)
                            continue;
                        
                        float height = rect.Y - rect.Y;
                        float width  = height / 2;
                        
                        float originX = rect.X - width / 2;
                        float originY = rect.Y;
                        
                        
                        PUBGPlayerModel *model = [[PUBGPlayerModel alloc] init];
                        model.flag = 40;
                        model.wuzimi = wuzijuli;
                        model.wuzi = CGRectMake(originX, originY, width, height);
                        [playerArray addObject:model];
                    }
                }
                if ([ClassName containsString:@"BP_Other_M249_Wrapper"]) {
                    if (wuzijuli > 2 && wuzijuli <= 50) {
                        
                        FVectorRect rect;
                        [self worldToScreenForRect:WorldLocation camViewInfo:POV canvas:self.canvas outRect:&rect];
                        if (rect.X > kScreenWidth)
                            continue;
                        
                        float height = rect.Y - rect.Y;
                        float width  = height / 2;
                        
                        float originX = rect.X - width / 2;
                        float originY = rect.Y;
                        
                        
                        PUBGPlayerModel *model = [[PUBGPlayerModel alloc] init];
                        model.flag = 41;
                        model.wuzimi = wuzijuli;
                        model.wuzi = CGRectMake(originX, originY, width, height);
                        [playerArray addObject:model];
                    }
                }
                if ([ClassName containsString:@"BP_Rifle_SCAR_Wrapper_C"]) {
                    if (wuzijuli > 2 && wuzijuli <= 50) {
                        
                        FVectorRect rect;
                        [self worldToScreenForRect:WorldLocation camViewInfo:POV canvas:self.canvas outRect:&rect];
                        if (rect.X > kScreenWidth)
                            continue;
                        
                        float height = rect.Y - rect.Y;
                        float width  = height / 2;
                        
                        float originX = rect.X - width / 2;
                        float originY = rect.Y;
                        
                        
                        PUBGPlayerModel *model = [[PUBGPlayerModel alloc] init];
                        model.flag = 42;
                        model.wuzimi = wuzijuli;
                        model.wuzi = CGRectMake(originX, originY, width, height);
                        [playerArray addObject:model];
                    }
                }
                if ([ClassName containsString:@"BP_Rifle_QBZ_Wrapper_C"]) {
                    if (wuzijuli > 2 && wuzijuli <= 50) {
                        
                        FVectorRect rect;
                        [self worldToScreenForRect:WorldLocation camViewInfo:POV canvas:self.canvas outRect:&rect];
                        if (rect.X > kScreenWidth)
                            continue;
                        
                        float height = rect.Y - rect.Y;
                        float width  = height / 2;
                        
                        float originX = rect.X - width / 2;
                        float originY = rect.Y;
                        
                        
                        PUBGPlayerModel *model = [[PUBGPlayerModel alloc] init];
                        model.flag = 43;
                        model.wuzimi = wuzijuli;
                        model.wuzi = CGRectMake(originX, originY, width, height);
                        [playerArray addObject:model];
                    }
                }
                if ([ClassName containsString:@"BP_Sniper_Kar98k_Wrapper_C"]) {
                    if (wuzijuli > 2 && wuzijuli <= 50) {
                        
                        FVectorRect rect;
                        [self worldToScreenForRect:WorldLocation camViewInfo:POV canvas:self.canvas outRect:&rect];
                        if (rect.X > kScreenWidth)
                            continue;
                        
                        float height = rect.Y - rect.Y;
                        float width  = height / 2;
                        
                        float originX = rect.X - width / 2;
                        float originY = rect.Y;
                        
                        
                        PUBGPlayerModel *model = [[PUBGPlayerModel alloc] init];
                        model.flag = 44;
                        model.wuzimi = wuzijuli;
                        model.wuzi = CGRectMake(originX, originY, width, height);
                        [playerArray addObject:model];
                    }
                }
            }
#pragma mark - 盔甲
            if (盔甲开关) {
                if ([ClassName containsString:@"PickUp_BP_Helmet_Lv1_C"]||[ClassName containsString:@"PickUp_BP_Helmet_Lv1_A_C"]||[ClassName containsString:@"PickUp_BP_Helmet_Lv1_B_C"]) {
                    if (wuzijuli > 2 && wuzijuli <= 50) {
                        
                        FVectorRect rect;
                        [self worldToScreenForRect:WorldLocation camViewInfo:POV canvas:self.canvas outRect:&rect];
                        if (rect.X > kScreenWidth)
                            continue;
                        
                        float height = rect.Y - rect.Y;
                        float width  = height / 2;
                        
                        float originX = rect.X - width / 2;
                        float originY = rect.Y;
                        
                        
                        PUBGPlayerModel *model = [[PUBGPlayerModel alloc] init];
                        model.flag = 46;
                        model.wuzimi = wuzijuli;
                        model.wuzi = CGRectMake(originX, originY, width, height);
                        [playerArray addObject:model];
                    }
                }
                if ([ClassName containsString:@"PickUp_BP_Armor_Lv1_C"]||[ClassName containsString:@"PickUp_BP_Armor_Lv1_A_C"]||[ClassName containsString:@"PickUp_BP_Armor_Lv1_B_C"]) {
                    if (wuzijuli > 2 && wuzijuli <= 50) {
                        
                        FVectorRect rect;
                        [self worldToScreenForRect:WorldLocation camViewInfo:POV canvas:self.canvas outRect:&rect];
                        if (rect.X > kScreenWidth)
                            continue;
                        
                        float height = rect.Y - rect.Y;
                        float width  = height / 2;
                        
                        float originX = rect.X - width / 2;
                        float originY = rect.Y;
                        
                        
                        PUBGPlayerModel *model = [[PUBGPlayerModel alloc] init];
                        model.flag = 47;
                        model.wuzimi = wuzijuli;
                        model.wuzi = CGRectMake(originX, originY, width, height);
                        [playerArray addObject:model];
                    }
                }
                if ([ClassName containsString:@"PickUp_BP_Bag_Lv1_C"]||[ClassName containsString:@"PickUp_BP_Bag_Lv1_A_C"]||[ClassName containsString:@"PickUp_BP_Bag_Lv1_B_C"]) {
                    if (wuzijuli > 2 && wuzijuli <= 50) {
                        
                        FVectorRect rect;
                        [self worldToScreenForRect:WorldLocation camViewInfo:POV canvas:self.canvas outRect:&rect];
                        if (rect.X > kScreenWidth)
                            continue;
                        
                        float height = rect.Y - rect.Y;
                        float width  = height / 2;
                        
                        float originX = rect.X - width / 2;
                        float originY = rect.Y;
                        
                        
                        PUBGPlayerModel *model = [[PUBGPlayerModel alloc] init];
                        model.flag = 48;
                        model.wuzimi = wuzijuli;
                        model.wuzi = CGRectMake(originX, originY, width, height);
                        [playerArray addObject:model];
                    }
                }
                if ([ClassName containsString:@"PickUp_BP_Helmet_Lv2_C"]||[ClassName containsString:@"PickUp_BP_Helmet_Lv2_A_C"]||[ClassName containsString:@"PickUp_BP_Helmet_Lv2_B_C"]) {
                    if (wuzijuli > 2 && wuzijuli <= 50) {
                        
                        FVectorRect rect;
                        [self worldToScreenForRect:WorldLocation camViewInfo:POV canvas:self.canvas outRect:&rect];
                        if (rect.X > kScreenWidth)
                            continue;
                        
                        float height = rect.Y - rect.Y;
                        float width  = height / 2;
                        
                        float originX = rect.X - width / 2;
                        float originY = rect.Y;
                        
                        
                        PUBGPlayerModel *model = [[PUBGPlayerModel alloc] init];
                        model.flag = 49;
                        model.wuzimi = wuzijuli;
                        model.wuzi = CGRectMake(originX, originY, width, height);
                        [playerArray addObject:model];
                    }
                }
                if ([ClassName containsString:@"PickUp_BP_Armor_Lv2_C"]||[ClassName containsString:@"PickUp_BP_Armor_Lv2_A_C"]||[ClassName containsString:@"PickUp_BP_Armor_Lv2_B_C"]) {
                    if (wuzijuli > 2 && wuzijuli <= 50) {
                        
                        FVectorRect rect;
                        [self worldToScreenForRect:WorldLocation camViewInfo:POV canvas:self.canvas outRect:&rect];
                        if (rect.X > kScreenWidth)
                            continue;
                        
                        float height = rect.Y - rect.Y;
                        float width  = height / 2;
                        
                        float originX = rect.X - width / 2;
                        float originY = rect.Y;
                        
                        
                        PUBGPlayerModel *model = [[PUBGPlayerModel alloc] init];
                        model.flag = 50;
                        model.wuzimi = wuzijuli;
                        model.wuzi = CGRectMake(originX, originY, width, height);
                        [playerArray addObject:model];
                    }
                }
                if ([ClassName containsString:@"PickUp_BP_Bag_Lv2_C"]||[ClassName containsString:@"PickUp_BP_Bag_Lv2_A_C"]||[ClassName containsString:@"PickUp_BP_Bag_Lv2_B_C"]) {
                    if (wuzijuli > 2 && wuzijuli <= 50) {
                        
                        FVectorRect rect;
                        [self worldToScreenForRect:WorldLocation camViewInfo:POV canvas:self.canvas outRect:&rect];
                        if (rect.X > kScreenWidth)
                            continue;
                        
                        float height = rect.Y - rect.Y;
                        float width  = height / 2;
                        
                        float originX = rect.X - width / 2;
                        float originY = rect.Y;
                        
                        
                        PUBGPlayerModel *model = [[PUBGPlayerModel alloc] init];
                        model.flag = 51;
                        model.wuzimi = wuzijuli;
                        model.wuzi = CGRectMake(originX, originY, width, height);
                        [playerArray addObject:model];
                    }
                }
                if ([ClassName containsString:@"PickUp_BP_Helmet_Lv3_C"]||[ClassName containsString:@"PickUp_BP_Helmet_Lv3_A_C"]||[ClassName containsString:@"PickUp_BP_Helmet_Lv3_B_C"]) {
                    if (wuzijuli > 2 && wuzijuli <= 50) {
                        
                        FVectorRect rect;
                        [self worldToScreenForRect:WorldLocation camViewInfo:POV canvas:self.canvas outRect:&rect];
                        if (rect.X > kScreenWidth)
                            continue;
                        
                        float height = rect.Y - rect.Y;
                        float width  = height / 2;
                        
                        float originX = rect.X - width / 2;
                        float originY = rect.Y;
                        
                        
                        PUBGPlayerModel *model = [[PUBGPlayerModel alloc] init];
                        model.flag = 52;
                        model.wuzimi = wuzijuli;
                        model.wuzi = CGRectMake(originX, originY, width, height);
                        [playerArray addObject:model];
                    }
                }
                if ([ClassName containsString:@"PickUp_BP_Armor_Lv3_C"]||[ClassName containsString:@"PickUp_BP_Armor_Lv3_A_C"]||[ClassName containsString:@"PickUp_BP_Armor_Lv3_B_C"]) {
                    if (wuzijuli > 2 && wuzijuli <= 50) {
                        
                        FVectorRect rect;
                        [self worldToScreenForRect:WorldLocation camViewInfo:POV canvas:self.canvas outRect:&rect];
                        if (rect.X > kScreenWidth)
                            continue;
                        
                        float height = rect.Y - rect.Y;
                        float width  = height / 2;
                        
                        float originX = rect.X - width / 2;
                        float originY = rect.Y;
                        
                        
                        PUBGPlayerModel *model = [[PUBGPlayerModel alloc] init];
                        model.flag = 53;
                        model.wuzimi = wuzijuli;
                        model.wuzi = CGRectMake(originX, originY, width, height);
                        [playerArray addObject:model];
                    }
                }
                if ([ClassName containsString:@"Pickup_BP_Bag_Lv3"]||[ClassName containsString:@"PickUp_BP_Bag_Lv3_A_C"]||[ClassName containsString:@"PickUp_BP_Bag_Lv3_B_C"]) {
                    if (wuzijuli > 2 && wuzijuli <= 50) {
                        
                        FVectorRect rect;
                        [self worldToScreenForRect:WorldLocation camViewInfo:POV canvas:self.canvas outRect:&rect];
                        if (rect.X > kScreenWidth)
                            continue;
                        
                        float height = rect.Y - rect.Y;
                        float width  = height / 2;
                        
                        float originX = rect.X - width / 2;
                        float originY = rect.Y;
                        
                        
                        PUBGPlayerModel *model = [[PUBGPlayerModel alloc] init];
                        model.flag = 54;
                        model.wuzimi = wuzijuli;
                        model.wuzi = CGRectMake(originX, originY, width, height);
                        [playerArray addObject:model];
                    }
                }
            }
#pragma mark - --------------------------瞄准镜-----------------------------------
            
            if (倍镜开关) {
                if ([ClassName containsString:@"BP_MZJ_3X_Pickup_C"]) {
                    if (wuzijuli > 2 && wuzijuli <= 50) {
                        
                        FVectorRect rect;
                        [self worldToScreenForRect:WorldLocation camViewInfo:POV canvas:self.canvas outRect:&rect];
                        if (rect.X > kScreenWidth)
                            continue;
                        
                        float height = rect.Y - rect.Y;
                        float width  = height / 2;
                        
                        float originX = rect.X - width / 2;
                        float originY = rect.Y;
                        
                        
                        PUBGPlayerModel *model = [[PUBGPlayerModel alloc] init];
                        model.flag = 55;
                        model.wuzimi = wuzijuli;
                        model.wuzi = CGRectMake(originX, originY, width, height);
                        [playerArray addObject:model];
                    }
                }
                if ([ClassName containsString:@"BP_MZJ_2X_Pickup_C"]) {
                    if (wuzijuli > 2 && wuzijuli <= 50) {
                        
                        FVectorRect rect;
                        [self worldToScreenForRect:WorldLocation camViewInfo:POV canvas:self.canvas outRect:&rect];
                        if (rect.X > kScreenWidth)
                            continue;
                        
                        float height = rect.Y - rect.Y;
                        float width  = height / 2;
                        
                        float originX = rect.X - width / 2;
                        float originY = rect.Y;
                        
                        
                        PUBGPlayerModel *model = [[PUBGPlayerModel alloc] init];
                        model.flag = 56;
                        model.wuzimi = wuzijuli;
                        model.wuzi = CGRectMake(originX, originY, width, height);
                        [playerArray addObject:model];
                    }
                }
                if ([ClassName containsString:@"BP_MZJ_8X_Pickup_C"]) {
                    if (wuzijuli > 2 && wuzijuli <= 50) {
                        
                        FVectorRect rect;
                        [self worldToScreenForRect:WorldLocation camViewInfo:POV canvas:self.canvas outRect:&rect];
                        if (rect.X > kScreenWidth)
                            continue;
                        
                        float height = rect.Y - rect.Y;
                        float width  = height / 2;
                        
                        float originX = rect.X - width / 2;
                        float originY = rect.Y;
                        
                        
                        PUBGPlayerModel *model = [[PUBGPlayerModel alloc] init];
                        model.flag = 57;
                        model.wuzimi = wuzijuli;
                        model.wuzi = CGRectMake(originX, originY, width, height);
                        [playerArray addObject:model];
                    }
                }
                if ([ClassName containsString:@"BP_MZJ_4X_Pickup_C"]) {
                    if (wuzijuli > 2 && wuzijuli <= 50) {
                        
                        FVectorRect rect;
                        [self worldToScreenForRect:WorldLocation camViewInfo:POV canvas:self.canvas outRect:&rect];
                        if (rect.X > kScreenWidth)
                            continue;
                        
                        float height = rect.Y - rect.Y;
                        float width  = height / 2;
                        
                        float originX = rect.X - width / 2;
                        float originY = rect.Y;
                        
                        
                        PUBGPlayerModel *model = [[PUBGPlayerModel alloc] init];
                        model.flag = 58;
                        model.wuzimi = wuzijuli;
                        model.wuzi = CGRectMake(originX, originY, width, height);
                        [playerArray addObject:model];
                    }
                }
                if ([ClassName containsString:@"BP_MZJ_6X_Pickup_C"]) {
                    if (wuzijuli > 2 && wuzijuli <= 50) {
                        
                        FVectorRect rect;
                        [self worldToScreenForRect:WorldLocation camViewInfo:POV canvas:self.canvas outRect:&rect];
                        if (rect.X > kScreenWidth)
                            continue;
                        
                        float height = rect.Y - rect.Y;
                        float width  = height / 2;
                        
                        float originX = rect.X - width / 2;
                        float originY = rect.Y;
                        
                        
                        PUBGPlayerModel *model = [[PUBGPlayerModel alloc] init];
                        model.flag = 59;
                        model.wuzimi = wuzijuli;
                        model.wuzi = CGRectMake(originX, originY, width, height);
                        [playerArray addObject:model];
                    }
                }
            }
#pragma mark - -------------------------配件-----------------------------------
            if (配件开关) {
                if ([ClassName containsString:@"BP_QK_Mid_Compensator_Pickup_C"]) {
                    if (wuzijuli > 2 && wuzijuli <= 50) {
                        
                        FVectorRect rect;
                        [self worldToScreenForRect:WorldLocation camViewInfo:POV canvas:self.canvas outRect:&rect];
                        if (rect.X > kScreenWidth)
                            continue;
                        
                        float height = rect.Y - rect.Y;
                        float width  = height / 2;
                        
                        float originX = rect.X - width / 2;
                        float originY = rect.Y;
                        
                        
                        PUBGPlayerModel *model = [[PUBGPlayerModel alloc] init];
                        model.flag = 60;
                        model.wuzimi = wuzijuli;
                        model.wuzi = CGRectMake(originX, originY, width, height);
                        [playerArray addObject:model];
                    }
                }
                if ([ClassName containsString:@"BP_QK_Large_Compensator_Pickup_C"]) {
                    if (wuzijuli > 2 && wuzijuli <= 50) {
                        
                        FVectorRect rect;
                        [self worldToScreenForRect:WorldLocation camViewInfo:POV canvas:self.canvas outRect:&rect];
                        if (rect.X > kScreenWidth)
                            continue;
                        
                        float height = rect.Y - rect.Y;
                        float width  = height / 2;
                        
                        float originX = rect.X - width / 2;
                        float originY = rect.Y;
                        
                        
                        PUBGPlayerModel *model = [[PUBGPlayerModel alloc] init];
                        model.flag = 61;
                        model.wuzimi = wuzijuli;
                        model.wuzi = CGRectMake(originX, originY, width, height);
                        [playerArray addObject:model];
                    }
                }
                if ([ClassName containsString:@"BP_QT_UZI_Pickup_C"]) {
                    if (wuzijuli > 2 && wuzijuli <= 50) {
                        
                        FVectorRect rect;
                        [self worldToScreenForRect:WorldLocation camViewInfo:POV canvas:self.canvas outRect:&rect];
                        if (rect.X > kScreenWidth)
                            continue;
                        
                        float height = rect.Y - rect.Y;
                        float width  = height / 2;
                        
                        float originX = rect.X - width / 2;
                        float originY = rect.Y;
                        
                        
                        PUBGPlayerModel *model = [[PUBGPlayerModel alloc] init];
                        model.flag = 62;
                        model.wuzimi = wuzijuli;
                        model.wuzi = CGRectMake(originX, originY, width, height);
                        [playerArray addObject:model];
                    }
                }
                if ([ClassName containsString:@"BP_QT_A_Pickup_C"]) {
                    if (wuzijuli > 2 && wuzijuli <= 50) {
                        
                        FVectorRect rect;
                        [self worldToScreenForRect:WorldLocation camViewInfo:POV canvas:self.canvas outRect:&rect];
                        if (rect.X > kScreenWidth)
                            continue;
                        
                        float height = rect.Y - rect.Y;
                        float width  = height / 2;
                        
                        float originX = rect.X - width / 2;
                        float originY = rect.Y;
                        
                        
                        PUBGPlayerModel *model = [[PUBGPlayerModel alloc] init];
                        model.flag = 63;
                        model.wuzimi = wuzijuli;
                        model.wuzi = CGRectMake(originX, originY, width, height);
                        [playerArray addObject:model];
                    }
                }
                if ([ClassName containsString:@"BP_WB_LightGrip_Pickup_C"]) {
                    if (wuzijuli > 2 && wuzijuli <= 50) {
                        
                        FVectorRect rect;
                        [self worldToScreenForRect:WorldLocation camViewInfo:POV canvas:self.canvas outRect:&rect];
                        if (rect.X > kScreenWidth)
                            continue;
                        
                        float height = rect.Y - rect.Y;
                        float width  = height / 2;
                        
                        float originX = rect.X - width / 2;
                        float originY = rect.Y;
                        
                        
                        PUBGPlayerModel *model = [[PUBGPlayerModel alloc] init];
                        model.flag = 64;
                        model.wuzimi = wuzijuli;
                        model.wuzi = CGRectMake(originX, originY, width, height);
                        [playerArray addObject:model];
                    }
                }
                if ([ClassName containsString:@"BP_WEP_Cowbar_Pickup"]) {
                    if (wuzijuli > 2 && wuzijuli <= 50) {
                        
                        FVectorRect rect;
                        [self worldToScreenForRect:WorldLocation camViewInfo:POV canvas:self.canvas outRect:&rect];
                        if (rect.X > kScreenWidth)
                            continue;
                        
                        float height = rect.Y - rect.Y;
                        float width  = height / 2;
                        
                        float originX = rect.X - width / 2;
                        float originY = rect.Y;
                        
                        
                        PUBGPlayerModel *model = [[PUBGPlayerModel alloc] init];
                        model.flag = 65;
                        model.wuzimi = wuzijuli;
                        model.wuzi = CGRectMake(originX, originY, width, height);
                        [playerArray addObject:model];
                    }
                }
                if ([ClassName containsString:@"BP_WEP_Machere_Pickup"]) {
                    if (wuzijuli > 2 && wuzijuli <= 50) {
                        
                        FVectorRect rect;
                        [self worldToScreenForRect:WorldLocation camViewInfo:POV canvas:self.canvas outRect:&rect];
                        if (rect.X > kScreenWidth)
                            continue;
                        
                        float height = rect.Y - rect.Y;
                        float width  = height / 2;
                        
                        float originX = rect.X - width / 2;
                        float originY = rect.Y;
                        
                        
                        PUBGPlayerModel *model = [[PUBGPlayerModel alloc] init];
                        model.flag = 66;
                        model.wuzimi = wuzijuli;
                        model.wuzi = CGRectMake(originX, originY, width, height);
                        [playerArray addObject:model];
                    }
                }
                if ([ClassName containsString:@"BP_WEP_Pan_Pickup"]) {
                    if (wuzijuli > 2 && wuzijuli <= 50) {
                        
                        FVectorRect rect;
                        [self worldToScreenForRect:WorldLocation camViewInfo:POV canvas:self.canvas outRect:&rect];
                        if (rect.X > kScreenWidth)
                            continue;
                        
                        float height = rect.Y - rect.Y;
                        float width  = height / 2;
                        
                        float originX = rect.X - width / 2;
                        float originY = rect.Y;
                        
                        
                        PUBGPlayerModel *model = [[PUBGPlayerModel alloc] init];
                        model.flag = 67;
                        model.wuzimi = wuzijuli;
                        model.wuzi = CGRectMake(originX, originY, width, height);
                        [playerArray addObject:model];
                    }
                }
                if ([ClassName containsString:@"BP_WEP_Sickle_Pickup"]) {
                    if (wuzijuli > 2 && wuzijuli <= 50) {
                        
                        FVectorRect rect;
                        [self worldToScreenForRect:WorldLocation camViewInfo:POV canvas:self.canvas outRect:&rect];
                        if (rect.X > kScreenWidth)
                            continue;
                        
                        float height = rect.Y - rect.Y;
                        float width  = height / 2;
                        
                        float originX = rect.X - width / 2;
                        float originY = rect.Y;
                        
                        
                        PUBGPlayerModel *model = [[PUBGPlayerModel alloc] init];
                        model.flag = 68;
                        model.wuzimi = wuzijuli;
                        model.wuzi = CGRectMake(originX, originY, width, height);
                        [playerArray addObject:model];
                    }
                }
            }
#pragma mark - -------------------------子弹-----------------------------------
            if (子弹开关) {
                if ([ClassName containsString:@"BP_Ammo_762mm_Pickup_C"]) {
                    if (wuzijuli > 2 && wuzijuli <= 50) {
                        
                        FVectorRect rect;
                        [self worldToScreenForRect:WorldLocation camViewInfo:POV canvas:self.canvas outRect:&rect];
                        if (rect.X > kScreenWidth)
                            continue;
                        
                        float height = rect.Y - rect.Y;
                        float width  = height / 2;
                        
                        float originX = rect.X - width / 2;
                        float originY = rect.Y;
                        
                        
                        PUBGPlayerModel *model = [[PUBGPlayerModel alloc] init];
                        model.flag = 69;
                        model.wuzimi = wuzijuli;
                        model.wuzi = CGRectMake(originX, originY, width, height);
                        [playerArray addObject:model];
                    }
                }
                if ([ClassName containsString:@"BP_Ammo_556mm_Pickup_C"]) {
                    if (wuzijuli > 2 && wuzijuli <= 50) {
                        
                        FVectorRect rect;
                        [self worldToScreenForRect:WorldLocation camViewInfo:POV canvas:self.canvas outRect:&rect];
                        if (rect.X > kScreenWidth)
                            continue;
                        
                        float height = rect.Y - rect.Y;
                        float width  = height / 2;
                        
                        float originX = rect.X - width / 2;
                        float originY = rect.Y;
                        
                        
                        PUBGPlayerModel *model = [[PUBGPlayerModel alloc] init];
                        model.flag = 70;
                        model.wuzimi = wuzijuli;
                        model.wuzi = CGRectMake(originX, originY, width, height);
                        [playerArray addObject:model];
                    }
                }
                if ([ClassName containsString:@"BP_Ammo_45ACP_Pickup_C"]) {
                    if (wuzijuli > 2 && wuzijuli <= 50) {
                        
                        FVectorRect rect;
                        [self worldToScreenForRect:WorldLocation camViewInfo:POV canvas:self.canvas outRect:&rect];
                        if (rect.X > kScreenWidth)
                            continue;
                        
                        float height = rect.Y - rect.Y;
                        float width  = height / 2;
                        
                        float originX = rect.X - width / 2;
                        float originY = rect.Y;
                        
                        
                        PUBGPlayerModel *model = [[PUBGPlayerModel alloc] init];
                        model.flag = 71;
                        model.wuzimi = wuzijuli;
                        model.wuzi = CGRectMake(originX, originY, width, height);
                        [playerArray addObject:model];
                    }
                }
                if ([ClassName containsString:@"BP_Ammo_12Guage_Pickup_C"]) {
                    if (wuzijuli > 2 && wuzijuli <= 50) {
                        
                        FVectorRect rect;
                        [self worldToScreenForRect:WorldLocation camViewInfo:POV canvas:self.canvas outRect:&rect];
                        if (rect.X > kScreenWidth)
                            continue;
                        
                        float height = rect.Y - rect.Y;
                        float width  = height / 2;
                        
                        float originX = rect.X - width / 2;
                        float originY = rect.Y;
                        
                        
                        PUBGPlayerModel *model = [[PUBGPlayerModel alloc] init];
                        model.flag = 72;
                        model.wuzimi = wuzijuli;
                        model.wuzi = CGRectMake(originX, originY, width, height);
                        [playerArray addObject:model];
                    }
                }
                if ([ClassName containsString:@"BP_Ammo_40mm_Pickup_C"]) {
                    if (wuzijuli > 2 && wuzijuli <= 50) {
                        
                        FVectorRect rect;
                        [self worldToScreenForRect:WorldLocation camViewInfo:POV canvas:self.canvas outRect:&rect];
                        if (rect.X > kScreenWidth)
                            continue;
                        
                        float height = rect.Y - rect.Y;
                        float width  = height / 2;
                        
                        float originX = rect.X - width / 2;
                        float originY = rect.Y;
                        
                        
                        PUBGPlayerModel *model = [[PUBGPlayerModel alloc] init];
                        model.flag = 73;
                        model.wuzimi = wuzijuli;
                        model.wuzi = CGRectMake(originX, originY, width, height);
                        [playerArray addObject:model];
                    }
                }
                if ([ClassName containsString:@"BP_Ammo_9mm_Pickup_C"]) {
                    if (wuzijuli > 2 && wuzijuli <= 50) {
                        
                        FVectorRect rect;
                        [self worldToScreenForRect:WorldLocation camViewInfo:POV canvas:self.canvas outRect:&rect];
                        if (rect.X > kScreenWidth)
                            continue;
                        
                        float height = rect.Y - rect.Y;
                        float width  = height / 2;
                        
                        float originX = rect.X - width / 2;
                        float originY = rect.Y;
                        
                        
                        PUBGPlayerModel *model = [[PUBGPlayerModel alloc] init];
                        model.flag = 74;
                        model.wuzimi = wuzijuli;
                        model.wuzi = CGRectMake(originX, originY, width, height);
                        [playerArray addObject:model];
                    }
                }
            }
#pragma mark - -------------------------药品-----------------------------------
            if (药品开关) {
                if ([ClassName containsString:@"Injection_Pickup_C"]) {
                    if (wuzijuli > 2 && wuzijuli <= 50) {
                        
                        FVectorRect rect;
                        [self worldToScreenForRect:WorldLocation camViewInfo:POV canvas:self.canvas outRect:&rect];
                        if (rect.X > kScreenWidth)
                            continue;
                        
                        float height = rect.Y - rect.Y;
                        float width  = height / 2;
                        
                        float originX = rect.X - width / 2;
                        float originY = rect.Y;
                        
                        
                        PUBGPlayerModel *model = [[PUBGPlayerModel alloc] init];
                        model.flag = 75;
                        model.wuzimi = wuzijuli;
                        model.wuzi = CGRectMake(originX, originY, width, height);
                        [playerArray addObject:model];
                    }
                }
                if ([ClassName containsString:@"Firstaid_Pickup_C"]) {
                    if (wuzijuli > 2 && wuzijuli <= 50) {
                        
                        FVectorRect rect;
                        [self worldToScreenForRect:WorldLocation camViewInfo:POV canvas:self.canvas outRect:&rect];
                        if (rect.X > kScreenWidth)
                            continue;
                        
                        float height = rect.Y - rect.Y;
                        float width  = height / 2;
                        
                        float originX = rect.X - width / 2;
                        float originY = rect.Y;
                        
                        
                        PUBGPlayerModel *model = [[PUBGPlayerModel alloc] init];
                        model.flag = 76;
                        model.wuzimi = wuzijuli;
                        model.wuzi = CGRectMake(originX, originY, width, height);
                        [playerArray addObject:model];
                    }
                }
                if ([ClassName containsString:@"Pills_Pickup"]) {
                    if (wuzijuli > 2 && wuzijuli <= 50) {
                        
                        FVectorRect rect;
                        [self worldToScreenForRect:WorldLocation camViewInfo:POV canvas:self.canvas outRect:&rect];
                        if (rect.X > kScreenWidth)
                            continue;
                        
                        float height = rect.Y - rect.Y;
                        float width  = height / 2;
                        
                        float originX = rect.X - width / 2;
                        float originY = rect.Y;
                        
                        
                        PUBGPlayerModel *model = [[PUBGPlayerModel alloc] init];
                        model.flag = 77;
                        model.wuzimi = wuzijuli;
                        model.wuzi = CGRectMake(originX, originY, width, height);
                        [playerArray addObject:model];
                    }
                }
                if ([ClassName containsString:@"Drink_Pickup_C"]) {
                    if (wuzijuli > 2 && wuzijuli <= 50) {
                        
                        FVectorRect rect;
                        [self worldToScreenForRect:WorldLocation camViewInfo:POV canvas:self.canvas outRect:&rect];
                        if (rect.X > kScreenWidth)
                            continue;
                        
                        float height = rect.Y - rect.Y;
                        float width  = height / 2;
                        
                        float originX = rect.X - width / 2;
                        float originY = rect.Y;
                        
                        
                        PUBGPlayerModel *model = [[PUBGPlayerModel alloc] init];
                        model.flag = 78;
                        model.wuzimi = wuzijuli;
                        model.wuzi = CGRectMake(originX, originY, width, height);
                        [playerArray addObject:model];
                    }
                }
                if ([ClassName containsString:@"Bandage_Pickup"]) {
                    if (wuzijuli > 2 && wuzijuli <= 50) {
                        
                        FVectorRect rect;
                        [self worldToScreenForRect:WorldLocation camViewInfo:POV canvas:self.canvas outRect:&rect];
                        if (rect.X > kScreenWidth)
                            continue;
                        
                        float height = rect.Y - rect.Y;
                        float width  = height / 2;
                        
                        float originX = rect.X - width / 2;
                        float originY = rect.Y;
                        
                        
                        PUBGPlayerModel *model = [[PUBGPlayerModel alloc] init];
                        model.flag = 79;
                        model.wuzimi = wuzijuli;
                        model.wuzi = CGRectMake(originX, originY, width, height);
                        [playerArray addObject:model];
                    }
                }
                if ([ClassName containsString:@"FirstAidbox_Pickup"]) {
                    if (wuzijuli > 2 && wuzijuli <= 50) {
                        
                        FVectorRect rect;
                        [self worldToScreenForRect:WorldLocation camViewInfo:POV canvas:self.canvas outRect:&rect];
                        if (rect.X > kScreenWidth)
                            continue;
                        
                        float height = rect.Y - rect.Y;
                        float width  = height / 2;
                        
                        float originX = rect.X - width / 2;
                        float originY = rect.Y;
                        
                        
                        PUBGPlayerModel *model = [[PUBGPlayerModel alloc] init];
                        model.flag = 80;
                        model.wuzimi = wuzijuli;
                        model.wuzi = CGRectMake(originX, originY, width, height);
                        [playerArray addObject:model];
                    }
                }
            }
#pragma mark - -------------------------盒子-----------------------------------
            if (盒子开关) {
                if ([ClassName containsString:@"PickUpListWrapperActor"]) {
                    if (wuzijuli > 2 && wuzijuli <= 50) {
                        
                        FVectorRect rect;
                        [self worldToScreenForRect:WorldLocation camViewInfo:POV canvas:self.canvas outRect:&rect];
                        if (rect.X > kScreenWidth)
                            continue;
                        
                        float height = rect.Y - rect.Y;
                        float width  = height / 2;
                        
                        float originX = rect.X - width / 2;
                        float originY = rect.Y;
                        
                        
                        PUBGPlayerModel *model = [[PUBGPlayerModel alloc] init];
                        model.flag = 81;
                        model.wuzimi = wuzijuli;
                        model.wuzi = CGRectMake(originX, originY, width, height);
                        [playerArray addObject:model];
                    }
                }
            }
            
#pragma mark - -------------------------空头-----------------------------------
            if (空头开关) {
                if ([ClassName containsString:@"BP_AirDropBox_C"]) {
                    if (wuzijuli > 2 && wuzijuli <= 50) {
                        
                        FVectorRect rect;
                        [self worldToScreenForRect:WorldLocation camViewInfo:POV canvas:self.canvas outRect:&rect];
                        if (rect.X > kScreenWidth)
                            continue;
                        
                        float height = rect.Y - rect.Y;
                        float width  = height / 2;
                        
                        float originX = rect.X - width / 2;
                        float originY = rect.Y;
                        
                        
                        PUBGPlayerModel *model = [[PUBGPlayerModel alloc] init];
                        model.flag = 82;
                        model.wuzimi = wuzijuli;
                        model.wuzi = CGRectMake(originX, originY, width, height);
                        [playerArray addObject:model];
                    }
                }
            }
            
#pragma mark - -------------------------信号枪-----------------------------------
            if (信号枪开关) {
                if ([ClassName containsString:@"BP_Pistol_Flaregun_Wrapper_C"]) {
                    if (wuzijuli > 2 && wuzijuli <= 50) {
                        
                        FVectorRect rect;
                        [self worldToScreenForRect:WorldLocation camViewInfo:POV canvas:self.canvas outRect:&rect];
                        if (rect.X > kScreenWidth)
                            continue;
                        
                        float height = rect.Y - rect.Y;
                        float width  = height / 2;
                        
                        float originX = rect.X - width / 2;
                        float originY = rect.Y;
                        
                        
                        PUBGPlayerModel *model = [[PUBGPlayerModel alloc] init];
                        model.flag = 83;
                        model.wuzimi = wuzijuli;
                        model.wuzi = CGRectMake(originX, originY, width, height);
                        [playerArray addObject:model];
                    }
                }
            }
            
#pragma mark - -------------------------投掷物提醒-----------------------------------
            if ([ClassName containsString:@"ProjGrenade_BP_C"]) {
                if (wuzijuli > 2 && wuzijuli <= 50) {
                    
                    FVectorRect rect;
                    [self worldToScreenForRect:WorldLocation camViewInfo:POV canvas:self.canvas outRect:&rect];
                    if (rect.X > kScreenWidth)
                        continue;
                    
                    float height = rect.Y - rect.Y;
                    float width  = height / 2;
                    
                    float originX = rect.X - width / 2;
                    float originY = rect.Y;
                    
                    
                    PUBGPlayerModel *model = [[PUBGPlayerModel alloc] init];
                    model.flag = 84;
                    model.wuzimi = wuzijuli;
                    model.wuzi = CGRectMake(originX, originY, width, height);
                    [playerArray addObject:model];
                }
            }
            else if ([ClassName containsString:@"ProjFire_BP_C"]) {
                if (wuzijuli > 2 && wuzijuli <= 50) {
                    
                    FVectorRect rect;
                    [self worldToScreenForRect:WorldLocation camViewInfo:POV canvas:self.canvas outRect:&rect];
                    if (rect.X > kScreenWidth)
                        continue;
                    
                    float height = rect.Y - rect.Y;
                    float width  = height / 2;
                    
                    float originX = rect.X - width / 2;
                    float originY = rect.Y;
                    
                    
                    PUBGPlayerModel *model = [[PUBGPlayerModel alloc] init];
                    model.flag = 85;
                    model.wuzimi = wuzijuli;
                    model.wuzi = CGRectMake(originX, originY, width, height);
                    [playerArray addObject:model];
                }
            }
            else if ([ClassName containsString:@"ProjBurn_BP_C"]) {
                if (wuzijuli > 2 && wuzijuli <= 50) {
                    
                    FVectorRect rect;
                    [self worldToScreenForRect:WorldLocation camViewInfo:POV canvas:self.canvas outRect:&rect];
                    if (rect.X > kScreenWidth)
                        continue;
                    
                    float height = rect.Y - rect.Y;
                    float width  = height / 2;
                    
                    float originX = rect.X - width / 2;
                    float originY = rect.Y;
                    
                    
                    PUBGPlayerModel *model = [[PUBGPlayerModel alloc] init];
                    model.flag = 86;
                    model.wuzimi = wuzijuli;
                    model.wuzi = CGRectMake(originX, originY, width, height);
                    [playerArray addObject:model];
                }
            }
#pragma mark - 懒加载
        }
    }
    if (block) {
        block(playerArray);
    }
}

@end
