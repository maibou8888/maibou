//
//  DailyViewController.m
//  WZYB_syb
//
//  Created by wzyb on 15-1-9.
//  Copyright (c) 2015年 WZYB. All rights reserved.
//

#import "DailyViewController.h"
#import "PPiFlatSegmentedControl.h"
#import "DairyCell.h"
#import "AppDelegate.h"
#import "Function.h"
#import "SubmitOrderViewController.h"
#import "VisitViewController.h"
#import "RegisterViewController.h"
#import "TasksAssignedViewController.h"
#import "AssessmentViewController.h"
#import "AdviceViewController.h"
#import "SecretViewController.h"
#import "Select_StorageViewController.h"
#import "Logistic_LocationViewController.h"
#import "HolidayViewController.h"
#import "ZBarSDK.h"
#import "ZbarCustomVC.h"
#import "MMDrawerBarButtonItem.h"
#import "MMDrawerController.h"
#import "Redlabel.h"
#import "SearchListViewController.h"
#import "SearchApplyViewController.h"
#import "SearchCustomerViewController.h"
#import "SearchSignViewController.h"
#import "KGModal.h"
#import <QuartzCore/QuartzCore.h>
#import "PresentView.h"
#import "ReturnOrderViewController.h"

@interface DailyViewController ()<PPiFlatSegmentedControlDelegate,UITableViewDelegate,UITableViewDataSource,zbarNewViewDelegate,ZBarReaderDelegate,PresentViewDelegate>
{
    AppDelegate *app;
    ZbarCustomVC *reader;
    PPiFlatSegmentedControl *segmented;
    
    UIScrollView *_scrollView;
    NSInteger selectIndexTake;           //取得当前点击的是segment的哪一块
    NSMutableArray *_data;               //tableViewCell名称数据可变数组
    NSMutableArray *_textData;           //tableViewCell描述数据可变数组
    NSMutableArray *_imageData;          //tableViewCell图片数据可变数组
    NSMutableArray *_keyData;
    NSDictionary *_dataDic;              //贴片数据字典
    NSDictionary *_unReadDic;            //未读的数据
    UIImageView  *redImageView;          //滑动红线
    
    NSString *_showString;               //cell上面的追加显示或不显示
    NSString *_urlString;
    NSMutableArray *_searchImageArray;
    NSMutableArray *_searchTextArray;
    NSMutableArray *_searchKeyArray;
    
    NSInteger taskNumber;
    NSInteger assgNumber;
    NSInteger mesgNumber;
    
    NSArray *_dataArray;
    MMDrawerController *mmDrawVC;
}
@property (nonatomic , retain) UITableView *dailyTableView;
@property (nonatomic , retain) Redlabel *messageRedLabel;
@property (nonatomic , retain) Redlabel *taskRedLabel;
@property (nonatomic , retain) Redlabel *approveRedLabel;
@property (nonatomic , retain) Redlabel *segmentRedLabel;
@end

@implementation DailyViewController

-(void)Notify_DaiVC {
    [self getUnReadMessageNumber];
}

-(void)Notify_DaiVC_Assign {
    [self getUnReadMessageNumber];
}

-(void)Notify_DaiVC_mesage {
    [self addRedLabelMthod_mesg];
    [self showBadgeNumber];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.showPushView = NO;
    [self addNavTItle:@"日常" flag:1];
    reader = [ZbarCustomVC getSingle];  //ios6
    app = (AppDelegate *)[UIApplication sharedApplication].delegate;
    app.dairyVC = self;
    app.dairy_AssgVC = self;
    app.dairy_MesgVC = self;
    
    [self _initView];
}

