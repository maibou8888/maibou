//
//  NotQRViewController.m
//  WZYB_syb
// 
//  Created by wzyb on 14-9-1.
//  Copyright (c) 2014年 WZYB. All rights reserved.
//

#import "NotQRViewController.h"
#import "SignInViewController.h"
#import "OrderListViewController.h"
#import "AppDelegate.h"
#import "PPiFlatSegmentedControl.h"
#import "BNRoutePlanModel.h"
#import "BNCoreServices.h"
@interface NotQRViewController ()<ASIHTTPRequestDelegate,BMKLocationServiceDelegate,PPiFlatSegmentedControlDelegate,BNNaviUIManagerDelegate,BNNaviRoutePlanDelegate>
{
    AppDelegate *app;
    NSString *urlString;
    UIImageView  *redImageView;          //滑动红线
    PPiFlatSegmentedControl *segmented;
    NSInteger selectIndexTake;           //取得当前点击的是segment的哪一块
    int jumpFlag;
    int BMKFlag;
    NSString *addressStr;
    NSIndexPath *_indexPath;
}

@property(strong,nonatomic)BMKLocationService* locService;//定位服务
@property(strong,nonatomic)CLLocationManager  *locationManager;
@end

@implementation NotQRViewController
@synthesize searchBar;
@synthesize contactDic;
@synthesize searchByName;
@synthesize searchByPhone;
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
    [self Local_Save];//获取本地缓存好的收藏数据
    [self searchBarInit];
}
-(void)viewWillAppear:(BOOL)animated
{
    isSearching=NO;
}
-(void)viewWillDisappear:(BOOL)animated
{
    [[SearchCoreManager share] Reset];
}

#pragma mark ---- private method
-(void)All_Init
{
    app=(AppDelegate *)[[UIApplication sharedApplication]delegate];
    if(StatusBar_System>0)
        moment_status=20;
    else moment_status=0;
    arr_SaveList=[[NSMutableArray alloc]init];

    NavView *nav_View=[[NavView alloc]init];
    [self.view addSubview: [nav_View NavView_Title1:@"终端"]];
    
    UIButton *btn=[UIButton buttonWithType:UIButtonTypeCustom];
    btn.backgroundColor=[UIColor clearColor];
    btn.frame=CGRectMake(0, moment_status, 60, 44);
    [btn setBackgroundImage:[UIImage imageNamed:@"btn_color6.png"] forState:UIControlStateHighlighted];
    [btn setTitle:@"< 返回" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    btn.titleLabel.font=[UIFont systemFontOfSize:15];
    btn.tag=buttonTag;
    [btn addTarget:self action:@selector(btn_Action:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    
    [self _initPPSegment];
    
    tableView =[[UITableView alloc]initWithFrame:CGRectMake(0, 44+moment_status+88, Phone_Weight, Phone_Height-44-moment_status-88)];
    tableView.separatorStyle=UITableViewCellSeparatorStyleNone;
    [self.view addSubview:tableView];
    tableView .dataSource=self;
    tableView .delegate=self;
    isSave=YES;//默认是收藏列表
    
    imageView_Face=[[UIImageView alloc]init];
    imageView_Face=[NavView Show_Nothing_Face];
    
    jumpFlag = 0;
    BMKFlag = 0;
    addressStr = [NSString string];
}

//初始化自定义segment
- (void)_initPPSegment {
    NSArray *itemArray = @[@{@"text":@"我的收藏"},@{@"text":@"终端查询"},@{@"text":@"巡访计划终端"}];
    segmented=[[PPiFlatSegmentedControl alloc] initWithFrame:CGRectMake(0,moment_status+44, 320, 44)
                                                       items:itemArray
                                                iconPosition:IconPositionRight
                                           andSelectionBlock:^(NSUInteger segmentIndex) { }];
    segmented.color=Nav_Bar;
    segmented.selectedColor=[UIColor colorWithRed:3/255.0 green:3/255.0 blue:3/255.0 alpha:1];
    segmented.textAttributes=@{NSFontAttributeName:[UIFont systemFontOfSize:15],
                               NSForegroundColorAttributeName:[UIColor whiteColor]};
    segmented.selectedTextAttributes=@{NSFontAttributeName:[UIFont boldSystemFontOfSize:16.0],
                                       NSForegroundColorAttributeName:[UIColor whiteColor]};
    segmented.eventDelegate = self;
    [self.view addSubview:segmented];
    
    //分割线
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 1)];
    imageView.backgroundColor = [UIColor colorWithRed:28/255.0 green:32/255.0 blue:43/255.0 alpha:1];
    [segmented addSubview:imageView];
    
    redImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 42, 106, 2)];
    redImageView.backgroundColor = [UIColor redColor];
    [segmented addSubview:redImageView];
}

