//
//  OfflineDemoViewController.m
//  BaiduMapSdkSrc
//
//  Created by baidu on 13-4-16.
//  Copyright (c) 2013年 baidu. All rights reserved.
//

#import "OfflineDemoViewController.h"
#import "OfflineDemoMapViewController.h"

#define CityName @"cityname"
#define ChildCityNumber @"childcitynumber"
#define CityID   @"cityid"

@implementation OfflineDemoViewController
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBarHidden = YES;
    
    //适配ios7
    if( ([[[UIDevice currentDevice] systemVersion] doubleValue]>=7.0))
    {
        self.navigationController.navigationBar.translucent = NO;
    }
    
    //初始化离线地图服务
    _offlineMap = [[BMKOfflineMap alloc]init];
    //获取热门城市
    _arrayHotCityData = [_offlineMap getHotCityList];
    //获取支持离线下载城市列表
    _arrayOfflineCityData = [_offlineMap getOfflineCityList];
    //初始化Segment
    tableviewChangeCtrl.selectedSegmentIndex = 0;
    
    _startCityID = 0.0;
    tempID = [NSString string];
    _arrayTotalOffLineCityData = [NSMutableArray array];
    _showingArray = [NSMutableArray array];
    _dictionaryOfflineCityData = [NSMutableDictionary dictionary];
    _downLoadDic = [NSMutableDictionary dictionary];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        for (BMKOLSearchRecord* item in _arrayOfflineCityData) {
            [_arrayTotalOffLineCityData addObject:item.cityName];
            [_showingArray addObject:[NSNumber numberWithBool:NO]];
            
            NSMutableArray *tempMutArray = [NSMutableArray array];
            NSMutableDictionary *mutDic = [NSMutableDictionary dictionary];
            if(item.childCities != nil && item.childCities.count > 0)
            {
                for (BMKOLSearchRecord* childitem in item.childCities)
                {
                    NSString* tempPackSize = [self getDataSizeString:childitem.size];
                    NSString *tempCityName = [NSString stringWithFormat:@"%@-(%@)",childitem.cityName,tempPackSize];
                    NSString* childID = [NSString stringWithFormat:@"%d",childitem.cityID];
                    [mutDic setObject:tempCityName forKey:CityName];
                    [mutDic setObject:childID forKey:CityID];
                    id object = [mutDic  copy];
                    [tempMutArray addObject:object];
                }
            }else {
                NSString* tempPackSize = [self getDataSizeString:item.size];
                NSString* cityID = [NSString stringWithFormat:@"%d",item.cityID];
                NSString *tempCityName = [NSString stringWithFormat:@"%@-(%@)",item.cityName,tempPackSize];
                [mutDic setObject:tempCityName forKey:CityName];
                [mutDic setObject:cityID forKey:CityID];
                [tempMutArray addObject:mutDic];
            }
            [_dictionaryOfflineCityData setObject:tempMutArray forKey:item.cityName];
        }
    });
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 114, 320, 1)];
    headerView.backgroundColor = [UIColor colorWithRed:235/255.0 green:235/255.0 blue:235/255.0 alpha:1];
    [self.view addSubview:headerView];
}

-(void)viewWillAppear:(BOOL)animated {
    _mapView.delegate = self;
    _offlineMap.delegate = self; 
}

-(void)viewWillDisappear:(BOOL)animated {
    [_mapView viewWillDisappear];
    _mapView.delegate = nil; // 不用时，置nil
    _offlineMap.delegate = nil; // 不用时，置nil
}

- (void)dealloc {

    if (_offlineMap != nil) {
        _offlineMap = nil;
    }
    if (_mapView) {
        _mapView = nil;
    }
}

//输入框处理
-(IBAction)textFiledReturnEditing:(id)sender {
    [sender resignFirstResponder];
}
//根据城市名检索城市id
- (IBAction)search:(id)sender
{
    [cityName resignFirstResponder];
    //根据城市名获取城市信息，得到cityID
    NSArray* city = [_offlineMap searchCity:cityName.text];
    if (city.count > 0) {
        BMKOLSearchRecord* oneCity = [city objectAtIndex:0];
        cityId.text =  [NSString stringWithFormat:@"%d", oneCity.cityID];
    }
}

- (IBAction)backAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

