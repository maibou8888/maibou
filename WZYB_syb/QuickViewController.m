//
//  QuickViewController.m
//  WZYB_syb
//
//  Created by wzyb on 15-1-9.
//  Copyright (c) 2015年 WZYB. All rights reserved.
//

#import "QuickViewController.h"
#import "RegisterViewController.h"
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
#import "QuickCell.h"
#import "AppDelegate.h"
#import "ZBarSDK.h"
#import "ZbarCustomVC.h"
#import "DailyViewController.h"
#import "MMDrawerBarButtonItem.h"
#import "MMDrawerController.h"
#import "UIImageView+WebCache.h"
#import "SDWebImageDownloader.h"
#import "Redlabel.h"
#import "NewTabbarViewController.h"
#import "SearchListViewController.h"
#import "SearchApplyViewController.h"
#import "SearchCustomerViewController.h"
#import "SearchSignViewController.h"
#import "KGModal.h"
#import <QuartzCore/QuartzCore.h>
#import "PresentView.h"
#import "PresentView_loc.h"
#import "ReturnOrderViewController.h"

@interface QuickViewController () <UITableViewEventDelegate, UIGestureRecognizerDelegate, zbarNewViewDelegate, ZBarReaderDelegate, SDWebImageDownloaderDelegate, PresentViewDelegate, PresentViewDelegate_loc> {
    NSMutableArray* _quickTableImageData;
    NSMutableArray* _quickTableTextData;
    AppDelegate* app;
    CGFloat x;
    CGFloat y;
    NSInteger row;
    ZbarCustomVC* reader; //二维码对象
    MMDrawerController* mmDrawVC1;
    NSInteger taskNumber;
    NSInteger assgNumber;
    NSInteger mesgNumber;
    NSInteger timeNumber;
    NSInteger addNumber;
    NSArray* _adverArray;
    NSMutableArray* _keyArray;
    UIImageView* gpsView;
    NSString *urlString;
    NSDictionary *unReadMesDic;
}

@property (strong, nonatomic) UITableView* quickTableView;
@property (strong, nonatomic) UIScrollView* scrollView;
@property (strong, nonatomic) UILabel* redLabel;
@property (strong, nonatomic) UILabel* redAssignLabel;
@property (strong, nonatomic) UILabel* redMessageLabel;

@property (weak, nonatomic) IBOutlet UIImageView* topImageView;
@property (weak, nonatomic) IBOutlet UIScrollView* myScrollView;
@property (weak, nonatomic) IBOutlet UIButton* subBtn;

- (IBAction)walkSignAction:(id)sender;
- (IBAction)presentAcion:(id)sender;
- (IBAction)subAction:(id)sender;
@end

@implementation QuickViewController

- (void)Notify_quiVC
{
    [self getUnReadMessageNumber];
}

- (void)Notify_quiVC_Assign
{
    [self getUnReadMessageNumber];
}

- (void)Notify_quiVC_mesage
{
    [self addRedLabelMthod_mesg];
    [self showBadgeNumber];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.showPushView = NO;
    [self addNavTItle:[[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"coname"] flag:1];
    nav_View.backgroundColor = [UIColor redColor];
    if (isIOS6) {
        nav_View.topHeight = @"1";
    }
    [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(timerMethod) userInfo:nil repeats:YES];
    nav_View.backgroundColor = [UIColor clearColor];
    app = (AppDelegate*)[UIApplication sharedApplication].delegate;
    app.quickVC = self;
    app.qui_AssgVC = self;
    app.qui_MesgVC = self;
    reader = [ZbarCustomVC getSingle]; //ios6
    [self _initView];

    BOOL cameraFlag = [Function CanLocation];
    if (!cameraFlag) {
        PresentView_loc* presentView = [PresentView_loc getSingle];
        presentView.presentViewDelegate = self;
        presentView.frame = CGRectMake(0, 0, 240, 250);
        [[KGModal sharedInstance] showWithContentView:presentView andAnimated:YES];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    app.is_msg_open = YES;
    self.subBtn.hidden = YES;
    [self addGPSPNG];
    if ([app.quickString isEqualToString:@"1"]) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            if ([Function judgeFileExist:Quick_List Kind:Library_Cache]) {
                NSDictionary* dic = [Function ReadFromFile:Quick_List Kind:Library_Cache];
                NSMutableArray* tempArray = [dic objectForKey:TEXT];
                if (tempArray.count) {
                    _quickTableTextData = [dic objectForKey:TEXT];
                    _quickTableImageData = [dic objectForKey:IMAGE];
                    _keyArray = [dic objectForKey:KEY];
                }
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                _quickTableView.frame = CGRectMake(0, 0, 320, [self _getQuickRow] * 90 + 100);
                self.myScrollView.contentSize = CGSizeMake(320, Phone_Height > 480 ? (_quickTableView.height + 53) : _quickTableView.height + 140);
                [_quickTableView reloadData];
                
//                [self getUnReadMessageNumber];
            });
        });

        app.quickString = @"0";
    }
    else {
        dispatch_async(dispatch_get_main_queue(), ^{
            
//            [self getUnReadMessageNumber];
        });
    }
}

