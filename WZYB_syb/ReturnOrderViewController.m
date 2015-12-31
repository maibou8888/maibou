//
//  ReturnOrderViewController.m
//  WZYB_syb
//
//  Created by wzyb on 15/6/29.
//  Copyright (c) 2015年 WZYB. All rights reserved.
//

#import "ReturnOrderViewController.h"
#import "AppDelegate.h"
#import "PresentView.h"
#import "KGModal.h"
#import "SubmitOrderTableViewCell.h"

@interface ReturnOrderViewController () <UIActionSheetDelegate, ZBarReaderDelegate, PresentViewDelegate, zbarNewViewDelegate, UITableViewDelegate, UITableViewDataSource> {
    AppDelegate* app;
    NSString* urlString;
    ZbarCustomVC* reader;
    NSMutableArray* arr_ListData; //存储列表数据
    UITableView* _RDTableView;
    NSInteger firstFlag;
}
@property (nonatomic, retain) NSString* str_qr_url; //获取二维码串
@end

@implementation ReturnOrderViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    //title
    app = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    if (StatusBar_System > 0)
        moment_status = 20;
    else
        moment_status = 0;
    app.str_temporary = @"";
    firstFlag = 0;
    [self.view addSubview:[nav_View NavView_Title1:self.titleString]];

    urlString = [NSString string];
    arr_ListData = [NSMutableArray array];
    [[Advance_Search sharedInstance].arr_search removeAllObjects];
    app.str_Date = [Function getYearMonthDay_Now];

    //返回button
    UIButton* btn_back = [UIButton buttonWithType:UIButtonTypeCustom];
    btn_back.frame = CGRectMake(0, moment_status, 60, 44);
    btn_back.backgroundColor = [UIColor clearColor];
    btn_back.tag = 0;
    [btn_back addTarget:self action:@selector(backAction:) forControlEvents:UIControlEventTouchUpInside];
    [nav_View.view_Nav addSubview:btn_back];
    [btn_back setBackgroundImage:[UIImage imageNamed:@"btn_color6.png"] forState:UIControlStateHighlighted];
    [btn_back setTitle:@"< 返回" forState:UIControlStateNormal];
    [btn_back setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    btn_back.titleLabel.font = [UIFont systemFontOfSize:15];

    //追加button
    UIButton* btn_SignIn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn_SignIn.frame = CGRectMake(Phone_Weight - 44, moment_status, 44, 44);
    [btn_SignIn setTitle:@"追加" forState:UIControlStateNormal];
    [btn_SignIn setBackgroundImage:[UIImage imageNamed:@"btn_color6.png"] forState:UIControlStateHighlighted];
    btn_SignIn.titleLabel.textColor = [UIColor whiteColor];
    btn_SignIn.titleLabel.font = [UIFont systemFontOfSize:15];
    btn_SignIn.backgroundColor = [UIColor clearColor];
    btn_SignIn.tag = 2;
    [btn_SignIn addTarget:self action:@selector(backAction:) forControlEvents:UIControlEventTouchUpInside];
    [nav_View.view_Nav addSubview:btn_SignIn];

    //日历
    UIImageView* img_arrow = [[UIImageView alloc] init];
    img_arrow.frame = CGRectMake(Phone_Weight - 44 - 44 - 44, moment_status, 44, 44);
    img_arrow.image = [UIImage imageNamed:@"nav_menu_arrow.png"];
    [nav_View.view_Nav addSubview:img_arrow];

    UIButton* btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(Phone_Weight / 2 - 44, moment_status, 44 * 2.5, 44);
    [btn setBackgroundImage:[UIImage imageNamed:@"nav_menu_arrow_back.png"] forState:UIControlStateHighlighted];
    btn.backgroundColor = [UIColor clearColor];
    btn.tag = 3;
    [btn addTarget:self action:@selector(backAction:) forControlEvents:UIControlEventTouchUpInside];
    [nav_View.view_Nav addSubview:btn];

    //tableView
    _RDTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, Phone_Weight, Phone_Height - 64) style:UITableViewStylePlain];
    _RDTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _RDTableView.backgroundColor = [UIColor clearColor];
    _RDTableView.dataSource = self;
    _RDTableView.delegate = self;
    [self.view addSubview:_RDTableView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self localMethod];
    if (app.order_refresh || !firstFlag) {
        firstFlag = 1;
        app.order_refresh = 0;
        [self Get_OrderList];
    }
}

