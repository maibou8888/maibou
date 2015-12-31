//
//  AddNewClerkOrRivalViewController.h
//  WZYB_syb
//
//  Created by wzyb on 14-8-25.
//  Copyright (c) 2014年 WZYB. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIActionSheetViewController.h"
#import "NoteViewController.h"//查看详细文本 或者输入框
#import "RBCustomDatePickerView.h"//日期选择器
#import "MRZoomScrollView.h"
#import "OrientationViewController.h"

@protocol MyDelegate_AddClerkOrRival <NSObject>
@optional
-(void)Notify_AddClerkOrRival:(NSString*)title;
@end
@interface AddNewClerkOrRivalViewController : UIViewController<UIScrollViewDelegate,UITextFieldDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIActionSheetDelegate,UIAlertViewDelegate,BMKLocationServiceDelegate>
{
    NSInteger moment_status;
    NSInteger momentHeight;//当前高度
    NSInteger combox_height_thisView;
    NSInteger near_by_thisView;
    NSInteger btn_tag;//记录button tag
    BOOL isFirstOpen;//是否是第一次进入
    __weak IBOutlet UIScrollView *scrollView_Back;
    NSInteger num_editer;//编辑状态下返回标号索引;
    NSMutableArray *arr_tex;
    NSMutableArray *array_Dynamic;//动态部分
    /**静态**/
    __weak IBOutlet UIButton *btn_0;    //名称
    __weak IBOutlet UIButton *btn_1;    //类型
    __weak IBOutlet UIButton *btn_2;    //联系人
    __weak IBOutlet UIButton *btn_3;    //电话
    __weak IBOutlet UIButton *btn_4;    //规模
    __weak IBOutlet UIButton *btn_5;    //档次
    __weak IBOutlet UIButton *btn_6;    //状态
    __weak IBOutlet UIButton *btn_7;    //地址
    __weak IBOutlet UIButton *btn_8;    //邮件
    
    __weak IBOutlet UITextField *tex_0; //名称
    __weak IBOutlet UITextField *tex_1; //类型
    __weak IBOutlet UITextField *tex_2; //联系人
    __weak IBOutlet UITextField *tex_3; //电话
    __weak IBOutlet UITextField *tex_4; //规模
    __weak IBOutlet UITextField *tex_5; //档次
    __weak IBOutlet UITextField *tex_6; //状态
    __weak IBOutlet UITextField *tex_7; //地址
    __weak IBOutlet UITextField *tex_8; //邮件
    
    NSString *str_value1;//类型H12
    NSString *str_value2;//档次H4
    NSString *str_value3;//状态H3
    /**静态**/
    /**媒体**/
    NSMutableArray *arr_Media_image;//图片（h7type,required97,imgView,is_addimg）//类型 是否必须（1 必须） 图片（UIimageView） 是否添加过（1添加过）
    NSMutableArray *arr_ShowImage;//按钮背后展示图片imageView
    UIView *view_imageView_back;//全屏大图片
    NSInteger camera_index;//正在拍照的序号
    BOOL isCamera;//如果是拍照  YES
    UIImage *chosenImage;//做显示在self.view 上的image
    /**媒体**/
    /**日历**/
    UIView *view_back;//日历背景
    BOOL isOpenDate;//日期表打开了吗 yes 打开 NO 没打开
    NSInteger dateIndex;//日期在数组中的索引
    
    BOOL isPhoto_OK;//NO的时候 有效
    /**日历**/
}
@property(weak,nonatomic)id<MyDelegate_AddClerkOrRival> delegate;
@property (nonatomic, retain) MRZoomScrollView  *zoomScrollView;
@property(nonatomic,assign)BOOL isDetail;//是否查看详细  YES查看详细页面 NO 不是
@property(nonatomic,retain)NSString *str_title;//0 新客户 1竞争对手 2 签约客户(签约客户界面label超链接)
/*****************///以下是查看详细要用的参数
@property(nonatomic,retain)NSString *str_index_no;
@property(nonatomic,strong)NSString *str_value1;    //类型H12
@property(nonatomic,strong)NSString *str_value2;    //档次H4
@property(nonatomic,strong)NSString *str_value3;    //状态H3
@property(nonatomic,strong)NSString *str_tex0;
@property(nonatomic,strong)NSString *str_tex1;
@property(nonatomic,strong)NSString *str_tex2;
@property(nonatomic,strong)NSString *str_tex3;
@property(nonatomic,strong)NSString *str_tex4;
@property(nonatomic,strong)NSString *str_tex5;
@property(nonatomic,strong)NSString *str_tex6;
@property(nonatomic,strong)NSString *str_tex7;
@property(nonatomic,strong)NSString *str_tex8;
@property(nonatomic,strong)NSString *urlString;
@property(nonatomic,strong)NSDictionary *dic_data_all;//传过来的动态数据和媒体
@property(strong,nonatomic)BMKLocationService* locService;//定位服务
@property(strong,nonatomic)CLLocationManager  *locationManager;
@property(nonatomic,assign)NSInteger authFlag; //判断地址btn是否有权限
@property(nonatomic,assign)NSInteger addressFlag; //判断是否定位
@property(nonatomic,assign)NSInteger showLocalImage; //显示保存本地的图片
@property(nonatomic,strong)NSString *local;
@property(nonatomic,strong)NSString *convertNumber;
@property(nonatomic,assign)NSInteger editFlag;
@end