- (void)_initView
{
    timeNumber = 0;
    addNumber = 0;
    _quickTableTextData = [[NSMutableArray alloc] init];
    _quickTableImageData = [[NSMutableArray alloc] init];
    _keyArray = [NSMutableArray array];
    _adverArray = [NSArray array];

    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSString* isFirstString = [defaults objectForKey:FIRST];

    if ([Function judgeFileExist:Quick_List Kind:Library_Cache] && [isFirstString isEqualToString:@"1"]) {
        NSDictionary* dic = [Function ReadFromFile:Quick_List Kind:Library_Cache];
        _quickTableImageData = [dic objectForKey:IMAGE];
        _keyArray = [dic objectForKey:KEY];
        NSDictionary* dataDic = [[NSDictionary alloc] initWithDictionary:[defaults objectForKey:@"TileTitle"]]; //贴片数据
        for (NSInteger i = 0; i < _keyArray.count; i++) {
            if ([@"1" isEqualToString:[[dataDic objectForKey:[_keyArray objectAtIndex:i]] objectForKey:@"authority"]]) {
                [_quickTableTextData addObject:[[dataDic objectForKey:[_keyArray objectAtIndex:i]] objectForKey:@"title"]];
            }
            else {
                if (![[_keyArray objectAtIndex:i] isEqualToString:@"1"]) {
                    [_quickTableImageData removeObjectAtIndex:i];
                    [_keyArray removeObjectAtIndex:i];
                    i = 0;
                }
            }
            if ([[_keyArray objectAtIndex:i] isEqualToString:@"1"]) {
                [_quickTableTextData addObject:@"添加"];
                break;
            }
        }
    }
    else {
        NSArray* imageArray = [[NSArray alloc] initWithObjects:@"newCustomer.png",
                                               @"opponent.png", @"order.png", @"returnGoods.png", @"task.png",
                                               @"assign.png", @"apply.png", @"approve.png", @"gps.png", @"message.png", nil];

        NSArray* keyArray = [[NSMutableArray alloc]
            initWithObjects:@"customer", @"competitor", @"order", @"returnGoods",
            @"task", @"taskAssign", @"apply", @"approve", @"gps", @"message", nil];

        NSDictionary* dataDic = [[NSDictionary alloc] initWithDictionary:[defaults objectForKey:@"TileTitle"]]; //贴片数据
        for (NSInteger i = 0; i < keyArray.count; i++) {
            if ([@"1" isEqualToString:[[dataDic objectForKey:[keyArray objectAtIndex:i]] objectForKey:@"authority"]]) {
                [_quickTableTextData addObject:[[dataDic objectForKey:[keyArray objectAtIndex:i]] objectForKey:@"title"]];
                [_quickTableImageData addObject:[imageArray objectAtIndex:i]];
                [_keyArray addObject:[keyArray objectAtIndex:i]];
            }
        }
        [_quickTableTextData addObject:@"添加"];
        [_quickTableImageData addObject:@"addMore.png"];
        [_keyArray addObject:@"1"];

        NSDictionary* dic_data = [NSDictionary dictionaryWithObjectsAndKeys:_quickTableTextData, TEXT,
                                               _quickTableImageData, IMAGE, _keyArray, KEY, nil];
        NSString* str1 = [Function achieveThe_filepath:Quick_List Kind:Library_Cache];
        [Function Delete_TotalFileFromPath:str1];
        [Function creatTheFile:Quick_List Kind:Library_Cache];
        [Function WriteToFile:Quick_List File:dic_data Kind:Library_Cache];
    }

    _adverArray = [[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:ADVERT]; //获取广告数据
    [defaults setObject:@"1" forKey:FIRST]; //判断是不是第一次登录
    [defaults synchronize];

    NSString* backViewUrl = [[defaults objectForKey:APPBGIG] objectForKey:@"HomePageImage"];
    NSString* filepath = [Function achieveThe_filepath:[NSString stringWithFormat:@"%@/%@", MyFolder, HomeView]
                                                  Kind:Library_Cache];
    if ([Function judgeFileExist:HomeView Kind:Library_Cache]) {
        self.topImageView.image = [UIImage imageWithContentsOfFile:filepath];
    }
    else {
        //开始下载
        [SDWebImageDownloader downloaderWithURL:[NSURL URLWithString:backViewUrl]
                                       delegate:self
                                       userInfo:@"home"];
    }

    [self _addView];
}

- (void)_addView
{
    _quickTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, [self _getQuickRow] * 90 + 100)
                                                   style:UITableViewStylePlain];
    _quickTableView.delegate = self;
    _quickTableView.dataSource = self;
    [self.myScrollView addSubview:_quickTableView];
    self.myScrollView.contentSize = CGSizeMake(320, Phone_Height > 480 ? (_quickTableView.height + 53) : _quickTableView.height + 140);
    //tableView顶端线条
    UIImageView* imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 0.5)];
    imageView.image = ImageName(@"btn_color55.png");
    imageView.opaque = YES;
    [_quickTableView addSubview:imageView];

    //长按手势的添加
    UILongPressGestureRecognizer* longPressGr = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressToDo:)];
    longPressGr.minimumPressDuration = 1.0;
    longPressGr.delegate = self;
    [_quickTableView addGestureRecognizer:longPressGr];

    //三条杠button
    UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(12, 31, 40, 22);
    [button setImage:ImageName(@"draw") forState:UIControlStateNormal];
    [button addTarget:self action:@selector(leftDrawerButtonPress) forControlEvents:UIControlEventTouchUpInside];
    [nav_View.view_Nav addSubview:button];

    if (isIOS6) {
        button.top = 11;
    }

    self.redLabel = [[Redlabel alloc] initWithFrame:CGRectZero];
    self.redAssignLabel = [[Redlabel alloc] initWithFrame:CGRectZero];
    self.redMessageLabel = [[Redlabel alloc] initWithFrame:CGRectZero];

    [_quickTableView addSubview:self.redLabel];
    [_quickTableView addSubview:self.redMessageLabel];
    [_quickTableView addSubview:self.redAssignLabel];

    gpsView = [[UIImageView alloc] initWithImage:ImageName(@"ic_gps_icon.png")];
    gpsView.frame = CGRectZero;
}

