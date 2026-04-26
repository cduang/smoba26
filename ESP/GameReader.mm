
#include "Utilties.h"

#include <mach/mach.h>
#include <dlfcn.h>
#include <mach-o/dyld_images.h>
#include <stdio.h>
#include "crossproc.h"
long Imageaddress,Game_Data,Game_Viewport;
static char * _Nullable machoPath = "smoba";

Matrix ViewMatrix;
extern bool 绘制总开关;

static float MemHeroHP;
static int MemHeroID;
static float MemPosx;
static float MemPosy;
static int MemHeroTeam;
static int MemHeroSkillTime;
static int MemHeroFacion;
static int MemHeroHealth;
static int MemHeroMaxHealth;
static int MemHeroTalent;
static int MemHeroTalentTime;
static int MemYeGuaiTime;
static int MemYeGuaiDead;




//std::vector<SmobaMonsterData>MonsterData;
static mach_port_t task;
extern "C" kern_return_t


mach_vm_region_recurse(
                       vm_map_t                 map,
                       mach_vm_address_t        *address,
                       mach_vm_size_t           *size,
                       uint32_t                 *depth,
                       vm_region_recurse_info_t info,
                       mach_msg_type_number_t   *infoCnt);
extern void*  _dyld_get_prog_image_header();


static int get_processes_pid() {
    static int PID;
    size_t length = 0;
    static const int name[] = {CTL_KERN, KERN_PROC, KERN_PROC_ALL, 0};
    int err = sysctl((int *)name, (sizeof(name) / sizeof(*name)) - 1, NULL, &length, NULL, 0);
    if (err == -1) err = errno;
    if (err == 0) {
        struct kinfo_proc *procBuffer = (struct kinfo_proc *)malloc(length);
        if(procBuffer == NULL) return -1;
        sysctl((int *)name, (sizeof(name) / sizeof(*name)) - 1, procBuffer, &length, NULL, 0);
        int count = (int)length / sizeof(struct kinfo_proc);
        for (int i = 0; i < count; ++i) {
            const char *procname = procBuffer[i].kp_proc.p_comm;
            NSString *进程名字=[NSString stringWithFormat:@"%s",procname];
            pid_t pid = procBuffer[i].kp_proc.p_pid;
            if ([进程名字 containsString:@"smoba"]) {
                kern_return_t kret = task_for_pid(mach_task_self(), pid, &task);
                if (kret == KERN_SUCCESS) {
                    PID = pid;
                }
            }
        }
    }
    return  PID;
}

static long get_module_base() {
    pid_t pid = get_processes_pid();
    kern_return_t kret = task_for_pid(mach_task_self(), pid, &task);
    
    if (kret != KERN_SUCCESS) {
        return 0;
    }

    task_dyld_info_data_t task_dyld_info;
    mach_msg_type_number_t count = TASK_DYLD_INFO_COUNT;
    kret = task_info(task, TASK_DYLD_INFO, (task_info_t)&task_dyld_info, &count);
    if (kret != KERN_SUCCESS) {
        return 0;
    }

    struct dyld_all_image_infos64 aii;
    mach_vm_size_t aiiSize = sizeof(aii);
    kret = mach_vm_read_overwrite(task, task_dyld_info.all_image_info_addr, aiiSize, (mach_vm_address_t)&aii, &aiiSize);
    if (kret != KERN_SUCCESS) {
        return 0;
    }

    mach_vm_address_t ii = aii.infoArray;
    uint32_t iiCount = aii.infoArrayCount;
    mach_msg_type_number_t iiSize = iiCount * sizeof(struct dyld_image_info64);
    
    kret = mach_vm_read(task, ii, iiSize, (vm_offset_t *)&ii, &iiSize);
    if (kret != KERN_SUCCESS) {
        return 0;
    }

    for (int i = 0; i < iiCount; i++) {
        mach_vm_address_t addr = ((struct dyld_image_info64 *)ii)[i].imageLoadAddress;
        mach_vm_address_t path = ((struct dyld_image_info64 *)ii)[i].imageFilePath;

        char pathbuffer[PATH_MAX] = {0};
        mach_vm_size_t size3;
        if (mach_vm_read_overwrite(task, path, MAXPATHLEN, (mach_vm_address_t)pathbuffer, &size3) != KERN_SUCCESS) {
            strcpy(pathbuffer, "<Unknown>");
        }

        NSString *moduleName = [NSString stringWithUTF8String:pathbuffer];
        if ([moduleName containsString:@"UnityFramework"]) {
            vm_deallocate(mach_task_self(), ii, iiSize);
            //MOD = addr;
            return (long)addr;
        }
    }

    vm_deallocate(mach_task_self(), ii, iiSize);
    return 0;
}

