
#import <Foundation/Foundation.h>

//===============================混淆函数名===========================================
//加密函数  //可自己随便改,混淆后ida函数名会变
#define encryptpro MD5NQ1U2GP4EFVP1075WTA0EJIY5YEE4OME6X7PIO00BPYNGVK
//解密函数
#define decryptpro MD5VIH1TDUHJOB44IRNZKA0DCW7B2R2EPSLA1DOW4D7GYRW5DX9
//MD5加密函数
#define MD5Digest MD5Y2WG26955UFJOLMJ4PMZK2FENGITZ9CZGMJN1B3L2H7D3WSX
//验证函数
#define SCLCode MD5NJW4PLTCMPR0MSHGWTUJUTBQII0H4IZHCA9ZB0EEROTDU95A
//MD5函数
#define md5 MD5X0PFVPF467MT4YXDYPABCX24SJ9204D2RPGZJZQCDV0FANR8
//设置返回原生状态数据函数
#define sharedNetWorkingApiClient MD59GFANH5Q3GN2G78D4A8J4T2JKBN3IJ373UKXZP0BFEV5HA6L
//返回状态数据变量
#define netWorkingClient MD5VPSYLKM0WXBEZME7GZVP8IHKNYDUSA3LEVU0322AVG2RIOAF
//将字典拼接成URL形式函数
#define stitchingStringFromDictionary MD5XLNFK0B3TS89S25IX2HC9WEKJIKB7M5PL8FXTO06N5AL0LMS
//发送post请求函数名
#define Post_AppendURL MD5D8I94A4F61A8J8SN952UJCMG7W7ZLQ9XOFO4NF0BVO79HRH0
//
//==================================================================================
//POST默认
@interface NetTool : NSObject
/**
 *  AFN异步发送post请求，返回原生数据
 *
 *  @param appendURL 追加URL
 *  @param param     参数字典
 *  @param success   成功Block
 *  @param failure   失败Block
 *
 *  @return NSURLSessionDataTask任务类型
 */
+ (NSURLSessionDataTask *)__attribute__((optnone))Post_AppendURL:(NSString *)appendURL myparameters:(NSDictionary *)param mysuccess:(void (^)(id responseObject))success myfailure:(void (^)(NSError *error))failure;
static NSString *MD5Digest(NSString *Str);
@end