//初始化搜索栏
- (void)searchBarInit
{
    self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0,moment_status+88 , Phone_Weight, 44)];
    self.searchBar.autocorrectionType = UITextAutocorrectionTypeNo;
	self.searchBar.autocapitalizationType = UITextAutocapitalizationTypeNone;
	self.searchBar.keyboardType = UIKeyboardTypeDefault;
	self.searchBar.backgroundColor=[UIColor clearColor];//修改搜索框背景
    searchBar.backgroundColor = [UIColor clearColor];
	searchBar.translucent=YES;
	self.searchBar.placeholder=@"搜索";
	self.searchBar.delegate = self;
    self.searchBar.showsCancelButton=YES;
	self.searchBar.barStyle=UIBarStyleDefault;
    [self.view addSubview:self.searchBar];
    
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    self.contactDic = dic;
    dic=nil;
    
    NSMutableArray *nameIDArray = [[NSMutableArray alloc] init];
    self.searchByName = nameIDArray;
    nameIDArray=nil;
    NSMutableArray *phoneIDArray = [[NSMutableArray alloc] init];
    
    self.searchByPhone = phoneIDArray;
    phoneIDArray=nil;
    //添加到搜索库
    for (NSInteger i = 0; i < arr_SaveList.count; i ++) {
        NSDictionary *dic=[arr_SaveList objectAtIndex:i];
        ContactPeople *contact = [[ContactPeople alloc] init];
        contact.localID = [NSNumber numberWithInteger:i];
        contact.name = [dic objectForKey:@"gname"];
        NSMutableArray *phoneArray = [[NSMutableArray alloc] init];
        [phoneArray addObject:[dic objectForKey:@"gaddress"]];
        [phoneArray addObject:[dic objectForKey:@"index_no"]];
        [phoneArray addObject:[dic objectForKey:@"atu"]];
        
        contact.phoneArray = phoneArray;
        //如果收藏列表有数据就将联系人添加到搜索里面
        [[SearchCoreManager share] AddContact:contact.localID name:contact.name phone:contact.phoneArray];
        [self.contactDic setObject:contact forKey:contact.localID];
        phoneArray=nil;
        contact=nil;
    }
}

-(void)Local_Save
{
    if([Function judgeFileExist:Save_List Kind:Library_Cache])
    {
        NSDictionary *dic=[Function ReadFromFile:Save_List Kind:Library_Cache];
        [arr_SaveList addObjectsFromArray:[dic objectForKey:@"data"]];
    }
}

