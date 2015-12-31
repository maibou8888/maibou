//
//  RegisterViewController.m
//  WZYB_syb
//  客户登记ViewController
//  Created by wzyb on 14-6-27.
//  Copyright (c) 2014年 WZYB. All rights reserved.
//

#import "RegisterViewController.h"
#import "AdvancedSearchViewController.h"
#import "RegisterCell.h"
#import "AppDelegate.h"
#define FaceW 94
#define FaceH 54.5
@interface RegisterViewController () {
    AppDelegate* app;
    NSString* urlString;
    UIImageView* imageView_Face;
}
@end

@implementation RegisterViewController

- (id)initWithNibName:(NSString*)nibNameOrNil bundle:(NSBundle*)nibBundleOrNil
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
    [self Set_SegmentView];
    app.str_Date = [Function getYearMonthDay_Now];
    [[Advance_Search sharedInstance].arr_search removeAllObjects];
}
- (void)viewWillAppear:(BOOL)animated
{
    if (app.isOnlyGoBack) {
        app.isOnlyGoBack = NO;
    }
    else {
        [self get_NewOrFighterList];
    }
    [self localMethod];
}
#pragma mark MyDelegate
- (void)Notify_AddClerkOrRival:(NSString*)title //点击提交或更新之后执行的委托事件
{
    [SGInfoAlert showInfo:title
                  bgColor:[[UIColor darkGrayColor] CGColor]
                   inView:self.view
                 vertical:0.5];
    [self get_NewOrFighterList];
    [tableView_Register reloadData];
}
- (void)All_Init
{
    app = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    if (StatusBar_System > 0)
        moment_status = 20;
    else
        moment_status = 0;
    NavView* nav_View = [[NavView alloc] init];
    if (!self.isRival) {
        [self.view addSubview:[nav_View NavView_Title1:self.titleString]];
    }
    else {
        [self.view addSubview:[nav_View NavView_Title22:self.titleString]];
    }
    //返回按钮
    UIButton* btn_back = [UIButton buttonWithType:UIButtonTypeCustom];
    btn_back.frame = CGRectMake(0, moment_status, 60, 44);
    btn_back.backgroundColor = [UIColor clearColor];
    btn_back.tag = buttonTag + 4;
    [btn_back addTarget:self action:@selector(GoBack) forControlEvents:UIControlEventTouchUpInside];
    [nav_View.view_Nav addSubview:btn_back];

    [btn_back setBackgroundImage:[UIImage imageNamed:@"btn_color6.png"] forState:UIControlStateHighlighted];
    [btn_back setTitle:@"< 返回" forState:UIControlStateNormal];
    [btn_back setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    btn_back.titleLabel.font = [UIFont systemFontOfSize:15];
    //日历
    UIImageView* img_arrow = [[UIImageView alloc] init];
    img_arrow.frame = CGRectMake(Phone_Weight - 44 - 44 - 44, moment_status, 44, 44);
    img_arrow.image = [UIImage imageNamed:@"nav_menu_arrow.png"];
    [nav_View.view_Nav addSubview:img_arrow];

    tableView_Register = [[UITableView alloc] initWithFrame:CGRectMake(0, 44 + moment_status, Phone_Weight, Phone_Height - 44 - moment_status)];
    tableView_Register.backgroundColor = [UIColor clearColor];
    tableView_Register.separatorStyle = UITableViewCellSeparatorStyleNone; //隐藏tableViewCell的分割线
    [self.view addSubview:tableView_Register];
    NSDictionary* dic_H = [[BasicData sharedInstance].dic_BasicData objectForKey:@"MasterList"];
    arr_H12 = [dic_H objectForKey:@"H12"]; //所有的head
    arr_Customer = [NSMutableArray array];

    imageView_Face = [[UIImageView alloc] initWithImage:ImageName(@"nav_face_nothing.png")];
    imageView_Face.frame = CGRectMake((Phone_Weight - FaceW) * 0.5, (Phone_Height - FaceH) * 0.5, FaceW, FaceH);
    ;
    [self.view addSubview:imageView_Face];
}
- (void)Creat_TableView
{
    tableView_Register.dataSource = self;
    tableView_Register.delegate = self;
    [tableView_Register reloadData];
}
- (void)Is_Nothing
{
    if (arr_Customer.count == 0) {
        imageView_Face.hidden = NO;
    }
    else {
        imageView_Face.hidden = YES;
    }
}
- (void)Set_SegmentView
{
    for (NSInteger i = 1; i < 3; i++) {
        UIButton* btn = [UIButton buttonWithType:UIButtonTypeCustom];
        if (i == 1) //新客户添加
        {
            btn.backgroundColor = [UIColor clearColor];
            btn.frame = CGRectMake(Phone_Weight - 44, moment_status, 44, 44);
            [btn setBackgroundImage:[UIImage imageNamed:@"btn_color6.png"] forState:UIControlStateHighlighted];
            [btn setTitle:@"创建" forState:UIControlStateNormal];
            btn.titleLabel.textColor = [UIColor whiteColor];
            btn.titleLabel.font = [UIFont systemFontOfSize:15];
        }
        else if (i == 2) //日历
        {
            btn.backgroundColor = [UIColor clearColor];
            btn.frame = CGRectMake(Phone_Weight * 0.5 - 44, moment_status, 44 * 2.5, 44);
            [btn setBackgroundImage:[UIImage imageNamed:@"nav_menu_arrow_back.png"] forState:UIControlStateHighlighted];
        }
        btn.tag = buttonTag + i;
        [btn addTarget:self action:@selector(btn_Action:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:btn];
    }
}
- (void)GoBack
{
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)btn_Action:(id)sender
{
    UIButton* btn = (UIButton*)sender;
    if (btn.tag == buttonTag + 2) //日历
    {
        AdvancedSearchViewController* ad = [[AdvancedSearchViewController alloc] init];
        if (!self.isRival) {
            ad.customerFlag = 1;
        }
        ad.str_Num = @"1";
        [self.navigationController pushViewController:ad animated:YES];
    }
    else if (buttonTag + 1 == btn.tag) {
        //添加新客户 之前要利用字段 判断添加的是竞争对手还是客户
        AddNewClerkOrRivalViewController* addVC = [[AddNewClerkOrRivalViewController alloc] init];
        NSString* str;
        if (self.isRival) 
        {
            str = @"1";
        }
        else {
            str = @"0";
        }
        addVC.str_title = str;
        addVC.addressFlag = 1;
        addVC.showLocalImage = 1;
        [self.navigationController pushViewController:addVC animated:YES];
    }
}
- (NSInteger)numberOfSectionsInTableView:(UITableView*)tableView
{
    return 1;
}
- (CGFloat)tableView:(UITableView*)tableView heightForRowAtIndexPath:(NSIndexPath*)indexPath
{
    return 120;
}
- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
    return arr_Customer.count;
}

- (UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
    RegisterCell* cell = (RegisterCell*)[tableView dequeueReusableCellWithIdentifier:@"RegisterCell"];
    if (cell == nil) {
        NSArray* nib;
        if (isPad) {
            nib = [[NSBundle mainBundle] loadNibNamed:@"RegisterCell_ipad" owner:[RegisterCell class] options:nil];
        }
        else {
            nib = [[NSBundle mainBundle] loadNibNamed:@"RegisterCell" owner:[RegisterCell class] options:nil];
        }
        cell = (RegisterCell*)[nib objectAtIndex:0];
        cell.contentView.backgroundColor = [UIColor clearColor];
    }
    cell.backgroundColor = [UIColor clearColor];

    NSDictionary* dic = [arr_Customer objectAtIndex:indexPath.row];
    for (NSInteger i = 0; i < arr_H12.count; i++) {
        NSDictionary* dicH = [arr_H12 objectAtIndex:i];
        if ([[dicH objectForKey:@"cvalue"] isEqualToString:[dic objectForKey:@"svtype"]]) {
            cell.label_CompanyName.text = [dicH objectForKey:@"clabel"];
            break;
        }
    }
    if ([[dic objectForKey:@"gtype"] isEqualToString:@"0"]) { //新客户
        cell.imageView_Head.image = [UIImage imageNamed:@"cell_clerk.png"];
    }
    else {
        cell.imageView_Head.image = [UIImage imageNamed:@"cell_competitor.png"];
    }
    if ([[dic objectForKey:@"local"] isEqualToString:@"1"]) {
        cell.label_CompanyName.backgroundColor = [UIColor colorWithRed:166.0 / 255.0 green:153.0 / 255.0 blue:163.0 / 255.0 alpha:1.0];
        cell.localLabel.hidden = NO;
    }
    else {
        cell.label_CompanyName.backgroundColor = [UIColor colorWithRed:238.0 / 255.0 green:138.0 / 255.0 blue:16.0 / 255.0 alpha:1.0];
    }
    cell.label_BusinessName.text = [dic objectForKey:@"gname"];
    cell.label_CompanyName.textAlignment = NSTextAlignmentCenter;
    cell.label_CompanyName.layer.cornerRadius = 5.0;
    cell.label_adress.text = [dic objectForKey:@"gaddress"];
    cell.label_Date.text = [dic objectForKey:@"ins_date"];
    cell.label_Scale.top = cell.label_BusinessName.bottom + 5;
    cell.label_adress.top = cell.label_Scale.bottom + 5;
    if ([Function StringIsNotEmpty:[dic objectForKey:@"gvolume"]]) {
        cell.label_Scale.text = [NSString stringWithFormat:@"规模:%@", [dic objectForKey:@"gvolume"]];
    }
    else {
        cell.label_Scale.text = @"规模:";
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone; //无点击效果
    dic = nil;
    return cell;
}
- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath
{
    NSDictionary* dic = [arr_Customer objectAtIndex:indexPath.row];
    if ([[dic objectForKey:@"local"] isEqualToString:@"1"]) {
        [self To_DetailView_Info:dic Photo:nil AllData:[dic objectForKey:@"tempDic"]];
        return;
    }
    [self getListDetail:[dic objectForKey:@"index_no"]];
}
- (NSString*)SettingURL_getListDetail:(NSString*)url
{
    NSString* string;
    if (!self.isRival) {
        string = [NSString stringWithFormat:@"%@%@", url, KGet_Detail0];
    }
    else {
        string = [NSString stringWithFormat:@"%@%@", url, KGet_Detail1];
    }
    return string;
}
- (void)getListDetail:(NSString*)index_no
{
    if ([Function isConnectionAvailable]) {
        MBProgressHUD* hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.mode = MBProgressHUDModeIndeterminate;
        hud.labelText = @"加载中..."; //加载提示语言

        if (app.isPortal) {
            urlString = [self SettingURL_getListDetail:KPORTAL_URL];
        }
        else {
            urlString = [self SettingURL_getListDetail:kBASEURL];
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

        [request setPostValue:index_no forKey:@"index_no"];
        [request startAsynchronous]; //异步
    }
    else {
        [SGInfoAlert showInfo:@"当前网络不可用，请检查网络连接"
                      bgColor:[[UIColor darkGrayColor] CGColor]
                       inView:self.view
                     vertical:0.5];
    }
}
- (NSString*)SettingUrl_get_NewOrFighterList:(NSString*)url
{
    NSString* string;
    if (!self.isRival) {
        string = [NSString stringWithFormat:@"%@%@", url, KGet_Customer0];
    }
    else {
        string = [NSString stringWithFormat:@"%@%@", url, KGet_Customer1];
    }
    return string;
}
- (void)get_NewOrFighterList
{
    if ([Function isConnectionAvailable]) {
        MBProgressHUD* hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.mode = MBProgressHUDModeIndeterminate;
        hud.labelText = @"加载中..."; //加载提示语言

        if (app.isPortal) {
            urlString = [self SettingUrl_get_NewOrFighterList:KPORTAL_URL];
        }
        else {
            urlString = [self SettingUrl_get_NewOrFighterList:kBASEURL];
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
        if ([Advance_Search sharedInstance].arr_search.count > 0) {
            [request setPostValue:[[Advance_Search sharedInstance].arr_search objectAtIndex:0] forKey:@"start_date"];
            [request setPostValue:[[Advance_Search sharedInstance].arr_search objectAtIndex:1] forKey:@"end_date"];
            [request setPostValue:[[Advance_Search sharedInstance].arr_search objectAtIndex:2] forKey:@"gname"];
            [request setPostValue:[[Advance_Search sharedInstance].arr_search objectAtIndex:3] forKey:@"maxGvolume"];
            [request setPostValue:[[Advance_Search sharedInstance].arr_search objectAtIndex:4] forKey:@"minGvolume"];

            for (int i = 0; i < app.mutDynDic.count; i++) {
                NSString* tempStr = [[Advance_Search sharedInstance].arr_search objectAtIndex:5 + i];
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
//  0  列表数据   1每行的查看详细
- (void)get_JsonString:(NSString*)jsonString Type:(NSString*)type
{
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    SBJsonParser* parser = [[SBJsonParser alloc] init];
    NSDictionary* dict = [parser objectWithString:jsonString];
    if ([[dict objectForKey:@"ret"] isEqualToString:@"0"]) {
        NSArray* tempArray = [dict objectForKey:@"CustomerList"];
        if ([type isEqual:@"0"]) {
            arr_Customer = [NSMutableArray array];
            [self localMethod];
            for (int i = 0; i < tempArray.count; i++) {
                [arr_Customer addObject:[tempArray objectAtIndex:i]];
            }
            [self Is_Nothing];
            [self Creat_TableView];
        }
        else { //查看详细
            NSDictionary* dic = [dict objectForKey:@"CustomerInfo"];
            NSArray* arr = [dict objectForKey:@"MediaList"];
            [self To_DetailView_Info:dic Photo:arr AllData:dict];
        }
    }
    else {
        if ([type isEqual:@"0"]) {
            NSString* str;
            if (self.isRival) {
                str = @"获取竞争对手列表失败";
            }
            else {
                str = @"获取新客户列表失败";
            }
            [SGInfoAlert showInfo:str
                          bgColor:[[UIColor darkGrayColor] CGColor]
                           inView:self.view
                         vertical:0.5];
        }
        else {
        }
    }
}
- (void)To_DetailView_Info:(NSDictionary*)dic Photo:(NSArray*)arr AllData:(NSDictionary*)data
{
    AddNewClerkOrRivalViewController* addVC = [[AddNewClerkOrRivalViewController alloc] init];
    NSString* str;
    if (self.isRival) {
        str = @"1";
    }
    else {
        str = @"0";
    }
    addVC.str_title = str;
    addVC.isDetail = YES;
    addVC.local = [dic objectForKey:@"local"];
    addVC.str_value1 = [dic objectForKey:@"svtype"]; //类型H12
    addVC.str_value2 = [dic objectForKey:@"plevel"]; //档次H4
    addVC.str_value3 = [dic objectForKey:@"gcoopstate"]; //状态H3

    addVC.str_tex0 = [dic objectForKey:@"gname"];
    addVC.str_tex1 = [self Calculate:@"H12" Value:[dic objectForKey:@"svtype"]];
    addVC.str_tex2 = [dic objectForKey:@"gcontact"];

    addVC.str_tex3 = [dic objectForKey:@"gtel"];
    addVC.str_tex4 = [dic objectForKey:@"gvolume"];

    addVC.str_tex5 = [self Calculate:@"H4" Value:[dic objectForKey:@"plevel"]];
    addVC.str_tex6 = [self Calculate:@"H3" Value:[dic objectForKey:@"gcoopstate"]];

    addVC.str_tex7 = [dic objectForKey:@"gaddress"];
    addVC.str_tex8 = [dic objectForKey:@"gmail"];

    addVC.str_index_no = [dic objectForKey:@"index_no"];
    app.str_alat = [dic objectForKey:@"glat"];
    app.str_nlng = [dic objectForKey:@"glng"];

    if ([[dic objectForKey:@"local"] isEqualToString:@"1"]) {
        addVC.showLocalImage = YES;
        NSString* addressStr = [dic objectForKey:@"gaddress"];
        if (![addressStr isEqualToString:@"地址未知"]) {
            addVC.str_tex7 = addressStr;
        }
        else {
            addVC.addressFlag = 1;
        }
    }
    NSString* number = [dic objectForKey:@"tempIndexNumber"];
    if (number.length) {
        addVC.convertNumber = number;
    }
    addVC.dic_data_all = [NSDictionary dictionaryWithDictionary:data];

    [self.navigationController pushViewController:addVC animated:YES];
}
- (NSString*)Calculate:(NSString*)str_H Value:(NSString*)str_value
{
    NSDictionary* dic = [[BasicData sharedInstance].dic_BasicData objectForKey:@"MasterList"];
    NSArray* arr = [dic objectForKey:str_H];
    for (NSInteger i = 0; i < arr.count; i++) {
        NSDictionary* dict = [arr objectAtIndex:i];
        if ([[dict objectForKey:@"cvalue"] isEqualToString:str_value]) {
            return [dict objectForKey:@"clabel"];
        }
    }
    return @"";
}

- (void)requestFinished:(ASIHTTPRequest*)request
{
    if (request.tag == 100) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        if ([request responseStatusCode] == 200) {
            NSString* jsonString = [request responseString];
            [self get_JsonString:jsonString Type:@"1"];
        }
        else {
            [SGInfoAlert showInfo:@"发生异常,请稍后再试"
                          bgColor:[[UIColor darkGrayColor] CGColor]
                           inView:self.view
                         vertical:0.5];
            [NdUncaughtExceptionHandler Post_url:[NSString stringWithFormat:@"URL:%@,HTTP_Code%d", urlString, [request responseStatusCode]]];
        }
    }
    if (request.tag == 101) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        if ([request responseStatusCode] == 200) {
            NSString* jsonString = [request responseString];
            [self get_JsonString:jsonString Type:@"0"];
        }
        else {
            [SGInfoAlert showInfo:@"发生异常,请稍后再试"
                          bgColor:[[UIColor darkGrayColor] CGColor]
                           inView:self.view
                         vertical:0.5];
            [NdUncaughtExceptionHandler Post_url:[NSString stringWithFormat:@"URL:%@,HTTP_Code%d", urlString, [request responseStatusCode]]];
        }
    }
}

- (void)requestFailed:(ASIHTTPRequest*)request
{
    if (request.tag == 100) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [SGInfoAlert showInfo:@"哎呀，服务器无响应，一会再试试吧"
                      bgColor:[[UIColor darkGrayColor] CGColor]
                       inView:self.view
                     vertical:0.5];
    }
    if (request.tag == 101) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [SGInfoAlert showInfo:@"哎呀，服务器无响应，一会再试试吧"
                      bgColor:[[UIColor darkGrayColor] CGColor]
                       inView:self.view
                     vertical:0.5];
    }
}

- (void)localMethod
{
    if ([Function judgeFileExist:Customer_Local Kind:Library_Cache]) {
        NSInteger k = 0;
        NSInteger m = 0;
        NSMutableArray* customerLArray = [Function ReadFromFile:Customer_Local WithKind:Library_Cache];

        for (int i = 0; i < customerLArray.count; i++) {
            NSString* gtype = [[customerLArray objectAtIndex:i] objectForKey:@"gtype"];
            if (self.isRival == gtype.boolValue) {
                NSString* localString = [[customerLArray objectAtIndex:i] objectForKey:@"local"];
                if ([localString isEqualToString:@"1"]) {
                    for (int j = 0; j < arr_Customer.count; j++) {
                        k = 0;
                        NSString* gnameString = [[arr_Customer objectAtIndex:j] objectForKey:@"tempIndexNumber"];
                        NSString* gnameString1 = [[customerLArray objectAtIndex:i] objectForKey:@"tempIndexNumber"];
                        if ([gnameString isEqualToString:gnameString1]) {
                            m = j;
                            k = 1;
                            break;
                        }
                    }
                    if (k == 0) {
                        [arr_Customer insertObject:[customerLArray objectAtIndex:i] atIndex:0];
                    }
                    else {
                        [arr_Customer removeObjectAtIndex:m];
                        [arr_Customer insertObject:[customerLArray objectAtIndex:i] atIndex:m];
                    }
                }
            }
        }

        [self Creat_TableView];
    }
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
