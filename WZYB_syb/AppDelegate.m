//
//  AppDelegate.m
//  WZYB_syb
//
//  Created by wzyb on 14-6-5.
//  Copyright (c) 2014年 WZYB. All rights reserved.
//

#import "APService.h"
#import <AudioToolbox/AudioToolbox.h>

#import "BPush.h"
#import "JSONKit.h"
#import "OpenUDID.h"

#import "XGPush.h"
#import "XGSetting.h"

#import "AppDelegate.h"
#import "Function.h"
#import "NdUncaughtExceptionHandler.h"
#import "TabBarViewController.h"
#import "NewMoreViewController.h"
#import "BNCoreServices.h"

#import <ShareSDK/ShareSDK.h>
//第三方平台的SDK头文件，根据需要的平台导入。
//以下分别对应微信、新浪微博、腾讯微博、人人、易信
#import "WXApi.h"
#import "WeiboSDK.h"
#import "WeiboApi.h"
//以下是腾讯QQ和QQ空间
#import <TencentOpenAPI/QQApi.h>
#import <TencentOpenAPI/QQApiInterface.h>
#import <TencentOpenAPI/TencentOAuth.h>

//开启QQ和Facebook网页授权需要
#import <QZoneConnection/ISSQZoneApp.h>
#import <FacebookConnection/ISSFacebookApp.h>

@implementation AppDelegate
@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;
/*个推*/
@synthesize gexinPusher = _gexinPusher;
@synthesize appKey = _appKey;
@synthesize appSecret = _appSecret;
@synthesize appID = _appID;
@synthesize clientId = _clientId;
@synthesize sdkStatus = _sdkStatus;
@synthesize lastPayloadIndex = _lastPaylodIndex;
@synthesize payloadId = _payloadId;

- (void)Baidu_Map
{
    // 要使用百度地图，请先启动BaiduMapManager
    _mapManager = [[BMKMapManager alloc] init];
    // 如果要关注网络及授权验证事件，请设定generalDelegate参数
    BOOL ret = [_mapManager start:Baidu_Key generalDelegate:self];

    //初始化导航SDK
    [BNCoreServices_Instance initServices:Baidu_Key];
    [BNCoreServices_Instance startServicesAsyn:nil fail:nil];

    if (!ret) {
        NSLog(@"manager start failed!");
    }
}

- (void)startSdkWith:(NSString*)appID
              appKey:(NSString*)appKey
           appSecret:(NSString*)appSecret
{
    if (!_gexinPusher) {
        _sdkStatus = SdkStatusStoped;

        self.appID = appID;
        self.appKey = appKey;
        self.appSecret = appSecret;
        _clientId = nil;

        NSError* err = nil;
        _gexinPusher =
            [GexinSdk createSdkWithAppId:_appID
                                  appKey:_appKey
                               appSecret:_appSecret
                              appVersion:[[[NSBundle mainBundle] infoDictionary]
                                             objectForKey:@"CFBundleVersion"]
                                delegate:self
                                   error:&err];

        if (!_gexinPusher) {
        }
        else {
            _sdkStatus = SdkStatusStarting;
        }
    }
}

- (void)stopSdk
{
    if (_gexinPusher) {
        [_gexinPusher destroy];
        //[_gexinPusher release];
        _gexinPusher = nil;

        _sdkStatus = SdkStatusStoped;
        //[_clientId release];
        _clientId = nil;
    }
}

- (void)registerRemoteNotification
{
#ifdef __IPHONE_8_0 //判断IOS SDK
    if (isIOS8) {

        UIUserNotificationSettings* uns = [UIUserNotificationSettings
            settingsForTypes:(UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound)
                  categories:nil];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
        [[UIApplication sharedApplication] registerUserNotificationSettings:uns];
    }
    else {
        UIRemoteNotificationType apn_type = (UIRemoteNotificationType)(
            UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeBadge);
        [[UIApplication sharedApplication]
            registerForRemoteNotificationTypes:apn_type];
    }
#else
    UIRemoteNotificationType apn_type = (UIRemoteNotificationType)(
        UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeBadge);
    [[UIApplication sharedApplication]
        registerForRemoteNotificationTypes:apn_type];
#endif
}

- (void)AllInit
{
    self.taskNumber = 0;
    self.assgNumber = 0;
    self.mesgNumber = 0;
    self.gpsNumber = 0;
    self.backFlag = 0;
    self.backTime = 0;
    self.gpsFlag1 = 0;
    self.applySearch = 0;
    self.gpsFlag2 = 0;
    self.gpsHome = 0;
    self.searchList = 0;
    self.markFlag = 0;
    self.selectFlag = 0;
    self.order_refresh = 0;
    self.gpsHomeActive = 0;
    self.loginFlag = 0;
    self.customerNumber = 0;
    self.str_nlng = @"";
    self.str_alat = @"";
    self.exeString = @"";
    self.customerStr = @"";
    self.BSAddress = @"";
    self.BSAddressStr = @"";
    self.personIndex1 = @"";
    self.personIndex2 = @"";

    self.notifier = 1;
    self.str_printf = nil;
    self.str_alat_alng = @"000.000000 , 00.000000";
    self.str_LocationName = @"";
    self.str_osum = @"";
    self.array_Photo = [NSMutableArray arrayWithCapacity:1];
    self.array_message = [NSMutableArray arrayWithCapacity:1];
    self.arr_location = [NSMutableArray arrayWithCapacity:1];

    self.branchArray = [NSMutableArray array];
    self.typeArray = [NSMutableArray array];
    self.addressArray = [NSMutableArray array];
    self.mutDynDic = [NSMutableArray array];

    self.filepath_LocationList = [Function CreateTheFolder_From:Library_Cache
                                                 FileHolderName:MyFolder
                                                       FileName:Location_List];
    if (isPad) {
        self.Font = 20;
    }
    else {
        self.Font = 16; //正好 统一
    }
}
- (BOOL)application:(UIApplication*)application
    didFinishLaunchingWithOptions:(NSDictionary*)launchOptions
{
    [application setStatusBarHidden:NO];
    [application setStatusBarStyle:UIStatusBarStyleLightContent];
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    if ([ASIHTTPRequest isMultitaskingSupported]) {
        NSLog(@"Multitasking is supported.");
    }
    else {
        NSLog(@"Multitasking is not supported.");
    }
    [NdUncaughtExceptionHandler setDefaultHandler];

    [self Baidu_Map];
    [self AllInit];
    [self GPS_Init];

    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    if (isIPhone5) {
        self.rootVC = [[RootViewController alloc]
            initWithNibName:@"RootViewController_iphone_5"
                     bundle:nil];
    }
    else {
        self.rootVC = [[RootViewController alloc]
            initWithNibName:@"RootViewController_iphone_4"
                     bundle:nil];
    }

    UINavigationController* nav =
        [[UINavigationController alloc] initWithRootViewController:self.rootVC];
    self.window.backgroundColor = [UIColor whiteColor];
    self.window.rootViewController = nav;
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    [application setApplicationIconBadgeNumber:0];
    [self.window makeKeyAndVisible];

    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSString* firstShow = [defaults objectForKey:@"firstShow"];
    if (![firstShow integerValue]) {
        [application setStatusBarHidden:YES];
        [self firstShow];
    }
    else {
        [self comeIntoApp];
    }
    [self PUSH:launchOptions]; //通知start
    [self _initShareSDK];
    return YES;
}

