//
//  AssessmentDetailViewController.h
//  WZYB_syb
//  我的审批事项/申请事项
//  Created by wzyb on 14-8-6.
//  Copyright (c) 2014年 WZYB. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LocationViewController.h"
#import "ShowMyPositionViewController.h"
#import "NoteViewController.h"
#import "SendMessageViewController.h"
#import "MRZoomScrollView.h"
@protocol MyDelegate_AssessDetailView
@optional
-(void)Notify_AssessDetailView;
@end
@interface AssessmentDetailViewController :UIViewController<UIScrollViewDelegate,UIAlertViewDelegate,MyDelegate_AssessDetailView,UIActionSheetDelegate,MFMessageComposeViewControllerDelegate>
{
    NSInteger moment_status;
    NSInteger momentHeight;//scrollView 当前高度
    NSInteger combox_height_thisView;
    NSInteger near_by_thisView;
    UIScrollView *scrollView_Back;
    NSMutableArray *arr_text;//承接所有的text数据
    NSInteger btn_tag;//累计tag
    UIView *view_imageView_back;//全屏大图片
    NSMutableArray *arr_imageView;//所有图片
    BOOL isReadDetail;//是否阅读详细 YES 是
    UILabel *lab_rcontent;
    UILabel *lab_address;
    UILabel *lab_relations;
    UILabel *lab_ins_date;
    UILabel *lab_result;
   
    NSArray *arry_list;//审批表
    NSDictionary *dic_UserList;//部门员工列表数据
    NSArray *arr_H1;
    UITableView *tableView_Inform;
    NSMutableArray *arr_Key;//记住出现了哪些key
    
    UISwitch *switchButton;//是否交代他人;
    BOOL isToOthers;//NO 不交办他人 YES 交办他人
    BOOL isAgree;//是否是同意状态 YES 是
    UIButton *btn_peo;//浏览人员
    UILabel *label_later;//后续审批人
    NSString *str_isSubmit;//是(1)否(0) 提交
    
    NSString *str_ins_uid;//审批流程记录表主键
    NSString *str_rcontent;//申请内容
    NSString *str_replay_content;//反馈内容
    NSString *str_rtype;//0是物料申请 其他不是
    NSString *str_glat;
    NSString *str_glng;
    
    NSString *str_req_index_no;//申请事项的传值  因为self。str_req_index_no 里面为空 所以临时创建此参数;
    NSArray *arr_ApproveList;////审批人集合
 
}
@property(assign,nonatomic)id<MyDelegate_AssessDetailView> delegate;
@property (nonatomic, retain) MRZoomScrollView  *zoomScrollView;
@property(nonatomic,retain)NSString *str_req_index_no;//申请信息表主键 页面传值
@property(nonatomic,retain)NSString *str_index_no;//申请内容 页面传值
@property(assign)BOOL isFromWillAssess;//是点击待审批进来的吗？YES是 NO  不是 页面传值
@property(nonatomic,assign)BOOL isMaterial;//当前申请是否是物料申请 YES 是
@property(nonatomic,strong)NSString *str_title;//标题 页面传值
@property(nonatomic,strong)NSString *str_type;//审批类型 clabel
@property(nonatomic,strong)NSString *urlString;
@property(nonatomic,strong)NSString *isAss;
@property(nonatomic,strong)NSString *tsts;
@property(nonatomic,assign)NSInteger ShowBtnFlag;

@end