//kern_return_t get_task_for_pid_wrapper(pid_t pid, mach_port_t *task) {
//    return task_for_pid(mach_task_self(), pid, task);
//}
//
//long get_library_header_address(pid_t pid, const char* library_name) {
//    mach_port_t task = MACH_PORT_NULL;
//    kern_return_t kr = get_task_for_pid_wrapper(pid, &task);
//    if (kr != KERN_SUCCESS) {
//        printf("Failed to get task for pid %d\n", pid);
//        return 0;
//    }
//
//    task_dyld_info_data_t dyld_info;
//    mach_msg_type_number_t count = TASK_DYLD_INFO_COUNT;
//    if (task_info(task, TASK_DYLD_INFO, (task_info_t)&dyld_info, &count) == KERN_SUCCESS) {
//        mach_vm_address_t address = dyld_info.all_image_info_addr;
//        struct dyld_all_image_infos *all_image_infos = NULL;
//        vm_size_t size;
//        kr = vm_read_overwrite(task, address, sizeof(struct dyld_all_image_infos), (mach_vm_address_t)&all_image_infos, &size);
//        if (kr != KERN_SUCCESS) {
//            printf("Failed to read all_image_infos from task\n");
//            return 0;
//        }
//
//        for (int i = 0; i < all_image_infos->infoArrayCount; i++) {
//            struct dyld_image_info *image_info = NULL;
//            kr = vm_read_overwrite(task, (mach_vm_address_t)(all_image_infos->infoArray + i), sizeof(struct dyld_image_info), (mach_vm_address_t)&image_info, &size);
//            if (kr != KERN_SUCCESS) {
//                printf("Failed to read image_info from task\n");
//                continue;
//            }
//
//            char *image_path = NULL;
//            kr = vm_read_overwrite(task, (mach_vm_address_t)image_info->imageFilePath, PATH_MAX, (mach_vm_address_t)&image_path, &size);
//            if (kr == KERN_SUCCESS && strstr(image_path, library_name) != NULL) {
//                printf("Found library %s\n", library_name);
//                return (long)image_info->imageLoadAddress;
//            }
//        }
//    }
//
//    return 0;
//}
//
//
//
//static int get_processes_pid() {
//    static int PID;
//    size_t length = 0;
//    static const int name[] = {CTL_KERN, KERN_PROC, KERN_PROC_ALL, 0};
//    int err = sysctl((int *)name, (sizeof(name) / sizeof(*name)) - 1, NULL, &length, NULL, 0);
//    if (err == -1) err = errno;
//    if (err == 0) {
//        struct kinfo_proc *procBuffer = (struct kinfo_proc *)malloc(length);
//        if(procBuffer == NULL) return -1;
//        sysctl((int *)name, (sizeof(name) / sizeof(*name)) - 1, procBuffer, &length, NULL, 0);
//        int count = (int)length / sizeof(struct kinfo_proc);
//        for (int i = 0; i < count; ++i) {
//            const char *procname = procBuffer[i].kp_proc.p_comm;
//            NSString *进程名字=[NSString stringWithFormat:@"%s",procname];
//            pid_t pid = procBuffer[i].kp_proc.p_pid;
//            //自己写判断进程名
//            if([进程名字 containsString:@"smoba"])
//            {
//                kern_return_t kret = task_for_pid(mach_task_self(), pid, &task);
//                if (kret == KERN_SUCCESS) {
//                    PID = pid;
//                }
//            }
//        }
//    }
//    return  PID;
//}

static bool Read_Data(long Src,int Size,void* Dst)
{
    vm_size_t size = 0;
    
    kern_return_t error = vm_read_overwrite(task, (vm_address_t)Src, Size, (vm_address_t)Dst, &size);
    if(error != KERN_SUCCESS || size != Size) {
        return false;
    }
    return true;
}


