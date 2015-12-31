//
//  ShareViewController.m
//  CloudWitNess
//
//  Created by wzyb on 15/7/16.
//  Copyright (c) 2015年 YLYL. All rights reserved.
//

#import "ShareViewController.h"
#import <ShareSDK/ShareSDK.h>

@interface ShareViewController ()<UITextViewDelegate,UITextFieldDelegate>
@property (strong, nonatomic) IBOutlet UITextField *titleLabel;
@property (strong, nonatomic) IBOutlet UITextView *descripTextView;
- (IBAction)pressShareButtonAction:(id)sender;

@end

@implementation ShareViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview: [nav_View NavView_Title1:@"分享"]];
    self.descripTextView.returnKeyType = UIReturnKeyDone;
    
    //左边返回键
    UIButton *btn=[UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame=CGRectMake(0, moment_status, 60, 44);
    btn.backgroundColor=[UIColor clearColor];
    btn.tag=buttonTag-1;
    [btn addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
    [nav_View.view_Nav  addSubview:btn];
    [btn setTitle:@"< 返回" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    btn.titleLabel.font=[UIFont systemFontOfSize:15];
}

- (void)backAction {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)shareInformationWithUrlString:(NSString *)urlString {
    //构建分享内容
    id<ISSContent> publishContent = nil;
    NSString *imagePath = [[NSBundle mainBundle] pathForResource:@"120" ofType:@"png"];
    publishContent = [ShareSDK content:self.descripTextView.text
                        defaultContent:@""
                                 image:[ShareSDK imageWithPath:imagePath]
                                 title:self.titleLabel.text
                                   url:urlString
                           description:@"熵盈宝app"
                             mediaType:SSPublishContentMediaTypeNews];
    
    //创建弹出菜单容器
    id<ISSContainer> container = [ShareSDK container];
    [container setIPadContainerWithView:self.view arrowDirect:UIPopoverArrowDirectionUp];
    
    //弹出分享菜单
    [ShareSDK showShareActionSheet:container
                         shareList:nil
                           content:publishContent
                     statusBarTips:YES
                       authOptions:nil
                      shareOptions:nil
                            result:^(ShareType type, SSResponseState state, id<ISSPlatformShareInfo> statusInfo, id<ICMErrorInfo> error, BOOL end)
     {
         if (state == SSResponseStateSuccess) {
             NSLog(NSLocalizedString(@"TEXT_ShARE_SUC", @"分享成功"));
         }
         else if (state == SSResponseStateFail) {
             NSLog(NSLocalizedString(@"TEXT_ShARE_FAI", @"分享失败,错误码:%d,错误描述:%@"), [error errorCode], [error errorDescription]);
         }
     }];
}

- (IBAction)pressShareButtonAction:(id)sender {
    if (self.titleLabel.text.length && self.descripTextView.text.length) {
        [self shareInformationWithUrlString:self.urlString];
    }else {
        [SGInfoAlert showInfo:@"请将内容填写完整"
                      bgColor:[[UIColor darkGrayColor] CGColor]
                       inView:self.view
                     vertical:0.5];
    }
}

#pragma mark ---- UITextField delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark ---- UITextView delegate
-(BOOL)textViewShouldEndEditing:(UITextView *)textView {
    [textView resignFirstResponder];
    return YES;
}

-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    return YES;
}

#pragma mark ---- NSSet method
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

@end
