//
//  RootViewController.m
//  WZYB_syb
//
//  Created by wzyb on 14-6-5.
//  Copyright (c) 2014年 WZYB. All rights reserved.
//
#import "RootViewController.h"
#import "Function.h"
#import "Document_Read.h"
#import "SDWebImageDownloader.h"
#import "AppDelegate.h"
#import "ServerViewController.h"
@interface RootViewController ()
{
    AppDelegate *app;
    int comHostFlg;//主服务器通讯失败FLG（0：成功 1：失败）
}

@property (weak, nonatomic) IBOutlet UIButton *codeNewBtn;
@property (weak, nonatomic) IBOutlet UIButton *codeBtn;
- (IBAction)serverAcction:(id)sender;
- (IBAction)remCodeAction:(id)sender;

@end

@implementation RootViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (NSArray *)rangesOfString:(NSString *)searchString inString:(NSString *)str {
 
    NSArray *arr=[str componentsSeparatedByString:searchString];
    return arr;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self All_Init];
    [self isLoad_past];
    if([Function isBlankString:[[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"coname"]])
    {
       lab_CompanyTitle.text=@"";
    }
    else
    {
        lab_CompanyTitle.text=[[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"coname"];
    }
    [self getSecondServer];
    isSelect=YES;
}
-(void)All_Init
{
    app=(AppDelegate *)[UIApplication sharedApplication].delegate;
    app.gpsFlag2 = 0;// music no-limit gps monitor flag(0:stop 1:run)
    app.gps_threadFlag = 0;// monitor thread is running?(0:no runing 1:running)
    
    comHostFlg = 0;
    
    textField_Account.placeholder=@"账号:";
    textField_Account.returnKeyType=UIReturnKeyNext;
    [self.view addSubview:textField_Account];
    
    textField_Secret.placeholder=@"密码:";
    textField_Secret.secureTextEntry=YES;
    textField_Secret.returnKeyType=UIReturnKeyDone;
    [self.view addSubview:textField_Secret];
    
    textField_Account.keyboardType=UIKeyboardTypeNumbersAndPunctuation;
    textField_Secret.keyboardType=UIKeyboardTypeNumbersAndPunctuation;
    [textField_Account setClearButtonMode:UITextFieldViewModeAlways];
    [textField_Secret setClearButtonMode:UITextFieldViewModeAlways];
    textField_Account.delegate=self;
    textField_Secret.delegate=self;
    
    //登录按钮
    btn_Login.backgroundColor=[UIColor clearColor];
    [btn_Login setImage:[UIImage imageNamed:@"icon_root_btn_sgin@2X"] forState:UIControlStateNormal];
    [self.view addSubview:btn_Login];
    btn_Login.tag=buttonTag;
    [btn_Login addTarget:self action:@selector(RegisterAnDlogin_Function:) forControlEvents:UIControlEventTouchUpInside];
   
    //公司CompanyTitle
    lab_CompanyTitle.font=[UIFont fontWithName:@"Helvetica-Bold" size:23];
    lab_CompanyTitle.textAlignment=NSTextAlignmentCenter;
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    self.navigationController.navigationBarHidden=YES;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL select = [defaults boolForKey:@"isSelectCode"];
    if (select) {
        textField_Secret.text =[[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"secret"];
        [self.codeBtn setImage:[UIImage imageNamed:@"icon_agree.png"] forState:UIControlStateNormal];
        [self.codeNewBtn setImage:[UIImage imageNamed:@"icon_agree.png"] forState:UIControlStateNormal];
    }else {
        textField_Secret.text = @"";
    }
    lab_CompanyTitle.text = [[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"coname"];//set the name of the corp.
}
-(BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
    [UIMenuController sharedMenuController].menuVisible = NO;  //donot display the menu
    [self resignFirstResponder];         //do not allow the user to selected anything
    return NO;
}
- (BOOL)verify
{
    if(!isSelect)
    {
        [SGInfoAlert showInfo1:@"请先同意应用协议"
                      bgColor:[[UIColor darkGrayColor] CGColor]
                       inView:self.view
                     vertical:0.5];
        return false;
    }
    if(textField_Secret.text.length==0&&textField_Account.text.length==0)
    {
        [SGInfoAlert showInfo1:@"账号和密码不能为空"
                      bgColor:[[UIColor darkGrayColor] CGColor]
                       inView:self.view
                     vertical:0.5];
        return false;
    }
    else
    {
        if (textField_Account.text.length == 0) {
            [SGInfoAlert showInfo1:@"账号不能为空"
                          bgColor:[[UIColor darkGrayColor] CGColor]
                           inView:self.view
                         vertical:0.5];
            return false;
        }
        if (textField_Secret.text.length == 0) {
            [SGInfoAlert showInfo1:@"密码不能为空"
                          bgColor:[[UIColor darkGrayColor] CGColor]
                           inView:self.view
                         vertical:0.5];
            return false;
        }
    }
    return true;
}
-(void)Submit_Account :(NSString *)account Secret:(NSString *)secret
{
    
    [NavView Portal_Exist];
    if([Function judgeFileExist:login Kind:Library_Cache])
    {
        NSDictionary* dic11 =[Function ReadFromFile:login Kind:Library_Cache];
        if(![[dic11 objectForKey:@"account"] isEqualToString:textField_Account.text])
        {//如果换账号了 要使用主服务器基地址 但是同一个账号第二次登录就用分支URL
            app.isPortal=NO;
            //Dlog(@"换号了");
        }
        else
        {
            //Dlog(@"没换号");
        }
    }
    if([Function isConnectionAvailable])
    {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.mode = MBProgressHUDModeIndeterminate;
        hud.labelText = @"加载中...";
        
        btn_Login.userInteractionEnabled=NO;
        if(Again_request && comHostFlg == 1)
        {
            //主服务器失败请求备用服务器
            urlString=[NSString stringWithFormat:@"%@%@",app.secondServer,KCHK_LOGIN];
            comHostFlg = 0;
            app.serverString = @"3";
            
        }else if(Again_request)
        {
            //分支出错请求主服务器
            urlString=[NSString stringWithFormat:@"%@%@",kBASEURL,KCHK_LOGIN];
            comHostFlg = 1;
            Again_request = NO;
            app.serverString = @"1";
        }
        else if(app.isPortal)
        {
            //第二次进来请求分支服务器
            urlString=[NSString stringWithFormat:@"%@%@",KPORTAL_URL,KCHK_LOGIN];
            comHostFlg = 0;
            app.serverString = @"2";
        }
        else
        {
            //第一次进来请求主服务器
            urlString=[NSString stringWithFormat:@"%@%@",kBASEURL,KCHK_LOGIN];
            comHostFlg = 1;
            app.serverString = @"1";
        }

        NSURL *url = [ NSURL URLWithString :  urlString];
        
        ASIFormDataRequest *request = [ ASIFormDataRequest requestWithURL :url];
        request.delegate = self;
        request.tag = 100;
        
        [request setRequestMethod:@"POST"];
        [request setPostValue:textField_Account.text forKey:KUSER_UID];
        [request setPostValue:textField_Secret.text forKey:KUSER_PASSWORD];
        [request setPostValue:[[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"token"] forKey:@"user.token"];
        [request setPostValue:[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"] forKey:@"version"];

        [request startAsynchronous ];//异步
    }
    else
    {
        [SGInfoAlert showInfo1:@"请检查网络"
                      bgColor:[[UIColor darkGrayColor] CGColor]
                       inView:self.view
                     vertical:0.5];
    }
}

-(void)get_JsonString:(NSString *)jsonString
{
    SBJsonParser *pause = [[SBJsonParser alloc] init];
    __block NSDictionary *dict =[pause objectWithString: jsonString];
    
    app.GiftFlagStr = [dict objectForKey:@"GiftFlag"];
    app.NCPString = [dict objectForKey:@"NoChangePrice"];
    [self setDic:[dict objectForKey:ProductBrandList] forKey:ProductBrandList];
    [self setDic:[dict objectForKey:ProductTypeList]  forKey:ProductTypeList];
    [self setDic:[dict objectForKey:ProductPooList]   forKey:ProductPooList];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:[dict objectForKey:APPBGIG] forKey:APPBGIG];
    [userDefaults synchronize];
    if([[dict objectForKey:@"ret"] isEqualToString:@"0"])
    {
        [self Get_LastVersion];//检测新版本
        NSDictionary* _dic =[Function ReadFromFile:login Kind:Library_Cache];
        if(![[_dic objectForKey:@"account"] isEqualToString:textField_Account.text])
        {//如果换账号了 清除缓存定位数据
            [Function DeleteTheFile:[NSString stringWithFormat:@"%@/%@",MyFolder,Location_List] Kind:Library_Cache];
            [Function DeleteTheFile:[NSString stringWithFormat:@"%@/%@",MyFolder,Quick_List]  Kind:Library_Cache];
            
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults setObject:[dict objectForKey:@"TileTitle"] forKey:@"TileTitle"];
            [defaults setInteger:0 forKey:NUMBER];
            [defaults setInteger:0 forKey:NUM_ASG];
            [defaults setInteger:0 forKey:NUM_MES];
            [defaults setObject:@"0" forKey:FIRST];
            [defaults synchronize];
        }
        __block NSDictionary *dic=[dict objectForKey:@"SelfInfo"];
        [[SelfInf_Singleton sharedInstance].dic_SelfInform setObject:[dict objectForKey:@"Advert"] forKey:ADVERT];
        
        [[SelfInf_Singleton sharedInstance].dic_SelfInform setObject:textField_Account.text forKey:@"account"];
        [[SelfInf_Singleton sharedInstance].dic_SelfInform setObject:textField_Secret.text forKey:@"secret"];
        [[SelfInf_Singleton sharedInstance].dic_SelfInform setObject:[dic objectForKey:@"password"] forKey:@"secret"];
        if(![Function isBlankString:[dic objectForKey:@"token"]])
        {
            [[SelfInf_Singleton sharedInstance].dic_SelfInform setObject:[dic objectForKey:@"token"] forKey:@"token"];
        }
        [[SelfInf_Singleton sharedInstance].dic_SelfInform setObject:[dic objectForKey:@"coname"] forKey:@"coname"];
        [[SelfInf_Singleton sharedInstance].dic_SelfInform setObject:[dic objectForKey:@"uname"] forKey:@"uname"];
        [[SelfInf_Singleton sharedInstance].dic_SelfInform setObject:[dic objectForKey:@"index_no"] forKey:@"index_no"];
        [[SelfInf_Singleton sharedInstance].dic_SelfInform setObject:textField_Account.text forKey:@"user.uid"];
        [[SelfInf_Singleton sharedInstance].dic_SelfInform setObject:[dic objectForKey:@"auth"] forKey:@"auth"];
        [[SelfInf_Singleton sharedInstance].dic_SelfInform setObject:[dic objectForKey:@"umtel"] forKey:@"umtel"];
        [[SelfInf_Singleton sharedInstance].dic_SelfInform setObject:[dic objectForKey:@"db_ip"] forKey:@"db_ip"];
        [[SelfInf_Singleton sharedInstance].dic_SelfInform setObject:[dic objectForKey:@"db_name"] forKey:@"db_name"];
        [[SelfInf_Singleton sharedInstance].dic_SelfInform setObject:[dic objectForKey:@"belongto"] forKey:@"belongto"];
        
        NSString *gpsFlag = [dict objectForKey:GPSFLAG];//server's start gps flag
        NSString *timeInterval = [dict objectForKey:GPSTIMER];// server's monitor interval time
        
        if ([gpsFlag isEqualToString:@"1"]) {// start music gps monitor
            NSLog(@"started the no-limit gps monitor.");
            app.gpsFlag2 = 1;// music no-limit gps monitor flag(0:stop 1:run)
            if (app.gps_threadFlag != 1) {
                NSLog(@"open 1 gps monitor thread.");
                [app backgroundHandlerWithFlag:[gpsFlag integerValue] timerInterval:[timeInterval doubleValue]];
                app.gps_threadFlag = 1;
            }
        }else {
            NSLog(@"close 1 gps monitor thread.");
            NSLog(@"stop the current gps monitor loop op.");
            app.gpsFlag2 = 0;// music no-limit gps monitor flag(0:stop 1:run)
            app.gps_threadFlag = 0;
        }
        
        if(![Function isBlankString:[dic objectForKey:@"portal_url"]])
        {
            [[SelfInf_Singleton sharedInstance].dic_SelfInform setObject:[dic objectForKey:@"portal_url"] forKey:@"portal_url"];
            app.isPortal=YES;//所有除登录页面的网络交互只需要 app.isPortal=YES状态下的分支url 除个别的url外
        }
        else
        {
            app.isPortal=NO;
        }
        ////////
        //gps  主动定位的时间次数 和提交时间间隔
        [[SelfInf_Singleton sharedInstance].dic_SelfInform setObject:[dict objectForKey:@"GprsTimer"] forKey:@"GprsTimer"];
        [[SelfInf_Singleton sharedInstance].dic_SelfInform setObject:[dict objectForKey:@"GprsPostTimer"] forKey:@"GprsPostTimer"];
       
        //如果开机图文件不存在 或者 本地远程图片url为空 或者 url 有变化
        if(![Function judgeFileExist:CompanyLogo Kind:Library_Cache]||[Function isBlankString:[[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"CompanyLogo"]]||![[[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"CompanyLogo"]isEqualToString:[dict objectForKey:@"CompanyLogo"]])
        {
            //开始下载
            [SDWebImageDownloader downloaderWithURL:[NSURL URLWithString:[dict objectForKey:@"CompanyLogo"]] delegate:self userInfo:@"CLogo"];
        }
        [[SelfInf_Singleton sharedInstance].dic_SelfInform setObject:[dict objectForKey:@"CompanyLogo"] forKey:@"CompanyLogo"];
        [[SelfInf_Singleton sharedInstance].dic_SelfInform setObject:[dict objectForKey:@"GpsDistance"] forKey:@"GpsDistance"];
        [[SelfInf_Singleton sharedInstance].dic_SelfInform setObject:[dict objectForKey:@"NoticeTimer"] forKey:@"NoticeTimer"];
        
         [TileAuthority  sharedInstance].dic_TileAuthority=[dict objectForKey:@"TileAuthority"];
        /****简单权限设置新加*****/
        //休假
        [[SelfInf_Singleton sharedInstance].dic_SelfInform setObject:@"-1" forKey:@"holiday"];
        
        if([[dic objectForKey:@"auth"] isEqualToString:@"4"])
        {//如果是boss  没有gbelong  设置gebelong为-1
            [[SelfInf_Singleton sharedInstance].dic_SelfInform setObject:@"-1" forKey:@"gbelongto"];
        }
        else
        {
            [[SelfInf_Singleton sharedInstance].dic_SelfInform setObject:[dic objectForKey:@"gbelongto"] forKey:@"gbelongto"];
            if([[dic objectForKey:@"auth"] isEqualToString:@"2"])
            {
                if(![Function isBlankString:[dic objectForKey:@"holiday"]])
                [[SelfInf_Singleton sharedInstance].dic_SelfInform setObject:[dic objectForKey:@"holiday"] forKey:@"holiday"];
            }
        }
        if([Function isBlankString:[dic objectForKey:@"qrcode_only"]])
        {
            [[SelfInf_Singleton sharedInstance].dic_SelfInform setObject:@"-1" forKey:@"qrcode_only"];
        }
        else
        {
            [[SelfInf_Singleton sharedInstance].dic_SelfInform setObject:[dic objectForKey:@"qrcode_only"] forKey:@"qrcode_only"];
        }
        
        if(![Function isBlankString:[dic objectForKey:@"token"]])
        {
            [self Back_Token];//回执令牌
        }
        /*设置推送*/
        [app Set_All_Tag:dic];//tel  belongto  gbelongto
        /*设置推送*/
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self Back_ClientID:KSave_client_id Key:app.clientId Ptype:@"IGTPUSH"];
            [self Back_ClientID:KSave_client_id Key:[NSString stringWithFormat:@"%@,%@",app.baidu_userId,app.baidu_channelId] Ptype:@"BAIDUPUSH"];
            if(![[[dict objectForKey:@"SelfInfo"] objectForKey:@"mst_timestamp"] isEqualToString:[[SelfInf_Singleton sharedInstance].dic_SelfInform  objectForKey:@"mst_timestamp"]])
            {//如果此次和上次的时间戳不相等（包括原本就没有时间戳）  更新表数据 相等 则不更新
                NSArray *keyArrays = [dict allKeys];
                NSArray *valueArrays = [dict allValues];
                for (int i = 0; i < keyArrays.count; i ++) {
                    [[BasicData sharedInstance].dic_BasicData setObject:[valueArrays objectAtIndex:i] forKey:[keyArrays objectAtIndex:i]];
                }
                
                [Function DeleteTheFile:[NSString stringWithFormat:@"%@/%@",MyFolder,BasicDataType] Kind:Library_Cache];
                [Function creatTheFile:BasicDataType Kind:Library_Cache];
                [Function WriteToFile:BasicDataType File:dict Kind:Library_Cache];
                [[SelfInf_Singleton sharedInstance].dic_SelfInform setObject:[dic objectForKey:@"mst_timestamp"] forKey:@"mst_timestamp"];
                
                NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                [defaults setObject:[dict objectForKey:@"TileTitle"] forKey:@"TileTitle"];
                [defaults synchronize];
            }
            dic=nil;
            dict=nil;
            //时间戳end
            /*
             判断账号密码是否存在 存在 则更新
             不存在 创建文件 写入文件
             */
            [Function DeleteTheFile:[NSString stringWithFormat:@"%@/%@",MyFolder,login] Kind:Library_Cache];
            [Function creatTheFile:login Kind:Library_Cache];
            [Function WriteToFile:login File:[SelfInf_Singleton sharedInstance].dic_SelfInform Kind:Library_Cache];
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [self creat_TabarView];
                btn_Login.userInteractionEnabled=YES;
            });
    
            
        });
        /*
         根据Json结果
         if（当前账号是管理者级别）//以前的
         {
         进入ManagerViewController页面，同时，请求服务器发短信验证码 同时我得到这个key----->Captcha,
         当校验结束，进入主页面对应显示当前层级的各种功能
         }
         else
         {
         直接进入主页面，对应显示当前层级的各种功能
         }
         */
        
    }
    else
    {
        [SGInfoAlert showInfo1:[dict objectForKey:@"message"]
                      bgColor:[[UIColor darkGrayColor] CGColor]
                       inView:self.view
                     vertical:0.5];
        btn_Login.userInteractionEnabled=YES;
        dict=nil;
    }
    [self requestWithCustommer:0];
    [self requestWithCustommer:1];
    [self get_OrderDynamic];
    [self get_ROrderDynamic];
}

- (void)setDic:(id)dic forKey:(NSString *)key {
    NSDictionary *tempDic = dic;
    if (tempDic.count) {
        [[SelfInf_Singleton sharedInstance].dic_SelfInform setObject:tempDic forKey:key];
    }
}

- (void)requestWithCustommer:(NSInteger)isCustomer {
 
    if(app.isPortal)
    {
        if (isCustomer) {
            urlString=[self Setting_URL_Get_dynamic:KPORTAL_URL isNewCustomer:0];
        }else {
            urlString=[self Setting_URL_Get_dynamic:KPORTAL_URL isNewCustomer:1];
        }
    }
    else
    {
        if (isCustomer) {
            urlString=[self Setting_URL_Get_dynamic:kBASEURL isNewCustomer:0];
        }else {
            urlString=[self Setting_URL_Get_dynamic:kBASEURL isNewCustomer:1];
        }
    }

    NSURL *url = [ NSURL URLWithString : urlString];
    ASIFormDataRequest *request = [ ASIFormDataRequest requestWithURL :url];
    request.delegate = self;
    if (isCustomer) {
        request.tag = 102;
    }else {
        request.tag = 103;
    }
    
    [request setRequestMethod:@"POST"];
    [request setPostValue:[[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"account"]forKey:KUSER_UID];
    [request setPostValue:[[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"secret"] forKey:KUSER_PASSWORD];
    [request setPostValue:[[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"token"] forKey:@"user.token"];
    [request setPostValue:[[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"db_ip"] forKey:@"db_ip"];
    [request setPostValue:[[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"db_name"] forKey:@"db_name"];
    [request startAsynchronous ];//异步
}

-(NSString*)Setting_URL_Get_dynamic:(NSString *)basic_url isNewCustomer:(NSInteger)isNewCustomer
{
    NSString *str = nil;
    if(!isNewCustomer)
    {
        str=[NSString stringWithFormat:@"%@%@",basic_url,KNewCustomer_Dynamic0];
    }
    else
    {
        str=[NSString stringWithFormat:@"%@%@",basic_url,KNewCustomer_Dynamic1];
    }
    return str;
}

-(void)RegisterAnDlogin_Function:(id)sender
{
    UIButton *btn=(UIButton *)sender;
    if(btn.tag==buttonTag)
    {
        if([self verify])//账号密码符合规格
        {
            [self Submit_Account:textField_Account.text Secret:textField_Account.text];
        }
    }
}
//上次是否登录过
-(void)isLoad_past
{
    if([Function judgeFileExist:login Kind:Library_Cache])
    {
        NSDictionary* dic =[Function ReadFromFile:login Kind:Library_Cache];
        textField_Account.text=[dic objectForKey:@"account"];
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        BOOL select = [defaults boolForKey:@"isSelectCode"];
        if (select) {
            textField_Secret.text =[dic objectForKey:@"secret"];
        }
        
        [[SelfInf_Singleton sharedInstance].dic_SelfInform addEntriesFromDictionary:dic];
    }
    if([Function judgeFileExist:BasicDataType Kind:Library_Cache])
    {
        NSDictionary *dict=[Function ReadFromFile:BasicDataType Kind:Library_Cache];
        
        NSArray *keyArrays = [dict allKeys];
        NSArray *valueArrays = [dict allValues];
        for (int i = 0; i < keyArrays.count; i ++) {
            [[BasicData sharedInstance].dic_BasicData setObject:[valueArrays objectAtIndex:i] forKey:[keyArrays objectAtIndex:i]];
        }
    }
}
-(void)creat_TabarView
{
    NewTabbarViewController *newTabVC = [NewTabbarViewController new];
    
    MMDrawerController * drawerController = [[MMDrawerController alloc]
                                             initWithCenterViewController:newTabVC
                                             leftDrawerViewController:[LeftViewController new]
                                             rightDrawerViewController:nil];
    [drawerController setMaximumLeftDrawerWidth:240.0];
    [drawerController setOpenDrawerGestureModeMask:MMOpenDrawerGestureModeAll];
    [drawerController setCloseDrawerGestureModeMask:MMCloseDrawerGestureModeAll];
    
    [self.navigationController pushViewController:drawerController animated:YES];
}

#pragma mark - UITextView Delegate Methods
- (void)textFieldDidBeginEditing:(UITextField *)textField{
    //开始编辑时触发，文本字段将成为first responder
    [textField becomeFirstResponder];
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    //主要是[receiver resignFirstResponder]在哪调用就能把receiver对应的键盘往下收
    if(textField==textField_Account)
    {
        [textField_Secret becomeFirstResponder];
    }
    [textField resignFirstResponder];
    return YES;
}
- (void)textFieldDidEndEditing:(UITextField *)textField
{
    
}
-(BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController*)viewController
{
    return YES;
}
//回执token
-(void)Back_Token
{
    if([Function isConnectionAvailable])
    {
        NSString *string;
        
        if(app.isPortal)
        {
            string=[NSString stringWithFormat:@"%@%@",KPORTAL_URL,KReceive_token];
        }
        else
        {
            string=[NSString stringWithFormat:@"%@%@",kBASEURL,KReceive_token];
        }
        NSURL *url = [ NSURL URLWithString :  string ];
        ASIFormDataRequest *request = [ ASIFormDataRequest requestWithURL :url];
        request.delegate = self;
        
        [request setRequestMethod:@"POST"];
        [request setPostValue:[[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"account"]forKey:KUSER_UID];
        [request setPostValue:[[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"secret"] forKey:KUSER_PASSWORD];
        [request setPostValue:[[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"token"] forKey:@"user.token"];
        [request setPostValue:[[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"db_ip"] forKey:@"db_ip"];
        [request setPostValue:[[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"db_name"] forKey:@"db_name"];

        [request startAsynchronous ];//异步
    }
}
-(void)Back_ClientID:(NSString *)url_suffixed Key:(NSString *)clientId Ptype:(NSString*)ptype
{
    if([Function isConnectionAvailable])
    {
        NSString *string;
        if(app.isPortal)
        {
            string=[NSString stringWithFormat:@"%@%@",KPORTAL_URL,KSave_client_id];
        }
        else
        {
            string=[NSString stringWithFormat:@"%@%@",kBASEURL,KSave_client_id];
        }
        NSURL *url = [ NSURL URLWithString :  string ];
        ASIFormDataRequest *request = [ ASIFormDataRequest requestWithURL :url];
        request.delegate = self;
        [request setRequestMethod:@"POST"];
        [request setPostValue:[[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"account"]forKey:KUSER_UID];
        [request setPostValue:[[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"secret"] forKey:KUSER_PASSWORD];
        [request setPostValue:[[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"token"] forKey:@"user.token"];
        [request setPostValue:[[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"db_ip"] forKey:@"db_ip"];
        [request setPostValue:[[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"db_name"] forKey:@"db_name"];
        [request setPostValue:clientId forKey:@"client_id"];
        [request setPostValue:ptype forKey:@"ptype"];
        [request startAsynchronous ];//异步
    }
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)Action_FindBack:(id)sender
{
    ForgetSecretViewController *forgetVC=[[ForgetSecretViewController alloc]init];
    [self presentViewController:forgetVC animated:YES completion:nil];
}

- (IBAction)To_term:(id)sender
{
    DocumentViewController *docVC=[[DocumentViewController alloc]init];
    docVC.string_Title=@"用户协议";
    docVC.str_Url=[NSString stringWithFormat:@"%@%@",kBASEURL,KTerm];
    docVC.str_isGraph=@"100";
    docVC.str_only_Online=@"1";
    [self presentViewController:docVC animated:YES completion:nil];
}

- (IBAction)select:(UIButton *)sender
{
    if(isSelect)
    {
        isSelect=NO;
        [sender setImage:[UIImage imageNamed:@"icon_disagree.png"] forState:UIControlStateNormal];
    }
    else
    {
        isSelect=YES;
        [sender setImage:[UIImage imageNamed:@"icon_agree.png"] forState:UIControlStateNormal];
    }
}
// 接收结果
- (void)imageDownloader:(SDWebImageDownloader *)downloader
     didFinishWithImage:(UIImage *)image
{
    NSData *imageData = UIImageJPEGRepresentation(image , 1.0);
    [Function DeleteTheFile:[NSString stringWithFormat:@"%@/%@",MyFolder,CompanyLogo] Kind:Library_Cache];
    [Function creatTheFile:CompanyLogo Kind:Library_Cache];
    [Function WriteToFile:CompanyLogo File:imageData Kind:Library_Cache];
}
#pragma Version
-(void)Get_LastVersion
{
    if([Function isConnectionAvailable])
    {//判断版本 主服务器基地址
        NSString *string=[NSString stringWithFormat:@"%@",GetLastVersion];
        NSURL *url = [ NSURL URLWithString:string];
        ASIFormDataRequest *request = [ ASIFormDataRequest requestWithURL :url];
        request.delegate = self;
        request.tag = 101;
        [request setRequestMethod:@"POST"];
        [request startAsynchronous ];
    }
}

//请求备份服务器
-(void)getSecondServer {
    if([Function isConnectionAvailable])
    {
        NSString *string=[NSString stringWithFormat:@"%@",SecondServer];
        NSURL *url = [ NSURL URLWithString :  string ];
        ASIFormDataRequest *request = [ ASIFormDataRequest requestWithURL :url];
        request.delegate = self;
        request.tag = 110;
        [request setRequestMethod:@"get"];
        [request startAsynchronous ];
    }
}
-(void)Get_data:(NSData *)responseData
{
    NSString *result=[[NSString alloc]initWithData:responseData encoding:NSUTF8StringEncoding];
    NSArray *arr=[result componentsSeparatedByString:@","];
    str_url_version=[arr objectAtIndex:2];
    NSString *versionHttp  = [[arr objectAtIndex:1] substringFromIndex:4];
    NSString *versionLocal = [[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]substringFromIndex:4];
    
    if(versionLocal.integerValue < versionHttp.integerValue)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"软件版本检测" message:[arr objectAtIndex:3]delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"更新",nil];
        [alert show];
        alert.tag=10;
        alert=nil;
    }
}
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(alertView.tag==10)
    {
        if(buttonIndex==1)
        {
            [[UIApplication sharedApplication ] openURL:[NSURL URLWithString:str_url_version]];
        }
    }
}
- (IBAction)remCodeAction:(id)sender {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL select = [defaults boolForKey:@"isSelectCode"];
    if(select)
    {
        select=NO;
        [self.codeBtn setImage:[UIImage imageNamed:@"icon_disagree.png"] forState:UIControlStateNormal];
        [self.codeNewBtn setImage:[UIImage imageNamed:@"icon_disagree.png"] forState:UIControlStateNormal];
    }
    else
    {
        select=YES;
        [self.codeBtn setImage:[UIImage imageNamed:@"icon_agree.png"] forState:UIControlStateNormal];
        [self.codeNewBtn setImage:[UIImage imageNamed:@"icon_agree.png"] forState:UIControlStateNormal];
    }
    [defaults setBool:select forKey:@"isSelectCode"];
    [defaults synchronize];
}

-(void)requestFinished:(ASIHTTPRequest *)request {
    if (request.tag == 100) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        if([request responseStatusCode]==200)
        {
            Again_request=NO;
            NSString * jsonString  =  [request responseString];
            [self get_JsonString:jsonString];
        }
        else
        {
            [SGInfoAlert showInfo1:@"登录异常"
                          bgColor:[[UIColor darkGrayColor] CGColor]
                           inView:self.view
                         vertical:0.5];
            [NdUncaughtExceptionHandler Post_url:[NSString stringWithFormat:@"URL:%@,%d",urlString,[request responseStatusCode]]];
        }
    }
    if (request.tag == 101) {
        [self Get_data:[request responseData]];
    }
    if (request.tag == 102) {
        NSString * jsonString1  =  [request responseString];
        [self GetJson_DynamicList:jsonString1 withTag:request.tag];
    }
    if (request.tag == 103) {
        NSString * jsonString1  =  [request responseString];
        [self GetJson_DynamicList:jsonString1 withTag:request.tag];
    }
    if (request.tag == 110) {
        app.secondServer=[[NSString alloc]initWithData:[request responseData] encoding:NSUTF8StringEncoding];
    }
    if (request.tag == 105) {
        if([request responseStatusCode]==200)
        {
            SBJsonParser *parser = [[SBJsonParser alloc] init];
            NSDictionary *dict =[parser objectWithString:[request responseString]];
            if([[dict objectForKey:@"DynamicCount"] isEqualToString:@"0"]&&[[dict objectForKey:@"MediaCount"] isEqualToString:@"0"]){
            }
            else
            {
                app.dic_json=dict;
            }
        }
        else
        {
            [SGInfoAlert showInfo1:@"发生异常"
                          bgColor:[[UIColor darkGrayColor] CGColor]
                           inView:self.view
                         vertical:0.5];
            [NdUncaughtExceptionHandler Post_url:[NSString stringWithFormat:@"URL:%@,HTTP_Code%d",urlString,[request responseStatusCode]]];
        }
    }
    if (request.tag == 106) {
        if([request responseStatusCode]==200)
        {
            SBJsonParser *parser = [[SBJsonParser alloc] init];
            NSDictionary *dict =[parser objectWithString:[request responseString]];
            if([[dict objectForKey:@"DynamicCount"] isEqualToString:@"0"]&&[[dict objectForKey:@"MediaCount"] isEqualToString:@"0"]){
            }
            else
            {
                app.dic_json1=dict;
            }
        }
        else
        {
            [SGInfoAlert showInfo1:@"发生异常"
                          bgColor:[[UIColor darkGrayColor] CGColor]
                           inView:self.view
                         vertical:0.5];
            [NdUncaughtExceptionHandler Post_url:[NSString stringWithFormat:@"URL:%@,HTTP_Code%d",urlString,[request responseStatusCode]]];
        }
    }
}

-(void)requestFailed:(ASIHTTPRequest *)request {
    if (request.tag == 100) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [SGInfoAlert showInfo1:@"服务器无响应"
                      bgColor:[[UIColor darkGrayColor] CGColor]
                       inView:self.view
                     vertical:0.5];
        btn_Login.userInteractionEnabled=YES;
        if(!Again_request&& request.responseStatusCode!= 200)
        {
            Again_request=YES;
            [self Submit_Account:textField_Account.text Secret:textField_Account.text];
        }
        else
        {
            Again_request=NO;
        }
    }
}

-(void)GetJson_DynamicList:(NSString *)jsonString withTag:(NSInteger)requestTag
{
    SBJsonParser *parser = [[SBJsonParser alloc] init];
    NSDictionary *dict =[parser objectWithString: jsonString];
    if (requestTag == 102) {
        //新客户本地缓存
        NSString *str1= [Function achieveThe_filepath:Customer_List Kind:Library_Cache];
        [Function Delete_TotalFileFromPath:str1];
        [Function creatTheFile:Customer_List Kind:Library_Cache];
        [Function WriteToFile:Customer_List File:dict Kind:Library_Cache];
    }else {
        //竞争对手本地缓存
        NSString *str1= [Function achieveThe_filepath:Opponent_List Kind:Library_Cache];
        [Function Delete_TotalFileFromPath:str1];
        [Function creatTheFile:Opponent_List Kind:Library_Cache];
        [Function WriteToFile:Opponent_List File:dict Kind:Library_Cache];
    }
}

- (IBAction)serverAcction:(id)sender {
    ServerViewController *serverVC = [ServerViewController new];
    serverVC.baseServerStr = kBASEURL;
    serverVC.portServerStr = KPORTAL_URL;
    serverVC.secondServerStr = app.secondServer;
    serverVC.redStr = app.serverString;
    [self.navigationController pushViewController:serverVC animated:YES];
}

//获取登陆的终端动态信息(保存本地)
-(void)get_OrderDynamic
{
    if(app.isPortal)
    {
        urlString =[NSString stringWithFormat:@"%@%@",KPORTAL_URL,KGetOrder_Dynamic];
    }
    else
    {
        urlString =[NSString stringWithFormat:@"%@%@",kBASEURL,KGetOrder_Dynamic];
    }
    NSURL *url = [ NSURL URLWithString :  urlString];
    ASIFormDataRequest *request = [ ASIFormDataRequest requestWithURL :url];
    request.delegate = self;
    request.tag = 105;
    [request setRequestMethod:@"POST"];
    [request setPostValue:[[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"account"]forKey:KUSER_UID];
    [request setPostValue:[[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"secret"] forKey:KUSER_PASSWORD];
    [request setPostValue:[[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"token"] forKey:@"user.token"];
    [request setPostValue:[[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"db_ip"] forKey:@"db_ip"];
    [request setPostValue:[[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"db_name"] forKey:@"db_name"];
    [request startAsynchronous ];//异步
}

//获取登陆的终端动态信息(保存本地)
-(void)get_ROrderDynamic
{
    if(app.isPortal)
    {
        urlString =[NSString stringWithFormat:@"%@%@",KPORTAL_URL,KGetROrder_Dynamic];
    }
    else
    {
        urlString =[NSString stringWithFormat:@"%@%@",kBASEURL,KGetROrder_Dynamic];
    }
    NSURL *url = [ NSURL URLWithString :  urlString];
    ASIFormDataRequest *request = [ ASIFormDataRequest requestWithURL :url];
    request.delegate = self;
    request.tag = 106;
    [request setRequestMethod:@"POST"];
    [request setPostValue:[[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"account"]forKey:KUSER_UID];
    [request setPostValue:[[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"secret"] forKey:KUSER_PASSWORD];
    [request setPostValue:[[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"token"] forKey:@"user.token"];
    [request setPostValue:[[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"db_ip"] forKey:@"db_ip"];
    [request setPostValue:[[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"db_name"] forKey:@"db_name"];
    [request startAsynchronous ];//异步
}
@end
