//
//  LocationPersonViewController.h
//  WZYB_syb
//  部门员工查看巡访列表和轨迹回放的视图控制器
//  Created by wzyb on 14-6-27.
//  Copyright (c) 2014年 WZYB. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <BaiduMapAPI/BMapKit.h>
#import "NavView.h"
#import "VisitCell.h"
#import "CustomOverlayView.h"//地图划线
#import "CustomOverlay.h"//地图划线
#import "RBCustomDatePickerView.h"//日期选择器
@interface LocationPersonViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,BMKMapViewDelegate,BMKLocationServiceDelegate,UIAlertViewDelegate>
{
    NSInteger moment_status;
    BMKMapView* mapView;//地图视图
    BMKLocationService* locService;//定位服务
    //RBCustomDatePickerView *pickerView;//日期
    BOOL isPointsOrList;//YES  地图轨迹 NO List表
    NSArray *arr_HistoryList_Data;//获取坐标数据
    
    UIButton *btn_list;//轨迹明细
    UIButton *btn_graph;//轨迹回放
    NSString *str_date;
    
    UIView *view_back;//日历背景
    BOOL isOpenDate;//日期表打开了吗 yes 打开 NO 没打开
    RBCustomDatePickerView *pickerView;
    
    UITableView *tableView;
    NSArray *arr_HistoryList;//历史列表
    UIImageView *imageView_Face;
    BOOL isRealPaoPao;
    
    float distance;
}
@property (nonatomic,retain) NSString *urlString;
@end
