//
//  ChooseListViewController.m
//  WZYB_syb
//
//  Created by wzyb on 14-7-23.
//  Copyright (c) 2014年 WZYB. All rights reserved.
//

#import "ChooseListViewController.h"
#import "AppDelegate.h"
#import "KxMenu.h"
#import "ItemBrowseViewController.h"
#import "FilterViewController.h"
#import "Redlabel.h"
#import "ChooseView.h"
#import "UIViewController+LewPopupViewController.h"
#import "LewPopupViewAnimationSpring.h"

#define searchHeight 44
#define NUMBERS @"0123456789.\n"

@interface ChooseListViewController () <UITextFieldDelegate, UITextViewDelegate> {
    AppDelegate* app;
    NSArray* arr_H13; //单位
    NSString *chooseTFStr;
    NSString *chooseTWStr;
    BOOL switchFlag;
    NSIndexPath* _indexPath;
    NSNumber* localID1;
    NSString* urlString;
    Redlabel* label;
    ChooseView* chooseView;
    UITextField *myTextfield;
}
@end

@implementation ChooseListViewController
@synthesize searchBar;
@synthesize contactDic;
@synthesize searchByName;
@synthesize searchByPhone;
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
}
- (void)viewWillAppear:(BOOL)animated
{
    isSearching = NO;
    [self searchBarInit];
    [self Creat_TableView];
}
- (void)viewWillDisappear:(BOOL)animated
{
    [[SearchCoreManager share] Reset];
}
- (void)All_Init
{
    localID1 = nil;
    switchFlag = 0;
    chooseTFStr = [NSString string];
    chooseTWStr = [NSString string];
    arr_List = [NSMutableArray array];
    app = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    if (StatusBar_System > 0)
        moment_status = 20;
    else
        moment_status = 0;
    NavView* nav_View = [[NavView alloc] init];
    [self.view addSubview:[nav_View NavView_Title1:@"筛选"]];

    //筛选按钮
    UIImageView* img_arrow = [[UIImageView alloc] init];
    img_arrow.frame = CGRectMake(Phone_Weight - 155, moment_status, 44, 44);
    img_arrow.image = [UIImage imageNamed:@"nav_menu_arrow.png"];
    [nav_View.view_Nav addSubview:img_arrow];

    UIButton* btn1 = [UIButton buttonWithType:UIButtonTypeCustom];
    btn1.frame = CGRectMake(Phone_Weight / 2 - 44, moment_status, 44 * 2.5, 44);
    [btn1 setBackgroundImage:[UIImage imageNamed:@"nav_menu_arrow_back.png"] forState:UIControlStateHighlighted];
    btn1.backgroundColor = [UIColor clearColor];
    btn1.tag = buttonTag + 1;
    [btn1 addTarget:self action:@selector(selectItem) forControlEvents:UIControlEventTouchUpInside];
    [nav_View.view_Nav addSubview:btn1];

    //左边返回键
    UIButton* btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(0, moment_status, 60, 44);
    btn.backgroundColor = [UIColor clearColor];
    btn.tag = buttonTag - 1;
    [btn addTarget:self action:@selector(btn_Action:) forControlEvents:UIControlEventTouchUpInside];
    [nav_View.view_Nav addSubview:btn];
    [btn setBackgroundImage:[UIImage imageNamed:@"btn_color6.png"] forState:UIControlStateHighlighted];
    [btn setTitle:@"< 返回" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont systemFontOfSize:15];

    UIButton* refreshBtn = [[UIButton alloc] initWithFrame:CGRectMake(320 - 44, 20, 44, 44)];
    [refreshBtn setTitle:@"●●●" forState:UIControlStateNormal];
    refreshBtn.titleLabel.font = [UIFont systemFontOfSize:15.0f];
    [refreshBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [refreshBtn setBackgroundImage:[UIImage imageNamed:@"btn_color6.png"] forState:UIControlStateHighlighted];
    [refreshBtn addTarget:self action:@selector(_refreshButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:refreshBtn];

    //购物车项目个数
    label = [[Redlabel alloc] initWithFrame:CGRectMake(260, 33, 18, 18)];
    [self.view addSubview:label];

    if ([AddProduct sharedInstance].arr_AddToList.count) {
        label.text = [NSString stringWithFormat:@"%lu", (unsigned long)[AddProduct sharedInstance].arr_AddToList.count];
        label.hidden = NO;
    }

    imageView_Face = [[UIImageView alloc] init];
    imageView_Face = [NavView Show_Nothing_Face];

    NSDictionary* dic_H = [[BasicData sharedInstance].dic_BasicData objectForKey:@"MasterList"];
    arr_H13 = [dic_H objectForKey:@"H13"]; //所有的head
    urlString = [NSString string];

    chooseView = [ChooseView defaultPopupView];
}

- (void)selectItem
{
    FilterViewController* filterVC = [FilterViewController new];
    [self presentViewController:filterVC animated:YES completion:nil];
}

//下拉列表
- (void)_refreshButtonAction:(UIButton*)sender
{
    NSArray* menuItems =
        @[
           [KxMenuItem menuItem:@"查看订购项目"
                          image:[UIImage imageNamed:@"shopping"]
                         target:self
                         action:@selector(pushMenuItem:)],

           [KxMenuItem menuItem:@"下载最新产品数据"
                          image:[UIImage imageNamed:@"download"]
                         target:self
                         action:@selector(pushMenuItem:)]
        ];

    [KxMenu showMenuInView:self.view
                  fromRect:sender.frame
                 menuItems:menuItems];
}

//下拉列表action
- (void)pushMenuItem:(id)sender
{
    KxMenuItem* menu = (KxMenuItem*)sender;
    if ([menu.title isEqualToString:@"查看订购项目"]) {
        if ([AddProduct sharedInstance].arr_AddToList.count) {
            ItemBrowseViewController* itemVC = [ItemBrowseViewController new];
            itemVC.cIndexNumber = self.cIndexNumber;
            itemVC.meterialFlag = [app.str_Product_material integerValue];
            if (self.returnFlag) {
                itemVC.returnFlag = 1;
            }
            [self.navigationController pushViewController:itemVC animated:YES];
        }
        else {
            [SGInfoAlert showInfo:@"请先选择产品"
                          bgColor:[[UIColor darkGrayColor] CGColor]
                           inView:self.view
                         vertical:0.5];
        }
    }
    else {
        [self UpdateItemRequest];
    }
}

- (void)UpdateItemRequest
{
    if ([Function isConnectionAvailable]) {
        MBProgressHUD* hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.mode = MBProgressHUDModeIndeterminate;
        hud.labelText = @"加载中..."; //加载提示语言
        if (app.isPortal) {
            urlString = [NSString stringWithFormat:@"%@%@", KPORTAL_URL, UpdateItem];
        }
        else {
            urlString = [NSString stringWithFormat:@"%@%@", kBASEURL, UpdateItem];
        }

        NSURL* url = [NSURL URLWithString:urlString];
        ASIFormDataRequest* request = [ASIFormDataRequest requestWithURL:url];
        request.delegate = self;
        [request setRequestMethod:@"POST"];

        [request setPostValue:[[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"account"] forKey:KUSER_UID];
        [request setPostValue:[[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"secret"] forKey:KUSER_PASSWORD];
        [request setPostValue:[[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"token"] forKey:@"user.token"];
        [request setPostValue:[[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"db_ip"] forKey:@"db_ip"];
        [request setPostValue:[[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"db_name"] forKey:@"db_name"];

        [request setPostValue:app.str_Product_material forKey:@"mptype"];
        [request startAsynchronous]; //异步
    }
    else {
        [SGInfoAlert showInfo:@"当前网络不可用，请检查网络连接"
                      bgColor:[[UIColor darkGrayColor] CGColor]
                       inView:self.view
                     vertical:0.5];
    }
}

- (void)searchBarInit
{
    /***数据初始化****/
    NSDictionary* dic_ProductList = [[BasicData sharedInstance].dic_BasicData objectForKey:@"ProductList"];
    if ([app.str_Product_material isEqualToString:@"1"]) //物料
    {
        if (app.selectFlag) {
            app.selectFlag = 0;
            arr_List = [NSMutableArray array];
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),
                ^{
                    NSArray* tempArray = [dic_ProductList objectForKey:@"1"];
                    for (NSDictionary* tempDic in tempArray) {
                        if ([app.branchArray containsObject:[tempDic objectForKey:@"ext1"]] ||
                            [app.typeArray containsObject:[tempDic objectForKey:@"ptype"]] ||
                            [app.addressArray containsObject:[tempDic objectForKey:@"poo"]]) {
                            [arr_List addObject:tempDic];
                        }
                    }
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [tableView reloadData];
                    });
                });
        }
        else {
            arr_List = [dic_ProductList objectForKey:@"1"]; //数据表
        }
    }
    else if ([app.str_Product_material isEqualToString:@"0"]) //商品
    {
        if ([self.str_isFromQR isEqualToString:@"1"]) {
            NSMutableArray* list = [NSMutableArray arrayWithCapacity:1];
            NSMutableDictionary* data;
            NSArray* arr = [dic_ProductList objectForKey:@"0"]; //数据表
            for (NSInteger i = 0; i < arr.count; i++) {
                NSDictionary* dic = [arr objectAtIndex:i];
                if ([[dic objectForKey:@"pcode"] isEqualToString:self.str_pcode]) {
                    data = [NSMutableDictionary dictionaryWithDictionary:dic];
                    [data setObject:[NSString stringWithFormat:@"%ld", (long)i] forKey:@"index"];
                    [list addObject:data];
                }
            }
            arr_List = list;
        }
        else {
            if (app.selectFlag) {
                app.selectFlag = 0;
                arr_List = [NSMutableArray array];
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),
                    ^{
                        if (app.branchArray.count || app.typeArray.count || app.addressArray.count) {
                            NSArray* tempArray = [dic_ProductList objectForKey:@"0"];
                            for (NSDictionary* tempDic in tempArray) {
                                if ([app.branchArray containsObject:[tempDic objectForKey:@"ext1"]] ||
                                    [app.typeArray containsObject:[tempDic objectForKey:@"ptype"]] ||
                                    [app.addressArray containsObject:[tempDic objectForKey:@"poo"]]) {
                                    [arr_List addObject:tempDic];
                                }
                            }
                        }
                        else {
                            arr_List = [dic_ProductList objectForKey:@"0"]; //数据表
                        }
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [tableView reloadData];
                        });
                    });
            }
            else {
                arr_List = [dic_ProductList objectForKey:@"0"]; //数据表
            }
        }
    }
    /***数据初始化****/
    self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, moment_status + 44, Phone_Weight, searchHeight)];
    self.searchBar.autocorrectionType = UITextAutocorrectionTypeNo;
    self.searchBar.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.searchBar.keyboardType = UIKeyboardTypeDefault;
    self.searchBar.backgroundColor = [UIColor clearColor]; //修改搜索框背景
    searchBar.backgroundColor = [UIColor clearColor];
    searchBar.translucent = YES;
    self.searchBar.placeholder = @"搜索";
    self.searchBar.delegate = self;
    self.searchBar.showsCancelButton = YES;
    self.searchBar.barStyle = UIBarStyleDefault;
    UIImageView* imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_searchbar.png"]];
    imageView.frame = CGRectMake(20, 10, searchBar.frame.size.width - 40, searchBar.frame.size.height - 20);

    [self.view addSubview:self.searchBar];

    NSMutableDictionary* dic = [[NSMutableDictionary alloc] init];
    self.contactDic = dic;
    dic = nil;

    NSMutableArray* nameIDArray = [[NSMutableArray alloc] init];
    self.searchByName = nameIDArray;
    nameIDArray = nil;
    NSMutableArray* phoneIDArray = [[NSMutableArray alloc] init];
    self.searchByPhone = phoneIDArray;
    phoneIDArray = nil;

    //添加到搜索库
    for (NSInteger i = 0; i < arr_List.count; i++) {
        NSDictionary* dic = [arr_List objectAtIndex:i];
        ContactPeople* contact = [[ContactPeople alloc] init];
        contact.localID = [NSNumber numberWithInteger:i];
        contact.name = [dic objectForKey:@"pname"];
        NSMutableArray* phoneArray = [[NSMutableArray alloc] init];
        [phoneArray addObject:[dic objectForKey:@"pcode"]]; //1
        [phoneArray addObject:[dic objectForKey:@"ptype"]]; //2
        [phoneArray addObject:[dic objectForKey:@"price"]]; //3
        [phoneArray addObject:[dic objectForKey:@"poo"]]; //4
        if (![Function isBlankString:[dic objectForKey:@"ext1"]]) //5
        {
            [phoneArray addObject:[dic objectForKey:@"ext1"]];
        }
        else {
            [phoneArray addObject:@"        "];
        }
        if ([self.str_isFromQR isEqualToString:@"1"]) //6
        {
            [phoneArray addObject:[dic objectForKey:@"index"]];
        }

        for (NSInteger i = 0; i < arr_H13.count; i++) {
            NSDictionary* dic_H = [arr_H13 objectAtIndex:i];
            if ([[dic_H objectForKey:@"cvalue"] isEqualToString:[dic objectForKey:@"punit"]]) {
                [phoneArray addObject:[dic_H objectForKey:@"clabel"]];
            }
        }
        contact.phoneArray = phoneArray;
        [[SearchCoreManager share] AddContact:contact.localID name:contact.name phone:contact.phoneArray];
        [self.contactDic setObject:contact forKey:contact.localID];
        phoneArray = nil;
        contact = nil;
    }
    /***测试新的搜索***/
    /***测试新的搜索***/
}
- (void)Creat_TableView
{
    tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 44 + moment_status + searchHeight, Phone_Weight, Phone_Height - 44 - moment_status - searchHeight)];
    [self.view addSubview:tableView];
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableView.dataSource = self;
    tableView.delegate = self;
}

- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
    if (isSearching) {

        if ([self.searchBar.text length] <= 0) {
            if ([self.contactDic count] == 0) {
                [self.view addSubview:imageView_Face];
            }
            else {
                [imageView_Face removeFromSuperview];
            }
            return [self.contactDic count];
        }
        else {
            if ([self.searchByName count] + [self.searchByPhone count] == 0) {
                [self.view addSubview:imageView_Face];
            }
            else {
                [imageView_Face removeFromSuperview];
            }
            return [self.searchByName count] + [self.searchByPhone count];
        }
        // */
        // return self.allTableData.count;
    }
    else {
        if (arr_List.count == 0) {
            [self.view addSubview:imageView_Face];
        }
        else {
            [imageView_Face removeFromSuperview];
        }
        return arr_List.count;
    }
}
- (CGFloat)tableView:(UITableView*)tableView heightForRowAtIndexPath:(NSIndexPath*)indexPath
{
    return 205;
}
- (UITableViewCell*)tableView:(UITableView*)tableView1 cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
    ChooseCell* cell = (ChooseCell*)[tableView1 dequeueReusableCellWithIdentifier:@"ChooseCell"];
    if (cell == nil) {
        NSArray* nib = [[NSBundle mainBundle] loadNibNamed:@"ChooseCell" owner:[ChooseCell class] options:nil];
        cell = (ChooseCell*)[nib objectAtIndex:0];
        cell.contentView.backgroundColor = [UIColor whiteColor];
    }
    if (isSearching) {
        NSNumber* localID = nil;
        NSMutableString* matchString = [NSMutableString string];
        NSMutableArray* matchPos = [NSMutableArray array];
        if (indexPath.row < [searchByName count]) {
            localID = [self.searchByName objectAtIndex:indexPath.row];

            //姓名匹配 获取对应匹配的拼音串 及高亮位置
            if ([self.searchBar.text length]) {
                [[SearchCoreManager share] GetPinYin:localID pinYin:matchString matchPos:matchPos];
            }
        }
        else {
            localID = [self.searchByPhone objectAtIndex:indexPath.row - [searchByName count]];

            NSMutableArray* matchPhones = [NSMutableArray array];
            //号码匹配 获取对应匹配的号码串 及高亮位置
            if ([self.searchBar.text length]) {
                [[SearchCoreManager share] GetPhoneNum:localID phone:matchPhones matchPos:matchPos];
                [matchString appendString:[matchPhones objectAtIndex:0]];
            }
        }
        ContactPeople* contact = [self.contactDic objectForKey:localID];
        cell.lab_pname.text = contact.name;
        cell.lab_pcode.text = [contact.phoneArray objectAtIndex:0];
        cell.lab_poo.text = [contact.phoneArray objectAtIndex:3];
        cell.lab_price.text = [contact.phoneArray objectAtIndex:2];
        cell.lab_ptype.text = [contact.phoneArray objectAtIndex:1];
        cell.lab_branded.text = [contact.phoneArray objectAtIndex:4];
        cell.unitLabel.text = [contact.phoneArray objectAtIndex:5];
    }
    else {
        NSDictionary* dic = [arr_List objectAtIndex:indexPath.row];
        cell.lab_pname.text = [dic objectForKey:@"pname"];
        cell.lab_pcode.text = [dic objectForKey:@"pcode"]; //pcode是条码编号
        cell.lab_poo.text = [dic objectForKey:@"poo"]; //产地
        cell.lab_price.text = [dic objectForKey:@"price"];
        cell.lab_ptype.text = [dic objectForKey:@"ptype"]; //型号
        cell.lab_branded.text = [dic objectForKey:@"ext1"]; //品牌

        for (NSInteger i = 0; i < arr_H13.count; i++) {
            NSDictionary* dic_H = [arr_H13 objectAtIndex:i];
            if ([[dic_H objectForKey:@"cvalue"] isEqualToString:[dic objectForKey:@"punit"]]) {
                cell.unitLabel.text = [dic_H objectForKey:@"clabel"];
            }
        }
    }
    cell.selectionStyle = UITableViewCellSelectionStyleGray;
    return cell;
}
- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath
{
    _indexPath = indexPath;
    if (isSearching) {
        NSMutableString* matchString = [NSMutableString string];
        NSMutableArray* matchPos = [NSMutableArray array];
        if (indexPath.row < [searchByName count]) {
            localID1 = [self.searchByName objectAtIndex:indexPath.row];

            //姓名匹配 获取对应匹配的拼音串 及高亮位置
            if ([self.searchBar.text length]) {
                [[SearchCoreManager share] GetPinYin:localID1 pinYin:matchString matchPos:matchPos];
            }
        }
        else {
            localID1 = [self.searchByPhone objectAtIndex:indexPath.row - [searchByName count]];
            NSMutableArray* matchPhones = [NSMutableArray array];

            //号码匹配 获取对应匹配的号码串 及高亮位置
            if ([self.searchBar.text length]) {
                [[SearchCoreManager share] GetPhoneNum:localID1 phone:matchPhones matchPos:matchPos];
                [matchString appendString:[matchPhones objectAtIndex:0]];
            }
        }
        if ([self.str_isFromQR isEqualToString:@"1"]) {
            ContactPeople* contact = [self.contactDic objectForKey:localID1];

            app.str_choose = [contact.phoneArray objectAtIndex:contact.phoneArray.count - 1];
        }
        else {
            app.str_choose = [localID1 stringValue];
        }
    }
    
    if (app.GiftFlagStr.integerValue && !app.isApproval) {
        //显示备注和赠品
        [self whenFlagTrueShowAlert];
    }else {
        if (isIOS8) {
            [self showOkayCancelAlert];
        }else {
            [self showAlert_IOS7];
        }
    }
}

