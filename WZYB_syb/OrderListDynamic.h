//
//  OrderListDynamic.h
//  WZYB_syb
//  订单附加信息视图控制器
//  Created by wzyb on 14-9-26.
//  Copyright (c) 2014年 WZYB. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <BaiduMapAPI/BMapKit.h>
#import "RBCustomDatePickerView.h"
#import "UIActionSheetViewController.h"
#import "NoteViewController.h"
#import "MRZoomScrollView.h"
@interface OrderListDynamic : UIViewController<UIScrollViewDelegate,UIActionSheetDelegate,UIAlertViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,BMKLocationServiceDelegate,BMKGeoCodeSearchDelegate>
{
    NSInteger moment_status;
    NSInteger momentHeight;
    NSInteger btn_tag;//记录button tag
    UIScrollView *scroll;
    
    NSInteger num_editer;//编辑状态下返回标号索引;
    NSMutableArray *arr_tex;
    NSMutableArray *array_Dynamic;//动态部分
    /**日历**/
    UIView *view_back;//日历背景
    BOOL isOpenDate;//日期表打开了吗 yes 打开 NO 没打开
    NSInteger dateIndex;//日期在数组中的索引
    /**日历**/
    /**媒体**/
    NSMutableArray *arr_Media_image;//图片（h7type,required97,imgView,is_addimg）//类型 是否必须（1 必须） 图片（UIimageView） 是否添加过（1添加过）
    NSMutableArray *arr_ShowImage;//按钮背后展示图片imageView
    UIView *view_imageView_back;//全屏大图片
    NSInteger camera_index;//正在拍照的序号
    BOOL isCamera;//如果是拍照  YES
    UIImage *chosenImage;//做显示在self.view 上的image
    /**媒体**/
    CLLocationManager  *locationManager;
    BMKLocationService* locService;//定位服务
    BMKGeoCodeSearch* geocodesearch;//获取坐标所在地址：省市区 街道 号
}
@property (nonatomic, retain) MRZoomScrollView  *zoomScrollView;

@property(nonatomic,strong)NSDictionary *dic_json;
@property(nonatomic,assign)NSInteger localFlag;
@property(nonatomic,assign)BOOL isDetail;
@property(nonatomic,strong)NSString *str_cindex_no;
@property(nonatomic,strong)NSString *str_should_Accounts;
@property(nonatomic,strong)NSString *str_real_Accounts;
@property(nonatomic,strong)NSString *str_disCount;
@property(nonatomic,strong)NSString *str_isInstead;
@property(nonatomic,strong)NSString *str_isFromOnlineOrder;

@property(nonatomic,strong)NSString *mtypeStr;
@property(nonatomic,strong)NSString *indexStr;
@property(nonatomic,assign)NSInteger fromSign; //判断是否从签到寻访画面进来
@property(nonatomic,retain)NSString *matterFlag;
@property(nonatomic,retain)NSDictionary *convertDic;
@property(nonatomic,retain)NSString *titleString;
@property(nonatomic,retain)NSString *terminalName;
@property(nonatomic,strong)NSString *convertNumber;
@property(nonatomic,assign)NSInteger RDFlag;
@end
