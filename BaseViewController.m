//
//  BaseViewController.m
//  oc discuss
//
//  Created by wzyb on 15-1-6.
//  Copyright (c) 2015年 YLYL. All rights reserved.
//

#import "BaseViewController.h"

@interface BaseViewController ()<UIGestureRecognizerDelegate>

@end

@implementation BaseViewController
@synthesize pushView;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if(StatusBar_System>0)
        moment_status=20;
    else moment_status=0;
    
    [self _getPushView:moment_status];
    [self.view addSubview:self.pushView];
    
    nav_View=[[NavView alloc]init];
    
    imageView_Face=[[UIImageView alloc]init];
    imageView_Face=[NavView Show_Nothing_Face];
}

- (void)addNavTItle:(NSString *)navTitle flag:(NSInteger)flag{
    if (flag == 1) {
        [self.view addSubview: [nav_View NavView_Title1:navTitle]];
    }else {
        [self.view addSubview: [nav_View NavView_Title2:navTitle]];
    }
}

//设置推送视图
-(void)_getPushView:(CGFloat)pointy{
    if (pushView == nil) {
        pushView = [[UIView alloc] initWithFrame:CGRectMake(0,pointy , 320, 44)]; //背景
        pushView.backgroundColor = [UIColor colorWithRed:217.0/255.0 green:237.0/255.0  blue:247.0/255.0 alpha:1.0 ];
        pushView.layer.cornerRadius = 5;
        pushView.layer.borderColor = [UIColor colorWithRed:103.0/255.0 green:195.0/255.0  blue:223.0/255.0 alpha:1.0 ].CGColor;
        pushView.layer.borderWidth = 1;
        [self.view addSubview:pushView];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(60, 10, 140, 24)];   //文字
        label.text = @"您有新消息,点击刷新";
        label.font = [UIFont systemFontOfSize:14];
        label.backgroundColor = [UIColor clearColor];
        label.textColor = [UIColor colorWithRed:35.0/255.0 green:102.0/255.0  blue:135.0/255.0 alpha:1.0 ];
        [label setTextAlignment:NSTextAlignmentCenter];
        label.userInteractionEnabled = YES;
        [pushView addSubview:label];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(labelTap)];
        tap.delegate = self;
        [label addGestureRecognizer:tap];   //添加手势
        
        UIImageView *imageView = [[UIImageView alloc] init];    //下划线
        imageView.backgroundColor = [UIColor colorWithRed:35.0/255.0 green:102.0/255.0  blue:135.0/255.0 alpha:1.0 ];
        imageView.frame = CGRectMake(label.left+4, label.bottom-4, label.width-8, 1);
        [pushView addSubview:imageView];
        
        UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom]; //取消按键
        cancelBtn.frame = CGRectMake(290, 15, 14, 14);
        [cancelBtn setImage:[UIImage imageNamed:@"60-x.png"] forState:UIControlStateNormal];
        [cancelBtn addTarget:self action:@selector(cancel) forControlEvents:UIControlEventTouchUpInside];
        [pushView addSubview:cancelBtn];
    }else
        return;
}

-(void)Jpush_mention:(BOOL)isOpen
{
    if(isOpen)
    {
        [UIView animateWithDuration:0.8f animations:^{
            self.pushView.frame = CGRectMake(0,moment_status+44 , 320, 44); 
            [self pushViewOpenOrClose];
        } completion:^(BOOL finished)
         {
             baseTimer = [NSTimer scheduledTimerWithTimeInterval:3
                                                          target:self
                                                        selector:@selector(_timerMethod)
                                                        userInfo:nil
                                                         repeats:NO];
         }];
    }
    else
    {
        [UIView animateWithDuration:0.8f animations:^{
            self.pushView.frame = CGRectMake(0,moment_status, 320, 44);
            [baseTimer invalidate];
            [self pushViewOpenOrClose];
        } completion:nil];
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

- (void)labelTap{
    [self Jpush_mention:NO];
    [self labelTapMethod];
}

- (void)cancel{
    [self Jpush_mention:NO];
}

- (void)_timerMethod{
    [self Jpush_mention:NO];
    [baseTimer invalidate];
}

-(void)setShowPushView:(BOOL )showPushView {
    _showPushView = showPushView;
    
    if (_showPushView) {
        [self.view addSubview:pushView];
    }
    else
    {
        if ([pushView superview]) {
            [pushView removeFromSuperview];
        }
    }
}

- (void)labelTapMethod{
    
}
- (void)pushViewOpenOrClose{
    
}

@end
