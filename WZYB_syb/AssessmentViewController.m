//
//  AssessmentViewController.m
//  WZYB_syb
//
//  Created by wzyb on 14-7-1.
//  Copyright (c) 2014年 WZYB. All rights reserved.
//

#import "AssessmentViewController.h"
#import "AppDelegate.h"
#import "KxMenu.h"

@interface AssessmentViewController () <MyDelegate_msgVC, MyDelegate_AdvancedSearch, ASIHTTPRequestDelegate> {
    AppDelegate* app;
    NSString* searchStr;
    NSDictionary* allDynamicDic;
    NSString* selectString;
}
@end

@implementation AssessmentViewController

- (id)initWithNibName:(NSString*)nibNameOrNil bundle:(NSBundle*)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
#pragma MyDelegate
- (void)Notify_AssessDetailView
{
    [self MyApply];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self All_Init];
    [self GetAllApply_dynamic];

    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    [defaults setInteger:0 forKey:NUM_ASG];

    app.isOnlyGoBack = NO;
    app.assessSearch = @"0";
    app.str_Date = [Function getYearMonthDay_Now];
    [[Advance_Search sharedInstance].arr_search removeAllObjects];
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    if (app.isOnlyGoBack) {
        app.isOnlyGoBack = NO;
    }
    else {
        if (![searchStr isEqualToString:@"1"]) {
            [self MyApply];
        }
        searchStr = @"";
    }
}
//通知
- (void)Notify_assVC
{
    if (self.isWillAssess) {
        [self Jpush_mention:YES];
    }
}

- (void)Notify_AdvancedSearch
{
    searchStr = @"1";
    [self MyApply]; //更新列表
}

