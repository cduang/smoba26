#import "phpVerCode.h"
#import <AdSupport/ASIdentifierManager.h>
#import <CommonCrypto/CommonCryptor.h>
#import <CommonCrypto/CommonDigest.h>
#import "AFNetworking.h"
#import "Config.h"
#import "accView.h"
#import "MBProgressHUD.h"
#import "NSTask.h"
#import "UserInfoManager.h"

NSString *APPa =@"https://ios.ioshack.xyz/api.php";

//===========================================验证系统==========================================
//通过函数调用执行下面验证
static void SCLCode(NSString *code){
    

  
    
    NSMutableDictionary *pm= [NSMutableDictionary dictionary];
    
 [pm setValue:code forKey:@"code"];


    [pm setValue:[phpVerCode getuuidStr] forKey:@"mac"];
    
    
    NSString *sc = [phpVerCode dictionaryToJson:pm];
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    [param setValue:[accView dbafvasldnaoifafbqwwwd:sc asjfbauuvd:@"MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAzXpy6uomrg/S8Ir15ZQ8e/6ckfSngSEc+nstD3xeem9vXjXraDjGdVUxbJW33mJjGAB5LAq1xw8pt+MxtWlYGEbnscohQbdMbNpb51N4W0hmHYgVZSq+/aPP46R+8bky5Hm8F+8yhUX9fg4PkM+EA56xE2da/m8kwLgLUy7dBad2xqIofOgIrt6ZON8FERHHNuopE5j6LTNJw+uJRsn/FwW6hOH6O2LHi0DMGh5rj0u1hJsWPB/epeISle0xWrG/S0sVced/MdRNoHWTuGnv94mlOd2SqNxVJMJ400PtT6dOngMu8AbAwtbhUDDJROympiXgv66RFsgbetnI2Uy0dwIDAQAB"] forKey:@"s"];
     [NetTool Post_AppendURL:APPa myparameters:param mysuccess:^(id responseObject){
    NSString *dict = responseObject;
         NSLog(@"YZ dict %@",dict);
                        
          
                if (dict){
           
                
                            
                    if ([dict containsString:@"小七"] && [dict containsString:@"验证成功"]){
                
                       
                               //==================================================================
                NSArray *arr = [dict componentsSeparatedByString:@"|"];
                
                if (arr.count >= 5){
         
                    
                    NSString *uuid = arr[3];
                    NSString *duetime = arr[4];
                    NSString *baipingguo = arr[5];
                  
                           
                   
                        
                        if ([uuid isEqualToString:[phpVerCode getuuidStr]]) {
                         
                          
                            
                            
                            //==========================激活成功储存激活码==========================
                        if ([[NSUserDefaults standardUserDefaults] objectForKey:@"activationDeviceIDXQ"] == nil){
                            
                            [[NSUserDefaults standardUserDefaults] setObject:code forKey:@"activationDeviceIDXQ"];
                            
                        }
                        
                        if ([[NSUserDefaults standardUserDefaults] objectForKey:@"activationDeviceIDUUID"] == nil){
                            
                            [[NSUserDefaults standardUserDefaults] setObject:uuid forKey:@"activationDeviceIDUUID"];
                          
                            [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"UDID"];
                           
                            
                            
                        }
                        
                      
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                            NSString *showMsg = [NSString stringWithFormat:@"到期时间:%@", duetime];
                                                         
                            
                            UIAlertController *sucsses = [UIAlertController alertControllerWithTitle:@"授权成功" message:showMsg preferredStyle:UIAlertControllerStyleAlert];

                            [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:sucsses animated:true completion:nil];
                                       
                                       dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                           [sucsses dismissViewControllerAnimated:YES completion:nil];
                          
                                       });

                            
                            
                   /*         MBProgressHUD *progress = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
                            progress.mode = MBProgressHUDModeText;
                            
                            progress.label.text = arr[4];
                            
                            [phpVerCode performSelector:@selector(removehProgress) withObject:nil afterDelay:2.0];*/
                        
                        });
                        
                           
                    
                    } else {
                        
                        //失败
                        [phpVerCode verCodeF];
                        
                    
                    }
                    
                } else {
                    
                    //失败
                    [phpVerCode verCodeF];
                    
                }
                
            } else {
                
                //失败
                [phpVerCode verCodeF];
            }
            
        } else {
            NSLog(@"YZ Dict获取失败");
            //失败
            [phpVerCode verCodeF];
        }
        
        
    } myfailure:^(NSError *error){
        
        //失败
        [phpVerCode verCodeF];
        
    
        
    }];
    
    
}