static bool Write_Data(uintptr_t targetAddr, uint32_t newValue) {
    vm_size_t size = sizeof(newValue);
    kern_return_t error = vm_write(task, (vm_address_t)targetAddr, (vm_offset_t)&newValue, size);
    return error == KERN_SUCCESS;
}



//long Read_Long(long src)
//{
//    long Buff=6710;
//    Read_Data(src,8,&Buff);
//    return Buff;
//}
//
//int Read_Int(long src)
//{
//    int Buff=6710;
//    Read_Data(src,4,&Buff);
//    return Buff;
//}
//
//int Read_Short(long src)
//{
//    int Buff=6710;
//    Read_Data(src,2,&Buff);
//    return Buff;
//}
//
//float Read_Float(long src)
//{
//    float Buff=6710;
//    Read_Data(src,4,&Buff);
//    return Buff;
//}

static long Read_Long(long src)
{
    long Buff=0;
    Read_Data(src,8,&Buff);
    return Buff;
}

static int Read_Int(long src)
{
    int Buff=0;
    Read_Data(src,4,&Buff);
    return Buff;
}

static int Read_Short(long src)
{
    int Buff=0;
    Read_Data(src,2,&Buff);
    return Buff;
}

static float Read_Float(long src)
{
    float Buff=0;
    Read_Data(src,4,&Buff);
    return Buff;
}



static float ScreenPosx;
static float ScreenPosy;

bool ToScreen(Vector2 GameCanvas,Vector2 HeroPos,Vector2* Screen)
{
    Screen->x=0;Screen->y=0;
    float ViewW;
    ViewW = ViewMatrix._13 * HeroPos.x + ViewMatrix._33 * HeroPos.y + ViewMatrix._43;
    if (ViewW < 0.01) return false;
    ViewW = 1/ViewW;
    Screen->x = (1+(ViewMatrix._11 * HeroPos.x + ViewMatrix._31 * HeroPos.y + ViewMatrix._41) * ViewW)*GameCanvas.x/2;
    Screen->y = (1-(ViewMatrix._12 * HeroPos.x + ViewMatrix._32 * HeroPos.y + ViewMatrix._42) * ViewW)*GameCanvas.y/2;
    return true;
}

static float MiniPosx;
static float MiniPosy;

Vector2 ToMiniMap(Vector2 MiniMap,Vector2 HeroPos)
{
    Vector2 Pos;
    float transformation = ViewMatrix._11>0?1:-1;
    Pos.x = (50 + HeroPos.x*transformation)/100;
    Pos.y = (50 - HeroPos.y*transformation)/100;
    
    return {MiniMap.x + Pos.x*MiniMap.y,Pos.y*MiniMap.y};
}

//读取屏幕坐标
static Vector2 GetPlayerPos(long Target)
{
    long Target_P1 = Read_Long(Target+0x240);//0x1F0-0x220
    long Target_P2 = Read_Long(Target_P1+0x10);
    long Target_P3 = Read_Long(Target_P2);
    long Target_P4 = Read_Long(Target_P3 + 0x10);
    
    int x1 = Read_Short(Target_P4);
    int x2 = Read_Short(Target_P4+2);
    
    int y1 = Read_Short(Target_P4+8);
    int y2 = Read_Short(Target_P4+10);
   
    if (x1 == 6710 || x1 == 0) {
        return {MemPosx,MemPosy};
    }
    MemPosx = (float)(x1-x2)/(float)1000;
    MemPosy = (float)(y1-y2)/(float)1000;
    NSLog(@"SMOBA-Apibug 屏幕坐标MemPosx:%f  MemPosy:%f",MemPosx,MemPosy);
    return {MemPosx,MemPosy};

}
//读取野怪位置
static Vector2 GetMonsterPos(long Target)
{
    long Target_P1 = Read_Long(Target+0x228);
    long Target_P2 = Read_Long(Target_P1+0x10);
    
    int x1 = Read_Short(Target_P2);
    int x2 = Read_Short(Target_P2+2);
    
    int y1 = Read_Short(Target_P2+8);
    int y2 = Read_Short(Target_P2+10);
   
    return {(float)(x1-x2)/(float)1000,(float)(y1-y2)/(float)1000};
}


//获取团队阵营
static int GetPlayerTeam(long Target)
{
    return Read_Int(Target+0x3C);//0x34
}

