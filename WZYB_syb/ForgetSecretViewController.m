//
//  ForgetSecretViewController.m
//  WZYB_syb
//
//  Created by wzyb on 14-8-15.
//  Copyright (c) 2014年 WZYB. All rights reserved.
//

#import "ForgetSecretViewController.h"
#import "AppDelegate.h"
@interface ForgetSecretViewController ()<ASIHTTPRequestDelegate>
{
    AppDelegate *app;
}
@end

@implementation ForgetSecretViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self All_Init];
    [self creat_View1];
}
-(void)All_Init
{
    app=(AppDelegate*)[UIApplication sharedApplication].delegate;
    if(StatusBar_System>0)
        moment_status=20;
    else moment_status=0;
    near_by_thisView=Near_By;
    NavView *nav_View=[[NavView alloc]init];
    [self.view addSubview: [nav_View NavView_Title1:@"忘记密码"]];
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
}
-(void)creat_View1
{
    [self.view addSubview:view_background];
    view_background.center=CGPointMake(Phone_Weight*0.5, view_background.frame.size.height*0.5+44+moment_status);
    UIButton *btn_submit=[UIButton buttonWithType:UIButtonTypeCustom];
    [btn_submit.layer setMasksToBounds:YES];
    [btn_submit.layer setCornerRadius:5.0];//设置矩形四个圆角半径
    btn_submit.frame=CGRectMake((Phone_Weight-300)/2, 120, 300, 44);
    [btn_submit.layer setMasksToBounds:YES];
    [btn_submit.layer setCornerRadius:5.0];//设置矩形四个圆角半径
    btn_submit.backgroundColor=[UIColor clearColor];
    btn_submit.tag=buttonTag;
    [btn_submit setTitle:@"提交" forState:UIControlStateNormal];
    [btn_submit setTitle:@"提交" forState:UIControlStateHighlighted];
    [btn_submit setBackgroundImage:[UIImage imageNamed:@"btn_color6.png"] forState:UIControlStateNormal];
    [btn_submit setBackgroundImage:[UIImage imageNamed:@"btn_color1.png"] forState:UIControlStateHighlighted];
    [btn_submit addTarget:self action:@selector(btn_Action:) forControlEvents:UIControlEventTouchUpInside];
    [view_background addSubview:btn_submit];
}

-(void)btn_Action:(UIButton *)btn
{
    if(btn.tag==buttonTag-1)
    {//返回
        //Dlog(@"返回");
        [self dismissModalViewControllerAnimated:YES];
    }
    else if(btn.tag==buttonTag)
    {//提交
        //Dlog(@"提交");
        [text_oldSecret resignFirstResponder];
        if([self Verify_tel])
        {
            [self Forget_Secret];
        }
        else
        {
            
        }
    }
}
#pragma mark -UITextView Delegate Method
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    textField.returnKeyType=UIReturnKeyDone;
    return YES;
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}
-(BOOL)Verify_tel//校验手机号
{
    if([Function isBlankString:text_oldSecret.text]||[text_oldSecret.text isEqualToString:@""])
    {
        [SGInfoAlert showInfo:@"手机号不能为空"
                      bgColor:[[UIColor darkGrayColor] CGColor]
                       inView:self.view
                     vertical:0.5];
        return NO;
    }
    if(text_oldSecret.text.length!=11)
    {
        [SGInfoAlert showInfo:@"手机号不是一个11位数"
                      bgColor:[[UIColor darkGrayColor] CGColor]
                       inView:self.view
                     vertical:0.5];
        return NO;
    }
    if([text_oldSecret.text characterAtIndex:0] !='1' )
    {
        //Dlog(@"%c",[text_oldSecret.text characterAtIndex:0]);
        [SGInfoAlert showInfo:@"手机号应该以1开头"
                      bgColor:[[UIColor darkGrayColor] CGColor]
                       inView:self.view
                     vertical:0.5];
        return NO;
    }
    return YES;
}

//忘记密码
-(void)Forget_Secret
{
    if([Function isConnectionAvailable])
    {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.mode = MBProgressHUDModeIndeterminate;
        hud.labelText = @"加载中...";//加载提示语言
        if(app.isPortal)
        {
            self.urlString=[NSString stringWithFormat:@"%@%@",KPORTAL_URL,Kforget_password];
        }
        else
        {
            self.urlString=[NSString stringWithFormat:@"%@%@",kBASEURL,Kforget_password];
        }

        NSURL *url = [ NSURL URLWithString :  self.urlString];
        ASIFormDataRequest *request = [ ASIFormDataRequest requestWithURL :url];
        request.delegate = self;
        
        [request setRequestMethod:@"POST"];
        [request setPostValue:text_oldSecret.text forKey:KUSER_UID];
        [request startAsynchronous ];//异步
    }
    else
    {
        [SGInfoAlert showInfo:@"当前网络不可用，请检查网络连接"
                      bgColor:[[UIColor darkGrayColor] CGColor]
                       inView:self.view
                     vertical:0.7];
    }
}
-(void)get_JsonString:(NSString *)jsonString
{
    SBJsonParser *pause = [[SBJsonParser alloc] init];
    NSDictionary *dict =[pause objectWithString: jsonString];
    NSString *msg;
    if([[dict objectForKey:@"ret"] isEqualToString:@"0"])
    {
        msg=[dict objectForKey:@"message"];
        if([Function isBlankString:msg])
        {
            msg=@"密码找回成功";
        }
    }
    else
    {
        msg=[dict objectForKey:@"message"];
        if([Function isBlankString:msg])
        {
            msg=@"找回密码请求提交失败,请重试";
        }
    }
    [SGInfoAlert showInfo:msg
                  bgColor:[[UIColor darkGrayColor] CGColor]
                   inView:self.view
                 vertical:0.5];
}

-(void)requestFinished:(ASIHTTPRequest *)request {
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    if([request responseStatusCode]==200)
    {
        NSString * jsonString  =  [request responseString];
        [self get_JsonString:jsonString];
    }
    else
    {
        [SGInfoAlert showInfo:@"发生异常,请稍后再试"
                      bgColor:[[UIColor darkGrayColor] CGColor]
                       inView:self.view
                     vertical:0.5];
        [NdUncaughtExceptionHandler Post_url:[NSString stringWithFormat:@"URL:%@,HTTP_Code%d",self.urlString,[request responseStatusCode]]];
    }
}

-(void)requestFailed:(ASIHTTPRequest *)request {
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    [SGInfoAlert showInfo:@"哎呀，服务器无响应，一会再试试吧"
                  bgColor:[[UIColor darkGrayColor] CGColor]
                   inView:self.view
                 vertical:0.5];
    //Dlog(@"HTTP 响应码：%d",[request responseStatusCode]);
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
