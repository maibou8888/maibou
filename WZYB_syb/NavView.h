//
//  NavView.h
//  WZYB_syb
//
//  Created by wzyb on 14-6-13.
//  Copyright (c) 2014年 WZYB. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NavView : UIView<UIAlertViewDelegate>
{
     UIView *view_Nav;
}
@property(nonatomic,strong) NSString *topHeight;
@property(nonatomic,strong) UIView *view_Nav;
-(UIView *)NavView_Title2:(NSString *)title;
-(UIView *)NavView_Title1:(NSString *)title;
-(UIView *)NavView_Title:(NSString *)title;
+ (float) heightForTextView: (UITextView *)textView WithText: (NSString *) strText;//计算textView文本高度
+(NSString *)returnString:(NSString *)str;
+(NSInteger)returnCount;//返回多少条未读
+(NSString*)returnPeriod:(NSString *)Str_time;   //Period 判断是一天中的 上午 下午 还是夜晚
+(UIImageView *)Show_Nothing_Face;
+(NSString *)return_SignStatus:(NSString *)title;
+(NSString *)return_index_H:(NSString *)strH Label:(NSString *)lab;
+(NSString *)return_YES_Or_NO:(NSString*)str;
+(void)Portal_Exist;//判断有没有分支url
+(NSString*) doDevicePlatform;
+(NSString *)HTTPCode:(NSInteger)code;
+(BOOL) validateMobile:(NSString *)mobile;
-(UIView *)NavView_Title22:(NSString *)title;
-(UIView *)NavView_Title3:(NSString *)title;
@end