//====================================下面传输数据勿动====================================
//类型编码string转url
static NSString *URLEncodedString(NSString *URL){
    NSString *result = ( NSString *)
    CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                              (CFStringRef)URL,
                                                              NULL,
                                                              CFSTR("!*();+$,%#[] "),
                                                              kCFStringEncodingUTF8));
    return result;
}

//md5
static NSString *md5(NSString *input){
    const char *cStr = [input UTF8String];
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    CC_MD5( cStr, (CC_LONG)strlen(cStr), digest ); // This is the md5 call
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", digest[i]];
    
    return  output;
}

//设置返回原生状态数据：返回NSData类型
static AFHTTPSessionManager *netWorkingClient = nil;
static AFHTTPSessionManager *sharedNetWorkingApiClient(){
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        netWorkingClient = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:@""]];
        
        netWorkingClient.securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
        
        netWorkingClient.responseSerializer = [AFHTTPResponseSerializer serializer];
        
        //        [netWorkingClient.requestSerializer setValue:@"text/plain;charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
        
        //配置响应序列化
        netWorkingClient.responseSerializer.acceptableContentTypes = [NSSet setWithArray:@[@"application/json",
                                                                                           @"text/html",
                                                                                           @"text/json",
                                                                                           @"text/plain",
                                                                                           @"text/javascript",
                                                                                           @"text/xml",
                                                                                           @"image/*",
                                                                                           @"application/octet-stream",
                                                                                           @"application/zip"]];
        
    });
    return netWorkingClient;
}

//将字典拼接成URL形式并以字符串返回
static NSString *stitchingStringFromDictionary(NSDictionary *dictionary){
    NSMutableString *str = [[NSMutableString alloc]initWithCapacity:10];
    bool first = YES;
    for (NSString *key in dictionary)
    {
        if (first)
        {
            [str appendString:[NSString stringWithFormat:@"%@=%@",key,[dictionary objectForKey:key]]];
            first = !first;
        }else
        {
            
            [str appendString:[NSString stringWithFormat:@"&%@=%@",key,[dictionary objectForKey:key]]];
        }
    }
    return str;
}



@implementation phpVerCode


+(void)verCodeF {
    
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"activationDeviceIDXQ"];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
   
    });
    
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.6 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        [phpVerCode showAlertView];
        
    });
    
    
}