//开始下载离线包
-(IBAction)start:(id)sender
{
    [_offlineMap start:[cityId.text floatValue]];
}
//停止下载离线包
-(IBAction)stop:(id)sender
{
    [_offlineMap pause:[cityId.text floatValue]];
}

//城市列表/下载管理切换
-(IBAction)segmentChanged:(id)sender
{
    UISegmentedControl* control = (UISegmentedControl*)sender;
    switch (control.selectedSegmentIndex) {
        case 0:
        {
            groupTableView.hidden = NO;
            plainTableView.hidden = YES;
            [groupTableView reloadData];
        }
            break;
        case 1:
        {
            groupTableView.hidden = YES;
            plainTableView.hidden = NO;
            //获取各城市离线地图更新信息
            _arraylocalDownLoadMapInfo = [NSMutableArray arrayWithArray:[_offlineMap getAllUpdateInfo]];
            [plainTableView reloadData];
        }
            break;
            
        default:
            break;
    }
}
//离线地图delegate，用于获取通知
- (void)onGetOfflineMapState:(int)type withState:(int)state
{
    
    if (type == TYPE_OFFLINE_UPDATE) {
        //id为state的城市正在下载或更新，start后会毁掉此类型
        BMKOLUpdateElement* updateInfo;
        updateInfo = [_offlineMap getUpdateInfo:state];
        
        for (int index = 0; index < _arraylocalDownLoadMapInfo.count; index ++)
        {
            ATableViewCell *cell = (ATableViewCell *)[plainTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
            
            BMKOLUpdateElement* item = [_arraylocalDownLoadMapInfo objectAtIndex:index];
            if ([item.cityName isEqualToString:updateInfo.cityName])
            {
                //是否可更新
                if(item.update)
                {
                    cell.lblPropress.text = [NSString stringWithFormat:@"%@————%d(可更新)", item.cityName,updateInfo.ratio];
                }
                else
                {
                    cell.lblPropress.text = [NSString stringWithFormat:@"%@ (%d%@)", item.cityName,updateInfo.ratio,@"%"];
                    cell.progressView.progress = updateInfo.ratio*0.01;
                }
            }else {
                
            }
        }
        
    }
    if (type == TYPE_OFFLINE_NEWVER) {
        //id为state的state城市有新版本,可调用update接口进行更新
        BMKOLUpdateElement* updateInfo;
        updateInfo = [_offlineMap getUpdateInfo:state];
    }
    if (type == TYPE_OFFLINE_UNZIP) {
        //正在解压第state个离线包，导入时会回调此类型
    }
    if (type == TYPE_OFFLINE_ZIPCNT) {
        //检测到state个离线包，开始导入时会回调此类型
        if(state==0)
        {
            [self showImportMesg:state];
        }
    }
    if (type == TYPE_OFFLINE_ERRZIP) {
        //有state个错误包，导入完成后会回调此类型
    }
    if (type == TYPE_OFFLINE_UNZIPFINISH) {
        //导入成功state个离线包，导入成功后会回调此类型
        [self showImportMesg:state];
    }
    
}
//导入提示框
- (void)showImportMesg:(int)count
{
    NSString* showmeg = [NSString stringWithFormat:@"成功导入离线地图包个数:%d", count];
    UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:@"导入离线地图" message:showmeg delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定",nil];
    [myAlertView show];
}

#pragma mark UITableView delegate

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 16)];
    headerView.backgroundColor = [UIColor colorWithRed:235/255.0 green:235/255.0 blue:235/255.0 alpha:1];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 2, 300, 16)];
    label.text = [_arrayTotalOffLineCityData objectAtIndex:section];
    label.textColor = [UIColor grayColor];
    label.font = [UIFont systemFontOfSize:12.0f];
    [headerView addSubview:label];
    return headerView;
}

//定义表中有几个section
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if(tableView== groupTableView)
    {
        return _arrayTotalOffLineCityData.count;
    }
    else
    {
        return 1;
    }
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if(tableView == groupTableView)
    {
        return 18.0f;
    }
    return 0.0f;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.0001f;
}

