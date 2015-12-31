//
//  HolidayViewController.m
//  WZYB_syb
//
//  Created by wzyb on 14-11-13.
//  Copyright (c) 2014年 WZYB. All rights reserved.
//

#import "HolidayViewController.h"

@interface HolidayViewController ()<ASIHTTPRequestDelegate>

@end

/*
 （申请休假 工作中）
 （我在休假中,有急事电话联系 开始工作）
 
 */
@implementation HolidayViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    [self All_Init:self.titleString];
    self.View_Back.frame=CGRectMake(0,moment_status+44 , Phone_Weight, 300);
    [self.view addSubview:self.View_Back];
    self.lab_title.text=@"休假";
    self.lab_UpTitle.text=@"我在休假中,有急事电话联系";
    self.lab_DownTitle.text=@"开始工作";
    self.img_Down.image=[UIImage imageNamed:@""];
    self.img_Up.image=[UIImage imageNamed:@""];
    isHoliday=[self Holiday_status];//校验休假状态
    [self Moment_btn_status:isHoliday];
}
-(void)Moment_btn_status:(BOOL)flag
{
    if(flag)
    {
        self.lab_UpTitle.text=@"我在休假中,有急事电话联系";
        self.lab_DownTitle.text=@"开始工作";
        
        self.img_Up.image=[UIImage imageNamed:@"ic_loaded_greg.png"];
        self.img_Down.image=[UIImage imageNamed:@""];
        
        self.btn_up.enabled=NO;
        self.btn_down.enabled=YES;

    }
    else
    {
        self.lab_UpTitle.text=@"申请休假";
        self.lab_DownTitle.text=@"工作中";
        
        self.img_Up.image=[UIImage imageNamed:@""];
        self.img_Down.image=[UIImage imageNamed:@"ic_loaded_greg.png"];
        
        self.btn_up.enabled=YES;
        self.btn_down.enabled=NO;
    }
}
- (IBAction)Action_Choose:(id)sender
{
    UIButton *btn=(UIButton *)sender;
    NSString *msg ;
    if(btn.tag==11)
    {
        msg=@"请求结束休假";
        
    }
    else
    {
        msg=@"请求开始休假";
    }
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                    message:msg
                                                   delegate:self
                                          cancelButtonTitle:@"取消"
                                          otherButtonTitles:@"确定", nil];
    alert.tag=11;
    [alert show];
    alert=nil;
}
-(BOOL)Holiday_status//校验休假状态
{
    if([[[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"holiday"] isEqualToString:@"1"])
    {
        return YES;
    }
    return NO;
}
-(NSString *)SettingURL_To_Holiday:(NSString *)url
{
    NSString *string;
    if(isHoliday)
    {//结束休假
        string=[NSString stringWithFormat:@"%@%@",url,Kend_holiday];
    }
    else
    {//申请休假
        string=[NSString stringWithFormat:@"%@%@",url,Kapply_holiday];
    }
    return string;
}
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    //Dlog(@"%ld",(long)buttonIndex);
    if(alertView.tag==11)//休假
    {
        if(buttonIndex==1)
        {
            [self To_Holiday];
        }
        else
        {
            //Dlog(@"取消");
        }
    }
}
-(void)To_Holiday//休假
{
    if([Function isConnectionAvailable])
    {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.mode = MBProgressHUDModeIndeterminate;
        hud.labelText = @"加载中...";//加载提示语言
        if(app.isPortal)
        {
            self.urlString=[self SettingURL_To_Holiday:KPORTAL_URL];
        }
        else
        {
            self.urlString=[self SettingURL_To_Holiday:kBASEURL];
        }
        NSURL *url = [ NSURL URLWithString :  self.urlString];
        ASIFormDataRequest *request = [ ASIFormDataRequest requestWithURL :url];
        request.delegate = self;
        [request setRequestMethod:@"POST"];
        
        [request setPostValue:[[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"account"]forKey:KUSER_UID];
        [request setPostValue:[[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"secret"] forKey:KUSER_PASSWORD];
        [request setPostValue:[[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"token"] forKey:@"user.token"];
        [request setPostValue:[[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"db_ip"] forKey:@"db_ip"];
        [request setPostValue:[[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"db_name"] forKey:@"db_name"];
        
//        [request setCompletionBlock :^{
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
//                [NdUncaughtExceptionHandler Post_url:[NSString stringWithFormat:@"URL:%@,HTTP_Code%d",self.urlString,[request responseStatusCode]]];
//            }
//        }];
//        [request setFailedBlock :^{
//            [MBProgressHUD hideHUDForView:self.view animated:YES];
//            [SGInfoAlert showInfo:@"哎呀，服务器无响应，一会再试试吧"
//                          bgColor:[[UIColor darkGrayColor] CGColor]
//                           inView:self.view
//                         vertical:0.5];
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
                     vertical:0.5];
    }
}
-(void)get_JsonString:(NSString *)jsonString
{
    SBJsonParser *pause = [[SBJsonParser alloc] init];
    NSDictionary *dict =[pause objectWithString: jsonString];
    NSString *msg;
    if([dict objectForKey:@"ret"])
    {
        isHoliday=!isHoliday;
        [self Moment_btn_status:isHoliday];
        if(isHoliday)
        {
            msg=@"请求休假成功,开始休假";
            [[SelfInf_Singleton sharedInstance].dic_SelfInform setObject:@"1" forKey:@"holiday"];
        }
        else
        {
            msg=@"请求结束休假成功,已结束休假";
            [[SelfInf_Singleton sharedInstance].dic_SelfInform setObject:@"0" forKey:@"holiday"];
        }
    }
    else
    {
        if(isHoliday)
        {
            msg=@"请求休假失败,请重试";
        }
        else
        {
            msg=@"请求结束休假失败,请重试";
        }
    }
    [SGInfoAlert showInfo:msg
                  bgColor:[[UIColor darkGrayColor] CGColor]
                   inView:self.view
                 vertical:0.5];
}

-(void)btn_Action:(UIButton *)btn {
    [self.navigationController popViewControllerAnimated:YES];
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
    // 请求响应失败，返回错误信息
    //Dlog(@"HTTP 响应码：%d",[request responseStatusCode]);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
