//
//  NewMoreViewController.m
//  WZYB_syb
//
//  Created by wzyb on 15-1-9.
//  Copyright (c) 2015年 WZYB. All rights reserved.
//

#import "NewMoreViewController.h"
#import "AdviceViewController.h"
#import "SecretViewController.h"
#import "NewMoreCell.h"
#import "AppDelegate.h"
#import "MMDrawerBarButtonItem.h"
#import "MMDrawerController.h"
#import "HolidayViewController.h"
#import "OfflineViewController.h"
#import "OfflineDemoViewController.h"
#import "presentView_Alert.h"
#import "KGModal.h"

@interface NewMoreViewController ()<UITableViewDataSource,UITableViewDelegate,CLLocationManagerDelegate,PresentViewDelegate_Alert>
{
    NSMutableArray *_tableData;
    NSMutableArray *_imageData;
    NSMutableArray *_keyData;
    AppDelegate *app;
    MMDrawerController *mmDrawVC;
    CLLocationManager *locationManager;
}

@property (nonatomic , retain) UITableView *tableView;
@end

@implementation NewMoreViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.showPushView = NO;
    [self addNavTItle:@"更多" flag:1];
    app = (AppDelegate *)[UIApplication sharedApplication].delegate;
    
    NSArray *keyArray  = @[@"reply",@"holiday",@"offline",@"clearCache",@"toolsDownload",
                           @"offlineMap",@"alertSetting",@"aboutUs"];
    NSArray *keyArray1 = @[@"problem.png",@"holiday.png",@"offline.png",@"clear.png",@"toolDown.png",
                           @"offLineMap.png",@"alertNotification",@"aboutUs.png"];
    
    _tableData = [NSMutableArray array];
    _imageData = [NSMutableArray array];
    _keyData   = [NSMutableArray array];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *dataDic = [[NSDictionary alloc] initWithDictionary:[defaults objectForKey:@"TileTitle"]]; //贴片数据
    for (int i = 0; i <keyArray.count; i ++) {
        if ([@"1" isEqualToString:[[dataDic objectForKey:[keyArray objectAtIndex:i]]  objectForKey:@"authority"]])
        {
            [_tableData addObject:[[dataDic objectForKey:[keyArray objectAtIndex:i]]  objectForKey:@"title"]];
            [_imageData addObject:[keyArray1 objectAtIndex:i]];
            [_keyData addObject:[keyArray objectAtIndex:i]];
        }
    }
    
    [self _initView];
}

- (void)_initView {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(12,31, 40, 22);
    if (isIOS6) {
        button.top = 11;
    }
    [button setImage:ImageName(@"draw") forState:UIControlStateNormal];
    [button addTarget:self action:@selector(leftDrawerButtonPress) forControlEvents:UIControlEventTouchUpInside];
    [nav_View.view_Nav addSubview:button];
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, nav_View.view_Nav.bottom, 320, Phone_Height-64-49)
                                              style:UITableViewStylePlain];
    [self.view addSubview:_tableView];
    _tableView.delegate = self;
    _tableView.dataSource = self;
}

