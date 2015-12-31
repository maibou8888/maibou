//
//  VisitViewController.m
//  WZYB_syb
//
//  Created by wzyb on 14-6-27.
//  Copyright (c) 2014年 WZYB. All rights reserved.
//

#import "VisitViewController.h"
#import "ZBarSDK.h"
#import "QRCodeGenerator.h"
#import "AppDelegate.h"
#import "KGModal.h"
#import <QuartzCore/QuartzCore.h>
#import "PresentView.h"
@interface VisitViewController ()<MyDelegate_SignIn,MyDelegate_AdvancedSearch,zbarNewViewDelegate,PresentViewDelegate>
{
    AppDelegate *app;
    NSString *urlString;
}

@end

@implementation VisitViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
#pragma mark  MyDelegate

-(void)Notify_SignIn //signInVC点击返回执行的委托事件
{
    app.str_Date=[Function getYearMonthDay_Now];
    [self getVistList];//获取巡访列表
}
-(void)Notify_AdvancedSearch //高级搜索点击搜索时执行的委托事件
{
    [self getVistList];//获取巡访列表
}
#pragma mark MyDelegate end

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self All_Init];
    app.str_Date=[Function getYearMonthDay_Now];
    [[Advance_Search sharedInstance].arr_search removeAllObjects];
    [self getVistList];//获取巡访列表
}
-(void)viewWillAppear:(BOOL)animated
{
    app.str_Date=[Function getYearMonthDay_Now];
    if(![str_auth isEqualToString:@"4"])
    {
        [[Advance_Search sharedInstance].arr_search removeAllObjects];
    }
}
-(void)All_Init
{
     app=(AppDelegate *)[[UIApplication sharedApplication]delegate];
    if(StatusBar_System>0)
        moment_status=20;
    else moment_status=0;
    //导航及导航键start
    NavView *nav_View=[[NavView alloc]init];
    [self.view addSubview: [nav_View NavView_Title1:@"签到巡访"]];
    //扫描二维码 之后 并进行页面跳转
    UIButton *btn_QR=[UIButton buttonWithType:UIButtonTypeCustom];
    btn_QR.frame=CGRectMake(Phone_Weight-45, moment_status, 44, 44);
    [btn_QR setTitle:@"新建" forState:UIControlStateNormal];
    [btn_QR setBackgroundImage:[UIImage imageNamed:@"btn_color6.png"] forState:UIControlStateHighlighted];
    [btn_QR setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    btn_QR.titleLabel.font=[UIFont systemFontOfSize:15];
    btn_QR.backgroundColor=[UIColor clearColor];
    btn_QR.tag=buttonTag;
    [btn_QR addTarget:self action:@selector(Action_QR:) forControlEvents:UIControlEventTouchUpInside];
    [nav_View.view_Nav  addSubview:btn_QR];
    //日期按钮
    UIImageView *img_arrow=[[UIImageView alloc]init];
    img_arrow.frame=CGRectMake(Phone_Weight-44-44-44, moment_status, 44, 44);
    img_arrow.image=[UIImage imageNamed:@"nav_menu_arrow.png"];
    [nav_View.view_Nav addSubview:img_arrow];
    
    UIButton *btn=[UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame=CGRectMake(Phone_Weight/2-44, moment_status, 44*2.5, 44);
    [btn setBackgroundImage:[UIImage imageNamed:@"nav_menu_arrow_back.png"] forState:UIControlStateHighlighted];
    btn.backgroundColor=[UIColor clearColor];
    btn.tag=buttonTag+1;
    [btn addTarget:self action:@selector(Action_QR:) forControlEvents:UIControlEventTouchUpInside ];
    [nav_View.view_Nav  addSubview:btn];
    //end
    str_auth=[[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"auth"]; 
    tableView_Visit=[[UITableView alloc]init];
#pragma mark ---- 1.0.4 s
    UIButton *btn_back=[UIButton buttonWithType:UIButtonTypeCustom];//签到按钮
    btn_back.frame=CGRectMake(0, moment_status, 60, 44);
    btn_back.backgroundColor=[UIColor clearColor];
    btn_back.tag=buttonTag-1;
    [btn_back addTarget:self action:@selector(Action_QR:) forControlEvents:UIControlEventTouchUpInside];
    [nav_View.view_Nav  addSubview:btn_back];
    [btn_back setBackgroundImage:[UIImage imageNamed:@"btn_color6.png"] forState:UIControlStateHighlighted];
    [btn_back setTitle:@"< 返回" forState:UIControlStateNormal];
    [btn_back setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    btn_back.titleLabel.font=[UIFont systemFontOfSize:15];

    tableView_Visit.frame=CGRectMake(0, 44+moment_status, Phone_Weight, Phone_Height-(44+moment_status));
#pragma mark ---- 1.0.4 e
    tableView_Visit.backgroundColor=[UIColor clearColor];
    [self.view addSubview:tableView_Visit];
    tableView_Visit.separatorStyle = UITableViewCellSeparatorStyleNone;//隐藏tableViewCell的分割线
    tableView_Visit.dataSource=self;
    tableView_Visit.delegate=self;

    imageView_Face=[[UIImageView alloc]init];
    imageView_Face=[NavView Show_Nothing_Face];
    
    reader = [ZbarCustomVC getSingle];  //1.0.4
}
-(void)Creat_TableView
{
    [tableView_Visit reloadData];
}
-(void)Is_Nothing
{
    if(arr_VistData.count==0)
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
    return arr_VistData.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    return 120;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    VisitCell *cell=(VisitCell*)[tableView dequeueReusableCellWithIdentifier:@"VisitCell"];
    if(cell==nil)
    {
        NSArray *nib;
        if(isPad)
        {
            nib = [[NSBundle mainBundle] loadNibNamed:@"VisitCell_ipad" owner:[VisitCell class] options:nil];
        }
        else
        {
            nib = [[NSBundle mainBundle] loadNibNamed:@"VisitCell" owner:[VisitCell class] options:nil];
        }
        cell = (VisitCell *)[nib objectAtIndex:0];
        cell.contentView.backgroundColor = [UIColor clearColor];
    }
    cell.backgroundColor=[UIColor clearColor];
    NSDictionary *dic=[arr_VistData objectAtIndex:indexPath.row];
    cell.label_CompanyName.text=[dic objectForKey:@"gname"];
    cell.label_during.text=[dic objectForKey:@"access_time"];
    cell.label_SignUp_time.text=[dic objectForKey:@"access_start_date"];
    cell.label_SignOut_time.text=[dic objectForKey:@"access_end_date"];
    /*
     gps_result
     0:疑似地址不匹配
     1:到达已签到
     2:到达未签退
     3:签到成功 签到和签退的流程已结束 gps_result为3 
     -1:终端无坐标
     */
    cell.imageView_status.image=[UIImage imageNamed:[NSString stringWithFormat:@"%@.png",[self return_signUpStatus:[dic objectForKey:@"gps_result"]]]];
    NSArray *array = [[dic objectForKey:@"access_start_date"] componentsSeparatedByString:@" "]; //寻访日期
    NSString *date=[array objectAtIndex:0];
    NSString *today=[Function getYearMonthDay_Now];
    if([[dic objectForKey:@"gps_result"] isEqualToString:@"1"]&&[date isEqualToString:today])
    {
        cell.imageView_tap.image=[UIImage imageNamed:@"cell_right_arrow.png"];
    }
    else
    {
//        cell.imageView_tap.image=[UIImage imageNamed:@""];
    }
    cell.selectionStyle=UITableViewCellSelectionStyleNone;//无点击效果
    return cell;
}
-(NSString*)return_signUpStatus:(NSString *)str
{
    /*
     gps_result
     0:疑似地址不匹配
     1:到达已签到
     2:到达未签退
     3:签到成功
     -1:终端无坐标
     */
    if([str isEqualToString:@"-1"])
    {
        return @"cell_sign-1";
    }
    else if([str isEqualToString:@"1"])
    {
        return @"cell_sign1";//到达已签到
    }
    else if([str isEqualToString:@"2"])
    {
        return @"cell_sign2";
    }
    else if([str isEqualToString:@"3"])
    {
        return @"cell_sign3";
    }
    else //0
    {
        return @"cell_sign0";
    }
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //只有当gps_result为1的时候（即到达已签到）才能点击
    NSDictionary *dic=[arr_VistData objectAtIndex:indexPath.row];
    NSArray *array = [[dic objectForKey:@"access_start_date"] componentsSeparatedByString:@" "];
    NSString *date=[array objectAtIndex:0];
    NSString *today=[Function getYearMonthDay_Now];
    if([[dic objectForKey:@"gps_result"] isEqualToString:@"1"]&&[today isEqualToString:date])//到达已签到
    {
        SignInViewController *signVC=[[SignInViewController alloc]initWithNibName:@"SignInViewController" bundle:nil ];
        signVC.str_isFrom_More=@"1";//巡访
        app.VC_notify=signVC;
        signVC.is_QR=NO;
        app.str_atu=[dic objectForKey:@"atu"];
        [self.navigationController pushViewController:signVC animated:YES];
    }else {
        if([Function isConnectionAvailable])
        {
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            hud.mode = MBProgressHUDModeIndeterminate;
            hud.labelText = @"加载中...";//加载提示语言
            
            if(app.isPortal)
            {
                urlString=[NSString stringWithFormat:@"%@%@",KPORTAL_URL,KGet_matter];
            }
            else
            {
                urlString=[NSString stringWithFormat:@"%@%@",kBASEURL,KGet_matter];
            }
            NSURL *url = [ NSURL URLWithString :  urlString];
            ASIFormDataRequest *request = [ ASIFormDataRequest requestWithURL :url];
            request.delegate = self;
            request.tag = 104;
            [request setRequestMethod:@"POST"];
            [request setPostValue:[[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"account"]forKey:KUSER_UID];
            [request setPostValue:[[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"secret"] forKey:KUSER_PASSWORD];
            [request setPostValue:[[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"token"] forKey:@"user.token"];
            [request setPostValue:[[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"db_ip"] forKey:@"db_ip"];
            [request setPostValue:[[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"db_name"] forKey:@"db_name"];
            
            [request setPostValue:@"1" forKey:@"item.stype"];
            [request setPostValue:[dic objectForKey:@"index_no"] forKey:@"item.index_no"];
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
}
-(void)Action_QR:(id)sender
{
    UIButton *btn=(UIButton *)sender;
    if(btn.tag==buttonTag-1)
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
    else if(btn.tag==buttonTag)//去签到
    {
        if([[[SelfInf_Singleton sharedInstance].dic_SelfInform  objectForKey:@"qrcode_only"] isEqualToString:@"1"])
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"二维码扫终端" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定",nil];
            [alert show];
            alert.tag=10;
            alert=nil;
        }
        else
        {
            UIActionSheet *actionSheet =[[UIActionSheet alloc]initWithTitle:@"选择新建方式" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"二维码", @"列表",nil];
            if([str_auth isEqualToString:@"4"])
            {
                [actionSheet showInView:self.view];
            }
            else
            {
#pragma mark ---- 1.0.4 s
                [actionSheet showInView:self.view];
#pragma mark ---- 1.0.4 e
            }
            actionSheet.tag=1;
            actionSheet=nil;
        }
    }
    else if(buttonTag+1==btn.tag)//日历
    {
        AdvancedSearchViewController *ad=[[AdvancedSearchViewController alloc]init];
        ad.str_Num=@"2";
        [self.navigationController pushViewController:ad animated:YES];
    }
}
#pragma mark -
#pragma mark ActionSheet delegate methods
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    //Dlog(@"%d",buttonIndex);
    if(actionSheet.tag==1)
    {
        if(buttonIndex==0)
        {
            [self Let_QR];  //二维码
        }
        else if(buttonIndex==1)
        {
            //Dlog(@"列表选择");
            NotQRViewController *notQR=[[NotQRViewController alloc]init];
            notQR.str_From=@"1";//巡访
            [self.navigationController pushViewController: notQR animated:YES];
        }
    }
}
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(alertView.tag==10)
    {
        if(buttonIndex==1)
        {
            [self Let_QR];
        }
    }
}
-(void)Let_QR
{
    [self CreateTheQR];
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

-(void)dismissZbarAction {
    //Dlog(@"dismiss"); //iOS6
}
- (void)zbarDismissAction {
    //Dlog(@"dismiss"); //iOS7
}

#pragma mark ---- isIOS7 委托回调
//ios7以上获取二维码方法
-(void)getCodeString:(NSString *)codeString {
    SignInViewController *signVC=[[SignInViewController alloc]initWithNibName:@"SignInViewController" bundle: nil];
    signVC.str_isFrom_More=@"1";//巡访
    signVC.is_QR=YES;
    signVC.atuString = codeString;
    app.VC_notify=signVC;
    [self.navigationController pushViewController:signVC animated:YES];
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
        SignInViewController *signVC=[[SignInViewController alloc]initWithNibName:@"SignInViewController" bundle: nil];
        signVC.str_isFrom_More=@"1";//巡访
        signVC.is_QR=YES;
        signVC.atuString = result;
        app.VC_notify=signVC;
        [self.navigationController pushViewController:signVC animated:YES];
    }];
}

-(void)getVistList//获取巡访列表
{
    if([Function isConnectionAvailable])
    {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.mode = MBProgressHUDModeIndeterminate;
        hud.labelText = @"加载中...";//加载提示语言

        if(app.isPortal)
        {
            urlString=[NSString stringWithFormat:@"%@%@",KPORTAL_URL,KGET_ACCESS];
        }
        else
        {
            urlString=[NSString stringWithFormat:@"%@%@",kBASEURL,KGET_ACCESS];
        }
        NSURL *url = [ NSURL URLWithString :  urlString];
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
            [request setPostValue:[[Advance_Search sharedInstance].arr_search objectAtIndex:0] forKey:@"start_date"];
            [request setPostValue: [[Advance_Search sharedInstance].arr_search objectAtIndex:1]forKey:@"end_date"];
            [request setPostValue:[NavView return_SignStatus:[[Advance_Search sharedInstance].arr_search objectAtIndex:2]] forKey:@"gps_result"];
        }
        else
        {
            //没有搜索条件时默认为搜索今天的签到寻访记录
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
-(void)get_JsonString:(NSString *)jsonString Type:(NSString*)type
{
    SBJsonParser *parser = [[SBJsonParser alloc] init];
    NSDictionary *dict =[parser objectWithString: jsonString];
    if([[dict objectForKey:@"ret"] isEqualToString:@"0"])
    {
        if([type isEqualToString:@"0"])//请求列表
        {
             arr_VistData= [dict objectForKey:@"AccessList"] ;
            [self Is_Nothing];
            [self Creat_TableView];
        }
        else//向网络发送二维码
        {
            NSDictionary *dic_Return=[dict objectForKey:@"CustomerInfo"];
            SignInViewController *signVC=[[SignInViewController alloc]init];
            signVC.qr_getCustomer=[[QR_GetCustomer alloc]init];
            signVC.qr_getCustomer.str_gname=[dic_Return objectForKey:@"gname"];
            signVC.qr_getCustomer.str_address=[dic_Return objectForKey:@"gaddress"];
            signVC.qr_getCustomer.str_last_sign_date=[dic_Return objectForKey:@"last_sign_date"];
            signVC.qr_getCustomer.str_glng=[dic_Return objectForKey:@"glng"];
            signVC.qr_getCustomer.str_glat=[dic_Return objectForKey:@"glat"];
            signVC.qr_getCustomer.str_belongto=[dic_Return objectForKey:@"belongto"];
            signVC.qr_getCustomer.str_index_no=[dic_Return objectForKey:@"index_no"];
            signVC.qr_getCustomer.str_gbelongto=[dic_Return objectForKey:@"gbelongto"];
            signVC.qr_getCustomer.str_gtype=[dic_Return objectForKey:@"gtype"];
            signVC.qr_getCustomer.str_atu=self.qRUrl;
            [self.tabBarController.navigationController pushViewController:signVC animated:YES];
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)requestFinished:(ASIHTTPRequest *)request {
    if (request.tag == 100) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        
        if([request responseStatusCode]==200)
        {
            NSString * jsonString  =  [request responseString];
            [self get_JsonString:jsonString Type:@"0"];
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
    }else if (request.tag == 104) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        if([request responseStatusCode]==200)
        {
            NSString * jsonString  =  [request responseString];
            SBJsonParser *parser = [[SBJsonParser alloc] init];
            NSDictionary *dict =[parser objectWithString: jsonString];
            OrderListDynamic *order=[[OrderListDynamic alloc]init];
            order.fromSign = 1;
            order.dic_json=dict;
            order.isDetail=YES;
            order.titleString = @"附加信息";
            [self.navigationController pushViewController:order animated:YES];
        }
    }

    [MBProgressHUD hideHUDForView:self.view animated:YES];
    if([request responseStatusCode]==200)
    {
        NSString * jsonString  =  [request responseString];
        [self get_JsonString:jsonString Type:@"1"];
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
    if (request.tag == 100) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        
        [SGInfoAlert showInfo:@"哎呀，服务器无响应，一会再试试吧"
                      bgColor:[[UIColor darkGrayColor] CGColor]
                       inView:self.view
                     vertical:0.5];
        // 请求响应失败，返回错误信息
        //Dlog(@"HTTP 响应码：%d",[request responseStatusCode]);
        return;
    }
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    
    [SGInfoAlert showInfo:@"哎呀，服务器无响应，一会再试试吧"
                  bgColor:[[UIColor darkGrayColor] CGColor]
                   inView:self.view
                 vertical:0.5];
    // 请求响应失败，返回错误信息
    //Dlog(@"HTTP 响应码：%d",[request responseStatusCode]);
}

#pragma mark ---- presentView delegate method

- (void)presentViewDissmissAction {
    
    [[KGModal sharedInstance] closeAction:nil];
    
}

@end