//第一次进入的时候显示的界面
- (void)firstShow
{
    UIScrollView* scrollView = [[UIScrollView alloc]
        initWithFrame:CGRectMake(0, 0, 320,
                          [UIScreen mainScreen].bounds.size.height)];
    scrollView.tag = 333;
    scrollView.bounces = NO;
    [self.window addSubview:scrollView];

    UIImageView* imageView = [[UIImageView alloc] initWithFrame:scrollView.frame];
    imageView.userInteractionEnabled = YES;
    imageView.backgroundColor = [UIColor whiteColor];
    imageView.height = 2844.5;
    imageView.image = ImageName(@"firstPage.png");
    scrollView.contentSize = CGSizeMake(320, imageView.height);
    [scrollView addSubview:imageView];

    UIButton* buttonNever = [UIButton buttonWithType:UIButtonTypeCustom];
    buttonNever.frame = CGRectMake(10, 5, 80, 40);
    buttonNever.titleLabel.font = [UIFont systemFontOfSize:17.0];
    [buttonNever setTitle:@"不再显示" forState:UIControlStateNormal];
    [buttonNever addTarget:self
                    action:@selector(neverShow)
          forControlEvents:UIControlEventTouchUpInside];
    [buttonNever setTitleColor:[UIColor colorWithRed:209.0 / 255.0
                                               green:47 / 255.0
                                                blue:27 / 255.0
                                               alpha:1.0]
                      forState:UIControlStateNormal];
    [imageView addSubview:buttonNever];

    UIButton* buttonTop = [UIButton buttonWithType:UIButtonTypeCustom];
    buttonTop.frame = CGRectMake(250, 5, 80, 40);
    buttonTop.titleLabel.font = [UIFont systemFontOfSize:17.0];
    [buttonTop setTitle:@"跳过" forState:UIControlStateNormal];
    [buttonTop addTarget:self
                  action:@selector(comeIntoApp)
        forControlEvents:UIControlEventTouchUpInside];
    [buttonTop setTitleColor:[UIColor colorWithRed:209.0 / 255.0
                                             green:47 / 255.0
                                              blue:27 / 255.0
                                             alpha:1.0]
                    forState:UIControlStateNormal];
    [imageView addSubview:buttonTop];

    UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(110, 2810, 100, 40);
    button.titleLabel.font = [UIFont systemFontOfSize:17.0];
    [button setTitle:@"进入应用" forState:UIControlStateNormal];
    [button addTarget:self
                  action:@selector(comeIntoApp)
        forControlEvents:UIControlEventTouchUpInside];
    [button setTitleColor:[UIColor colorWithRed:209.0 / 255.0
                                          green:47 / 255.0
                                           blue:27 / 255.0
                                          alpha:1.0]
                 forState:UIControlStateNormal];
    [imageView addSubview:button];
}

//永远不再显示
- (void)neverShow
{
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:@"1" forKey:@"firstShow"];
    [self comeIntoApp];
}

//展示界面之后的企业自定义界面
- (void)comeIntoApp
{
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    UIScrollView* tempScrollView = (UIScrollView*)[self.window viewWithTag:333];

    CATransition* animation = [CATransition animation];
    animation.delegate = self;
    animation.duration = 0.5;
    animation.timingFunction = UIViewAnimationCurveEaseInOut;
    animation.type = @"mapCurl";
    animation.subtype = kCATransitionFromLeft;
    [tempScrollView.layer.superlayer addAnimation:animation forKey:@"animation"];

    [tempScrollView removeFromSuperview];

    if (self.splashScreen == nil) {
        self.splashScreen = [[UIImageView alloc] initWithFrame:self.window.bounds];
    }
    NSString* filepath = [Function
        achieveThe_filepath:[NSString
                                stringWithFormat:@"%@/%@", MyFolder, CompanyLogo]
                       Kind:Library_Cache]; //即使为空也没事
    self.splashScreen.image = [UIImage imageWithContentsOfFile:filepath];

    [self.window addSubview:self.splashScreen];
    [UIView animateWithDuration:3.0
        animations:^{
            self.splashScreen.alpha = 0.999;
        }
        completion:^(BOOL finished) {
            [self.splashScreen removeFromSuperview];
        }];
}

//获取电量
- (float)getBatteryLeve
{
    [[UIDevice currentDevice] setBatteryMonitoringEnabled:YES];
    return [[UIDevice currentDevice] batteryLevel];
}

- (void)loginStateChange:(NSNotification*)notification
{
    UINavigationController* nav = nil;
    BOOL loginSuccess = [notification.object boolValue];
    if (loginSuccess) {
        nav = [[UINavigationController alloc]
            initWithRootViewController:[[TabBarViewController alloc] init]];
    }
    else {
        nav =
            [[UINavigationController alloc] initWithRootViewController:self.rootVC];
    }
    self.window.rootViewController = nav;
}

