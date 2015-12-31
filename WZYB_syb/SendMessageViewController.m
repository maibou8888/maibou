//
//  SendMessageViewController.m
//  WZYB_syb
//
//  Created by wzyb on 14-10-9.
//  Copyright (c) 2014年 WZYB. All rights reserved.
//

#import "SendMessageViewController.h"
#import "AppDelegate.h"
@interface SendMessageViewController ()
{
    AppDelegate *app;
    NSString *urlString;
}

@end

@implementation SendMessageViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
-(void)All_Init
{
    app=(AppDelegate*)[UIApplication sharedApplication].delegate;
    if(StatusBar_System>0)
        moment_status=20;
    else moment_status=0;
    NavView *nav_View=[[NavView alloc]init];
    [self.view addSubview: [nav_View NavView_Title1:@"发送应用信息"]];
    for(NSInteger i=0;i<2;i++)
    {
        UIButton *btn=[UIButton buttonWithType:UIButtonTypeCustom];
        btn.backgroundColor=[UIColor clearColor];
        [btn addTarget:self action:@selector(btn_Action:) forControlEvents:UIControlEventTouchUpInside];
        [nav_View.view_Nav  addSubview:btn];
        [btn setBackgroundImage:[UIImage imageNamed:@"btn_color6.png"] forState:UIControlStateHighlighted];
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        btn.titleLabel.font=[UIFont systemFontOfSize:15];
        if(i==0)
        {
            btn.frame=CGRectMake(0, moment_status, 60, 44);
            btn.tag=buttonTag-1;
            [btn setTitle:@"< 返回" forState:UIControlStateNormal];
        }
        else if(i==1)
        {
            btn.frame=CGRectMake(Phone_Weight-44, moment_status, 44, 44);
            btn.tag=buttonTag+2;
            [btn setTitle:@"发送" forState:UIControlStateNormal];
        }
    }
    tex_tel.textAlignment=NSTextAlignmentRight;
    tex_peo.textAlignment=NSTextAlignmentRight;
    tex_content.textAlignment=NSTextAlignmentRight;
    view_back.frame=CGRectMake(0, moment_status+44+53, Phone_Weight, Phone_Height-moment_status-44-53);
    view_back.backgroundColor=[UIColor clearColor];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self All_Init];
    [self Row_Header:[UIColor colorWithRed:24/255.0 green:84/255.0 blue:156/255.0 alpha:1.0] Title:@"发送信息"  Pic:@"0" Background:@"icon_AddNewClerk_FirstTitle.png"];
    isFirstOpen=YES;
    [self Creat_Submit];
}
-(void)viewWillAppear:(BOOL)animated
{
    if(isFirstOpen)
    {
        tex_peo.text=self.str_peo;
        tex_tel.text=self.str_tel;
        isFirstOpen=NO;
    }
    else
    {
        if(![Function isBlankString:app.str_temporary])
            tex_content.text=app.str_temporary;
    }
    
}
-(void)Row_Header:(UIColor *)color Title:(NSString *)title Pic:(NSString *)png Background:(NSString*)name
{
    //信息start
    UIImageView *imgView=[[UIImageView alloc]init];
    imgView.frame=CGRectMake(0,moment_status+44, Phone_Weight, 53);
    imgView.image=[UIImage imageNamed:name];
    [self.view addSubview:imgView];
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
    [self.view addSubview:imgView];
    //end
}
-(void)Creat_Submit
{
    UIButton *btn_submit=[UIButton buttonWithType:UIButtonTypeCustom];
    [btn_submit.layer setMasksToBounds:YES];
    [btn_submit.layer setCornerRadius:5.0];//设置矩形四个圆角半径
    btn_submit.frame=CGRectMake((Phone_Weight-300)/2, btn_content.frame.origin.y+btn_content.frame.size.height+20, 300, 44);
    [btn_submit.layer setMasksToBounds:YES];
    [btn_submit.layer setCornerRadius:5.0];//设置矩形四个圆角半径
    btn_submit.backgroundColor=[UIColor clearColor];
    btn_submit.tag=buttonTag+2;
    [btn_submit setTitle:@"发送" forState:UIControlStateNormal];
    [btn_submit setTitle:@"发送" forState:UIControlStateHighlighted];
    [btn_submit setBackgroundImage:[UIImage imageNamed:@"btn_color6.png"] forState:UIControlStateNormal];
    [btn_submit setBackgroundImage:[UIImage imageNamed:@"btn_color1.png"] forState:UIControlStateHighlighted];
    [btn_submit addTarget:self action:@selector(btn_Action:) forControlEvents:UIControlEventTouchUpInside];
    [view_back addSubview:btn_submit];
}
-(void)btn_Action:(UIButton*)btn
{
    //Dlog(@"%ld",(long)btn.tag);
    if(btn.tag==buttonTag-1)
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
    else if(btn.tag==buttonTag+2)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"发送信息" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定",nil];
        [alert show];
        alert.tag=10;
    }
}
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(alertView.tag==10)
    {
        if(buttonIndex==1)
        {
            //Dlog(@"调用url");
            if([Function isBlankString:tex_content.text])
            {
                [SGInfoAlert showInfo:@"请填写发送信息"
                              bgColor:[[UIColor darkGrayColor] CGColor]
                               inView:self.view
                             vertical:0.7];
            }
            else
            {
                [self Submit_messageUlr];
            }
        }
    }
}
-(void)Submit_messageUlr
{
    if([Function isConnectionAvailable])
    {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.mode = MBProgressHUDModeIndeterminate;
        hud.labelText = @"加载中...";//加载提示语言

        if(app.isPortal)
        {
           urlString =[NSString stringWithFormat:@"%@%@",KPORTAL_URL,KPush_Notice];
        }
        else
        {
            urlString=[NSString stringWithFormat:@"%@%@",kBASEURL,KPush_Notice];
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
        /**/
        [request setPostValue:self.str_mtype forKey:@"mtype"];
        [request setPostValue:tex_content.text forKey:@"content"];
        [request setPostValue:self.str_index_no forKey:@"user_index_no"];
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
//
//            
//        }];
//        
//        [request setFailedBlock :^{
//            [MBProgressHUD hideHUDForView:self.view animated:YES];
//            [SGInfoAlert showInfo:@"哎呀，服务器无响应，一会再试试吧"
//                          bgColor:[[UIColor darkGrayColor] CGColor]
//                           inView:self.view
//                         vertical:0.5];
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
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    SBJsonParser *parser = [[SBJsonParser alloc] init];
    NSDictionary *dict =[parser objectWithString: jsonString];
    if([[dict objectForKey:@"ret"] isEqual:@"0"])
    {
        [SGInfoAlert showInfo:@"消息发送成功"
                      bgColor:[[UIColor darkGrayColor] CGColor]
                       inView:self.view
                     vertical:0.5];
        [self.navigationController popViewControllerAnimated:YES];
    }
    else
    {
        [SGInfoAlert showInfo:[dict objectForKey:@"message"]
                      bgColor:[[UIColor darkGrayColor] CGColor]
                       inView:self.view
                     vertical:0.5];
    }
}
- (IBAction)Action_Content:(id)sender
{
    NoteViewController *noteVC=[[NoteViewController alloc]init];
    noteVC.str_title=@"编辑消息";
    noteVC.str_keybordType=@"1";
    if(![Function isBlankString:tex_content.text])
        noteVC.str_content=tex_content.text;
    [self.navigationController pushViewController:noteVC animated:YES];
    noteVC=nil;
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
                 vertical:0.5];
    //Dlog(@"HTTP 响应码：%d",[request responseStatusCode]);
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