#pragma mark---- UITableViewDataSource,UITableViewDelegate method
- (NSInteger)numberOfSectionsInTableView:(UITableView*)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger tableHeight = [self _getQuickRow];
    if (tableHeight >= 3) {
        if (section == 0) {
            return 3;
        }
        else if (section == 1) {
            return tableHeight - 3;
        }
    }
    if (section == 0) {
        return tableHeight;
    }
    return 0;
}

- (UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
    QuickCell* cell = (QuickCell*)[tableView dequeueReusableCellWithIdentifier:@"QuickCell"];
    if (cell == nil) {
        NSArray* nib;
        nib = [[NSBundle mainBundle] loadNibNamed:@"QuickCell" owner:[QuickCell class] options:nil];
        cell = (QuickCell*)[nib objectAtIndex:0];
        cell.contentView.backgroundColor = [UIColor clearColor];
    }

    if (indexPath.section == 0) {
        //判断是否超过数组count
        if (indexPath.row * 4 + 0 <= _quickTableImageData.count - 1) {
            [cell.firstButton setImage:ImageName([_quickTableImageData objectAtIndex:indexPath.row * 4 + 0])
                              forState:UIControlStateNormal];
            cell.firstButton.tag = 100 + indexPath.row * 4 + 0;
            cell.firstBackBtn.tag = 100 + indexPath.row * 4 + 0;
            [cell.firstLabel setText:[_quickTableTextData objectAtIndex:indexPath.row * 4 + 0]];
            [cell.firstButton addTarget:self action:@selector(_quickButtonAction:) forControlEvents:UIControlEventTouchUpInside];
            [cell.firstBackBtn addTarget:self action:@selector(_quickButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        }
        if (indexPath.row * 4 + 1 <= _quickTableImageData.count - 1) {
            [cell.secondButton setImage:ImageName([_quickTableImageData objectAtIndex:indexPath.row * 4 + 1])
                               forState:UIControlStateNormal];
            cell.secondButton.tag = 100 + indexPath.row * 4 + 1;
            cell.secondBackBtn.tag = 100 + indexPath.row * 4 + 1;
            [cell.secondLabel setText:[_quickTableTextData objectAtIndex:indexPath.row * 4 + 1]];
            [cell.secondButton addTarget:self action:@selector(_quickButtonAction:) forControlEvents:UIControlEventTouchUpInside];
            [cell.secondBackBtn addTarget:self action:@selector(_quickButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        }
        if (indexPath.row * 4 + 2 <= _quickTableImageData.count - 1) {
            [cell.thirdButton setImage:ImageName([_quickTableImageData objectAtIndex:indexPath.row * 4 + 2])
                              forState:UIControlStateNormal];
            cell.thirdButton.tag = 100 + indexPath.row * 4 + 2;
            cell.thirdBackBtn.tag = 100 + indexPath.row * 4 + 2;
            [cell.thirdLabel setText:[_quickTableTextData objectAtIndex:indexPath.row * 4 + 2]];
            [cell.thirdButton addTarget:self action:@selector(_quickButtonAction:) forControlEvents:UIControlEventTouchUpInside];
            [cell.thirdBackBtn addTarget:self action:@selector(_quickButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        }
        if (indexPath.row * 4 + 3 <= _quickTableImageData.count - 1) {
            [cell.fourthButton setImage:ImageName([_quickTableImageData objectAtIndex:indexPath.row * 4 + 3])
                               forState:UIControlStateNormal];
            cell.fourthButton.tag = 100 + indexPath.row * 4 + 3;
            cell.forthBackBtn.tag = 100 + indexPath.row * 4 + 3;
            [cell.fourthLabel setText:[_quickTableTextData objectAtIndex:indexPath.row * 4 + 3]];
            [cell.fourthButton addTarget:self action:@selector(_quickButtonAction:) forControlEvents:UIControlEventTouchUpInside];
            [cell.forthBackBtn addTarget:self action:@selector(_quickButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        }
    }
    else if (indexPath.section == 1) {
        //判断是否超过数组count
        if (indexPath.row * 4 + 12 <= _quickTableImageData.count - 1) {
            [cell.firstButton setImage:ImageName([_quickTableImageData objectAtIndex:indexPath.row * 4 + 12])
                              forState:UIControlStateNormal];
            cell.firstButton.tag = 100 + indexPath.row * 4 + 12;
            cell.firstBackBtn.tag = 100 + indexPath.row * 4 + 12;
            [cell.firstLabel setText:[_quickTableTextData objectAtIndex:indexPath.row * 4 + 12]];
            [cell.firstButton addTarget:self action:@selector(_quickButtonAction:) forControlEvents:UIControlEventTouchUpInside];
            [cell.firstBackBtn addTarget:self action:@selector(_quickButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        }
        if (indexPath.row * 4 + 13 <= _quickTableImageData.count - 1) {
            [cell.secondButton setImage:ImageName([_quickTableImageData objectAtIndex:indexPath.row * 4 + 13])
                               forState:UIControlStateNormal];
            cell.secondButton.tag = 100 + indexPath.row * 4 + 13;
            cell.secondBackBtn.tag = 100 + indexPath.row * 4 + 13;
            [cell.secondLabel setText:[_quickTableTextData objectAtIndex:indexPath.row * 4 + 13]];
            [cell.secondButton addTarget:self action:@selector(_quickButtonAction:) forControlEvents:UIControlEventTouchUpInside];
            [cell.secondBackBtn addTarget:self action:@selector(_quickButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        }
        if (indexPath.row * 4 + 14 <= _quickTableImageData.count - 1) {
            [cell.thirdButton setImage:ImageName([_quickTableImageData objectAtIndex:indexPath.row * 4 + 14])
                              forState:UIControlStateNormal];
            cell.thirdButton.tag = 100 + indexPath.row * 4 + 14;
            cell.thirdBackBtn.tag = 100 + indexPath.row * 4 + 14;
            [cell.thirdLabel setText:[_quickTableTextData objectAtIndex:indexPath.row * 4 + 14]];
            [cell.thirdButton addTarget:self action:@selector(_quickButtonAction:) forControlEvents:UIControlEventTouchUpInside];
            [cell.thirdBackBtn addTarget:self action:@selector(_quickButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        }
        if (indexPath.row * 4 + 15 <= _quickTableImageData.count - 1) {
            [cell.fourthButton setImage:ImageName([_quickTableImageData objectAtIndex:indexPath.row * 4 + 15])
                               forState:UIControlStateNormal];
            cell.fourthButton.tag = 100 + indexPath.row * 4 + 15;
            cell.forthBackBtn.tag = 100 + indexPath.row * 4 + 15;
            [cell.fourthLabel setText:[_quickTableTextData objectAtIndex:indexPath.row * 4 + 15]];
            [cell.fourthButton addTarget:self action:@selector(_quickButtonAction:) forControlEvents:UIControlEventTouchUpInside];
            [cell.forthBackBtn addTarget:self action:@selector(_quickButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        }
    }

    return cell;
}

- (UIView*)tableView:(UITableView*)tableView viewForFooterInSection:(NSInteger)section
{
    UIView* footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 100)];
    footerView.backgroundColor = [UIColor colorWithPatternImage:ImageName(@"QB.png")];

    UIImageView* topImageView1 = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 0.5)];
    topImageView1.image = ImageName(@"btn_color55.png");
    [footerView addSubview:topImageView1];

    UIImageView* bottomImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 99.5, 320, 0.5)];
    bottomImageView.image = ImageName(@"btn_color55.png");
    [footerView addSubview:bottomImageView];

    //广告scrollView
    _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 15, 320, 70)];
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.showsVerticalScrollIndicator = NO;
    _scrollView.contentSize = CGSizeMake(320 * 3, 70);
    _scrollView.delegate = self;
    _scrollView.pagingEnabled = YES;

    for (NSInteger i = 0; i < 3; i++) {
        UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(0, 0, 320, 70);
        button.tag = i;
        [button addTarget:self action:@selector(pressAdvertImage:) forControlEvents:UIControlEventTouchUpInside];

        UIImageView* imageView = [[UIImageView alloc] initWithFrame:CGRectMake(i * 320, 0, 320, 70)];
        [imageView setImageWithURL:[NSURL URLWithString:[[_adverArray objectAtIndex:i] objectForKey:@"image"]]
                  placeholderImage:nil];
        imageView.userInteractionEnabled = YES;
        [imageView addSubview:button];
        [_scrollView addSubview:imageView];
    }

    [footerView addSubview:_scrollView];
    return footerView;
}

- (CGFloat)tableView:(UITableView*)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0;
}

- (CGFloat)tableView:(UITableView*)tableView heightForFooterInSection:(NSInteger)section
{
    if (section == 0) {
        return 100;
    }
    return 0;
}

- (CGFloat)tableView:(BaseTableView*)tableView heightForRowAtIndexPath:(NSIndexPath*)indexPath
{
    return 90;
}

- (void)tableView:(BaseTableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)tableView:(UITableView*)tableView willDisplayCell:(UITableViewCell*)cell forRowAtIndexPath:(NSIndexPath*)indexPath
{
    if ([tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [tableView setSeparatorInset:UIEdgeInsetsZero];
    }

    if ([tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [tableView setLayoutMargins:UIEdgeInsetsZero]; // ios 8 newly added
    }

    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

#pragma mark---- UIGestureRecognizer delegate method
- (BOOL)gestureRecognizer:(UIGestureRecognizer*)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer*)otherGestureRecognizer
{
    return YES;
}

- (void)longPressToDo:(UILongPressGestureRecognizer*)gesture
{
    if (gesture.state == UIGestureRecognizerStateBegan) {
        CGPoint point = [gesture locationInView:_quickTableView];
        NSIndexPath* indexPath = [_quickTableView indexPathForRowAtPoint:point];
        if (indexPath == nil)
            return;

        //获取长按手势x坐标和当前的indexPath.row
        x = point.x;
        y = point.y;
        row = indexPath.row;

        //判断是不是长按了添加按键  如果是则return
        if ([[_quickTableTextData objectAtIndex:(row * 4 + x / 80)] isEqualToString:@"添加"]) {
            return;
        }
        if (y > 270) {
            self.subBtn.frame = CGRectMake(55 + [self _cal:x sub:80], 375 + [self _cal:y - 370 sub:90], 20, 20);
        }
        else {
            self.subBtn.frame = CGRectMake(55 + [self _cal:x sub:80], 5 + [self _cal:y sub:90], 20, 20);
        }
        self.subBtn.hidden = NO;
        [self.quickTableView addSubview:self.subBtn];
    }
}

#pragma mark---- private method
//计算行数
- (NSInteger)_getQuickRow
{
    if (_quickTableImageData.count % 4 == 0) {
        return _quickTableImageData.count / 4;
    }
    return _quickTableImageData.count / 4 + 1;
}

//点击cell的Btn执行的事件
- (void)_quickButtonAction:(UIButton*)button
{
    NSString* string = [_keyArray objectAtIndex:(button.tag - 100)];
    NSString* titleString = [_quickTableTextData objectAtIndex:(button.tag - 100)];
    if ([string isEqualToString:@"customer"]) {
        //新客户
        RegisterViewController* registerVC = [[RegisterViewController alloc] init];
        registerVC.isRival = NO;
        registerVC.titleString = titleString;
        app.VC_Register = registerVC;
        [self.navigationController pushViewController:registerVC animated:YES];
    }
    else if ([string isEqualToString:@"competitor"]) {
        //竞争对手
        RegisterViewController* registerVC = [[RegisterViewController alloc] init];
        registerVC.isRival = YES;
        registerVC.titleString = titleString;
        app.VC_Register = registerVC;
        [self.navigationController pushViewController:registerVC animated:YES];
    }
    else if ([string isEqualToString:@"order"]) {
        //我的订单
        SubmitOrderViewController* sub = [[SubmitOrderViewController alloc] init];
        app.VC_SubmitOrder = sub;
        sub.titleString = titleString;
        [self.navigationController pushViewController:sub animated:YES];
    }
    else if ([string isEqualToString:@"task"]) {
        //我的任务
        TasksAssignedViewController* taskVC = [[TasksAssignedViewController alloc] init];
        taskVC.isMineTask = YES;
        app.VC_Task = taskVC;
        taskVC.titleString = titleString;
        [self.navigationController pushViewController:taskVC animated:YES];
    }
    else if ([string isEqualToString:@"taskAssign"]) {
        //任务交办
        TasksAssignedViewController* taskVC = [[TasksAssignedViewController alloc] init];
        taskVC.isMineTask = NO;
        app.VC_Task = taskVC;
        taskVC.titleString = titleString;
        [self.navigationController pushViewController:taskVC animated:YES];
    }
    else if ([string isEqualToString:@"signQuery"]) {
        //轨迹回放
        LocationViewController* loVC = [[LocationViewController alloc] init];
        loVC.str_from = @"1";
        loVC.titleString = titleString;
        [self.navigationController pushViewController:loVC animated:YES];
    }
    else if ([string isEqualToString:@"apply"]) {
        //我的申请
        AssessmentViewController* assVC = [[AssessmentViewController alloc] init];
        assVC.isWillAssess = NO;
        app.VC_Assessment = assVC;
        assVC.titleString = titleString;
        [self.navigationController pushViewController:assVC animated:YES];
    }
    else if ([string isEqualToString:@"approve"]) {
        //我的审批
        AssessmentViewController* assVC = [[AssessmentViewController alloc] init];
        assVC.isWillAssess = YES;
        app.VC_Assessment = assVC;
        assVC.titleString = titleString;
        [self.navigationController pushViewController:assVC animated:YES];
    }
    else if ([string isEqualToString:@"gps"]) {
        //GPS记录
        Logistic_LocationViewController* loc = [[Logistic_LocationViewController alloc] init];
        loc.titleString = titleString;
        [self presentViewController:loc animated:YES completion:nil];
    }
    else if ([string isEqualToString:@"message"]) {
        //消息通知
        app.New_msg = NO;
        MessageViewController* messageVC = [MessageViewController new];
        app.VC_msg = messageVC;
        messageVC.titleString = titleString;
        [self.navigationController pushViewController:messageVC animated:YES];
    }
    else if ([string isEqualToString:@"stock"]) {
        //仓库信息
        Select_StorageViewController* seVC = [[Select_StorageViewController alloc] init];
        seVC.titleString = titleString;
        [self.navigationController pushViewController:seVC animated:YES];
    }
    else if ([string isEqualToString:@"document"]) {
        //企业文档
        FileViewController* fileVC = [[FileViewController alloc] init];
        fileVC.titleString = titleString;
        [self.navigationController pushViewController:fileVC animated:YES];
    }
    else if ([string isEqualToString:@"searchOrder"]) {
        //订单查询
        SearchListViewController* searchListVC = [SearchListViewController new];
        [self.navigationController pushViewController:searchListVC animated:YES];
    }
    else if ([string isEqualToString:@"searchApply"]) {
        //申请查询
        SearchApplyViewController* searchApply = [SearchApplyViewController new];
        [self.navigationController pushViewController:searchApply animated:YES];
    }
    else if ([string isEqualToString:@"searchCustomer"]) {
        //客户查询
        SearchCustomerViewController* searchCustomerVC = [SearchCustomerViewController new];
        [self.navigationController pushViewController:searchCustomerVC animated:YES];
    }
    else if ([string isEqualToString:@"searchCheckin"]) {
        //考勤查询
        SearchSignViewController* signVC = [SearchSignViewController new];
        [self.navigationController pushViewController:signVC animated:YES];
    }
    else if ([string isEqualToString:@"salesRanking"]) {
        //销售排名
        DocumentViewController* docVC = [[DocumentViewController alloc] init];
        docVC.titleString = titleString;
        docVC.str_Url = [self String_To_UrlString:SaleRank];
        docVC.str_isGraph = @"1";
        [self.navigationController pushViewController:docVC animated:YES];
    }
    else if ([string isEqualToString:@"returnGoods"]) {
        //退货登记
        ReturnOrderViewController* returnGoodsVC = [ReturnOrderViewController new];
        returnGoodsVC.titleString = titleString;
        app.VC_SubmitROrder = returnGoodsVC;
        [self.navigationController pushViewController:returnGoodsVC animated:YES];
    }
    else {
        app.quickString = @"1";
        NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:@"NO" forKey:SHOW];
        [defaults synchronize];

        NSDictionary* dic_data = [NSDictionary dictionaryWithObjectsAndKeys:_quickTableTextData, TEXT,
                                               _quickTableImageData, IMAGE,
                                               _keyArray, KEY, nil];
        NSString* str1 = [Function achieveThe_filepath:Quick_List Kind:Library_Cache];
        [Function Delete_TotalFileFromPath:str1];
        [Function creatTheFile:Quick_List Kind:Library_Cache];
        [Function WriteToFile:Quick_List File:dic_data Kind:Library_Cache];

        DailyViewController* dairyVC = [DailyViewController new];
        [dairyVC setShowDBtnString:@"YES"];
        [self.navigationController pushViewController:dairyVC animated:YES];
    }
}

//计算当前要显示的删除按键的位置
- (double)_cal:(double)value sub:(NSInteger)subValue
{
    double integer;
    modf(value / subValue, &integer); //取模
    return integer * subValue;
}

- (IBAction)walkSignAction:(id)sender
{
    //签到寻访
    VisitViewController* vis = [[VisitViewController alloc] init];
    app.VC_Visit = vis;
    [self.navigationController pushViewController:vis animated:YES];
}

- (IBAction)presentAcion:(id)sender
{
    //考勤
    if ([Function checkIsSimulator]) {
        return;
    }
    [self CreateTheQR];
}

//删除按键执行的方法
- (IBAction)subAction:(id)sender
{
    CGFloat number = 0;
    if (y > 270) {
        number = 12;
    }

    if (x >= 0 && x <= 80) {
        [_quickTableImageData removeObjectAtIndex:row * 4 + number];
        [_quickTableTextData removeObjectAtIndex:row * 4 + number];
        [_keyArray removeObjectAtIndex:row * 4 + number];
    }
    else if (x > 80 && x <= 160) {
        [_quickTableImageData removeObjectAtIndex:row * 4 + 1 + number];
        [_quickTableTextData removeObjectAtIndex:row * 4 + 1 + number];
        [_keyArray removeObjectAtIndex:row * 4 + 1 + number];
    }
    else if (x > 160 && x <= 240) {
        [_quickTableImageData removeObjectAtIndex:row * 4 + 2 + number];
        [_quickTableTextData removeObjectAtIndex:row * 4 + 2 + number];
        [_keyArray removeObjectAtIndex:row * 4 + 2 + number];
    }
    else if (x > 240 && x <= 320) {
        [_quickTableImageData removeObjectAtIndex:row * 4 + 3 + number];
        [_quickTableTextData removeObjectAtIndex:row * 4 + 3 + number];
        [_keyArray removeObjectAtIndex:row * 4 + 3 + number];
    }

    dispatch_async(dispatch_get_main_queue(), ^{
        _quickTableView.frame = CGRectMake(0, 0, 320, [self _getQuickRow] * 90 + 100);
        self.myScrollView.contentSize = CGSizeMake(320, Phone_Height > 480 ? (_quickTableView.height + 53) : _quickTableView.height + 140);
        [_quickTableView reloadData];
        [self getUnReadMessageNumber];
        [self addGPSPNG];
        self.subBtn.hidden = YES;
    });

    if ([Function judgeFileExist:Quick_List Kind:Library_Cache]) {
        NSDictionary* dic_data = [NSDictionary dictionaryWithObjectsAndKeys:_quickTableTextData, TEXT,
                                               _quickTableImageData, IMAGE, _keyArray, KEY, nil];
        NSString* str1 = [Function achieveThe_filepath:Quick_List Kind:Library_Cache];
        [Function Delete_TotalFileFromPath:str1];
        [Function creatTheFile:Quick_List Kind:Library_Cache];
        [Function WriteToFile:Quick_List File:dic_data Kind:Library_Cache];
    }
}

//点击三条杠执行的侧拉方法
- (void)leftDrawerButtonPress
{
    [self returnMMDrawVC1];
    [mmDrawVC1 toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
}

- (void)returnMMDrawVC1
{
    if (mmDrawVC1 != nil) {
        return;
    }
    mmDrawVC1 = (MMDrawerController*)self.parentViewController.parentViewController;
}

//添加红色的未读标记label
- (void)addRedLabelMthod
{
    taskNumber = 0;
    app.taskNumber = [[unReadMesDic objectForKey:@"TaskCount"] integerValue];
    if (app.taskNumber > 0) {
        self.redLabel.hidden = NO;
        self.redLabel.text = [NSString stringWithFormat:@"%ld", (long)app.taskNumber];
        for (NSString* tempString in _keyArray) {
            if ([@"task" isEqualToString:tempString]) {
                break;
            }
            taskNumber++;
        }

        if (taskNumber == _quickTableTextData.count) {
            self.redLabel.hidden = YES; //没有找到我的任务则隐藏
        }

        double xt = 0.0;
        modf(taskNumber / 4, &xt); //取模
        self.redLabel.frame = CGRectMake(80 * (taskNumber - xt * 4) + 8, 90 * xt + 4, 30, 17);
    }
    else {
        self.redLabel.hidden = YES;
    }
}

//添加红色的未读标记label
- (void)addRedLabelMthod_assg
{
    assgNumber = 0;
    app.assgNumber = [[unReadMesDic objectForKey:@"ApproveCount"] integerValue];
    if (app.assgNumber > 0) {
        self.redAssignLabel.hidden = NO;
        self.redAssignLabel.text = [NSString stringWithFormat:@"%ld", (long)app.assgNumber];
        for (NSString* tempString in _keyArray) {
            if ([@"approve" isEqualToString:tempString]) {
                break;
            }
            assgNumber++;
        }

        if (assgNumber == _quickTableTextData.count) {
            self.redAssignLabel.hidden = YES; //没有找到我的审批则隐藏
        }

        double xt = 0.0;
        modf(assgNumber / 4, &xt); //取模
        self.redAssignLabel.frame = CGRectMake(80 * (assgNumber - xt * 4) + 8, 90 * xt + 4, 30, 17);
    }
    else {
        self.redAssignLabel.hidden = YES;
    }
}

//添加红色的未读标记label
- (void)addRedLabelMthod_mesg
{
    mesgNumber = 0;
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    app.mesgNumber = [defaults integerForKey:NUM_MES];
    if (app.mesgNumber > 0) {
        self.redMessageLabel.hidden = NO;
        self.redMessageLabel.text = [NSString stringWithFormat:@"%ld", (long)app.mesgNumber];
        for (NSString* tempString in _keyArray) {
            if ([@"message" isEqualToString:tempString]) {
                break;
            }
            mesgNumber++;
        }
        
        if (mesgNumber == _quickTableTextData.count) {
            self.redMessageLabel.hidden = YES; //没有找到我的任务则隐藏
        }
        
        double xt = 0.0;
        modf(mesgNumber / 4, &xt); //取模
        self.redMessageLabel.frame = CGRectMake(80 * (mesgNumber - xt * 4) + 8, 90 * xt + 4, 30, 17);
    }
    else {
        self.redMessageLabel.hidden = YES;
    }
}

//添加红色的未读标记label
- (void)addGPSPNG
{
    NSInteger numberTemp = 0;
    if (app.gpsFlag1) {
        for (NSString* tempString in _keyArray) {
            if ([@"gps" isEqualToString:tempString]) {
                break;
            }
            numberTemp++;
        }

        if (numberTemp == _quickTableTextData.count) {
            return;
        }

        double xt = 0.0;
        modf(numberTemp / 4, &xt); //取模
        gpsView.frame = CGRectMake(80 * (numberTemp - xt * 4) + 8, 90 * xt + 8, 17, 17);
        [self.quickTableView addSubview:gpsView];
    }
    else {
        if (gpsView.superview) {
            [gpsView removeFromSuperview];
        }
    }
}

//点击广告
- (void)pressAdvertImage:(UIButton*)button
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[[_adverArray objectAtIndex:button.tag] objectForKey:@"link"]]];
}

- (void)timerMethod
{
    timeNumber++;
    if (timeNumber == 3) {
        timeNumber = 0;
    }
    [_scrollView scrollRectToVisible:CGRectMake(320.0 * timeNumber, 15.0, 320.0, 70.0) animated:YES];
}

- (void)showBadgeNumber
{
    NSInteger number  = [[unReadMesDic objectForKey:@"ApproveCount"] integerValue];
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSInteger number1 = [defaults integerForKey:NUM_MES];
    NSInteger number2 = [[unReadMesDic objectForKey:@"TaskCount"]    integerValue];
    if (number + number1 + number2) {
        app.quickVC.tabBarItem.badgeValue = [NSString stringWithFormat:@"%ld", number + number1 + number2];
        app.dairyVC.tabBarItem.badgeValue = [NSString stringWithFormat:@"%ld", number + number1 + number2];
    }
    else {
        app.quickVC.tabBarItem.badgeValue = nil;
        app.dairyVC.tabBarItem.badgeValue = nil;
    }
}

- (NSString*)String_To_UrlString:(NSString*)string
{
    NSString* str = [NSString stringWithFormat:@"%@%@&user.uid=%@&user.password=%@&user.token=%@", kBASEURL, string, [[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"account"], [[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"secret"], [[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"token"]];
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
            urlString = [NSString stringWithFormat:@"%@%@",KPORTAL_URL,KGet_UnRead];
        }
        else
        {
            urlString = [NSString stringWithFormat:@"%@%@",kBASEURL,KGet_UnRead];
        }
        
        NSURL *url = [ NSURL URLWithString:urlString];
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

#pragma mark---- zbar method
- (void)CreateTheQR
{
    BOOL cameraFlag = [Function CanOpenCamera];
    if (!cameraFlag) {
        PresentView* presentView = [PresentView getSingle];
        presentView.presentViewDelegate = self;
        presentView.frame = CGRectMake(0, 0, 240, 250);
        [[KGModal sharedInstance] showWithContentView:presentView andAnimated:YES];
        return;
    }
    if (isIOS7) {
        zbarNewViewController* zbarNew = [zbarNewViewController new];
        zbarNew.zbarNewDelegate = self;
        [self presentViewController:zbarNew
                           animated:YES
                         completion:^{
                         }];
    }
    else {
        [reader CreateTheQR:self];
    }
}

- (void)dismissZbarAction
{
    //Dlog(@"dismiss"); //iOS6
}
- (void)zbarDismissAction
{
    //Dlog(@"dismiss"); //iOS7
}

#pragma mark---- isIOS7 委托回调
//ios7以上获取二维码方法
- (void)getCodeString:(NSString*)codeString
{
    SignInViewController* sign = [[SignInViewController alloc] init];
    sign.str_isFrom_More = @"2"; //2是考勤 1是巡访
    sign.atuString = codeString;
    [self.navigationController pushViewController:sign animated:YES];
}

#pragma mark ---- ASIHttpRequest method
-(void)requestFinished:(ASIHTTPRequest *)request {
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    if([request responseStatusCode]==200){
        NSString * jsonString  =  [request responseString];
        SBJsonParser *parser = [[SBJsonParser alloc] init];
        unReadMesDic =[parser objectWithString: jsonString];
        [self addRedLabelMthod];
        [self addRedLabelMthod_assg];
        [self addRedLabelMthod_mesg];
        [self showBadgeNumber];
    }else{
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
}

#pragma mark---- isIOS7以下 委托回调
//ios7以下获取二维码方法
- (void)imagePickerController:(UIImagePickerController*)picker didFinishPickingMediaWithInfo:(NSDictionary*)info
{
    [picker dismissViewControllerAnimated:YES
                               completion:^{
                                   [picker removeFromParentViewController];
                                   UIImage* image = [info objectForKey:UIImagePickerControllerOriginalImage];
                                   //初始化
                                   ZBarReaderController* read = [ZBarReaderController new];
                                   //设置代理
                                   read.readerDelegate = self;
                                   CGImageRef cgImageRef = image.CGImage;
                                   ZBarSymbol* symbol = nil;
                                   id<NSFastEnumeration> results = [read scanImage:cgImageRef];
                                   for (symbol in results) {
                                       break;
                                   }
                                   NSString* result;
                                   if ([symbol.data canBeConvertedToEncoding:NSShiftJISStringEncoding])

                                   {
                                       result = [NSString stringWithCString:[symbol.data cStringUsingEncoding:NSShiftJISStringEncoding] encoding:NSUTF8StringEncoding];
                                   }
                                   else {
                                       result = symbol.data;
                                   }
                                   SignInViewController* sign = [[SignInViewController alloc] init];
                                   sign.str_isFrom_More = @"2"; //2是考勤 1是巡访
                                   sign.atuString = result;
                                   [self.navigationController pushViewController:sign animated:YES];
                               }];
}

#pragma mark---- SDWebImageDownloader delegate method
- (void)imageDownloader:(SDWebImageDownloader*)downloader
     didFinishWithImage:(UIImage*)image
{
    if ([downloader.userInfo isEqualToString:@"home"]) {
        NSData* imageData = UIImageJPEGRepresentation(image, 1.0);
        [Function DeleteTheFile:[NSString stringWithFormat:@"%@/%@", MyFolder, HomeView] Kind:Library_Cache];
        [Function creatTheFile:HomeView Kind:Library_Cache];
        [Function WriteToFile:HomeView File:imageData Kind:Library_Cache];

        NSString* filepath = [Function achieveThe_filepath:[NSString stringWithFormat:@"%@/%@", MyFolder, HomeView]
                                                      Kind:Library_Cache];
        self.topImageView.image = [UIImage imageWithContentsOfFile:filepath];
        return;
    }
}

#pragma mark---- presentView delegate method
- (void)presentViewDissmissAction
{
    [[KGModal sharedInstance] closeAction:nil];
}

- (void)presentViewDissmissAction_loc
{
    [[KGModal sharedInstance] closeAction:nil];
}

@end