- (void)Set_All_Tag:(NSDictionary*)dic
{
    //只有信鸽和极光有别名 但是都有tag  个推和百度用客户ID
    //*******************************百度
    user_tel = [dic objectForKey:@"umtel"]; //这个应该是账号 我这里用的是手机号
    NSString* tags;
    if ([[[SelfInf_Singleton sharedInstance]
                .dic_SelfInform objectForKey:@"gbelongto"]
            isEqualToString:@"-1"]) {
        tags = [[SelfInf_Singleton sharedInstance]
                    .dic_SelfInform objectForKey:@"belongto"];
    }
    else {
        tags = [NSString
            stringWithFormat:@"%@,%@_%@",
            [[SelfInf_Singleton sharedInstance]
                                     .dic_SelfInform objectForKey:@"belongto"],
            [[SelfInf_Singleton sharedInstance]
                                     .dic_SelfInform objectForKey:@"belongto"],
            [[SelfInf_Singleton sharedInstance]
                                     .dic_SelfInform objectForKey:@"gbelongto"]];
    }
    NSArray* tagArr = [tags componentsSeparatedByString:@";"];
    [BPush setTags:tagArr];

    //*******************************个推
    if ([[[SelfInf_Singleton sharedInstance]
                .dic_SelfInform objectForKey:@"gbelongto"]
            isEqualToString:@"-1"]) {

        [_gexinPusher
            setTags:[NSArray arrayWithObjects:[[SelfInf_Singleton sharedInstance]
                                                      .dic_SelfInform
                                                  objectForKey:@"belongto"],
                             nil]];
    }
    else {
        [_gexinPusher
            setTags:[NSArray
                        arrayWithObjects:
                            [NSString
                                stringWithFormat:@"%@_%@",
                                [[SelfInf_Singleton sharedInstance]
                                                         .dic_SelfInform
                                                     objectForKey:@"belongto"],
                                [[SelfInf_Singleton sharedInstance]
                                                         .dic_SelfInform
                                                     objectForKey:@"gbelongto"]],
                        [[SelfInf_Singleton sharedInstance]
                                    .dic_SelfInform objectForKey:@"gbelongto"],
                        nil]];
    }

    //*******************************信鸽
    if ([[[SelfInf_Singleton sharedInstance]
                .dic_SelfInform objectForKey:@"gbelongto"]
            isEqualToString:@"-1"]) {
        [XGPush setTag:[[SelfInf_Singleton sharedInstance]
                               .dic_SelfInform objectForKey:@"belongto"]];
    }
    else {
        [XGPush setTag:[[SelfInf_Singleton sharedInstance]
                               .dic_SelfInform objectForKey:@"belongto"]];
        [XGPush setTag:[NSString
                           stringWithFormat:
                               @"%@_%@",
                           [[SelfInf_Singleton sharedInstance]
                                       .dic_SelfInform objectForKey:@"belongto"],
                           [[SelfInf_Singleton sharedInstance]
                                       .dic_SelfInform objectForKey:@"gbelongto"]]];
    }
    [XGPush setAccount:user_tel];

    //*******************************极光
    //获取电话号 作为Jpush的alias(别名)
    NSSet* set;
    if ([[[SelfInf_Singleton sharedInstance]
                .dic_SelfInform objectForKey:@"gbelongto"]
            isEqualToString:@"-1"]) {
        set =
            [NSSet setWithObjects:[[SelfInf_Singleton sharedInstance]
                                          .dic_SelfInform objectForKey:@"belongto"],
                   nil];
    }
    else {
        set = [NSSet
            setWithObjects:
                [[SelfInf_Singleton sharedInstance]
                        .dic_SelfInform objectForKey:@"belongto"],
            [NSString stringWithFormat:
                          @"%@_%@",
                      [[SelfInf_Singleton sharedInstance]
                                  .dic_SelfInform objectForKey:@"belongto"],
                      [[SelfInf_Singleton sharedInstance]
                                  .dic_SelfInform objectForKey:@"gbelongto"]],
            nil];
    }
    [APService setTags:set
                   alias:user_tel
        callbackSelector:@selector(tagsAliasCallback:tags:alias:)
                  target:self];
}
- (void)PUSH:(NSDictionary*)launchOptions
{
    [[UIApplication
            sharedApplication] cancelAllLocalNotifications]; //清除所有通知(包含本地通知)
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;

    //*******************************个推 ->
    //使用APPID/APPKEY/APPSECRENT创建个推实例
    [self startSdkWith:kAppId appKey:kAppKey appSecret:kAppSecret];

    //*******************************BaiduPush
    [BPush setupChannel:launchOptions];
    [BPush setDelegate:self];
    [BPush bindChannel];

    //*******************************信鸽
    [XGPush startApp:2200050894 appKey:@"I3H1LE3T8J8U"];
    void (^successCallback)(void) = ^(void) { //注销之后需要再次注册前的准备
        if (![XGPush isUnRegisterStatus]) { //如果变成需要注册状态
        }
    };
    [XGPush initForReregister:successCallback];

    void (^successBlock)(void) = ^(void) { // success回调
        // Dlog(@"[XGPush]handleLaunching's successBlock");
    };
    void (^errorBlock)(void) = ^(void) { // error回调
        // Dlog(@"[XGPush]handleLaunching's errorBlock");
    };
    [XGPush handleLaunching:launchOptions
            successCallback:successBlock
              errorCallback:errorBlock];

    //*******************************Jpush
    [self registerRemoteNotification]; //四个推送公用

    [APService setupWithOption:launchOptions];
    NSNotificationCenter* defaultCenter = [NSNotificationCenter defaultCenter];
    [defaultCenter addObserver:self
                      selector:@selector(networkDidReceiveMessage:)
                          name:kJPFNetworkDidReceiveMessageNotification
                        object:nil];
    NSNotificationCenter* defaultCenter1 = [NSNotificationCenter defaultCenter];

    [defaultCenter1 addObserver:self
                       selector:@selector(networkDidSetup:)
                           name:kJPFNetworkDidSetupNotification
                         object:nil];
    [defaultCenter1 addObserver:self
                       selector:@selector(networkDidClose:)
                           name:kJPFNetworkDidCloseNotification
                         object:nil];
    [defaultCenter1 addObserver:self
                       selector:@selector(networkDidRegister:)
                           name:kJPFNetworkDidRegisterNotification
                         object:nil];
    [defaultCenter1 addObserver:self
                       selector:@selector(networkDidLogin:)
                           name:kJPFNetworkDidLoginNotification
                         object:nil];
    if (launchOptions != nil) {
        NSDictionary* dictionary = [launchOptions
            objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
        if (dictionary != nil) {
            // Dlog(@"Launched from push notification: %@", dictionary);
            [self addMessageFromRemoteNotification:dictionary];
        }
    }
}

//shareSDK
- (void)_initShareSDK {
    [ShareSDK registerApp:@""];
    
    //开启QQ空间网页授权开关(optional)
    id<ISSQZoneApp> app =(id<ISSQZoneApp>)[ShareSDK getClientWithType:ShareTypeQQSpace];
    [app setIsAllowWebAuthorize:YES];
    
    //开启Facebook网页授权开关(optional)
    id<ISSFacebookApp> facebookApp =(id<ISSFacebookApp>)[ShareSDK getClientWithType:ShareTypeFacebook];
    [facebookApp setIsAllowWebAuthorize:YES];
    
    //添加QQ空间应用  注册网址  http://connect.qq.com/intro/login/
    [ShareSDK connectQZoneWithAppKey:@"100371282"
                           appSecret:@"aed9b0303e3ed1e27bae87c33761161d"
                   qqApiInterfaceCls:[QQApiInterface class]
                     tencentOAuthCls:[TencentOAuth class]];
    
    //添加QQ应用  注册网址  http://mobile.qq.com/api/
    [ShareSDK connectQQWithQZoneAppKey:@"100371282"
                     qqApiInterfaceCls:[QQApiInterface class]
                       tencentOAuthCls:[TencentOAuth class]];
    
    //添加微信应用  http://open.weixin.qq.com
    [ShareSDK connectWeChatWithAppId:@"wx8c8f29e2867c5f6f"
                           appSecret:@"dd6ba3d0934888d65ea940e611cb68b8"
                           wechatCls:[WXApi class]];
}

- (BOOL)application:(UIApplication*)application handleOpenURL:(NSURL*)url
{
    return YES;
}
- (NSUInteger)application:(UIApplication*)application
    supportedInterfaceOrientationsForWindow:(UIWindow*)window
{
    return UIInterfaceOrientationMaskPortrait; //保持竖屏
}

// push start
- (void)applicationDidEnterBackground:(UIApplication*)application
{
    [application setApplicationIconBadgeNumber:0];
    //角标清0
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    self.gpsHome = 1;
    // [EXT] 切后台关闭SDK，让SDK第一时间断线，让个推先用APN推送
    //    [self stopSdk];
}

#pragma Infinite Background
- (void)backgroundHandler
{
    //    self.locationSpace = YES; //这个属性设置再后台定位的时间间隔
    //    自己在定位类中加个定时器就行了
    UIApplication* app = [UIApplication sharedApplication];
    //声明一个任务标记 可在.h中声明为全局的
    __block UIBackgroundTaskIdentifier bgTask;
    bgTask = [app beginBackgroundTaskWithExpirationHandler:^{

        dispatch_async(dispatch_get_main_queue(), ^{
            if (bgTask != UIBackgroundTaskInvalid) {
                bgTask = UIBackgroundTaskInvalid;
            }
        });
    }];
    // 开始执行长时间后台执行的任务 项目中启动后定位就开始了
    // 这里不需要再去执行定位 可根据自己的项目做执行任务调整
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),
        ^{
            // Dlog(@"开始无限后台");
            self.counter = 0; //初始化 只执行一次
            while (self.counter == 0) {
                self.counter = 1;
                self.locService.delegate = self;
                sleep([[[SelfInf_Singleton sharedInstance]
                            .dic_SelfInform
                    objectForKey:@"GprsTimer"] doubleValue]); //休眠时间
                self.counter = 0;
            }
        });
}
- (void)applicationWillEnterForeground:(UIApplication*)application
{
}
#pragma 定位坐标上传策略
//存在本地数据提交
- (void)IsExist_LocalLocation_Data
{
    //    [Function DeleteTheFile:[NSString
    //    stringWithFormat:@"%@/%@",MyFolder,Location_List] Kind:Library_Cache];
    if ([Function judgeFileExist:Location_List Kind:Library_Cache]) {
        NSArray* arr = [NSArray arrayWithContentsOfFile:self.filepath_LocationList];
        if (arr.count > 0) {
            if (arr.count <= Update_Locaion_datas) {
                [self Push_myMoment_GPRS:arr IsFromLocal:@"1"]; //全部
            }
            else {
                NSMutableArray* arr2 = [NSMutableArray arrayWithCapacity:1];
                for (NSInteger i = 0; i < Update_Locaion_datas; i++) {
                    [arr2 addObject:[arr objectAtIndex:i]];
                }
                [self Push_myMoment_GPRS:arr2 IsFromLocal:@"2"]; //分批
            }
        }
        else {
            // Dlog(@"本地无数据");
        }
    }
}