//定义每个section中有几行
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(tableView == groupTableView)
    {
        if (![[_showingArray objectAtIndex:section]boolValue]) {
            return 1;
        }
        else{
            NSString *titleStr = [_arrayTotalOffLineCityData objectAtIndex:section];
            NSArray *sectionArray = [_dictionaryOfflineCityData objectForKey:titleStr];
            return sectionArray.count;
        }
    }
    else
    {
        return [_arraylocalDownLoadMapInfo count];
    }
}
//定义cell样式填充数据
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if(tableView == groupTableView)
    {
        static NSString *CellIdentifier = @"OfflineMapCityCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];;
            
        }
        NSString *titleStr = [_arrayTotalOffLineCityData objectAtIndex:indexPath.section];
        NSArray *sectionArray = [_dictionaryOfflineCityData objectForKey:titleStr];
        NSDictionary *tempDic = [sectionArray objectAtIndex:indexPath.row];
        cell.textLabel.text = [tempDic objectForKey:CityName];
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(285, 12, 20, 20)];
        imageView.image = [UIImage imageNamed:@"offDown.png"];
        [cell.contentView addSubview:imageView];
        return cell;
    }
    else
    {
        static NSString *CellIdentifier1 = @"OfflineMapCityCell1";
        
        ATableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier1];
        if (cell == nil) {
            cell = [[[NSBundle mainBundle] loadNibNamed:@"ATableViewCell" owner:self options:0] objectAtIndex:0];
            
        }
        if(_arraylocalDownLoadMapInfo!=nil&&_arraylocalDownLoadMapInfo.count>indexPath.row)
        {
            _arraylocalDownLoadMapInfo = [NSMutableArray arrayWithArray:[_offlineMap getAllUpdateInfo]];
            BMKOLUpdateElement* item = [_arraylocalDownLoadMapInfo objectAtIndex:indexPath.row];
            cell.item = item;
            //是否可更新
            if(item.update)
            {
               cell.lblPropress.text = [NSString stringWithFormat:@"%@————%d(可更新)", item.cityName,item.ratio];
            }
            else
            {
               cell.lblPropress.text = [NSString stringWithFormat:@"%@ (%d%@)", item.cityName,item.ratio,@"%"];
                cell.progressView.progress = item.ratio*0.01;
            }
        }
        else
        {
            cell.lblPropress.text = @"";
        }
        return cell;
    }
    return nil;
}

//是否允许table进行编辑操作
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if(tableView== groupTableView)
    {
        return NO;
    }
    else
    {
        return YES;
    }
}

//提交编辑列表的结果
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        //删除poi
        if (tableView == plainTableView) {
            BMKOLUpdateElement* item = [_arraylocalDownLoadMapInfo objectAtIndex:indexPath.row];
            //删除指定城市id的离线地图
            [_offlineMap remove:item.cityID];
            //将此城市的离线地图信息从数组中删除
            [(NSMutableArray*)_arraylocalDownLoadMapInfo removeObjectAtIndex:indexPath.row];
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                             withRowAnimation:UITableViewRowAnimationLeft];
        }
    }
}
//表的行选择操作
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    if(tableView==plainTableView)
    {
        BMKOLUpdateElement* item = [_arraylocalDownLoadMapInfo objectAtIndex:indexPath.row];
        if(item.ratio==100)
        {
            //跳转到地图浏览页面
            OfflineDemoMapViewController *offlineMapViewCtrl = [[OfflineDemoMapViewController alloc] init];
            offlineMapViewCtrl.title = @"查看离线地图";
            offlineMapViewCtrl.cityId = item.cityID;
            offlineMapViewCtrl.offlineServiceOfMapview = _offlineMap;
            UIBarButtonItem *customLeftBarButtonItem = [[UIBarButtonItem alloc] init];
            customLeftBarButtonItem.title = @"返回";
            self.navigationItem.backBarButtonItem = customLeftBarButtonItem;
            [self.navigationController pushViewController:offlineMapViewCtrl animated:YES];
            
        }
        else if(item.ratio<100)//弹出提示框
        {
            cityId.text = [NSString stringWithFormat:@"%d", item.cityID];
            cityName.text = item.cityName;
            UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"该离线地图未完全下载，请继续下载！" delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定",nil];
            myAlertView.tag = 100;
            [myAlertView show];
        }
    }
    else
    {
        NSString *titleStr = [_arrayTotalOffLineCityData objectAtIndex:indexPath.section];
        NSArray *sectionArray = [_dictionaryOfflineCityData objectForKey:titleStr];
        NSDictionary *tempDic = [sectionArray objectAtIndex:indexPath.row];
        
        if (indexPath.row == 0) {
            if([[_showingArray objectAtIndex:indexPath.section]boolValue]){
                
                if (sectionArray.count == 1) {
                    NSString *downFlag = [_downLoadDic objectForKey:[tempDic objectForKey:CityID]];
                    if (downFlag.integerValue) {
                        return;
                    }
                    [_offlineMap start:[[tempDic objectForKey:CityID] floatValue]];
                    [_downLoadDic setObject:@"1" forKey:[tempDic objectForKey:CityID]];
                }else {
                    _startCityID = [[tempDic objectForKey:CityID] floatValue];
                    tempID = [tempDic objectForKey:CityID];
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提醒" message:@"" delegate:self cancelButtonTitle:@"收起" otherButtonTitles:@"下载地图", nil];
                    [alertView show];
                    _indexPath = indexPath;
                }
            }else{
                if (sectionArray.count == 1) {
                    NSString *downFlag = [_downLoadDic objectForKey:[tempDic objectForKey:CityID]];
                    if (downFlag.integerValue) {
                        return;
                    }
                    [_offlineMap start:[[tempDic objectForKey:CityID] floatValue]];
                    [_downLoadDic setObject:@"1" forKey:[tempDic objectForKey:CityID]];
                    return;
                }
                [_showingArray setObject:[NSNumber numberWithBool:YES] atIndexedSubscript:indexPath.section];
            }
            [tableView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationFade];
        }else {
            NSString *downFlag = [_downLoadDic objectForKey:[tempDic objectForKey:CityID]];
            if (downFlag.integerValue) {
                return;
            }
            [_offlineMap start:[[tempDic objectForKey:CityID] floatValue]];
            [_downLoadDic setObject:@"1" forKey:[tempDic objectForKey:CityID]];
        }
        
    }
}

