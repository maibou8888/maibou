//
//  NdUncaughtExceptionHandler.m
//  WZYB_syb
//
//  Created by wzyb on 14-9-5.
//  Copyright (c) 2014年 WZYB. All rights reserved.
//

#import "NdUncaughtExceptionHandler.h"
#import <MessageUI/MFMailComposeViewController.h>
NSString *applicationDocumentsDirectory() {
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}

void UncaughtExceptionHandler(NSException *exception) {
    NSArray *arr = [exception callStackSymbols];
    NSString *reason = [exception reason];
    NSString *name = [exception name];
    //手机系统版本
    NSString* phoneVersion = [[UIDevice currentDevice] systemVersion];
    //应用版本
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *appCurVersion = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    
    NSString *iphoneInfo=[NSString stringWithFormat:@"\n手机系统版本:IOS%@==手机型号:%@==应用版本:%@\n",phoneVersion,[NavView doDevicePlatform],appCurVersion];
    
    
    NSString *url_msg = [NSString stringWithFormat:@"\n=============异常崩溃报告=============\n%@name:\n%@\nreason:\n%@\ncallStackSymbols:\n%@",
                     iphoneInfo,name,reason,[arr componentsJoinedByString:@"\n"]];
    
   [NdUncaughtExceptionHandler Post_url:url_msg];
}

@implementation NdUncaughtExceptionHandler

-(NSString *)applicationDocumentsDirectory {
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}

+ (void)setDefaultHandler
{
    NSSetUncaughtExceptionHandler (&UncaughtExceptionHandler);
}
+ (NSUncaughtExceptionHandler*)getHandler
{
    return NSGetUncaughtExceptionHandler();
}
+(void)Post_url:(NSString *)url_msg
{
    if([Function isConnectionAvailable])
    {//主服务器基地址
        NSString *string;
        string=[NSString stringWithFormat:@"%@%@",kBASEURL,KError];
        NSURL *url = [ NSURL URLWithString :  string ];
        ASIFormDataRequest *request = [ ASIFormDataRequest requestWithURL :url];
        request.delegate = self;
        [request setRequestMethod:@"POST"];
        [request setPostValue:[[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"account"] forKey:@"user.uid"];
        [request setPostValue:url_msg forKey:@"content"];
        [request startSynchronous ];
    }
}

-(void)requestFinished:(ASIHTTPRequest *)request {
    
}

-(void)requestFailed:(ASIHTTPRequest *)request {
    
}
@end