- (void)showAlert_IOS7 {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"请输入订购数量" message:@"" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定",nil];
    [alert setAlertViewStyle:UIAlertViewStylePlainTextInput];
    myTextfield = [alert textFieldAtIndex:0];
    myTextfield.delegate = self;
    [alert show];
}

- (void)showOkayCancelAlert {
    NSString *message = NSLocalizedString(@"请输入订购数量", nil);
    NSString *cancelButtonTitle = NSLocalizedString(@"取消", nil);
    NSString *otherButtonTitle = NSLocalizedString(@"确定", nil);
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"" message:message preferredStyle:UIAlertControllerStyleAlert];
    
    // Create the actions.
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:cancelButtonTitle style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        NSLog(@"取消");
    }];
    
    UIAlertAction *otherAction = [UIAlertAction actionWithTitle:otherButtonTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        if (myTextfield.text.integerValue) {
            [self addItem];
        }
    }];
    
    // Add the actions.
    [alertController addAction:cancelAction];
    [alertController addAction:otherAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
    
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        myTextfield = textField;
        // 可以在这里对textfield进行定制，例如改变背景色
        myTextfield.backgroundColor = [UIColor orangeColor];
        myTextfield.textColor = [UIColor whiteColor];
        myTextfield.font = [UIFont systemFontOfSize:17.0];
        myTextfield.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
        myTextfield.delegate = self;
    }];
}

