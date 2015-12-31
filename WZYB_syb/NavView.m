//
//  NavView.m
//  WZYB_syb
//
//  Created by wzyb on 14-6-13.
//  Copyright (c) 2014年 WZYB. All rights reserved.
//

#import "NavView.h"
#import "Function.h"
#include <sys/types.h>
#include <sys/sysctl.h>
//#import "UIImage+WaterMark.h"
//#import "UIImage+Category/wiUIImage+Category.h"
//#import "UIImage+Category/wiUIImageView+Category.h"

#import "AppDelegate.h"
#define FaceW 94
#define FaceH 54.5
@implementation NavView
@synthesize view_Nav=view_Nav;
-(UIView *)NavView_Title2:(NSString *)title
{
    AppDelegate *app=(AppDelegate *)[[UIApplication sharedApplication]delegate];
    UILabel *label_Title;
    if(isIOS7)
    {
        view_Nav=[[UIView alloc]init];
        if(app.isLeft)
        {
            view_Nav.frame=CGRectMake(0, 0, Phone_Height, 64);
        }
        else
        {
            view_Nav.frame=CGRectMake(0, 0, Phone_Weight, 64);
        }
        label_Title=[[UILabel alloc]initWithFrame:CGRectMake(44, 20, view_Nav.frame.size.width-88, 44)];
        
    }
    else
    {
        view_Nav=[[UIView alloc]init];
        if(app.isLeft)
        {
            view_Nav.frame=CGRectMake(0, 0, Phone_Height, 44);
        }
        else
        {
            view_Nav.frame=CGRectMake(0, 0, Phone_Weight, 44);
        }
        label_Title=[[UILabel alloc]initWithFrame:CGRectMake(44, 0, view_Nav.frame.size.width-88, 44)];
    }
    view_Nav.backgroundColor=Nav_Bar;
    label_Title.backgroundColor=[UIColor clearColor];
    label_Title.text=title;
    label_Title.textColor=[UIColor whiteColor];
    label_Title.font =[UIFont systemFontOfSize:19.0f];
    label_Title.textAlignment=NSTextAlignmentCenter;
    [view_Nav addSubview:label_Title];
    
    UIImageView *img_arrow=[[UIImageView alloc]init];
    img_arrow.frame=CGRectMake(Phone_Weight-44-44-44, 20, 44, 44);
    img_arrow.image=[UIImage imageNamed:@"nav_menu_arrow.png"];
    [view_Nav addSubview:img_arrow];
    return view_Nav;
}

-(UIView *)NavView_Title1:(NSString *)title
{
    AppDelegate *app=(AppDelegate *)[[UIApplication sharedApplication]delegate];
    UILabel *label_Title;
    if(isIOS7)
    {
        view_Nav=[[UIView alloc]init];
        if(app.isLeft)
        {
            view_Nav.frame=CGRectMake(0, 0, Phone_Height, 64);
        }
        else
        {
            view_Nav.frame=CGRectMake(0, 0, Phone_Weight, 64);
        }
        label_Title=[[UILabel alloc]initWithFrame:CGRectMake(44, 20, view_Nav.frame.size.width-88, 44)];
        
    }
    else
    {
        view_Nav=[[UIView alloc]init];
        if(app.isLeft)
        {
            view_Nav.frame=CGRectMake(0, 0, Phone_Height, 44);
        }
        else
        {
            view_Nav.frame=CGRectMake(0, 0, Phone_Weight, 44);
        }
        label_Title=[[UILabel alloc]initWithFrame:CGRectMake(44, 0, view_Nav.frame.size.width-88, 44)];
    }
    view_Nav.backgroundColor=Nav_Bar;
    label_Title.backgroundColor=[UIColor clearColor];
    label_Title.text=title;
    label_Title.textColor=[UIColor whiteColor];
    label_Title.font =[UIFont systemFontOfSize:19.0f];
    label_Title.textAlignment=NSTextAlignmentCenter;
    [view_Nav addSubview:label_Title];

    return view_Nav;
}

