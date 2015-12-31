//
//  TasksAssignedViewController.h
//  WZYB_syb
//  我的任务/任务交办视图控制器
//  Created by wzyb on 14-7-2.
//  Copyright (c) 2014年 WZYB. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyTaskViewController.h"
#import "UnderLineLabel.h"

@protocol MyDelegate_Task <NSObject>
@optional
-(void)Notify_Task;
@end
@interface TasksAssignedViewController : BaseViewController<UITableViewDataSource,UITableViewDelegate,MyDelegate_MyTask>
{
    UITableView *tableView_task;//任务表
    NSArray *arr_list;//数据列表

    UIButton *btn_MyTask;//我的申请
    UIButton *btn_ToOrder;//我的指派
    
    UILabel *lab_MyTask;
    UILabel *lab_ToOrder;
    
    NSString *auth;//判断级别1.普通员工2.部门经理3.管理员4.boss
    UITextField *text_Bord;//查看详细和
    
    NSInteger URLFlag;    //高级搜索前后的URL区分 //1.0.4
}
@property(weak,nonatomic)id<MyDelegate_Task> delegate;
@property(nonatomic,assign)BOOL isOnTabbar;//YES 在tabbar上
@property(nonatomic,assign)BOOL isMineTask; //是我的任务吗 YES 是 NO 不是
@property(nonatomic,retain)NSString *titleString;
@end
