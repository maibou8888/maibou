//
//  AppDelegate.h
//  WZYB_syb
//
//  Created by wzyb on 14-6-5.
//  Copyright (c) 2014年 WZYB. All rights reserved.
//
// http://192.168.0.2:8080/wzyb/app.html
#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioToolbox.h>
//要想使用封装好的音频类,导入框,导入类头文件,缺一不可;
#import <AVFoundation/AVFoundation.h>
#import "RootViewController.h"
#import <BaiduMapAPI/BMapKit.h>

#import "GexinSdk.h"
#import "BPush.h"

@protocol MyDelegate_msgVC
@optional
- (void)Notify_MoreVC; // more界面刷新委托
- (void)Notify_msgVC;  //消息通知界面刷新委托
- (void)Notify_assVC;  //我的申请，我的审批界面刷新委托
- (void)Notify_TaskVC; //我的任务，任务交办界面刷新委托
@end

@protocol NewUIDelegate
@optional
- (void)Notify_quiVC;        //快捷控制器委托方法(我的任务)
- (void)Notify_quiVC_Assign; //快捷控制器委托方法(任务交办)
- (void)Notify_quiVC_mesage; //快捷控制器委托方法(任务交办)
@end

@protocol NewDairyUIDelegate
@optional
- (void)Notify_DaiVC;        //日常控制器委托方法(我的任务)
- (void)Notify_DaiVC_Assign; //日常控制器委托方法(任务交办)
- (void)Notify_DaiVC_mesage; //日常控制器委托方法(任务交办)
@end

typedef enum { SdkStatusStoped, SdkStatusStarting, SdkStatusStarted } SdkStatus;
@interface AppDelegate
    : UIResponder <UIApplicationDelegate, BMKLocationServiceDelegate,
                   BMKGeneralDelegate, UIAlertViewDelegate, GexinSdkDelegate,
                   BPushDelegate, CLLocationManagerDelegate,
                   AVAudioPlayerDelegate, ASIHTTPRequestDelegate> {
  BMKMapManager *_mapManager;
  CLLocationManager *locationManager;
  NSString *str_url_version;
  BOOL IsFromeGexin;  //来自个推
  NSString *user_tel; //别名 电话
  NSString *extras_uid;
  BMKLocationService *locationService;

  __block UIBackgroundTaskIdentifier bgTask1;
}

@property(strong, nonatomic) UIWindow *window;
@property(assign, nonatomic) id<MyDelegate_msgVC> mydelegate;
@property(assign, nonatomic) id<NewUIDelegate> myNewDelegate;
@property(assign, nonatomic) id<NewDairyUIDelegate> myDairlNewDelegate;
@property(nonatomic, strong) RootViewController *rootVC;
/*个推*/
@property(strong, nonatomic) GexinSdk *gexinPusher;
@property(strong, nonatomic) NSString *appKey;
@property(strong, nonatomic) NSString *appSecret;
@property(strong, nonatomic) NSString *appID;
@property(strong, nonatomic) NSString *clientId;
@property(assign, nonatomic) SdkStatus sdkStatus;
@property(assign, nonatomic) NSInteger lastPayloadIndex;
@property(strong, nonatomic) NSString *payloadId;
/*个推*/
/*百度云推*/
@property(strong, nonatomic) NSString *baidu_appId;
@property(strong, nonatomic) NSString *baidu_channelId;
@property(strong, nonatomic) NSString *baidu_userId;
/*百度云推*/
////////////////全局变量
@property(nonatomic, assign) float Font;                    //字号大小
@property(nonatomic, strong) NSMutableArray *array_message; //消息
@property(nonatomic, strong) NSMutableArray *array_Photo;
@property(nonatomic, strong) NSString *str_Date; //获取选择日期
@property(nonatomic, strong) NSString *str_startDate;
@property(nonatomic, strong) NSString *str_endDate;
@property(nonatomic, assign) BOOL isDateLegal; //日期是否合法
@property(nonatomic, assign)
    BOOL isSignUp; //是否已经签到 YES 签到过 NO 没签到过
