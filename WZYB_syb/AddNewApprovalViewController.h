//
//  AddNewApprovalViewController.h
//  WZYB_syb
//  申请清单添加视图控制器
//  Created by wzyb on 14-7-11.
//  Copyright (c) 2014年 WZYB. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OrderListViewController.h"
//#import "LocatingViewController.h"
#import "NotQRViewController.h"
#import "UIActionSheetViewController.h"
#import "NoteViewController.h"
#import "LocationViewController.h"
#import "NavView.h"
#import "ZBarSDK.h"
#import "RBCustomDatePickerView.h"//日期选择器
#import "MRZoomScrollView.h"
@interface AddNewApprovalViewController : UIViewController<UIScrollViewDelegate,UITextFieldDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIActionSheetDelegate,UIAlertViewDelegate,ZBarReaderDelegate>
{
    NSInteger moment_status;
    UIScrollView *scrollView_Back;
    NSInteger momentHeight;//scrollView 当前高度
    NSInteger combox_height_thisView;
    NSInteger near_by_thisView;
    NSInteger btn_tag;//累计tag
    NSInteger button_Index;//每行的索引
    NSMutableArray *arrData_H9;//H9 label 和Value
    NSArray *arr_list;//动态数据列表
    NSArray *arr_MediaList;//动态媒体列表
    NSMutableArray *arr_Media_image;//图片（h7type,required97,imgView,is_addimg）//类型 是否必须（1 必须） 图片（UIimageView） 是否添加过（1添加过）
    NSMutableArray *arr_ShowImage;//按钮背后展示图片imageView
    NSMutableArray *arr_text;//输入集合数组
    UIImage *chosenImage;//做显示在self.view 上的image
    NSString *str_ValueH;//审批类型cvalue
    
    BOOL isProduct;//物料按钮 YES点击了物料按钮
    BOOL isMaterial;//当前申请是否是物料申请 YES 是
    BOOL isPressProduct;//如果点击了物料按钮 响应二维码而不是照相
    BOOL isBack;//是否 返回 YES 是
    BOOL isCamera;//如果是拍照  YES
    BOOL isChoose;//是否选择菜单YES 是
    NSInteger camera_index;//正在拍照的序号
    
//    UIButton *btn_product;
//    UIButton *btn_submit;
    UIButton *btn_Approval_Master;
    BOOL  isToChooseOther;
    UIView *view_imageView_back;//全屏大图片
    
    UIView *view_back;//日历背景
    BOOL isOpenDate;//日期表打开了吗 yes 打开 NO 没打开
    NSInteger dateIndex;//日期在数组中的索引
    ZbarCustomVC * reader;
   // BOOL Again_request;
    //
    /*
   
    UILabel *lab_rtype;//审批类型
    NSString *str_rtype_cvalue;//审批类型
    UITextField *tex_rcontent;//申请内容
    UITextField *tex_relations;//相关人员
    UITextField *tex_rsum;//费用支出合计
    UITextField *tex_raddress;//执行地址
    
    
    UILabel *label_photo;//照片说明
    UIView *view_btn1;//图片白背景1
    UIView *view_btn2;//图片白背景2
    UIView *view_btn3;//图片白背景3
    
    UIImageView *img_1;
    UIImageView *img_2;
    UIImageView *img_3;
    NSString *str_imgValue1;
    NSString *str_imgValue2;
    NSString *str_imgValue3;
    
    NSString *str_img_Type;//当前拍的是哪张？ 1 2 3做标记 区分
    */
   
}
@property (nonatomic, retain) MRZoomScrollView  *zoomScrollView;
@property(nonatomic,strong)NSString *str_typeLabel;// 审批类型 clabel页面传值来的
@property(nonatomic,strong)NSString *str_Json;//json  页面传值来的
/************/
//@property(nonatomic,retain)NSString *str_cindex_no;//终端编号 下物料时候用 扫二维码返回的值
@property(nonatomic,retain)NSString *str_qr_url;//获取二维码串
//@property (strong , nonatomic) ZBarReaderViewController* reader;//二维码类
@property(nonatomic,retain)NSString *urlString;
@property(nonatomic,assign)NSInteger flag;
@end