- (void)application:(UIApplication*)application
    didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken
{
    //*******************************极光推送
    [APService registerDeviceToken:deviceToken];
    NSString* token = [[deviceToken description]
        stringByTrimmingCharactersInSet:
            [NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    // Dlog(@"deviceToken:%@", [token stringByReplacingOccurrencesOfString:@" "
    // withString:@""]);

    //*******************************向个推服务器注册deviceToken
    if (_gexinPusher) {
        [_gexinPusher registerDeviceToken:token];
    }
    //*******************************百度推送
    [BPush registerDeviceToken:deviceToken];

    //*******************************信鸽推
    [[XGSetting getInstance] setChannel:@"appstore"];
    [[XGSetting getInstance] setGameServer:@"巨神峰"];
    [XGPush registerDevice:deviceToken];
}
- (void)application:(UIApplication*)application
    didFailToRegisterForRemoteNotificationsWithError:(NSError*)error
{
    // Dlog(@"did Fail To Register For Remote Notifications With Error: %@",
    // error);
    // [3-EXT]:如果APNS注册失败，通知个推服务器
    if (self.gexinPusher) {
        [self.gexinPusher registerDeviceToken:@""];
    }
}

#if __IPHONE_OS_VERSION_MAX_ALLOWED > __IPHONE_7_1 //当前ios版本||>= _IPHONE80_
//注册UserNotification成功的回调
- (void)application:(UIApplication*)application
    didRegisterUserNotificationSettings:
        (UIUserNotificationSettings*)notificationSettings
{
    [application registerForRemoteNotifications];
}
//按钮点击事件回调
- (void)application:(UIApplication*)application
    handleActionWithIdentifier:(NSString*)identifier
          forLocalNotification:(UILocalNotification*)notification
             completionHandler:(void (^)())completionHandler
{
    if ([identifier isEqualToString:@"ACCEPT_IDENTIFIER"]) {
        // Dlog(@"ACCEPT_IDENTIFIER is clicked");
    }
    completionHandler();
}
- (void)application:(UIApplication*)application
    handleActionWithIdentifier:(NSString*)identifier
         forRemoteNotification:(NSDictionary*)userInfo
             completionHandler:(void (^)())completionHandlerr
{
}
#endif

- (void)application:(UIApplication*)application
    didReceiveRemoteNotification:(NSDictionary*)userInfo
          fetchCompletionHandler:
              (void (^)(UIBackgroundFetchResult))completionHandler
{
    [APService handleRemoteNotification:userInfo];

    [self addMessageFromRemoteNotification:userInfo];

    if (![Function isBlankString:[userInfo objectForKey:@"messageType"]]) {
    }
    else {
        IsFromeGexin = YES; //来自个推
    }
    completionHandler(UIBackgroundFetchResultNoData);

    [[UIApplication sharedApplication] cancelAllLocalNotifications];

    //*******************************百度推送
    [BPush handleNotification:userInfo];
    //*******************************信鸽推
    [XGPush handleReceiveNotification:userInfo];
    [application setApplicationIconBadgeNumber:0];
}
- (void)application:(UIApplication*)application
    didReceiveRemoteNotification:(NSDictionary*)userInfo
{
    //推送反馈(app运行时)
    [APService handleRemoteNotification:userInfo];
    [self addMessageFromRemoteNotification:userInfo];
    [BPush handleNotification:userInfo];
    [XGPush handleReceiveNotification:userInfo];
    [application setApplicationIconBadgeNumber:0];
}
- (void)addMessageFromRemoteNotification:(NSDictionary*)userInfo
{
    [self startPlayer1];
    //    NSString *auth=[[SelfInf_Singleton sharedInstance].dic_SelfInform
    //    objectForKey:@"auth"];
    // Dlog(@"推送结果:===%@===",[userInfo objectForKey:@"messageType"]);
    self.is_Jpush = YES;
    if (![Function isBlankString:[userInfo objectForKey:@"messageType"]]) {
        if ([[userInfo objectForKey:@"messageType"]
                isEqualToString:@"task"]) //任务界面刷新数据
        {
            self.New_Task = YES;
            self.mydelegate = (id)self.VC_Task;
            [self.mydelegate Notify_TaskVC];

            self.taskNumber = 0;
            NSUserDefaults* userdefaults1 = [NSUserDefaults standardUserDefaults];
            self.taskNumber = [userdefaults1 integerForKey:NUMBER];
            self.taskNumber++;
            [userdefaults1 setInteger:self.taskNumber forKey:NUMBER];
            [userdefaults1 synchronize];

            self.myNewDelegate = (id)self.quickVC;
            [self.myNewDelegate Notify_quiVC];

            self.myDairlNewDelegate = (id)self.dairyVC;
            [self.myDairlNewDelegate Notify_DaiVC];
        }
        else if ([[userInfo objectForKey:@"messageType"]
                     isEqualToString:@"approve"]) //审批界面刷新数据
        {
            self.New_Ass = YES;

            self.mydelegate = (id)self.VC_Assessment;
            [self.mydelegate Notify_assVC];

            self.assgNumber = 0;
            NSUserDefaults* userdefaults = [NSUserDefaults standardUserDefaults];
            self.assgNumber = [userdefaults integerForKey:NUM_ASG];
            self.assgNumber++;
            [userdefaults setInteger:self.assgNumber forKey:NUM_ASG];
            [userdefaults synchronize];

            self.myNewDelegate = (id)self.qui_AssgVC;
            [self.myNewDelegate Notify_quiVC_Assign];

            self.myDairlNewDelegate = (id)self.dairy_AssgVC;
            [self.myDairlNewDelegate Notify_DaiVC_Assign];
        }
        else
            self.New_msg = YES;
    }
    else {
        self.New_msg = YES;
    }
    if (self.is_msg_open) {
        self.mydelegate = (id)self.VC_msg; // vc
        //指定代理对象为，second
        [self.mydelegate Notify_msgVC];

        self.mesgNumber = 0;
        NSUserDefaults* userdefaults = [NSUserDefaults standardUserDefaults];
        self.mesgNumber = [userdefaults integerForKey:NUM_MES];
        NSLog(@"%ld",(long)self.mesgNumber);
        self.mesgNumber++;
        NSLog(@"%ld",(long)self.mesgNumber);
        [userdefaults setInteger:self.mesgNumber forKey:NUM_MES];
        [userdefaults synchronize];
        NSLog(@"%@",[userdefaults objectForKey:NUM_MES]);

        self.myNewDelegate = (id)self.qui_MesgVC;
        [self.myNewDelegate Notify_quiVC_mesage];

        self.myDairlNewDelegate = (id)self.dairy_MesgVC;
        [self.myDairlNewDelegate Notify_DaiVC_mesage];
    }
    if (self.New_msg || self.New_Ass || self.New_Task) // more界面刷新数据
    {
        self.mydelegate = (id)self.VC_more;
        [self.mydelegate Notify_MoreVC];
    }
    self.mydelegate = nil;
}
- (void)startPlayer1
{
    AudioServicesPlaySystemSound(1007);
    // AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
}
void PlayFinishCallBack1()
{
    // Dlog(@"播放完成");
}

#pragma mark - JPush method
- (void)networkDidReceiveMessage:(NSNotification*)notification
{
    [self Push_MyLocationNow:[notification userInfo]];
    //    NSString *content = [userInfo valueForKey:@"content"];
    //    NSString *extras = [userInfo valueForKey:@"extras"];
    //    NSString *customizeField1 = [extras valueForKey:@"customizeField1"];
    //    //自定义参数，key是自己定义的
}

- (void)networkDidSetup:(NSNotification*)notification
{
}

- (void)networkDidClose:(NSNotification*)notification
{
}
- (void)networkDidRegister:(NSNotification*)notification
{
}

- (void)networkDidLogin:(NSNotification*)notification
{
}
- (void)tagsAliasCallback:(int)iResCode
                     tags:(NSSet*)tags
                    alias:(NSString*)alias
{
}
// push end
- (void)applicationWillResignActive:(UIApplication*)application
{
}

- (void)applicationDidBecomeActive:(UIApplication*)application
{
    [application setApplicationIconBadgeNumber:0];

    if (self.loginFlag && self.gpsHome && !self.gpsHomeActive) {
        [self.locService stopUserLocationService];
    }
    self.loginFlag = 1;
    self.gpsHome = 0;
    self.gpsHomeActive = 1;
    // [EXT] 重新上线
    self.locService.delegate = nil;
    [self startSdkWith:kAppId appKey:kAppKey appSecret:kAppSecret];

    BOOL p = [_audioPlayer isPlaying];
    if (p) {
        return;
    }
    else {
        [_audioPlayer play];
    }
}

- (void)applicationWillTerminate:(UIApplication*)application
{
    [self saveContext];
}

- (void)saveContext
{
    NSError* error = nil;
    NSManagedObjectContext* managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            abort();
        }
    }
}

