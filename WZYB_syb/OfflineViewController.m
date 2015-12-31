//
//  OfflineViewController.m
//  WZYB_syb
//
//  Created by wzyb on 15-4-27.
//  Copyright (c) 2015年 WZYB. All rights reserved.
//

#import "OfflineViewController.h"

@interface OfflineViewController ()
{
    NSString *offLine;
}
@property (weak, nonatomic) IBOutlet UIImageView *offLineImageView;
@property (weak, nonatomic) IBOutlet UIImageView *onLineImageView;
@property (strong, nonatomic) IBOutlet UIView *BigView;

- (IBAction)pressOfflineButton:(id)sender;
- (IBAction)pressOnflineButton:(id)sender;
@end

@implementation OfflineViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //title
    [self.view addSubview: [nav_View NavView_Title1:@"离线模式"]];
    
    UIButton *btn_back=[UIButton buttonWithType:UIButtonTypeCustom];
    btn_back.frame=CGRectMake(0, moment_status, 60, 44);
    btn_back.backgroundColor=[UIColor clearColor];
    btn_back.tag=buttonTag;
    [btn_back addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    [nav_View.view_Nav  addSubview:btn_back];
    [btn_back setBackgroundImage:[UIImage imageNamed:@"btn_color6.png"] forState:UIControlStateHighlighted];
    [btn_back setTitle:@"< 返回" forState:UIControlStateNormal];
    [btn_back setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    btn_back.titleLabel.font=[UIFont systemFontOfSize:15];
    
    //bigView init
    [self.view addSubview:self.BigView];
    self.BigView.top = 64;
    
    //imageView show and unshow
    self.offLineImageView.hidden = YES;
    self.onLineImageView.hidden = NO;
    
    NSUserDefaults *userdefaults = [NSUserDefaults standardUserDefaults];
    offLine = [userdefaults objectForKey:@"OFFLINE"];
    if([offLine isEqualToString:@"1"]){
        self.offLineImageView.hidden = NO;
        self.onLineImageView.hidden = YES;
    }else if ([offLine isEqualToString:@"0"]) {
        self.offLineImageView.hidden = YES;
        self.onLineImageView.hidden = NO;
    }
}

- (void)back {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)pressOfflineButton:(id)sender {
    self.offLineImageView.hidden = NO;
    self.onLineImageView.hidden = YES;
    
    NSUserDefaults *userdefaults = [NSUserDefaults standardUserDefaults];
    [userdefaults setObject:@"1" forKey:@"OFFLINE"];
    [userdefaults synchronize];
}

- (IBAction)pressOnflineButton:(id)sender {
    self.offLineImageView.hidden = YES;
    self.onLineImageView.hidden = NO;
    
    NSUserDefaults *userdefaults = [NSUserDefaults standardUserDefaults];
    [userdefaults setObject:@"0" forKey:@"OFFLINE"];
    [userdefaults synchronize];
}
@end