- (void)whenFlagTrueShowAlert
{
    chooseView.switchBtn.on = 0;
    chooseView.numberTextField.text = @"";
    chooseView.remarkTextView.text = @"";
    chooseView.numberTextField.delegate = self;
    chooseView.remarkTextView.delegate = self;
    chooseView.parentVC = self;
    [chooseView.sureBtn addTarget:self action:@selector(sureAction) forControlEvents:UIControlEventTouchUpInside];
    [self lew_presentPopupView:chooseView
                     animation:[LewPopupViewAnimationSpring new]
                     dismissed:^{
                     }];
}

- (void)sureAction
{
    switchFlag  = chooseView.switchBtn.on;
    chooseTFStr = chooseView.numberTextField.text;
    chooseTWStr = chooseView.remarkTextView.text;
    
    [self lew_dismissPopupViewWithanimation:[LewPopupViewAnimationSpring new]];
    
    if (chooseTFStr.integerValue) {
        [self addItem];
    }
}

- (void)addItem
{
    NSDictionary* tempDic = [NSDictionary dictionary];
    if (isSearching) {
        tempDic = [arr_List objectAtIndex:[localID1 integerValue]];
    }
    else {
        tempDic = [arr_List objectAtIndex:_indexPath.row];
    }

    if (!self.returnFlag) {
        if ((chooseTFStr.integerValue > [[tempDic objectForKey:@"stock_cnt"] integerValue]) ||
            (myTextfield.text.integerValue > [[tempDic objectForKey:@"stock_cnt"] integerValue])) {
            [SGInfoAlert showInfo:@"您的订购数量超过了库存数量,请重新选择订购数量"
                          bgColor:[[UIColor darkGrayColor] CGColor]
                           inView:self.view
                         vertical:0.5];
            return;
        }
    }

    NSMutableDictionary* dic_unit = [NSMutableDictionary dictionary];

    [dic_unit setObject:[tempDic objectForKey:@"pname"] forKey:@"name"];
    [dic_unit setObject:[tempDic objectForKey:@"ptype"] forKey:@"type"];
    [dic_unit setObject:[tempDic objectForKey:@"poo"] forKey:@"address"];
    [dic_unit setObject:[tempDic objectForKey:@"price"] forKey:@"price"];
    [dic_unit setObject:[tempDic objectForKey:@"price"] forKey:@"selling_price"];

    NSString *totalPrice = nil;
    if (app.GiftFlagStr.integerValue && !app.isApproval) {
        [dic_unit setObject:chooseTFStr forKey:@"cnt"];
        [dic_unit setObject:chooseTWStr forKey:@"remark"];
        NSString *switchString = [NSString stringWithFormat:@"%d",switchFlag];
        [dic_unit setObject:switchString forKey:@"switch"];
        totalPrice = [NSString stringWithFormat:@"%.1f",
                        (long)chooseTFStr.integerValue * ([[tempDic objectForKey:@"price"] floatValue])];
    }else {
        [dic_unit setObject:myTextfield.text forKey:@"cnt"];
        totalPrice = [NSString stringWithFormat:@"%.1f",
                                (long)myTextfield.text.integerValue*([[tempDic objectForKey:@"price"] floatValue])];
    }
    [dic_unit setObject:totalPrice forKey:@"should"];
    if (switchFlag) {
        //如果是赠品则将实收合计设置为0
        [dic_unit setObject:@"0" forKey:@"real_rsum"];
    }else {
        [dic_unit setObject:totalPrice forKey:@"real_rsum"];
    }

    for (NSInteger i = 0; i < arr_H13.count; i++) {
        NSDictionary* dic_H = [arr_H13 objectAtIndex:i];
        if ([[dic_H objectForKey:@"cvalue"] isEqualToString:[tempDic objectForKey:@"punit"]]) {
            [dic_unit setObject:[dic_H objectForKey:@"clabel"] forKey:@"unit"];
        }
    }
    [dic_unit setObject:[tempDic objectForKey:@"index_no"] forKey:@"pindex_no"];
    [dic_unit setObject:[tempDic objectForKey:@"pcode"] forKey:@"pcode"];
    [dic_unit setObject:[tempDic objectForKey:@"stock_cnt"] forKey:@"stock_cnt"];
    [dic_unit setObject:[tempDic objectForKey:@"ext1"] forKey:@"ext1"];
    [[AddProduct sharedInstance].arr_AddToList addObject:dic_unit];
    if ([AddProduct sharedInstance].arr_AddToList.count) {
        label.text = [NSString stringWithFormat:@"%lu", (unsigned long)[AddProduct sharedInstance].arr_AddToList.count];
        label.hidden = NO;
    }
}

