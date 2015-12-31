//
//  Function.h
//  Text
//
//  Created by DAWEI FAN on 19/05/2014.
//  Copyright (c) 2014 huiztech. All rights reserved.
//

#import <Foundation/Foundation.h>
#define IMAGE_MAX_SIZE_WIDTH 640
#define IMAGE_MAX_SIZE_GEIGHT 1136
@interface Function : NSObject
/*
 * 检查当前设备是否为模拟器
 */
+ (bool)checkIsSimulator;
/*
 * 压缩图片大小
 */
+(UIImage *)fitSmallImage:(UIImage *)image;
/*
 * 设计尺寸 配合上面方法
 */
+ (CGSize)fitsize:(CGSize)thisSize;
/*
 * 合法年月日
 */
+(BOOL)isOKDate:(NSString *)str;
/*
 * 输入框抖动
 */
+(void)lockAnimationForView:(UIView*)view;
/*
 * 判断字符串是否为空 方法
 */
+(BOOL) isBlankString:(NSString *)string ;
/*
 * 判断网络是否可用
 */
+(BOOL)isConnectionAvailable;
/*
 * 判断String是否为空
 */
+ (BOOL)retuYES:(id)object;
/*
 * 时间戳
 */
+(NSString *)getTimeNow;
/*
 * 获取系统时间 精确到秒
 */
+(NSString *)getSystemTimeNow;
/*
 * 获取系统年月日
 */
+(NSString *)getYearMonthDay_Now;
/*
 * 图片转换成二进制文件并返回
 */
+(NSData *)Image_TransForm_Data:(UIImage *)image;
/*
 * 按比例修改图片尺寸
 */
+ (UIImage *) imageWithImageSimple:(UIImage*)image scaledToSize:(CGSize) newSize;
/*
 * 缩放图片
 */
+ (CGRect)scaleImage:(UIImage *)image toSize:(CGRect)newSize;
/*
 * 自动调整label高度
 */
+ (CGSize)labelSize:(UILabel *)label;
/*
 * 获取imageData
 */
+(NSData *)Image_TransForm_Data1:(UIImage *)image Tag:(float)tag;

/*
 * 有文件夹则读取路径 无则创建之后再读取路径 并返回路径
 */
+(NSString *)CreateTheFolder_From:(NSString *)fileStyle
                   FileHolderName:(NSString *)folderName
                         FileName:(NSString *)fileName;
/*
 * 获取文件路径 或者文件夹路径 fileName 为文件夹名称或者带后缀的文件比如1.png
 */
+(NSString *)achieveThe_filepath:(NSString *)fileName Kind:(NSString *)fileStyle;
/*
 * 判断文件是否存在 YES 存在 NO不存在
 */
+(BOOL)judgeFileExist:(NSString * )fileName Kind:(NSString *)fileStyle;
/*
 * 创建一个名为fileName的文件
 */
+(void)creatTheFile:(NSString *)fileName Kind:(NSString *)fileStyle;
/*
 * 把file 写入名为fileName的文件
 */
+(void)WriteToFile:(NSString *)fileName File:(id)dic Kind:(NSString *)fileSyle;
/*
 * 从名为fileName的文件 读取 数据内容
 */
+(id)ReadFromFile:(NSString *)fileName Kind:(NSString *)fileStyle;
/*
 * 修改文件中某条信息记录
 */
+(void)Revision_TheFile_Name:(NSString *)fileName File:(NSString *)txt Key:(NSString *)key Kind:(NSString *)fileStyle;
/*
 * 删除路径下所有缓存文件包括文件夹自己
 */
+(void)Delete_TotalFileFromPath:(NSString *)fileAndFolder_Path ;
/*
 * 删除所有图片缓存
 */
+(void)Delete_TotalFileFromPath;
/*
 * 读取数据
 */
+(NSMutableArray *)ReadFromFile:(NSString *)fileName WithKind:(NSString *)fileStyle;
/*
 * 删除路径
 */
+(void)DeleteTheFile:(NSString *)fileName Kind:(NSString *)fileSyle;
/*
 * 获取UIimage
 */
+ (UIImage *)imageNamed:(NSString *)name;
/*
 * 随机获取数据
 */
+(NSMutableArray *)getRandomNumber:(NSArray * )temp;
/*
 * 判断字符串是否为空
 */
+(BOOL)StringIsNotEmpty:(NSString *)checkString;
/*
 * 根据cvalue获取clabel数据
 */
+(NSString *)Calculate:(NSString *)str_H Value:(NSString *)str_value;
/*
 * 判断人员类别
 */
+(NSString *)userType:(NSString *)type;
/*
 * 判断主管还是副主管
 */
+(NSString *)returnUtype:(NSString *)utype;
/*
 * UIButton异步加载UIimage
 */
+ (void)setButtonimageWithURLString:(NSString *)BtnUrlString Button:(UIButton *)button;
/*
 * 判断照相机是否有权限打开
 */
+ (BOOL)CanOpenCamera;
/*
 * 判断定位是否打开
 */
+ (BOOL)CanLocation;
/*
 * 按照约定压缩图片尺寸以及质量
 */
+ (NSData *)GetImageFromCamera:(UIImage *)image;
/*
 * 按照指定的文本自动调整label的高度
 */
+ (CGSize)labelSize:(UILabel *)label text:(NSString *)text;
/*
 * 跳到百度地图app
 */
+ (BOOL)JumpToBaiduMap:(NSString *)origin destination:(NSString *)destin region:(NSString *)region go:(NSInteger)goFlag;
@end
