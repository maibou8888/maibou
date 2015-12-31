//
//  Water_Mark.m
//  WZYB_syb
//
//  Created by wzyb on 14-9-18.
//  Copyright (c) 2014年 WZYB. All rights reserved.
//

#import "Water_Mark.h"

@implementation Water_Mark
+(UIImage*) imageWithUIView:(UILabel*) view
{
    UIGraphicsBeginImageContext(view.bounds.size);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    [view.layer renderInContext:ctx];
    UIImage* tImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return tImage;
}
+(UIImage*) imageWithUIView1:(UIImageView*) view
{
    UIGraphicsBeginImageContext(view.bounds.size);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    [view.layer renderInContext:ctx];
    UIImage* tImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return tImage;
}
+(NSData *)Image_TransForm_Data:(UIImage *)image
{
    
    float actualHeight = image.size.height;
    float actualWidth = image.size.width;
    
    if(actualHeight>Phone_Weight||actualWidth>(Phone_Weight))
    {
        actualWidth=actualWidth/(actualWidth/(Phone_Weight));
        actualHeight=actualHeight/(actualHeight/(Phone_Height));
    }
    else
    {
        actualWidth=actualWidth/2.0;
        actualHeight=actualHeight/2.0;
    }
    actualWidth= actualWidth*0.9;
    actualHeight= actualHeight*0.9;
    NSData *imageData = UIImageJPEGRepresentation(image,1.0);
    UIImage *img=[UIImage imageWithData:imageData];
 imageData =UIImageJPEGRepresentation([Function imageWithImageSimple:img scaledToSize:CGSizeMake(actualWidth, actualHeight)] ,1.0);
    
    if(imageData.length/1024<=150)
    {
    }
    return imageData;
}
+(UIImage *)TransFor_ChooseImage:(UIImage*)choose_image  Lab:(UIImage*)image
{
    UIImageView *whole_imageView=[[UIImageView alloc]init];
    whole_imageView.backgroundColor=[UIColor clearColor];
    whole_imageView.image=choose_image;
    whole_imageView.frame=CGRectMake(0, 0, whole_imageView.image.size.width,  whole_imageView.image.size.height);
    
    UIImageView *imgView=[[UIImageView alloc]init];
    imgView.image=image;
    imgView.backgroundColor=[UIColor clearColor];
    imgView.frame=CGRectMake(0,choose_image.size.height-image.size.height , image.size.width, image.size.height);
    [whole_imageView addSubview:imgView];
    return [self imageWithUIView1:whole_imageView];
}
+(UILabel*)Label_Freedom_Content:(NSString *)content Choose_image:(UIImage*)choose_image
{
    UILabel *lab=[[UILabel alloc]initWithFrame:CGRectMake(0, 0,choose_image.size.width, 44)];
    lab.backgroundColor=ClearWhite;
    [lab setNumberOfLines:0];
    lab.textAlignment=NSTextAlignmentLeft ;
    
    int w = choose_image.size.width;
    int h = choose_image.size.height;
    if(h<w)
    {
        h=w;
    }
    UIFont *font = [UIFont systemFontOfSize:w/11.0/3.0];
    CGSize size = CGSizeMake(lab.frame.size.width,2000);
    lab.text=content;
    //计算UILabel字符显示的实际大小
    CGSize labelsize = [lab.text sizeWithFont:font constrainedToSize:size lineBreakMode:NSLineBreakByWordWrapping];
    //重设UILabel实例的frame
    lab.frame=CGRectMake(lab.frame.origin.x,lab.frame.origin.x,lab.frame.size.width, labelsize.height+10);
    lab.font=[UIFont systemFontOfSize:w/11.0/3.0];
    return lab;
}
+ (UIImage *)getPicZoomImage:(UIImage *)image Tag:(float)tag
{
   // UIImage *img = image;
    CGSize itemSize ;
    float actualHeight = image.size.height*tag;
    float actualWidth = image.size.width*tag;
    
//    if(actualHeight>(Phone_Height*2.0)||actualWidth>(Phone_Weight*2.0))
//    {
//        actualWidth=actualWidth/(actualHeight/(Phone_Height*2.0));
//        actualHeight=actualHeight/(actualHeight/(Phone_Height*2.0));
//    }
//    else
//    {
//        actualWidth=actualWidth/2.0;
//        actualHeight=actualHeight/2.0;
//    }
    itemSize = CGSizeMake(actualWidth,actualHeight);
    UIGraphicsBeginImageContext(itemSize);
    //   UIGraphicsBeginImageContextWithOptions(itemSize,NO,scole);//这里要测试一下2的效果
    CGRect imageRect = CGRectMake(0, 0, actualWidth, actualHeight);
    [image drawInRect:imageRect];
    image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}
@end
