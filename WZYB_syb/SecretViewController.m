//
//  SecretViewController.m
//  WZYB_syb
//
//  Created by wzyb on 14-8-15.
//  Copyright (c) 2014年 WZYB. All rights reserved.
//

#import "SecretViewController.h"
#import "NoteViewController.h"
#import "AppDelegate.h"
@interface SecretViewController ()
{
    AppDelegate *app;
    NSString *urlString;
}
@end

@implementation SecretViewController

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
    [self All_init];
    [self creat_View];
}
-(void)viewWillAppear:(BOOL)animated
{
    if(index_row==1)
    {
        tex_Old.text=app.str_temporary;
    }
    else if(index_row==2)
    {
        tex_New.text=app.str_temporary;
    }
    else if(index_row==3)
    {
        tex_Review.text=app.str_temporary;
    }
    index_row=0;
}
-(void)All_init
{
    app=(AppDelegate *)[[UIApplication sharedApplication]delegate];
    if(StatusBar_System>0)
        moment_status=20;
    else moment_status=0;
    near_by_thisView=Near_By;
    NavView *nav_View=[[NavView alloc]init];
    [self.view addSubview: [nav_View NavView_Title1:@"修改密码"]];
    //左边返回键
    for (NSInteger i=0; i<2; i++)
    {
        UIButton *btn=[UIButton buttonWithType:UIButtonTypeCustom];
        btn.backgroundColor=[UIColor clearColor];
        [btn addTarget:self action:@selector(btn_Action:) forControlEvents:UIControlEventTouchUpInside];
        [nav_View.view_Nav  addSubview:btn];
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        btn.titleLabel.font=[UIFont systemFontOfSize:15];
        [btn setBackgroundImage:[UIImage imageNamed:@"btn_color6.png"] forState:UIControlStateHighlighted];
        if(i==0)
        {
            btn.frame=CGRectMake(0, moment_status, 60, 44);
            btn.tag=buttonTag-1;
            [btn setTitle:@"< 返回" forState:UIControlStateNormal];
        }
        else if(i==1)
        {
            btn.frame=CGRectMake(Phone_Weight-44, moment_status, 44, 44);
            btn.tag=buttonTag;
            [btn setTitle:@"提交" forState:UIControlStateNormal];
        }
    }
}
-(void)creat_View
{
    if(isIOS7)
    {
        view_background.frame= CGRectMake(0, 44+moment_status, Phone_Weight,Phone_Height-44-moment_status);
    }
    else
    {
       view_background.frame= CGRectMake(0, 44+moment_status, Phone_Weight,505);
    }
    view_background.backgroundColor=[UIColor clearColor];
    [self.view addSubview:view_background];
   [self Row_Header:[UIColor colorWithRed:223/255.0 green:52/255.0 blue:46/255.0 alpha:1.0] Title:@"密码重置" Pic:@"9" Background:@"icon_AddNewClerk_FirstTitle.png"];
    UIButton *btn_submit=[UIButton buttonWithType:UIButtonTypeCustom];
    btn_submit.frame=CGRectMake((Phone_Weight-300)/2, 197, 300, 44);
    [self Button_Describ_Btn:btn_submit  Title:@"提交" Tag:buttonTag Normal:@"btn_color6.png" Highligt:@"btn_color1.png"];
}
-(void)Row_Header:(UIColor *)color Title:(NSString *)title Pic:(NSString *)png Background:(NSString*)name
{
    //信息start
    UIImageView *imgView=[[UIImageView alloc]init];
    imgView.frame=CGRectMake(0,0, Phone_Weight, 53);
    imgView.image=[UIImage imageNamed:name];
    [view_background addSubview:imgView];
    UILabel *lab=[[UILabel alloc]init];
    lab.frame=CGRectMake(54, 8, 100, 38);
    lab.backgroundColor=[UIColor clearColor];
    lab.textColor=color;
    lab.text=title;
    lab.font=[UIFont systemFontOfSize:19.0];
    [imgView addSubview:lab];
    UIImageView *imgView_icon1=[[UIImageView alloc]init];
    imgView_icon1.frame=CGRectMake(14, 10, 32, 32);
    imgView_icon1.backgroundColor=[UIColor clearColor];
    imgView_icon1.image=[UIImage imageNamed:[NSString stringWithFormat:@"iconic_%@.png",png]];
    [imgView addSubview:imgView_icon1];
    [view_background addSubview:imgView];
    //end
}
-(void)Button_Describ_Btn:(UIButton *)btn Title:(NSString*)title Tag:(NSInteger)tag Normal:(NSString *)pic1 Highligt:(NSString *)pic2
{
    [btn.layer setMasksToBounds:YES];
    [btn.layer setCornerRadius:5.0];//设置矩形四个圆角半径
    [btn setTitle:title forState:UIControlStateNormal];
    [btn setTitle:title forState:UIControlStateHighlighted ];
    
    btn.titleLabel.textColor=[UIColor whiteColor];
    btn.titleLabel.font=[UIFont systemFontOfSize:15];
    btn.backgroundColor=[UIColor clearColor];
    btn.tag=tag;
    [btn setBackgroundImage:[UIImage imageNamed:pic1] forState:UIControlStateNormal];
    [btn setBackgroundImage:[UIImage imageNamed:pic2] forState:UIControlStateHighlighted];
    [btn addTarget:self action:@selector(btn_Action:) forControlEvents:UIControlEventTouchUpInside];
    [view_background addSubview:btn];
    
}
-(void)btn_Action:(id)sender
{
    UIButton *btn=(UIButton *)sender;
    if(btn.tag==buttonTag-1)//返回
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
    else if(btn.tag==buttonTag)
    {//提交
        //Dlog(@"提交");
        for (id obj in self.view.subviews) {
            if ([obj isKindOfClass:[UITextField class]] ) {
                [obj resignFirstResponder];
            }
        }
        [self Verify_secret];
    }
        
}

