//
//  AssessmentViewController.h
//  WZYB_syb
//  我的审批/我的申请视图控制器
//  Created by wzyb on 14-7-1.
//  Copyright (c) 2014年 WZYB. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LocationViewController.h"
#import "UIActionSheetViewController.h"
#import "AssessmentDetailViewController.h"
#import "AssessViewCell.h"
#import "Assess1TableViewCell.h"
#import "NavView.h"
#import "UnderLineLabel.h"
#import "RBCustomDatePickerView.h"//日期选择器
@protocol MyDelegate_Ass <NSObject>
@optional
-(void)Notify_Ass;
@end


@interface AssessmentViewController : BaseViewController<UITableViewDataSource,UITableViewDelegate>
{
    NSString *auth;//用户级别
    UITableView *tableView_Approval;//审批列表
    NSArray *arr_AssessList;//列表数据
    UIButton *btn_date;//日历
    NSArray *arr_H9;//审批类型
    BOOL isFirstOpen; //YES 是
}
@property(weak,nonatomic)id<MyDelegate_Ass> delegate;
@property(nonatomic,assign)BOOL isOnTabbar;//YES 在tabbar上
@property(nonatomic,assign)BOOL  isWillAssess;//待办审批列表 是YES 不是NO;
@property(nonatomic,retain)NSString *titleString;
@property(nonatomic,retain)NSString *urlString;
@end
