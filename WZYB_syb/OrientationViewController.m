//
//  OrientationViewController.m
//  WZYB_syb
//
//  Created by wzyb on 14-9-16.
//  Copyright (c) 2014年 WZYB. All rights reserved.
//

#import "OrientationViewController.h"
#import "AppDelegate.h"
@interface OrientationViewController ()
{
    AppDelegate *app;
    UIImageView *moveImage;
    NSInteger number;       //判断只有在移动地图时才执行的数据
    BOOL flagAddress;
    NSString *longtitude;
    NSString *latitude;
    NSInteger mapNumber;
}
@end

@implementation OrientationViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self All_Init];
    if (isIOS8) {
        //由于IOS8中定位的授权机制改变 需要进行手动授权
        locationManager = [[CLLocationManager alloc] init];
        //获取授权认证
        [locationManager requestAlwaysAuthorization];
        [locationManager requestWhenInUseAuthorization];
    }

}
-(void)viewWillAppear:(BOOL)animated
{
    [mapView1 viewWillAppear];
    [locService startUserLocationService];
    mapView1.userTrackingMode = BMKUserTrackingModeFollow;
  
    mapView1.zoomLevel=BaiduMap_level;
    mapView1.delegate = self; // 此处记得不用的时候需要置nil，否则影响内存的释放
    locService.delegate = self;
    [self start];
}
-(void)viewWillDisappear:(BOOL)animated
{
    [mapView1 viewWillDisappear];
    [locService stopUserLocationService];
    [self stop];
}
-(void)All_Init
{ //41.624256 123.450819
    number = 0;
    flagAddress = 0;
    mapNumber = 0;
//    annotation2 = [[BMKPointAnnotation alloc]init];//火柴头初始化
//    annotation1 = [[BMKPointAnnotation alloc]init];//火柴头初始化
    
    if(StatusBar_System>0)
        moment_status=20;
    else moment_status=0;
    app=(AppDelegate *)[[UIApplication sharedApplication]delegate];
    //处理导航start
    NavView *nav_View=[[NavView alloc]init];
    [self.view addSubview: [nav_View NavView_Title1:self.str_title]];
    
    longtitude = [NSString string];
    latitude = [NSString string];;
    
    UIButton *btn_SignIn=[UIButton buttonWithType:UIButtonTypeCustom];//返回
    btn_SignIn.frame=CGRectMake(0, moment_status, 60, 44);
    [btn_SignIn setBackgroundImage:[UIImage imageNamed:@"btn_color6.png"] forState:UIControlStateHighlighted];
    [btn_SignIn setTitle:@"< 返回" forState:UIControlStateNormal];
    [btn_SignIn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    btn_SignIn.titleLabel.font=[UIFont systemFontOfSize:15];
    
    btn_SignIn.backgroundColor=[UIColor clearColor];
    btn_SignIn.tag=buttonTag-1;
    [btn_SignIn addTarget:self action:@selector(btn_Action:) forControlEvents:UIControlEventTouchUpInside];
    [nav_View.view_Nav  addSubview:btn_SignIn];
    if (!self.editFlag) {
        UIButton *btn_SignIn1=[UIButton buttonWithType:UIButtonTypeCustom];//返回
        btn_SignIn1.frame=CGRectMake(Phone_Weight-44, moment_status, 44, 44);
        [btn_SignIn1 setTitle:@"确定" forState:UIControlStateNormal];
        [btn_SignIn1 setBackgroundImage:[UIImage imageNamed:@"btn_color6.png"] forState:UIControlStateHighlighted];
        [btn_SignIn1 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        btn_SignIn1.titleLabel.font=[UIFont systemFontOfSize:15];
        btn_SignIn1.backgroundColor=[UIColor clearColor];
        btn_SignIn1.tag=buttonTag-2;
        [btn_SignIn1 addTarget:self action:@selector(btn_Action:) forControlEvents:UIControlEventTouchUpInside];
        [nav_View.view_Nav  addSubview:btn_SignIn1];
    }
    //处理导航end
    //初始化百度地图start
    mapView1 = [[BMKMapView alloc]initWithFrame:CGRectMake(0, moment_status+44, Phone_Weight, Phone_Height-(moment_status+44))];
    mapView1.showsUserLocation = YES;
    [self.view addSubview:mapView1];
    
    btn_update=[UIButton buttonWithType:UIButtonTypeCustom];
    btn_update.frame=CGRectMake(Phone_Weight-50, moment_status+44+20, 44, 44);
    btn_update.backgroundColor=[UIColor clearColor];
    [btn_update setBackgroundImage:[UIImage imageNamed:@"baidu_again.png"] forState:UIControlStateNormal];
    [self.view addSubview: btn_update];
    [btn_update addTarget:self action:@selector(Update_GPS) forControlEvents:UIControlEventTouchUpInside];
    locService=[[BMKLocationService alloc]init];
    //初始化百度地图end
    
    if (self.showGreenView != 1 && !self.editFlag) {
        //绿色不会移动的实时更新位置图标
        UIImage *userImage = ImageName(@"annotation.png");
        moveImage = [[UIImageView alloc] initWithImage:userImage];
        CGFloat screenHeight = self.view.frame.size.height;
        moveImage.frame = CGRectMake(150, screenHeight/2, userImage.size.width,userImage.size.height);
        moveImage.image=userImage;
        moveImage.backgroundColor = [UIColor clearColor];
        [self.view addSubview:moveImage];
        [self.view bringSubviewToFront:moveImage];
      }
}

//位置移动监听函数
- (void)mapView:(BMKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
    if (self.showGreenView != 1) {
        if(!isFirstComeIn)
        {
            mapView1.zoomLevel=BaiduMap_level;
            isFirstComeIn=YES;
        }
        CLLocationCoordinate2D  centerCoordinateNew = mapView.centerCoordinate;
        BMKGeoCodeSearch * _geoCodeSearch = [[BMKGeoCodeSearch alloc]init];
        _geoCodeSearch.delegate = self;
        BMKReverseGeoCodeOption *reverseGeoCodeOption= [[BMKReverseGeoCodeOption alloc] init];
        reverseGeoCodeOption.reverseGeoPoint = centerCoordinateNew;
        [_geoCodeSearch reverseGeoCode:reverseGeoCodeOption];
    }
}

//反地址编码
- (void)onGetReverseGeoCodeResult:(BMKGeoCodeSearch *)searcher
                           result:(BMKReverseGeoCodeResult *)result
                        errorCode:(BMKSearchErrorCode)error
{
    number ++;
    if (error == BMK_SEARCH_NO_ERROR) {
        if (number > 1 && !self.editFlag) {
            flagAddress = 1;
            [UIView animateWithDuration:0.3 animations:^{
                moveImage.top -= 10;
            } completion:^(BOOL finish){
                if (finish) {
                    [UIView animateWithDuration:0.3 animations:^{
                        moveImage.top += 10;
                    } completion:^(BOOL finish){
                        if (finish) {
                            app.str_LocationName = result.address;
                            app.str_nlng = [NSString stringWithFormat:@"%f",result.location.longitude];
                            app.str_alat = [NSString stringWithFormat:@"%f",result.location.latitude];
                        }
                    }];
                }
            }];
        }
    }
}

-(void)Update_GPS
{
    [locService stopUserLocationService];
    locService=nil;
    locService=[[BMKLocationService alloc]init];
    [locService startUserLocationService];
    mapView1.delegate = self; // 此处记得不用的时候需要置nil，否则影响内存的释放
    locService.delegate = self;
    [mapView1 reloadInputViews];
    [self.view insertSubview:mapView1 atIndex:0];
    isUpdate=YES;
//    [UIView animateWithDuration:2.0 animations:^{
//        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
//        hud.mode = MBProgressHUDModeIndeterminate;
//        hud.labelText = @"重载中...";//加载提示语言
//    } completion:^(BOOL finished) {
//        [MBProgressHUD hideHUDForView:self.view animated:YES];
//    }];
}

- (void)start
{//5second 调用一次
    timer = [NSTimer scheduledTimerWithTimeInterval:UpdateLocation_Time target:self selector:@selector(updateLocation:) userInfo:nil repeats:YES];
}
- (void)stop
{
    [timer invalidate];
    timer = nil;
    mapView1.delegate=nil;
    locService.delegate=nil;
}
-(void)updateLocation:(NSTimer *)theTimer
{
    mapView1.delegate = self; // 此处记得不用的时候需要置nil，否则影响内存的释放
    locService.delegate = self;
}

-(void)btn_Action:(id)sender
{
    UIButton *btn=(UIButton *)sender;
    if(btn.tag==buttonTag-1)//返回
    {
        [self WhenBack_mention];
    }
    else if(btn.tag==buttonTag-2)//切换定位和坐标取点
    {
        if([Function isBlankString:app.str_LocationName])
        {
            [SGInfoAlert showInfo:@"选择无效,请重试"
                          bgColor:[[UIColor darkGrayColor] CGColor]
                           inView:self.view
                         vertical:0.5];
        }
        else
        {
            [self MentionAlert:[NavView returnString:app.str_LocationName]];
        }
    }
}
-(void)WhenBack_mention//编辑状态中 返回提示
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"处于编辑状态,确认要返回吗" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定",nil];
    [alert show];
    alert=nil;
}

-(void)MentionAlert:(NSString *)msg
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提交位置" message:msg delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定",nil];
    alert.tag = 100;
    [alert show];
}
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex==1)
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
}
//////
/**
 *用户位置更新后，会调用此函数
 *@param userLocation 新的用户位置
 */
