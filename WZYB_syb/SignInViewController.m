//
//  SignInViewController.m
//  WZYB_syb
//
//  Created by wzyb on 14-6-27.
//  Copyright (c) 2014年 WZYB. All rights reserved.
//

#import "SignInViewController.h"
#import "AddNewClerkOrRivalViewController.h"
#import "AppDelegate.h"

#import "KGModal.h"
#import <QuartzCore/QuartzCore.h>
#import "PresentView.h"

#define menu_sub 0
@interface SignInViewController ()<MyDelegate_OrderListView,zbarNewViewDelegate,PresentViewDelegate>
{
    AppDelegate *app;
    NSString *urlString;
    NSString *myType;
    NSDictionary *convertDic;
}
@property (weak, nonatomic) IBOutlet UIButton *matterBtn;
- (IBAction)matterButtonAction:(id)sender;

@end

@implementation SignInViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
#pragma mark  MyDelegate
-(void)Notify_OrderListView
{
 
}

- (void)viewDidLoad
{
    if (isIOS8) {
        //由于IOS8中定位的授权机制改变 需要进行手动授权
        locationManager = [[CLLocationManager alloc] init];
        //获取授权认证
        [locationManager requestAlwaysAuthorization];
        [locationManager requestWhenInUseAuthorization];
    }
    app=(AppDelegate *)[[UIApplication sharedApplication]delegate];
    isReQR=NO;
    [super viewDidLoad]; 
    [self All_Init];
    [self theMenu];//构建菜单明细
    [locService startUserLocationService];
    
    self.qr_getCustomer.str_gmemo=@"";//签退测试备注
    button_CloseMenu.backgroundColor=[UIColor clearColor];
    if([self.str_isFrom_More isEqualToString:@"2"])
    {//考勤
        isFirstOpenQR=YES;
        button_onlineList.hidden=YES;
        account_index=0;
        isReQR=YES;
        self.qr_getCustomer.str_atu = self.atuString;
        if (self.qr_getCustomer.str_atu.length) {
            [self SubmitTheQR_Inform:self.qr_getCustomer.str_atu];
        }
    }
    else
    {//巡访签到
        if(self.is_QR)//是扫二维码进来的吗
        {
            isFirstOpenQR=YES;
            account_index=0;
            isReQR=YES;
            self.qr_getCustomer.str_atu = self.atuString;
            [self SubmitTheQR_Inform:self.atuString];
            
//            [self CreateTheQR];//第一次扫二维码
        }
        else
        {
            //点击列表之后进入下面搜索出来的公司调用的方法
            isFirstOpenQR=NO;
            [self SubmitTheQR_Inform:app.str_atu];
            //app.str_atu http://115.28.188.245/syb/ad.html?actionId=sign&belongto=1&atu=482bd57ea95bb42cc15c82d63af42ea920051
        }
    }
    str_auth=[[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"auth"];//用户权限级别
    /*
     网络交互 返回json
     1:发送二维码得终端信息
     0:签到
     2:签退
     3:在线下订单
     */
    /*
     提交的内容 有两条填写的假数据
     1. 我当前所在的位置
     2.备注内容
     3.测试距离的 我填写了 0
     */
     /*
     
     判断签到地点是不是本部门  gbelong
     gtype=1
     如果签到地点 gbelong 和selfInfo gbelong 比较判断
     if(gtype==1)//巡店
     {
         if（gbelong==gbelong）//判断是不是本部门
        {
           是本部门 四个按钮都可用 //签到 签退 label超链接 还有在线下单四个按钮
        }
        else
        {
            只可以重扫码 //只能扫描本部门的二维码
        }
     }
     else if(gtype==2)//考勤 签到
     {
     
     }
     */
}
-(void)viewWillAppear:(BOOL)animated
{
    if (app.backToSign) {
        app.backToSign = 0;
        isFirstOpenQR=NO;
        if ([self.str_isFrom_More isEqualToString:@"1"]) {
            [self SubmitTheQR_Inform:app.str_atu];
        }else {
            [self SubmitTheQR_Inform:self.atuString];
        }
    }
    if(isReNotQR)
    {
        isReNotQR=NO;
        locService.delegate = self;
        [locService startUserLocationService];
        [self SubmitTheQR_Inform:app.str_atu];
    }
    if(isReQR)
    {
        isReQR=NO;
        [locService startUserLocationService];
    }
}
-(void)viewWillDisappear:(BOOL)animated
{
    [mapView viewWillDisappear];
    [locService stopUserLocationService];
    [self stop];
}
-(void)All_Init
{
    app.str_alat=@"";
    app.str_nlng=@"";
    app.str_LocationName=@"";

    self.qr_getCustomer=[[QR_GetCustomer alloc]init];
    annotation1 = [[BMKPointAnnotation alloc]init];//火柴头初始化
    if(StatusBar_System>0)
        moment_status=20;
    else moment_status=0;
    distance=[[[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"GpsDistance"]integerValue];
    //处理导航start
    NavView *nav_View=[[NavView alloc]init];
    [self.view addSubview: [nav_View NavView_Title1:@"位置"]];
    //返回按钮
    UIButton *btn =[UIButton buttonWithType:UIButtonTypeCustom];
    btn .frame=CGRectMake(0, moment_status, 60, 44);
    [btn setBackgroundImage:[UIImage imageNamed:@"btn_color6.png"] forState:UIControlStateHighlighted];
    [btn setTitle:@"< 返回" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    btn.titleLabel.font=[UIFont systemFontOfSize:15];
    btn.backgroundColor=[UIColor clearColor];
    btn.tag=buttonTag+5;
    [btn addTarget:self action:@selector(btn_Action:) forControlEvents:UIControlEventTouchUpInside];
    [nav_View.view_Nav  addSubview:btn];
    //重扫二维码
    button_Re_QR=[UIButton buttonWithType:UIButtonTypeCustom];
    button_Re_QR.tag=buttonTag+1;
    [button_Re_QR addTarget:self action:@selector(btn_Action:) forControlEvents:UIControlEventTouchUpInside ];
    button_Re_QR.frame=CGRectMake(Phone_Weight-100,moment_status, 100, 44);
    [nav_View.view_Nav addSubview:button_Re_QR];
    [button_Re_QR setBackgroundImage:[UIImage imageNamed:@"btn_color6.png"] forState:UIControlStateHighlighted];
    [button_Re_QR setTitle:@"重新确认终端" forState:UIControlStateNormal];
    [button_Re_QR setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    button_Re_QR.titleLabel.font=[UIFont systemFontOfSize:15];
    //处理导航end
    //处理弹出菜单规格start
    btn_Width=60;
    btn_Height=35;
    
    //处理弹出菜单规格end
    //初始化百度地图start
    mapView = [[BMKMapView alloc]init ];
    mapView.frame=CGRectMake(0, moment_status+44, Phone_Weight, Phone_Height-(moment_status+44));
    
    [self.view addSubview:mapView];
    locService=[[BMKLocationService alloc]init];
    
    button_toSignClerk=[UIButton buttonWithType:UIButtonTypeCustom];
    button_toSignClerk.backgroundColor=[UIColor clearColor];
    [button_toSignClerk addTarget:self action:@selector(ToSignClerK) forControlEvents:UIControlEventTouchUpInside];
    [button_toSignClerk setBackgroundImage:[UIImage imageNamed:@"nav_menu_arrow_back1.png"] forState:UIControlStateHighlighted];
    
    //重新定位
    btn_update=[UIButton buttonWithType:UIButtonTypeCustom];
    btn_update.frame=CGRectMake(Phone_Weight-44, moment_status+44+20, 44, 44);
    btn_update.backgroundColor=[UIColor clearColor];
    [btn_update setBackgroundImage:[UIImage imageNamed:@"baidu_again@2X.png"] forState:UIControlStateNormal];
    [self.view addSubview: btn_update];
    [btn_update addTarget:self action:@selector(Update_GPS) forControlEvents:UIControlEventTouchUpInside];
    
    reader = [ZbarCustomVC getSingle];  //1.0.4
    reader.zbarDelegate = self;
    
    btn_update1=[UIButton buttonWithType:UIButtonTypeCustom];
    btn_update1.frame=CGRectMake(Phone_Weight-50, moment_status+44+20, 44, 44);
    btn_update1.backgroundColor=[UIColor clearColor];
    [btn_update1 setBackgroundImage:[UIImage imageNamed:@"baidu_again.png"] forState:UIControlStateNormal];
    [btn_update1 addTarget:self action:@selector(Update_GPS1) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview: btn_update1];
}

-(void)Update_GPS1
{
    [locService stopUserLocationService];
    locService=nil;
    locService=[[BMKLocationService alloc]init];
    [locService startUserLocationService];
    mapView.delegate = self; // 此处记得不用的时候需要置nil，否则影响内存的释放
    locService.delegate = self;
    [mapView reloadInputViews];
    [self.view insertSubview:mapView atIndex:0];
    isUpdate=YES;
}

-(void)Update_GPS
{
    account_index=0;
    [locService stopUserLocationService];
    locService=nil;
    locService=[[BMKLocationService alloc]init];
    [locService startUserLocationService];
    mapView.delegate = self; // 此处记得不用的时候需要置nil，否则影响内存的释放
    locService.delegate = self;
    [mapView reloadInputViews];
    [self.view insertSubview:mapView atIndex:0];
    isUpdate=YES;
}
-(void)ShowTheLocation
{
    //显示终端
    [mapView removeAnnotation:annotation1] ;
    CLLocationCoordinate2D coor;
    coor.latitude =[self.qr_getCustomer.str_glat doubleValue] ;//纬度
    coor.longitude =[self.qr_getCustomer.str_glng doubleValue];
    mapView.centerCoordinate=coor;
    annotation1.coordinate = coor;
    mapView.zoomLevel=BaiduMap_level;
    annotation1.title = self.qr_getCustomer.str_gname;
    [mapView addAnnotation:annotation1];
}
-(void)Calculate_Destination_Latitude:(double)XX Longitude:(double)YY
{
    CLLocationCoordinate2D c1;//定的我所在的位置
    c1.latitude=[self.qr_getCustomer.str_glat doubleValue];
    c1.longitude=[self.qr_getCustomer.str_glng doubleValue];
    BMKMapPoint mp1=BMKMapPointForCoordinate(c1);
    CLLocationCoordinate2D c2;
    c2.latitude=XX;
    c2.longitude=YY;
    BMKMapPoint mp2=BMKMapPointForCoordinate(c2);
    
    CLLocationDistance dis=BMKMetersBetweenMapPoints(mp1, mp2);
    self.qr_getCustomer.str_dist=[NSString stringWithFormat:@"%.0f",dis];
    //Dlog(@"x:%lf,y:%lf",mp1.x,mp1.y);
    //Dlog(@"x:%lf,y:%lf",mp2.x,mp2.y);
    self.qr_getCustomer.str_new_lat=[NSString stringWithFormat:@"%lf",XX];
    self.qr_getCustomer.str_new_lng=[NSString stringWithFormat:@"%lf",YY];
    //Dlog(@"dis:%@",self.qr_getCustomer.str_dist);
    if(isUpdate)
    {
        isUpdate=NO;
        mapView.centerCoordinate=c1;
    }
    if(account_index<2)
    {
        if([self.self.qr_getCustomer.str_dist floatValue]/1000.0<2)
        {
            mapView.zoomLevel=BaiduMap_level-1;
        }
        else if([self.self.qr_getCustomer.str_dist floatValue]/1000.0<4)
        {
            mapView.zoomLevel=BaiduMap_level-2;
        }
        else if([self.self.qr_getCustomer.str_dist floatValue]/1000.0<8)
        {
            mapView.zoomLevel=BaiduMap_level-3;
        }
        else if([self.self.qr_getCustomer.str_dist floatValue]/1000.0<12)
        {
            mapView.zoomLevel=BaiduMap_level-4;
        }
        else if([self.self.qr_getCustomer.str_dist floatValue]/1000.0<16)
        {
            mapView.zoomLevel=BaiduMap_level-5;
        }
        else if([self.self.qr_getCustomer.str_dist floatValue]/1000.0<20)
        {
            mapView.zoomLevel=BaiduMap_level-6;
        }
        else if([self.self.qr_getCustomer.str_dist floatValue]/1000.0<24)
        {
            mapView.zoomLevel=BaiduMap_level-7;
        }
        else if([self.self.qr_getCustomer.str_dist floatValue]/1000.0<28)
        {
            mapView.zoomLevel=BaiduMap_level-8;
        }
        else if([self.self.qr_getCustomer.str_dist floatValue]/1000.0<10)
        {
            mapView.zoomLevel=BaiduMap_level-9;
        }
        else
        {
            mapView.zoomLevel=6;
        }
    }
    account_index++;
    [self SignUp];//签到按钮设置
}
- (void)start
{//5second 调用一次
    timer = [NSTimer scheduledTimerWithTimeInterval:UpdateLocation_Time target:self selector:@selector(updateLocation:) userInfo:nil repeats:YES];
}
- (void)stop
{
    [timer invalidate];
    timer = nil;
    mapView.delegate=nil;
    locService.delegate=nil;
    geocodesearch.delegate = nil; // 不用时，置nil

}
-(void)updateLocation:(NSTimer *)theTimer
{
    mapView.delegate = self; // 此处记得不用的时候需要置nil，否则影响内存的释放
    locService.delegate = self;
}
-(void)theMenu
{
    //底端菜单
    View_menu.backgroundColor=[UIColor clearColor];
    View_menu.frame=CGRectMake((Phone_Weight-300)/2,Phone_Height-190, 300, 190);
    [self.view addSubview:View_menu];
    //响应方法
    button_signUp.tag=buttonTag;
    [button_signUp addTarget:self action:@selector(btn_Action:) forControlEvents:UIControlEventTouchUpInside];
    button_onlineList.tag=buttonTag+2;
    button_onlineList.backgroundColor=[UIColor clearColor];
    [button_onlineList addTarget:self action:@selector(btn_Action:) forControlEvents:UIControlEventTouchUpInside ];
    button_signOut.tag=buttonTag+3;
    
    [button_signOut addTarget:self action:@selector(btn_Action:) forControlEvents:UIControlEventTouchUpInside];
}

-(void)SignUp
{
    if([Function isBlankString:self.qr_getCustomer.str_gname])
    {
        self.qr_getCustomer.str_gname=@"无法获取该终端名称";
    }
    if([Function isBlankString:self.qr_getCustomer.str_address])
    {
        self.qr_getCustomer.str_address=@"无法获取该终端地址";
    }
    lab_gname.text=[NSString stringWithFormat:@"%@",self.qr_getCustomer.str_gname];
    
    if([self.str_isFrom_More isEqualToString:@"1"])//只有当权限为2（部门经理）或者4（boss）的时候才能显示超链接
    {
        CGSize labelsize = [lab_gname.text sizeWithFont:lab_gname.font constrainedToSize:lab_gname.frame.size lineBreakMode:NSLineBreakByWordWrapping];
        UIImageView *imav = [[UIImageView alloc]initWithFrame:CGRectMake(lab_gname.frame.origin.x,lab_gname.frame.origin.y+lab_gname.frame.size.height,labelsize.width,1)];
        imav.backgroundColor = [UIColor whiteColor];
        [View_menu addSubview:imav];
        
        button_toSignClerk.frame=CGRectMake(lab_gname.frame.origin.x,lab_gname.frame.origin.y, labelsize.width, labelsize.height);
        [View_menu addSubview:button_toSignClerk];
    }
    lab_address.text=[NSString stringWithFormat:@"%@",self.qr_getCustomer.str_address];
    lab_test.text=@"";
    [self Is_theSameOffice];
}
-(void)TheBtn_Status
{
    /**签到状态start**/
    self.imageView_Status.image=[UIImage imageNamed:[self return_signUpStatus:self.qr_getCustomer.str_sign_type]];
    /**签到状态end**/
    if([self.str_isFrom_More isEqualToString:@"1"])//巡访
    {
        if([self.qr_getCustomer.str_gbelongto isEqualToString:
            [[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"gbelongto"]]||[str_auth isEqualToString:@"4"]) //str_auth为4是因为boss没有gbelongto字段
        {//同一个部门
            
            if([self.qr_getCustomer.str_sign_type isEqualToString:@"1"]||[self.qr_getCustomer.str_sign_type isEqualToString:@"2"])//到达已签到 和到达未签退
            {//已经签到
                button_signUp.userInteractionEnabled=NO;
                [button_signUp setBackgroundImage:[UIImage imageNamed:@"icon_SignUp_finish.png"] forState:UIControlStateNormal]; //灰色图标
                
                if (self.qr_getCustomer.RequiredCount.integerValue && !self.qr_getCustomer.DynamicSaved.integerValue) {
                    button_signOut.userInteractionEnabled=NO;
                    self.matterBtn.userInteractionEnabled = YES;
                    [self.matterBtn setBackgroundImage:ImageName(@"matter.png") forState:UIControlStateNormal];
                    [button_signOut  setBackgroundImage:ImageName(@"icon_SignOut_finish.png") forState:UIControlStateNormal];
                }else {
                    button_signOut.userInteractionEnabled=YES;
                    self.matterBtn.userInteractionEnabled = YES;
                    [self.matterBtn setBackgroundImage:ImageName(@"matter.png") forState:UIControlStateNormal];
                    [button_signOut setBackgroundImage:[UIImage imageNamed:@"icon_SignOut_normal.png"] forState:UIControlStateNormal];
                }
            }
            else //if([self.qr_getCustomer.str_sign_type isEqualToString:@"0"])
            {//按钮都可用 该签到了
                button_signOut.userInteractionEnabled=NO;
                [button_signOut setBackgroundImage:[UIImage imageNamed:@"icon_SignOut_finish.png"] forState:UIControlStateNormal];
                
                button_signUp.userInteractionEnabled=YES;
                [button_signUp setBackgroundImage:[UIImage imageNamed:@"icon_SignUp_normal.png"] forState:UIControlStateNormal];
                
                self.matterBtn.userInteractionEnabled = NO;
                [self.matterBtn setBackgroundImage:ImageName(@"matterGray.png") forState:UIControlStateNormal];
            }
        }
        else
        {
            [button_signOut setBackgroundImage:[UIImage imageNamed:@"icon_SignOut_finish.png"] forState:UIControlStateNormal];
            [button_signUp setBackgroundImage:[UIImage imageNamed:@"icon_SignUp_finish.png"] forState:UIControlStateNormal];
            [self.matterBtn setBackgroundImage:ImageName(@"matterGray.png") forState:UIControlStateNormal];
            self.matterBtn.userInteractionEnabled = NO;
            button_signOut.userInteractionEnabled=NO;
            button_signUp.userInteractionEnabled=NO;
        }
    }
    else//考勤
    {//只隐藏 在线下订单
        if([self.qr_getCustomer.str_sign_type isEqualToString:@"1"]||[self.qr_getCustomer.str_sign_type isEqualToString:@"2"])//到达已签到 和到达未签退
        {
            button_signUp.userInteractionEnabled=NO;
            [button_signUp setBackgroundImage:[UIImage imageNamed:@"icon_SignUp_finish.png"] forState:UIControlStateNormal];
            if (self.qr_getCustomer.RequiredCount.integerValue && !self.qr_getCustomer.DynamicSaved.integerValue) {
                button_signOut.userInteractionEnabled=NO;
                self.matterBtn.userInteractionEnabled = YES;
                [self.matterBtn setBackgroundImage:ImageName(@"matter.png") forState:UIControlStateNormal];
                [button_signOut  setBackgroundImage:ImageName(@"icon_SignOut_finish.png") forState:UIControlStateNormal];
            }else {
                button_signOut.userInteractionEnabled=YES;
                self.matterBtn.userInteractionEnabled = YES;
                [self.matterBtn setBackgroundImage:ImageName(@"matter.png") forState:UIControlStateNormal];
                [button_signOut setBackgroundImage:[UIImage imageNamed:@"icon_SignOut_normal.png"] forState:UIControlStateNormal];
            }
        }
        else//签到
        {
            button_signOut.userInteractionEnabled=NO;
            [button_signOut setBackgroundImage:[UIImage imageNamed:@"icon_SignOut_finish.png"] forState:UIControlStateNormal];
            [self.matterBtn setBackgroundImage:ImageName(@"matterGray.png") forState:UIControlStateNormal];
            self.matterBtn.userInteractionEnabled = NO;
            button_signUp.userInteractionEnabled=YES;
            [button_signUp setBackgroundImage:[UIImage imageNamed:@"icon_SignUp_normal.png"] forState:UIControlStateNormal];
        }
    }
}
-(NSString*)return_signUpStatus:(NSString *)str
{
    
    if([str isEqualToString:@"-1"])
    {
        return @"icon_sign-1";
    }
    else if([str isEqualToString:@"1"])
    {
        return @"icon_sign1";
    }
    else if([str isEqualToString:@"2"])
    {
        return @"icon_sign2";
    }
    else if([str isEqualToString:@"3"])
    {
        return @"icon_sign3";
    }
    else if([str isEqualToString:@"0"])
    {
        return @"icon_sign0";
    }
    else
    {
        return @"";
    }
}
-(void)Is_theSameOffice
{
    if([Function isBlankString:self.qr_getCustomer.str_dist])
        return;
    if([self.qr_getCustomer.str_dist floatValue]>=1000)
    {
        lab_test.text=[NSString stringWithFormat:@"距离终端约%.2f公里",[self.qr_getCustomer.str_dist floatValue]/1000];
        lab_test.textColor=[UIColor redColor];
    }
    else
    {
        lab_test.text=[NSString stringWithFormat:@"距离终端约%@米",self.qr_getCustomer.str_dist];
        lab_test.textColor=[UIColor whiteColor];
    }

    if([self.qr_getCustomer.str_gbelongto isEqualToString:
        [[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"gbelongto"]]|| [str_auth isEqualToString:@"4"])
    {//同一部门
        if([self.qr_getCustomer.str_dist integerValue] >=distance)
        {
            isBeyond_Distance=YES;
        }
        else
        {
            isBeyond_Distance=NO;
        }
    }
    else
    {//不是同一部门
        button_onlineList.hidden=YES;
        if([self.qr_getCustomer.str_dist integerValue] >=distance)
        {
            if([self.str_isFrom_More isEqualToString:@"1"])//巡访
            {
                [SGInfoAlert showInfo:@"您不隶属该部门,不能签到、签退、在线下订单"
                              bgColor:[[UIColor darkGrayColor] CGColor]
                               inView:self.view
                             vertical:0.5];
            }
            isBeyond_Distance=YES;
        }
        else
        {
            if([self.str_isFrom_More isEqualToString:@"1"])//巡访
            {
                [SGInfoAlert showInfo:@"您不隶属该部门,不能签到、签退、在线下订单"
                              bgColor:[[UIColor darkGrayColor] CGColor]
                               inView:self.view
                             vertical:0.5];
            }
            isBeyond_Distance=NO;
        }
    }
}
-(void)btn_Action:(id)sender
{
    UIButton *btn=(UIButton *)sender;
    if(btn.tag==buttonTag+5)//返回
    {
        self.delegate =(id) app.VC_Visit ;//vc
        //指定代理对象为，second
        [self.delegate Notify_SignIn];//这里获得代理方法的返回值。
        [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:1] animated:YES];
    }
    else if(btn.tag==buttonTag)//签到
    {
        //Dlog(@"签到");
        if(isBeyond_Distance)
        {
            [self WhenPress_mention:[NSString stringWithFormat:@"确认签到:距离终端超过%ldm,签到可能失败",(long)distance]Tag:1];
        }
        else
        {
            [self WhenPress_mention:@"确认签到"Tag:1];
        }
    }
    else if(btn.tag==buttonTag+1)//重扫QR 改为重新确认终端
    {
        isFirstOpenQR=NO;
        if([self.str_isFrom_More isEqualToString:@"2"])
        {
            [self WhenPress_mention:@"二维码重扫终端" Tag:5];
        }
        else
        {
            if([[[SelfInf_Singleton sharedInstance].dic_SelfInform  objectForKey:@"qrcode_only"] isEqualToString:@"1"])
            {
                [self WhenPress_mention:@"二维码重扫终端" Tag:5];
            }
            else
            {
                UIActionSheet *actionSheet =[[UIActionSheet alloc]initWithTitle:@"选择重新确认终端方式" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"扫二维码",@"列表", nil];
                [actionSheet showInView:self.view];
                actionSheet.tag=buttonTag+1;
                actionSheet=nil;
                [self SignUp];
            }
   
        }
    }
    else if (buttonTag+2==btn.tag)//在线下单
    {
        [self WhenPress_mention:@"现在就去在线下订单"Tag:4];
    }
    else if(buttonTag+3==btn.tag)//签退
    {
        
        //Dlog(@"签退");
        if(isBeyond_Distance)
        {
            [self WhenPress_mention:[NSString stringWithFormat:@"确认签退:距离终端超过%ldm,签退可能失败",(long)distance] Tag:3];
        }
        else
        {
            [self WhenPress_mention:@"确认签退" Tag:3];
        }
    }
    else if(buttonTag+4==btn.tag)//收起menu
    {
        if(!isCloseMenu)
        {
            isCloseMenu=YES;
            [UIView animateWithDuration:0.8f animations:^{
                view_Menu.frame=CGRectMake(menu_sub/2, Phone_Height, Menu_width, 0);
            } completion:^(BOOL finished)
             {
                 [view_Menu removeFromSuperview];
                 button_CloseMenu.frame=CGRectMake(Menu_width-45+menu_sub/2, Phone_Height-46, 44, 44);
                 [self.view addSubview:button_CloseMenu];
             }];
        }
        else
        {
            isCloseMenu=NO;
            button_CloseMenu.frame=CGRectMake(Menu_width-45, 2, 44, 44);
            [view_Menu addSubview:button_CloseMenu];
            [UIView animateWithDuration:0.8f animations:^{
                if(isIOS7)
                {
                    view_Menu.frame=CGRectMake(menu_sub/2, Phone_Height- 1/3.0*Phone_Height, Menu_width, 1/3.0*Phone_Height);
                }
                else
                {
                    view_Menu.frame=CGRectMake(menu_sub/2, Phone_Height- 1/3.0*Phone_Height-20, Menu_width, 1/3.0*Phone_Height);
                }
                [self.view addSubview:view_Menu];

            } completion:^(BOOL finished) {
                
            }];
        }
    }
}
-(void)WhenPress_mention:(NSString *)msg Tag:(NSInteger)tag
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:msg delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定",nil];
    [alert show];
    alert.tag=tag;
    alert=nil;
}
-(void)WhenPress_mention1:(NSString *)msg Tag:(NSInteger)tag
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:msg delegate:self cancelButtonTitle:nil otherButtonTitles:@"重试",nil];
    [alert show];
    alert.tag=tag;
    alert=nil;
}

-(void)SubmitTheQR_Inform:(NSString *)str_QR_atu
{
    if([Function isConnectionAvailable])
    {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.mode = MBProgressHUDModeIndeterminate;
        hud.labelText = @"加载中...";//加载提示语言
        
        if(app.isPortal)
        {
            urlString=[NSString stringWithFormat:@"%@%@",KPORTAL_URL,KGET_CUSTOMER];
        }
        else
        {
            urlString=[NSString stringWithFormat:@"%@%@",kBASEURL,KGET_CUSTOMER];
        }
        NSURL *url = [ NSURL URLWithString :  urlString];
        ASIFormDataRequest *request = [ ASIFormDataRequest requestWithURL :url];
        request.delegate = self;
        request.tag = 100;
        [request setRequestMethod:@"POST"];
        [request setPostValue:[[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"account"]forKey:KUSER_UID];
        [request setPostValue:[[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"secret"] forKey:KUSER_PASSWORD];
        [request setPostValue:[[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"token"] forKey:@"user.token"];
        [request setPostValue:[[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"db_ip"] forKey:@"db_ip"];
        [request setPostValue:[[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"db_name"] forKey:@"db_name"];
        
        
        [request setPostValue:str_QR_atu forKey:KATU];
        [request setPostValue:self.str_isFrom_More forKey:@"stype"];//2考勤 1巡访
        [request startAsynchronous ];//异步
    }
    else
    {
        [SGInfoAlert showInfo:@"当前网络不可用，请检查网络连接"
                      bgColor:[[UIColor darkGrayColor] CGColor]
                       inView:self.view
                     vertical:0.5];
    }
}
-(BOOL)IsBlank
{
    if(
       [Function isBlankString:self.qr_getCustomer.str_new_lng]||
       [Function isBlankString:self.qr_getCustomer.str_new_lat] )
    {
        return YES;
    }
    return NO;
}
-(NSString *)SettingURL_GoTO_SignUpOrOut:(NSString *)url Type:(NSString *)type
{
    NSString *string;
    if([type isEqualToString:@"0"])
    {
        string=[NSString stringWithFormat:@"%@%@",url,KSIGN_TYPE0];
    }
    else
    {
        string=[NSString stringWithFormat:@"%@%@",url,KSIGN_TYPE1];
    }
    return string;
}
-(void)GoTO_SignUpOrOut:(NSString *)type//去签到或者签退
{
    myType = type;
    if([Function isConnectionAvailable])
    {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.mode = MBProgressHUDModeIndeterminate;
        hud.labelText = @"加载中...";//加载提示语言
        
        if(app.isPortal)
        {
            urlString=[self SettingURL_GoTO_SignUpOrOut:KPORTAL_URL Type:type];
        }
        else
        {
            urlString=[self SettingURL_GoTO_SignUpOrOut:kBASEURL Type:type];
        }
        NSURL *url = [ NSURL URLWithString :  urlString];
        ASIFormDataRequest *request = [ ASIFormDataRequest requestWithURL :url];
        request.delegate = self;
        request.tag = 101;
        [request setRequestMethod:@"POST"];
        [request setPostValue:[[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"account"]forKey:KUSER_UID];
        [request setPostValue:[[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"secret"] forKey:KUSER_PASSWORD];
        [request setPostValue:[[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"token"] forKey:@"user.token"];
        [request setPostValue:[[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"db_ip"] forKey:@"db_ip"];
        [request setPostValue:[[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"db_name"] forKey:@"db_name"];
        
        [request setPostValue:self.qr_getCustomer.str_index_no forKey:@"item.customer_index_no"];
        [request setPostValue:self.qr_getCustomer.str_gname forKey:@"item.gname"];
        [request setPostValue:self.qr_getCustomer.str_address forKey:@"item.gaddress"];
        [request setPostValue:self.qr_getCustomer.str_belongto forKey:@"item.gbelongto"];
        [request setPostValue:self.qr_getCustomer.str_glng forKey:@"item.glng"];
        [request setPostValue:self.qr_getCustomer.str_glat forKey:@"item.glat"];
        [request setPostValue:self.qr_getCustomer.str_atu forKey:@"atu"];
        [request setPostValue:app.str_LocationName forKey:@"address"];
        [request setPostValue:self.qr_getCustomer.str_new_lng forKey:@"alng"];
        [request setPostValue:self.qr_getCustomer.str_new_lat forKey:@"alat"];
        [request setPostValue:self.qr_getCustomer.str_dist forKey:@"dist"];
        [request setPostValue:self.qr_getCustomer.str_gmemo forKey:@"item.gmemo"];
        if([self.str_isFrom_More isEqualToString:@"2"])
        {
            [request setPostValue:@"2" forKey:@"item.stype"];//考勤签到
        }
        else
        {
            [request setPostValue:@"1" forKey:@"item.stype"];//巡访签到
        }
        [request startAsynchronous ];//异步
    }
    else
    {
        [SGInfoAlert showInfo:@"当前网络不可用，请检查网络连接"
                      bgColor:[[UIColor darkGrayColor] CGColor]
                       inView:self.view
                     vertical:0.5];
    }
}
-(void)get_JsonString:(NSString *)jsonString Type:(NSString *)type
{//signtype(就是self.qr_getCustomer.str_sign_type) 0将要签到 1将要签退
    SBJsonParser *parser = [[SBJsonParser alloc] init];
    NSDictionary *dict =[parser objectWithString: jsonString];
    if([type isEqualToString:@"0"])//签到
    {
        if([[dict objectForKey:@"ret"] isEqualToString:@"0"])
        {
            NSDictionary *dic=[dict objectForKey:@"SignInfo"];
            self.qr_getCustomer.str_sign_type=[dic objectForKey:@"gps_result"];
            self.imageView_Status.image=[UIImage imageNamed:[self return_signUpStatus:self.qr_getCustomer.str_sign_type]];
            button_signUp.userInteractionEnabled=NO;
            [button_signUp setBackgroundImage:[UIImage imageNamed:@"icon_SignUp_finish.png"] forState:UIControlStateNormal];
            
            button_signOut.userInteractionEnabled=YES;
            [button_signOut setBackgroundImage:[UIImage imageNamed:@"icon_SignOut_normal.png"] forState:UIControlStateNormal];
            self.qr_getCustomer.str_sign_type = [[dict objectForKey:@"SignInfo"] objectForKey:@"sign_type"];
            if ([self.qr_getCustomer.str_sign_type isEqualToString:@"1"]) {
                self.qr_getCustomer.DynamicCount = [dict objectForKey:@"DynamicCount"];
                self.qr_getCustomer.RequiredCount = [dict objectForKey:@"RequiredCount"];
                self.qr_getCustomer.DynamicSaved = [dict objectForKey:@"DynamicSaved"];
                self.qr_getCustomer.InfoNumberStr = [[dict objectForKey:@"SignInfo"] objectForKey:@"index_no"];;
                [self TheBtn_Status];
            }
        }
        else
        {
            [SGInfoAlert showInfo:[dict objectForKey:@"message"]
                          bgColor:[[UIColor darkGrayColor] CGColor]
                           inView:self.view
                         vertical:0.5];
        }
    }
    else if([type isEqualToString:@"1"])//签退
    {
        if([[dict objectForKey:@"ret"] isEqualToString:@"0"])
        {
            NSDictionary *dic=[dict objectForKey:@"SignInfo"];
            self.qr_getCustomer.str_sign_type=[dic objectForKey:@"gps_result"];
            self.imageView_Status.image=[UIImage imageNamed:[self return_signUpStatus:self.qr_getCustomer.str_sign_type]];
            button_signOut.userInteractionEnabled=NO;
            button_signUp.userInteractionEnabled=YES;
            [button_signOut setBackgroundImage:[UIImage imageNamed:@"icon_SignOut_finish.png"] forState:UIControlStateNormal];
            [button_signUp setBackgroundImage:[UIImage imageNamed:@"icon_SignUp_normal.png"] forState:UIControlStateNormal];
        }
        else
        {
            [SGInfoAlert showInfo:[dict objectForKey:@"message"]
                          bgColor:[[UIColor darkGrayColor] CGColor]
                           inView:self.view
                         vertical:0.5];
        }
        [self.navigationController popViewControllerAnimated:YES];
    }
    else if([type isEqualToString:@"100"])//向远程提交二维码 返回结果
    {
        [self Set_SighUp:dict];
    }
    else if([type isEqualToString:@"101"])//跳转签约客户
    {
        NSDictionary *dic=[dict objectForKey:@"CustomerInfo"];
        if(![Function isBlankString:[dic objectForKey:@"gaddress"]])
        {
            NSArray *arr=[dict objectForKey:@"MediaList"];
            [self To_DetailView_Info:dic Photo:arr AllData:dict];
        }
    }
}
-(void)Set_SighUp:(NSDictionary *)dict
{
    if(!isFistOpenMap)
    {
        [mapView viewWillAppear];
        // [locService startUserLocationService];
        locService.delegate = self;
        mapView.showsUserLocation = NO;
        mapView.userTrackingMode = BMKUserTrackingModeFollow;
        mapView.showsUserLocation = YES;
        mapView.delegate = self; // 此处记得不用的时候需要置nil，否则影响内存的释放
        [self start];
    }
    NSDictionary *dic_Return=[dict objectForKey:@"CustomerInfo"];
    self.qr_getCustomer.str_gname=[dic_Return objectForKey:@"gname"];
    self.qr_getCustomer.str_address=[dic_Return objectForKey:@"gaddress"];
    self.qr_getCustomer.str_last_sign_date=[dic_Return objectForKey:@"last_sign_date"];
    self.qr_getCustomer.str_glng=[dic_Return objectForKey:@"glng"];
    self.qr_getCustomer.str_glat=[dic_Return objectForKey:@"glat"];
    self.qr_getCustomer.str_belongto=[dic_Return objectForKey:@"belongto"];
    self.qr_getCustomer.str_index_no=[dic_Return objectForKey:@"index_no"];
    self.qr_getCustomer.str_gbelongto=[dic_Return objectForKey:@"gbelongto"];
    NSDictionary *dic_SignInfo=[dict objectForKey:@"SignInfo"];
    if([Function isBlankString:[dic_SignInfo objectForKey:@"gps_result"]])
    {
        self.qr_getCustomer.str_sign_type=@"";
    }
    else
    {
        self.qr_getCustomer.str_sign_type=[dic_SignInfo objectForKey:@"sign_type"];
//        if([self.qr_getCustomer.str_sign_type isEqualToString:@"1"]) {
            self.qr_getCustomer.DynamicCount = [dict objectForKey:@"DynamicCount"];
            self.qr_getCustomer.RequiredCount = [dict objectForKey:@"RequiredCount"];
            self.qr_getCustomer.DynamicSaved=[dict objectForKey:@"DynamicSaved"];
            self.qr_getCustomer.InfoNumberStr = [dic_SignInfo objectForKey:@"index_no"];
//        }
    }
    if([Function isBlankString:self.qr_getCustomer.str_address])
    {
        self.qr_getCustomer.str_address=@"无法获取该终端地址";
    }
    lab_address.text=[NSString stringWithFormat:@"%@",self.qr_getCustomer.str_address];
    [self ShowTheLocation];//显示终端信息
    [self TheBtn_Status];
}
//签约客户start
-(void)getListDetail:(NSString *)index_no
{
    if([Function isConnectionAvailable])
    {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.mode = MBProgressHUDModeIndeterminate;
        hud.labelText = @"加载中...";//加载提示语言
        
        if(app.isPortal)
        {
            urlString=[NSString stringWithFormat:@"%@%@",KPORTAL_URL,KGet_Detail2 ];
        }
        else
        {
            urlString=[NSString stringWithFormat:@"%@%@",kBASEURL,KGet_Detail2 ];
        }
        NSURL *url = [ NSURL URLWithString :  urlString];
        ASIFormDataRequest *request = [ ASIFormDataRequest requestWithURL :url];
        request.delegate = self;
        request.tag = 102;
        [request setRequestMethod:@"POST"];
        [request setPostValue:[[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"account"]forKey:KUSER_UID];
        [request setPostValue:[[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"secret"] forKey:KUSER_PASSWORD];
        [request setPostValue:[[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"token"] forKey:@"user.token"];
        [request setPostValue:[[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"db_ip"] forKey:@"db_ip"];
        [request setPostValue:[[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"db_name"] forKey:@"db_name"];
        
        [request setPostValue: index_no forKey:@"index_no"];
        [request startAsynchronous ];//异步
    }
    else
    {
        [SGInfoAlert showInfo:@"当前网络不可用，请检查网络连接"
                      bgColor:[[UIColor darkGrayColor] CGColor]
                       inView:self.view
                     vertical:0.5];
    }
}
-(void)To_DetailView_Info:(NSDictionary *)dic Photo:(NSArray *)arr AllData:(NSDictionary *)data
{
    AddNewClerkOrRivalViewController * addVC=[[AddNewClerkOrRivalViewController alloc]init];
    addVC.str_title=@"2";
    addVC.isDetail=YES;
    addVC.str_value1=[dic objectForKey:@"svtype"];//类型H12
    addVC.str_value2=[dic objectForKey:@"plevel"];//档次H4
    addVC.str_value3=[dic objectForKey:@"gcoopstate"];//状态H3
    
    
    addVC.str_tex0=[dic objectForKey:@"gname"];
    addVC.str_tex1=[self Calculate:@"H12" Value:[dic objectForKey:@"svtype"]];
    addVC.str_tex2=[dic objectForKey:@"gcontact"];
    
    addVC.str_tex3=[dic objectForKey:@"gtel"];
    addVC.str_tex4=[dic objectForKey:@"gvolume"];
    
    addVC.str_tex5=[self Calculate:@"H4" Value:[dic objectForKey:@"plevel"]];
    addVC.str_tex6=[self Calculate:@"H3" Value:[dic objectForKey:@"gcoopstate"]];
    
    addVC.str_tex7=[dic objectForKey:@"gaddress"];
    
    addVC.str_index_no=[dic objectForKey:@"index_no"];
    app.str_alat=[dic objectForKey:@"glat"];
    app.str_nlng=[dic objectForKey:@"glng"];
    addVC.dic_data_all=[NSDictionary dictionaryWithDictionary:data];
    addVC.authFlag = 1;
    isReNotQR=YES;
    [self.navigationController pushViewController: addVC animated:YES];
}
-(NSString *)Calculate:(NSString *)str_H Value:(NSString *)str_value
{
    NSDictionary *dic=[[BasicData sharedInstance].dic_BasicData objectForKey:@"MasterList"];
    NSArray *arr=[dic objectForKey:str_H];
    for(NSInteger i=0;i<arr.count;i++)
    {
        NSDictionary *dict=[arr objectAtIndex:i];
        if([[dict objectForKey:@"cvalue"] isEqualToString:str_value])
        {
            return [dict objectForKey:@"clabel"];
        }
    }
    return @"";
}
//签约客户end
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)ToSignClerK {
    [self getListDetail:self.qr_getCustomer.str_index_no];
}

- (IBAction)matterButtonAction:(id)sender {
    if([Function isConnectionAvailable])
    {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.mode = MBProgressHUDModeIndeterminate;
        hud.labelText = @"加载中...";//加载提示语言
        
        if(app.isPortal)
        {
            urlString=[NSString stringWithFormat:@"%@%@",KPORTAL_URL,KGet_matter];
        }
        else
        {
            urlString=[NSString stringWithFormat:@"%@%@",kBASEURL,KGet_matter];
        }
        NSURL *url = [ NSURL URLWithString :  urlString];
        ASIFormDataRequest *request = [ ASIFormDataRequest requestWithURL :url];
        request.delegate = self;
        request.tag = 104;
        [request setRequestMethod:@"POST"];
        [request setPostValue:[[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"account"]forKey:KUSER_UID];
        [request setPostValue:[[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"secret"] forKey:KUSER_PASSWORD];
        [request setPostValue:[[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"token"] forKey:@"user.token"];
        [request setPostValue:[[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"db_ip"] forKey:@"db_ip"];
        [request setPostValue:[[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"db_name"] forKey:@"db_name"];
        
        [request setPostValue:self.str_isFrom_More forKey:@"item.stype"];
        [request setPostValue:self.qr_getCustomer.InfoNumberStr forKey:@"item.index_no"];
        [request startAsynchronous ];//异步
    }
    else
    {
        [SGInfoAlert showInfo:@"当前网络不可用，请检查网络连接"
                      bgColor:[[UIColor darkGrayColor] CGColor]
                       inView:self.view
                     vertical:0.5];
    }
}

#pragma mark ---- UIAlertView delegate method
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    //button_num 1 2 3 4分别是签到 重扫 在线下订单 签退
    if(alertView.tag==4)
    {
        if(buttonIndex==1)
        {
            [[AddProduct sharedInstance].arr_AddToList removeAllObjects];
            app.isApproval=NO;
            app.str_Product_material=@"0";//商品  扫描条码时候扫商品
            OrderListViewController *onlineVC=[[OrderListViewController alloc]init];
            onlineVC.str_cindex_no=self.qr_getCustomer.str_index_no;
            onlineVC.str_isFromOnlineOrder=@"1";//在线下订单
            onlineVC.str_title=@"在线下订单";
            [self.navigationController pushViewController:onlineVC animated:YES];
            return;
        }
    }
    else if(alertView.tag==1)
    {
        if(buttonIndex==1)
        {
            if([self IsBlank])
            {
                [self WhenPress_mention1:@"定位信息不完整,无法签到,请确认定位服务开启状态良好"  Tag:6];
            }
            else
            {
                [self GoTO_SignUpOrOut:@"0"];
            }
        }
    }
    else if(alertView.tag==2)
    {
        if(buttonIndex==1)
        {
            isFirstOpenQR=NO;
            //[self CreateTheQR];//重扫二维码
            UIActionSheet *actionSheet =[[UIActionSheet alloc]initWithTitle:@"选择重新确认终端方式" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"扫二维码",@"列表", nil];
            [actionSheet showInView:self.view];
            actionSheet.tag=buttonTag+1;
            actionSheet=nil;
            [self SignUp];
        }
    }
    else if(alertView.tag==3)
    {
        if(buttonIndex==1)
        {
            if(YES)
            {
                if([self IsBlank])
                {
                    [self WhenPress_mention1:@"定位信息不完整,无法签到,请确认定位服务开启状态良好"  Tag:6];
                }
                else
                {
                    [self GoTO_SignUpOrOut:@"1"];
                }
            }
            else
            {
                [SGInfoAlert showInfo:@"您还没签到,请先去签到!"
                              bgColor:[[UIColor darkGrayColor] CGColor]
                               inView:self.view
                             vertical:0.5];
            }
        }
    }
    else if(alertView.tag==5)
    {
        if(buttonIndex==1)
        {
            //Dlog(@"扫二维码");
            [self CreateTheQR];
        }
    }
    else if (alertView.tag==6)
    {
        account_index=0;
        [locService stopUserLocationService];
        locService=nil;
        locService=[[BMKLocationService alloc]init];
        [locService startUserLocationService];
        mapView.delegate = self; // 此处记得不用的时候需要置nil，否则影响内存的释放
        locService.delegate = self;
        [mapView reloadInputViews];
        [self.navigationController popViewControllerAnimated:YES];
    }
}
#pragma mark ---- UIActionSheet delegate method
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(actionSheet.tag==buttonTag+1)
    {
        if(buttonIndex==0)
        {
            //Dlog(@"扫二维码");
            [self CreateTheQR];
        }
        else if(buttonIndex==1)
        {
            //Dlog(@"列表选择");
            NotQRViewController *notQR=[[NotQRViewController alloc]init];
            notQR.str_From=@"5";//重扫二维码
            isReNotQR=YES;
            [self.navigationController pushViewController: notQR animated:YES];
            account_index=0;
        }
    }
}

-(void)CreateTheQR
{
    account_index=0;
    isReQR=YES;
    BOOL cameraFlag = [Function CanOpenCamera];
    
    if (!cameraFlag) {
        
        PresentView *presentView = [PresentView getSingle];
        
        presentView.presentViewDelegate = self;
        
        presentView.frame = CGRectMake(0, 0, 240, 250);
        
        [[KGModal sharedInstance] showWithContentView:presentView andAnimated:YES];
        
        return;
        
    }
    
    if (isIOS7) {
        zbarNewViewController *zbarNew = [zbarNewViewController new];
        zbarNew.zbarNewDelegate = self;
        [self presentViewController:zbarNew animated:YES completion:^{
        }];
    }else {
        [reader CreateTheQR:self];
    }
}

#pragma mark ---- zbar delegate method
-(void)dismissZbarAction {
    //Dlog(@"dismiss"); //iOS6
}

-(void)getCodeString:(NSString *)codeString {
    //ios7以上获取二维码方法
    self.qr_getCustomer.str_atu = codeString;
    [self SubmitTheQR_Inform:codeString];
}

-(void)zbarDismissAction{
    account_index=12;
    
    if([self.str_isFrom_More isEqualToString:@"2"])
    {
        isReQR=YES;
        [locService stopUserLocationService];
        [locService startUserLocationService];
        if ([Function StringIsNotEmpty:self.qr_getCustomer.str_atu]) {
            //Dlog(@"二维码有数据");
            return;
        }
        [self.navigationController popViewControllerAnimated:YES];  //1.0.4 二维码扫描直接跳回更多页面(比如模拟器运行时)
        return;
    }
    
    if(isFirstOpenQR)
    {
        isReQR=NO;
        [self.navigationController popViewControllerAnimated:YES];
    }
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [picker dismissViewControllerAnimated:YES completion:^{
        [picker removeFromParentViewController];
        UIImage * image = [info objectForKey:UIImagePickerControllerOriginalImage];
        //初始化
        ZBarReaderController * read = [ZBarReaderController new];
        //设置代理
        read.readerDelegate = self;
        CGImageRef cgImageRef = image.CGImage;
        ZBarSymbol * symbol = nil;
        id <NSFastEnumeration> results = [read scanImage:cgImageRef];
        for (symbol in results)
        {
            break;
        }
        NSString * result;
        if ([symbol.data canBeConvertedToEncoding:NSShiftJISStringEncoding])
            
        {
            result = [NSString stringWithCString:[symbol.data cStringUsingEncoding: NSShiftJISStringEncoding] encoding:NSUTF8StringEncoding];
        }
        else
        {
            result = symbol.data;
        }
        self.qr_getCustomer.str_atu = result;
        [self SubmitTheQR_Inform:result];
    }];
}
#pragma mark ---- BaiduMap delegate method
/**
 *在地图View将要启动定位时，会调用此函数
 *@param mapView 地图View
 */
- (void)mapViewWillStartLocatingUser:(BMKMapView *)mapView
{
    //Dlog(@"start locate");
}
-(void)mapView:(BMKMapView *)mapView1 regionDidChangeAnimated:(BOOL)animated
{
    if(!isFirstComeIn)
    {
        mapView.zoomLevel=BaiduMap_level;
        isFirstComeIn=YES;
    }
}
/**
 *用户位置更新后，会调用此函数
 *@param userLocation 新的用户位置
 */
- (void)didUpdateBMKUserLocation:(BMKUserLocation *)userLocation
{
    if(account_index<10)
    {
        //Dlog(@"李群：didUpdateUserLocation lat %f,long %f",userLocation.location.coordinate.latitude,userLocation.location.coordinate.longitude);
        [mapView updateLocationData:userLocation];
        
        [self Calculate_Destination_Latitude:userLocation.location.coordinate.latitude Longitude:userLocation.location.coordinate.longitude];
        //Dlog(@"定位ING中");
        
        CLGeocoder *geocoder = [[CLGeocoder alloc] init];
        
        app.str_alat=[NSString stringWithFormat:@"%lf",userLocation.location.coordinate.latitude];
        app.str_nlng=[NSString stringWithFormat:@"%lf",userLocation.location.coordinate.longitude];
        [geocoder reverseGeocodeLocation: userLocation.location completionHandler:^(NSArray *array, NSError *error) {
            if(error==0&&array.count > 0) {
                CLPlacemark *placemark = [array objectAtIndex:0];
                app.str_LocationName=[NSString stringWithFormat:@"%@%@%@%@%@",placemark.administrativeArea,placemark.locality,placemark.subLocality,placemark.thoroughfare,placemark. subThoroughfare];
                app.str_LocationName=[NavView returnString:app.str_LocationName];
                //Dlog(@"%@",app.str_LocationName);
                isGetLocationName=YES;
                // [locService stopUserLocationService];
                locService.delegate=nil;
            }
        }];
        geocoder=nil;
    }
}
/**
 *在地图View停止定位后，会调用此函数
 *@param mapView 地图View
 */
- (void)mapViewDidStopLocatingUser:(BMKMapView *)mapView
{
    //Dlog(@"stop locate");
}

/**
 *定位失败后，会调用此函数
 *@param mapView 地图View
 *@param error 错误号，参考CLError.h中定义的错误号
 */
- (void)mapView:(BMKMapView *)mapView didFailToLocateUserWithError:(NSError *)error
{
    //Dlog(@"location error");
}
/**
 *返回反地理编码搜索结果
 *@param searcher 搜索对象
 *@param result 搜索结果
 *@param error 错误号，@see BMKSearchErrorCode
 */

- (BMKAnnotationView *)mapView:(BMKMapView *)mapView viewForAnnotation:(id <BMKAnnotation>)annotation {
    if ([annotation isKindOfClass:[BMKPointAnnotation class]]) {
        static NSString* kPin = @"pin";
        BMKPinAnnotationView *newAnnotationView1 = [[BMKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:kPin];
        [newAnnotationView1 setDraggable:NO];//允许用户拖动
        newAnnotationView1.animatesDrop = NO;// 设置该标注点动画显示
        
        newAnnotationView1.annotation=annotation;
        
        newAnnotationView1.image = [UIImage imageNamed:@"address.png"];   //把大头针换成别的图片
        
        return newAnnotationView1;
    }
    return nil;
}

#pragma mark ---- ASIHttpRequest delegate method
-(void)requestFinished:(ASIHTTPRequest *)request {
    if (request.tag == 100) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        if([request responseStatusCode]==200)
        {
            NSString * jsonString  =  [request responseString];
            
            [self get_JsonString:jsonString Type:@"100"];
            return;
        }
        else
        {
            [SGInfoAlert showInfo:@"发生异常,请稍后再试"
                          bgColor:[[UIColor darkGrayColor] CGColor]
                           inView:self.view
                         vertical:0.5];
            [NdUncaughtExceptionHandler Post_url:[NSString stringWithFormat:@"URL:%@,HTTP_Code%d",urlString,[request responseStatusCode]]];
        }
    }
    if (request.tag == 101) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        if([request responseStatusCode]==200)
        {
            NSString * jsonString  =  [request responseString];
            [self get_JsonString:jsonString Type:myType];
        }
        else
        {
            [SGInfoAlert showInfo:@"发生异常,请稍后再试"
                          bgColor:[[UIColor darkGrayColor] CGColor]
                           inView:self.view
                         vertical:0.5];
            [NdUncaughtExceptionHandler Post_url:[NSString stringWithFormat:@"URL:%@,HTTP_Code%d",urlString,[request responseStatusCode]]];
        }
    }
    if (request.tag == 102) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        
        if([request responseStatusCode]==200)
        {
            NSString * jsonString  =  [request responseString];
            [self get_JsonString:jsonString  Type:@"101"];
        }
        else
        {
            [SGInfoAlert showInfo:@"发生异常,请稍后再试"
                          bgColor:[[UIColor darkGrayColor] CGColor]
                           inView:self.view
                         vertical:0.5];
            [NdUncaughtExceptionHandler Post_url:[NSString stringWithFormat:@"URL:%@,HTTP_Code%d",urlString,[request responseStatusCode]]];
        }
    }
    if (request.tag == 104) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        if([request responseStatusCode]==200)
        {
            convertDic = [NSDictionary dictionaryWithObjectsAndKeys:
                          self.qr_getCustomer.str_index_no,@"item.customer_index_no",
                          self.qr_getCustomer.str_gname ,@"item.gname",
                          self.qr_getCustomer.str_address,@"item.gaddress",
                          self.qr_getCustomer.str_belongto,@"item.gbelongto",
                          self.qr_getCustomer.str_glng,@"item.glng",
                          self.qr_getCustomer.str_glat,@"item.glat",
                          app.str_LocationName,@"address",
                          self.qr_getCustomer.str_new_lng,@"alng",
                          self.qr_getCustomer.str_new_lat,@"alat",
                          self.qr_getCustomer.str_dist,@"dist",
                          self.qr_getCustomer.str_gmemo,@"item.gmemo",
                          self.qr_getCustomer.str_atu,@"atu",nil];
            
            NSString * jsonString  =  [request responseString];
            SBJsonParser *parser = [[SBJsonParser alloc] init];
            NSDictionary *dict =[parser objectWithString: jsonString];
            OrderListDynamic *order=[[OrderListDynamic alloc]init];
            order.indexStr = self.qr_getCustomer.InfoNumberStr;
            order.titleString = @"巡检附加信息";
            order.matterFlag = self.str_isFrom_More;
            order.mtypeStr = @"1";
            order.convertDic = convertDic;
            order.dic_json=dict;
            order.isDetail=self.qr_getCustomer.DynamicSaved.integerValue;
            [self.navigationController pushViewController:order animated:YES];

        }
        else
        {
            [SGInfoAlert showInfo:@"发生异常,请稍后再试"
                          bgColor:[[UIColor darkGrayColor] CGColor]
                           inView:self.view
                         vertical:0.5];
            [NdUncaughtExceptionHandler Post_url:[NSString stringWithFormat:@"URL:%@,HTTP_Code%d",urlString,[request responseStatusCode]]];
        }
    }
}

-(void)requestFailed:(ASIHTTPRequest *)request {
    if (request.tag == 100) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [SGInfoAlert showInfo:@"哎呀，服务器无响应，一会再试试吧"
                      bgColor:[[UIColor darkGrayColor] CGColor]
                       inView:self.view
                     vertical:0.5];
    }
    if (request.tag == 101) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        
        [SGInfoAlert showInfo:@"哎呀，服务器无响应，一会再试试吧"
                      bgColor:[[UIColor darkGrayColor] CGColor]
                       inView:self.view
                     vertical:0.5];
    }
    if (request.tag == 102) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [SGInfoAlert showInfo:@"哎呀，服务器无响应，一会再试试吧"
                      bgColor:[[UIColor darkGrayColor] CGColor]
                       inView:self.view
                     vertical:0.5];
    }
}

#pragma mark ---- presentView delegate method

- (void)presentViewDissmissAction {
    
    [[KGModal sharedInstance] closeAction:nil];
    
}
@end