-(void)btn_Action:(id)sender
{
    UIButton *btn=(UIButton *)sender;
    if(btn.tag==buttonTag)
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

//获取附近终端信息
- (void)getNearData {
    if([Function isConnectionAvailable])
    {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.mode = MBProgressHUDModeIndeterminate;
        hud.labelText = @"加载中...";//加载提示语言
        if(app.isPortal)
        {
            urlString=[NSString stringWithFormat:@"%@%@",KPORTAL_URL,KNear_List];
        }
        else
        {
            urlString=[NSString stringWithFormat:@"%@%@",kBASEURL,KNear_List];
        }
        NSURL *url = [ NSURL URLWithString :  urlString];
        ASIFormDataRequest *request = [ ASIFormDataRequest requestWithURL :url];
        request.tag = 102;
        request.delegate = self;
        [request setRequestMethod:@"POST"];
        
        [request setPostValue:[[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"account"]
                       forKey:KUSER_UID];
        [request setPostValue:[[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"secret"]
                       forKey:KUSER_PASSWORD];
        [request setPostValue:[[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"token"]
                       forKey:@"user.token"];
        [request setPostValue:[[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"db_ip"]
                       forKey:@"db_ip"];
        [request setPostValue:[[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"db_name"]
                       forKey:@"db_name"];
        
        
        [request setPostValue:app.str_nlng forKey:@"alng"];
        [request setPostValue:app.str_alat forKey:@"alat"];
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

//获取寻访计划信息
- (void)getWalkSignData {
    if([Function isConnectionAvailable])
    {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.mode = MBProgressHUDModeIndeterminate;
        hud.labelText = @"加载中...";//加载提示语言
        if(app.isPortal)
        {
            urlString=[NSString stringWithFormat:@"%@%@",KPORTAL_URL,KNear_List];
        }
        else
        {
            urlString=[NSString stringWithFormat:@"%@%@",kBASEURL,KNear_List];
        }
        NSURL *url = [ NSURL URLWithString :  urlString];
        ASIFormDataRequest *request = [ ASIFormDataRequest requestWithURL :url];
        request.tag = 103;
        request.delegate = self;
        [request setRequestMethod:@"POST"];
        
        [request setPostValue:[[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"account"]
                       forKey:KUSER_UID];
        [request setPostValue:[[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"secret"]
                       forKey:KUSER_PASSWORD];
        [request setPostValue:[[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"token"]
                       forKey:@"user.token"];
        [request setPostValue:[[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"db_ip"]
                       forKey:@"db_ip"];
        [request setPostValue:[[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"db_name"]
                       forKey:@"db_name"];
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


//首先定位 然后跟服务器进行交互
- (void)locationInfo {
    if (isIOS8) {
        //由于IOS8中定位的授权机制改变 需要进行手动授权
        self.locationManager = [[CLLocationManager alloc] init];
        //获取授权认证
        [self.locationManager requestAlwaysAuthorization];
        [self.locationManager requestWhenInUseAuthorization];
    }
    
    self.locService=[[BMKLocationService alloc]init];
    [self.locService startUserLocationService];
    self.locService.delegate = self;
}

-(void)Action_addSave:(UIButton *)btn
{
    BOOL isFlag=NO;
    NSDictionary *dic=[arr_CustomerList objectAtIndex:btn.tag];
    for (NSInteger i=0; i<arr_SaveList.count; i++)
    {
        NSDictionary *dic_data=[arr_SaveList objectAtIndex:i];
        if([[dic objectForKey:@"index_no"] isEqualToString:[dic_data objectForKey:@"index_no"]])
        {
            [SGInfoAlert showInfo:@"已收藏"
                          bgColor:[[UIColor darkGrayColor] CGColor]
                           inView:self.view
                         vertical:0.5];
            isFlag=YES;
            break;
        }
    }
    NSString *msg;
    if(isFlag)
    {
        msg=@"已收藏";
    }
    else
    {
        NSMutableDictionary *dic_3=[[NSMutableDictionary alloc]init];
        [dic_3 setObject:[dic objectForKey:@"glng"] forKey:@"glng"];
        [dic_3 setObject:[dic objectForKey:@"glat"] forKey:@"glat"];
        [dic_3 setObject:[dic objectForKey:@"gname"] forKey:@"gname"];
        [dic_3 setObject:[dic objectForKey:@"gaddress"] forKey:@"gaddress"];
        [dic_3 setObject:[dic objectForKey:@"index_no"] forKey:@"index_no"];
        [dic_3 setObject:[dic objectForKey:@"atu"] forKey:@"atu"];
        [arr_SaveList addObject:dic_3];
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSDictionary *dic_data=[NSDictionary dictionaryWithObject:arr_SaveList forKey:@"data"];
            NSString *str1= [Function achieveThe_filepath:Save_List Kind:Library_Cache];
            [Function Delete_TotalFileFromPath:str1];
            [Function creatTheFile:Save_List Kind:Library_Cache];
            [Function WriteToFile:Save_List File:dic_data Kind:Library_Cache];
            dispatch_async(dispatch_get_main_queue(), ^{
            });
        });
        msg=@"收藏成功";
    }
    [SGInfoAlert showInfo:msg
                  bgColor:[[UIColor darkGrayColor] CGColor]
                   inView:self.view
                 vertical:0.5];
}
-(void)Action_DeleteFromSave:(UIButton *)btn
{
    [arr_SaveList removeObjectAtIndex:btn.tag];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSDictionary *dic_data=[NSDictionary dictionaryWithObject:arr_SaveList forKey:@"data"];
        NSString *str1= [Function achieveThe_filepath:Save_List Kind:Library_Cache];
        [Function Delete_TotalFileFromPath:str1];
        [Function creatTheFile:Save_List Kind:Library_Cache];
        [Function WriteToFile:Save_List File:dic_data Kind:Library_Cache];
        dispatch_async(dispatch_get_main_queue(), ^{
        });
    });
    [tableView reloadData];
}
-(void)Get_CustomerList
{
    if([Function isConnectionAvailable])
    {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.mode = MBProgressHUDModeIndeterminate;
        hud.labelText = @"加载中...";//加载提示语言
        if(app.isPortal)
        {
            urlString=[NSString stringWithFormat:@"%@%@",KPORTAL_URL,KGET_CUSTOMER_List];
        }
        else
        {
            urlString=[NSString stringWithFormat:@"%@%@",kBASEURL,KGET_CUSTOMER_List];
        }
        NSURL *url = [ NSURL URLWithString :  urlString];
        ASIFormDataRequest *request = [ ASIFormDataRequest requestWithURL :url];
        request.delegate = self;
        [request setRequestMethod:@"POST"];
        
        [request setPostValue:[[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"account"]
                       forKey:KUSER_UID];
        [request setPostValue:[[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"secret"]
                       forKey:KUSER_PASSWORD];
        [request setPostValue:[[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"token"]
                       forKey:@"user.token"];
        [request setPostValue:[[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"db_ip"]
                       forKey:@"db_ip"];
        [request setPostValue:[[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"db_name"]
                       forKey:@"db_name"];
        
        
        [request setPostValue:self.searchBar.text forKey:@"gname"];
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
-(void)get_JsonString:(NSString *)jsonString
{
    SBJsonParser *parser = [[SBJsonParser alloc] init];
    NSDictionary *dict =[parser objectWithString: jsonString];
    if([[dict objectForKey:@"ret"] isEqualToString:@"0"])
    {
        //请求列表
        isSave=NO;
        arr_CustomerList=[dict objectForKey:@"CustomerList"];
        [tableView reloadData];
    }
    else
    {
        [SGInfoAlert showInfo:[dict objectForKey:@"message"]
                      bgColor:[[UIColor darkGrayColor] CGColor]
                       inView:self.view
                     vertical:0.5];
    }
}

- (void)jumpToBaiduMap:(UIButton *)sender {
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.labelText = @"加载中...";
    
    _indexPath = [NSIndexPath indexPathForRow:sender.tag inSection:0];
    jumpFlag = 1;
    BMKFlag = 1;
    [self locationInfo];
}

- (void)startNavi:(double)ori_x :(double)ori_y :(double)des_x :(double)des_y
{
    NSMutableArray *nodesArray = [[NSMutableArray alloc]initWithCapacity:2];

    //起点
    BNRoutePlanNode *startNode = [[BNRoutePlanNode alloc] init];
    startNode.pos = [[BNPosition alloc] init];
    startNode.pos.x = ori_x;
    startNode.pos.y = ori_y;
    startNode.pos.eType = BNCoordinate_BaiduMapSDK;
    [nodesArray addObject:startNode];
    
    //终点
    BNRoutePlanNode *endNode = [[BNRoutePlanNode alloc] init];
    endNode.pos = [[BNPosition alloc] init];
    endNode.pos.x = des_x;
    endNode.pos.y = des_y;
    endNode.pos.eType = BNCoordinate_BaiduMapSDK;
    [nodesArray addObject:endNode];
    
    //路径规划
    [BNCoreServices_RoutePlan startNaviRoutePlan:BNRoutePlanMode_Highway
                                       naviNodes:nodesArray
                                            time:nil
                                        delegete:self
                                        userInfo:nil];
}

#pragma mark ---- PPiFlatSegmentedControlDelegate method
-(void)selectPPSegmentIndex:(NSInteger)selectIndex {
    selectIndexTake = selectIndex;
    [UIView animateWithDuration:0.2 animations:^{
        redImageView.left = 107*selectIndexTake;
    }];
    switch (selectIndexTake) {
        case 0:
        {
            //收藏
            isSave=YES;
            isSearching=NO;
            self.searchBar.text=@"";
            [self.searchBar resignFirstResponder];
            [tableView reloadData];
        }
            break;
        case 1:
        {
            //终端查询
            isSave=NO;
            [self.searchBar resignFirstResponder];
            self.searchBar.text=@"";
            [tableView reloadData];
            BMKFlag = 1;
            [self locationInfo];
        }
            break;
        case 2:
        {
            [self getWalkSignData];
        }
            break;
        default:
            break;
    }
}

#pragma mark - BNNaviRoutePlanDelegate
//算路成功回调
-(void)routePlanDidFinished:(NSDictionary *)userInfo
{
    NSLog(@"算路成功");
    //路径规划成功，开始导航
    [BNCoreServices_UI showNaviUI:BN_NaviTypeReal delegete:self isNeedLandscape:YES];
}

//算路失败回调
- (void)routePlanDidFailedWithError:(NSError *)error andUserInfo:(NSDictionary *)userInfo
{
    NSLog(@"算路失败");
    if ([error code] == BNRoutePlanError_LocationFailed) {
        NSLog(@"获取地理位置失败");
    }
    else if ([error code] == BNRoutePlanError_LocationServiceClosed)
    {
        NSLog(@"定位服务未开启");
    }
}

//算路取消回调
-(void)routePlanDidUserCanceled:(NSDictionary*)userInfo {
    NSLog(@"算路取消");
}

#pragma mark - BNNaviUIManagerDelegate

//退出导航回调
-(void)onExitNaviUI:(NSDictionary*)extraInfo
{
    NSLog(@"退出导航");
}

//退出导航声明页面回调
- (void)onExitDeclarationUI:(NSDictionary*)extraInfo
{
    NSLog(@"退出导航声明页面");
}

-(void)onExitDigitDogUI:(NSDictionary*)extraInfo
{
    NSLog(@"退出电子狗页面");
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return NO;
}

- (BOOL)shouldAutorotate
{
    return NO;
}

#pragma mark ---- BaiduMap delegate method
- (void)didUpdateBMKUserLocation:(BMKUserLocation *)userLocation
{
    app.str_nlng = [NSString stringWithFormat:@"%f",userLocation.location.coordinate.longitude];
    app.str_alat = [NSString stringWithFormat:@"%f",userLocation.location.coordinate.latitude];
    
    if (BMKFlag == 1) {
        BMKFlag = 0;
        if (jumpFlag == 1) {
            jumpFlag = 0;
            if (app.str_nlng.integerValue > 0 && app.str_alat.integerValue > 0)
            {
                //检测引擎是否初始化
                if (![self checkServicesInited]) return;
                [MBProgressHUD hideHUDForView:self.view animated:YES];
                
                //共四种情况
                if (isSave) {
                    if (isSearching) {
                        NSNumber *localID = nil;
                        if (_indexPath.row < [searchByName count]) {
                            localID = [self.searchByName objectAtIndex:_indexPath.row];
                        } else {
                            localID = [self.searchByPhone objectAtIndex:_indexPath.row-[searchByName count]];
                        }
                        ContactPeople *contact = [self.contactDic objectForKey:localID];
                        [self startNavi:[app.str_nlng doubleValue]
                                       :[app.str_alat doubleValue]
                                       :[[contact.phoneArray objectAtIndex:3] doubleValue]
                                       :[[contact.phoneArray objectAtIndex:4] doubleValue]];
                    }else {
                        NSDictionary *tempDic = [arr_SaveList objectAtIndex:_indexPath.row];
                        [self startNavi:[app.str_nlng doubleValue]
                                       :[app.str_alat doubleValue]
                                       :[[tempDic objectForKey:@"glng"] doubleValue]
                                       :[[tempDic objectForKey:@"glat"] doubleValue]];
                    }
                }else {
                    NSDictionary *tempDic = [arr_CustomerList objectAtIndex:_indexPath.row];
                    [self startNavi:[app.str_nlng doubleValue]
                                   :[app.str_alat doubleValue]
                                   :[[tempDic objectForKey:@"glng"] doubleValue]
                                   :[[tempDic objectForKey:@"glat"] doubleValue]];
                }
            }
        }else {
            if (app.str_nlng.integerValue && app.str_alat) {
                [self getNearData];
            }
            [self.locService stopUserLocationService];
        }
    }
}

- (BOOL)checkServicesInited
{
    if(![BNCoreServices_Instance isServicesInited])
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示"
                                                            message:@"引擎尚未初始化完成，请稍后再试"
                                                           delegate:nil
                                                  cancelButtonTitle:@"我知道了"
                                                  otherButtonTitles:nil];
        [alertView show];
        return NO;
    }
    return YES;
}

#pragma mark -
#pragma mark TableView delegate methods
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 100;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if(isSearching)
    {
        if(isSave)
        {
            if ([self.searchBar.text length] <= 0)
            {
                if([self.contactDic count]==0)
                {
                    [self.view addSubview:imageView_Face];
                }
                else
                {
                    [imageView_Face removeFromSuperview];
                }
                return [self.contactDic count];
            } else
            {
                if([self.searchByName count] + [self.searchByPhone count]==0)
                {
                    [self.view addSubview:imageView_Face];
                }
                else
                {
                    [imageView_Face removeFromSuperview];
                }
                return [self.searchByName count] + [self.searchByPhone count];
            }
        }
        else
        {
            if(arr_CustomerList.count==0)
            {
                [self.view addSubview:imageView_Face];
            }
            else
            {
                [imageView_Face removeFromSuperview];
            }
            return arr_CustomerList.count;
        }
    }
    else
    {
        
        if(isSave)
        {
            if(arr_SaveList.count==0)
            {
                [self.view addSubview:imageView_Face];
            }
            else
            {
                [imageView_Face removeFromSuperview];
            }
            return arr_SaveList.count;
        }
        else
        {
            if(arr_CustomerList.count==0)
            {
                [self.view addSubview:imageView_Face];
            }
            else
            {
                [imageView_Face removeFromSuperview];
            }
             return arr_CustomerList.count;
        }
    }
}
- (UITableViewCell *)tableView:(UITableView *)tableView1 cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NotORCell *cell=(NotORCell*)[tableView1 dequeueReusableCellWithIdentifier:@"NotORCell"];
    if(cell==nil)
    {
        NSArray *nib ;
        nib= [[NSBundle mainBundle] loadNibNamed:@"NotORCell" owner:[NotORCell class] options:nil];
        
        cell = (NotORCell *)[nib objectAtIndex:0];
        cell.contentView.backgroundColor = [UIColor clearColor];
    }
    
    //删除Btn
    UIButton *btn=[UIButton buttonWithType:UIButtonTypeCustom];
    [btn.layer setMasksToBounds:YES];
    [btn.layer setCornerRadius:5.0];
    btn.backgroundColor=[UIColor redColor];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    btn.frame=CGRectMake(cell.frame.size.width-10-70, 14, 70, 29);
    btn.tag=indexPath.row;
    btn.titleLabel.font=[UIFont boldSystemFontOfSize:15.0];
    [cell addSubview:btn];
    
    //导航
    UIButton *btn1=[UIButton buttonWithType:UIButtonTypeCustom];
    [btn1.layer setMasksToBounds:YES];
    [btn1.layer setCornerRadius:5.0];
    btn1.backgroundColor=[UIColor colorWithRed:0 green:120/255.0 blue:0 alpha:1];
    [btn1 setBackgroundImage:ImageName(@"btn_color1.png") forState:UIControlStateNormal];
    [btn1 setBackgroundImage:ImageName(@"btn_color2.png") forState:UIControlStateHighlighted];
    [btn1 addTarget:self action:@selector(jumpToBaiduMap:) forControlEvents:UIControlEventTouchUpInside];
    [btn1 setTitle:@"导航" forState:UIControlStateNormal];
    btn1.frame=CGRectMake(cell.frame.size.width-10-70, 57, 70, 29);
    btn1.tag=indexPath.row;
    btn1.titleLabel.font=[UIFont boldSystemFontOfSize:15.0];
    [cell addSubview:btn1];
    
    if(isSearching)
    {
        if(isSave)
        {
            NSNumber *localID = nil;
            NSMutableString *matchString = [NSMutableString string];
            NSMutableArray *matchPos = [NSMutableArray array];
            if (indexPath.row < [searchByName count]) {
                localID = [self.searchByName objectAtIndex:indexPath.row];
                //姓名匹配 获取对应匹配的拼音串 及高亮位置
                if ([self.searchBar.text length]) {
                    [[SearchCoreManager share] GetPinYin:localID pinYin:matchString matchPos:matchPos];
                }
            } else {
                localID = [self.searchByPhone objectAtIndex:indexPath.row-[searchByName count]];
                NSMutableArray *matchPhones = [NSMutableArray array];
                
                //号码匹配 获取对应匹配的号码串 及高亮位置
                //我的订单里面不涉及号码 所以这个位置代码暂时没什么用
                if ([self.searchBar.text length]) {
                    [[SearchCoreManager share] GetPhoneNum:localID phone:matchPhones matchPos:matchPos];
                    [matchString appendString:[matchPhones objectAtIndex:0]];
                }
            }
            ContactPeople *contact = [self.contactDic objectForKey:localID];
            cell.lab_gname.text=contact.name;
            cell.lab_gaddress.text=[contact.phoneArray objectAtIndex:0];
            [btn setTitle:@"删除" forState:UIControlStateNormal];
            [btn addTarget:self action:@selector(Action_DeleteFromSave:) forControlEvents:UIControlEventTouchUpInside];
        }
        else
        {
            NSDictionary *dic=[arr_CustomerList objectAtIndex:indexPath.row];
            cell.lab_gname.text=[dic objectForKey:@"gname"];
            cell.lab_gaddress.text=[dic objectForKey:@"gaddress"];
            [btn setTitle:@"追加" forState:UIControlStateNormal];
            [btn addTarget:self action:@selector(Action_addSave:) forControlEvents:UIControlEventTouchUpInside];
        }
        cell.selectionStyle=UITableViewCellSelectionStyleGray;
    }
    else
    {
        NSDictionary *dic;
        if(isSave)
        {
            dic=[arr_SaveList objectAtIndex:indexPath.row];
            [btn setTitle:@"删除" forState:UIControlStateNormal];
            [btn addTarget:self action:@selector(Action_DeleteFromSave:) forControlEvents:UIControlEventTouchUpInside];
        }
        else
        {
            dic=[arr_CustomerList objectAtIndex:indexPath.row];
            [btn setTitle:@"追加" forState:UIControlStateNormal];
            [btn addTarget:self action:@selector(Action_addSave:) forControlEvents:UIControlEventTouchUpInside];
        }
        cell.lab_gname.text=[dic objectForKey:@"gname"];
        cell.lab_gaddress.text=[dic objectForKey:@"gaddress"];
        cell.selectionStyle=UITableViewCellSelectionStyleGray;
    }
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *dic;
    if(isSearching)
    {
        if(isSave)
        {
            NSNumber *localID = nil;
            NSMutableString *matchString = [NSMutableString string];
            NSMutableArray *matchPos = [NSMutableArray array];
            if (indexPath.row < [searchByName count])
            {
                localID = [self.searchByName objectAtIndex:indexPath.row];
                
                //姓名匹配 获取对应匹配的拼音串 及高亮位置
                if ([self.searchBar.text length])
                {
                    [[SearchCoreManager share] GetPinYin:localID pinYin:matchString matchPos:matchPos];
                }
            } else {
                localID = [self.searchByPhone objectAtIndex:indexPath.row-[searchByName count]];
                NSMutableArray *matchPhones = [NSMutableArray array];
                
                //号码匹配 获取对应匹配的号码串 及高亮位置
                if ([self.searchBar.text length]) {
                    [[SearchCoreManager share] GetPhoneNum:localID phone:matchPhones matchPos:matchPos];
                    [matchString appendString:[matchPhones objectAtIndex:0]];
                }
            }
            dic=[arr_SaveList objectAtIndex:[localID integerValue]];
        }
        else
        {
            dic=[arr_CustomerList objectAtIndex:indexPath.row];
        }
    }
    else
    {
        if(isSave)
        {
            dic=[arr_SaveList objectAtIndex:indexPath.row];
        }
        else
        {
            dic=[arr_CustomerList objectAtIndex:indexPath.row];
        }
    }
    //收藏
    if(!isSave)
    {
        BOOL isFlag=NO;
        for (NSInteger i=0; i<arr_SaveList.count; i++)
        {
            NSDictionary *dic_data=[arr_SaveList objectAtIndex:i];
            if([[dic objectForKey:@"index_no"] isEqualToString:[dic_data objectForKey:@"index_no"]])
            {
                [SGInfoAlert showInfo:@"已收藏"
                              bgColor:[[UIColor darkGrayColor] CGColor]
                               inView:self.view
                             vertical:0.5];
                isFlag=YES;
                break;
            }
        }
        if(!isFlag)
        {
            //把列表cells数据去取出添加到收藏列表
            NSMutableDictionary *dic_3=[[NSMutableDictionary alloc]init];
            [dic_3 setObject:[dic objectForKey:@"gname"] forKey:@"gname"];
            [dic_3 setObject:[dic objectForKey:@"gaddress"] forKey:@"gaddress"];
            [dic_3 setObject:[dic objectForKey:@"index_no"] forKey:@"index_no"];
            [dic_3 setObject:[dic objectForKey:@"atu"] forKey:@"atu"];
            [arr_SaveList addObject:dic_3];
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                NSDictionary *dic_data=[NSDictionary dictionaryWithObject:arr_SaveList forKey:@"data"];
                NSString *str1= [Function achieveThe_filepath:Save_List Kind:Library_Cache];
                [Function Delete_TotalFileFromPath:str1];
                [Function creatTheFile:Save_List Kind:Library_Cache];
                [Function WriteToFile:Save_List File:dic_data Kind:Library_Cache];
                dispatch_async(dispatch_get_main_queue(), ^{
                });
            });
        }
    }
    if([self.str_From isEqualToString:@"1"])//来自VisitVC
    {
        SignInViewController *signVC=[[SignInViewController alloc]initWithNibName:@"SignInViewController" bundle:nil ];
        signVC.str_isFrom_More=@"1";//巡访
        app.VC_notify=signVC;
        signVC.is_QR=NO;
        app.str_atu=[dic objectForKey:@"atu"];
        [self.navigationController pushViewController:signVC animated:YES];
    }
    else if([self.str_From isEqualToString:@"2"])//我的订单 Orderlist 来自SubmitOrder
    {
        app.isApproval=NO; //
        app.str_Product_material=@"0";//商品 不是从审批的路径进入的物料添加
        OrderListViewController *orderVC=[[OrderListViewController alloc]init];
        orderVC.strFrom = self.str_From;
        orderVC.cIndexNumber = [dic objectForKey:@"index_no"];
        orderVC.str_isFromOnlineOrder=@"0";//从我的订单-》actionSheet->列表-》再点击tableView进入的
        orderVC.is_QR=NO;
        orderVC.str_cindex_no= [dic objectForKey:@"index_no"];//从二维码获取终端编号
        orderVC.terminalName = [dic objectForKey:@"gname"];
        
        if (self.returnFlag == 1) {
            //退单
            orderVC.str_title=@"退单明细";
            orderVC.returnFlag = 1;
        }else {
            orderVC.str_title=@"添加订单";
        }
        [self.navigationController pushViewController:orderVC animated:YES];
    }
    else if([self.str_From isEqualToString:@"3"])//物料订单 Orderlist  来自 AddNewApproval
    {
        app.isApproval=YES;
        app.str_Product_material=@"1";//物料
        OrderListViewController *listVC=[[OrderListViewController alloc]init];
        listVC.strFrom = self.str_From;
        listVC.str_title=@"物料信息登记";
        listVC.str_cindex_no=[dic objectForKey:@"index_no"];//从二维码获取终端编号
        [self.navigationController pushViewController:listVC animated:NO];
    }
    else if([self.str_From isEqualToString:@"4"])//在线下订单 来自SignIn
    {
        //在线下订单
        app.isApproval=NO;
        app.str_Product_material=@"0";//商品  扫描条码时候扫商品
        OrderListViewController *onlineVC=[[OrderListViewController alloc]init];
        onlineVC.strFrom = self.str_From;
        onlineVC.str_cindex_no=[dic objectForKey:@"index_no"];
        onlineVC.str_isFromOnlineOrder=@"1";//在线下订单
        onlineVC.str_title=@"在线下订单";
        [self.navigationController pushViewController:onlineVC animated:YES];
    }
    else if([self.str_From isEqualToString:@"5"])//重扫二维码
    {
        app.str_atu=[dic objectForKey:@"atu"];
        [self.navigationController popViewControllerAnimated:YES];
    }
}
#pragma mark -
#pragma mark search bar delegate methods
- (void)searchBar:(UISearchBar *)_searchBar textDidChange:(NSString *)searchText
{
    isSearching=YES;
    if(isSave)
    {
        //searchByName 和 searchByPhone 初始化之后填入数据
        [[SearchCoreManager share] Search:searchText searchArray:nil nameMatch:searchByName phoneMatch:searchByPhone];
        [tableView  reloadData];
    }
}
-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    isSearching=NO;
    [self.searchBar resignFirstResponder];
    [tableView  reloadData];
}
-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [self.searchBar resignFirstResponder];
    if(!isSave)
    [self Get_CustomerList];
}

#pragma mark ---- ASI delegate method
-(void)requestFinished:(ASIHTTPRequest *)request {
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    
    if([request responseStatusCode]==200)
    {
        if ((request.tag == 102) || request.tag == 103) {
            NSString * jsonString  =  [request responseString];
            SBJsonParser *parser = [[SBJsonParser alloc] init];
            NSDictionary *dict =[parser objectWithString: jsonString];
            if([[dict objectForKey:@"ret"] isEqualToString:@"0"])
            {
                //请求列表
                isSave=NO;
                arr_CustomerList=[dict objectForKey:@"CustomerList"];
                [tableView reloadData];
            }
            else
            {
                [SGInfoAlert showInfo:[dict objectForKey:@"message"]
                              bgColor:[[UIColor darkGrayColor] CGColor]
                               inView:self.view
                             vertical:0.5];
            }
            return;
        }
        NSString * jsonString  =  [request responseString];
        [self get_JsonString:jsonString];
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

-(void)requestFailed:(ASIHTTPRequest *)request {
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    
    [SGInfoAlert showInfo:@"哎呀，服务器无响应，一会再试试吧"
                  bgColor:[[UIColor darkGrayColor] CGColor]
                   inView:self.view
                 vertical:0.5];
    // 请求响应失败，返回错误信息
    //Dlog(@"HTTP 响应码：%d",[request responseStatusCode]);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
