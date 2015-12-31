//
//  Water_Mark.h
//  WZYB_syb
//
//  Created by wzyb on 14-9-18.
//  Copyright (c) 2014年 WZYB. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Water_Mark : NSObject
+(UIImage*) imageWithUIView:(UILabel*) view;
+(UIImage*) imageWithUIView1:(UIImageView*) view;
+(NSData *)Image_TransForm_Data:(UIImage *)image;
+(UIImage *)TransFor_ChooseImage:(UIImage*)choose_image  Lab:(UIImage*)image;
+(UILabel*)Label_Freedom_Content:(NSString *)content Choose_image:(UIImage*)choose_image;
+ (UIImage *)getPicZoomImage:(UIImage *)image Tag:(float)tag;
@end
