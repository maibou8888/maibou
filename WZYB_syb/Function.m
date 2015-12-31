 //
//  Function.m
//  Text
//
//  Created by DAWEI FAN on 19/05/2014.
//  Copyright (c) 2014 huiztech. All rights reserved.
//

#import "Function.h"
#import "Reachability.h"
#include <sys/sysctl.h>
#import <CoreLocation/CoreLocation.h>
#define Size 1.5

@implementation Function

+ (bool)checkIsSimulator
{
    NSString* deviceType = [UIDevice currentDevice].model;
    //Dlog(@"deviceType = %@", deviceType);
    if ([deviceType isEqualToString:@"iPhone Simulator"]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提醒" message:@"模拟器暂不支持照相机功能" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
        return YES;
    }
    return NO;
}

+(UIImage *)fitSmallImage:(UIImage *)image
{
    if (nil == image)
    {
        return nil;
    }
    if (image.size.width<IMAGE_MAX_SIZE_WIDTH && image.size.height<IMAGE_MAX_SIZE_GEIGHT)
    {
        return image;
    }
    CGSize size = [self fitsize:image.size];
    UIGraphicsBeginImageContext(size);
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    [image drawInRect:rect];
    UIImage *newing = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newing;
}

+ (CGSize)fitsize:(CGSize)thisSize
{
    if(thisSize.width == 0 && thisSize.height ==0)
        return CGSizeMake(0, 0);
    CGFloat wscale = thisSize.width/IMAGE_MAX_SIZE_WIDTH;
    CGFloat hscale = thisSize.height/IMAGE_MAX_SIZE_GEIGHT;
    CGFloat scale = (wscale>hscale)?wscale:hscale;
    CGSize newSize = CGSizeMake(thisSize.width/scale, thisSize.height/scale);
    return newSize;
}
+(BOOL)isOKDate:(NSString *)str
{
    NSString * Regex = @"^(?:(?!0000)[0-9]{4}([-/.]?)(?:(?:0?[1-9]|1[0-2])([-/.]?)(?:0?[1-9]|1[0-9]|2[0-8])|(?:0?[13-9]|1[0-2])([-/.]?)(?:29|30)|(?:0?[13578]|1[02])([-/.]?)31)|(?:[0-9]{2}(?:0[48]|[2468][048]|[13579][26])|(?:0[48]|[2468][048]|[13579][26])00)([-/.]?)0?2([-/.]?)29)$";
    NSPredicate * Test = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",Regex];
    return [ Test evaluateWithObject:str];
}
+(void)lockAnimationForView:(UIView*)view
{
    CALayer *lbl = [view layer];
    CGPoint posLbl = [lbl position];
    CGPoint y = CGPointMake(posLbl.x-Size, posLbl.y-Size);
    CGPoint x = CGPointMake(posLbl.x+Size , posLbl.y+Size);
    CABasicAnimation * animation = [CABasicAnimation animationWithKeyPath:@"position"];
    [animation setTimingFunction:[CAMediaTimingFunction
                                  functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    [animation setFromValue:[NSValue valueWithCGPoint:x]];
    [animation setToValue:[NSValue valueWithCGPoint:y]];
    [animation setAutoreverses:YES];
    [animation setDuration:0.08];
    [animation setRepeatCount:3];
    [lbl addAnimation:animation forKey:nil];
}
+(BOOL) isBlankString:(NSString *)string {//判断字符串是否为空 方法
    
    if (string == nil || string == NULL) {
        return YES;
    }
    if ([string isKindOfClass:[NSNull class]]) {
        return YES;
    }
    if ([[string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length]==0) {
        return YES;
    }
    return NO;
}
#pragma mark 检测网路状态
#pragma mark -是否存在网络
+(BOOL) isConnectionAvailable
{
    NetworkStatus networkStatus = [Reachability reachabilityForInternetConnection].currentReachabilityStatus;
    if (networkStatus == NotReachable) {
        return NO;
    }
    return YES;
}

+ (BOOL)retuYES:(id)object {
    NSString *tempString = (NSString *)object;
    if (tempString.length) {
        return YES;
    }
    return NO;
}

+(NSString *)getTimeNow
{
    NSString *timeSp = [NSString stringWithFormat:@"%ld", (long)[[NSDate date] timeIntervalSince1970]];
    return timeSp;
}
+(NSString *)getSystemTimeNow
{
    NSString* date;
    NSDateFormatter * formatter = [[NSDateFormatter alloc ] init];
    [formatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
    date = [formatter stringFromDate:[NSDate date]];
    NSString * timeNow = [[NSString alloc] initWithFormat:@"%@", date];
    return timeNow;
}
+(NSString *)getYearMonthDay_Now
{
    NSString* date;
    NSDateFormatter * formatter = [[NSDateFormatter alloc ] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    date = [formatter stringFromDate:[NSDate date]];
    //Dlog(@"%@",date);
    NSString * timeNow = [[NSString alloc] initWithFormat:@"%@", date];
    return timeNow;
}
+(NSData *)Image_TransForm_Data1:(UIImage *)image Tag:(float)tag
{
    float actualHeight = image.size.height;
    float actualWidth = image.size.width;
    
    if(actualHeight>(Phone_Height*2.0)||actualWidth>(Phone_Weight*2.0))
    {
        actualWidth=actualWidth/(actualHeight/(Phone_Height*2.0));
        actualHeight=actualHeight/(actualHeight/(Phone_Height*2.0));
    }
    else
    {
        actualWidth=actualWidth/2.0;
        actualHeight=actualHeight/2.0;
    }
    NSData *imageData = UIImageJPEGRepresentation([self imageWithImageSimple:image scaledToSize:CGSizeMake(actualWidth, actualHeight)] ,tag);
    //Dlog(@"%dKB",imageData.length/1024);
    
    if(imageData.length/1024<=150)
    {
        //Dlog(@"VVVV");
    }
    return imageData;
}
+(NSData *)Image_TransForm_Data:(UIImage *)image
{
    float actualHeight = image.size.height;
    float actualWidth = image.size.width;
    
    if(actualHeight>(Phone_Height*2.0)||actualWidth>(Phone_Weight*2.0))
    {
        actualWidth=actualWidth/(actualHeight/(Phone_Height*2.0));
        actualHeight=actualHeight/(actualHeight/(Phone_Height*2.0));
    }
    else
    {
        actualWidth=actualWidth/2.0;
        actualHeight=actualHeight/2.0;
    }
    NSData *imageData = UIImageJPEGRepresentation([self imageWithImageSimple:image scaledToSize:CGSizeMake(actualWidth, actualHeight)] ,0.6);
    //Dlog(@"%dKB",imageData.length/1024);
    
    if(imageData.length/1024<=150)
    {
        //Dlog(@"VVVV");
    }
    return imageData;
}
/**
 * 修改图片大小
 */
+ (UIImage *) imageWithImageSimple:(UIImage*)image scaledToSize:(CGSize) newSize
{
    newSize.height=image.size.height*(newSize.width/image.size.width);
    UIGraphicsBeginImageContext(newSize);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage=UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return  newImage;
    
}
+ (CGRect )scaleImage:(UIImage *)image toSize:(CGRect)newSize
{
    float actualHeight = image.size.height;
    float actualWidth = image.size.width;
    float imgRatio = actualWidth/actualHeight;
    if(actualWidth>=IMAGE_MAX_SIZE_WIDTH)
    {
        actualWidth/=2;
        actualHeight/=2;
    }
    float maxRatio = newSize.size.width/newSize.size.height;
    
    if(imgRatio!=maxRatio){
        if(imgRatio < maxRatio){
            imgRatio = newSize.size.height/ actualHeight;
            actualWidth = imgRatio * actualWidth;
            actualHeight = newSize.size.height;
        }
        else{
            imgRatio = newSize.size.width / actualWidth;
            actualHeight = imgRatio * actualHeight;
            actualWidth = newSize.size.width;
        }
    }
    CGRect rect = CGRectMake(0,0,actualWidth , actualHeight);
    return rect;
}

+ (CGSize)labelSize:(UILabel *)label {
    CGSize titleSize = [label.text sizeWithFont:[UIFont systemFontOfSize:13]
                              constrainedToSize:CGSizeMake(209, 1000)
                                  lineBreakMode:NSLineBreakByWordWrapping];
    return titleSize;
}

///////////////////////////////////////////////
+(NSString*)CreateTheFolder_From:(NSString *)fileStyle FileHolderName:(NSString *)folderName FileName:(NSString *)fileName
{
    //创建文件夹：
    //查找路径的时候 会创建该文件夹 所以即使做删除所有文件包括文件夹后 最后查找路径的时候还是会被重新创建，这个路径就是该应用的归属 不错不是吗
    NSString *filePath=[Function achieveThe_filepath:nil Kind:fileStyle];
    filePath = [filePath stringByAppendingPathComponent:folderName];
    BOOL isDir = NO;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL existed = [fileManager fileExistsAtPath:filePath isDirectory:&isDir];
    if ( !(isDir == YES && existed == YES) )
    {
        [fileManager createDirectoryAtPath:filePath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    filePath = [filePath stringByAppendingPathComponent:fileName];
    return filePath;
}
+(NSString *)achieveThe_filepath:(NSString *)fileName Kind:(NSString *)fileSyle
{
    NSString *filePath;
    if([fileSyle isEqual:Document])
    {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        //获取完整路径
        NSString *documentsDirectory = [paths objectAtIndex:0];
        filePath = [documentsDirectory stringByAppendingPathComponent:fileName];
    }
    else if([fileSyle isEqual:Library_Cache])
    {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        //获取完整路径
        NSString *documentsDirectory = [paths objectAtIndex:0];
        filePath = [documentsDirectory stringByAppendingPathComponent:fileName];
    }
    else//tmp
    {
        filePath=[NSString stringWithFormat:@"%@%@",NSTemporaryDirectory(),fileName];
    }
    return filePath;
}

+(BOOL)judgeFileExist:(NSString * )fileName Kind:(NSString *)fileStyle
{
    NSString *filepath=[Function CreateTheFolder_From:fileStyle FileHolderName:MyFolder FileName:fileName];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    return  [fileManager fileExistsAtPath:filepath];
    //返回 YES 存在  NO不存在
}
+(void)creatTheFile:(NSString *)fileName Kind:(NSString *)fileStyle
{
    NSString *filepath=[Function CreateTheFolder_From:fileStyle FileHolderName:MyFolder FileName:fileName];
    NSFileManager* fm = [NSFileManager defaultManager];
    [fm createFileAtPath:filepath contents:nil attributes:nil];
}
+(void)WriteToFile:(NSString *)fileName File:(id)dic Kind:(NSString *)fileStyle
{
     NSString *filepath=[Function CreateTheFolder_From:fileStyle FileHolderName:MyFolder FileName:fileName];
    if([dic writeToFile:filepath atomically:YES])
    {
        //Dlog(@"写入成功");
    }
    else
    {
        //Dlog(@"写入失败");
    }
}
+(id )ReadFromFile:(NSString *)fileName Kind:(NSString *)fileStyle
{
    NSString *filepath=[Function CreateTheFolder_From:fileStyle FileHolderName:MyFolder FileName:fileName];
    id dic = [NSDictionary dictionaryWithContentsOfFile:filepath];
    return dic;
}

+(NSMutableArray *)ReadFromFile:(NSString *)fileName WithKind:(NSString *)fileStyle
{
    NSString *filepath=[Function CreateTheFolder_From:fileStyle FileHolderName:MyFolder FileName:fileName];
    NSMutableArray *mutableArray = [NSMutableArray arrayWithContentsOfFile:filepath];
    return mutableArray;
}

+(void)DeleteTheFile:(NSString *)fileName Kind:(NSString *)fileSyle
{
    NSString *filepath=[Function achieveThe_filepath:fileName Kind:fileSyle];
    //删除文件
    NSFileManager *fm = [NSFileManager defaultManager];
    [fm removeItemAtPath:filepath error:nil];
    if([Function judgeFileExist:fileName Kind:fileSyle])
    {
        //Dlog(@"删除失败");
    }
    else
    {
        //Dlog(@"删除成功");
    }
}
+(void)Revision_TheFile_Name:(NSString *)fileName File:(NSString *)txt Key:(NSString *)key Kind:(NSString *)fileSyle
{
    NSString *filepath=[Function achieveThe_filepath:fileName Kind:fileSyle];
    NSMutableDictionary *applist = [[NSMutableDictionary alloc] initWithContentsOfFile:filepath];
   // 修改一个plist文件数据
    [applist setObject:txt forKey:key];
    //修改后直接把数据再写入文件
    [applist writeToFile:filepath atomically:YES];
 }
+(void)Delete_TotalFileFromPath:(NSString *)fileAndFolder_Path
{
    [[NSFileManager defaultManager] removeItemAtPath:fileAndFolder_Path error:nil];
}
+(void)Delete_TotalFileFromPath;
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    //获取完整路径
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:@"ImageCache"];
    [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
}
+ (UIImage *)imageNamed:(NSString *)name
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone){
        if (isIPhone5) {
            return [UIImage imageNamed: [NSString stringWithFormat:@"%@-568h",name]];
        }else{
            return [UIImage imageNamed:name];
        }
    }else{
        return [UIImage imageNamed:name];
    }
    return [UIImage imageNamed:name];
}
+(NSMutableArray *)getRandomNumber:(NSArray * )temp
{
    NSMutableArray *tempArray = [[NSMutableArray alloc] initWithArray:temp];
    NSMutableArray *resultArray = [[NSMutableArray alloc] init];
    int i;
    NSInteger count = temp.count;
    //Dlog(@"count:%d",count);
    for (i = 0; i < count; i ++) {
        int index = arc4random() % (count - i);
        [resultArray addObject:[tempArray objectAtIndex:index]];
       // //Dlog(@"index:%d,xx:%@",index,[tempArray objectAtIndex:index]);
        [tempArray removeObjectAtIndex:index];
    }
   // //Dlog(@"resultArray is %@",resultArray);
    return resultArray;
}

+(BOOL)StringIsNotEmpty:(NSString *)checkString
{
    if ([checkString isEqualToString:@"(null)"] || checkString.length == 0 || (NSNull *)checkString == [NSNull null]) {
        return NO;
    }
    return YES;
}

+(NSString *)Calculate:(NSString *)str_H Value:(NSString *)str_value
{
    NSDictionary *dic=[[BasicData sharedInstance].dic_BasicData objectForKey:@"MasterList"];
    NSArray *arr=[dic objectForKey:str_H];
    for(NSInteger i=0;i<arr.count;i++)
    {
        NSDictionary *dict=[arr objectAtIndex:i];
        if([[dict objectForKey:@"cvalue"] isEqualToString:str_value])
        {
            return [dict objectForKey:@"clabel"];
        }
    }
    return @"";
}

+(NSString *)userType:(NSString *)type {
    if ([type isEqualToString:@"1"]) {
        return @"普通员工";
    }else if ([type isEqualToString:@"2"]) {
        return @"部门负责人";
    }
    return @"企业负责人";
}

+(NSString *)returnUtype:(NSString *)utype {
    if ([utype isEqualToString:@"0"]) {
        return @"主管";
    }else if ([utype isEqualToString:@"1"]) {
        return @"副主管";
    }
    return @"";
}

+ (void)setButtonimageWithURLString:(NSString *)BtnUrlString Button:(UIButton *)button{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        UIImage *image = nil;
        NSURL *url = [NSURL URLWithString:BtnUrlString];
        NSData *data = [NSData dataWithContentsOfURL:url];
        image = [UIImage imageWithData:data];
        
        if (image) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [button setImage:image forState:UIControlStateNormal];
            });
        }else {
            NSLog(@"async load error.");
        }
    });
}