-(void)LocationName:(double  )lat lng:(double)lng
{//反向地理编码
    CLLocation *c = [[CLLocation alloc] initWithLatitude:lat longitude:lng];
    //创建位置
    __block CLGeocoder *revGeo = [[CLGeocoder alloc] init];
    [revGeo reverseGeocodeLocation:c completionHandler:^(NSArray *array, NSError *error) {
        if (array.count > 0) {
            CLPlacemark *placemark = [array objectAtIndex:0];
            app.str_LocationName=[NSString stringWithFormat:@"%@%@%@%@%@",placemark.administrativeArea,placemark.locality,placemark.subLocality,placemark.thoroughfare,placemark. subThoroughfare];
            app.str_LocationName=[NavView returnString:app.str_LocationName];
            revGeo=nil;
        }
    }];
}

- (void)mapView:(BMKMapView *)mapView onClickedMapBlank:(CLLocationCoordinate2D)coordinate
{
    if(!isPick)return;
    latitude=[NSString stringWithFormat:@"%f",coordinate.latitude];
    longtitude=[NSString stringWithFormat:@"%f",coordinate.longitude];
    [self LocationName:coordinate.latitude lng:coordinate.longitude];
}
- (void)mapView:(BMKMapView *)mapView onClickedMapPoi:(BMKMapPoi*)mapPoi
{
    if(!isPick)return;;
    latitude=[NSString stringWithFormat:@"%f",mapPoi.pt.latitude];
    longtitude=[NSString stringWithFormat:@"%f",mapPoi.pt.longitude];
    [self LocationName:mapPoi.pt.latitude lng:mapPoi.pt.longitude];
    locService.delegate=nil;
}
- (void)mapView:(BMKMapView *)mapView didSelectAnnotationView:(BMKAnnotationView *)view
{
    //Dlog(@"%lf",view.annotation.coordinate.latitude);
}

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

