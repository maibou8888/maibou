//
//  OrderListViewController.h
//  WZYB_syb
//  订单详细/添加订单视图控制器/在线下订单视图控制器
//  Created by wzyb on 14-6-27.
//  Copyright (c) 2014年 WZYB. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AddListOrderViewController.h"
#import "SubmitOrderViewController.h"
#import "OrderListDynamic.h"
#import "NavView.h"
@protocol MyDelegate_OrderListView
@optional
-(void)Notify_OrderListView;
@end

@interface OrderListViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate,UIAlertViewDelegate,MyDelegate_OrderListView>
{
    NSInteger moment_status;
    UIButton *btn_Add;//添加新品
    UITableView *tableView_orderList;//xx快消品订单列表
 
    float should_Accounts;//应收
    float real_Accounts;//实收
    float disCount;//折扣
    NSString *str_isInstead;//是否代收  //1  代收 0 不代收
    NSArray *arr_list;//订单详细列表
    NSArray *arr_H13;//物料或者产品单位
    NSArray *arr_sectionName;//物料或者产品列表
    /**动态菜单start**/
    __weak IBOutlet UILabel *lab_should;//应收
    __weak IBOutlet UILabel *lab_real;//实收
    __weak IBOutlet UILabel *lab_discount;//折扣
    __weak IBOutlet UILabel *lab_switch;//代收
    
    BOOL isCloseMenu;//Menu状态 默认 NO  没关闭状态
    __weak IBOutlet UIView *view_meun_background;
    __weak IBOutlet UIButton *btn_cancel;//收缩菜单
    BOOL isSwitch;//NO 默认不是代收
    __weak IBOutlet UIButton *btn_switch;
    
    __weak IBOutlet UIButton *btn_submit;
    /**动态菜单end**/
    __weak IBOutlet UIButton *btn_AllCancel;//不提交
    
    __weak IBOutlet UILabel *label_RealWords;//实收合计标签 实收合计：
    __weak IBOutlet UILabel *label_ShouldTitle;//应收合计标签 应收合计
    
    UIImageView *imageView_Face;
    BOOL isDetail_FirstOpen; //NO 是
    NSDictionary *dic_json;//页面传值
}
@property(assign,nonatomic)id<MyDelegate_OrderListView> delegate;
@property(nonatomic,strong)NSString *str_title;//标题
@property(nonatomic,strong)NSString *str_isfromeDetail;//查看详细  1
@property(nonatomic,strong)NSString *str_index_no;//查看详细list索引
@property(nonatomic,strong)NSString *str_cindex_no;////终端索引
@property(nonatomic,strong)NSString *str_isFromOnlineOrder;//1是在线下订单按钮过来的 从SignIn来（即在线下订单） 0从SubmitOrder来   2是物料查看详细
@property(nonatomic,assign)BOOL is_QR;//是扫二维码进来的吗 YES  是 NO不是
@property(nonatomic,strong)NSString *str_suspend;//已经选好了终端即 已经下过物料但没提交  状态为1
@property(nonatomic,assign)NSInteger returnFlag;

@property(nonatomic,strong)NSDictionary *dic_json;
@property(nonatomic,assign)BOOL isDynamic;//添加订单列表是否有数据
@property(nonatomic,retain)NSString *strFrom;
@property(nonatomic,retain)NSString *terminalName;
@property(nonatomic,retain)NSDictionary *dataDic;
@property(nonatomic,assign)NSInteger localFlag;
@property(nonatomic,retain)NSString *cIndexNumber;
@property(nonatomic,assign)NSInteger RDFlag;
@property(nonatomic,assign)NSInteger HIDFlag;

- (IBAction)Actioncancel:(id)sender;
- (IBAction)Action_switch:(id)sender;
- (IBAction)Action_AllCancel:(id)sender;
- (IBAction)Action_Submit:(id)sender;

 

@end
