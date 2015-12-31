//
//  ServerViewController.m
//  WZYB_syb
//
//  Created by wzyb on 15-4-10.
//  Copyright (c) 2015年 WZYB. All rights reserved.
//

#import "ServerViewController.h"
#import "AppDelegate.h"

@interface ServerViewController ()
{
    AppDelegate *app;
    NSInteger moment_status;
}
@property (weak, nonatomic) IBOutlet UILabel *baseLabel;
@property (weak, nonatomic) IBOutlet UILabel *portLabel;
@property (weak, nonatomic) IBOutlet UILabel *secondLabel;
@end

@implementation ServerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    app=(AppDelegate*)[UIApplication sharedApplication].delegate;
    if(StatusBar_System>0)
        moment_status=20;
    else moment_status=0;
    
    NavView *nav_View=[[NavView alloc]init];
    [self.view addSubview: [nav_View NavView_Title1:@"服务器信息"]];
    //左边返回键
    UIButton *btn=[UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame=CGRectMake(0, moment_status, 60, 44);
    btn.backgroundColor=[UIColor clearColor];
    btn.tag=buttonTag-1;
    [btn addTarget:self action:@selector(btn_Action:) forControlEvents:UIControlEventTouchUpInside];
    [nav_View.view_Nav  addSubview:btn];
    [btn setTitle:@"< 返回" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    btn.titleLabel.font=[UIFont systemFontOfSize:15];
    
    if ([Function StringIsNotEmpty:self.baseServerStr]) {
        self.baseLabel.text = self.baseServerStr;
    }
    if ([Function StringIsNotEmpty:self.portServerStr]) {
        self.portLabel.text = self.portServerStr;
    }
    if ([Function StringIsNotEmpty:self.secondServerStr]) {
        self.secondLabel.text = self.secondServerStr;
    }
    
    switch (self.redStr.integerValue) {
        case 1:
            self.baseLabel.textColor = [UIColor greenColor];
            break;
        case 2:
            self.portLabel.textColor = [UIColor greenColor];
            break;
        case 3:
            self.secondLabel.textColor = [UIColor greenColor];
            break;
            
        default:
            break;
    }
}

-(void)btn_Action:(UIButton *)btn
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