- (void)leftDrawerButtonPress {
    [self returnMMDrawVC];
    [mmDrawVC toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
}

- (void)returnMMDrawVC {
    if (mmDrawVC != nil) {
        return;
    }
    mmDrawVC = (MMDrawerController*)self.parentViewController.parentViewController;
}

- (void)presentViewDissmissAction
{
    [[KGModal sharedInstance] closeAction:nil];
}

#pragma mark ---- UITableViewDataSource,UITableViewDelegate method
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _tableData.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NewMoreCell *cell = (NewMoreCell*)[tableView dequeueReusableCellWithIdentifier:@"NewMoreCell"];
    if(cell==nil)
    {
        NSArray *nib ;
        nib= [[NSBundle mainBundle] loadNibNamed:@"NewMoreCell" owner:[NewMoreCell class] options:nil];
        cell = (NewMoreCell *)[nib objectAtIndex:0];
        cell.contentView.backgroundColor = [UIColor clearColor];
    }
    cell.cellImageView.frame = CGRectMake(21, 15, 30, 30);
    cell.cellImageView.image = ImageName([_imageData objectAtIndex:indexPath.row]);
    cell.contentLabel.text = [_tableData objectAtIndex:indexPath.row];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *indexString = [_keyData objectAtIndex:indexPath.row];
    NSString *titleString = [_tableData objectAtIndex:indexPath.row];
    
    if ([indexString isEqualToString:@"reply"]) {
        //反馈
        AdviceViewController *fileVC=[[AdviceViewController alloc]init];
        fileVC.titleString = titleString;
        [self.navigationController pushViewController:fileVC animated:YES];
    }else if ([indexString isEqualToString:@"holiday"]) {
        //休假
        HolidayViewController *loc=[[HolidayViewController alloc]init];
        loc.titleString = titleString;
        [self.navigationController pushViewController:loc animated:YES];
    }else if ([indexString isEqualToString:@"offline"]) {
        //离线模式
        OfflineViewController *offLineVC = [OfflineViewController new];
        [self.navigationController pushViewController:offLineVC animated:YES];
    }else if ([indexString isEqualToString:@"clearCache"]) {
        //清除缓存
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                        message:@"您确定要清除所有缓存吗"
                                                       delegate:self
                                              cancelButtonTitle:@"取消"
                                              otherButtonTitles:@"确定", nil];
        [alert show];
        alert.tag=12;
    }else if ([indexString isEqualToString:@"toolsDownload"]) {
        //工具下载
        DocumentViewController *doc=[[DocumentViewController alloc]init];
        doc.titleString = @"工具下载";
        doc.str_only_Online=@"1";
        doc.str_Url=@"http://www.yunlingyilian.com/resources/tools_ios.html";
        [self.navigationController pushViewController:doc animated:YES];
    }else if ([indexString isEqualToString:@"offlineMap"]) {
        //离线地图包
        OfflineDemoViewController *offlineVC = [OfflineDemoViewController new];
        [self.navigationController pushViewController:offlineVC animated:YES];
    }else if ([indexString isEqualToString:@"alertSetting"]) {
        presentView_Alert* presentView = [presentView_Alert getSingle];
        presentView.presentViewDelegate = self;
        presentView.frame = CGRectMake(0, 0, 280, 206);
        [[KGModal sharedInstance] showWithContentView:presentView andAnimated:YES];
    }else if ([indexString isEqualToString:@"aboutUs"]) {
        //关于我们
        DocumentViewController *doc=[[DocumentViewController alloc]init];
        doc.titleString = titleString;
        doc.str_only_Online=@"1";
        doc.str_Url=@"http://yunlingyilian.com/about.html";
        [self.navigationController pushViewController:doc animated:YES];
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([tableView respondsToSelector:@selector(setSeparatorInset:)]){
        [tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [tableView setLayoutMargins:UIEdgeInsetsZero]; // ios 8 newly added
    }
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

#pragma mark ---- UIAlertView delegate method
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if(buttonIndex==1)
    {
        [SGInfoAlert showInfo:@" 已清除全部缓存 "
                      bgColor:[[UIColor darkGrayColor] CGColor]
                       inView:self.view
                     vertical:0.5];
        
        [Function DeleteTheFile:[NSString stringWithFormat:@"%@/%@",MyFolder,IsReadBefore] Kind:Library_Cache];//阅读已读未读
        [Function DeleteTheFile:[NSString stringWithFormat:@"%@/%@",MyFolder,Message_Notice] Kind:Library_Cache];//消息
        [Function DeleteTheFile:[NSString stringWithFormat:@"%@/%@",MyFolder,Clerk_list]  Kind:Library_Cache];//本地客户或竞争对手信息
        [Function DeleteTheFile:[NSString stringWithFormat:@"%@/%@",MyFolder,Save_List]  Kind:Library_Cache];//收藏终端
        [Function DeleteTheFile:[NSString stringWithFormat:@"%@/%@",MyFolder,CompanyLogo] Kind:Library_Cache];//企业Logo
        [Function DeleteTheFile:Office_Products Kind:Library_Cache];//文档
        [Function Delete_TotalFileFromPath];//所有缓存的网络图片
        [[AddProduct sharedInstance].arr_AddToList removeAllObjects];//订单数据
        [[IsRead  sharedInstance ].arr_isRead removeAllObjects];//已读通知数据
        [[NSURLCache sharedURLCache] removeAllCachedResponses];
        [app.array_message removeAllObjects];
    }
}
   
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
