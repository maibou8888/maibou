//
//  Logistic_LocationViewController.m
//  WZYB_syb
//
//  Created by wzyb on 14-11-12.
//  Copyright (c) 2014年 WZYB. All rights reserved.
//

#import "Logistic_LocationViewController.h"

@interface Logistic_LocationViewController ()

@end

@implementation Logistic_LocationViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    [self All_Init:self.titleString];
    self.View_Back.frame=CGRectMake(0,moment_status+44 , Phone_Weight, 420);
    [self.view addSubview:self.View_Back];
    self.lab_title.text=self.titleString;
    
    btn_GPS=[UIButton buttonWithType:UIButtonTypeCustom];
    [btn_GPS.layer setMasksToBounds:YES];
    [btn_GPS.layer setCornerRadius:5.0];//设置矩形四个圆角半径
    btn_GPS.frame=CGRectMake((Phone_Weight-303)*0.5, 209, 303, 44);
    btn_GPS.backgroundColor=[UIColor clearColor];
    [btn_GPS addTarget:self action:@selector(Action_Choose:) forControlEvents:UIControlEventTouchUpInside];
    [btn_GPS.layer setMasksToBounds:YES];
    [btn_GPS.layer setCornerRadius:5.0];//设置矩形四个圆角半径
    [btn_GPS setBackgroundImage:nil forState:UIControlStateNormal];
    btn_GPS.titleLabel.font=[UIFont systemFontOfSize:21.0];
    btn_GPS.titleLabel.textColor=[UIColor whiteColor];
    [btn_GPS setBackgroundImage:[UIImage imageNamed:@"btn_color4"] forState:UIControlStateHighlighted];
    [self.View_Back addSubview:btn_GPS];
    self.lab_alat_alng.textAlignment=NSTextAlignmentCenter;
    self.lab_day.textAlignment=NSTextAlignmentCenter;
    self.lab_hour.textAlignment=NSTextAlignmentCenter;
    self.lab_min.textAlignment=NSTextAlignmentCenter;
    [self.progressive  setProgress:0.0f];
    [self.View_Back addSubview:self.progressive];
    if(isIOS7)
    {
        self.prgViewBack.frame=CGRectMake(self.prgViewBack.frame.origin.x,self.prgViewBack.frame.origin.y+5, self.prgViewBack.frame.size.width, 10);
    }
    self.progressive.center=self.prgViewBack.center;
    self.lab_address.adjustsFontSizeToFitWidth=YES;
    
    self.tex_mention.frame=CGRectMake(btn_GPS.frame.origin.x, btn_GPS.center.y+40, 303, 130);
    self.tex_mention.editable=NO;
    [self.tex_mention.layer setMasksToBounds:YES];
    [self.tex_mention.layer setCornerRadius:5.0];//设置矩形四个圆角半径

}
-(void)viewWillAppear:(BOOL)animated
{
    if(app.isLocating==YES)
    {
        [self start];
        [btn_GPS setTitle:@"关闭GPS记录" forState:UIControlStateNormal];
        btn_GPS.backgroundColor=[UIColor redColor];
    }
    else
    {
        [btn_GPS setTitle:@"启动GPS记录" forState:UIControlStateNormal];
        btn_GPS.backgroundColor=self.lab_alat_alng.textColor;
    }
}
-(void)viewWillDisappear:(BOOL)animated
{
    [self stop];
}
- (void)Action_Choose:(id)sender
{
    NSString *msg;
    if(app.isLocating)
    {
        msg=@"即将关闭GPS记录";
       
        
    }
    else
    {
         msg=@"即将启动GPS记录";
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
#pragma AlertViewDelegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex==1)
    {
        if(app.isLocating)
        {
            app.isLocating=NO;
            app.gpsFlag1 = 0;
            [btn_GPS setTitle:@"启动GPS记录" forState:UIControlStateNormal];
            btn_GPS.backgroundColor=self.lab_alat_alng.textColor;
            [app IsExist_LocalLocation_Data];
            [app  Stop_GPS];
            [self stop];
            self.lab_min.text=@"0";
            self.lab_hour.text=@"0";
            self.lab_day.text=@"0";
            self.lab_address.text=@"";
            self.progressive.progress=0.0f;
            self.lab_alat_alng.text=@"000.000000 , 00.000000";
        }
        else
        {
            app.isLocating=YES;
            app.gpsFlag1 = 1;
            [btn_GPS setTitle:@"关闭GPS记录" forState:UIControlStateNormal];
            btn_GPS.backgroundColor=[UIColor redColor];
            app.start_location_time=[Function getSystemTimeNow];
            [app IsExist_LocalLocation_Data];
            [app.locService startUserLocationService];
            if(app.isFirstStart_Infinite_Background)
            {//在应用程序生命周期只开启一次无线后台
                app.isFirstStart_Infinite_Background=NO;
                [app Start_Background_On];
            }
            [self start];
        }
    }
}
- (void)start
{//5second 调用一次
    timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(Update_Lab_timer:) userInfo:nil repeats:YES];
}
- (void)stop
{
    [timer invalidate];
    timer = nil;
}
-(void)Update_Lab_timer:(NSTimer *)time
{
    NSArray *arr_time=[self intervalFromLastDate:app.start_location_time toTheDate:[Function getSystemTimeNow]];
    self.lab_day.text=[arr_time objectAtIndex:0];
    self.lab_hour.text=[arr_time objectAtIndex:1];
    self.lab_min.text=[arr_time objectAtIndex:2];
    
    self.lab_alat_alng.text=app.str_alat_alng;
    if([app.str_printf isEqualToString:@"1"])
    {
        app.str_printf=nil;
        [SGInfoAlert showInfo:@"GPS记录提交成功"
                      bgColor:[[UIColor darkGrayColor] CGColor]
                       inView:self.view
                     vertical:0.5];
    }
    if(self.progressive.progress>=1.0f)
    {
        self.progressive.progress=0.0f;
    }
    else
    {
        self.progressive.progress+=1.0/[[[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"GprsTimer"] integerValue];
    }
}
- (NSArray *)intervalFromLastDate: (NSString *) dateString1 toTheDate:(NSString *) dateString2
{
    NSArray *timeArray1=[dateString1 componentsSeparatedByString:@"."];
    dateString1=[timeArray1 objectAtIndex:0];
    
    NSArray *timeArray2=[dateString2 componentsSeparatedByString:@"."];
    dateString2=[timeArray2 objectAtIndex:0];
   // //Dlog(@"%@.....%@",dateString1,dateString2);
    NSDateFormatter *date=[[NSDateFormatter alloc] init];
    [date setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    NSDate *d1=[date dateFromString:dateString1];
    NSTimeInterval late1=[d1 timeIntervalSince1970]*1;
    
    NSDate *d2=[date dateFromString:dateString2];
    NSTimeInterval late2=[d2 timeIntervalSince1970]*1;
    
    NSTimeInterval cha=late2-late1;
   // NSString *timeString=@"";
    NSString *days=@"";
    NSString *hour=@"";
    NSString *min=@"";
   // NSString *sen=@"";
    
    //sen = [NSString stringWithFormat:@"%d", (int)cha%60];
    // min = [min substringToIndex:min.length-7];
    // 秒
    //sen=[NSString stringWithFormat:@"%@", sen];

    min = [NSString stringWithFormat:@"%d", (int)cha/60%60];
    // min = [min substringToIndex:min.length-7];
    // 分
    min=[NSString stringWithFormat:@"%@", min];
    
    // 小时
    hour= [NSString stringWithFormat:@"%d", (int)cha/3600%24];
    // hour = [hour substringToIndex:house.length-7];
    hour=[NSString stringWithFormat:@"%@", hour];
    
    //天
    days=[NSString stringWithFormat:@"%d", (int)cha/3600/24];
    
   // timeString=[NSString stringWithFormat:@"%@天%@时%@分%@秒",days,hour,min,sen];
    date=nil;
    return [NSArray arrayWithObjects:days, hour,min,nil];
}
-(void)btn_Action:(UIButton *)btn
{
    self.delegate= (id)app.VC_more;
    [self.delegate Notify_MyLogistic];
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