//判断死亡
static bool GetPlayerDead(long Target)
{
    long PlayerHP = Read_Long(Target+0x160);//0x148
    return Read_Int(PlayerHP+0x98)==0;
}

//血量百分百
static float GetPlayerHeroHp(long Target)
{
    long PlayerHP = Read_Long(Target+0x160);//0x148
    
    int hp = Read_Int(PlayerHP+0x98);
    
    int v5= Read_Int(PlayerHP+0xA0);
    
    if(hp == 0 || v5 == 0) return 0;
    
    return (float)hp/v5;
    
}

static float GetMonsterHp(long Target)
{
    int heroid = Read_Int(Target+0x30);
    if (heroid == 6710) {
        return  MemHeroID;
    }
    MemHeroID = heroid;
    return MemHeroID;//头像偏移0x28
}


//获取玩家英雄
static int GetPlayerHero(long Target)
{
    return Read_Int(Target+0x30);//头像偏移0x28
    
}
//回城
static bool GetHeroBack(long Target){
    long GoBack_1 = Read_Long(Target+0x148);//0x130
    long GoBack_2 = Read_Long(GoBack_1+0x168);//0x168
    long GoBack_3 = Read_Long(GoBack_2+0x110);//0x110
    int GoBack = Read_Int(GoBack_3-0xd0);
    return GoBack==1; //返回是否为1 为1回城不为1正常
}

//获取玩家英雄天赋
int GetPlayerHeroTalent(long Target){
    long PlayerData1 = Read_Long(Target+ 0x148);
    long PlayerData2 = Read_Long(PlayerData1+ 0x150);
    int herotalent = Read_Int(PlayerData2+ 0x500);
    if (herotalent == 6710) {
        return MemHeroTalent;
    }
    MemHeroTalent = herotalent;
    return MemHeroTalent;
}

//玩家英雄天赋时间
int GetPlayerHeroTalentTime(long Target){//召唤师偏移
    long PlayerTime1 = Read_Long(Target+ 0x148);
    long PlayerTime2 = Read_Long(PlayerTime1+ 0x150);
    long PlayerTime3 = Read_Long(PlayerTime2+ 0x110);
    int PlayerTime4 = Read_Int(PlayerTime3+ 0x3C);
    if (PlayerTime4 == 6710) {
        return MemHeroTalentTime;
    }
    MemHeroTalentTime = (PlayerTime4 / 8192000);
    return MemHeroTalentTime;
}

//获取英雄技能时间
int GetGetHeroSkillTime(long Target){//大招偏移
    long Target_P1 = Read_Long(Target + 0x148);
    long Target_P2 = Read_Long(Target_P1 + 0x108);
    long Target_P3 = Read_Long(Target_P2 + 0x110);
    int Target_P4 = Read_Int(Target_P3 + 0x3C);
    if (Target_P4 == 6710) {
        return MemHeroSkillTime;
    }
    MemHeroSkillTime = Target_P4/8192000;
    return MemHeroSkillTime;
}

//读取技能
static bool GetKillActivate(long P_Skill)
{
    if (Read_Int(P_Skill+0x10)==0) return false;
    return Read_Int(P_Skill+0x34)==1;
}
//读取4技能
static void GetHeroSkill(long Target, bool *Skill1, bool *Skill2, bool *Skill3, bool *Skill4)
{
    long SkillList = Read_Long(Target + 0x148);
    long P_Skill1 = Read_Long(SkillList + 0xD8);
    long P_Skill2 = Read_Long(SkillList + 0xF8);
    long P_Skill3 = Read_Long(SkillList + 0x108);
    long P_Skill4 = Read_Long(SkillList + 0x150);
    
    *Skill1 = GetKillActivate(P_Skill1);
    *Skill2 = GetKillActivate(P_Skill2);
    *Skill3 = GetKillActivate(P_Skill3);
    *Skill4 = GetKillActivate(P_Skill4);
}



