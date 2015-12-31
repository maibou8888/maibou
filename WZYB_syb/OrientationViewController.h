//
//  OrientationViewController.h
//  WZYB_syb
//
//  Created by wzyb on 14-9-16.
//  Copyright (c) 2014年 WZYB. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <BaiduMapAPI/BMapKit.h>
@interface OrientationViewController : UIViewController<BMKMapViewDelegate,BMKLocationServiceDelegate,BMKGeoCodeSearchDelegate,UIAlertViewDelegate>
{
    NSInteger moment_status;
    BMKMapView* mapView1;//地图视图
    BMKLocationService* locService;//定位服务
    CLLocationManager  *locationManager;
//    BMKPointAnnotation* annotation2;//火柴头
//    BMKPointAnnotation* annotation1;//火柴头
    BOOL isPick;//是否手动取点 NO 手动
    BOOL isSetMapSpan;
    NSTimer *timer;//定时器 定时调用 定位服务的代理方法
    BOOL isFirstComeIn;//是不是第一次进地图 NO 是
    UIButton *btn_update;//更新GPS
    BOOL isUpdate;//更新GPS
}
@property(nonatomic,assign)NSInteger showGreenView;
@property(nonatomic,strong)NSString *str_title;//标题
@property(nonatomic,strong)NSString *str_IsFromWhere;// 1 客户 只可手动取点  2 审批申请 不能手动选点
@property(nonatomic,assign)NSInteger editFlag;

@end