-(UIView *)NavView_Title3:(NSString *)title
{
    AppDelegate *app=(AppDelegate *)[[UIApplication sharedApplication]delegate];
    UILabel *label_Title;
    if(isIOS7)
    {
        view_Nav=[[UIView alloc]init];
        if(app.isLeft)
        {
            view_Nav.frame=CGRectMake(0, 0, Phone_Height, 64);
        }
        else
        {
            view_Nav.frame=CGRectMake(0, 0, Phone_Weight, 64);
        }
        label_Title=[[UILabel alloc]initWithFrame:CGRectMake(44, 20, view_Nav.frame.size.width-88, 44)];
        
    }
    else
    {
        view_Nav=[[UIView alloc]init];
        if(app.isLeft)
        {
            view_Nav.frame=CGRectMake(0, 0, Phone_Height, 44);
        }
        else
        {
            view_Nav.frame=CGRectMake(0, 0, Phone_Weight, 44);
        }
        label_Title=[[UILabel alloc]initWithFrame:CGRectMake(44, 0, view_Nav.frame.size.width-88, 44)];
    }
    view_Nav.backgroundColor=Nav_Bar;
    label_Title.backgroundColor=[UIColor clearColor];
    label_Title.text=title;
    label_Title.textColor=[UIColor whiteColor];
    label_Title.font =[UIFont systemFontOfSize:16.0f];
    label_Title.textAlignment=NSTextAlignmentCenter;
    [view_Nav addSubview:label_Title];
    
    return view_Nav;
}

-(UIView *)NavView_Title22:(NSString *)title
{
    AppDelegate *app=(AppDelegate *)[[UIApplication sharedApplication]delegate];
    UILabel *label_Title;
    if(isIOS7)
    {
        view_Nav=[[UIView alloc]init];
        if(app.isLeft)
        {
            view_Nav.frame=CGRectMake(0, 0, Phone_Height, 64);
        }
        else
        {
            view_Nav.frame=CGRectMake(0, 0, Phone_Weight, 64);
        }
        label_Title=[[UILabel alloc]initWithFrame:CGRectMake(44, 20, view_Nav.frame.size.width-108, 44)];
        
    }
    else
    {
        view_Nav=[[UIView alloc]init];
        if(app.isLeft)
        {
            view_Nav.frame=CGRectMake(0, 0, Phone_Height, 44);
        }
        else
        {
            view_Nav.frame=CGRectMake(0, 0, Phone_Weight, 44);
        }
        label_Title=[[UILabel alloc]initWithFrame:CGRectMake(44, 0, view_Nav.frame.size.width-108, 44)];
    }
    view_Nav.backgroundColor=Nav_Bar;
    label_Title.backgroundColor=[UIColor clearColor];
    label_Title.text=title;
    label_Title.textColor=[UIColor whiteColor];
    label_Title.font =[UIFont systemFontOfSize:19.0f];
    label_Title.textAlignment=NSTextAlignmentCenter;
    [view_Nav addSubview:label_Title];
    
    return view_Nav;
}

