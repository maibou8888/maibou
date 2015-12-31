//
//  AdvancedSearchViewController.h
//  WZYB_syb
//
//  Created by wzyb on 14-9-23.
//  Copyright (c) 2014年 WZYB. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RBCustomDatePickerView.h"//日期选择器
@protocol MyDelegate_AdvancedSearch
@optional
-(void)Notify_AdvancedSearch;
-(void)Notify_AdvancedSearch_1;
@end


@interface AdvancedSearchViewController : UIViewController<UIScrollViewDelegate>
{
    NSInteger moment_status;
    NSInteger moment_height;

    UIView *view_back;//日历背景
    BOOL isOpenDate;//日期表打开了吗 yes 打开 NO 没打开
    UIScrollView *scroll;
    //clerk
    __weak IBOutlet UITextField *tex_startDate;
    __weak IBOutlet UITextField *tex_endDate;
    __weak IBOutlet UIScrollView *scroll_clerk;
    __weak IBOutlet UITextField *tex_gname;
    __weak IBOutlet UITextField *tex_max;
    __weak IBOutlet UITextField *tex_min;
    IBOutlet UIButton *modeMax;
    
    //clerk
    //vist
    __weak IBOutlet UIScrollView *scroll_visit;
    __weak IBOutlet UITextField *tex2_start;
    __weak IBOutlet UITextField *tex2_end;
    __weak IBOutlet UITextField *tex2_status;
    //vist
    //MyTask
    
    __weak IBOutlet UIScrollView *scroll_myTask;
    __weak IBOutlet UITextField *tex3_start;
    __weak IBOutlet UITextField *tex3_end;
    __weak IBOutlet UITextField *tex3_status;
    __weak IBOutlet UITextField *tex3_toWho;
    __weak IBOutlet UITextField *tex3_keyword;
    //MyTask
    //Assign
    __weak IBOutlet UIScrollView *scroll_assign;
    __weak IBOutlet UITextField *tex4_start;
    __weak IBOutlet UITextField *tex4_end;
    __weak IBOutlet UITextField *tex4_status;
    __weak IBOutlet UITextField *tex4_toWho;
    __weak IBOutlet UITextField *tex4_min;
    __weak IBOutlet UITextField *tex4_max;
    //Assign
    //MyApply
    __weak IBOutlet UIScrollView *scroll_myApply;
    __weak IBOutlet UITextField *tex5_start;
    __weak IBOutlet UITextField *tex5_end;
    __weak IBOutlet UITextField *tex5_type;
    __weak IBOutlet UITextField *tex5_status;
    __weak IBOutlet UITextField *tex5_min;
    __weak IBOutlet UITextField *tex5_max;
    __weak IBOutlet UITextField *tex5_person;
    
    IBOutlet UIButton *attendButton;
    
    //MyApply
    //Assess
    __weak IBOutlet UIScrollView *scroll_assess;
    __weak IBOutlet UITextField *tex6_start;
    __weak IBOutlet UITextField *tex6_end;
    __weak IBOutlet UITextField *tex6_type;
    __weak IBOutlet UITextField *tex6_peo;
    __weak IBOutlet UITextField *tex6_status;
    __weak IBOutlet UITextField *tex6_min;
    __weak IBOutlet UITextField *tex6_max;
    //Assess
    //Order
    __weak IBOutlet UIScrollView *scroll_order;
    __weak IBOutlet UITextField *tex7_start;
    __weak IBOutlet UITextField *tex7_end;
    __weak IBOutlet UITextField *tex7_min;
    __weak IBOutlet UITextField *tex7_max;
    __weak IBOutlet UITextField *tex7_status;
    __weak IBOutlet UITextField *tex7_isInstead;
    //Order
    NSInteger Index;
    BOOL isFirst;
    NSMutableArray *arr;
    NSString *auth;
}
@property(assign,nonatomic)id<MyDelegate_AdvancedSearch> delegate;
@property(nonatomic,strong)NSString *str_Num;   // 1--客户 2---寻访签到
@property(nonatomic,strong)NSString *str_Assess;//是审批
@property(nonatomic,assign)NSInteger firstFlag;
@property(nonatomic,assign)NSInteger returnFlag;

@property(nonatomic,assign)NSInteger customerFlag;
@property(nonatomic,retain)NSArray *dynamic_customer;
@property(nonatomic,assign)NSInteger allTypeFlag;
@property(nonatomic,retain)NSString *applyType;

- (IBAction)Action_StartDate:(id)sender; //开始日期
- (IBAction)Action_EndDate:(id)sender;   //结束日期

//clerk
- (IBAction)Action_chooseGname:(id)sender; //终端名称
- (IBAction)Action_chooseMax:(id)sender;   //规模(最大)
- (IBAction)Action_chooseMin:(id)sender;   //规模(最小)
//clerk
//vist
- (IBAction)Action_status:(UIButton *)sender; //签到状态
//vist

//MyTask
- (IBAction)Action3_status:(UIButton *)sender; //执行状态
- (IBAction)Action3_toWho:(UIButton *)sender;  //执行人/指派人
- (IBAction)Action3_Keyword:(UIButton *)sender; //关键字
//MyTask
//Assign
- (IBAction)Action4_min:(UIButton *)sender; //实收最小
- (IBAction)Action4_max:(UIButton *)sender; //实收最大
//Assign
//MyApply
- (IBAction)Action5_type:(UIButton *)sender; //申请类型
- (IBAction)Action5_status:(UIButton *)sender; //申请状态
//MyApply
//Assess
- (IBAction)Action6_Peo:(UIButton *)sender; //申请人
//Assess
//Order

- (IBAction)Action7_statusOrInstead:(UIButton *)sender; //执行(代收款状态)
- (IBAction)personApartment:(id)sender; //所属部门
- (IBAction)terminalAction:(id)sender;  //终端区分

//Order

@end
