//
//  MoreViewController.h
//  WZYB_syb
//
//  Created by wzyb on 14-8-18.
//  Copyright (c) 2014年 WZYB. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SubmitOrderViewController.h"
#import "VisitViewController.h"

@interface MoreViewController : UIViewController<UIScrollViewDelegate,UIAlertViewDelegate>
{
     NSInteger moment_status;
     NSString *str_auth;//用户级别
     BOOL isHoliday;//是否正在休假中 YES 是 holiday=1
    /*普通员工*/
    __weak IBOutlet UIButton *btn_msg;//tag 1
    __weak IBOutlet UIButton *btn_addClerk;//tag 2
    __weak IBOutlet UIButton *btn_rival;//tag 3
    __weak IBOutlet UIButton *btn_vist;//tag4
    __weak IBOutlet UIButton *btn_myOrder;//tag 5
    __weak IBOutlet UIButton *btn_myApply;//tag 6
    __weak IBOutlet UIButton *btn_myTask;//7
    __weak IBOutlet UIButton *btn_myApproval;//8
    __weak IBOutlet UIButton *btn_Document;//9
    __weak IBOutlet UIButton *btn_check;//10
    __weak IBOutlet UIButton *btn_gps;//20
    __weak IBOutlet UIButton *btn_storage;//21
    
    /*普通员工*/
    /*部门经理*/
    
    __weak IBOutlet UIButton *btn2_msg;//1
    __weak IBOutlet UIButton *btn2_addClerk;//2
    __weak IBOutlet UIButton *btn2_rival;//tag 3
    __weak IBOutlet UIButton *btn2_vist;//tag4
    __weak IBOutlet UIButton *btn2_myOrder;//tag 5
    __weak IBOutlet UIButton *btn2_myApply;//tag 6
    __weak IBOutlet UIButton *btn2_myTask;//7
    __weak IBOutlet UIButton *btn2_myApproval;//8
    __weak IBOutlet UIButton *btn2_Document;//9
    __weak IBOutlet UIButton *btn2_check;//10
    __weak IBOutlet UIButton *btn2_ask;//11 任务交办
    __weak IBOutlet UIButton *btn2_gps;//20
    __weak IBOutlet UIButton *btn2_storage;//21
    
    __weak IBOutlet UIButton *btn2_routeBack;//22  assess
    /*部门经理*/
    /*管理者*/
    //废弃了 不用了
    /*管理者*/
    /*boss*/
    __weak IBOutlet UIButton *btn4_msg;//tag 1
    __weak IBOutlet UIButton *btn4_addClerk;//tag 2
    __weak IBOutlet UIButton *btn4_rival;//tag 3
    __weak IBOutlet UIButton *btn4_vist;//tag4
    __weak IBOutlet UIButton *btn4_myOrder;//tag 5
    __weak IBOutlet UIButton *btn4_myApply;//tag 6
    __weak IBOutlet UIButton *btn4_myTask;//7
    __weak IBOutlet UIButton *btn4_myApproval;//8
    __weak IBOutlet UIButton *btn4_Document;//9
    __weak IBOutlet UIButton *btn4_check;//10
    __weak IBOutlet UIButton *btn4_ask;//11 任务交办
    __weak IBOutlet UIButton *btn4_dataAnalyse;//12
    __weak IBOutlet UIButton *btn4_gps;//20
    __weak IBOutlet UIButton *btn4_storage;//21
    __weak IBOutlet UIButton *btn4_routeBack;//22  assess
    /*boss*/
}
@property (strong, nonatomic) IBOutlet UIScrollView *scroll1;//普通员工
@property (strong, nonatomic) IBOutlet UIScrollView *scroll2;//部门经理
@property (strong, nonatomic) IBOutlet UIScrollView *scroll3;//管理员
@property (strong, nonatomic) IBOutlet UIScrollView *scroll4;//boss
@property (weak, nonatomic) IBOutlet UIImageView *img_mention_4_1;
@property (weak, nonatomic) IBOutlet UIImageView *img_mention_2_1;
@property (weak, nonatomic) IBOutlet UIImageView *img_mention_1_1;

@property (weak, nonatomic) IBOutlet UIImageView *img_mention_1_2;
@property (weak, nonatomic) IBOutlet UIImageView *img_mention_1_3;

@property (weak, nonatomic) IBOutlet UIImageView *img_mention_2_2;
@property (weak, nonatomic) IBOutlet UIImageView *img_mention_2_3;
@property (weak, nonatomic) IBOutlet UIImageView *img_mention_4_2;
@property (weak, nonatomic) IBOutlet UIImageView *img_mention_4_3;


/*方法*/
- (IBAction)action_message:(id)sender;//消息通知
//-----------------1

- (IBAction)action_clerk:(id)sender;//客户登记
- (IBAction)action_rival:(id)sender;//竞争对手登记
- (IBAction)action_visit:(id)sender;//巡访签到
- (IBAction)action_submitOrder:(id)sender;//我的订单
- (IBAction)action_myTask:(id)sender;//我的任务
- (IBAction)action_myApply:(id)sender;//我的申请
- (IBAction)action_WaitingForAssessment:(id)sender;//待审批
- (IBAction)action_SignUp:(id)sender;//考勤
//-----------------1
//-----------------2
- (IBAction)action_Path:(id)sender;//轨迹回放
- (IBAction)action_TaskAssign:(id)sender;//任务交办
- (IBAction)action_Have_A_Rest:(id)sender;//休假
//-----------------2
//-----------------3
- (IBAction)action_DataAnalyse:(id)sender;//企业分析（数据分析）
//-----------------3
- (IBAction)action_CompanyDocument:(id)sender;//企业文档
- (IBAction)action_Advice:(id)sender;//问题反馈
- (IBAction)action_ClearAll:(id)sender;//清除缓存
- (IBAction)action_AboutUs:(id)sender;//关于 我们
- (IBAction)action_ChangeSecret:(id)sender;//修改密码
- (IBAction)action_Exit:(id)sender;//退出
- (IBAction)action_GPS:(id)sender;//GPS监控
- (IBAction)action_Storage:(id)sender;//库存量

/*方法*/
@end
