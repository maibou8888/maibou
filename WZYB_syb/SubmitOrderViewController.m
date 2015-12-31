//
//  SubmitOrderViewController.m
//  WZYB_syb
//
//  Created by wzyb on 14-6-27.
//  Copyright (c) 2014年 WZYB. All rights reserved.
//

#import "SubmitOrderViewController.h"
#import "OrderListViewController.h"
#import "SubmitOrderTableViewCell.h"
#import "AppDelegate.h"
#import "KGModal.h"
#import <QuartzCore/QuartzCore.h>
#import "PresentView.h"
@interface SubmitOrderViewController ()<MyDelegate_OrderListView,MyDelegate_AdvancedSearch,zbarNewViewDelegate,PresentViewDelegate>
{
    AppDelegate *app;
    NSString *urlString;
}
@end

@implementation SubmitOrderViewController
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
    [[Advance_Search sharedInstance].arr_search removeAllObjects];
    app.str_Date=[Function getYearMonthDay_Now];
    [self Get_OrderList];
}
-(void)viewWillAppear:(BOOL)animated
{
    app.str_Date=[Function getYearMonthDay_Now];
    [self localMethod];
    if (app.order_refresh) {
        app.order_refresh = 0;
        [self Get_OrderList];
    }
}
#pragma mark  MyDelegate
-(void)Notify_OrderListView
{
    [self Get_OrderList];
}
-(void)Notify_AdvancedSearch
{
    [self Get_OrderList];
}
-(void)All_Init
{
    app=(AppDelegate *)[[UIApplication sharedApplication]delegate];
    if(StatusBar_System>0)
        moment_status=20;
    else moment_status=0;
    app.str_temporary = @"";
    NavView *nav_View=[[NavView alloc]init];
    [self.view addSubview: [nav_View NavView_Title1:self.titleString]];
    
    //添加订单“添加”
    UIButton *btn_SignIn=[UIButton buttonWithType:UIButtonTypeCustom]; 
    btn_SignIn.frame=CGRectMake(Phone_Weight-44, moment_status, 44, 44);
    [btn_SignIn setTitle:@"追加" forState:UIControlStateNormal];
    [btn_SignIn setBackgroundImage:[UIImage imageNamed:@"btn_color6.png"] forState:UIControlStateHighlighted];
    btn_SignIn.titleLabel.textColor=[UIColor whiteColor];
    btn_SignIn.titleLabel.font=[UIFont systemFontOfSize:15];
    btn_SignIn.backgroundColor=[UIColor clearColor];
    btn_SignIn.tag=buttonTag;
    [btn_SignIn addTarget:self action:@selector(Action:) forControlEvents:UIControlEventTouchUpInside];
    [nav_View.view_Nav  addSubview:btn_SignIn];
    //日历
    UIImageView *img_arrow=[[UIImageView alloc]init];
    img_arrow.frame=CGRectMake(Phone_Weight-44-44-44, moment_status, 44, 44);
    img_arrow.image=[UIImage imageNamed:@"nav_menu_arrow.png"];
    [nav_View.view_Nav addSubview:img_arrow];
    
    UIButton *btn=[UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame=CGRectMake(Phone_Weight/2-44, moment_status, 44*2.5, 44);
    [btn setBackgroundImage:[UIImage imageNamed:@"nav_menu_arrow_back.png"] forState:UIControlStateHighlighted];
    btn.backgroundColor=[UIColor clearColor];
    btn.tag=buttonTag+1;
    [btn addTarget:self action:@selector(Action:) forControlEvents:UIControlEventTouchUpInside];
    [nav_View.view_Nav  addSubview:btn];
    
    str_auth=[[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"auth"];
    tableView_Submit=[[UITableView alloc]init];

    //但boss登录时我的订单实在菜单的贴片中 push之后tableView的framework要重新设置
    tableView_Submit.frame= CGRectMake(0, 44+moment_status, Phone_Weight, Phone_Height-(44+moment_status));
    UIButton *btn_back=[UIButton buttonWithType:UIButtonTypeCustom];
    btn_back.frame=CGRectMake(0, moment_status, 60, 44);
    btn_back.backgroundColor=[UIColor clearColor];
    btn_back.tag=buttonTag-1;
    [btn_back addTarget:self action:@selector(Action:) forControlEvents:UIControlEventTouchUpInside];
    [nav_View.view_Nav  addSubview:btn_back];
    [btn_back setBackgroundImage:[UIImage imageNamed:@"btn_color6.png"] forState:UIControlStateHighlighted];
    [btn_back setTitle:@"< 返回" forState:UIControlStateNormal];
    [btn_back setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    btn_back.titleLabel.font=[UIFont systemFontOfSize:15];
    
    tableView_Submit.backgroundColor=[UIColor clearColor];
    tableView_Submit.separatorStyle = UITableViewCellSeparatorStyleNone;//隐藏tableViewCell的分割线
    [self.view addSubview:tableView_Submit];
    tableView_Submit.dataSource=self;
    tableView_Submit.delegate=self;
    
    imageView_Face=[[UIImageView alloc]init];
    imageView_Face=[NavView Show_Nothing_Face];
    
    reader = [ZbarCustomVC getSingle];  //1.0.4
    arr_ListData = [NSMutableArray array];
}

#pragma mark ---- zbar custom end ----
-(void)Creat_TableView
{
    [self Is_Nothing];
    [tableView_Submit reloadData];
}
-(void)Is_Nothing
{
    if(arr_ListData.count==0)
    {
        [self.view addSubview:imageView_Face];
    }
    else
    {
        [imageView_Face removeFromSuperview];
    }
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return arr_ListData.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    if(isPad)
        return 110;
    return 130;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SubmitOrderTableViewCell *cell=(SubmitOrderTableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"SubmitOrderTableViewCell"];
    if(cell==nil)
    {
        NSArray *nib;
        if(isPad)
        {
            nib= [[NSBundle mainBundle] loadNibNamed:@"SubmitOrderTableViewCell_ipad" owner:[SubmitOrderTableViewCell class] options:nil];
        }
        else
        {
            nib= [[NSBundle mainBundle] loadNibNamed:@"SubmitOrderTableViewCell" owner:[SubmitOrderTableViewCell class] options:nil];
        }
        cell = (SubmitOrderTableViewCell *)[nib objectAtIndex:0];
        cell.contentView.backgroundColor = [UIColor clearColor];
    }
    cell.backgroundColor=[UIColor clearColor];
    UIImageView *viewCell;
    viewCell=[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, Phone_Weight, 120)];
    viewCell.image=[UIImage imageNamed:@"cell_message_background@2X.png"]; //白色背景图片
    [cell insertSubview:viewCell atIndex:0];
    viewCell=nil;
    
    NSDictionary *dic=[arr_ListData objectAtIndex:indexPath.row];
    NSString *tempIndexNumber_order = [dic objectForKey:@"tempIndexNumber_order"];
    if (tempIndexNumber_order.integerValue > 0) {
        cell.lab_gname.text = [dic objectForKey:@"terminal"];
        cell.lab_should.text = [dic objectForKey:@"osum"];
        cell.lab_real.text = [dic objectForKey:@"orsum"];
        NSString *tempStr = [dic objectForKey:@"odiscount"];
        NSString *discountStr = [NSString stringWithFormat:@"%ld%@",tempStr.integerValue*100,@"%"];
        cell.lab_count_number.text = discountStr;
        cell.offLineLabel.hidden = NO;
        cell.offLineLabel.top = 15;
    }else {
        cell.lab_gname.text=[dic objectForKey:@"gname"];
        cell.lab_real.text=[NSString stringWithFormat:@"%@元",[dic objectForKey:@"orsum"]];
        cell.lab_should.text=[NSString stringWithFormat:@"%@元",[dic objectForKey:@"osum"]];
        cell.lab_count_number.text=[NSString stringWithFormat:@"%@%@",[dic objectForKey:@"odiscount"],@"%"];
        cell.offLineLabel.hidden = YES;
    }
    
    cell.lab_gname.top = 15;
    cell.lab_gcode.text=[dic objectForKey:@"index_no"];//订单编号
    if([[dic objectForKey:@"ctc_sts"]isEqualToString:@"0"]) //ctc_sts 0/不代收 1/代收
    {
        cell.img_isInstead.image=[UIImage imageNamed:@"cell_unimplement.png"]; //方块图片
    }
    else
    {
        cell.img_isInstead.image=[UIImage imageNamed:@"cell_implement.png"];   //对号方块图片
    }
    if([[dic objectForKey:@"exe_sts"]isEqualToString:@"0"])  //exe_sts 0/未执行 1/已执行
    {
        cell.img_exe_sts.image=[UIImage imageNamed:@"cell_unimplement.png"];
    }
    else
    {
        cell.img_exe_sts.image=[UIImage imageNamed:@"cell_implement.png"];
    }
    cell.lab_time.text=[dic objectForKey:@"ins_date"];
    cell.img_am_pm.image=[UIImage imageNamed:[NavView returnPeriod:[dic objectForKey:@"ins_date"]]];
    cell.selectionStyle=UITableViewCellSelectionStyleNone;//无点击效果
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    OrderListViewController *order=[[OrderListViewController alloc]init];
    order.str_isfromeDetail=@"1";//是查看详细
    NSDictionary *dic=[arr_ListData objectAtIndex:indexPath.row];
    order.str_title=[NSString stringWithFormat:@"订单详细"];
    
    if (![Function StringIsNotEmpty:[dic objectForKey:@"tempIndexNumber_order"]]) {
        order.str_index_no=[dic objectForKey:@"index_no"];
        order.cIndexNumber = [dic objectForKey:@"cindex_no"];
    }else {
        [[AddProduct sharedInstance].arr_AddToList removeAllObjects];
        order.dataDic = dic;
        order.localFlag = 1;
        order.str_isfromeDetail=@"0";
    }
    app.isApproval=NO;
    [self.navigationController pushViewController:order animated:YES];
    dic=nil;
}

-(void)Action:(id)sender
{
    UIButton *btn=(UIButton *)sender;
    if(btn.tag==buttonTag-1)
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
    else if(btn.tag==buttonTag)//去填写订单表
    {
        if ([AddProduct sharedInstance].arr_AddToList.count) {
            [[AddProduct sharedInstance].arr_AddToList removeAllObjects];
        }
        UIActionSheet *actionSheet =[[UIActionSheet alloc]initWithTitle:@"选择创建方式" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"扫二维码",@"列表", nil];
        
        [actionSheet showInView:self.view];
        actionSheet.tag=1;
        actionSheet=nil;
    }
    else if(buttonTag+1==btn.tag)//日历按钮
    {
        AdvancedSearchViewController *ad=[[AdvancedSearchViewController alloc]init];
        ad.str_Num=@"7";
        ad.returnFlag = 0;
        [self.navigationController pushViewController:ad animated:YES];
    }
}
#pragma mark -
#pragma mark ActionSheet delegate methods
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(actionSheet.tag==1){
        if(buttonIndex==0){
            [self CreateTheQR];
        }
        else if(buttonIndex==1){
            NotQRViewController *notQR=[[NotQRViewController alloc]init];
            notQR.str_From=@"2";//我的订单 Orderlist
            [self.navigationController pushViewController: notQR animated:YES];
        }
    }
}
-(void)Get_OrderList
{
    if([Function isConnectionAvailable])
    {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.mode = MBProgressHUDModeIndeterminate;
        hud.labelText = @"加载中...";//加载提示语言

        if(app.isPortal)
        {
            urlString=[NSString stringWithFormat:@"%@%@",KPORTAL_URL,KGet_Order];
        }
        else
        {
            urlString=[NSString stringWithFormat:@"%@%@",kBASEURL,KGet_Order];
        }
        NSURL *url = [ NSURL URLWithString:urlString];
         ASIFormDataRequest *request = [ ASIFormDataRequest requestWithURL :url];
        request.delegate = self;
        request.tag = 100;
        [request setRequestMethod:@"POST"];
        [request setPostValue:[[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"account"]forKey:KUSER_UID];
        [request setPostValue:[[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"secret"] forKey:KUSER_PASSWORD];
        [request setPostValue:[[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"token"] forKey:@"user.token"];
        [request setPostValue:[[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"db_ip"] forKey:@"db_ip"];
        [request setPostValue:[[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"db_name"] forKey:@"db_name"];
        
        if([Advance_Search sharedInstance].arr_search.count>0)
        {
            [request setPostValue: [[Advance_Search sharedInstance].arr_search objectAtIndex:0] forKey:@"start_date"];
            [request setPostValue: [[Advance_Search sharedInstance].arr_search objectAtIndex:1] forKey:@"end_date"];
            [request setPostValue: [[Advance_Search sharedInstance].arr_search objectAtIndex:2] forKey:@"minOrsum"];
            [request setPostValue: [[Advance_Search sharedInstance].arr_search objectAtIndex:3] forKey:@"maxOrsum"];
            [request setPostValue: [NavView return_YES_Or_NO:[[Advance_Search sharedInstance].arr_search objectAtIndex:4]] forKey:@"exe_sts"];
            [request setPostValue: [NavView return_YES_Or_NO:[[Advance_Search sharedInstance].arr_search objectAtIndex:5]] forKey:@"ctc_sts"];
        }
        else
        {
            [request setPostValue: [Function getYearMonthDay_Now] forKey:@"start_date"];
            [request setPostValue: [Function getYearMonthDay_Now] forKey:@"end_date"];
        }
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
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    
    SBJsonParser *parser = [[SBJsonParser alloc] init];
    NSDictionary *dict =[parser objectWithString: jsonString];
    if([[dict objectForKey:@"ret"]isEqualToString:@"0"])
    {
        arr_ListData = [NSMutableArray array];
        [self localMethod];
        NSArray *dataArray = [dict objectForKey:@"OrderList"];
        for (int i = 0; i < dataArray.count; i ++) {
            [arr_ListData addObject:[dataArray objectAtIndex:i]];
        }

        [self Is_Nothing];
        [self Creat_TableView];
    }
    else
    {
        [SGInfoAlert showInfo:@"获取订单列表失败"
                      bgColor:[[UIColor darkGrayColor] CGColor]
                       inView:self.view
                     vertical:0.5];
    }
    
    dict=nil;
}
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

-(void)dismissZbarAction {
    //Dlog(@"dismiss"); //iOS6
}
- (void)zbarDismissAction {
    //Dlog(@"dismiss"); //iOS7
}

-(void)getCodeString:(NSString *)codeString {
    self.str_qr_url = codeString;
    [self SubmitTheQR_Inform:codeString];
}

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
        self.str_qr_url = result;
        [self SubmitTheQR_Inform:result];
    }];
}

-(void)SubmitTheQR_Inform:(NSString *)str_QR_atu
{
    if([Function isConnectionAvailable])
    {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.mode = MBProgressHUDModeIndeterminate;
        hud.labelText = @"加载中...";//加载提示语言

        if(app.isPortal)
        {
            urlString=[NSString stringWithFormat:@"%@%@",KPORTAL_URL,KGET_CUSTOMER];
        }
        else
        {
            urlString=[NSString stringWithFormat:@"%@%@",kBASEURL,KGET_CUSTOMER];
        }
        NSURL *url = [ NSURL URLWithString :  urlString];
        ASIFormDataRequest *request = [ ASIFormDataRequest requestWithURL :url];
        request.delegate = self;
        request.tag = 101;
        [request setRequestMethod:@"POST"];
        [request setPostValue:[[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"account"]forKey:KUSER_UID];
        [request setPostValue:[[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"secret"] forKey:KUSER_PASSWORD];
        [request setPostValue:[[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"token"] forKey:@"user.token"];
        [request setPostValue:[[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"db_ip"] forKey:@"db_ip"];
        [request setPostValue:[[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"db_name"] forKey:@"db_name"];
        
        [request setPostValue:str_QR_atu forKey:KATU];
        [request setPostValue:@"1" forKey:@"stype"];//2考勤 1巡访 物料
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
-(void)JsonString:(NSString *)jsonString
{
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    SBJsonParser *parser = [[SBJsonParser alloc] init];
    NSDictionary *dict =[parser objectWithString: jsonString];
    if([[dict objectForKey:@"ret"]isEqualToString:@"0"])
    {
        NSDictionary *dic=[dict objectForKey:@"CustomerInfo"];
        if([[[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"gbelongto"] isEqualToString:[dic objectForKey:@"gbelongto"]])
        {
            app.isApproval=NO;
            app.str_Product_material=@"0";//商品
            OrderListViewController *orderVC=[[OrderListViewController alloc]init];
            orderVC.str_title=@"添加订单";
            orderVC.str_isFromOnlineOrder=@"0";//从订单列表来
            orderVC.cIndexNumber = [dic objectForKey:@"index_no"];
            orderVC.is_QR=YES;
            orderVC.str_cindex_no= [dic objectForKey:@"index_no"];//从二维码获取终端编号
            [self.navigationController pushViewController:orderVC animated:YES];
        }
        else
        {
            //不是同一个部门弹出警告框
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"您不隶属该部门,不能下订单!"delegate:nil cancelButtonTitle:nil otherButtonTitles:@"确定",nil];
            [alert show];
            alert=nil;
        }
        dic=nil;
    }
    else
    {
        [SGInfoAlert showInfo: [dict objectForKey:@"message"]
                      bgColor:[[UIColor darkGrayColor] CGColor]
                       inView:self.view
                     vertical:0.5];
    }
    
    dict=nil;
}

-(void)requestFinished:(ASIHTTPRequest *)request {
    if (request.tag == 101) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        
        if([request responseStatusCode]==200)
        {
            NSString * jsonString  =  [request responseString];
            [self JsonString:jsonString];
        }
        else
        {
            [SGInfoAlert showInfo:@"发生异常,请稍后再试"
                          bgColor:[[UIColor darkGrayColor] CGColor]
                           inView:self.view
                         vertical:0.5];
            [NdUncaughtExceptionHandler Post_url:[NSString stringWithFormat:@"URL:%@,HTTP_Code%d",urlString,[request responseStatusCode]]];
        }
        return;
    }
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    if([request responseStatusCode]==200)
    {
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

#pragma mark ---- presentView delegate method
- (void)presentViewDissmissAction {
    [[KGModal sharedInstance] closeAction:nil];
}

- (void)localMethod {
    if([Function judgeFileExist:Order_Local Kind:Library_Cache])
    {
        NSInteger k = 0;
        NSInteger m = 0;
        NSMutableArray *orderLArray = [Function ReadFromFile:Order_Local WithKind:Library_Cache];
        for (int n = 0; n < arr_ListData.count; n ++) {
            NSString *gnameString = [[arr_ListData objectAtIndex:n] objectForKey:@"tempIndexNumber_order"];
            if (gnameString.integerValue) {
                [arr_ListData removeObjectAtIndex:n];
            }
        }
    
        for (int i = 0; i < orderLArray.count; i ++)
        {
                for (int j = 0; j < arr_ListData.count; j ++)
                {
                    k = 0;
                    NSString *gnameString = [[arr_ListData objectAtIndex:j] objectForKey:@"tempIndexNumber_order"];
                    NSString *gnameString1 = [[orderLArray objectAtIndex:i] objectForKey:@"tempIndexNumber_order"];
                    if ([gnameString isEqualToString:gnameString1]) {
                        m = j;
                        k = 1;
                        break;
                    }
                }
                if (k == 0) {
                    [arr_ListData insertObject:[orderLArray objectAtIndex:i] atIndex:0];
                }else {
                    [arr_ListData removeObjectAtIndex:m];
                    [arr_ListData insertObject:[orderLArray objectAtIndex:i] atIndex:m];
                }
        }
        [self Creat_TableView];
    }
}

@end
