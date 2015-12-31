//
//  SignInViewController.h
//  WZYB_syb
//  位置视图控制器
//  Created by wzyb on 14-6-27.
//  Copyright (c) 2014年 WZYB. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OrderListViewController.h"
#import "NavView.h"

#import <CoreLocation/CoreLocation.h>
#import <BaiduMapAPI/BMapKit.h>
#import "QR_GetCustomer.h"
#import "ZBarSDK.h"
@protocol MyDelegate_SignIn
@optional
-(void)Notify_SignIn;
@end
@interface SignInViewController : UIViewController<BMKMapViewDelegate,BMKLocationServiceDelegate,BMKGeoCodeSearchDelegate,ZBarReaderDelegate,UIAlertViewDelegate,UIActionSheetDelegate,ZbarCustomDelegate>
{
    NSInteger moment_status;
    NSInteger btn_Width;
    NSInteger btn_Height;
    NSInteger account_index;//计数器
    UIImageView *imageViewBack;//view_menu背景
    UIView *view_Menu;//菜单
    NSInteger Menu_width;//菜单宽度
    BOOL isCloseMenu;//Menu状态 默认 NO  没关闭状态
    BOOL isOrderList;//是否在线下单去 是YES 否 NO
    BOOL isFirstComeIn;//是不是第一次进地图 NO 是
    BOOL isFirstOpenQR;//是否 刚进入该页面 就打开的二维码 YES 是
    BOOL isFistOpenMap;//第一次调用地图 NO 是
    BOOL isReNotQR;//是不是重新确认终端 且是读取列表方式 YES 是
    BOOL isGetLocationName;//是否获取到坐标地址 YES  是  暂无用处
    BOOL isReQR;//开启二维码
    //BOOL isJustMomentFromSuperView;//是否刚从别的页面跳转过来
    ////定位////
    BMKMapView* mapView;//地图视图
    BMKLocationService* locService;//定位服务
    BMKGeoCodeSearch* geocodesearch;//获取坐标所在地址：省市区 街道 号
    CLLocationManager  *locationManager;
    NSTimer *timer;//定时器 定时调用 定位服务的代理方法
    ////定位////
    
    BMKPointAnnotation* annotation1;//火柴头
    UIButton *button_Re_QR;
    UIButton *button_CloseMenu;//关闭菜单按钮
    UIButton *btn_update;//更新GPS
    BOOL isUpdate;//更新GPS
 
    BOOL isBeyond_Distance;//是否超过规定的distance距离  YES  是
    BOOL isCloseBtn_OnlineList;//是否关闭在线下订单按钮  YES  是（当考勤的时候 判断为是）
    __weak IBOutlet UIView *View_menu;
    __weak IBOutlet UIImageView *imageView_menuBack;
    __weak IBOutlet UIButton *button_signUp;
    __weak IBOutlet UIButton *button_signOut;
    __weak IBOutlet UIButton *button_onlineList;
    __weak IBOutlet UILabel *lab_gname;
    __weak IBOutlet UILabel *lab_address;
    __weak IBOutlet UILabel *lab_test;
 
    UIButton *button_toSignClerk;//选择进入签约终端 签到寻访-》新建-》列表-》终端查询-》label超链接
    NSInteger distance;//距离终端距离
    NSString *str_auth;
    ZbarCustomVC * reader;
    UIButton *btn_update1;//更新GPS
}
@property (nonatomic,retain) NSString *atuString;
@property(assign,nonatomic)id<MyDelegate_SignIn> delegate;
@property (nonatomic,retain)QR_GetCustomer *qr_getCustomer;//二维码得到客户信息
//@property (strong , nonatomic) ZBarReaderViewController* reader;//二维码类
@property(nonatomic,retain)NSString *str_isFrom_More;//是否从更多中 考勤签到而来 2 是考勤  1是巡访
@property (weak, nonatomic) IBOutlet UIImageView *imageView_Status;
@property(nonatomic,assign)BOOL is_QR;//是扫二维码进来的吗 YES  是 NO不是

@end