+ (BOOL)CanOpenCamera{
    if (isIOS7) {
        AVAuthorizationStatus authstatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
        if (authstatus ==AVAuthorizationStatusRestricted || authstatus ==AVAuthorizationStatusDenied) //用户关闭了权限
        {
            return NO;
        }
        return YES;
    }
    return YES;
}

+ (BOOL)CanLocation{
    if ([CLLocationManager locationServicesEnabled] &&
        ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorized
         || [CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined
         || [CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedWhenInUse)) {
            return YES;
        }
    return NO;
}

+ (NSData *)GetImageFromCamera:(UIImage *)image {
    NSData *imagedata=UIImageJPEGRepresentation([image resize:CGSizeMake(Phone_Weight,Phone_Height)],1);
    return imagedata;
}

+ (CGSize)labelSize:(UILabel *)label text:(NSString *)text {
    [label setNumberOfLines:0];
    label.lineBreakMode = NSLineBreakByWordWrapping;
    UIFont *font = [UIFont fontWithName:@"Arial" size:15];
    CGSize size = CGSizeMake(320,2000);
    CGSize labelsize = [text sizeWithFont:font constrainedToSize:size lineBreakMode:NSLineBreakByWordWrapping];
    return labelsize;
}

+ (BOOL)JumpToBaiduMap:(NSString *)origin destination:(NSString *)destin region:(NSString *)region go:(NSInteger)goFlag
{
    NSString *originNew = [origin stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *destinNew = [destin stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *regionNew = [region stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];

    NSString *stringURL = [NSString stringWithFormat:
                           @"baidumap://map/direction?origin=%@&destination=%@&mode=driving&region=%@",
                           originNew,destinNew,regionNew];
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:stringURL]]) {
        if (goFlag) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:stringURL]];
        }
        return YES;
    }
    return NO;
}
@end