void GetPlayers(std::vector<SmobaHeroData> *Players)
{
    Players->clear();
    long PDatas = Read_Long(Read_Long(Game_Data)+0x380);//0x378
    NSLog(@"SMOBA-Apibug PDatas %ld", PDatas);
    if (PDatas > Imageaddress)
    {
        int MyTeam = ViewMatrix._11>0?1:2;
        long Array = Read_Long(PDatas+0x60);
        int ArraySize = Read_Int(PDatas+0x7C);
        NSLog(@"SMOBA-Apibug ArraySize %d", ArraySize);
        if (ArraySize > 0 && ArraySize <= 20)
        {
            for (int i=0; i < ArraySize; i++) {
                long P_player = Read_Long(Array+i*0x18);
                NSLog(@"SMOBA-Apibug P_player %ld", P_player);
                if (P_player > Imageaddress)
                {
                    SmobaHeroData HeroData;
                    HeroData.HeroHP = GetPlayerHeroHp(P_player);
                    HeroData.HeroID = GetPlayerHero(P_player);
                    HeroData.HeroTeam = GetPlayerTeam(P_player);
                    HeroData.Dead = GetPlayerDead(P_player);
                    HeroData.GoBack = GetHeroBack(P_player);
                    HeroData.Pos = GetPlayerPos(P_player);
                    GetHeroSkill(P_player,&HeroData.Skill1,&HeroData.Skill2,&HeroData.Skill3,&HeroData.Skill4);
                    if (HeroData.HeroTeam != MyTeam) Players->push_back(HeroData);
                }
            }
        }
    }
}


//void GetPlayers(std::vector<SmobaHeroData> *Players)
//{
//    Players->clear();
//    NSLog(@"SMOBA-Apibug 清理数据");
//    long PDatas = Read_Long(Game_Data+0x380);
//    NSLog(@"SMOBA-Apibug PDatas %ld",PDatas);
//    if (PDatas > Imageaddress)
//    {
//        int MyTeam = ViewMatrix._11>0?1:2;
//        long Array = Read_Long(PDatas+0x60);
//        int ArraySize = Read_Int(PDatas+0x7C);
//        NSLog(@"SMOBA-Apibug ArraySize %d",ArraySize);
//        if (ArraySize > 0 && ArraySize <= 20)
//        {
//            for (int i=0; i < ArraySize; i++) {
//                long P_player = Read_Long(Array+i*0x18);
//                NSLog(@"SMOBA-Apibug P_player %ld", P_player);
//                if (P_player > Imageaddress)
//                {
//                    SmobaHeroData HeroData;
//                    //NSLog(@"SMOBA---");
//                  //  HeroData.HeroTeam = GetPlayerTeam(P_player);//获取玩家阵营
//                    if ( GetPlayerTeam(P_player) == MyTeam) continue;
//                    HeroData.HeroHP = GetPlayerHeroHp(P_player);//获取玩家谢亮百分比
//                    if (GetPlayerDead(P_player)) {
//                        //NSLog(@"SMOBA---这个人死了");
//                        HeroData.Dead = GetPlayerDead(P_player);//判断玩家是否阵亡
//                        Players->push_back(HeroData);
//                        continue;
//                    }else{
//                        HeroData.Dead = GetPlayerDead(P_player);//判断玩家是否阵亡
//                    }
//                    HeroData.Pos = GetPlayerPos(P_player);//获取玩家屏幕坐标
//                    HeroData.HeroID = GetPlayerHero(P_player);//获取玩家英雄
//                    HeroData.GoBack = GetHeroBack(P_player);//判断玩家是否正在回城状态
//                    HeroData.HeroTalent = GetPlayerHeroTalent(P_player);
//                    HeroData.HeroTalentTime = GetPlayerHeroTalentTime(P_player);
//                    HeroData.HeroSkillTime = GetGetHeroSkillTime(P_player);
//                    Players->push_back(HeroData);//阵营
//                }
//            }
//        }
//    }
//}

//当前血量
static int32_t GetGameHP(long Target){
    long HeroHP = Read_Long(Target+0x148);
    int32_t HP = Read_Int(HeroHP+0xA0);
    return HP;
}
//最大血量
static int32_t GetGameMaxHP(long Target){
    long MonsterMaxHP = Read_Long(Target+0x148);
    int32_t MaxHP = Read_Int(MonsterMaxHP+0xA8);
    return MaxHP;
}