- (void)Notify_AdvancedSearch
{
    [self Get_OrderList];
}

#pragma mark---- private method
- (void)backAction:(UIButton*)button
{
    if (button.tag == 0) {
        [self.navigationController popViewControllerAnimated:YES];
    }
    else if (button.tag == 2) {
        if ([AddProduct sharedInstance].arr_AddToList.count) {
            [[AddProduct sharedInstance].arr_AddToList removeAllObjects];
        }
        UIActionSheet* actionSheet = [[UIActionSheet alloc] initWithTitle:@"选择创建方式" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"扫二维码", @"列表", nil];

        [actionSheet showInView:self.view];
        actionSheet.tag = 1;
    }
    else if (button.tag == 3) {
        AdvancedSearchViewController* ad = [[AdvancedSearchViewController alloc] init];
        ad.str_Num = @"7";
        ad.returnFlag = 1;
        [self.navigationController pushViewController:ad animated:YES];
    }
}

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

- (void)SubmitTheQR_Inform:(NSString*)str_QR_atu
{
    if ([Function isConnectionAvailable]) {
        MBProgressHUD* hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.mode = MBProgressHUDModeIndeterminate;
        hud.labelText = @"加载中..."; //加载提示语言

        if (app.isPortal) {
            urlString = [NSString stringWithFormat:@"%@%@", KPORTAL_URL, KGET_CUSTOMER];
        }
        else {
            urlString = [NSString stringWithFormat:@"%@%@", kBASEURL, KGET_CUSTOMER];
        }
        NSURL* url = [NSURL URLWithString:urlString];
        ASIFormDataRequest* request = [ASIFormDataRequest requestWithURL:url];
        request.delegate = self;
        request.tag = 101;
        [request setRequestMethod:@"POST"];
        [request setPostValue:[[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"account"] forKey:KUSER_UID];
        [request setPostValue:[[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"secret"] forKey:KUSER_PASSWORD];
        [request setPostValue:[[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"token"] forKey:@"user.token"];
        [request setPostValue:[[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"db_ip"] forKey:@"db_ip"];
        [request setPostValue:[[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"db_name"] forKey:@"db_name"];

        [request setPostValue:str_QR_atu forKey:KATU];
        [request setPostValue:@"1" forKey:@"stype"]; //2考勤 1巡访 物料
        [request startAsynchronous]; //异步
    }
    else {
        [SGInfoAlert showInfo:@"当前网络不可用，请检查网络连接"
                      bgColor:[[UIColor darkGrayColor] CGColor]
                       inView:self.view
                     vertical:0.5];
    }
}

- (void)Get_OrderList
{
    if ([Function isConnectionAvailable]) {
        MBProgressHUD* hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.mode = MBProgressHUDModeIndeterminate;
        hud.labelText = @"加载中..."; //加载提示语言

        if (app.isPortal) {
            urlString = [NSString stringWithFormat:@"%@%@", KPORTAL_URL, KGet_ROrder];
        }
        else {
            urlString = [NSString stringWithFormat:@"%@%@", kBASEURL, KGet_ROrder];
        }
        NSURL* url = [NSURL URLWithString:urlString];
        ASIFormDataRequest* request = [ASIFormDataRequest requestWithURL:url];
        request.delegate = self;
        request.tag = 100;
        [request setRequestMethod:@"POST"];
        [request setPostValue:[[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"account"] forKey:KUSER_UID];
        [request setPostValue:[[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"secret"] forKey:KUSER_PASSWORD];
        [request setPostValue:[[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"token"] forKey:@"user.token"];
        [request setPostValue:[[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"db_ip"] forKey:@"db_ip"];
        [request setPostValue:[[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"db_name"] forKey:@"db_name"];

        if ([Advance_Search sharedInstance].arr_search.count > 0) {
            [request setPostValue:[[Advance_Search sharedInstance].arr_search objectAtIndex:0] forKey:@"start_date"];
            [request setPostValue:[[Advance_Search sharedInstance].arr_search objectAtIndex:1] forKey:@"end_date"];
            [request setPostValue:[[Advance_Search sharedInstance].arr_search objectAtIndex:2] forKey:@"minOrsum"];
            [request setPostValue:[[Advance_Search sharedInstance].arr_search objectAtIndex:3] forKey:@"maxOrsum"];
            [request setPostValue:[NavView return_YES_Or_NO:[[Advance_Search sharedInstance].arr_search objectAtIndex:4]] forKey:@"exe_sts"];
        }
        else {
            [request setPostValue:[Function getYearMonthDay_Now] forKey:@"start_date"];
            [request setPostValue:[Function getYearMonthDay_Now] forKey:@"end_date"];
        }
        [request startAsynchronous]; //异步
    }
    else {
        [SGInfoAlert showInfo:@"当前网络不可用，请检查网络连接"
                      bgColor:[[UIColor darkGrayColor] CGColor]
                       inView:self.view
                     vertical:0.5];
    }
}

- (void)JsonString:(NSString*)jsonString
{
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    SBJsonParser* parser = [[SBJsonParser alloc] init];
    NSDictionary* dict = [parser objectWithString:jsonString];
    if ([[dict objectForKey:@"ret"] isEqualToString:@"0"]) {
        NSDictionary* dic = [dict objectForKey:@"CustomerInfo"];
        if ([[[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"gbelongto"] isEqualToString:[dic objectForKey:@"gbelongto"]]) {
            app.isApproval = NO;
            app.str_Product_material = @"0"; //商品
            OrderListViewController* orderVC = [[OrderListViewController alloc] init];
            orderVC.str_title = @"退单明细";
            orderVC.returnFlag = 1;
            orderVC.str_isFromOnlineOrder = @"0"; //从订单列表来
            orderVC.cIndexNumber = [dic objectForKey:@"index_no"];
            orderVC.is_QR = YES;
            orderVC.str_cindex_no = [dic objectForKey:@"index_no"]; //从二维码获取终端编号
            [self.navigationController pushViewController:orderVC animated:YES];
        }
        else {
            //不是同一个部门弹出警告框
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"您不隶属该部门,不能下订单!" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
            [alert show];
            alert = nil;
        }
        dic = nil;
    }
    else {
        [SGInfoAlert showInfo:[dict objectForKey:@"message"]
                      bgColor:[[UIColor darkGrayColor] CGColor]
                       inView:self.view
                     vertical:0.5];
    }

    dict = nil;
}

- (void)get_JsonString:(NSString*)jsonString
{
    [MBProgressHUD hideHUDForView:self.view animated:YES];

    SBJsonParser* parser = [[SBJsonParser alloc] init];
    NSDictionary* dict = [parser objectWithString:jsonString];
    if ([[dict objectForKey:@"ret"] isEqualToString:@"0"]) {
        arr_ListData = [NSMutableArray array];
        [self localMethod];
        NSArray* dataArray = [dict objectForKey:@"ReturnList"];
        for (int i = 0; i < dataArray.count; i++) {
            [arr_ListData addObject:[dataArray objectAtIndex:i]];
        }

        if (arr_ListData.count) {
            [_RDTableView reloadData];
            [imageView_Face removeFromSuperview];
        }
        else {
            [self.view addSubview:imageView_Face];
        }
    }
    else {
        [SGInfoAlert showInfo:@"获取订单列表失败"
                      bgColor:[[UIColor darkGrayColor] CGColor]
                       inView:self.view
                     vertical:0.5];
    }

    dict = nil;
}

- (void)localMethod
{
    if ([Function judgeFileExist:ROrder_Local Kind:Library_Cache]) {
        NSInteger k = 0;
        NSInteger m = 0;
        NSMutableArray* orderLArray = [Function ReadFromFile:ROrder_Local WithKind:Library_Cache];
        for (int n = 0; n < arr_ListData.count; n++) {
            NSString* gnameString = [[arr_ListData objectAtIndex:n] objectForKey:@"tempIndexNumber_Rorder"];
            if (gnameString.integerValue) {
                [arr_ListData removeObjectAtIndex:n];
            }
        }

        for (int i = 0; i < orderLArray.count; i++) {
            for (int j = 0; j < arr_ListData.count; j++) {
                k = 0;
                NSString* gnameString = [[arr_ListData objectAtIndex:j] objectForKey:@"tempIndexNumber_Rorder"];
                NSString* gnameString1 = [[orderLArray objectAtIndex:i] objectForKey:@"tempIndexNumber_Rorder"];
                if ([gnameString isEqualToString:gnameString1]) {
                    m = j;
                    k = 1;
                    break;
                }
            }
            if (k == 0) {
                [arr_ListData insertObject:[orderLArray objectAtIndex:i] atIndex:0];
            }
            else {
                [arr_ListData removeObjectAtIndex:m];
                [arr_ListData insertObject:[orderLArray objectAtIndex:i] atIndex:m];
            }
        }
        [_RDTableView reloadData];
    }
}

#pragma mark---- custom zbar delegate
- (void)dismissZbarAction
{
    //Dlog(@"dismiss"); //iOS6
}
- (void)zbarDismissAction
{
    //Dlog(@"dismiss"); //iOS7
}

- (void)getCodeString:(NSString*)codeString
{
    self.str_qr_url = codeString;
    [self SubmitTheQR_Inform:codeString];
}

#pragma mark---- UIImagePickerController delegate method
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
                                   self.str_qr_url = result;
                                   [self SubmitTheQR_Inform:result];
                               }];
}

#pragma mark---- UITableView delegate and datasource
- (NSInteger)numberOfSectionsInTableView:(UITableView*)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
    return arr_ListData.count;
}
- (CGFloat)tableView:(UITableView*)tableView heightForRowAtIndexPath:(NSIndexPath*)indexPath;
{
    if (isPad)
        return 110;
    return 130;
}
- (UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
    SubmitOrderTableViewCell* cell = (SubmitOrderTableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"SubmitOrderTableViewCell"];
    if (cell == nil) {
        NSArray* nib;
        if (isPad) {
            nib = [[NSBundle mainBundle] loadNibNamed:@"SubmitOrderTableViewCell_ipad"
                                                owner:[SubmitOrderTableViewCell class]
                                              options:nil];
        }
        else {
            nib = [[NSBundle mainBundle] loadNibNamed:@"SubmitOrderTableViewCell"
                                                owner:[SubmitOrderTableViewCell class]
                                              options:nil];
        }
        cell = (SubmitOrderTableViewCell*)[nib objectAtIndex:0];
        cell.contentView.backgroundColor = [UIColor clearColor];
    }

    cell.shouldLabel.text = @"应付合计";
    cell.realLabel.text = @"实付合计";
    cell.codeLabel.text = @"退货编号";
    cell.takeLabel.hidden = YES;
    cell.img_isInstead.hidden = YES;
    cell.ctsLabel.top = 39;
    cell.img_exe_sts.top = 42;
    cell.backgroundColor = [UIColor clearColor];
    UIImageView* viewCell;
    viewCell = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, Phone_Weight, 120)];
    viewCell.image = [UIImage imageNamed:@"cell_message_background@2X.png"]; //白色背景图片
    [cell insertSubview:viewCell atIndex:0];
    viewCell = nil;

    NSDictionary* dic = [arr_ListData objectAtIndex:indexPath.row];
    NSString* tempIndexNumber_order = [dic objectForKey:@"tempIndexNumber_Rorder"];
    if (tempIndexNumber_order.integerValue > 0) {
        cell.lab_gname.text = [dic objectForKey:@"terminal"];
        cell.lab_should.text = [dic objectForKey:@"osum"];
        cell.lab_real.text = [dic objectForKey:@"orsum"];
        NSString* tempStr = [dic objectForKey:@"odiscount"];
        NSString* discountStr = [NSString stringWithFormat:@"%.0f%@", tempStr.floatValue * 100, @"%"];
        cell.lab_count_number.text = discountStr;
        cell.offLineLabel.hidden = NO;
        cell.offLineLabel.top = 15;
    }
    else {
        cell.lab_gname.text = [dic objectForKey:@"gname"];
        cell.lab_real.text = [NSString stringWithFormat:@"%@元", [dic objectForKey:@"rsum"]];
        cell.lab_should.text = [NSString stringWithFormat:@"%@元", [dic objectForKey:@"osum"]];
        cell.lab_count_number.text = [NSString stringWithFormat:@"%@%@", [dic objectForKey:@"odiscount"], @"%"];
        cell.offLineLabel.hidden = YES;
    }

    cell.lab_gname.top = 15;
    cell.lab_gcode.text = [dic objectForKey:@"index_no"]; //订单编号
    if ([[dic objectForKey:@"ctc_sts"] isEqualToString:@"0"]) //ctc_sts 0/不代收 1/代收
    {
        cell.img_isInstead.image = [UIImage imageNamed:@"cell_unimplement.png"]; //方块图片
    }
    else {
        cell.img_isInstead.image = [UIImage imageNamed:@"cell_implement.png"]; //对号方块图片
    }
    if ([[dic objectForKey:@"exe_sts"] isEqualToString:@"0"]) //exe_sts 0/未执行 1/已执行
    {
        cell.img_exe_sts.image = [UIImage imageNamed:@"cell_unimplement.png"];
    }
    else {
        cell.img_exe_sts.image = [UIImage imageNamed:@"cell_implement.png"];
    }
    cell.lab_time.text = [dic objectForKey:@"ins_date"];
    cell.img_am_pm.image = [UIImage imageNamed:[NavView returnPeriod:[dic objectForKey:@"ins_date"]]];
    cell.selectionStyle = UITableViewCellSelectionStyleNone; //无点击效果
    return cell;
}
- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath
{
    OrderListViewController* order = [[OrderListViewController alloc] init];
    order.str_isfromeDetail = @"1"; //是查看详细
    NSDictionary* dic = [arr_ListData objectAtIndex:indexPath.row];
    order.str_title = [NSString stringWithFormat:@"退单详细"];

    if (![Function StringIsNotEmpty:[dic objectForKey:@"tempIndexNumber_Rorder"]]) {
        order.str_index_no = [dic objectForKey:@"index_no"];
        order.cIndexNumber = [dic objectForKey:@"cindex_no"];
        order.returnFlag = 1;
    }
    else {
        [[AddProduct sharedInstance].arr_AddToList removeAllObjects];
        order.dataDic = dic;
        order.HIDFlag = 1;
        order.localFlag = 1;
        order.str_isfromeDetail = @"0";
        order.RDFlag = 1;
    }
    app.isApproval = NO;
    [self.navigationController pushViewController:order animated:YES];
    dic = nil;
}

#pragma mark ActionSheet delegate methods
- (void)actionSheet:(UIActionSheet*)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet.tag == 1) {
        if (buttonIndex == 0) {
            [self CreateTheQR];
        }
        else if (buttonIndex == 1) {
            NotQRViewController* notQR = [[NotQRViewController alloc] init];
            notQR.str_From = @"2"; //我的订单 Orderlist
            notQR.returnFlag = 1;
            [self.navigationController pushViewController:notQR animated:YES];
        }
    }
}

#pragma mark---- ASIHTTPRequest delegate method
- (void)requestFinished:(ASIHTTPRequest*)request
{
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    if (request.tag == 101) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];

        if ([request responseStatusCode] == 200) {
            NSString* jsonString = [request responseString];
            [self JsonString:jsonString];
        }
        else {
            [SGInfoAlert showInfo:@"发生异常,请稍后再试"
                          bgColor:[[UIColor darkGrayColor] CGColor]
                           inView:self.view
                         vertical:0.5];
            [NdUncaughtExceptionHandler Post_url:[NSString stringWithFormat:@"URL:%@,HTTP_Code%d", urlString, [request responseStatusCode]]];
        }
        return;
    }

    NSString* jsonString = [request responseString];
    [self get_JsonString:jsonString];
}

- (void)requestFailed:(ASIHTTPRequest*)request
{
    if (request.tag == 101) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];

        [SGInfoAlert showInfo:@"哎呀，服务器无响应，一会再试试吧"
                      bgColor:[[UIColor darkGrayColor] CGColor]
                       inView:self.view
                     vertical:0.5];
        return;
    }
    [MBProgressHUD hideHUDForView:self.view animated:YES];

    [SGInfoAlert showInfo:@"哎呀，服务器无响应，一会再试试吧"
                  bgColor:[[UIColor darkGrayColor] CGColor]
                   inView:self.view
                 vertical:0.5];
}
@end