#pragma mark 包大小转换工具类（将包大小转换成合适单位）
-(NSString *)getDataSizeString:(int) nSize
{
	NSString *string = nil;
	if (nSize<1024)
	{
		string = [NSString stringWithFormat:@"%dB", nSize];
	}
	else if (nSize<1048576)
	{
		string = [NSString stringWithFormat:@"%dK", (nSize/1024)];
	}
	else if (nSize<1073741824)
	{
		if ((nSize%1048576)== 0 )
        {
			string = [NSString stringWithFormat:@"%dM", nSize/1048576];
        }
		else
        {
            int decimal = 0; //小数
            NSString* decimalStr = nil;
            decimal = (nSize%1048576);
            decimal /= 1024;
            
            if (decimal < 10)
            {
                decimalStr = [NSString stringWithFormat:@"%d", 0];
            }
            else if (decimal >= 10 && decimal < 100)
            {
                int i = decimal / 10;
                if (i >= 5)
                {
                    decimalStr = [NSString stringWithFormat:@"%d", 1];
                }
                else
                {
                    decimalStr = [NSString stringWithFormat:@"%d", 0];
                }
                
            }
            else if (decimal >= 100 && decimal < 1024)
            {
                int i = decimal / 100;
                if (i >= 5)
                {
                    decimal = i + 1;
                    
                    if (decimal >= 10)
                    {
                        decimal = 9;
                    }
                    
                    decimalStr = [NSString stringWithFormat:@"%d", decimal];
                }
                else
                {
                    decimalStr = [NSString stringWithFormat:@"%d", i];
                }
            }
            
            if (decimalStr == nil || [decimalStr isEqualToString:@""])
            {
                string = [NSString stringWithFormat:@"%dMss", nSize/1048576];
            }
            else
            {
                string = [NSString stringWithFormat:@"%d.%@M", nSize/1048576, decimalStr];
            }
        }
	}
	else	// >1G
	{
		string = [NSString stringWithFormat:@"%dG", nSize/1073741824];
	}
	
	return string;
}

#pragma mark ---- UIAlertView delegate method
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == 100) {
        [_offlineMap start:[cityId.text floatValue]];
        return;
    }
    if (buttonIndex == 0) {
        [_showingArray setObject:[NSNumber numberWithBool:NO] atIndexedSubscript:_indexPath.section];
        [groupTableView reloadSections:[NSIndexSet indexSetWithIndex:_indexPath.section]
                      withRowAnimation:UITableViewRowAnimationFade];
    }else {

        NSString *downFlag = [_downLoadDic objectForKey:tempID];
        if (downFlag.integerValue) {
            return;
        }
        [_offlineMap start:_startCityID];
        [_downLoadDic setObject:@"1" forKey:tempID];
    }
}
@end