@property(nonatomic, strong) NSString *str_LocationName; //定位的地址
@property(nonatomic, strong) NSString *str_alat;         //纬度
@property(nonatomic, strong) NSString *str_nlng;         //经度
@property(nonatomic, strong) NSString *str_workerName;   //部门员工姓名
@property(nonatomic, strong) NSString *str_index_no; //部门员工 索引编号
@property(nonatomic, strong)
    NSArray *arr_uname_indexno; //部门员工姓名 部门员工 索引编号字典数组

@property(nonatomic, assign)
    BOOL isApproval; //是否是从审批的路径进入的物料添加 YES 是 NO 否
@property(nonatomic, strong) NSString *str_Product_material; // 0商品 1 物料
@property(nonatomic, strong) NSString *str_cindex_no;        //终端编号
@property(nonatomic, strong) NSString *str_osum;             //应收总价
@property(nonatomic, strong) NSString *str_orsum;            //实收总价
@property(nonatomic, strong) NSString *str_odiscount;        //折扣
@property(nonatomic, strong) NSString *str_ctc_sts;          //是否代收
@property(nonatomic, assign) BOOL isLeft;                    //要横屏吗
@property(nonatomic, strong)
    NSString *str_temporary; //临时传递的字符串  在添加新客户时候用的
@property(nonatomic, strong)
    NSString *str_temporary_valueH; //临时传递的字符串  在添加新客户时候用的
//类型 等 cvalue  0

@property(strong, nonatomic) UITabBarController *tabbarVC;
@property(strong, nonatomic) UIViewController *VC_notify; //代理刷新
@property(strong, nonatomic) UIViewController *VC_Task;
@property(strong, nonatomic) UIViewController *VC_Assessment;
@property(strong, nonatomic) UIViewController *VC_SubmitOrder;
@property(strong, nonatomic) UIViewController *VC_SubmitROrder;
@property(strong, nonatomic) UIViewController *VC_Visit;
@property(strong, nonatomic) UIViewController *VC_Register;
@property(strong, nonatomic) UIViewController *VC_msg;
@property(strong, nonatomic) UIViewController *VC_more;
@property(strong, nonatomic) UIViewController *VC_AddNewApproval;

@property(strong, nonatomic) UIViewController *quickVC;
@property(strong, nonatomic) UIViewController *qui_MesgVC;
@property(strong, nonatomic) UIViewController *qui_AssgVC;

@property(strong, nonatomic) UIViewController *dairyVC;
@property(strong, nonatomic) UIViewController *dairy_MesgVC;
@property(strong, nonatomic) UIViewController *dairy_AssgVC;
@property(strong, nonatomic) UIViewController *VC_searchList;
@property(strong, nonatomic) UIViewController *VC_searchApply;
@property(strong, nonatomic) UIViewController *VC_searchCustomer;
@property(strong, nonatomic) UIViewController *VC_searchSign;

@property(strong, nonatomic) NSString *str_atu; //二维码字符串
@property(strong, nonatomic) NSString *str_choose; //选择清单的哪一行  pcode
@property(assign, nonatomic)
    BOOL is_msg_open; //消息打开了吗如果处于打开之中 请求一次数据
@property(assign, nonatomic) BOOL is_Jpush;          //是否刚接到推送
@property(assign, nonatomic) NSInteger unRead_count; //未读计数 更新

@property(assign, nonatomic) BOOL New_msg;
@property(assign, nonatomic) BOOL New_Task;
@property(assign, nonatomic) BOOL New_Ass;
@property(assign, nonatomic) BOOL isOnlyGoBack; //仅仅是返回的时候不用更新列表
@property(assign, nonatomic) BOOL isPortal; //是否有分支url  yes 有

@property(strong, nonatomic) BMKLocationService *locService;     //定位服务
@property(strong, nonatomic) BMKLocationService *locServiceJush; //定位服务
@property(strong, nonatomic) NSMutableArray *arr_location;       //坐标数组
@property(nonatomic, assign) NSInteger counter;  //开辟无线后台计数
@property(nonatomic, assign) NSInteger counter1; //开辟无线后台计数
@property(assign, nonatomic) BOOL isLocating; //无线后台是否是打开的 YES是
@property(nonatomic, assign)
    BOOL isFirstStart_Infinite_Background;                    // YES 是首次
@property(strong, nonatomic) NSString *filepath_LocationList; //定位文件路径
@property(strong, nonatomic)
    NSString *start_location_time; //开始定位的时间 用来做时间差
