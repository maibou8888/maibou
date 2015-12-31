//
//  ShowMyPositionViewController.h
//  WZYB_syb
//  查看地址视图控制器
//  Created by wzyb on 14-9-12.
//  Copyright (c) 2014年 WZYB. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <BaiduMapAPI/BMapKit.h>
@interface ShowMyPositionViewController : UIViewController<BMKMapViewDelegate>
{
    NSInteger moment_status;
    BMKMapView* mapView;
    BMKPointAnnotation* annotation;
}
@property(nonatomic,strong)NSString *str_glat;
@property(nonatomic,strong)NSString *str_glng;
@property(nonatomic,strong)NSString *str_gname;
@end