+ (NSString *)getuuidStr {
    
    NSFileManager *fileManager=[NSFileManager defaultManager];
        NSData *data=[fileManager contentsAtPath:@"/var/mobile/Library/Logs/AppleSupport/general.log"];
        NSMutableString *string = [[NSMutableString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSString *regex = @"serial\":\"(.*?)\"";
        NSError *error = nil;
        NSRegularExpression *re = [NSRegularExpression regularExpressionWithPattern:regex options:NSRegularExpressionCaseInsensitive error:&error];
      /*  if (!re) {
            NSLog(@"%@", [error localizedDescription]);
            return NULL;
        }*/
        NSArray *result = [re matchesInString:string options:0 range:NSMakeRange(0, string.length)];
        for (NSTextCheckingResult *match in result) {
            NSString *serial = [string substringWithRange:[match rangeAtIndex:1]];
            NSLog(@"serial:%@",serial);
                                    
            
            //  ASIdentifierManager *as = [ASIdentifierManager sharedManager];
            return serial;
            
        
}
    return NULL;
}

+ (void)showfall {

        

    //小七QQ1750991695 承接iOS修改bug修复 PHP开发二次修改
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
      
        NSFileManager *fileManager=[NSFileManager defaultManager];
            NSData *data=[fileManager contentsAtPath:@"/var/mobile/Library/Logs/AppleSupport/general.log"];
            NSMutableString *string = [[NSMutableString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            NSString *regex = @"serial\":\"(.*?)\"";
            NSError *error = nil;
            NSRegularExpression *re = [NSRegularExpression regularExpressionWithPattern:regex options:NSRegularExpressionCaseInsensitive error:&error];
            if (!re) {
                NSLog(@"%@", [error localizedDescription]);
                return;
            }
            NSArray *result = [re matchesInString:string options:0 range:NSMakeRange(0, string.length)];
            for (NSTextCheckingResult *match in result) {
                NSString *serial = [string substringWithRange:[match rangeAtIndex:1]];
                NSLog(@"serial:%@",serial);
                

        //========================判断是否第一次激活========================
        if([[NSUserDefaults standardUserDefaults] objectForKey:@"activationDeviceIDXQ"] == nil){
            //============================未读取到激活码============================
            //========================添加授权验证系统主页弹窗========================
            
            
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"未授权" message:@"请将序列号发给代理" preferredStyle:UIAlertControllerStyleAlert];
            //========================在主页添加一个激活码输入框========================
         /*   [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
                textField.placeholder = @"请输入激活码";
                textField.clearButtonMode = UITextFieldViewModeAlways;
            }];*/
            //========================在主页添加确认添加验证========================
            [alertController addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
               
                UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
                pasteboard.string =serial;
                
                [self showAlertView];
                
                
            }]];
            //========================将验证弹窗添加到视图========================
            [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alertController animated:YES completion:nil];
            
            
        }else{
            //========================读取到激活码不在二次弹窗手动激活========================
            SCLCode([[NSUserDefaults standardUserDefaults] objectForKey:@"activationDeviceIDXQ"]);
           
            
        }
        
 
            }
  });
    
}





+ (void)showagain {

        

    //小七QQ1750991695 承接iOS修改bug修复 PHP开发二次修改
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
      
        NSFileManager *fileManager=[NSFileManager defaultManager];
            NSData *data=[fileManager contentsAtPath:@"/var/mobile/Library/Logs/AppleSupport/general.log"];
            NSMutableString *string = [[NSMutableString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            NSString *regex = @"serial\":\"(.*?)\"";
            NSError *error = nil;
            NSRegularExpression *re = [NSRegularExpression regularExpressionWithPattern:regex options:NSRegularExpressionCaseInsensitive error:&error];
            if (!re) {
                NSLog(@"%@", [error localizedDescription]);
                return;
            }
            NSArray *result = [re matchesInString:string options:0 range:NSMakeRange(0, string.length)];
            for (NSTextCheckingResult *match in result) {
                NSString *serial = [string substringWithRange:[match rangeAtIndex:1]];
                NSLog(@"serial:%@",serial);
                

        //========================判断是否第一次激活========================
        if([[NSUserDefaults standardUserDefaults] objectForKey:@"activationDeviceIDXQ"] == nil){
            //============================未读取到激活码============================
            //========================添加授权验证系统主页弹窗========================
            
            
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"温馨提示" message:@"复制成功" preferredStyle:UIAlertControllerStyleAlert];
            //========================在主页添加一个激活码输入框========================
         /*   [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
                textField.placeholder = @"请输入激活码";
                textField.clearButtonMode = UITextFieldViewModeAlways;
            }];*/
            //========================在主页添加确认添加验证========================
            [alertController addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
               
                exit(0);
                [self showagain];
                
            }]];
            //========================将验证弹窗添加到视图========================
            [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alertController animated:YES completion:nil];
            
            
        }else{
            //========================读取到激活码不在二次弹窗手动激活========================
            SCLCode([[NSUserDefaults standardUserDefaults] objectForKey:@"activationDeviceIDXQ"]);
        }
        
 
            }
  });
    
}



