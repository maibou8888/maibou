//
//  OfflineDemoViewController.h
//  BaiduMapSdkSrc
//
//  Created by baidu on 13-4-16.
//  Copyright (c) 2013年 baidu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <BaiduMapAPI/BMapKit.h>
#import "ATableViewCell.h"

@interface OfflineDemoViewController :UIViewController<BMKMapViewDelegate,BMKOfflineMapDelegate,UITableViewDataSource,UITableViewDelegate>
{
    IBOutlet BMKMapView* _mapView;//.xib里要有BMKMapView类用于初始化数据驱动
    BMKOfflineMap* _offlineMap;
    IBOutlet UIButton* downLoadBtn;
    IBOutlet UIButton* stopBtn;
    IBOutlet UIButton* searchBtn;
    IBOutlet UITextField* cityName;
    IBOutlet UILabel* cityId;
    IBOutlet UISegmentedControl* tableviewChangeCtrl;
    IBOutlet UITableView* groupTableView;
    IBOutlet UITableView* plainTableView;

    NSArray* _arrayHotCityData;                         //热门城市
    NSArray* _arrayOfflineCityData;                     //全国支持离线地图的城市
    NSMutableArray * _arraylocalDownLoadMapInfo;        //本地下载的离线地图
    NSMutableArray * _arrayTotalOffLineCityData;        //sectionArray
    NSMutableDictionary * _dictionaryOfflineCityData;   //每个省份所有的城市
    NSMutableArray * _showingArray;                     //判断省份是否展开
    NSIndexPath * _indexPath;
    NSIndexPath * _indexPath1;
    CGFloat _startCityID;
    
    NSMutableDictionary *_downLoadDic;
    NSString *tempID;
}
- (IBAction)backAction:(id)sender;
-(IBAction)start:(id)sender;
-(IBAction)stop:(id)sender;
-(IBAction)search:(id)sender;
-(IBAction)textFiledReturnEditing:(id)sender;
-(IBAction)segmentChanged:(id)sender;
@end
