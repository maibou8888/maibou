//
//  MyTaskViewController.h
//  WZYB_syb
//  我的任务/任务交办详情页面
//  Created by wzyb on 14-7-2.
//  Copyright (c) 2014年 WZYB. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LocationViewController.h"
#import "NavView.h"
@protocol MyDelegate_MyTask <NSObject>
@optional
-(void)Notify_MyTask:(NSString *)msg;
@end



@interface MyTaskViewController : UIViewController<UIScrollViewDelegate,UIAlertViewDelegate,UITextViewDelegate>
{
    NSInteger moment_status;
    BOOL isBack;                                    //是否返回  YES 是
 
    __weak IBOutlet UIScrollView *scroll1;          //我的任务
    NSString *str_tret;                             //提交反馈语言
 
    /****XIB*****/
    //scroll1  moreVC里面我的任务详情界面控件
    __weak IBOutlet UILabel *lab_content;           //任务内容
    __weak IBOutlet UILabel *lab_thePersonFrom;     //发起者
    __weak IBOutlet UILabel *lab_text;              //反馈备注
    __weak IBOutlet UILabel *lab_date;              //日期
    __weak IBOutlet UILabel *lab_status;            //任务状态
    
    __weak IBOutlet UIButton *btn_accept;
    __weak IBOutlet UIButton *btn_reject;
    __weak IBOutlet UIButton *btn_finish;
    
    //scroll2   moreVC里面任务交办详情界面控件
    __weak IBOutlet UIScrollView *scroll2;

    //scroll3
     IBOutlet UIScrollView *scroll3;
    __weak IBOutlet UILabel *lab_content3;          //任务内容
    __weak IBOutlet UILabel *lab_thePersonFrom3;    //相关人员
    __weak IBOutlet UIButton *btn_submit;
    BOOL isPeople;                                  //是相关人员 吗 YES 是
    BOOL isContent;                                 //是书写的文本吗 YES 是
    /****XIB*****/
    NSString *str_auth;
}
@property(weak,nonatomic)id<MyDelegate_MyTask> delegate;
@property(nonatomic,retain)NSString *str_isMyTask;  //是任务还是指派 1任务 0 指派
@property(nonatomic,retain)NSString *str_content;
@property(nonatomic,retain)NSString *str_ins_date;
@property(nonatomic,retain)NSString *str_index_no;
@property(nonatomic,retain)NSString *str_tsts;      //更新任务状态 1 2 3 接收 拒绝 完成
@property(nonatomic,retain)NSString *str_uname;     //交办任务的人们名称或发起者
@property(nonatomic,strong)NSString *str_tret;      //我的任务 更新状态时候的附加提交备注
@property(assign)BOOL isAddNewTask;                 //是否添加新任务  YES 是
@property(nonatomic,retain) NSString *urlString;

@property (strong, nonatomic) IBOutlet UITableView *myTableView;
@property (nonatomic , retain) NSDictionary *assignDic;

- (IBAction)Action_content:(id)sender;              //任务内容
- (IBAction)Action_AbountPeople:(id)sender;         //相关人员
- (IBAction)Action_tret:(id)sender;                 //反馈信息

@end