- (void)btn_Action:(id)sender
{
    UIButton* btn = (UIButton*)sender;
    if (btn.tag == buttonTag - 1) //返回
    {
        app.str_choose = nil;
        [self.navigationController popViewControllerAnimated:YES];
    }
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex==1)
    {
        if (isIOS8) {
            [self.navigationController popViewControllerAnimated:YES];
        }else {
            myTextfield = [alertView textFieldAtIndex:0];
            [self addItem];
        }
    }
}

#pragma mark---- UITextField delegate method
- (void)textFieldDidBeginEditing:(UITextField*)textField
{
    [textField becomeFirstResponder];
}
- (BOOL)textFieldShouldReturn:(UITextField*)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (BOOL)textField:(UITextField*)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString*)string
{
    NSCharacterSet* cs;
    cs = [[NSCharacterSet characterSetWithCharactersInString:NUMBERS] invertedSet];
    NSString* filtered = [[string componentsSeparatedByCharactersInSet:cs] componentsJoinedByString:@""];
    BOOL basicTest = [string isEqualToString:filtered];
    if (!basicTest) {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                        message:@"请输入指定字符"
                                                       delegate:nil
                                              cancelButtonTitle:@"确定"
                                              otherButtonTitles:nil];

        [alert show];
        return NO;
    }
    return YES;
}