- (void)viewWillAppear:(BOOL)animated {
    if ([app.quickString isEqualToString:@"1"]) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        _showString = [defaults objectForKey:SHOW];
        
        if([Function judgeFileExist:Quick_List Kind:Library_Cache])
        {
            NSDictionary *dic=[Function ReadFromFile:Quick_List Kind:Library_Cache];
            _searchTextArray  = [dic objectForKey:TEXT];
            _searchImageArray = [dic objectForKey:IMAGE];
            _searchKeyArray   = [dic objectForKey:KEY];
        }
        
        if ([_showString isEqualToString:@"NO"]) {
            UIButton *btn_back=[UIButton buttonWithType:UIButtonTypeCustom];//签到按钮
            btn_back.frame=CGRectMake(0, moment_status, 60, 44);
            btn_back.backgroundColor=[UIColor clearColor];
            btn_back.tag=buttonTag-1;
            [btn_back addTarget:self action:@selector(dairyBack) forControlEvents:UIControlEventTouchUpInside];
            [nav_View.view_Nav  addSubview:btn_back];
            [btn_back setBackgroundImage:[UIImage imageNamed:@"btn_color6.png"] forState:UIControlStateHighlighted];
            [btn_back setTitle:@"< 返回" forState:UIControlStateNormal];
            [btn_back setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            btn_back.titleLabel.font=[UIFont systemFontOfSize:15];
        }
    }else {
        app.is_msg_open=YES;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self getUnReadMessageNumber];
        });
    }
}

- (void)_initView {
    selectIndexTake = 0;
    _searchTextArray  = [[NSMutableArray alloc] init];
    _searchImageArray = [[NSMutableArray alloc] init];
    _searchKeyArray   = [[NSMutableArray alloc] init];
    _dataArray = @[@"message",@"task",@"taskAssign",@"apply",@"approve",@"document"];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    _dataDic = [[NSDictionary alloc] initWithDictionary:[defaults objectForKey:@"TileTitle"]];
    
    if (![self.showDBtnString isEqualToString:@"YES"]) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom]; //左边三条线Btn
        button.frame = CGRectMake(12,31, 40, 22);
        if (isIOS6) {
            button.top = 11;
        }
        [button setImage:ImageName(@"draw") forState:UIControlStateNormal];
        [button addTarget:self action:@selector(leftDrawerButtonPress) forControlEvents:UIControlEventTouchUpInside];
        [nav_View.view_Nav addSubview:button];
    }
    
    [self _initPPSegment];
    [self _initTableView];
}

- (void)_initPPSegment {
    NSArray *itemArray = @[@{@"text":@"行销"},@{@"text":@"客户"},@{@"text":@"办公"}];
    segmented=[[PPiFlatSegmentedControl alloc] initWithFrame:CGRectMake(0,nav_View.view_Nav.height, 320, 44)
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

- (void)_initTableView
{
    _data      = [[NSMutableArray alloc] init];
    _textData  = [[NSMutableArray alloc] init];
    _imageData = [[NSMutableArray alloc] init];
    _keyData   = [[NSMutableArray alloc] init];
    
    [self _setData:0]; //最开始默认segment为0时的数据
    
    _dailyTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320,_data.count*70+_data.count*12+30)
                                                   style:UITableViewStyleGrouped];
    _scrollView = [[UIScrollView alloc] initWithFrame:_dailyTableView.frame];
    _scrollView.contentSize = CGSizeMake(320, _dailyTableView.height +100);
    _scrollView.top = segmented.bottom;
    
    _scrollView.backgroundColor = [UIColor colorWithPatternImage:ImageName(@"scrollViewBackground.png")];
    self.view.backgroundColor = [UIColor colorWithPatternImage:ImageName(@"scrollViewBackground.png")];
    
    [_scrollView addSubview:_dailyTableView];
    [self.view addSubview:_scrollView];
    
    _dailyTableView.delegate = self;
    _dailyTableView.dataSource = self;
    
    self.messageRedLabel = [[Redlabel alloc] initWithFrame:CGRectZero];
    self.taskRedLabel    = [[Redlabel alloc] initWithFrame:CGRectZero];
    self.approveRedLabel = [[Redlabel alloc] initWithFrame:CGRectZero];
    [self hiddenRedLabel];
    
    self.segmentRedLabel = [[Redlabel alloc] initWithFrame:CGRectMake(290, 13, 30, 17)];
    [segmented addSubview:self.segmentRedLabel];
    self.segmentRedLabel.hidden = YES;
}