#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the
// persistent store coordinator for the application.
- (NSManagedObjectContext*)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }

    NSPersistentStoreCoordinator* coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's
// model.
- (NSManagedObjectModel*)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL* modelURL =
        [[NSBundle mainBundle] URLForResource:@"WZYB_syb"
                                withExtension:@"momd"];
    _managedObjectModel =
        [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's
// store added to it.
- (NSPersistentStoreCoordinator*)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }

    NSURL* storeURL = [[self applicationDocumentsDirectory]
        URLByAppendingPathComponent:@"WZYB_syb.sqlite"];
    NSError* error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc]
        initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType
                                                   configuration:nil
                                                             URL:storeURL
                                                         options:nil
                                                           error:&error]) {
        abort();
    }
    return _persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL*)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager]
        URLsForDirectory:NSDocumentDirectory
               inDomains:NSUserDomainMask] lastObject];
}
- (BOOL)isFirstLoad
{
    NSString* currentVersion = [[[NSBundle mainBundle] infoDictionary]
        objectForKey:@"CFBundleShortVersionString"]; // general Version String
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];

    NSString* lastRunVersion = [defaults objectForKey:LAST_RUN_VERSION_KEY];

    if (!lastRunVersion) {
        [defaults setObject:currentVersion forKey:LAST_RUN_VERSION_KEY];
        return YES; // lastRunVersion不存在  说明第一次启动
    }
    else if (![lastRunVersion isEqualToString:currentVersion]) {
        [defaults setObject:currentVersion forKey:LAST_RUN_VERSION_KEY];
        return YES; //改版本之后当前的版本与上一次版本不一样 第一次启动
    }
    return NO; // lastRunVersion == currentVersion
}
#pragma mark - BPushDelegate
- (void)onMethod:(NSString*)method response:(NSDictionary*)data
{
    NSDictionary* res = [[NSDictionary alloc] initWithDictionary:data];
    if ([BPushRequestMethod_Bind isEqualToString:method]) {
        NSString* appid = [res valueForKey:BPushRequestAppIdKey];
        NSString* userid = [res valueForKey:BPushRequestUserIdKey];
        NSString* channelid = [res valueForKey:BPushRequestChannelIdKey];
        // NSString *requestid = [res valueForKey:BPushRequestRequestIdKey];
        NSInteger returnCode =
            [[res valueForKey:BPushRequestErrorCodeKey] intValue];

        if (returnCode == BPushErrorCode_Success) {

            // 在内存中备份，以便短时间内进入可以看到这些值，而不需要重新bind
            self.baidu_appId = appid;
            self.baidu_channelId = channelid;
            self.baidu_userId = userid;
        }
        else {
            // Dlog(@"百度推送有错%d",returnCode);
        }
    }
    else if ([BPushRequestMethod_Unbind isEqualToString:method]) {
        NSInteger returnCode =
            [[res valueForKey:BPushRequestErrorCodeKey] intValue];
        if (returnCode == BPushErrorCode_Success) {
        }
        else {
            // Dlog(@"百度推送有错%d",returnCode);
        }
    }
}
- (void)Push_MyLocationNow:(NSDictionary*)dict
{
    self.gpsNumber = 1;
    [self.locService startUserLocationService];
    self.locService.delegate = self;
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication*)application
{
    /*
   Free up as much memory as possible by purging cached data objects that can be
   recreated (or reloaded from disk) later.
   */
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
}
#pragma mark - GexinSdkDelegate
- (void)GexinSdkDidRegisterClient:(NSString*)clientId
{
    // [4-EXT-1]: 个推SDK已注册
    _sdkStatus = SdkStatusStarted;
    //[_clientId release];
    _clientId = clientId;
    // Dlog(@"%@",clientId);
    //    [self stopSdk];
}
- (void)GexinSdkDidReceivePayload:(NSString*)payloadId
                  fromApplication:
                      (NSString*)
                          appId
{ // when click the YES  the action carry out
    // [4]: 收到个推消息
    //  [_payloadId release];
    /*
   {
   aps =     {
   alert =         {
   body = "\U65b0\U4efb\U52a1:\U66f4\U5065\U5eb7\U770b\U770b\U4f60\U4f60\U5bb6";
   };
   badge = 1;
   sound = default;
   };
   payload = "messageType:task";
   }  最后结果是messageType:task
   */
    IsFromeGexin = NO;
    _payloadId = payloadId;
    NSData* payload = [_gexinPusher retrivePayloadById:payloadId];
    NSString* payloadMsg = nil;
    if (payload) {
        payloadMsg =
            [[NSString alloc] initWithData:payload
                                  encoding:NSUTF8StringEncoding];
        NSDictionary* dic;
        if ([payloadMsg isEqualToString:@"messageType:task"]) {
            dic = [NSDictionary
                dictionaryWithObjects:[NSArray arrayWithObjects:@"task", nil]
                              forKeys:[NSArray arrayWithObjects:@"messageType", nil]];
        }
        else if ([payloadMsg isEqualToString:@"messageType:approve"]) {
            dic = [NSDictionary
                dictionaryWithObjects:[NSArray arrayWithObjects:@"approve", nil]
                              forKeys:[NSArray arrayWithObjects:@"messageType", nil]];
        }
        else {
            dic = [NSDictionary
                dictionaryWithObjects:[NSArray arrayWithObjects:@"message", nil]
                              forKeys:[NSArray arrayWithObjects:@"messageType", nil]];
        }
        [self addMessageFromRemoteNotification:dic];
    }
}