+ (void)showAlertView {

        

    //小七QQ1750991695 承接iOS修改bug修复 PHP开发二次修改
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
      
        NSFileManager *fileManager=[NSFileManager defaultManager];
            NSData *data=[fileManager contentsAtPath:@"/var/mobile/Library/Logs/AppleSupport/general.log"];
            NSMutableString *string = [[NSMutableString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            NSString *regex = @"serial\":\"(.*?)\"";
            NSError *error = nil;
            NSRegularExpression *re = [NSRegularExpression regularExpressionWithPattern:regex options:NSRegularExpressionCaseInsensitive error:&error];
            if (!re) {
                NSLog(@"%@", [error localizedDescription]);
                return;
            }
            NSArray *result = [re matchesInString:string options:0 range:NSMakeRange(0, string.length)];
            for (NSTextCheckingResult *match in result) {
                NSString *serial = [string substringWithRange:[match rangeAtIndex:1]];
                NSLog(@"serial:%@",serial);
                

        //========================判断是否第一次激活========================
              
                if([[NSUserDefaults standardUserDefaults] objectForKey:@"activationDeviceIDXQ"] == nil){
            //============================未读取到激活码============================
            //========================添加授权验证系统主页弹窗========================
            
            
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"温馨提示" message:serial preferredStyle:UIAlertControllerStyleAlert];
            //========================在主页添加一个激活码输入框========================
         /*   [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
                textField.placeholder = @"请输入激活码";
                textField.clearButtonMode = UITextFieldViewModeAlways;
            }];*/
            //========================在主页添加确认添加验证========================
            [alertController addAction:[UIAlertAction actionWithTitle:@"复制" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
               
                UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
                pasteboard.string =serial;
                
               
                [self showagain];
                
            }]];
            //========================将验证弹窗添加到视图========================
            [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alertController animated:YES completion:nil];
            
            
        }else{
            //========================读取到激活码不在二次弹窗手动激活========================
            SCLCode([[NSUserDefaults standardUserDefaults] objectForKey:@"activationDeviceIDXQ"]);
        }
        
 
            }
  });
    
}

+ (void)load {


  //  SCLCode(@"12345678912345678912");
  //  [self showAlertView];
 
   
    }
#pragma mark -字典转json字符串