-(UIView *)NavView_Title:(NSString *)title
{
    AppDelegate *app=(AppDelegate *)[[UIApplication sharedApplication]delegate];
    UILabel *label_Title;
    
    UIImageView *imageView_back=[[UIImageView alloc]init];
    if(StatusBar_System>0)
    {
        view_Nav=[[UIView alloc]initWithFrame:CGRectMake(0, 0, Phone_Weight, 64)];
        if(app.isLeft)
        {
            view_Nav.frame=CGRectMake(0, 0, Phone_Height, 64);
        }
        label_Title=[[UILabel alloc]initWithFrame:CGRectMake(44, 20, view_Nav.frame.size.width-88, 44)];
        
    }
    else
    {
        
        view_Nav=[[UIView alloc]init];
        if(app.isLeft)
        {
            view_Nav.frame=CGRectMake(0, 0, Phone_Height, 44);
        }
        else
        {
            view_Nav.frame= CGRectMake(0, 0, Phone_Weight, 44);
        }
        label_Title=[[UILabel alloc]initWithFrame:CGRectMake(44, 0, view_Nav.frame.size.width-88, 44)];
        imageView_back.frame=CGRectMake(0, 0, view_Nav.frame.size.width, 54);
    }
    [imageView_back setImage:[UIImage imageNamed:@"Nav_whiteBack"]];
    [view_Nav addSubview:imageView_back];
    imageView_back=nil;
    label_Title.backgroundColor=[UIColor clearColor];
    label_Title.text=title;
    //label_Title.textColor=Orange;
    label_Title.font =[UIFont systemFontOfSize:19.0f];
    label_Title.textAlignment=NSTextAlignmentCenter;
    [view_Nav addSubview:label_Title];
    return view_Nav;
}
/*其实UITextView在上下左右分别有一个8px的padding，当使用[NSString sizeWithFont:constrainedToSize:lineBreakMode:]时，需要将UITextView.contentSize.width减去16像素（左右的padding 2 x 8px）。同时返回的高度中再加上16像素（上下的padding），这样得到的才是UITextView真正适应内容的高度。*/
+ (float) heightForTextView: (UITextView *)textView WithText: (NSString *) strText{
        
    float fPadding = 16.0; // 8.0px x 2
    CGSize constraint = CGSizeMake(textView.contentSize.width - fPadding, CGFLOAT_MAX);
    
    CGSize size = [strText sizeWithFont: textView.font constrainedToSize:constraint lineBreakMode:NSLineBreakByWordWrapping];
    
    float fHeight = size.height + 16.0;
    
    return fHeight;
}
+(NSString *)returnString:(NSString *)str
{
    NSRange substr;
    NSMutableString *mstr= [NSMutableString stringWithString:str];
    NSString * search = @"(null)";
    NSString * replace = @"";
    substr = [mstr rangeOfString:search];
    while (substr.location != NSNotFound) {
        [mstr replaceCharactersInRange:substr withString:replace];
        substr = [mstr rangeOfString:search];
    }
    //Dlog(@"%@",mstr);
    return mstr;
}
-(NSString *)showWater:(NSString *)str
{
    NSRange substr;
    NSMutableString *mstr= [NSMutableString stringWithString:str];
    NSString * search = @"(null)";
    NSString * replace = @"";
    substr = [mstr rangeOfString:search];
    while (substr.location != NSNotFound) {
        [mstr replaceCharactersInRange:substr withString:replace];
        substr = [mstr rangeOfString:search];
    }
    //Dlog(@"%@",mstr);
    return mstr;
}
+(NSInteger)returnCount
{
    NSInteger count=0;
    for (int i=0;i<[IsRead sharedInstance].arr_isRead.count;i++)
    {
        NSDictionary *dic=[[IsRead sharedInstance].arr_isRead objectAtIndex:i];//[dictionary setObject:@"YES" forKey:@"is_read"];
        if([[dic objectForKey:@"is_read"] isEqualToString:@"NO"])
        {
            count++;
        }
    }
    return count;
}
+(NSString*)returnPeriod:(NSString *)Str_time
{//   2014-12-12 12:12
    NSArray *array = [Str_time componentsSeparatedByString:@" "];
    NSInteger Int_return=[[[array objectAtIndex:1]substringToIndex:2]integerValue];
    if(Int_return>=0&&Int_return<=12)
        return @"cell_order_am";//上午
    else if(Int_return>12&&Int_return<=18)
        return @"cell_order_pm.png";//下午
    else
        return @"cell_order_night.png";//晚上
}
+(UIImageView *)Show_Nothing_Face
{
    UIImageView *imageView_face=[[UIImageView alloc]init];
    imageView_face.image=[UIImage imageNamed:@"nav_face_nothing.png"]; //暂无符合条件的数据那张图片
    imageView_face.frame=CGRectMake((Phone_Weight-FaceW)*0.5, (Phone_Height-FaceH)*0.5, FaceW, FaceH);
    return imageView_face;
}
+(NSString *)return_SignStatus:(NSString *)title
{
    if([title isEqualToString:@"疑似地址不匹配"])
        return @"0";
    if([title isEqualToString:@"到达已签到"])
        return @"1";
    if([title isEqualToString:@"到达未签退"])
        return @"2";
    if([title isEqualToString:@"签到成功"])
        return @"3";
    if([title isEqualToString:@"终端无坐标"])
        return @"-1";
    return @"";
}
+(NSString *)return_index_H:(NSString *)strH Label:(NSString *)lab
{
    NSDictionary *dic=[[BasicData sharedInstance].dic_BasicData objectForKey:@"MasterList"];
    NSArray *sectionName=[dic objectForKey:strH];
    if(sectionName.count==0)//预存字段里面没有数据的话
    {
        return @"";
    }
    else
    {
        for(int i=0;i<sectionName.count;i++)
        {
            NSDictionary *dic=[sectionName objectAtIndex:i];
            if([[dic objectForKey:@"clabel"] isEqualToString:lab])
            {
                return [dic objectForKey:@"cvalue"];
            }
        }
    }
    return @"";
}
+(NSString *)return_YES_Or_NO:(NSString*)str
{
    if([str isEqualToString:@"未执行"]||[str isEqualToString:@"不代收"])
    {
      return @"0";
    }
    else if([str isEqualToString:@"已执行"]||[str isEqualToString:@"代收"])
        return @"1";
    return @"";
}
/*
 
 基地址转换逻辑：master 服务器 和 分支服务器的基地址 一个 rootMaster_url 一直在登录时候调用 第二次以后用 url
 请求成功会回调一个参数 url  这个是在登录以后一直使用,服务请求失败 就用rootMaster_url重新请求一次即可
 忽略不同服务器带来的数据可能不同步问题
*/
+(void)Portal_Exist
{
     AppDelegate *app=(AppDelegate *)[[UIApplication sharedApplication]delegate];
     if([Function isBlankString:KPORTAL_URL])
     {
         app.isPortal=NO;//基地址不可用
     }
     else
     {
         app.isPortal=YES;//基地址可以用
     }
}
//获得设备型号
+(NSString*) doDevicePlatform
{
//    int mib[2];
//    size_t len;
//    char *machine;
//    
//    mib[0] = CTL_HW;
//    mib[1] = HW_MACHINE;
//    sysctl(mib, 2, NULL, &len, NULL, 0);
//    machine = malloc(len);
//    sysctl(mib, 2, machine, &len, NULL, 0);
//    
//    NSString *platform = [NSString stringWithCString:machine encoding:NSASCIIStringEncoding];
//    free(machine);
    
    size_t size;
    int nR = sysctlbyname("hw.machine",
                          NULL, &size, NULL,
                          0);
    char*machine = (char*)malloc(size);
    
    nR =
    sysctlbyname("hw.machine", machine, &size,
                 NULL, 0);
    NSString *platform = [NSString
                          stringWithCString:machine encoding:NSASCIIStringEncoding];
    free(machine);
    if ([platform isEqualToString:@"iPhone1,1"]) return @"iPhone 2G (A1203)";
    if ([platform isEqualToString:@"iPhone1,2"]) return @"iPhone 3G (A1241/A1324)";
    if ([platform isEqualToString:@"iPhone2,1"]) return @"iPhone 3GS (A1303/A1325)";
    if ([platform isEqualToString:@"iPhone3,1"]) return @"iPhone 4 (A1332)";
    if ([platform isEqualToString:@"iPhone3,2"]) return @"iPhone 4 (A1332)";
    if ([platform isEqualToString:@"iPhone3,3"]) return @"iPhone 4 (A1349)";
    if ([platform isEqualToString:@"iPhone4,1"]) return @"iPhone 4S (A1387/A1431)";
    if ([platform isEqualToString:@"iPhone5,1"]) return @"iPhone 5 (A1428)";
    if ([platform isEqualToString:@"iPhone5,2"]) return @"iPhone 5 (A1429/A1442)";
    if ([platform isEqualToString:@"iPhone5,3"]) return @"iPhone 5c (A1456/A1532)";
    if ([platform isEqualToString:@"iPhone5,4"]) return @"iPhone 5c (A1507/A1516/A1526/A1529)";
    if ([platform isEqualToString:@"iPhone6,1"]) return @"iPhone 5s (A1453/A1533)";
    if ([platform isEqualToString:@"iPhone6,2"]) return @"iPhone 5s (A1457/A1518/A1528/A1530)";
    if ([platform isEqualToString:@"iPhone7,1"]) return @"iPhone 6 Plus (A1522/A1524)";
    if ([platform isEqualToString:@"iPhone7,2"]) return @"iPhone 6 (A1549/A1586)";
    
    if ([platform isEqualToString:@"iPod1,1"])   return @"iPod Touch 1G (A1213)";
    if ([platform isEqualToString:@"iPod2,1"])   return @"iPod Touch 2G (A1288)";
    if ([platform isEqualToString:@"iPod3,1"])   return @"iPod Touch 3G (A1318)";
    if ([platform isEqualToString:@"iPod4,1"])   return @"iPod Touch 4G (A1367)";
    if ([platform isEqualToString:@"iPod5,1"])   return @"iPod Touch 5G (A1421/A1509)";
    
    if ([platform isEqualToString:@"iPad1,1"])   return @"iPad 1G (A1219/A1337)";
    
    if ([platform isEqualToString:@"iPad2,1"])   return @"iPad 2 (A1395)";
    if ([platform isEqualToString:@"iPad2,2"])   return @"iPad 2 (A1396)";
    if ([platform isEqualToString:@"iPad2,3"])   return @"iPad 2 (A1397)";
    if ([platform isEqualToString:@"iPad2,4"])   return @"iPad 2 (A1395+New Chip)";
    if ([platform isEqualToString:@"iPad2,5"])   return @"iPad Mini 1G (A1432)";
    if ([platform isEqualToString:@"iPad2,6"])   return @"iPad Mini 1G (A1454)";
    if ([platform isEqualToString:@"iPad2,7"])   return @"iPad Mini 1G (A1455)";
    
    if ([platform isEqualToString:@"iPad3,1"])   return @"iPad 3 (A1416)";
    if ([platform isEqualToString:@"iPad3,2"])   return @"iPad 3 (A1403)";
    if ([platform isEqualToString:@"iPad3,3"])   return @"iPad 3 (A1430)";
    if ([platform isEqualToString:@"iPad3,4"])   return @"iPad 4 (A1458)";
    if ([platform isEqualToString:@"iPad3,5"])   return @"iPad 4 (A1459)";
    if ([platform isEqualToString:@"iPad3,6"])   return @"iPad 4 (A1460)";
    
    if ([platform isEqualToString:@"iPad4,1"])   return @"iPad Air (A1474)";
    if ([platform isEqualToString:@"iPad4,2"])   return @"iPad Air (A1475)";
    if ([platform isEqualToString:@"iPad4,3"])   return @"iPad Air (A1476)";
    if ([platform isEqualToString:@"iPad4,4"])   return @"iPad Mini 2G (A1489)";
    if ([platform isEqualToString:@"iPad4,5"])   return @"iPad Mini 2G (A1490)";
    if ([platform isEqualToString:@"iPad4,6"])   return @"iPad Mini 2G (A1491)";
    
    if ([platform isEqualToString:@"i386"])      return @"iPhone Simulator";
    if ([platform isEqualToString:@"x86_64"])    return @"iPhone Simulator";
    return platform;
}
+(NSString *)HTTPCode:(NSInteger)code
{
    
    return @"";
}
+(BOOL) validateMobile:(NSString *)mobile
{
    //判断是不是整数或是小数 (int 或者 double)
    NSString *phoneRegex = @"^[-+]?(([0-9]+)([.]([0-9]+))?|([.]([0-9]+))?)$";
    NSPredicate *phoneTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",phoneRegex];
    return [phoneTest evaluateWithObject:mobile];
}

-(void)setBackgroundColor:(UIColor *)backgroundColor {
    view_Nav.backgroundColor=backgroundColor;
}

-(void)setTopHeight:(NSString *)topHeight {
    if ([topHeight isEqualToString:@"1"]) {
        view_Nav.top = 10;
    }
}
@end
