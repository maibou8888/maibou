//
//  AddListOrderViewController.h
//  WZYB_syb
//  物料清单详细/编辑订单内容/订单内容/添加新订单内容视图控制器
//  Created by wzyb on 14-6-28.
//  Copyright (c) 2014年 WZYB. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChooseListViewController.h"
#import "NavView.h"
#import "ZBarSDK.h"
@interface AddListOrderViewController : UIViewController<ZBarReaderDelegate,UIScrollViewDelegate,UITextFieldDelegate,UIAlertViewDelegate,UIActionSheetDelegate>
{
    NSInteger moment_status;
    NSInteger momentHeight;
    NSMutableArray *array_TextField;//输入框数组
    //数据表 产品类型
    NSArray *sectionName;
    NSArray *arr_H13;//单位
    NSInteger indexRow;//选择的是哪个产品;
/////xib
    __weak IBOutlet UIScrollView *scroll_back;
    
    __weak IBOutlet UITextField *text_name; //品名
    __weak IBOutlet UITextField *text_code;//型号
    __weak IBOutlet UITextField *text_stock_num;//库存数量
    
    __weak IBOutlet UITextField *text_address;
    __weak IBOutlet UITextField *text_price;//原单价
    __weak IBOutlet UITextField *text_real_price;//现单价
    
    __weak IBOutlet UITextField *text_count;
    __weak IBOutlet UITextField *text_total;//应收
    __weak IBOutlet UITextField *text_real;//实收
    
    ///////////
    __weak IBOutlet UIButton *btn_stockNum;//库存数量
    __weak IBOutlet UIButton *btn_type;//型号
    __weak IBOutlet UIButton *btn_address;//产地
    __weak IBOutlet UIButton *btn_price;//单价
    __weak IBOutlet UIButton *btn_real_price;//现单价
    __weak IBOutlet UIButton *btn_count;//数量
    __weak IBOutlet UIButton *btn_should; //应收
    __weak IBOutlet UIButton *btn_real;//实收
    
    __weak IBOutlet UILabel *lab_pname;//品名
    __weak IBOutlet UILabel *lab_type;//型号
    __weak IBOutlet UILabel *lab_paddress;//地址
    __weak IBOutlet UILabel *lab_Init_Unit;//单价(元)
    __weak IBOutlet UILabel *lab_real_unit;//实收单价(元)
    __weak IBOutlet UILabel *lab_should;//应收合计(元)
    __weak IBOutlet UILabel *label_realwords;//实收合计
    
    __weak IBOutlet UIImageView *img_arrow_real_unitPrice;//实收单价箭头
    __weak IBOutlet UIImageView *img_arrow_cnt;//数量箭头
    __weak IBOutlet UIImageView *img_arrow;//实收合计箭头
    ///////添加一个品牌
    __weak IBOutlet UITextField *text_branded;//品牌
    ///////添加一个品牌
    
    
    UIButton *btn_submit;//确定提交按钮
    BOOL isFirst;//刚刚打开  YES 是
    BOOL isHaveStock;//是否有库存  YES 有
    BOOL isChoose;//是否去扫码或者选择列表项  YES 是
    BOOL chooseBack;
    BOOL isWirte;//是否手动填写数量  YES 是
    BOOL isFix_Real;//是否手动修改 实收合计
    BOOL isFix_Real_UnitPrice;//是否手动修改 现单价
    NSString *str_unit;//产品单位 cvalue
    NSString *str_unit_clabel;//单位 clabel
    NSString *str_pcode;//条形码 编码
    NSString *str_index_no;//每条产品的索引
    ZbarCustomVC * reader;
}
@property (strong,nonatomic)NSString *str_QR_url;//二维码返回信息
@property (nonatomic,strong)NSString *str_Detail;//是否是查看详细 1/2  是 1(编辑状态) 2只读状  态 3->添加订单-》创建(title为添加新订单内容时)
@property (nonatomic,strong)NSString *str_Index;//列表索引
@property (nonatomic,strong)NSString *str_index_no_fromSuper;//从上一页获取的索引 用于判断是哪个产品

@property(nonatomic,strong)NSString *str_name;
@property(nonatomic,strong)NSString *str_code;
@property(nonatomic,strong)NSString *str_stock_num;//库存数量
@property(nonatomic,strong)NSString *str_address;
@property(nonatomic,strong)NSString *str_price;
@property(nonatomic,strong)NSString *str_real_price;
@property(nonatomic,strong)NSString *str_count;//数量
@property(nonatomic,strong)NSString *str_real;
@property(nonatomic,strong)NSString *str_total;//合计
@property(nonatomic,strong)NSString *str_title;//标题
@property(nonatomic,strong)NSString *str_momo;
@property(nonatomic,strong)NSString *str_switch;

@property (weak, nonatomic) IBOutlet UILabel *lab_numUnit;//数量(单位)
@property (weak, nonatomic) IBOutlet UILabel *lab_stock_Unit;//库存 和数量单位统一
@property(nonatomic,strong)NSString *str_numUnit;//数量单位;
@property(nonatomic,strong)NSString *urlString;//数量单位;
@property(nonatomic,retain)NSString *strFrom;
@property(nonatomic,assign)NSInteger returnFlag;

//////
- (IBAction)Action_Name:(id)sender; //点击品名进入
- (IBAction)Action_Count:(id)sender;//点击数量进入
- (IBAction)Action_Real:(id)sender; //点击实收合计进入
- (IBAction)Action_Real_UnitPrice:(id)sender; //点击实收单价进入
- (IBAction)Action_reward:(id)sender;

@end
