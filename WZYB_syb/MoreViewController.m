//
//  MoreViewController.m
//  WZYB_syb
//
//  Created by wzyb on 14-8-18.
//  Copyright (c) 2014年 WZYB. All rights reserved.
//

#import "MoreViewController.h"
#import "RegisterViewController.h"
#import "TasksAssignedViewController.h"
#import "AssessmentViewController.h"
#import "AdviceViewController.h"
#import "SecretViewController.h"
#import "Select_StorageViewController.h"
#import "Logistic_LocationViewController.h"
#import "HolidayViewController.h"
#import "AppDelegate.h"
@interface MoreViewController ()<MyDelegate_msgVC,MyDelegate_Advice,MyDelegate_Task,MyDelegate_Ass,MyDelegate_Logistic>
{
    AppDelegate *app;
}
@end

@implementation MoreViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
#pragma MyDelegate
-(void)Notify_MoreVC
{
    [self Show_Dialog];
}
-(void)Notify_Advice:(NSString *)msg;
{
    [SGInfoAlert showInfo:msg
                  bgColor:[[UIColor darkGrayColor] CGColor]
                   inView:self.view
                 vertical:0.5];
}
-(void)Notify_Task
{
    [self Show_Dialog];
}
-(void)Notify_Ass
{
    [self Show_Dialog];
}
-(void)Notify_MyLogistic
{
    [self Update_LocatingStatus];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self All_Init];
    
}
-(void)viewWillAppear:(BOOL)animated
{
    [self creat_ScrollView];
    [self Show_Dialog];
    if([[[TileAuthority sharedInstance].dic_TileAuthority objectForKey:@"gps"]isEqualToString:@"1"])
    {
        [self Update_LocatingStatus];
    }
}
-(void)Update_LocatingStatus
{
    if([str_auth isEqualToString:@"1"])
    {
        if(app.isLocating)
        {
            [btn_gps setBackgroundImage:[UIImage imageNamed:@"ic_gps_ing.png"] forState:UIControlStateNormal];
        }
        else
        {
            [btn_gps setBackgroundImage:[UIImage imageNamed:@"more_btn_gps.png"] forState:UIControlStateNormal];
        }
        
    }
    else if([str_auth isEqualToString:@"2"])
    {
        if(app.isLocating)
        {
            [btn2_gps setBackgroundImage:[UIImage imageNamed:@"ic_gps_ing.png"] forState:UIControlStateNormal];
        }
        else
        {
            [btn2_gps setBackgroundImage:[UIImage imageNamed:@"more_btn_gps.png"] forState:UIControlStateNormal];
        }
    }
    else if ([str_auth isEqualToString:@"3"])
    {//废弃了 不用了
        
    }
    else if([str_auth isEqualToString:@"4"])
    {
        if(app.isLocating)
        {
            [btn4_gps setBackgroundImage:[UIImage imageNamed:@"ic_gps_ing.png"] forState:UIControlStateNormal];
        }
        else
        {
            [btn4_gps setBackgroundImage:[UIImage imageNamed:@"more_btn_gps.png"] forState:UIControlStateNormal];
        }
    }
}
-(void)Show_Dialog
{
    if(app.New_Ass||app.New_Task||app.New_msg)
    {
        self.tabBarItem.badgeValue=@"";
    }
    else
    {
        self.tabBarItem.badgeValue=nil;
    }
    if([str_auth isEqualToString:@"1"])
    {
        if(app.New_msg)
        {
            self.img_mention_1_1.hidden=NO;
        }
        else
        {
            self.img_mention_1_1.hidden=YES;
        }
        if(app.New_Ass)
        {
            self.img_mention_1_3.hidden=NO;
        }
        else
        {
            self.img_mention_1_3.hidden=YES;
        }
        if(app.New_Task)
        {
            self.img_mention_1_2.hidden=NO;
        }
        else
        {
            self.img_mention_1_2.hidden=YES;
        }
    }
    else if([str_auth isEqualToString:@"2"])
    {
        if(app.New_msg)
        {
            self.img_mention_2_1.hidden=NO;
        }
        else
        {
            self.img_mention_2_1.hidden=YES;
        }
        if(app.New_Ass)
        {
            self.img_mention_2_3.hidden=NO;
        }
        else
        {
            self.img_mention_2_3.hidden=YES;
        }
        if(app.New_Task)
        {
            self.img_mention_2_2.hidden=NO;
        }
        else
        {
            self.img_mention_2_2.hidden=YES;
        }
    }
    else if ([str_auth isEqualToString:@"3"])
    {//废弃了 不用了
        
    }
    else if([str_auth isEqualToString:@"4"])
    {
        if(app.New_msg)
        {
            self.img_mention_4_1.hidden=NO;
        }
        else
        {
            self.img_mention_4_1.hidden=YES;
        }
        if(app.New_Ass)
        {
            self.img_mention_4_3.hidden=NO;
        }
        else
        {
            self.img_mention_4_3.hidden=YES;
        }
        if(app.New_Task)
        {
            self.img_mention_4_2.hidden=NO;
        }
        else
        {
            self.img_mention_4_2.hidden=YES;
        }
    }
    
}
-(void)All_Init
{
    app=(AppDelegate*)[[UIApplication sharedApplication]delegate];
    if(StatusBar_System>0)
        moment_status=20;
    else moment_status=0;
    NavView *nav_View=[[NavView alloc]init];
    [self.view addSubview: [nav_View NavView_Title1:[[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"coname"] ]];
    str_auth=[[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"auth"];//用户权限级别
}                              
-(void)creat_ScrollView
{
    if([str_auth isEqualToString:@"1"])
    {
        self.scroll1.frame=CGRectMake(0,moment_status+44, Phone_Weight, Phone_Height-moment_status-44-TabbarHeight);
        self.scroll1.contentSize=CGSizeMake(0, 550);
        [self.view addSubview:self.scroll1];

        [self button_status:@"1"];
        
    }
    else if([str_auth isEqualToString:@"2"])
    {
        self.scroll2.frame=CGRectMake(0,moment_status+44, Phone_Weight, Phone_Height-moment_status-44-TabbarHeight);
        self.scroll2.contentSize=CGSizeMake(0, 550);
        [self.view addSubview:self.scroll2];
        [self button_status:@"2"];
    }
    else if ([str_auth isEqualToString:@"3"])
    {//废弃了 不用了
        self.scroll3.frame=CGRectMake(0,moment_status+44, Phone_Weight, Phone_Height-moment_status-44-TabbarHeight);
        self.scroll3.contentSize=CGSizeMake(0, 550);
        [self.view addSubview:self.scroll3];
    }
    else if([str_auth isEqualToString:@"4"])
    {
        self.scroll4.frame=CGRectMake(0,moment_status+44, Phone_Weight, Phone_Height-moment_status-44-TabbarHeight);
        self.scroll4.contentSize=CGSizeMake(0, 700);
        [self.view addSubview:self.scroll4];
        [self button_status:@"4"];
    }
}
-(void)button_status:(NSString *)str
{
    if([str isEqualToString:@"4"])
    {
        if( ![[[TileAuthority sharedInstance].dic_TileAuthority objectForKey:@"customer"]isEqualToString:@"1"])
        {
            [btn4_addClerk setBackgroundImage:[UIImage imageNamed:@"more_btn_gray_clerk.png"] forState:UIControlStateNormal];
            btn4_addClerk.userInteractionEnabled=NO;
        }
        if( ![[[TileAuthority sharedInstance].dic_TileAuthority objectForKey:@"competitor"]isEqualToString:@"1"])
        {
            [btn4_rival setBackgroundImage:[UIImage imageNamed:@"more_btn_gray_rival.png"] forState:UIControlStateNormal];
            btn4_rival.userInteractionEnabled=NO;
        }
        if(! [[[TileAuthority sharedInstance].dic_TileAuthority objectForKey:@"access"]isEqualToString:@"1"])
        {
            [btn4_vist setBackgroundImage:[UIImage imageNamed:@"more_btn_gray_visit2.png"] forState:UIControlStateNormal];
            btn4_vist.userInteractionEnabled=NO;
            [btn4_routeBack setBackgroundImage:[UIImage imageNamed:@"more_btn_gray_routsBack.png"] forState:UIControlStateNormal];
            btn4_routeBack.userInteractionEnabled=NO;
        }
        if( ![[[TileAuthority sharedInstance].dic_TileAuthority objectForKey:@"order"]isEqualToString:@"1"])
        {
            [btn4_myOrder setBackgroundImage:[UIImage imageNamed:@"more_btn_gray_order2.png"] forState:UIControlStateNormal];
            btn4_myOrder.userInteractionEnabled=NO;
        }
        if( ![[[TileAuthority sharedInstance].dic_TileAuthority objectForKey:@"task"]isEqualToString:@"1"])
        {
            [btn4_myTask setBackgroundImage:[UIImage imageNamed:@"more_btn_gray_task2.png"] forState:UIControlStateNormal];
            btn4_myTask.userInteractionEnabled=NO;
            [btn4_ask setBackgroundImage:[UIImage imageNamed:@"more_btn_gray_ask1.png"] forState:UIControlStateNormal];
            btn4_ask.userInteractionEnabled=NO;
        }
        if( ![[[TileAuthority sharedInstance].dic_TileAuthority objectForKey:@"apply"]isEqualToString:@"1"])
        {
            [btn4_myApply setBackgroundImage:[UIImage imageNamed:@"more_btn_gray_apply.png"] forState:UIControlStateNormal];
            btn4_myApply.userInteractionEnabled=NO;
            [btn4_myApproval setBackgroundImage:[UIImage imageNamed:@"more_btn_gray_approval.png"] forState:UIControlStateNormal];
            btn4_myApproval.userInteractionEnabled=NO;
        }
        if(! [[[TileAuthority sharedInstance].dic_TileAuthority objectForKey:@"checkin"]isEqualToString:@"1"])
        {
            [btn4_check setBackgroundImage:[UIImage imageNamed:@"more_btn_gray_check.png"] forState:UIControlStateNormal];
            btn4_check.userInteractionEnabled=NO;
        }
        if(! [[[TileAuthority sharedInstance].dic_TileAuthority objectForKey:@"analysis"]isEqualToString:@"1"])
        {
            [btn4_dataAnalyse setBackgroundImage:[UIImage imageNamed:@"more_btn_gray_data.png"] forState:UIControlStateNormal];
            btn4_dataAnalyse.userInteractionEnabled=NO;
            
        }
        if( ![[[TileAuthority sharedInstance].dic_TileAuthority objectForKey:@"document"]isEqualToString:@"1"])
        {
            [btn4_Document setBackgroundImage:[UIImage imageNamed:@"more_btn_gray_doc4.png"] forState:UIControlStateNormal];
            btn4_Document.userInteractionEnabled=NO;
        }
        if( ![[[TileAuthority sharedInstance].dic_TileAuthority objectForKey:@"gps"]isEqualToString:@"1"])
        {
            [btn4_gps setBackgroundImage:[UIImage imageNamed:@"more_btn_gray_gps.png"] forState:UIControlStateNormal];
            btn4_gps.userInteractionEnabled=NO;
        }
        if(![[[TileAuthority  sharedInstance].dic_TileAuthority objectForKey:@"stock"] isEqualToString:@"1"])
        {
            [btn4_storage setBackgroundImage:[UIImage imageNamed:@"more_btn_gray_sorage.png"] forState:UIControlStateNormal];
            btn4_storage.userInteractionEnabled=NO;
        }
        
    }
    else if([str isEqualToString:@"2"])
    {
        if( ![[[TileAuthority sharedInstance].dic_TileAuthority objectForKey:@"customer"]isEqualToString:@"1"])
        {
            [btn2_addClerk setBackgroundImage:[UIImage imageNamed:@"more_btn_gray_clerk.png"] forState:UIControlStateNormal];
            btn2_addClerk.userInteractionEnabled=NO;
        }
        if(! [[[TileAuthority sharedInstance].dic_TileAuthority objectForKey:@"competitor"]isEqualToString:@"1"])
        {
            [btn2_rival setBackgroundImage:[UIImage imageNamed:@"more_btn_gray_rival.png"] forState:UIControlStateNormal];
            btn2_rival.userInteractionEnabled=NO;
        }
        if( ![[[TileAuthority sharedInstance].dic_TileAuthority objectForKey:@"access"]isEqualToString:@"1"])
        {
            [btn2_vist setBackgroundImage:[UIImage imageNamed:@"more_btn_gray_visit2.png"] forState:UIControlStateNormal];
            btn2_vist.userInteractionEnabled=NO;
            [btn2_routeBack setBackgroundImage:[UIImage imageNamed:@"more_btn_gray_routsBack.png"] forState:UIControlStateNormal];
            btn2_routeBack.userInteractionEnabled=NO;
        }
        if(! [[[TileAuthority sharedInstance].dic_TileAuthority objectForKey:@"order"]isEqualToString:@"1"])
        {
            [btn2_myOrder setBackgroundImage:[UIImage imageNamed:@"more_btn_gray_order2.png"] forState:UIControlStateNormal];
            btn2_myOrder.userInteractionEnabled=NO;
        }
        if( ![[[TileAuthority sharedInstance].dic_TileAuthority objectForKey:@"task"]isEqualToString:@"1"])
        {
            [btn2_myTask setBackgroundImage:[UIImage imageNamed:@"more_btn_gray_task2.png"] forState:UIControlStateNormal];
            btn2_myTask.userInteractionEnabled=NO;
            [btn2_ask setBackgroundImage:[UIImage imageNamed:@"more_btn_gray_ask1.png"] forState:UIControlStateNormal];
            btn2_ask.userInteractionEnabled=NO;
        }
        
        if(! [[[TileAuthority sharedInstance].dic_TileAuthority objectForKey:@"apply"]isEqualToString:@"1"])
        {
            [btn2_myApply setBackgroundImage:[UIImage imageNamed:@"more_btn_gray_apply.png"] forState:UIControlStateNormal];
            btn2_myApply.userInteractionEnabled=NO;
            [btn2_myApproval setBackgroundImage:[UIImage imageNamed:@"more_btn_gray_approval.png"] forState:UIControlStateNormal];
            btn2_myApproval.userInteractionEnabled=NO;
        }
        if( ![[[TileAuthority sharedInstance].dic_TileAuthority objectForKey:@"checkin"]isEqualToString:@"1"])
        {
            [btn2_check setBackgroundImage:[UIImage imageNamed:@"more_btn_gray_check.png"] forState:UIControlStateNormal];
            btn2_check.userInteractionEnabled=NO;
        }
        if( ![[[TileAuthority sharedInstance].dic_TileAuthority objectForKey:@"document"]isEqualToString:@"1"])
        {
            [btn2_Document setBackgroundImage:[UIImage imageNamed:@"more_btn_gray_doc.png"] forState:UIControlStateNormal];
            btn2_Document.userInteractionEnabled=NO;
        }
        if( ![[[TileAuthority sharedInstance].dic_TileAuthority objectForKey:@"gps"]isEqualToString:@"1"])
        {
            [btn2_gps setBackgroundImage:[UIImage imageNamed:@"more_btn_gray_gps.png"] forState:UIControlStateNormal];
            btn2_gps.userInteractionEnabled=NO;
        }
        if(![[[TileAuthority  sharedInstance].dic_TileAuthority objectForKey:@"stock"] isEqualToString:@"1"])
        {
            [btn2_storage setBackgroundImage:[UIImage imageNamed:@"more_btn_gray_sorage.png"] forState:UIControlStateNormal];
            btn2_storage.userInteractionEnabled=NO;
        }
    }
    else//1
    {
        if( ![[[TileAuthority sharedInstance].dic_TileAuthority objectForKey:@"customer"]isEqualToString:@"1"])
        {
            [btn_addClerk setBackgroundImage:[UIImage imageNamed:@"more_btn_gray_clerk.png"] forState:UIControlStateNormal];
            btn_addClerk.userInteractionEnabled=NO;
        }
        if( ![[[TileAuthority sharedInstance].dic_TileAuthority objectForKey:@"competitor"]isEqualToString:@"1"])
        {
            [btn_rival setBackgroundImage:[UIImage imageNamed:@"more_btn_gray_rival.png"] forState:UIControlStateNormal];
            btn_rival.userInteractionEnabled=NO;
        }
        if(! [[[TileAuthority sharedInstance].dic_TileAuthority objectForKey:@"access"]isEqualToString:@"1"])
        {
            [btn_vist setBackgroundImage:[UIImage imageNamed:@"more_btn_gray_visit1.png"] forState:UIControlStateNormal];
            btn_vist.userInteractionEnabled=NO;
        }
        if(! [[[TileAuthority sharedInstance].dic_TileAuthority objectForKey:@"order"]isEqualToString:@"1"])
        {
            [btn_myOrder setBackgroundImage:[UIImage imageNamed:@"more_btn_gray_order1.png"] forState:UIControlStateNormal];
            btn_myOrder.userInteractionEnabled=NO;
        }
        if(! [[[TileAuthority sharedInstance].dic_TileAuthority objectForKey:@"task"]isEqualToString:@"1"])
        {
            [btn_myTask setBackgroundImage:[UIImage imageNamed:@"more_btn_gray_task1.png"] forState:UIControlStateNormal];
            btn_myTask.userInteractionEnabled=NO;
        }
        if(! [[[TileAuthority sharedInstance].dic_TileAuthority objectForKey:@"apply"]isEqualToString:@"1"])
        {
            [btn_myApply setBackgroundImage:[UIImage imageNamed:@"more_btn_gray_apply.png"] forState:UIControlStateNormal];
            btn_myApply.userInteractionEnabled=NO;
            [btn2_myApproval setBackgroundImage:[UIImage imageNamed:@"more_btn_gray_approval.png"] forState:UIControlStateNormal];
            btn2_myApproval.userInteractionEnabled=NO;
        }
        if( ![[[TileAuthority sharedInstance].dic_TileAuthority objectForKey:@"checkin"]isEqualToString:@"1"])
        {
            [btn_check setBackgroundImage:[UIImage imageNamed:@"more_btn_gray_check.png"] forState:UIControlStateNormal];
            btn_check.userInteractionEnabled=NO;
        }
        if(! [[[TileAuthority sharedInstance].dic_TileAuthority objectForKey:@"document"]isEqualToString:@"1"])
        {
            [btn_Document setBackgroundImage:[UIImage imageNamed:@"more_btn_gray_doc.png"] forState:UIControlStateNormal];
            btn_Document.userInteractionEnabled=NO;
        }
        if( ![[[TileAuthority sharedInstance].dic_TileAuthority objectForKey:@"gps"]isEqualToString:@"1"])
        {
            [btn_gps setBackgroundImage:[UIImage imageNamed:@"more_btn_gray_gps.png"] forState:UIControlStateNormal];
            btn_gps.userInteractionEnabled=NO;
        }
        if(![[[TileAuthority  sharedInstance].dic_TileAuthority objectForKey:@"stock"] isEqualToString:@"1"])
        {
            [btn_storage setBackgroundImage:[UIImage imageNamed:@"more_btn_gray_sorage.png"] forState:UIControlStateNormal];
            btn_storage.userInteractionEnabled=NO;
        }
     }
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)Message_TileAuthority
{
    [SGInfoAlert showInfo:@"抱歉,模块未未购买,无法使用"
                  bgColor:[[UIColor darkGrayColor] CGColor]
                   inView:self.view
                 vertical:0.5];
}
- (IBAction)action_message:(id)sender
{
    //Dlog(@"消息通知");
    app.New_msg=NO;
    if(app.New_Ass||app.New_Task||app.New_msg)
    {
        self.tabBarItem.badgeValue=@"";
    }
    else
    {
        self.tabBarItem.badgeValue=nil;
    }
    [app.tabbarVC setSelectedIndex:0];
}

- (IBAction)action_clerk:(id)sender
{
    //Dlog(@"客户登记");
    /*if(![[[TileAuthority sharedInstance].dic_TileAuthority objectForKey:@"customer"]isEqualToString:@"1"])
    {
        [self Message_TileAuthority];
        return;
    }
    */
    RegisterViewController *registerVC=[[RegisterViewController alloc]init];
    registerVC.isRival=NO;
    app.VC_Register=registerVC;
    [self.navigationController  pushViewController:registerVC animated:YES];
}

- (IBAction)action_rival:(id)sender
{
    //Dlog(@"竞争对手登记");
    /*if(![[[TileAuthority sharedInstance].dic_TileAuthority objectForKey:@"competitor"]isEqualToString:@"1"])
    {
        [self Message_TileAuthority];
        return;
    }*/
    RegisterViewController *registerVC=[[RegisterViewController alloc]init];
    registerVC.isRival=YES;
    app.VC_Register=registerVC;
    [self.navigationController  pushViewController:registerVC animated:YES];
}
- (IBAction)action_visit:(id)sender
{
    //Dlog(@"巡访签到");
    /*if(![[[TileAuthority sharedInstance].dic_TileAuthority objectForKey:@"access"]isEqualToString:@"1"])
    {
        [self Message_TileAuthority];
        return;
    }
    */
    if([str_auth isEqualToString:@"4"])
    {
        VisitViewController *vis=[[VisitViewController alloc]init];
        app.VC_Visit=vis;
        [self.navigationController pushViewController:vis animated:YES];
    }
    else
    {
        [app.tabbarVC setSelectedIndex:1];
    }
}
- (IBAction)action_submitOrder:(id)sender
{
    //Dlog(@"我的订单");
    /*if(![[[TileAuthority sharedInstance].dic_TileAuthority objectForKey:@"order"]isEqualToString:@"1"])
    {
        [self Message_TileAuthority];
        return;
    }
    */
    if([str_auth isEqualToString:@"4"])
    {
        SubmitOrderViewController *sub=[[SubmitOrderViewController alloc]init];
        app.VC_SubmitOrder=sub;
        [self.navigationController pushViewController:sub animated:YES];
    }
    else
    {
        [app.tabbarVC setSelectedIndex:2];
    }
}
- (IBAction)action_myTask:(id)sender//我的任务
{
    //Dlog(@"我的任务");
    app.New_Task=NO;
    /*if(![[[TileAuthority sharedInstance].dic_TileAuthority objectForKey:@"task"]isEqualToString:@"1"])
    {
        [self Message_TileAuthority];
        return;
    }
    */
    if(app.New_Ass||app.New_Task||app.New_msg)
    {
        self.tabBarItem.badgeValue=@"";
    }
    else
    {
        self.tabBarItem.badgeValue=nil;
    }
   
    TasksAssignedViewController *taskVC=[[TasksAssignedViewController alloc]init];
    taskVC.isMineTask=YES;
    if(![str_auth isEqualToString:@"4"])
    {
         app.VC_Task=taskVC;
    }
    [self.navigationController pushViewController:taskVC animated:YES];
}
- (IBAction)action_TaskAssign:(id)sender//任务交办
{
    //Dlog(@"任务交办");
    /*if(![[[TileAuthority sharedInstance].dic_TileAuthority objectForKey:@"task"]isEqualToString:@"1"])
    {
        [self Message_TileAuthority];
        return;
    }
    */
    if([str_auth isEqualToString:@"4"])
    {
        [app.tabbarVC setSelectedIndex:1];
        return;
    }
    TasksAssignedViewController *taskVC=[[TasksAssignedViewController alloc]init];
    taskVC.isMineTask=NO;
    app.VC_Task=taskVC;
    [self.navigationController pushViewController:taskVC animated:YES];
}
- (IBAction)action_myApply:(id)sender//我的申请
{
    //Dlog(@"我的申请");
    /*if(![[[TileAuthority sharedInstance].dic_TileAuthority objectForKey:@"apply"]isEqualToString:@"1"])
    {
        [self Message_TileAuthority];
        return;
    }
    */
    AssessmentViewController *assVC=[[AssessmentViewController alloc]init];
    assVC.isWillAssess=NO;
    app.VC_Assessment=assVC;
    [self.navigationController pushViewController:assVC animated:YES];
}
- (IBAction)action_WaitingForAssessment:(id)sender//待审批
{
    //Dlog(@"待审批");
    app.New_Ass=NO;
    [self Show_Dialog];
    /*
    if(![[[TileAuthority sharedInstance].dic_TileAuthority objectForKey:@"apply"]isEqualToString:@"1"])
    {
        [self Message_TileAuthority];
        return;
    }
     */
    if([str_auth isEqualToString:@"4"])
    {
        [app.tabbarVC setSelectedIndex:2];
        return;
    }
    AssessmentViewController *assVC=[[AssessmentViewController alloc]init];
    assVC.isWillAssess=YES;
    app.VC_Assessment=assVC;
    [self.navigationController pushViewController:assVC animated:YES];
}
- (IBAction)action_SignUp:(id)sender//考勤
{
    //Dlog(@"考勤签到");
    /*
     if(![[[TileAuthority sharedInstance].dic_TileAuthority objectForKey:@"checkin"]isEqualToString:@"1"])
    {
        [self Message_TileAuthority];
        return;
    }
    */
    SignInViewController *sign=[[SignInViewController alloc]init];
    sign.str_isFrom_More=@"2";//2是考勤 1是巡访
    [self.navigationController pushViewController:sign animated:YES];
}
- (IBAction)action_Path:(id)sender//路径回放
{
    //Dlog(@"轨迹回放");
    LocationViewController *loVC=[[LocationViewController alloc]init];
    loVC.str_from=@"1";//轨迹
    [self.navigationController pushViewController:loVC animated:YES];
}

- (IBAction)action_Have_A_Rest:(id)sender//休假
{
    //Dlog(@"休假");
    HolidayViewController *loc=[[HolidayViewController alloc]init];
    [self presentModalViewController:loc animated:YES];

}
- (IBAction)action_DataAnalyse:(id)sender//企业分析（数据分析）
{
    //Dlog(@"企业分析（数据分析）");
    /*
    if(![[[TileAuthority sharedInstance].dic_TileAuthority objectForKey:@"analysis"]isEqualToString:@"1"])
    {
        [self Message_TileAuthority];
        return;
    }
    */
    [app.tabbarVC setSelectedIndex:3];
}
- (IBAction)action_CompanyDocument:(id)sender //企业文档
{
    //企业文档
    //Dlog(@"企业文档");
    /*
    if(![[[TileAuthority sharedInstance].dic_TileAuthority objectForKey:@"document"]isEqualToString:@"1"])
    {
        [self Message_TileAuthority];
        return;
    }
     */
    FileViewController *fileVC=[[FileViewController alloc]init];
    [self.navigationController pushViewController:fileVC animated:YES];
}
- (IBAction)action_Advice:(id)sender//问题反馈
{
    //Dlog(@"问题反馈");
    AdviceViewController *fileVC=[[AdviceViewController alloc]init];
    [self.navigationController pushViewController:fileVC animated:YES];
}
- (IBAction)action_ClearAll:(id)sender//清除缓存
{
    //Dlog(@"清除缓存");
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                    message:@"您确定要清除所有缓存吗"
                                                   delegate:self
                                          cancelButtonTitle:@"取消"
                                          otherButtonTitles:@"确定", nil];
    [alert show];
    alert.tag=12;
    alert=nil;
}
- (IBAction)action_AboutUs:(id)sender//关于 我们
{
    //Dlog(@"关于 我们");
    DocumentViewController *doc=[[DocumentViewController alloc]init];
    doc.string_Title=@"关于我们";
    doc.str_only_Online=@"1";
    doc.str_Url=[NSString stringWithFormat:@"%@%@",kBASEURL,KAboutUs];
    [self.navigationController pushViewController:doc animated:YES];
}
- (IBAction)action_ChangeSecret:(id)sender//修改密码
{
    //Dlog(@"修改密码");
    SecretViewController *secretVC=[[SecretViewController alloc]init];
    [self.navigationController pushViewController:secretVC animated:YES];
}
- (IBAction)action_Exit:(id)sender//退出
{
    //Dlog(@"退出");
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                    message:@"您确定要退出该应用吗"
                                                   delegate:self
                                          cancelButtonTitle:@"取消"
                                          otherButtonTitles:@"确定", nil];
    alert.tag=10;
    [alert show];
    alert=nil;
}
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    //Dlog(@"%ld",(long)buttonIndex);
    
    if(alertView.tag==12)//清除缓存
    {
        if(buttonIndex==1)
        {
            [SGInfoAlert showInfo:@" 已清除全部缓存 "
                          bgColor:[[UIColor darkGrayColor] CGColor]
                           inView:self.view
                         vertical:0.5];
            
            [Function DeleteTheFile:[NSString stringWithFormat:@"%@/%@",MyFolder,IsReadBefore] Kind:Library_Cache];//阅读已读未读
            [Function DeleteTheFile:[NSString stringWithFormat:@"%@/%@",MyFolder,Message_Notice] Kind:Library_Cache];//消息
            [Function DeleteTheFile:[NSString stringWithFormat:@"%@/%@",MyFolder,Clerk_list]  Kind:Library_Cache];//本地客户或竞争对手信息
            [Function DeleteTheFile:[NSString stringWithFormat:@"%@/%@",MyFolder,Save_List]  Kind:Library_Cache];//收藏终端
            [Function DeleteTheFile:[NSString stringWithFormat:@"%@/%@",MyFolder,CompanyLogo] Kind:Library_Cache];//企业Logo
            [Function DeleteTheFile:Office_Products Kind:Library_Cache];//文档
            [Function Delete_TotalFileFromPath];//所有缓存的网络图片
            [[AddProduct sharedInstance].arr_AddToList removeAllObjects];//订单数据
            [[IsRead  sharedInstance ].arr_isRead removeAllObjects];//已读通知数据
            [app.array_message removeAllObjects];
            return;
        }
    }
    else if(alertView.tag==10)
    {
        if(buttonIndex==1)
        {
            [self exitApplication];//退出应用
        }
    }
}
- (void)exitApplication
{//退出应用
    
    UIWindow *window = app.window;
    [UIView animateWithDuration:0.8f animations:^{
        window.alpha = 0;
        window.frame = CGRectMake(window.bounds.size.width/2.0, window.bounds.size.width, 0, 0);
    } completion:^(BOOL finished) {
        exit(0);
    }];
}
- (IBAction)action_GPS:(id)sender
{
    //Dlog(@"GPS监控记录");
    Logistic_LocationViewController *loc=[[Logistic_LocationViewController alloc]init];
    [self presentModalViewController:loc animated:YES];

}
- (IBAction)action_Storage:(id)sender
{
    //Dlog(@"库存");
    Select_StorageViewController *seVC=[[Select_StorageViewController alloc]init];
    [self.navigationController pushViewController:seVC animated:YES];
}
@end
