//
//  NewTabbarViewController.m
//  WZYB_syb
//
//  Created by wzyb on 15-1-9.
//  Copyright (c) 2015年 WZYB. All rights reserved.
//

#import "NewTabbarViewController.h"
#import "QuickViewController.h"
#import "DailyViewController.h"
#import "NewMoreViewController.h"
#import "DataAnalyseViewController.h"
#import "AppDelegate.h"
@interface NewTabbarViewController () {
    AppDelegate* app;
    NSDictionary* _dataDic; //贴片数据字典
}
@end

@implementation NewTabbarViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    app = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    [self creat_TabarView];
}

- (void)creat_TabarView
{
    [[UITabBar appearance] setBackgroundImage:[UIImage imageNamed:@"bg_home_tab"]];
    [[UITabBar appearance] setSelectionIndicatorImage:nil];
    [self.tabBar setSelectedImageTintColor:Nav_Bar]; //tabbatItem标题颜色

    QuickViewController* quickVC = [QuickViewController new];
    DailyViewController* dailyVC = [DailyViewController new];
    NewMoreViewController* moreVC = [NewMoreViewController new];
    DataAnalyseViewController* analyVC = [DataAnalyseViewController new];

    app.dairyVC = dailyVC;

    UITabBarItem* quickItem = [[UITabBarItem alloc] initWithTitle:@"快捷" image:nil tag:1];
    UITabBarItem* dailyItem = [[UITabBarItem alloc] initWithTitle:@"日常" image:nil tag:2];
    UITabBarItem* analyItem = [[UITabBarItem alloc] initWithTitle:@"分析" image:nil tag:3];
    UITabBarItem* moreItem = [[UITabBarItem alloc] initWithTitle:@"更多" image:nil tag:4];

    if (isIOS7) {
        [quickItem setFinishedSelectedImage:RenderImage(@"quickPress.png") withFinishedUnselectedImage:RenderImage(@"quick.png")];
        [dailyItem setFinishedSelectedImage:RenderImage(@"dailyPress.png") withFinishedUnselectedImage:RenderImage(@"daily.png")];
        [analyItem setFinishedSelectedImage:RenderImage(@"analyPress.png") withFinishedUnselectedImage:RenderImage(@"analy.png")];
        [moreItem setFinishedSelectedImage:RenderImage(@"morePress.png") withFinishedUnselectedImage:RenderImage(@"more.png")];
    }
    else {
        [quickItem setFinishedSelectedImage:[UIImage imageNamed:@"quickPress.png"]
                withFinishedUnselectedImage:[UIImage imageNamed:@"quick.png"]];
        [dailyItem setFinishedSelectedImage:[UIImage imageNamed:@"dailyPress.png"]
                withFinishedUnselectedImage:[UIImage imageNamed:@"daily.png"]];
        [analyItem setFinishedSelectedImage:[UIImage imageNamed:@"analyPress.png"]
                withFinishedUnselectedImage:[UIImage imageNamed:@"analy.png"]];
        [moreItem setFinishedSelectedImage:[UIImage imageNamed:@"morePress.png"]
               withFinishedUnselectedImage:[UIImage imageNamed:@"more.png"]];
    }

    quickVC.tabBarItem = quickItem;
    dailyVC.tabBarItem = dailyItem;
    analyVC.tabBarItem = analyItem;
    moreVC.tabBarItem = moreItem;

    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    _dataDic = [[NSDictionary alloc] initWithDictionary:[defaults objectForKey:@"TileTitle"]];

    NSMutableArray* viewControllers = nil;
    if ([@"1" isEqualToString:[[_dataDic objectForKey:@"analysis"] objectForKey:@"authority"]]) {
        viewControllers = [[NSMutableArray alloc] initWithObjects:quickVC, dailyVC, analyVC, moreVC, nil];
    }
    else {
        viewControllers = [[NSMutableArray alloc] initWithObjects:quickVC, dailyVC, moreVC, nil];
    }

    self.viewControllers = viewControllers;
    app.tabbarVC = self; //方便菜单里面切换到tab
    self.delegate = self;
    [self setSelectedIndex:0];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