//野怪
void GetMonster(std::vector<SmobaMonsterData> *野怪数据)
{
    野怪数据->clear();
    long PDatas = *(long*)(Game_Data+0x138);
    if (PDatas > Imageaddress)
    {
        
        long Monster_Data = *(long*)(PDatas+0x148);
        int Monster_Count = *(int*)(PDatas+0x164);
        NSLog(@"Monster_Count=%d",Monster_Count);
        for (int i=0; i < Monster_Count; i++) {
            SmobaMonsterData Monster;
            long P_Monster = *(long*)(Monster_Data+i*0x18);
            Monster.野怪ID = GetPlayerHero(P_Monster);
            Monster.野怪当前血量 = GetGameHP(P_Monster);
            Monster.野怪最大血量 = GetGameMaxHP(P_Monster);
            Monster.MonsterPos = GetPlayerPos(P_Monster);
            
            野怪数据->push_back(Monster);
        }
        
    }
}

void GetMonsterTime(std::vector<SmobaMonsterTime> *野怪倒计时数据)
{
    野怪倒计时数据->clear();
    int64_t MsWorld = *(long long*)(Imageaddress + 0x10CC33DC8);
    int64_t MsDead = *(long long*)(MsWorld + 0x3A8);
    int64_t MsMonsterDataV1 = *(long long*)(MsDead + 0x88);
    int64_t MsMonsterDataV3 = *(long long*)(MsMonsterDataV1 + 0x120);
    int MonsterDeathArr[16] = {0,24,264,408,432,456,360,48,72,384,288,312,336,240,192,216};
    for (int i = 0; i < 16; i++) {
        int64_t DeathMonster = *(long long*)(MsMonsterDataV3 + MonsterDeathArr[i]);
        int32_t MonsterTime = *(int32_t*)(DeathMonster + 0x238)/1000 +3; //0x230
        if (!MonsterTime)continue;
        int32_t MonsterTimeMax = *(int32_t*)(DeathMonster + 0x1E4)/1000 +3;
        if (!MonsterTimeMax)continue;
        Vector2 MonsterLoc = MsMonsterLocFun(MonsterDeathArr[i]);
        if (!MonsterLoc.x&&!MonsterLoc.y)continue;
        SmobaMonsterTime Monstertime;
        Monstertime.野怪ID=MonsterDeathArr[i];
        Monstertime.野怪倒计时=MonsterTime;
        野怪倒计时数据->push_back(Monstertime);
    }
    
}

//矩阵
bool RefreshMatrix() {
    long viewportAddr = Read_Long(Game_Viewport + 0xb8);
    long level1Addr = Read_Long(viewportAddr + 0x0);
    long matrixAddr = Read_Long(level1Addr + 0x10) + 0x30c;
    Read_Data(matrixAddr, 64, &ViewMatrix);
    return true;
}

//bool RefreshMatrix()
//{
//    
//    long Ptr_View  = Read_Long(Read_Long(Read_Long(Read_Long(Read_Long(Read_Long(Read_Long(Game_Viewport + 0x80) + 0x1C8) + 0x138) + 0x68) + 0x88) + 0xA0) + 0x0);
//    NSLog(@"SMOBA-Apibug Ptr_View %ld",Ptr_View);
//
//    if (Ptr_View < Imageaddress) return false;
////    Read_Data(Ptr_View + 0x2C8,64,&ViewMatrix);
//    Read_Data(Read_Long(Ptr_View + 0x10) + 0x2C8, 64, &ViewMatrix);
//    return true;
//}

void* find_module_by_path(char* machoPath)
{
    NSString* path = [NSBundle.mainBundle.bundlePath stringByAppendingPathComponent:[NSString stringWithUTF8String:machoPath]];
    
    for(int i=0; i< _dyld_image_count(); i++) {

        const char* fpath = _dyld_get_image_name(i);
        void* baseaddr = (void*)_dyld_get_image_header(i);
        void* slide = (void*)_dyld_get_image_vmaddr_slide(i); //no use

        if([path isEqualToString:[NSString stringWithUTF8String:fpath]])
            return baseaddr;
    }
    
    return NULL;
}

bool Gameinitialization()
{
    Imageaddress = get_module_base();
    Game_Data = Read_Long(Imageaddress+0xE7D23F8);
    Game_Viewport = Read_Long(Imageaddress+0xEDD77D0);
    NSLog(@"SMOBA-Apibug Imageaddress %ld",Imageaddress);
    NSLog(@"SMOBA-Apibug Game_Data %ld",Game_Data);
    NSLog(@"SMOBA-Apibug Game_Viewport %ld",Game_Viewport);
    return Game_Data > Imageaddress && Game_Viewport > Imageaddress;
}