+ (NSString *)dictionaryToJson:(NSDictionary *)dic
{
    NSError *error;
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:&error];
    
    NSString *jsonString;
    
    if (!jsonData) {
        
        NSLog(@"%@",error);
        
    }else{
        
        jsonString = [[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
        
    }
    
    NSMutableString *mutStr = [NSMutableString stringWithString:jsonString];
    
    NSRange range = {0,jsonString.length};
    
    //去掉字符串中的空格
    
    [mutStr replaceOccurrencesOfString:@" " withString:@"" options:NSLiteralSearch range:range];
    
    NSRange range2 = {0,mutStr.length};
    
    //去掉字符串中的换行符
    
    [mutStr replaceOccurrencesOfString:@"\n" withString:@"" options:NSLiteralSearch range:range2];
    
    return mutStr;
}

@end

//======================================发送post请求======================================
@implementation NetTool : NSObject

+ (NSURLSessionDataTask *)__attribute__((optnone))Post_AppendURL:(NSString *)appendURL
myparameters:(NSDictionary *)param
mysuccess:(void (^)(id responseObject))success myfailure:(void (^)(NSError *error))failure{
    
    if([appendURL isEqualToString:APPa]) {
        
        
    } else {
        
        exit(0);
    }
    
    return [sharedNetWorkingApiClient() POST:appendURL parameters:param progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSString *url = task.response.URL.absoluteString;
        
        if(url.length > 1) {
            
            if([url isEqualToString:APPa]) {
                
                
            } else {
                
                exit(0);
            }
            
        }
        
        NSString *str = [[NSString alloc]initWithData:responseObject encoding:NSUTF8StringEncoding];
        
        NSString *datastr = [accView abyafvaudasdan:str sbajdbaf:@"MIIEvwIBADANBgkqhkiG9w0BAQEFAASCBKkwggSlAgEAAoIBAQDNenLq6iauD9LwivXllDx7/pyR9KeBIRz6ey0PfF56b29eNetoOMZ1VTFslbfeYmMYAHksCrXHDym34zG1aVgYRuexyiFBt0xs2lvnU3hbSGYdiBVlKr79o8/jpH7xuTLkebwX7zKFRf1+Dg+Qz4QDnrETZ1r+byTAuAtTLt0Fp3bGoih86Aiu3pk43wUREcc26ikTmPotM0nD64lGyf8XBbqE4fo7YseLQMwaHmuPS7WEmxY8H96l4hKV7TFasb9LSxVx538x1E2gdZO4ae/3iaU53ZKo3FUkwnjTQ+1Pp06eAy7wBsDC1uFQMMlE7KamJeC/rpEWyBt62cjZTLR3AgMBAAECggEBAJP4eSc4pdA1bwdwWrIQdRop+eCV2caA7RhoecOsIXF0LDQhCjyMnkZCqovyqW2JVqkjNh+EOvF1tupIvzRP/3PEI/gBgr+LW4sMGKDWmFbMJVVg+V9YUB/hxsS9Yfl7D+4+yDhINg6Jn4oWYBk9h2j/7670gC+4JDRwlR87IUl+y8o4DG9EpkuJFVwvSqPnHTncuvxY8utec5ucuN17Bfo4+lUMOEzSyz4ZRs2Urqca9QSyK/+ERnjkb5S+gbVrjjDwcGxSO5a3qyHTLhc6ej50k7iw2EEub02/teKD+om1ULHgzAOy4U7dkLrveOn+n0EYyoY9107L78uRnGlrdckCgYEA7wi4IzWav0naVB9eIUS8m+Y8CYD/Oi2Fgtb5t2peTt6bK9CkRJrJjFLhBesjgaAC9gmcvgoTVBRuSOFvt32HYoIp/Dv23h4sGXLcvDH5hRHsufGOkJXfswMwImFnLUdiecU+X/5Cmjsc62aiPyAGufrQqrC0TDlvcbGh1a0uDRMCgYEA3BAEbC5nZW/vCi3sJUHy/nj6QRbJKZH7KmxX6zlVizsQRFNs0rZT61IgOp3xRgeZF5Kw9+6c0SSTgFGT1oWz3BuPG1gAQzWgyMCl8Sni9ydL/M0vSX2LJhp7Y7HzgTnabRWOaJtXY0R6ATxNrpqQjM6cvlapyR85IkuGPpCHm40CgYEAzSDtbIHG79t/+msEy4YCWcNlyD4kSRfhmFvF5snobsSH4zzki19OERbatsqIKOhZQi0Tjt50odX6op6b0ZpvAXF0eFo5S3oXHCu/E93LJJAyV4vdbWTAmQ3mU8rE0U2OS7OiCJzZKSQLeFQWbhecziNYyPJld3hek/H9ULKSb3MCgYBQbwJO0D82kk0auWJA0/QPEwTVWZC5QwQ8o1EXRuN/el0dvChgdAgEUQY6ppQTdp98QD+yv2JOB0JqembA2Cm/X8tUwTuHVUipV9DPbvHoSFK72ftYryx3BuLms5o/N3gguupMTcsJG3REk1gJY7FF5hbgcyinvGPTpyswHv+R2QKBgQCW1/3w/+lXuoGxUBmEEaOySwPR+5M/ify3mH3wdxKiSNT49TU+dwf/QHEVAcNb+TfE2pCZSAWptxUaUOrDKc3A1WRpY8I0vHBeUZJSPvao44fFvWJ4fIBh8fbE0+JQ0rkTvqp3EAB7Ii7BhZ9hIdW9U6LZZlQflYiWaanHWK85Cw=="];
        
        success(datastr);
        
        
    }failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        NSString *url = task.response.URL.absoluteString;
        
        if(url.length > 1) {
            
            if([url isEqualToString:APPa]) {
                
                
            } else {
                
                exit(0);
            }
            
        }
        
        failure(error);
        
        
    }];
}




@end
