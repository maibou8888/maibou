//
//  DocumentViewController.m
//  WZYB_syb
//
//  Created by wzyb on 14-6-9.
//  Copyright (c) 2014年 WZYB. All rights reserved.
//

#import "DocumentViewController.h"
#import "Function.h"
#import "AppDelegate.h"
#import "KxMenu.h"
#import "ShareViewController.h"
@interface DocumentViewController ()<MBProgressHUDDelegate>
{
    AppDelegate *app;
    MBProgressHUD *hud;
    long long expectedLength;
    long long currentLength;
}
@end

@implementation DocumentViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.view.backgroundColor = [UIColor whiteColor];
    }
    return self;
}
-(void)All_Init
{
    
    app=(AppDelegate *)[[UIApplication sharedApplication]delegate];
    app.isLeft=NO;
    scaleFlag = NO;
    enablePan = NO;
    currentScale = 0;
    if(StatusBar_System>0)
        moment_status=20;
    else moment_status=0;
    nav_View1=[[NavView alloc]init];
    nav_View2=[[NavView alloc]init];
    nav_View3=[[NavView alloc]init];
    webView=[[UIWebView alloc]initWithFrame:CGRectMake(0, 44, Phone_Weight, Phone_Height-44)];
    [self.view addSubview:webView];
    [self.view addSubview: [nav_View1 NavView_Title1:self.titleString]];
    //左边返回键
    btn=[UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame=CGRectMake(0, moment_status, 60, 44);
    btn.backgroundColor=[UIColor clearColor];
    btn.tag=buttonTag-1;
    [btn addTarget:self action:@selector(btn_Action:) forControlEvents:UIControlEventTouchUpInside];
    [nav_View1.view_Nav  addSubview:btn];
    [btn setBackgroundImage:[UIImage imageNamed:@"btn_color6.png"] forState:UIControlStateHighlighted];
    [btn setTitle:@"< 返回" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    btn.titleLabel.font=[UIFont systemFontOfSize:15];
    
    if (!self.webViewHeight) {
        //右边横竖屏键
        btn1=[UIButton buttonWithType:UIButtonTypeCustom];
        btn1.frame=CGRectMake(Phone_Weight-44, moment_status, 44, 44);
        btn1.backgroundColor=[UIColor clearColor];
        btn1.tag=buttonTag;
        [btn1 addTarget:self action:@selector(btn_Action:) forControlEvents:UIControlEventTouchUpInside];
        [btn1 setBackgroundImage:[UIImage imageNamed:@"btn_color6.png"] forState:UIControlStateHighlighted];
        if (self.mutiSelect) {
            [btn1 setTitle:@"●●●" forState:UIControlStateNormal];
        }else {
            [btn1 setTitle:@"横屏" forState:UIControlStateNormal];
        }
        [btn1 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        btn1.titleLabel.font=[UIFont systemFontOfSize:15];
        [nav_View1.view_Nav  addSubview:btn1];
        btn1.hidden=YES;
    }
    
    //初始化webView
    if(![Function isBlankString:self.str_Url])
    {
        if(self.isCache)
        {//下载后观看
            [self Down_File];
            isLoading=YES;
        }
        else
        {
            if([self isEXist]&&![self.str_isGraph isEqualToString:@"1"]&&![self.str_only_Online isEqualToString:@"1"]) {
                //Dlog(@"本地存在该文本.");
                NSString*path=[Function achieveThe_filepath:[NSString stringWithFormat:@"%@/%@",Office_Products,self.str_Index] Kind:Library_Cache];
                NSURL *url = [NSURL fileURLWithPath:path];
                NSURLRequest *request = [NSURLRequest requestWithURL:url];
                [webView loadRequest:request];
            }
            else
            {
                //Dlog(@"是在线阅读.");
                [self loadDocument:self.str_Url inView:webView];
            }
        }
        webView.scalesPageToFit=YES;//点击伸缩效果的
        webView.delegate=self;
        
        if(self.isCache)
        {
            
        }
        else
        {
            hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            hud.mode = MBProgressHUDModeIndeterminate;
            hud.labelText = @"加载中...";//加载提示语言
        }
        
        
    }
    else
    {
        [SGInfoAlert showInfo:@"查无此路径文件"
                      bgColor:[[UIColor darkGrayColor] CGColor]
                       inView:self.view
                     vertical:0.5];
    }
}

-(void)Down_File
{
    //文件地址
    NSString *urlAsString = self.str_Url;
    NSURL    *url = [NSURL URLWithString:urlAsString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    NSMutableData *data = [[NSMutableData alloc] init];
    self.connectionData = data;
    data=nil;
    NSURLConnection *newConnection = [[NSURLConnection alloc]
                                      
                                      initWithRequest:request
                                      
                                      delegate:self
                                      
                                      startImmediately:YES];
    if (newConnection != nil){
        
        //Dlog(@"Successfully created the connection");
        
    } else {
        
        //Dlog(@"Could not create the connection");
        
    }
    newConnection=nil;
    hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    hud.delegate = self;
    hud.labelText = @"下载中...";
}
- (void)viewDidLoad
{
    [super viewDidLoad];
}
-(void)viewWillAppear:(BOOL)animated
{
    [self All_Init];
    if([self.str_isGraph isEqualToString:@"1"])
    {
        btn1.hidden=NO;
        app.isLeft=NO;
    }
}

-(void)loadDocument:(NSString*)documentName inView:(UIWebView*)webView1
{
    NSURL *url=[NSURL URLWithString:documentName];
    NSURLRequest *request =[NSURLRequest requestWithURL:url];
    [webView1 loadRequest:request];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView1
{
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    webView1.backgroundColor=[UIColor whiteColor];
    [webView1 stringByEvaluatingJavaScriptFromString:@"document.body.style.zoom=0.7"];
    
    CGSize actualSize = [webView1 sizeThatFits:CGSizeZero];
    CGRect newFrame = webView1.frame;
    newFrame.size.height = actualSize.height;
    newFrame.size.width = actualSize.width;
    webView.frame = newFrame;
    webView.hidden = NO;
    if (!app.isLeft) {
        [UIView animateWithDuration:0.3 animations:^{
            webView.frame=CGRectMake(0, 44, Phone_Weight, Phone_Height-44);
            if (self.webViewHeight) {
                webView.height = Phone_Height-54;
            }
        }];
    }else {
        [UIView animateWithDuration:0.3 animations:^{
            webView.frame=CGRectMake(0, 44, Phone_Height, Phone_Weight-44);
            if (self.webViewHeight) {
                webView.height = Phone_Height-54;
            }
        }];
    }
    if (self.modalFlag) {
        webView.top = 64;
    }
}
-(void)photo
{
    UIGraphicsBeginImageContextWithOptions(webView.scrollView.contentSize, FALSE, 0);
    [[[webView.scrollView.subviews objectAtIndex:0] layer] renderInContext:UIGraphicsGetCurrentContext()];//这个subview 的名字是 UIWebBrowserView
    //得到新的image
    UIImage* image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    NSString *filepath=[Function achieveThe_filepath:@"test.png" Kind:Library_Cache];
    NSData *data1 = [NSData dataWithData:UIImagePNGRepresentation(image)];
    [data1 writeToFile:filepath atomically:YES];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    [SGInfoAlert showInfo:@"当前链接无效,去查看其他内容试试~"
                  bgColor:[[UIColor darkGrayColor] CGColor]
                   inView:self.view
                 vertical:0.5];
}
-(void)btn_Action:(id)sender
{
    UIButton *_btn=(UIButton *)sender;
    if(_btn.tag==buttonTag-1)//返回
    {
        if([self.str_isGraph isEqualToString:@"100"] || self.modalFlag)
        {
            [self dismissViewControllerAnimated:YES completion:nil];
        }
        else
        {
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
    else
    {
        if (self.mutiSelect) {
            [self _refreshButtonAction:sender];
        }else {
            [self landScape];
        }
    }
}

//下拉列表
- (void)_refreshButtonAction:(UIButton *)sender {
    NSArray *menuItems =
    @[
      [KxMenuItem menuItem:@"分享"
                     image:nil
                    target:self
                    action:@selector(pushMenuItem:)],
      
      [KxMenuItem menuItem:@"横屏"
                     image:nil
                    target:self
                    action:@selector(pushMenuItem:)]
      ];
    
    [KxMenu showMenuInView:self.view
                  fromRect:sender.frame
                 menuItems:menuItems];
}

//下拉列表action
- (void) pushMenuItem:(id)sender
{
    KxMenuItem *menu = (KxMenuItem *)sender;
    if ([menu.title isEqualToString:@"分享"]) {
        ShareViewController* shareVC = [ShareViewController new];
        shareVC.title = @"分享";
        shareVC.urlString = self.str_Url;
        [self.navigationController pushViewController:shareVC animated:YES];
    }else {
        [self landScape];
    }
}

- (void)landScape {
    for (id obj in self.view.subviews) {
        if ([obj isKindOfClass:[NavView class]] ) {
            [obj removeFromSuperview];
        }
    }
    if(app.isLeft)
    {   //竖屏
        app.isLeft=NO;
        webView.hidden = YES;
        [self loadDocument:self.str_Url inView:webView];
        [self.view addSubview:[nav_View2 NavView_Title1:self.string_Title]];
        if(isIOS7)
        {
            nav_View2.view_Nav.frame=CGRectMake(0, 0, Phone_Weight, 64);
            self.view.bounds = CGRectMake(0,0, Phone_Weight ,Phone_Height);
        }
        else
        {
            nav_View2.view_Nav.frame=CGRectMake(0, 0, Phone_Weight, 44);
            self.view.bounds = CGRectMake(0,0, Phone_Weight ,Phone_Height);
        }
        btn.frame=CGRectMake(0, moment_status, 44, 44);
        btn1.frame=CGRectMake(Phone_Weight-45, moment_status, 44, 44);
        self.view.transform = CGAffineTransformMakeRotation(-M_PI*2);
        [UIView commitAnimations];
        [nav_View2.view_Nav  addSubview:btn];
        [nav_View2.view_Nav  addSubview:btn1];
    }
    else
    {
        //横屏
        app.isLeft=YES;
        webView.hidden = YES;
        [self loadDocument:self.str_Url inView:webView];
        [self.view addSubview:[nav_View3 NavView_Title1:self.string_Title]];
        nav_View3.view_Nav.frame=CGRectMake(0, 0, Phone_Height, 44);
        if(isIOS7)
        {
            nav_View3.view_Nav.frame=CGRectMake(0, 0, Phone_Height, 64);
            btn1.frame=CGRectMake(Phone_Height-55, moment_status, 44, 44);
            self.view.bounds = CGRectMake(0, 0, Phone_Height, Phone_Weight);
        }
        else
        {
            nav_View3.view_Nav.frame=CGRectMake(0, 0, Phone_Height, 44);
            self.view.bounds = CGRectMake(0, 0, Phone_Height, Phone_Weight);
            btn1.frame=CGRectMake(Phone_Height-45-10, moment_status, 44, 44);
        }
        btn.frame=CGRectMake(10, moment_status, 44, 44);
        self.view.transform = CGAffineTransformMakeRotation(M_PI*1.5);
        [UIView commitAnimations];
        [nav_View3.view_Nav addSubview:btn];
        [nav_View3.view_Nav  addSubview:btn1];
    }
}

- (void) connection:(NSURLConnection *)connection

   didFailWithError:(NSError *)error{
    [hud hide:YES];
    //Dlog(@"An error happened");
    [SGInfoAlert showInfo:@"下载错误,请尝试其他操作"
                  bgColor:[[UIColor darkGrayColor] CGColor]
                   inView:self.view
                 vertical:0.5];
    
    //Dlog(@"%@", error);
    isLoading=NO;
}
- (void) connection:(NSURLConnection *)connection

     didReceiveData:(NSData *)data{
    
    //Dlog(@"Received data");
    isLoading=YES;
    [self.connectionData appendData:data];
    currentLength += [data length];
    hud.progress = currentLength / (float)expectedLength;
    
}
- (NSArray *)rangesOfString:(NSString *)searchString inString:(NSString *)str {
    
    NSArray *arr=[str componentsSeparatedByString:searchString];
    return arr;
}
-(void)myTask
{
    float progress = 0.0f;
    while (isLoading) {
        progress += 0.01f;
        usleep(50000);
    }
}
- (void) connectionDidFinishLoading:(NSURLConnection *)connection{

    //Dlog(@"下载成功");
    NSString *filepath=[Function CreateTheFolder_From:Library_Cache FileHolderName:Office_Products FileName:self.str_Index];
    NSFileManager* fm = [NSFileManager defaultManager];
    [fm createFileAtPath:filepath contents:nil attributes:nil];
    
    if([self.connectionData writeToFile:filepath atomically:YES])
    {
        //Dlog(@"保存成功.");
        NSURL *url = [NSURL fileURLWithPath:filepath];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        [webView loadRequest:request];
        isLoading=NO;
        hud.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"37x-Checkmark.png"]] ;
        hud.labelText=@"下载成功!";
        hud.mode = MBProgressHUDModeCustomView;
        [hud hide:YES afterDelay:2.5];
    }
    else
    {
        [hud hide:YES];
        isLoading=NO;
         //Dlog(@"保存失败.");
        [SGInfoAlert showInfo:@"下载错误,请尝试其他操作"
                      bgColor:[[UIColor darkGrayColor] CGColor]
                       inView:self.view
                     vertical:0.5];
    }
}
- (void) connection:(NSURLConnection *)connection

 didReceiveResponse:(NSURLResponse *)response{
    [self.connectionData setLength:0];
    expectedLength = MAX([response expectedContentLength], 1);
    currentLength = 0;
    hud.mode = MBProgressHUDModeDeterminate;
}
-(BOOL)isEXist
{
    NSString *filepath=[Function CreateTheFolder_From:Library_Cache FileHolderName:Office_Products FileName:self.str_Index];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    return  [fileManager fileExistsAtPath:filepath];
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    webView.delegate = nil;
    [webView stopLoading];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    webView.delegate=nil;
    webView=nil;
}

@end