#pragma mark---- UITextView delegate method
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range
 replacementText:(NSString *)text {
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    return YES;
}

#pragma mark -
#pragma mark search bar delegate methods
- (void)searchBar:(UISearchBar*)_searchBar textDidChange:(NSString*)searchText
{
    isSearching = YES;
    [[SearchCoreManager share] Search:searchText searchArray:nil nameMatch:searchByName phoneMatch:self.searchByPhone];
    [tableView reloadData];
}
- (void)searchBarCancelButtonClicked:(UISearchBar*)searchBar
{
    isSearching = NO;
    [self.searchBar resignFirstResponder];
    [tableView reloadData];
}
- (void)searchBarSearchButtonClicked:(UISearchBar*)searchBar
{
    [self.searchBar resignFirstResponder];
}

#pragma mark---- ASIHTTPRequest delegate
- (void)requestFinished:(ASIHTTPRequest*)request
{
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    NSString* jsonString = [request responseString];
    SBJsonParser* parser = [[SBJsonParser alloc] init];
    NSDictionary* dict = [parser objectWithString:jsonString];
    if ([[dict objectForKey:@"ret"] isEqualToString:@"0"]) {
        NSDictionary* dic_ProductList = [[BasicData sharedInstance].dic_BasicData objectForKey:@"ProductList"];
        NSDictionary* tempDic = nil;
        if ([app.str_Product_material isEqualToString:@"1"]) {
            NSArray* meterialArray = [dic_ProductList objectForKey:@"0"];
            tempDic = [[NSDictionary alloc] initWithObjectsAndKeys:meterialArray, @"0",
                                            [dict objectForKey:@"ProductList"], @"1", nil];
            NSArray* tempArray = [[[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:ProductBrandList] objectForKey:@"0"];
            NSArray* tempArray1 = [[[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:ProductTypeList] objectForKey:@"0"];
            NSArray* tempArray2 = [[[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:ProductPooList] objectForKey:@"0"];

            NSArray* tempArray3 = [dict objectForKey:@"ProductBrandList"];
            NSArray* tempArray4 = [dict objectForKey:@"ProductTypeList"];
            NSArray* tempArray5 = [dict objectForKey:@"ProductPooList"];

            NSDictionary* tempDic1 = [[NSDictionary alloc] initWithObjectsAndKeys:tempArray, @"0", tempArray3, @"1", nil];
            NSDictionary* tempDic2 = [[NSDictionary alloc] initWithObjectsAndKeys:tempArray1, @"0", tempArray4, @"1", nil];
            NSDictionary* tempDic3 = [[NSDictionary alloc] initWithObjectsAndKeys:tempArray2, @"0", tempArray5, @"1", nil];

            [self setDic:tempDic1 forKey:ProductBrandList];
            [self setDic:tempDic2 forKey:ProductTypeList];
            [self setDic:tempDic3 forKey:ProductPooList];
        }
        else {
            NSArray* meterialArray = [dic_ProductList objectForKey:@"1"];
            tempDic = [[NSDictionary alloc] initWithObjectsAndKeys:meterialArray, @"1",
                                            [dict objectForKey:@"ProductList"], @"0", nil];
            NSArray* tempArray = [[[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:ProductBrandList] objectForKey:@"1"];
            NSArray* tempArray1 = [[[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:ProductTypeList] objectForKey:@"1"];
            NSArray* tempArray2 = [[[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:ProductPooList] objectForKey:@"1"];

            NSArray* tempArray3 = [dict objectForKey:@"ProductBrandList"];
            NSArray* tempArray4 = [dict objectForKey:@"ProductTypeList"];
            NSArray* tempArray5 = [dict objectForKey:@"ProductPooList"];

            NSDictionary* tempDic1 = [[NSDictionary alloc] initWithObjectsAndKeys:tempArray, @"1", tempArray3, @"0", nil];
            NSDictionary* tempDic2 = [[NSDictionary alloc] initWithObjectsAndKeys:tempArray1, @"1", tempArray4, @"0", nil];
            NSDictionary* tempDic3 = [[NSDictionary alloc] initWithObjectsAndKeys:tempArray2, @"1", tempArray5, @"0", nil];

            [self setDic:tempDic1 forKey:ProductBrandList];
            [self setDic:tempDic2 forKey:ProductTypeList];
            [self setDic:tempDic3 forKey:ProductPooList];
        }

        if (tempDic.count) {
            [[BasicData sharedInstance].dic_BasicData setObject:tempDic forKey:@"ProductList"];
        }

        arr_List = [dict objectForKey:@"ProductList"];
        if (arr_List.count) {
            [tableView reloadData];
        }
    }
}

- (void)setDic:(id)dic forKey:(NSString*)key
{
    NSDictionary* tempDic = dic;
    if (tempDic.count) {
        [[SelfInf_Singleton sharedInstance].dic_SelfInform setObject:tempDic forKey:key];
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

@end