-(void)Verify_secret//校验新密码书写
{
    if([Function isBlankString:tex_Old.text])
    {
        [SGInfoAlert showInfo:@"请先输入原始密码"
                      bgColor:[[UIColor darkGrayColor] CGColor]
                       inView:self.view
                     vertical:0.7];
    }
    else if([tex_New.text isEqualToString:tex_Review.text]&&![Function isBlankString:tex_New.text])
    {//新密码输入正确 且不为空
        [self ToChange_Secret];
    }
    else
    {
        [SGInfoAlert showInfo:@"校验与新密码不一致,请重新设置"
                      bgColor:[[UIColor darkGrayColor] CGColor]
                       inView:self.view
                     vertical:0.7];
    }
}
-(void)ToChange_Secret//修改密码
{
    if([Function isConnectionAvailable])
    {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.mode = MBProgressHUDModeIndeterminate;
        hud.labelText = @"加载中...";//加载提示语言

        if(app.isPortal)
        {
            urlString=[NSString stringWithFormat:@"%@%@",KPORTAL_URL,Knew_password];
        }
        else
        {
            urlString=[NSString stringWithFormat:@"%@%@",kBASEURL,Knew_password];
        }
        NSURL *url = [ NSURL URLWithString :  urlString];
        ASIFormDataRequest *request = [ ASIFormDataRequest requestWithURL :url];
        request.delegate = self;
        [request setRequestMethod:@"POST"];
        
        [request setPostValue:[[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"account"]forKey:KUSER_UID];
        [request setPostValue:[[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"secret"] forKey:KUSER_PASSWORD];
        [request setPostValue:[[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"token"] forKey:@"user.token"];
        [request setPostValue:[[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"db_ip"] forKey:@"db_ip"];
        [request setPostValue:[[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"db_name"] forKey:@"db_name"];
        [request setPostValue:tex_Old.text forKey:@"password"];
        [request setPostValue:tex_New.text forKey:@"password_new"];
        
//        [request setCompletionBlock :^{
//            
//            [MBProgressHUD hideHUDForView:self.view animated:YES];
//            if([request responseStatusCode]==200)
//            {
//                NSString * jsonString  =  [request responseString];
//                [self get_JsonString:jsonString];
//            }
//            else
//            {
//                [SGInfoAlert showInfo:@"发生异常,请稍后再试"
//                              bgColor:[[UIColor darkGrayColor] CGColor]
//                               inView:self.view
//                             vertical:0.5];
//                [NdUncaughtExceptionHandler Post_url:[NSString stringWithFormat:@"URL:%@,HTTP_Code%d",urlString,[request responseStatusCode]]];
//            }
//        }];
//        [request setFailedBlock :^{
//            [MBProgressHUD hideHUDForView:self.view animated:YES];
//            [SGInfoAlert showInfo:@"哎呀，服务器无响应，一会再试试吧"
//                          bgColor:[[UIColor darkGrayColor] CGColor]
//                           inView:self.view
//                         vertical:0.7];
//            // 请求响应失败，返回错误信息
//            //Dlog(@"HTTP 响应码：%d",[request responseStatusCode]);
//        }];
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
        msg=@"密码修改成功";
        NSDictionary *dic=[dict objectForKey:@"SelfInfo"];
        [[SelfInf_Singleton sharedInstance].dic_SelfInform setObject:[dic objectForKey:@"token"] forKey:@"token"];
        [[SelfInf_Singleton sharedInstance].dic_SelfInform setObject:[dic objectForKey:@"password"] forKey:@"secret"];
        [self ReWirte_ToFile];
    }
    else
    {
        msg=[dict objectForKey:@"message"];
    }
    [SGInfoAlert showInfo:msg
                  bgColor:[[UIColor darkGrayColor] CGColor]
                   inView:self.view
                 vertical:0.7];
}
-(void)ReWirte_ToFile
{
    [Function DeleteTheFile:[NSString stringWithFormat:@"%@/%@",MyFolder,login] Kind:Library_Cache];
    [Function creatTheFile:login Kind:Library_Cache];
    [Function WriteToFile:login File:[SelfInf_Singleton sharedInstance].dic_SelfInform Kind:Library_Cache];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)Action_EditTextField:(id)sender
{
    UIButton *btn=(UIButton *)sender;
    NoteViewController *noteVC=[[NoteViewController alloc]init];
    noteVC.isDetail=NO;
    noteVC.keyboardFlag = 1;
    index_row=btn.tag;
    if(btn.tag==1)
    {
        noteVC.str_title=@"原始密码";
        noteVC.str_content=tex_Old.text;
    }
    else if(btn.tag==2)
    {
        noteVC.str_title=@"新密码";
        noteVC.str_content=tex_New.text;
    }
    else if(btn.tag==3)
    {
        noteVC.str_title=@"原始密码";
        noteVC.str_content=tex_Review.text;
    }
    [self.navigationController pushViewController:noteVC animated:YES];
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
        [NdUncaughtExceptionHandler Post_url:[NSString stringWithFormat:@"URL:%@,HTTP_Code%d",urlString,[request responseStatusCode]]];
    }
}

-(void)requestFailed:(ASIHTTPRequest *)request {
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    [SGInfoAlert showInfo:@"哎呀，服务器无响应，一会再试试吧"
                  bgColor:[[UIColor darkGrayColor] CGColor]
                   inView:self.view
                 vertical:0.7];
    // 请求响应失败，返回错误信息
    //Dlog(@"HTTP 响应码：%d",[request responseStatusCode]);
}
@end
