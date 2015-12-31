//
//  TypeCustomerViewController.m
//  WZYB_syb
//
//  Created by wzyb on 15-3-5.
//  Copyright (c) 2015年 WZYB. All rights reserved.
//

#import "TypeCustomerViewController.h"
#import "AppDelegate.h"

@interface TypeCustomerViewController ()
{
    AppDelegate *app;
    NSArray *dataArray;
}
- (IBAction)customerAction:(id)sender;

@end

@implementation TypeCustomerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.showPushView = NO;
    [self.view addSubview: [nav_View NavView_Title1:@"终端"]];
    app=(AppDelegate *)[[UIApplication sharedApplication]delegate];
    
    UIButton *btn=[UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame=CGRectMake(0, moment_status, 60, 44);
    [btn setBackgroundImage:[UIImage imageNamed:@"btn_color6.png"] forState:UIControlStateHighlighted];
    [btn setTitle:@"< 返回" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    btn.titleLabel.font=[UIFont systemFontOfSize:15];
    btn.backgroundColor=[UIColor clearColor];
    [btn addTarget:self action:@selector(btn_Action:) forControlEvents:UIControlEventTouchUpInside];
    [nav_View.view_Nav  addSubview:btn];
    
    dataArray = @[@"新客户",@"竞争对手",@"签约客户"];
}

-(void)btn_Action:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)customerAction:(id)sender {
    UIButton *btn=(UIButton *)sender;
    app.customerNumber = btn.tag;
    app.customerStr = [dataArray objectAtIndex:btn.tag];
    [self.navigationController popViewControllerAnimated:YES];
}
@end
