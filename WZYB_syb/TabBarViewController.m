//
//  TabBarViewController.m
//  Check
//
//  Created by DAWEI FAN on 14/04/2014.
//  Copyright (c) 2014 huiztech. All rights reserved.
//

#import "TabBarViewController.h"
#import "AppDelegate.h"


@interface TabBarViewController ()
{
    AppDelegate *app;
}
@end

@implementation TabBarViewController

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
    app=(AppDelegate *)[[UIApplication sharedApplication]delegate];
    [self creat_TabarView];
}
-(void)viewWillAppear:(BOOL)animated
{
   
}
-(void)creat_TabarView
{
//    UIView *view=[[UIView alloc]initWithFrame:CGRectMake(0, 0,Phone_Weight, 60)];
//    view.backgroundColor=tabbar_Color;
//    [self.tabBar insertSubview:view atIndex:0];
//    self.tabBar.opaque = YES;
    
    //tabbar 背景图片 ios 6、7都适用  start
    [[UITabBar appearance] setBackgroundImage:[UIImage imageNamed:@"bg_home_tab"]];
    [[UITabBar appearance] setSelectionIndicatorImage:nil];
    //end
    
    [self.tabBar setSelectedImageTintColor:Nav_Bar];//tabbatItem标题颜色
    
    
    messageVC=[[MessageViewController alloc]init];//消息控制器
  //  registerVC=[[RegisterViewController alloc]init];//客户登记控制器
    visitVC=[[VisitViewController alloc]init];//巡访控制器
    submitVC=[[SubmitOrderViewController alloc]init];//提交订单控制器

    LocationVC=[[LocationViewController alloc]init];//轨迹回放
    LocationVC.str_from=@"1";
    graphVC=[[DataAnalyseViewController alloc]init];//数据分析
    taskVC=[[TasksAssignedViewController alloc]init];//任务
    assVC=[[AssessmentViewController alloc]init];//审批
    moreAnd_VC=[[MoreViewController alloc]init];//更多3
    
/*
    if(1)
    {
       1、 消息
       2、 终端巡访
       3、 订单上报
      // 4、 客户登记
       5、 更多(考勤Visit、移动审批,任务交办（仅限接收）,企业文档，系统设置（问题反馈，清除缓存，关于我们，退出）)
    }
    else if(2)
    {
        1、 消息
        2、 终端巡访
        3、 订单上报
       // 4、 客户登记
        5.  更多(考勤,轨迹回放,任务交办,移动审批,企业文档，系统设置（问题反馈，清除缓存，关于我们，退出）)
    }
    else if(3)//这块 不要了
    {
        消息(消息,(考勤,企业文档,系统设置,问题反馈，清除缓存，关于我们，退出）);
    }
    else if(4)
    {
        1.消息
        2.任务指派
        3.移动审批
        4.数据分析
        5.更多(轨迹回放,考勤,企业文档，系统设置（问题反馈，清除缓存，关于我们，退出）)
    }
        
    */
    auth=[[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"auth"];//权限级别
    UITabBarItem *message_Item=[[UITabBarItem alloc]initWithTitle:@"消息通知" image:nil tag:1];
    //UITabBarItem *message_Item = [[UITabBarItem alloc] initWithTabBarSystemItem:UITabBarSystemItemMostViewed tag:1];
    [message_Item setFinishedSelectedImage:[UIImage imageNamed:@"tabbarItem1-2.png"] withFinishedUnselectedImage:[UIImage imageNamed:@"tabbarItem1-1.png"]];
    messageVC.tabBarItem = message_Item;
 
    UITabBarItem *visit_Item=[[UITabBarItem alloc]initWithTitle:@"签到巡访" image:nil tag:3];
    [visit_Item setFinishedSelectedImage:[UIImage imageNamed:@"tabbarItem3-2.png"] withFinishedUnselectedImage:[UIImage imageNamed:@"tabbarItem3-1.png"]];
    visitVC.tabBarItem = visit_Item;
    
    UITabBarItem *submit_Item=[[UITabBarItem alloc]initWithTitle:@"我的订单" image:nil tag:4];
    [submit_Item setFinishedSelectedImage:[UIImage imageNamed:@"tabbarItem4-2.png"] withFinishedUnselectedImage:[UIImage imageNamed:@"tabbarItem4-1.png"]];
    submitVC.tabBarItem = submit_Item;
    
    UITabBarItem *much_Item=[[UITabBarItem alloc]initWithTitle:@"菜单" image:nil tag:5];
    [much_Item setFinishedSelectedImage:[UIImage imageNamed:@"tabbarItem5-2.png"] withFinishedUnselectedImage:[UIImage imageNamed:@"tabbarItem5-1.png"]];
    moreAnd_VC.tabBarItem = much_Item;
    
//    //轨迹回放
//    UITabBarItem *Location_Item=[[UITabBarItem alloc]initWithTitle:@"轨迹回放" image:nil tag:6];
//    [Location_Item setFinishedSelectedImage:[UIImage imageNamed:@"tabbarItem6-2.png"] withFinishedUnselectedImage:[UIImage imageNamed:@"tabbarItem6-1.png"]];
//    LocationVC.tabBarItem = Location_Item;
    //数据分析
    UITabBarItem *Graph_Item=[[UITabBarItem alloc]initWithTitle:@"企业分析" image:nil tag:7];
    [Graph_Item setFinishedSelectedImage:[UIImage imageNamed:@"tabbarItem7-2.png"] withFinishedUnselectedImage:[UIImage imageNamed:@"tabbarItem7-1.png"]];
    graphVC.tabBarItem = Graph_Item;
    //任务交办
    UITabBarItem *task_Item=[[UITabBarItem alloc]initWithTitle:@"任务交办" image:nil tag:8];
    [task_Item setFinishedSelectedImage:[UIImage imageNamed:@"tabbarItem8-2.png"] withFinishedUnselectedImage:[UIImage imageNamed:@"tabbarItem8-1.png"]];
    taskVC.tabBarItem = task_Item;
    //移动审批
    UITabBarItem *ass_Item=[[UITabBarItem alloc]initWithTitle:@"我的审批" image:nil tag:9];
    [ass_Item setFinishedSelectedImage:[UIImage imageNamed:@"tabbarItem9-2.png"] withFinishedUnselectedImage:[UIImage imageNamed:@"tabbarItem9-1.png"]];
    assVC.tabBarItem = ass_Item;
    
    //app.VC_Register=registerVC;
    app.VC_SubmitOrder=submitVC;
    app.VC_msg=messageVC;
    app.VC_Task=taskVC;
    app.VC_more=moreAnd_VC;
    app.VC_Visit=visitVC;
    if([auth isEqualToString:@"1"])
    {
        NSMutableArray *arrary_VC=[NSMutableArray arrayWithCapacity:1];
        [arrary_VC addObject:messageVC];
        if([[[TileAuthority sharedInstance].dic_TileAuthority objectForKey:@"access"]isEqualToString:@"1"])
        {
            [arrary_VC addObject:visitVC];
        }
        if([[[TileAuthority sharedInstance].dic_TileAuthority objectForKey:@"order"]isEqualToString:@"1"])
        {
            [arrary_VC addObject:submitVC];
        }
        [arrary_VC addObject:moreAnd_VC];
        self.delegate=self;
        self.viewControllers=arrary_VC;
        //设置选中哪个tab
    }
    else if([auth isEqualToString:@"2"])
    {
        NSMutableArray *arrary_VC=[NSMutableArray arrayWithCapacity:1];
        [arrary_VC addObject:messageVC];
        if([[[TileAuthority sharedInstance].dic_TileAuthority objectForKey:@"access"]isEqualToString:@"1"])
        {
            [arrary_VC addObject:visitVC];
        }
        if([[[TileAuthority sharedInstance].dic_TileAuthority objectForKey:@"order"]isEqualToString:@"1"])
        {
            [arrary_VC addObject:submitVC];
        }
        [arrary_VC addObject:moreAnd_VC];
        self.delegate=self;
        self.viewControllers=arrary_VC;
    }
    else if([auth isEqualToString:@"3"]) //暂时没有此权限 moreViewController.xib里面也是四层  第三个没有用
    {
        NSArray *arrary_VC= @[messageVC,moreAnd_VC];
        self.delegate=self;
        self.viewControllers=arrary_VC;
    }
    else if([auth isEqualToString:@"4"])
    {
        NSMutableArray *arrary_VC=[NSMutableArray arrayWithCapacity:1];
        [arrary_VC addObject:messageVC];
        if([[[TileAuthority sharedInstance].dic_TileAuthority objectForKey:@"task"]isEqualToString:@"1"])
        {
            [arrary_VC addObject:taskVC];
        }
        if([[[TileAuthority sharedInstance].dic_TileAuthority objectForKey:@"apply"]isEqualToString:@"1"])
        {
            [arrary_VC addObject:assVC];
        }
        if([[[TileAuthority sharedInstance].dic_TileAuthority objectForKey:@"analysis"]isEqualToString:@"1"])
        {
            [arrary_VC addObject:graphVC];
        }
        [arrary_VC addObject:moreAnd_VC];
        self.viewControllers=arrary_VC;
        taskVC.isMineTask=NO;
        taskVC.isOnTabbar=YES;
        assVC.isOnTabbar=YES;
        assVC.isWillAssess=YES;
        self.delegate=self;
        app.VC_Assessment=assVC;
        graphVC.isOnTabbar=YES;
    }
//    app.tabbarVC=self;//方便菜单里面切换到tab
    [self setSelectedIndex:0];
}
- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item
{//1.消息 2.客户登记 3.巡访签到 4.订单列表 5.更多 6.轨迹回放 7.数据分析 8.任务交办 9.移动审批
    if([auth isEqualToString:@"1"])
    {
        //=======做未读消息提示start
        if(item.tag==1)
        {
            app.unRead_count=[NavView returnCount];
            if(app.unRead_count!=0)
            {
                item.badgeValue = [NSString stringWithFormat:@"%ld",(long)app.unRead_count];
            }
            else
            {
                item.badgeValue=nil;
            }
        }
        //=======做未读消息提示end
    }
    else if([auth isEqualToString:@"2"])
    {
        
    }
    else if([auth isEqualToString:@"3"])
    {
        
    }
    else if([auth isEqualToString:@"5"])
    {
        //Dlog(@"XXX");
        if(app.New_Ass||app.New_Task||app.New_msg)
        {
            item.badgeValue=@"";
        }
        else
        {
            item.badgeValue=nil;
        }
    }
    
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