- (void)GexinSdkDidSendMessage:(NSString*)messageId result:(int)result
{
    // [4-EXT]:发送上行消息结果反馈
    //    NSString *record = [NSString stringWithFormat:@"Received sendmessage:%@
    //    result:%d", messageId, result];
    // Dlog(@"%@",record);
}

- (void)GexinSdkDidOccurError:(NSError*)error
{
    // [EXT]:个推错误报告，集成步骤发生的任何错误都在这里通知，如果集成后，无法正常收到消息，查看这里的通知。
    // Dlog(@"%@",[NSString stringWithFormat:@">>>[GexinSdk error]:%@", [error
    // localizedDescription]]);
}

#pragma mark---- other method
- (void)GPS_Init
{
    if (isIOS8) {
        //由于IOS8中定位的授权机制改变 需要进行手动授权
        locationManager = [[CLLocationManager alloc] init];
        //获取授权认证(永久授权)
        [locationManager requestAlwaysAuthorization];
        [locationManager requestWhenInUseAuthorization];
    }
    [locationManager startUpdatingLocation];
    self.locService = [[BMKLocationService alloc] init];
    self.isFirstStart_Infinite_Background = YES;
}

- (void)Start_Background_On
{
    if (![ASIHTTPRequest isMultitaskingSupported]) {
        return;
    }
    [self backgroundHandler];
}
- (void)Start_GPS_Delegate
{
    self.locService.delegate = self;
}
#pragma 主动定位
- (void)didUpdateBMKUserLocation:(BMKUserLocation*)userLocation
{
    if (self.gpsNumber == 1) {
        //透传
        self.gpsNumber = 0;

        if ([Function isConnectionAvailable]) {
            NSString* string;
            if (self.isPortal) {
                string = [NSString stringWithFormat:@"%@%@", KPORTAL_URL, KReply_myGPS];
            }
            else {
                string = [NSString stringWithFormat:@"%@%@", kBASEURL, KReply_myGPS];
            }

            NSURL* url = [NSURL URLWithString:string];
            ASIFormDataRequest* request = [ASIFormDataRequest requestWithURL:url];
            request.delegate = self;
            [request setRequestMethod:@"POST"];

            [request setPostValue:[[SelfInf_Singleton sharedInstance]
                                          .dic_SelfInform objectForKey:@"account"]
                           forKey:KUSER_UID];
            [request setPostValue:[[SelfInf_Singleton sharedInstance]
                                          .dic_SelfInform objectForKey:@"secret"]
                           forKey:KUSER_PASSWORD];
            [request setPostValue:[[SelfInf_Singleton sharedInstance]
                                          .dic_SelfInform objectForKey:@"token"]
                           forKey:@"user.token"];
            [request setPostValue:[[SelfInf_Singleton sharedInstance]
                                          .dic_SelfInform objectForKey:@"db_ip"]
                           forKey:@"db_ip"];
            [request setPostValue:[[SelfInf_Singleton sharedInstance]
                                          .dic_SelfInform objectForKey:@"db_name"]
                           forKey:@"db_name"];

            [request
                setPostValue:[NSString stringWithFormat:@"%f", [self getBatteryLeve]]
                      forKey:@"power"];
            [request
                setPostValue:[NSString stringWithFormat:@"%f", userLocation.heading
                                                                   .trueHeading]
                      forKey:@"direction"];
            [request
                setPostValue:[NSString
                                 stringWithFormat:@"%f", userLocation.location.speed]
                      forKey:@"speed"];
            [request
                setPostValue:[NSString
                                 stringWithFormat:@"%f", userLocation.location
                                                             .coordinate.longitude]
                      forKey:@"glng"];
            [request setPostValue:[NSString stringWithFormat:@"%f",
                                            userLocation.location
                                                .coordinate.latitude]
                           forKey:@"glat"];
            [request startAsynchronous]; //异步
        }
        self.locService.delegate = nil;
        return;
    }

    if (self.backFlag == 1) {
        self.backFlag = 0;
        //被动定位
        if (userLocation.location.coordinate.latitude == 0.0 || userLocation.location.coordinate.longitude == 0.0) {
            return;
        }

        NSString* string;
        if (self.isPortal) {
            string = [NSString stringWithFormat:@"%@%@", KPORTAL_URL, KReply_myGPS];
        }
        else {
            string = [NSString stringWithFormat:@"%@%@", kBASEURL, KReply_myGPS];
        }

        NSURL* url = [NSURL URLWithString:string];
        ASIFormDataRequest* request = [ASIFormDataRequest requestWithURL:url];
        request.delegate = self;
        request.tag = 102;
        [request setRequestMethod:@"POST"];

        [request setPostValue:[[SelfInf_Singleton sharedInstance]
                                      .dic_SelfInform objectForKey:@"account"]
                       forKey:KUSER_UID];
        [request setPostValue:[[SelfInf_Singleton sharedInstance]
                                      .dic_SelfInform objectForKey:@"secret"]
                       forKey:KUSER_PASSWORD];
        [request setPostValue:[[SelfInf_Singleton sharedInstance]
                                      .dic_SelfInform objectForKey:@"token"]
                       forKey:@"user.token"];
        [request setPostValue:[[SelfInf_Singleton sharedInstance]
                                      .dic_SelfInform objectForKey:@"db_ip"]
                       forKey:@"db_ip"];
        [request setPostValue:[[SelfInf_Singleton sharedInstance]
                                      .dic_SelfInform objectForKey:@"db_name"]
                       forKey:@"db_name"];

        [request setPostValue:[NSString stringWithFormat:@"%lf",
                                        userLocation.location
                                            .coordinate.longitude]
                       forKey:@"glng"];
        [request setPostValue:[NSString
                                  stringWithFormat:@"%lf", userLocation.location
                                                               .coordinate.latitude]
                       forKey:@"glat"];
        [request
            setPostValue:[NSString stringWithFormat:@"%f", [self getBatteryLeve]]
                  forKey:@"power"];
        [request setPostValue:[NSString stringWithFormat:@"%f", userLocation.heading
                                                                    .trueHeading]
                       forKey:@"direction"];
        [request setPostValue:[NSString stringWithFormat:@"%f", userLocation
                                                                    .location.speed]
                       forKey:@"speed"];
        [request startAsynchronous];

        self.locService.delegate = nil;
        return;
    }

    //主动定位
    // Dlog(@"开始刷代理");
    if (userLocation.location.coordinate.latitude == 0.0 || userLocation.location.coordinate.longitude == 0.0) {
        return;
    }
    self.locService.delegate = nil;
    NSMutableDictionary* dic = [NSMutableDictionary dictionaryWithCapacity:1];
    [dic setObject:[NSString stringWithFormat:@"%lf", userLocation.location
                                                          .coordinate.latitude]
            forKey:@"alat"];
    [dic setObject:[NSString stringWithFormat:@"%lf", userLocation.location
                                                          .coordinate.longitude]
            forKey:@"alng"];
    [dic setObject:[Function getSystemTimeNow] forKey:@"atime"];
    [self.arr_location addObject:dic];
    self.str_alat_alng = [NSString
        stringWithFormat:@"%lf,%lf", userLocation.location.coordinate.longitude,
        userLocation.location.coordinate.latitude];

    if (self.arr_location.count >=
        [[[SelfInf_Singleton sharedInstance]
                .dic_SelfInform objectForKey:@"GprsPostTimer"] integerValue]) {
        //当记录坐标次数大于等于“5”次 提交
        self.locService.delegate = nil;
        NSMutableArray* arr =
            [NSMutableArray arrayWithArray:self.arr_location]; //深复制 影子数据
        [self Push_myMoment_GPRS:arr IsFromLocal:@"0"];
        [self.arr_location
                removeAllObjects]; //删除处理 不然会由于异步数据更新不及时
        //或者会出现再次定位时候对self.arr_location
        //争夺发生的崩溃
    }
}

