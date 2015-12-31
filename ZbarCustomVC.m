//
//  ZbarCustomVC.m
//  NewProject
//
//  Created by wzyb on 15-1-2.
//  Copyright (c) 2015年 Steven. All rights reserved.
//

#import "ZbarCustomVC.h"

static ZbarCustomVC * reader = nil;

@implementation ZbarCustomVC

+(ZbarCustomVC*)getSingle       //单例
{
    if (reader != nil)
    {
        return reader;
    }
    static dispatch_once_t lock;
    
    dispatch_once(&lock, ^{ reader = [[self alloc]init]; });
    
    return reader;
}

-(void)CreateTheQR:(id)delegate
{
    reader.readerDelegate = delegate;
    [delegate presentViewController:reader animated:YES completion:nil];
    timer = [NSTimer scheduledTimerWithTimeInterval:0.02
                                             target:self
                                           selector:@selector(animation1)
                                           userInfo:nil
                                            repeats:YES];   //定时器，设定时间过1.5秒
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        UIView * view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 420)];
        view.backgroundColor = [UIColor clearColor];
        self.cameraOverlayView = view;
        
        UIView * downView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 80)];
        downView.alpha = 0.3;
        downView.backgroundColor = [UIColor blackColor];
        [view addSubview:downView];
        
        UIView * downViewLeft = [[UIView alloc] initWithFrame:CGRectMake(0, 80, 20, 280)];
        downViewLeft.alpha = 0.3;
        downViewLeft.backgroundColor = [UIColor blackColor];
        [view addSubview:downViewLeft];
        
        UIView * downViewRight = [[UIView alloc] initWithFrame:CGRectMake(300, 80, 20, 280)];
        downViewRight.alpha = 0.3;
        downViewRight.backgroundColor = [UIColor blackColor];
        [view addSubview:downViewRight];
        
        UILabel * label = [[UILabel alloc] initWithFrame:CGRectMake(20, 20, 280, 40)];
        label.text = @"请将产品的条码置于矩形方框内";
        label.textColor = [UIColor whiteColor];
        label.textAlignment = 1;
        label.lineBreakMode = 0;
        label.numberOfLines = 2;
        label.backgroundColor = [UIColor clearColor];
        [downView addSubview:label];
        
        UIImageView * image = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"pick_bg.png"]];
        image.frame = CGRectMake(20, 80, 280, 280);
        [view addSubview:image];
        
        UIView * downView1 = [[UIView alloc] initWithFrame:CGRectMake(0, 360, 320,Phone_Height-360+20)];
        downView1.alpha = 0.3;
        downView1.backgroundColor = [UIColor blackColor];
        [view addSubview:downView1];

        UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
        cancelButton.alpha = 0.4;
        [cancelButton setFrame:CGRectMake(130, 30, 60, 60)];
        [cancelButton setImage:[UIImage imageNamed:@"dismiss.png"] forState:UIControlStateNormal];
        [cancelButton addTarget:self action:@selector(dismissOverlayView:)forControlEvents:UIControlEventTouchUpInside];
        [downView1 addSubview:cancelButton];
        
        _line = [[UIImageView alloc] initWithFrame:CGRectMake(30, 10, 220, 2)];
        _line.image = [UIImage imageNamed:@"line.png"];
        [image addSubview:_line];
        
        self.supportedOrientationsMask = UIInterfaceOrientationPortrait;      //不支持界面旋转
        self.showsHelpOnFail = NO;
        self.showsZBarControls = NO;
        self.scanCrop = CGRectMake(0.1, 0.2, 0.8, 0.8);                       //扫描的感应框
        self.showsHelpOnFail = NO;
        self.showsZBarControls = NO;
        ZBarImageScanner * scanner1 = self.scanner;
        [scanner1 setSymbology:ZBAR_I25 config:ZBAR_CFG_ENABLE to:0];
    }
    return self;
}

- (void)dismissOverlayView:(id)sender{
    [timer invalidate];
    _line.frame = CGRectMake(30, 10, 220, 2);
    num = 0;
    upOrdown = NO;
    [self dismissModalViewControllerAnimated: YES];
    [self.zbarDelegate zbarDismissAction];
}

-(void)animation1
{
    if (upOrdown == NO) {
        num ++;
        _line.frame = CGRectMake(30, 10+2*num, 220, 2);
        if (2*num == 260) {
            upOrdown = YES;
        }
    }
    else {
        num --;
        _line.frame = CGRectMake(30, 10+2*num, 220, 2);
        if (num == 0) {
            upOrdown = NO;
        }
    }
}

@end