#pragma mark ---- UITableViewDelegate and UITableViewDataSource method
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _data.count;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DairyCell *cell=(DairyCell*)[tableView dequeueReusableCellWithIdentifier:@"DairyCell"];
    if(cell==nil)
    {
        NSArray *nib ;
        nib= [[NSBundle mainBundle] loadNibNamed:@"DairyCell" owner:[DairyCell class] options:nil];
        cell = (DairyCell *)[nib objectAtIndex:0];
        cell.contentView.backgroundColor = [UIColor clearColor];
    }
   
    cell.dairyImage.image = ImageName([_imageData objectAtIndex:indexPath.section]);
    cell.topText.text = [_data objectAtIndex:indexPath.section];
    cell.bottomText.text = [_textData objectAtIndex:indexPath.section];
    if ([_showString isEqualToString:@"NO"]) {
        cell.addBtn.hidden = NO;
        if (isIOS6) {
            cell.addBtn.backgroundColor = [UIColor clearColor];
            [cell.addBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
            cell.addBtn.left-=15;
            cell.bottomText.width-=5;
        }
        cell.addBtn.tag = indexPath.section;
        [cell.addBtn addTarget:self action:@selector(addModelAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([_showString isEqualToString:@"NO"]) {
        return;
    }
    DairyCell *cell = (DairyCell *)[_dailyTableView cellForRowAtIndexPath:indexPath];
    NSString *titleString = cell.topText.text;
    NSString *topString = [_keyData objectAtIndex:indexPath.section];
    switch (selectIndexTake) {
        case 0:
        {
            if ([topString isEqualToString:@"order"])
            {
                //我的订单
                SubmitOrderViewController *sub=[[SubmitOrderViewController alloc]init];
                app.VC_SubmitOrder=sub;
                sub.titleString = titleString;
                [self.navigationController pushViewController:sub animated:YES];
            }if ([topString isEqualToString:@"stock"])
            {
                //仓库
                Select_StorageViewController *seVC=[[Select_StorageViewController alloc]init];
                seVC.titleString = titleString;
                [self.navigationController pushViewController:seVC animated:YES];
            }else if ([topString isEqualToString:@"gps"])
            {
                //GPS记录
                Logistic_LocationViewController *loc=[[Logistic_LocationViewController alloc]init];
                loc.titleString = titleString;
                [self presentViewController:loc animated:YES completion:nil];
            }else if ([topString isEqualToString:@"searchOrder"])
            {
                //订单查询
                SearchListViewController *searchListVC = [SearchListViewController new];
                [self.navigationController pushViewController:searchListVC animated:YES];
            }else if ([topString isEqualToString:@"salesRanking"])
            {
                //销售排名
                DocumentViewController *docVC=[[DocumentViewController alloc]init];
                docVC.titleString=titleString;
                docVC.str_Url=[self String_To_UrlString:SaleRank];
                docVC.str_isGraph=@"1";
                [self.navigationController pushViewController:docVC animated:YES];
            }else if ([topString isEqualToString:@"returnGoods"])
            {
                //退货登记
                ReturnOrderViewController *returnGoodsVC = [ReturnOrderViewController new];
                returnGoodsVC.titleString = titleString;
                app.VC_SubmitROrder=returnGoodsVC;
                [self.navigationController pushViewController:returnGoodsVC animated:YES];
            }
        }
            break;
        case 1:
        {
            if ([topString isEqualToString:@"customer"])
            {
                //新客户
                RegisterViewController *registerVC=[[RegisterViewController alloc]init];
                registerVC.titleString = titleString;
                registerVC.isRival=NO;
                app.VC_Register=registerVC;
                [self.navigationController  pushViewController:registerVC animated:YES];
            }else if ([topString isEqualToString:@"competitor"])
            {
                //竞争对手
                RegisterViewController *registerVC=[[RegisterViewController alloc]init];
                registerVC.titleString = titleString;
                registerVC.isRival=YES;
                app.VC_Register=registerVC;
                [self.navigationController  pushViewController:registerVC animated:YES];
            }else if ([topString isEqualToString:@"signQuery"])
            {
                //轨迹回放
                LocationViewController *loVC=[[LocationViewController alloc]init];
                loVC.titleString = titleString;
                loVC.str_from=@"1";
                [self.navigationController pushViewController:loVC animated:YES];
            }else if ([topString isEqualToString:@"searchCustomer"])
            {
                //客户查询
                SearchCustomerViewController *searchCustomerVC = [SearchCustomerViewController new];
                [self.navigationController pushViewController:searchCustomerVC animated:YES];
            }
        }
            break;
        case 2:
        {
            if ([topString isEqualToString:@"message"])
            {
                //消息通知
                app.New_msg=NO;
                MessageViewController *messageVC = [MessageViewController new];
                messageVC.titleString = titleString;
                app.VC_msg=messageVC;
                [self.navigationController pushViewController:messageVC animated:YES];
            }else if ([topString isEqualToString:@"task"])
            {
                //我的任务
                TasksAssignedViewController *taskVC=[[TasksAssignedViewController alloc]init];
                taskVC.titleString = titleString;
                taskVC.isMineTask=YES;
                app.VC_Task=taskVC;
                [self.navigationController pushViewController:taskVC animated:YES];
            }else if ([topString isEqualToString:@"taskAssign"])
            {
                //任务交办
                TasksAssignedViewController *taskVC=[[TasksAssignedViewController alloc]init];
                taskVC.titleString = titleString;
                taskVC.isMineTask=NO;
                app.VC_Task=taskVC;
                [self.navigationController pushViewController:taskVC animated:YES];
            }else if ([topString isEqualToString:@"apply"])
            {
                //我的申请
                AssessmentViewController *assVC=[[AssessmentViewController alloc]init];
                assVC.titleString = titleString;
                assVC.isWillAssess=NO;
                app.VC_Assessment=assVC;
                [self.navigationController pushViewController:assVC animated:YES];
            }else if ([topString isEqualToString:@"approve"])
            {
                //我的审批
                AssessmentViewController *assVC=[[AssessmentViewController alloc]init];
                assVC.titleString = titleString;
                assVC.isWillAssess=YES;
                app.VC_Assessment=assVC;
                [self.navigationController pushViewController:assVC animated:YES];
            }else if ([topString isEqualToString:@"document"])
            {
                //企业文档
                FileViewController *fileVC=[[FileViewController alloc]init];
                fileVC.titleString = titleString;
                [self.navigationController pushViewController:fileVC animated:YES];
            }else if ([topString isEqualToString:@"searchApply"])
            {
                //申请查询
                SearchApplyViewController *searchApply = [SearchApplyViewController new];
                [self.navigationController pushViewController:searchApply animated:YES];
            }else if ([topString isEqualToString:@"searchCheckin"])
            {
                //考勤查询
                SearchSignViewController *signVC = [SearchSignViewController new];
                [self.navigationController pushViewController:signVC animated:YES];
            }
        }
            break;
            
        default:
            break;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return 12;
    }
    return 6;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 6;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 70;
}

#pragma mark ---- PPiFlatSegmentedControlDelegate method
-(void)selectPPSegmentIndex:(NSInteger)selectIndex {
    selectIndexTake = selectIndex;
    [UIView animateWithDuration:0.2 animations:^{
        redImageView.left = 107*selectIndexTake;
    }];
    [self _setData:selectIndex];
    [self _resetTableView];
    dispatch_async(dispatch_get_main_queue(), ^{
        [_dailyTableView reloadData];
        if (selectIndex == 2) {
            [self addRedLabelMthod];
            [self addRedLabelMthod_assg];
            [self addRedLabelMthod_mesg];
            [self showBadgeNumber];
        }
    });
}

#pragma mark ---- privary method
//点击segment时刷新不同的数据
- (void)_setData:(NSInteger)selectIndex {
    NSArray *array = nil;
    NSArray *array1 = nil;
    [self _resetArrayData];
    
    if (selectIndex == 0) {
        [self hiddenRedLabel];
        array  = @[@"order",@"returnGoods",@"stock",@"gps",@"searchOrder",@"salesRanking"];
        array1 = @[@"order.png",@"returnGoods.png",@"stock.png",@"gps.png",@"bossOrder.png",@"salerank.png"];
    }else if (selectIndex == 1) {
        [self hiddenRedLabel];
        array  = @[@"customer",@"competitor",@"signQuery",@"searchCustomer"];
        array1 = @[@"newCustomer.png",@"opponent.png",@"route.png",@"bossCustomer.png"];
    }else if (selectIndex == 2) {
        [self showRedLabel];
        array  = @[@"message",@"task",@"taskAssign",@"apply",@"approve",@"document",@"searchApply",@"searchCheckin"];
        array1 = @[@"message.png",@"task.png",@"assign.png",@"apply.png",@"approve.png",@"document.png",@"bossApply.png",@"bossSign.png"];
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSInteger number = [defaults integerForKey:NUMBER];
        NSInteger number1 = [defaults integerForKey:NUM_ASG];
        NSInteger number2 = [defaults integerForKey:NUM_MES];
        if (number > 0) {
            self.taskRedLabel.hidden = NO;
        }else {
            self.taskRedLabel.hidden = YES;
        }
        if (number1 > 0) {
            self.approveRedLabel.hidden = NO;
        }else {
            self.approveRedLabel.hidden = YES;
        }
        if (number2 > 0) {
            self.messageRedLabel.hidden = NO;
        }else {
            self.messageRedLabel.hidden = YES;
        }
    }
    
    [self AddObject:array arrayImage:array1];
}

//将数组数据清空
- (void)_resetArrayData {
    if (_data.count || _textData.count || _imageData.count) {
        [_data removeAllObjects];
        [_keyData removeAllObjects];
        [_textData removeAllObjects];
        [_imageData removeAllObjects];
    }
}

//重新加载tableView和scrollView数据
- (void)_resetTableView {
    _dailyTableView.frame = CGRectMake(0, 0, 320,_data.count*70+_data.count*12+70);
    if (_dailyTableView.height > Phone_Height-64-44) {
        _scrollView.height = Phone_Height-64-44;
    }else {
        _scrollView.height = _dailyTableView.height;
    }
    _scrollView.top = segmented.bottom;
    _scrollView.contentSize = CGSizeMake(320, _dailyTableView.height);
}

//遍历数组然后插入相关数据
- (void)AddObject:(NSArray *)arrayText arrayImage:(NSArray *)arrayImage {
    if (arrayText.count && arrayImage.count)
    {
        for (int i = 0; i < arrayText.count; i ++)
        {
            if ([@"1" isEqualToString:[[_dataDic objectForKey:[arrayText objectAtIndex:i]]  objectForKey:@"authority"]])
            {
                [_data      addObject:[[_dataDic objectForKey:[arrayText objectAtIndex:i]]  objectForKey:@"title"]];
                [_textData  addObject:[[_dataDic objectForKey:[arrayText objectAtIndex:i]]  objectForKey:@"description"]];
                [_imageData addObject:[arrayImage objectAtIndex:i]];
                [_keyData   addObject:[arrayText objectAtIndex:i]];
            }
        }
    }
}

//返回action
- (void)dairyBack {
    NSDictionary *dic_data=[NSDictionary dictionaryWithObjectsAndKeys:_searchTextArray,TEXT,
                                                                      _searchImageArray,IMAGE,
                                                                            _searchKeyArray,KEY,nil];
    NSString *str1= [Function achieveThe_filepath:Quick_List Kind:Library_Cache];
    [Function Delete_TotalFileFromPath:str1];
    [Function creatTheFile:Quick_List Kind:Library_Cache];
    [Function WriteToFile:Quick_List File:dic_data Kind:Library_Cache];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:@"YES" forKey:SHOW];
    [defaults synchronize];
    
    [self.navigationController popViewControllerAnimated:YES];
}

//追加点击事件
- (void)addModelAction:(UIButton *)button {
    NSInteger flag = 0;
    NSString *topString = [_data objectAtIndex:button.tag];
    for (NSString *string in _searchTextArray) {
        if ([topString isEqualToString:string]) {
            flag = 1;
            break;
        }
    }
    if (flag) {
        [SGInfoAlert showInfo:@"此模块已添加"
                      bgColor:[[UIColor darkGrayColor] CGColor]
                       inView:self.view
                     vertical:0.5];
        return;
    }
    
    [_searchTextArray  insertObject:topString atIndex:(_searchTextArray.count-1)];
    [_searchImageArray insertObject:[_imageData objectAtIndex:button.tag] atIndex:(_searchTextArray.count-2)];
    [_searchKeyArray insertObject:[_keyData objectAtIndex:button.tag]   atIndex:(_searchKeyArray.count-1)];
    
    [SGInfoAlert showInfo:@"添加成功"
                  bgColor:[[UIColor darkGrayColor] CGColor]
                   inView:self.view
                 vertical:0.5];
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

//添加红色的未读标记label
- (void)addRedLabelMthod {
    taskNumber = 0;
    app.taskNumber = [[_unReadDic objectForKey:@"TaskCount"] integerValue];
    if (app.taskNumber > 0) {
        self.taskRedLabel.hidden = NO;
        self.taskRedLabel.text = [NSString stringWithFormat:@"%ld",(long)app.taskNumber];
        for (NSString *tempString in _dataArray) {
            if ([@"task" isEqualToString:tempString]) {
                break;
            }
            taskNumber++;
        }
        
        if(taskNumber == _dataArray.count) {
            self.taskRedLabel.hidden = YES; //没有找到我的任务则隐藏
        }
        
        double xt = 0.0;
        modf(taskNumber/4, &xt); //取模
        self.taskRedLabel.frame = CGRectMake(5, 12*(taskNumber+1)+70*taskNumber+3, 30, 16);
        if (isIOS6) {
            self.taskRedLabel.left = 12;
        }
    }else {
        self.taskRedLabel.hidden = YES;
    }
}

//添加红色的未读标记label
- (void)addRedLabelMthod_assg {
    assgNumber = 0;
    app.assgNumber = [[_unReadDic objectForKey:@"ApproveCount"] integerValue];
    if (app.assgNumber > 0) {
        self.approveRedLabel.hidden = NO;
        self.approveRedLabel.text = [NSString stringWithFormat:@"%ld",(long)app.assgNumber];
        for (NSString *tempString in _dataArray) {
            if ([@"approve" isEqualToString:tempString]) {
                break;
            }
            assgNumber++;
        }
        
        if(assgNumber == _dataArray.count) {
            self.approveRedLabel.hidden = YES; //没有找到我的审批则隐藏
        }

        self.approveRedLabel.frame = CGRectMake(5, 12*(assgNumber+1)+70*assgNumber+3, 30, 16);
        if (isIOS6) {
            self.approveRedLabel.left = 12;
        }
    }else {
        self.approveRedLabel.hidden = YES;
    }
}

//添加红色的未读标记label
- (void)addRedLabelMthod_mesg {
    mesgNumber = 0;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    app.mesgNumber = [defaults integerForKey:NUM_MES];
    if (app.mesgNumber > 0) {
        self.messageRedLabel.hidden = NO;
        self.messageRedLabel.text = [NSString stringWithFormat:@"%ld",(long)app.mesgNumber];
        for (NSString *tempString in _dataArray) {
            if ([@"message" isEqualToString:tempString]) {
                break;
            }
            mesgNumber++;
        }
        
        if(mesgNumber == _dataArray.count) {
            self.messageRedLabel.hidden = YES; //没有找到我的任务则隐藏
        }
        
        self.messageRedLabel.frame = CGRectMake(5, 12*(mesgNumber+1)+70*mesgNumber+3, 30, 17);
        if (isIOS6) {
            self.messageRedLabel.left = 12;
        }
    }else {
        self.messageRedLabel.hidden = YES;
    }
}

- (void)hiddenRedLabel {
    self.messageRedLabel.hidden = YES;
    self.taskRedLabel.hidden = YES;
    self.approveRedLabel.hidden = YES;
    
    if (self.messageRedLabel.superview) {
        [self.messageRedLabel removeFromSuperview];
        [self.taskRedLabel removeFromSuperview];
        [self.approveRedLabel removeFromSuperview];
    }
}

- (void)showRedLabel {
    self.messageRedLabel.hidden = NO;
    self.taskRedLabel.hidden = NO;
    self.approveRedLabel.hidden = NO;
    
    [self.dailyTableView addSubview:self.messageRedLabel];
    [self.dailyTableView addSubview:self.taskRedLabel];
    [self.dailyTableView addSubview:self.approveRedLabel];
}

- (void)showBadgeNumber {
    NSInteger number  = [[_unReadDic objectForKey:@"ApproveCount"] integerValue];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSInteger number1 = [defaults integerForKey:NUM_MES];
    NSInteger number2 = [[_unReadDic objectForKey:@"TaskCount"]    integerValue];
    if(number+number1+number2)
    {
        app.quickVC.tabBarItem.badgeValue = [NSString stringWithFormat:@"%ld",number+number1+number2];
        app.dairyVC.tabBarItem.badgeValue = [NSString stringWithFormat:@"%ld",number+number1+number2];
        self.segmentRedLabel.text = [NSString stringWithFormat:@"%ld",number+number1+number2];
        self.segmentRedLabel.hidden = NO;
    }
    else
    {
        app.quickVC.tabBarItem.badgeValue = nil;
        app.dairyVC.tabBarItem.badgeValue = nil;
        self.segmentRedLabel.hidden = YES;
    }
}

-(NSString *)String_To_UrlString:(NSString*)string
{
    NSString *urlString = [[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"portal_url"];
    if ([Function StringIsNotEmpty:urlString]) {
        NSString *str=[NSString stringWithFormat:@"%@%@&user.uid=%@&user.password=%@&user.token=%@",urlString,string,[[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"account"],[[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"secret"],[[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"token"]];
        return str;
    }
    NSString *str=[NSString stringWithFormat:@"%@%@&user.uid=%@&user.password=%@&user.token=%@",kBASEURL,string,[[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"account"],[[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"secret"],[[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"token"]];
    return str;
}

- (void)getUnReadMessageNumber {
    if([Function isConnectionAvailable])
    {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.mode = MBProgressHUDModeIndeterminate;
        hud.labelText = @"加载中...";
        if(app.isPortal&&[app.assessSearch isEqualToString:@"0"])
        {
            _urlString = [NSString stringWithFormat:@"%@%@",KPORTAL_URL,KGet_UnRead];
        }
        else
        {
            _urlString = [NSString stringWithFormat:@"%@%@",kBASEURL,KGet_UnRead];
        }
        
        NSURL *url = [ NSURL URLWithString:_urlString];
        ASIFormDataRequest *request = [ ASIFormDataRequest requestWithURL :url];
        request.delegate = self;
        [request setPostValue:[[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"account"]forKey:KUSER_UID];
        [request setPostValue:[[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"secret"] forKey:KUSER_PASSWORD];
        [request setPostValue:[[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"token"] forKey:@"user.token"];
        [request setPostValue:[[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"db_ip"] forKey:@"db_ip"];
        [request setPostValue:[[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"db_name"] forKey:@"db_name"];
        [request startAsynchronous ];
    }
    else
    {
        [SGInfoAlert showInfo:@"当前网络不可用，请检查网络连接"
                      bgColor:[[UIColor darkGrayColor] CGColor]
                       inView:self.view
                     vertical:0.5];
    }
}

#pragma mark ---- zbar method
-(void)CreateTheQR
{
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

#pragma mark ---- isIOS7 委托回调
//ios7以上获取二维码方法
-(void)getCodeString:(NSString *)codeString {
    SignInViewController *sign=[[SignInViewController alloc]init];
    sign.str_isFrom_More=@"2";//2是考勤 1是巡访
    sign.atuString = codeString;
    [self.navigationController pushViewController:sign animated:YES];
}

-(void)dismissZbarAction {
    //Dlog(@"dismiss"); //iOS6
}
- (void)zbarDismissAction {
    //Dlog(@"dismiss"); //iOS7
}

#pragma mark ---- ASIHttpRequest method
-(void)requestFinished:(ASIHTTPRequest *)request {
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    if([request responseStatusCode]==200){
        NSString * jsonString  =  [request responseString];
        SBJsonParser *parser = [[SBJsonParser alloc] init];
        _unReadDic =[parser objectWithString: jsonString];
        [self addRedLabelMthod];
        [self addRedLabelMthod_assg];
        [self addRedLabelMthod_mesg];
        [self showBadgeNumber];
    }else{
        [SGInfoAlert showInfo:@"发生异常,请稍后再试"
                      bgColor:[[UIColor darkGrayColor] CGColor]
                       inView:self.view
                     vertical:0.5];
        [NdUncaughtExceptionHandler Post_url:[NSString stringWithFormat:@"URL:%@,HTTP_Code%d",_urlString,[request responseStatusCode]]];
    }
}

-(void)requestFailed:(ASIHTTPRequest *)request {
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    [SGInfoAlert showInfo:@"哎呀，服务器无响应，一会再试试吧"
                  bgColor:[[UIColor darkGrayColor] CGColor]
                   inView:self.view
                 vertical:0.5];
}


#pragma mark ---- isIOS7以下 委托回调
//ios7以下获取二维码方法
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
        SignInViewController *sign=[[SignInViewController alloc]init];
        sign.str_isFrom_More=@"2";//2是考勤 1是巡访
        sign.atuString = result;
        [self.navigationController pushViewController:sign animated:YES];
    }];
}

#pragma mark ---- presentView delegate method

- (void)presentViewDissmissAction {
    
    [[KGModal sharedInstance] closeAction:nil];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