- (void)All_Init
{
    searchStr = @"";
    app = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    auth = [[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"auth"];
    if (self.isWillAssess) //待审批事项
    {
        [self addNavTItle:self.titleString flag:2];
    }
    else //我的申请
    {
        [self addNavTItle:self.titleString flag:2];
    }
    //日历
    UIImageView* img_arrow = [[UIImageView alloc] init];
    img_arrow.frame = CGRectMake(Phone_Weight - 44 - 44 - 44, moment_status, 44, 44);
    img_arrow.image = [UIImage imageNamed:@"nav_menu_arrow.png"];
    [nav_View.view_Nav addSubview:img_arrow];

    tableView_Approval = [[UITableView alloc] initWithFrame:CGRectMake(0, 44 + moment_status, Phone_Weight, Phone_Height - moment_status - 44)];
    if ([auth isEqualToString:@"4"] && self.isWillAssess) {
        tableView_Approval.frame = CGRectMake(0, 44 + moment_status, Phone_Weight, Phone_Height - moment_status - 44);
    }
    [self Set_SegmentView];
    tableView_Approval.dataSource = self;
    tableView_Approval.delegate = self;
    tableView_Approval.backgroundColor = [UIColor clearColor];
    tableView_Approval.separatorStyle = UITableViewCellSeparatorStyleNone; //隐藏tableViewCell的分割线
    [self.view addSubview:tableView_Approval];

    NSDictionary* dic = [[BasicData sharedInstance].dic_BasicData objectForKey:@"MasterList"];
    arr_H9 = [dic objectForKey:@"H9"];
    selectString = [NSString string];
}

- (void)pushViewOpenOrClose
{
    tableView_Approval.top = self.pushView.bottom;
}

- (void)labelTapMethod
{
    if (self.isWillAssess) {
        //isFirstOpen=YES;//YES 才筛选出审批中状态的信息
        [self getAssessmentList];
    }
}

- (void)Is_Nothing
{
    if (arr_AssessList.count == 0) {
        [self.view addSubview:imageView_Face];
    }
    else {
        [imageView_Face removeFromSuperview];
    }
}
- (void)create_tableView
{
    [tableView_Approval reloadData];
}
- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
    return arr_AssessList.count;
}
- (CGFloat)tableView:(UITableView*)tableView heightForRowAtIndexPath:(NSIndexPath*)indexPath
{
    return 120;
}
- (UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{

    if (self.isWillAssess) //待办
    {
        AssessViewCell* cell = (AssessViewCell*)[tableView dequeueReusableCellWithIdentifier:@"AssessCell"];
        if (cell == nil) {
            NSArray* nib;
            nib = [[NSBundle mainBundle] loadNibNamed:@"AssessViewCell" owner:[AssessViewCell class] options:nil];
            cell = (AssessViewCell*)[nib objectAtIndex:0];
            cell.contentView.backgroundColor = [UIColor clearColor];
        }
        cell.backgroundColor = [UIColor clearColor];
        UIImageView* viewCell;
        viewCell = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, Phone_Weight, 120)];
        viewCell.image = [UIImage imageNamed:@"cell_message_background@2X.png"];
        [cell insertSubview:viewCell atIndex:0];
        viewCell = nil;
        NSDictionary* dic = [arr_AssessList objectAtIndex:indexPath.row];
        cell.lab_content.text = [dic objectForKey:@"rcontent"];
        cell.lab_uname.text = [dic objectForKey:@"uname"];
        cell.lab_date.text = [dic objectForKey:@"ins_date"];
        cell.lab_section.text = [dic objectForKey:@"relations"];
        cell.lab_applyMoney.text = [NSString stringWithFormat:@"%@元", [dic objectForKey:@"rsum"]];
        cell.lab_assessNumb.text = [NSString stringWithFormat:@"申请编号:%@", [dic objectForKey:@"req_index_no"]];
        /*
         exe_sts：0：审批中 1：拒绝 2：同意 3：终结
         rtype 申请类型arr_H9
         */
        cell.img_status.image = [UIImage imageNamed:[self return_AssessStatus:[dic objectForKey:@"exe_sts"]]];

        for (NSInteger i = 0; i < arr_H9.count; i++) {
            NSDictionary* dict = [arr_H9 objectAtIndex:i];
            if ([[dict objectForKey:@"cvalue"] isEqualToString:[dic objectForKey:@"rtype"]]) {
                cell.lab_type.text = [dict objectForKey:@"clabel"];
                break;
            }
            dict = nil;
        }
        cell.lab_type.backgroundColor = [UIColor colorWithRed:37.0 / 255.0 green:101.0 / 255.0 blue:171.0 / 255.0 alpha:1.0];
        cell.lab_type.layer.cornerRadius = 5.0;
        cell.lab_type.textAlignment = NSTextAlignmentCenter;
        cell.lab_type.textColor = [UIColor whiteColor];
        dic = nil;
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        return cell;
    }
    else //我的申请
    {
        Assess1TableViewCell* cell = (Assess1TableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"Assess1TableViewCell"];
        if (cell == nil) {
            NSArray* nib;
            nib = [[NSBundle mainBundle] loadNibNamed:@"Assess1TableViewCell" owner:[AssessViewCell class] options:nil];

            cell = (Assess1TableViewCell*)[nib objectAtIndex:0];
            cell.contentView.backgroundColor = [UIColor clearColor];
        }
        cell.backgroundColor = [UIColor clearColor];
        UIImageView* viewCell;
        viewCell = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, Phone_Weight, 120)];
        viewCell.image = [UIImage imageNamed:@"cell_message_background@2X.png"];
        [cell insertSubview:viewCell atIndex:0];
        viewCell = nil;

        NSDictionary* dic = [arr_AssessList objectAtIndex:indexPath.row];
        cell.lab_content.text = [dic objectForKey:@"rcontent"];
        cell.lab_date.text = [dic objectForKey:@"ins_date"];
        cell.lab_applyMoney.text = [NSString stringWithFormat:@"%@元", [dic objectForKey:@"rsum"]];

        /*
         exe_sts：0：审批中 1：拒绝 2：同意 3：终结
         rtype 申请类型arr_H9
         */
        cell.img_status.image = [UIImage imageNamed:[self return_AssessStatus:[dic objectForKey:@"exe_sts"]]];
        for (NSInteger i = 0; i < arr_H9.count; i++) {
            NSDictionary* dict = [arr_H9 objectAtIndex:i];
            if ([[dict objectForKey:@"cvalue"] isEqualToString:[dic objectForKey:@"rtype"]]) {
                cell.lab_type.text = [dict objectForKey:@"clabel"];
                break;
            }
            dict = nil;
        }
        cell.lab_type.backgroundColor = [UIColor colorWithRed:37.0 / 255.0 green:101.0 / 255.0 blue:171.0 / 255.0 alpha:1.0];
        cell.lab_type.layer.cornerRadius = 5.0;
        cell.lab_type.textAlignment = NSTextAlignmentCenter;
        cell.lab_type.textColor = [UIColor whiteColor];
        cell.lab_assessNumb.text = [NSString stringWithFormat:@"申请编号:%@", [dic objectForKey:@"index_no"]];
        dic = nil;
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        return cell;
    }
}
- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath
{
    NSDictionary* dic = [arr_AssessList objectAtIndex:indexPath.row];
    AssessmentDetailViewController* assVC = [[AssessmentDetailViewController alloc] init];
    assVC.str_index_no = [dic objectForKey:@"index_no"];

    if ([[dic objectForKey:@"rtype"] isEqualToString:@"0"]) //判断是否是物料申请
    {
        assVC.isMaterial = YES;
    }
    if (self.isWillAssess) //待审批列表
    {
        assVC.isFromWillAssess = YES;
        assVC.str_title = @"我的审批事项";
        assVC.str_req_index_no = [dic objectForKey:@"req_index_no"];
        for (NSInteger i = 0; i < arr_H9.count; i++) {
            NSDictionary* dict = [arr_H9 objectAtIndex:i];
            if ([[dict objectForKey:@"cvalue"] isEqualToString:[dic objectForKey:@"rtype"]]) {
                assVC.str_type = [dict objectForKey:@"clabel"];
                break;
            }
            dict = nil;
        }
    }
    else {
        assVC.isFromWillAssess = NO;
        assVC.str_title = @"申请事项";
        assVC.str_req_index_no = [dic objectForKey:@"index_no"];

        for (NSInteger i = 0; i < arr_H9.count; i++) {
            NSDictionary* dict = [arr_H9 objectAtIndex:i];
            if ([[dict objectForKey:@"cvalue"] isEqualToString:[dic objectForKey:@"rtype"]]) {
                assVC.str_type = [dict objectForKey:@"clabel"];

                break;
            }
            dict = nil;
        }
        dic = nil;
    }
    [self.navigationController pushViewController:assVC animated:YES];
}
- (NSString*)return_AssessStatus:(NSString*)str
{
    if ([str isEqualToString:@"3"]) {
        return @"cell_assess1_3.png";
    }
    else if ([str isEqualToString:@"1"]) { //拒绝
        return @"cell_assess1_1.png";
    }
    else if ([str isEqualToString:@"2"]) {
        return @"cell_assess1_2.png";
    }
    else //if([str isEqualToString:@"0"])
    {
        return @"cell_assess1_0.png";
    }

    // return @"";
}
- (void)Set_SegmentView
{
    for (NSInteger i = 0; i < 3; i++) {
        if (self.isOnTabbar && i == 0)
            continue;
        if (self.isWillAssess && (i == 1))
            continue;
        UIButton* btn = [UIButton buttonWithType:UIButtonTypeCustom];
        if (i == 0) //返回
        {
            btn.frame = CGRectMake(0, moment_status, 60, 44);
            btn.backgroundColor = [UIColor clearColor];
            [btn setBackgroundImage:[UIImage imageNamed:@"btn_color6.png"] forState:UIControlStateHighlighted];
            [btn setTitle:@"< 返回" forState:UIControlStateNormal];
            [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            btn.titleLabel.font = [UIFont systemFontOfSize:15];
        }
        else if (i == 1) //新审批
        {
            btn.backgroundColor = [UIColor clearColor];
            btn.frame = CGRectMake(Phone_Weight - 45, moment_status, 44, 44);
            [btn setBackgroundImage:[UIImage imageNamed:@"btn_color6.png"] forState:UIControlStateHighlighted];
            [btn setTitle:@"创建" forState:UIControlStateNormal];
            [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            btn.titleLabel.font = [UIFont systemFontOfSize:15];
        }
        else if (i == 2) //日历
        {
            btn.backgroundColor = [UIColor clearColor];
            btn.frame = CGRectMake(Phone_Weight * 0.5 - 44, moment_status, 44 * 2.5, 44);
            [btn setBackgroundImage:[UIImage imageNamed:@"nav_menu_arrow_back"] forState:UIControlStateHighlighted];
            btn_date = btn;
        }
        btn.tag = buttonTag + i;
        if (i == 2 && !self.isWillAssess) {
            [btn addTarget:self action:@selector(_refreshButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        }
        else {
            [btn addTarget:self action:@selector(btn_Action:) forControlEvents:UIControlEventTouchUpInside];
        }
        [self.view addSubview:btn];
    }
}
- (void)btn_Action:(id)sender
{
    UIButton* btn = (UIButton*)sender;
    if (btn.tag == buttonTag) //返回
    {
        if (!self.isWillAssess) {
            self.delegate = (id)app.VC_more;
            [self.delegate Notify_Ass];
        }
        [self.navigationController popViewControllerAnimated:YES];
    }
    else if (btn.tag == buttonTag + 1) //添加新审批
    {
        UIActionSheetViewController* actionVC = [[UIActionSheetViewController alloc] init];
        actionVC.str_H = @"H9";
        actionVC.str_title = @"审批类型";
        [self.navigationController pushViewController:actionVC animated:YES];
    }
    else if (btn.tag == buttonTag + 2) //日历
    {
        AdvancedSearchViewController* ad = [[AdvancedSearchViewController alloc] init];
        ad.str_Num = @"6";
        ad.str_Assess = @"1";
        [self.navigationController pushViewController:ad animated:YES];
    }
}

//下拉列表
- (void)_refreshButtonAction:(UIButton*)sender
{
    NSDictionary* dic = [[BasicData sharedInstance].dic_BasicData objectForKey:@"MasterList"];
    NSMutableArray* buttonArray = [NSMutableArray array];
    NSArray* H9Array = [dic objectForKey:@"H9"];
    for (NSDictionary* tempDic in H9Array) {
        KxMenuItem* item = [KxMenuItem menuItem:[tempDic objectForKey:@"clabel"]
                                          image:nil
                                         target:self
                                         action:@selector(pushMenuItem:)];
        [buttonArray addObject:item];
    }

    KxMenuItem* item = [KxMenuItem menuItem:@"全部类型"
                                      image:nil
                                     target:self
                                     action:@selector(pushMenuItem:)];
    [buttonArray addObject:item];

    [KxMenu showMenuInView:self.view
                  fromRect:sender.frame
                 menuItems:buttonArray];
}

//下拉列表action
- (void)pushMenuItem:(id)sender
{
    KxMenuItem* menu = (KxMenuItem*)sender;

    AdvancedSearchViewController* ad = [[AdvancedSearchViewController alloc] init];
    ad.str_Num = @"5";
    ad.str_Assess = @"1";

    if (![selectString isEqualToString:menu.title]) {
        selectString = [NSString stringWithFormat:@"%@", menu.title];
        [[Advance_Search sharedInstance].arr_search removeAllObjects];
    }

    if ([menu.title isEqualToString:@"全部类型"]) {
        ad.allTypeFlag = 1;
        ad.applyType = @"全部类型";
    }
    else {
        ad.dynamic_customer = [allDynamicDic objectForKey:[NavView return_index_H:@"H9" Label:menu.title]];
        ad.applyType = menu.title;
    }

    [self.navigationController pushViewController:ad animated:YES];
}

- (void)MyApply
{
    if (self.isWillAssess) {
        app.isOnlyGoBack = YES;
    }
    [self getAssessmentList];
}
- (NSString*)SettingURL_getAssessmentList:(NSString*)url
{
    NSString* string;
    if (self.isWillAssess) {
        if (![app.assessSearch isEqualToString:@"1"]) {
            string = [NSString stringWithFormat:@"%@%@", url, KGet_approve];
        }
        else {
            string = [NSString stringWithFormat:@"%@%@", url, KSearch_approve]; //点击搜索之后调用的action接口
        }
    }
    else {
        if (!app.applySearch) {
            string = [NSString stringWithFormat:@"%@%@", url, KGet_apply]; //1.0.4 修改接口
        }
        else {
            app.applySearch = 0;
            string = [NSString stringWithFormat:@"%@%@", url, KGet_SerApply]; //点击搜索之后调用的action接口
        }
    }
    return string;
}
- (void)getAssessmentList
{
    if ([Function isConnectionAvailable]) {
        MBProgressHUD* hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.mode = MBProgressHUDModeIndeterminate;
        hud.labelText = @"加载中..."; //加载提示语言
        if (app.isPortal && [app.assessSearch isEqualToString:@"0"]) {
            self.urlString = [self SettingURL_getAssessmentList:KPORTAL_URL];
        }
        else {
            self.urlString = [self SettingURL_getAssessmentList:kBASEURL];
        }
        NSURL* url = [NSURL URLWithString:self.urlString];
        ASIFormDataRequest* request = [ASIFormDataRequest requestWithURL:url];
        request.delegate = self;
        [request setPostValue:[[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"account"] forKey:KUSER_UID];
        [request setPostValue:[[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"secret"] forKey:KUSER_PASSWORD];
        [request setPostValue:[[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"token"] forKey:@"user.token"];
        [request setPostValue:[[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"db_ip"] forKey:@"db_ip"];
        [request setPostValue:[[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"db_name"] forKey:@"db_name"];

        if ([Advance_Search sharedInstance].arr_search.count > 0) {
            if (!self.isWillAssess) {
                [request setPostValue:[[Advance_Search sharedInstance].arr_search objectAtIndex:0] forKey:@"start_date"];
                [request setPostValue:[[Advance_Search sharedInstance].arr_search objectAtIndex:1] forKey:@"end_date"];
                if ([[[Advance_Search sharedInstance].arr_search objectAtIndex:2] isEqualToString:@"全部类型"]) {
                    [request setPostValue:[NavView return_index_H:@"H9" Label:@""] forKey:@"rtype"];
                }
                else {
                    [request setPostValue:[NavView return_index_H:@"H9" Label:[[Advance_Search sharedInstance].arr_search objectAtIndex:2]] forKey:@"rtype"];
                }
                [request setPostValue:[NavView return_index_H:@"H10" Label:[[Advance_Search sharedInstance].arr_search objectAtIndex:3]] forKey:@"exe_sts"];
                [request setPostValue:[[Advance_Search sharedInstance].arr_search objectAtIndex:4] forKey:@"minOrsum"];
                [request setPostValue:[[Advance_Search sharedInstance].arr_search objectAtIndex:5] forKey:@"maxOrsum"];
                [request setPostValue:app.str_index_no forKey:@"relations"];

                for (int i = 0; i < app.mutDynDic.count; i++) {
                    NSString* tempStr = [[Advance_Search sharedInstance].arr_search objectAtIndex:7 + i];
                    NSDictionary* tempDic = [app.mutDynDic objectAtIndex:i];
                    if ([Function StringIsNotEmpty:tempStr]) {
                        NSString* tempKey0 = [NSString stringWithFormat:@"dynamicList[%d].tindex_no", i];
                        NSString* tempKey1 = [NSString stringWithFormat:@"dynamicList[%d].data_type", i];
                        NSString* tempKey2 = nil;
                        if ([[tempDic objectForKey:@"rcontent"] integerValue]) {
                            tempKey2 = [NSString stringWithFormat:@"dynamicList[%d].rcontent", i];
                        }
                        else {
                            tempKey2 = [NSString stringWithFormat:@"dynamicList[%d].tcontent", i];
                        }

                        [request setPostValue:[tempDic objectForKey:@"index_no"] forKey:tempKey0];
                        [request setPostValue:[tempDic objectForKey:@"data_type"] forKey:tempKey1];
                        [request setPostValue:tempStr forKey:tempKey2];
                    }
                }
            }
            else {
                if ([app.assessSearch isEqualToString:@"1"]) {
                    [request setPostValue:[[Advance_Search sharedInstance].arr_search objectAtIndex:0] forKey:@"start_date"];
                    [request setPostValue:[[Advance_Search sharedInstance].arr_search objectAtIndex:1] forKey:@"end_date"];
                    [request setPostValue:[NavView return_index_H:@"H9" Label:[[Advance_Search sharedInstance].arr_search objectAtIndex:2]] forKey:@"rtype"];
                    [request setPostValue:[[Advance_Search sharedInstance].arr_search objectAtIndex:3] forKey:@"uname"];
                    [request setPostValue:[NavView return_index_H:@"H10" Label:[[Advance_Search sharedInstance].arr_search objectAtIndex:4]] forKey:@"exe_sts"];
                    [request setPostValue:[[Advance_Search sharedInstance].arr_search objectAtIndex:5] forKey:@"minOrsum"];
                    [request setPostValue:[[Advance_Search sharedInstance].arr_search objectAtIndex:6] forKey:@"maxOrsum"];
                }
            }
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
- (void)get_JsonString:(NSString*)jsonString Type:(NSString*)type
{
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    SBJsonParser* parser = [[SBJsonParser alloc] init];
    NSDictionary* dict = [parser objectWithString:jsonString];
    if ([[dict objectForKey:@"ret"] isEqualToString:@"0"]) {
        arr_AssessList = nil;
        if ([type isEqual:@"0"]) {
            arr_AssessList = [dict objectForKey:@"ApplyList"];
            [self create_tableView];
        }
        else {
            arr_AssessList = [dict objectForKey:@"ApproveList"];
            [self create_tableView];
        }
        [self Is_Nothing];
    }
    else {
        NSString* str;
        if ([type isEqual:@"0"]) {
            str = @"获取待办审批列表失败";
        }
        else {
            str = @"获取申请事项列表表失败";
        }
        [SGInfoAlert showInfo:str
                      bgColor:[[UIColor darkGrayColor] CGColor]
                       inView:self.view
                     vertical:0.5];
    }
}

//获取全部申请动态项目
- (void)GetAllApply_dynamic
{
    if ([Function isConnectionAvailable]) {
        MBProgressHUD* hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.mode = MBProgressHUDModeIndeterminate;
        hud.labelText = @"加载中..."; //加载提示语言

        if (app.isPortal) {
            self.urlString = [NSString stringWithFormat:@"%@%@", KPORTAL_URL, KAllApplyDynamic];
        }
        else {
            self.urlString = [NSString stringWithFormat:@"%@%@", kBASEURL, KAllApplyDynamic];
        }
        NSURL* url = [NSURL URLWithString:self.urlString];
        ASIFormDataRequest* request = [ASIFormDataRequest requestWithURL:url];
        request.delegate = self;
        request.tag = 101;
        [request setRequestMethod:@"POST"];
        [request setPostValue:[[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"account"] forKey:KUSER_UID];
        [request setPostValue:[[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"secret"] forKey:KUSER_PASSWORD];
        [request setPostValue:[[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"token"] forKey:@"user.token"];
        [request setPostValue:[[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"db_ip"] forKey:@"db_ip"];
        [request setPostValue:[[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"db_name"] forKey:@"db_name"];
        [request startAsynchronous]; //异步
    }
    else {
        [SGInfoAlert showInfo:@"当前网络不可用，请检查网络连接"
                      bgColor:[[UIColor darkGrayColor] CGColor]
                       inView:self.view
                     vertical:0.5];
    }
}

- (void)requestFinished:(ASIHTTPRequest*)request
{
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    if ([request responseStatusCode] == 200) {
        NSString* jsonString = [request responseString];
        SBJsonParser* parser = [[SBJsonParser alloc] init];
        NSDictionary* dict = [parser objectWithString:jsonString];
        if ([[dict objectForKey:@"ret"] isEqualToString:@"0"]) {
            if (request.tag == 101) {
                allDynamicDic = [dict objectForKey:@"DynamicList"];
                return;
            }
        }

        if (self.isWillAssess) {
            [self get_JsonString:jsonString Type:@"1"];
        }
        else {
            [self get_JsonString:jsonString Type:@"0"];
        }
    }
    else {
        [SGInfoAlert showInfo:@"发生异常,请稍后再试"
                      bgColor:[[UIColor darkGrayColor] CGColor]
                       inView:self.view
                     vertical:0.5];
        [NdUncaughtExceptionHandler Post_url:[NSString stringWithFormat:@"URL:%@,HTTP_Code%d", self.urlString, [request responseStatusCode]]];
    }
}

- (void)requestFailed:(ASIHTTPRequest*)request
{
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    [SGInfoAlert showInfo:@"哎呀，服务器无响应，一会再试试吧"
                  bgColor:[[UIColor darkGrayColor] CGColor]
                   inView:self.view
                 vertical:0.5];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