#pragma 数据提交
- (void)Push_myMoment_GPRS:(NSArray*)arr
               IsFromLocal:
                   (NSString*)flag // 0  1  2 0--在线 1 全部文件 2--部分文件
{
    self.tempArray = arr;
    self.tempString = flag;
    if ([Function isConnectionAvailable]) {
        self.tempString1 =
            [NSString stringWithFormat:@"%@%@", kBASEURL, KReply_myMoment_GPRS];
        NSURL* url = [NSURL URLWithString:self.tempString1];
        ASIFormDataRequest* request = [ASIFormDataRequest requestWithURL:url];
        request.delegate = self;
        request.tag = 100;
        [request setRequestMethod:@"POST"];
        [request setPostValue:[[SelfInf_Singleton sharedInstance]
                                      .dic_SelfInform objectForKey:@"account"]
                       forKey:KUSER_UID];
        [request setPostValue:[[SelfInf_Singleton sharedInstance]
                                      .dic_SelfInform objectForKey:@"secret"]
                       forKey:KUSER_PASSWORD];
        [request setPostValue:[[SelfInf_Singleton sharedInstance]
                                      .dic_SelfInform objectForKey:@"token"]
                       forKey:@"user.token"];
        [request setPostValue:[[SelfInf_Singleton sharedInstance]
                                      .dic_SelfInform objectForKey:@"db_ip"]
                       forKey:@"db_ip"];
        [request setPostValue:[[SelfInf_Singleton sharedInstance]
                                      .dic_SelfInform objectForKey:@"db_name"]
                       forKey:@"db_name"];
        ////
        [request setPostValue:[[SelfInf_Singleton sharedInstance]
                                      .dic_SelfInform objectForKey:@"account"]
                       forKey:KUSER_UID];

        for (NSInteger i = 0; i < arr.count; i++) { // alat  alng  address
            NSDictionary* dic_loc = [arr objectAtIndex:i];
            [request setPostValue:[dic_loc objectForKey:@"alng"]
                           forKey:[NSString stringWithFormat:@"postList[%ld].alng",
                                            (long)i]];
            [request setPostValue:[dic_loc objectForKey:@"alat"]
                           forKey:[NSString stringWithFormat:@"postList[%ld].alat",
                                            (long)i]];
            [request
                setPostValue:[dic_loc objectForKey:@"atime"]
                      forKey:[NSString
                                 stringWithFormat:@"postList[%ld].access_start_date",
                                 (long)i]];
        }
        [request startAsynchronous];
    }
    else {
        // Dlog(@"无网络连接处理");
        if ([flag isEqualToString:@"0"]) { // online
            [self Save_Online_data:arr];
        }
    }
}
//存储在线数据组
- (void)Save_Online_data:(NSArray*)arr_Online
{
    //存储每一组记录
    dispatch_async(
        dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSMutableArray* arr_moment = [NSMutableArray arrayWithCapacity:1];
            if ([NSArray arrayWithContentsOfFile:self.filepath_LocationList]
                    .count != 0) {
                [arr_moment
                    addObjectsFromArray:
                        [NSArray arrayWithContentsOfFile:self.filepath_LocationList]];
            }
            [arr_moment addObjectsFromArray:arr_Online];
            [Function DeleteTheFile:[NSString stringWithFormat:@"%@/%@", MyFolder,
                                              Location_List]
                               Kind:Library_Cache];
            [Function creatTheFile:Location_List Kind:Library_Cache];
            [Function WriteToFile:Location_List File:arr_moment Kind:Library_Cache];
        });
}
- (void)Stop_GPS
{
    self.counter = 100;
    self.counter1 = 100;
    self.locService.delegate = nil;
    [self.locService stopUserLocationService];
}

