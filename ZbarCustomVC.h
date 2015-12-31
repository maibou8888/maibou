//
//  ZbarCustomVC.h
//  NewProject
//  //1.0.4 二维码扫描类的封装
//  Created by wzyb on 15-1-2.
//  Copyright (c) 2015年 Steven. All rights reserved.
//

#import "ZBarReaderViewController.h"
#import "ZBarSDK.h"

@protocol ZbarCustomDelegate
@optional
- (void)zbarDismissAction;          //点击消失的委托回调
@end

@interface ZbarCustomVC : ZBarReaderViewController<ZBarReaderDelegate>
{
    int num;
    BOOL upOrdown;
    NSTimer * timer;
}

@property (nonatomic, strong) UIImageView * line;
@property(assign,nonatomic)id<ZbarCustomDelegate> zbarDelegate;

+(ZbarCustomVC *)getSingle;
-(void)CreateTheQR:(id)delegate;    //创建二维码
- (void)dismissOverlayView:(id)sender;
@end