- (void)setMapRegionWithCoordinate:(CLLocationCoordinate2D)coordinate
{
    BMKCoordinateRegion region;
    if (!isSetMapSpan)//这里用一个变量判断一下,只在第一次锁定显示区域时 设置一下显示范围 Map Region
    {
        region = BMKCoordinateRegionMake(coordinate, BMKCoordinateSpanMake(0.05, 0.05));//越小地图显示越详细
        isSetMapSpan = YES;
        [mapView1 setRegion:region animated:YES];//执行设定显示范围
    }
    //注释掉该行代码 整个地图随便移动了
    // [mapView setCenterCoordinate:coordinate animated:YES];//根据提供的经纬度为中心原点 以动画的形式移动到该区域
}
- (void)didUpdateBMKUserLocation:(BMKUserLocation *)userLocation
{
    mapNumber ++;
    if (mapNumber > 1) {
        return;
    }
        if (flagAddress != 1) {
        [mapView1 updateLocationData:userLocation];
        [self setMapRegionWithCoordinate:userLocation.location.coordinate];
            
        CLLocationCoordinate2D coor;
        if ([app.str_alat doubleValue] > 0.000000 && [app.str_nlng doubleValue] > 0.000000) {
            coor.latitude =[app.str_alat doubleValue];//纬度
            coor.longitude =[app.str_nlng doubleValue];
            [mapView1 setCenterCoordinate:coor animated:YES];
        }

        latitude=[NSString stringWithFormat:@"%lf",userLocation.location.coordinate.latitude];
        longtitude=[NSString stringWithFormat:@"%lf",userLocation.location.coordinate.longitude];
            
        CLGeocoder *geocoder = [[CLGeocoder alloc] init];
        [geocoder reverseGeocodeLocation: userLocation.location completionHandler:^(NSArray *array, NSError *error) {
            if(error==0&&array.count > 0) {
                CLPlacemark *placemark = [array objectAtIndex:0];
                
                if (!app.str_LocationName.length) {
                    app.str_LocationName=[NSString stringWithFormat:@"%@%@%@%@%@",placemark.administrativeArea,placemark.locality,placemark.subLocality,placemark.thoroughfare,placemark. subThoroughfare];
                }
                if (!app.str_alat.length) {
                    app.str_alat = [NSString stringWithFormat:@"%@",latitude];
                    app.str_nlng = [NSString stringWithFormat:@"%@",longtitude];
                }
                app.str_LocationName=[NavView returnString:app.str_LocationName];
                [self Map_ToMyLocation:latitude Lng:longtitude];
                locService.delegate=nil;
                if([self.str_IsFromWhere isEqualToString:@"1"])
                {//如果是添加客户 手动选点
                    isPick=YES;
                }
                else if([self.str_IsFromWhere isEqualToString:@"2"])
                {//添加申请
                    isPick=NO;
                }
            }
        }];
        geocoder=nil;
    }
}

-(void)Map_ToLocation:(NSString *)lat Lng:(NSString *)lng
{
    mapView1.hidden=NO;
    //我点选的位置 设为中心
//    [mapView1 removeAnnotation:annotation2] ;
    CLLocationCoordinate2D coor;
    coor.latitude =[lat doubleValue] ;//纬度
    coor.longitude =[lng doubleValue];
    
//    mapView1.centerCoordinate=coor;
//    annotation2.coordinate = coor;
//    annotation2.title = app.str_LocationName;
//    [mapView1 addAnnotation:annotation2];
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}
-(void)Map_ToMyLocation:(NSString *)lat Lng:(NSString *)lng
{//定位的位置
//    [mapView1 removeAnnotation:annotation1] ;
    CLLocationCoordinate2D coor;
    coor.latitude =[lat doubleValue] ;//纬度
    coor.longitude =[lng doubleValue];
    if(isUpdate)
    {
        isUpdate=NO;
//        mapView1.centerCoordinate=coor;
    }
//    annotation1.coordinate = coor;
//    annotation1.title =[NSString stringWithFormat:@"我在:%@",app.str_LocationName];
//   [mapView1 addAnnotation:annotation1];
    mapView1.hidden=NO;
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}
/////////////
 
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
