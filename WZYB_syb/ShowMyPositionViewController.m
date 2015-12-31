//
//  ShowMyPositionViewController.m
//  WZYB_syb
//
//  Created by wzyb on 14-9-12.
//  Copyright (c) 2014年 WZYB. All rights reserved.
//

#import "ShowMyPositionViewController.h"

@interface ShowMyPositionViewController ()

@end

@implementation ShowMyPositionViewController

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
    
}
-(void)All_Init
{
    if(StatusBar_System>0)
        moment_status=20;
    else moment_status=0;
    NavView *nav_View=[[NavView alloc]init];
    [self.view addSubview: [nav_View NavView_Title1:@"查看地址"]];
    //左边返回键
    UIButton *btn=[UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame=CGRectMake(0, moment_status, 60, 44);
    btn.backgroundColor=[UIColor clearColor];
    btn.tag=buttonTag-1;
    [btn addTarget:self action:@selector(btn_Action:) forControlEvents:UIControlEventTouchUpInside];
    [nav_View.view_Nav  addSubview:btn];
    [btn setBackgroundImage:[UIImage imageNamed:@"btn_color6.png"] forState:UIControlStateHighlighted];
    [btn setTitle:@"< 返回" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    btn.titleLabel.font=[UIFont systemFontOfSize:15];
    
    //初始化百度地图start
    mapView = [[BMKMapView alloc]init ];
    mapView.frame=CGRectMake(0, moment_status+44, Phone_Weight, Phone_Height-(moment_status+44));
    [self.view addSubview:mapView];
    mapView.delegate = self;

}
-(void)viewWillAppear:(BOOL)animated
{
    [mapView viewWillAppear];
    [self ShowTheLocation];
}
-(void)viewWillDisappear:(BOOL)animated
{
    [mapView viewWillDisappear];
    mapView.delegate = nil;
}
-(void)ShowTheLocation
{
    //显示终端
    annotation = [[BMKPointAnnotation alloc]init];
    CLLocationCoordinate2D coor;
    coor.latitude =[self.str_glat doubleValue] ;//纬度
    coor.longitude =[self.str_glng doubleValue];
    mapView.centerCoordinate=coor;
    annotation.coordinate = coor;
    mapView.zoomLevel=BaiduMap_level;
    annotation.title = self.str_gname;
    [mapView addAnnotation:annotation];
    annotation=nil;
}
-(void)btn_Action:(UIButton *)btn
{
    if(btn.tag==buttonTag-1)
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