#pragma mark---- 被动定位无线后台
- (void)backgroundHandlerWithFlag:(NSInteger)flag
                    timerInterval:(double)timeInterval
{
    if (flag == 1) {
        dispatch_queue_t dispatchQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        dispatch_async(dispatchQueue, ^(void) {
            //从budle路径下读取音频文件　　轻音乐 - 萨克斯回家
            //这个文件名是你的歌曲名字,mp3是你的音频格式
            NSString* string =
                [[NSBundle mainBundle] pathForResource:@"nosound"
                                                ofType:@"mp3"];
            //把音频文件转换成url格式
            NSURL* url = [NSURL fileURLWithPath:string];
            //初始化音频类 并且添加播放文件
            _audioPlayer =
                [[AVAudioPlayer alloc] initWithContentsOfURL:url
                                                       error:nil];

            if (_audioPlayer != nil) {
                _audioPlayer.delegate = self;

                [_audioPlayer setNumberOfLoops:-1]; //循环播放
                if ([_audioPlayer prepareToPlay] && [_audioPlayer play]) {
                }
                else {
                }

                NSError* audioSessionError = nil;
                AVAudioSession* audioSession = [AVAudioSession sharedInstance];
                //静音状态下播放
                [audioSession setActive:YES error:nil];
                //设置代理 可以处理电话打进时中断音乐播放

                if ([audioSession setCategory:AVAudioSessionCategoryPlayback
                                        error:&audioSessionError]) {
                }
                else {
                }

                //添加通知，拔出耳机后暂停播放
                [[NSNotificationCenter defaultCenter]
                    addObserver:self
                       selector:@selector(audioSessionInterrupted:)
                           name:AVAudioSessionInterruptionNotification
                         object:nil];
                for (;;) {
                    self.backFlag = 1;
                    self.locService.delegate = self;
                    [self.locService startUserLocationService];
                    sleep(timeInterval); //阻塞 代替NSTimer
                    // music no-limit gps monitor flag(0:stop 1:run)
                    if (self.gpsFlag2 == 0) {
                        NSLog(@"Stopped the no-limit gps monitor.");
                        break;
                    }
                }
            }
            else {
            }
        });
    }
}

- (void)audioSessionInterrupted:(NSNotification*)notification
{
    NSDictionary* interruptionDictionary = [notification userInfo];
    NSNumber* interruptionType = (NSNumber*)
        [interruptionDictionary valueForKey:AVAudioSessionInterruptionTypeKey];
    if ([interruptionType intValue] == AVAudioSessionInterruptionTypeBegan) {

        [self pause_music];
    }
    else if ([interruptionType intValue] == AVAudioSessionInterruptionTypeEnded) {

        [self play_music];
    }
    else {
    }
}

- (void)pause_music
{
    AVAudioSession* audioSession = [AVAudioSession sharedInstance];
    [audioSession setActive:NO error:nil];
    [audioSession setCategory:AVAudioSessionCategoryPlayback error:nil];
    [_audioPlayer pause];
}

- (void)play_music
{
    AVAudioSession* audioSession = [AVAudioSession sharedInstance];
    [audioSession setActive:YES error:nil];
    [audioSession setCategory:AVAudioSessionCategoryPlayback error:nil];
    // BOOL ptp = [_audioPlayer prepareToPlay];
    BOOL p = [_audioPlayer play];
    if (p) {
    }
    else {
    }
}

- (void)func:(NSDictionary*)dic
{
    self.backTime++;
    UILocalNotification* notification = [[UILocalNotification alloc] init];
    if (notification != nil) {
        NSDate* now = [NSDate new];
        notification.fireDate = [now dateByAddingTimeInterval:0]; // 10秒后通知
        notification.repeatInterval = 0; //循环次数，kCFCalendarUnitWeekday一周一次
        notification.timeZone = [NSTimeZone defaultTimeZone];
        notification.soundName = UILocalNotificationDefaultSoundName; //声音，可以换成alarm.soundName =
        //@"myMusic.caf"
        //去掉下面2行就不会弹出提示框
        notification.alertBody = [NSString
            stringWithFormat:@"上传次数:%ld 提交坐标:%@,%@",
            (long)self.backTime, [dic objectForKey:@"glng"],
            [dic objectForKey:@"alat"]]; //提示信息 弹出提示框
        notification.alertAction = @"打开"; //提示框按钮
        [[UIApplication sharedApplication] scheduleLocalNotification:notification];
    }
    notification = nil;
}

- (void)requestFinished:(ASIHTTPRequest*)request
{
    if (request.tag == 100) {
        if ([request responseStatusCode] == 200) {
            SBJsonParser* pause = [[SBJsonParser alloc] init];
            __block NSDictionary* dict =
                [pause objectWithString:[request responseString]];
            if ([[dict objectForKey:@"ret"] isEqualToString:@"0"]) {
                if ([self.tempString isEqualToString:@"0"]) //在线提交数据
                {
                    [self IsExist_LocalLocation_Data];
                }
                else if ([self.tempString isEqualToString:@"1"]) {
                    [Function DeleteTheFile:[NSString stringWithFormat:@"%@/%@", MyFolder,
                                                      Location_List]
                                       Kind:Library_Cache];
                }
                else { // part  2
                    NSMutableArray* applist = [[[NSMutableArray alloc]
                        initWithContentsOfFile:self.filepath_LocationList] mutableCopy];
                    [applist removeObjectsInArray:self.tempArray]; //移除指定数组中元素
                    [applist writeToFile:self.filepath_LocationList atomically:YES];

                    [self IsExist_LocalLocation_Data];
                }
                self.str_printf = @"1";
            }
            else {
                if ([self.tempString isEqualToString:@"0"]) {
                    [self Save_Online_data:self.tempArray]; //深复制
                }
            }
            dict = nil;
        }
        else {
            [self Save_Online_data:self.tempArray]; //深复制
            [NdUncaughtExceptionHandler
                Post_url:[NSString
                             stringWithFormat:@"CompletionBlock URL:%@,HTTPCode%d",
                             self.tempString1,
                             [request responseStatusCode]]];
        }
    }
}

- (void)requestFailed:(ASIHTTPRequest*)request
{
    if (request.tag == 100) {
        [self Save_Online_data:self.tempArray];
        [NdUncaughtExceptionHandler
            Post_url:[NSString stringWithFormat:@"FailedBlock URL:%@,HTTPCode%d",
                               self.tempString1,
                               [request responseStatusCode]]];
    }
}

- (void)audioPlayerEndInterruption:(AVAudioPlayer*)player
                       withOptions:(NSUInteger)flags
{
    if (flags == AVAudioSessionInterruptionFlags_ShouldResume && player != nil) {
        [player play];
    }
}

- (BOOL)returnYES
{
    NSUserDefaults* userdefaults = [NSUserDefaults standardUserDefaults];
    NSString* offLineStr = [userdefaults objectForKey:@"OFFLINE"];
    if ([offLineStr isEqualToString:@"1"]) {
        return YES;
    }
    return NO;
}

@end
