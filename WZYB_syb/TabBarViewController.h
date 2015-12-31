//
//  TabBarViewController.h
//  Check
//
//  Created by DAWEI FAN on 14/04/2014.
//  Copyright (c) 2014 huiztech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MessageViewController.h"

#import "VisitViewController.h"
#import "SubmitOrderViewController.h"
#import "MoreViewController.h"
#import "TasksAssignedViewController.h"
#import "SignInViewController.h"//考勤签到
#import "FileViewController.h"//企业文档
#import "LocationViewController.h"//轨迹回放
#import "LocationPersonViewController.h"
#import "DataAnalyseViewController.h"//企业分析（数据分析）
#import "AssessmentViewController.h"//移动审批
@interface TabBarViewController : UITabBarController<UITabBarControllerDelegate>
{
    MessageViewController *messageVC;//消息控制器
    VisitViewController *visitVC;//巡访控制器
    SubmitOrderViewController *submitVC;//提交订单控制器
    
    LocationViewController *LocationVC;//轨迹回放
   // GraphViewController *graphVC;//数据分析
    DataAnalyseViewController *graphVC;//企业分析（数据分析）
    TasksAssignedViewController *taskVC;//任务
    AssessmentViewController *assVC;//审批
    
    MoreViewController *moreAnd_VC;//更多3
    NSString *auth;//用户级别
}

@end