@property(strong, nonatomic) NSString *str_printf;    //待删除数据
@property(strong, nonatomic) NSString *str_alat_alng; //经纬度显示
@property(strong, nonatomic) NSString *assessSearch; // 1  代表我开始使用搜索了
@property(assign, nonatomic) NSInteger applySearch; // 1  代表我开始使用搜索了
@property(assign, nonatomic) NSInteger searchList; // 1  代表我开始使用搜索了

@property(readonly, strong, nonatomic)
    NSManagedObjectContext *managedObjectContext;
@property(readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property(readonly, strong, nonatomic)
    NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property(nonatomic, strong) UIImageView *splashScreen;
@property(nonatomic, strong) UIImageView *imgView;
@property(nonatomic, assign) BOOL notifier;

@property(nonatomic, assign) NSInteger taskNumber;
@property(nonatomic, assign) NSInteger assgNumber;
@property(nonatomic, assign) NSInteger mesgNumber;
@property(nonatomic, assign) NSInteger gpsNumber;
@property(nonatomic, assign) NSInteger GPSFlag;
@property(nonatomic, retain) NSString *quickString;
@property(strong, nonatomic) AVAudioPlayer *audioPlayer; //播放器player

/*
 *被动定位属性
 */
@property(strong, nonatomic) NSString *str_startTime;
@property(nonatomic, assign) NSInteger backFlag;
@property(nonatomic, assign) NSInteger backTime;

@property(nonatomic, unsafe_unretained) UIBackgroundTaskIdentifier bgTask12;

@property(strong, nonatomic) NSArray *tempArray;
@property(strong, nonatomic) NSString *tempString;
@property(strong, nonatomic) NSString *tempString1;
@property(strong, nonatomic) NSDictionary *tempDic;

@property(assign, nonatomic) NSInteger gpsFlag1;
@property(assign, nonatomic)
    NSInteger gpsFlag2; // music no-limit gps monitor flag(0:stop 1:run)
@property(assign, nonatomic) NSInteger
    gps_threadFlag; // monitor thread is running?(0:no runing 1:running)
@property(assign, nonatomic)
    NSInteger gpsHome; // open baiduService in background
@property(assign, nonatomic)
    NSInteger gpsHomeActive; // make sure baiduService stop
@property(nonatomic,retain)  NSString *GiftFlagStr;
@property(assign, nonatomic) NSInteger loginFlag;
@property(strong, nonatomic) NSString *exeString;
@property(strong, nonatomic) NSString *customerStr;
@property(assign, nonatomic) NSInteger customerNumber;
@property(nonatomic, retain) NSString *BSAddress;
@property(nonatomic, retain) NSString *BSAddressStr;
@property(nonatomic, retain) NSString *takeText;
@property(nonatomic, assign) NSInteger backToSign;
@property(nonatomic, assign) NSInteger markFlag;
@property(nonatomic, retain) NSMutableArray *secondArray;
@property(nonatomic, retain) NSString *serverString;
@property(nonatomic, retain) NSString *secondServer;
@property(nonatomic, retain) NSString *personIndex1;
@property(nonatomic, retain) NSString *personIndex2;
@property(nonatomic, retain) NSDictionary *offLineDic;
@property(nonatomic, retain) NSDictionary *dic_json;
@property(nonatomic, retain) NSDictionary *dic_json1;
@property(nonatomic, retain) NSArray *tempOrderArray;
@property(nonatomic, assign) NSInteger order_refresh;

@property(nonatomic, retain) NSMutableArray *branchArray;
@property(nonatomic, retain) NSMutableArray *typeArray;
@property(nonatomic, retain) NSMutableArray *addressArray;
@property(nonatomic, assign) NSInteger selectFlag;

@property(nonatomic, retain) NSMutableArray *mutDynDic;
@property(nonatomic, retain) NSString *NCPString;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

- (void)Start_GPS_Delegate;
- (void)Stop_GPS;
- (void)IsExist_LocalLocation_Data;
- (void)Start_Background_On;
- (void)Set_All_Tag:(NSDictionary *)dic; //发送Tag 注册别名
- (void)backgroundHandlerWithFlag:(NSInteger)flag
                    timerInterval:(double)timeInterval; //被动定位
- (BOOL)returnYES; //判断是否选用离线
@end
