//
//  UIActionSheetViewController.m
//  WZYB_syb
//
//  Created by wzyb on 14-7-31.
//  Copyright (c) 2014年 WZYB. All rights reserved.
//

#import "UIActionSheetViewController.h"
#import "AddNewApprovalViewController.h"
#import "AppDelegate.h"
@interface UIActionSheetViewController ()
{
    AppDelegate *app;
    NSString *urlString;
    NSInteger btnTag;
}
@end

@implementation UIActionSheetViewController

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
}
-(void)viewWillAppear:(BOOL)animated
{
    [self All_Init];
    [self Calculate];
    isBack=NO;
}
-(void)viewWillDisappear:(BOOL)animated
{
   [scrollView_Back removeFromSuperview];
   [sectionName removeAllObjects];
}
-(void)All_Init
{
    app=(AppDelegate *)[[UIApplication sharedApplication]delegate];
    if(StatusBar_System>0)
        moment_status=20;
    else moment_status=0;
    sectionName=[[NSMutableArray alloc] init];
    arr_btn=[[NSMutableArray alloc]init];
    combox_height_thisView=combox_height;
    near_by_thisView=Near_By;
    
    NavView *nav_View=[[NavView alloc]init];
    [self.view addSubview: [nav_View NavView_Title1:self.str_title]];
    //左边返回键
    UIButton *btn=[UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame=CGRectMake(0, moment_status, 60, 44);
    [btn setBackgroundImage:[UIImage imageNamed:@"btn_color6.png"] forState:UIControlStateHighlighted];
    [btn setTitle:@"< 返回" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    btn.titleLabel.font=[UIFont systemFontOfSize:15];
    btn.backgroundColor=[UIColor clearColor];
    btn.tag=buttonTag-1;
    [btn addTarget:self action:@selector(btn_Action:) forControlEvents:UIControlEventTouchUpInside];
    [nav_View.view_Nav  addSubview:btn];
    
    //背景
    //背景图案
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"AddNewClerkBacground"]]];
    
    scrollView_Back=[[UIScrollView alloc]initWithFrame:CGRectMake(0, moment_status+44,Phone_Weight, Phone_Height-moment_status-44)];
    scrollView_Back.backgroundColor=[UIColor clearColor];
    [self.view addSubview:scrollView_Back];
}
-(void)Calculate
{
    NSDictionary *dic=[[BasicData sharedInstance].dic_BasicData objectForKey:@"MasterList"];
    [sectionName addObjectsFromArray:[dic objectForKey:self.str_H]];
    if([self.str_H isEqualToString:@"H8"])
    {
        NSMutableDictionary *dic=[[NSMutableDictionary alloc]initWithCapacity:2];
        [dic setObject:@"未确认" forKey:@"clabel"];
        [dic setObject:@"-1" forKey:@"cvalue"];
        [sectionName addObject:dic];
    }
    if(![Function isBlankString:self.str_tdefault])
    {
        NSArray  * array= [self.str_tdefault componentsSeparatedByString:@","];
        NSMutableArray *arr_name=[[NSMutableArray alloc]initWithCapacity:2];
        for(NSInteger i=0;i<array.count;i++)
        {
            NSMutableDictionary *dic=[[NSMutableDictionary alloc]initWithCapacity:2];
            [dic setObject:[array objectAtIndex:i] forKey:@"clabel"];
            [dic setObject:@"-1" forKey:@"cvalue"];
            [arr_name addObject:dic];
            dic=nil;
        }
        sectionName=arr_name;
        arr_name=nil;
        array=nil;
    }
    if(sectionName.count==0)//预存字段里面没有数据的话
    {
        [SGInfoAlert showInfo:@"无法获取分类,请连接网络操作"
                      bgColor:[[UIColor darkGrayColor] CGColor]
                       inView:self.view
                     vertical:0.5];
    }
    else
    {
        [self createView];
    }

    dic=nil;
}
-(void)createView
{
    momentHeight=44;
    for(NSInteger i=0;i<sectionName.count;i++)
    {
        NSDictionary *dic=[sectionName objectAtIndex:i];
        UIButton *btn=[UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame=CGRectMake(near_by_thisView, momentHeight, (scrollView_Back.frame.size.width-near_by_thisView*2), combox_height_thisView);
        btn.backgroundColor=[UIColor clearColor];
        [btn addTarget:self action:@selector(btn_Action:) forControlEvents:UIControlEventTouchUpInside];
        [scrollView_Back addSubview:btn];
        if(sectionName.count==1)
        {
             [btn setImage:[UIImage imageNamed:@"set_single@2X.png"] forState:UIControlStateNormal];

        }
        else if(sectionName.count==2)
        {
            if(i==0)
            {
                [btn setImage:[UIImage imageNamed:@"set_header@2X.png"] forState:UIControlStateNormal];
            }
            else
            {
                [btn setImage:[UIImage imageNamed:@"set_bottom@2X.png"] forState:UIControlStateNormal];
            }
        }
        else
        {
            if(i==0)
            {
                [btn setImage:[UIImage imageNamed:@"set_header@2X.png"] forState:UIControlStateNormal];
            }
            else if(i==sectionName.count-1)
            {
                [btn setImage:[UIImage imageNamed:@"set_bottom@2X.png"] forState:UIControlStateNormal];
            }
            else
            {
                [btn setImage:[UIImage imageNamed:@"set_middle@2X.png"] forState:UIControlStateNormal];
            }

        }
        btn.tag=buttonTag+ i;
        UILabel *lab=[[UILabel alloc]initWithFrame:CGRectMake(0,0, btn.frame.size.width,btn.frame.size.height)];
        lab.textAlignment=NSTextAlignmentCenter;
        lab.backgroundColor=[UIColor clearColor];
        lab.text=[dic objectForKey:@"clabel"];
        lab.font=[UIFont systemFontOfSize:app.Font];
        [btn addSubview:lab];
        if (self.editFlag) {
            btn.enabled = NO;
        }
        [arr_btn addObject:btn];
        momentHeight +=btn.frame.size.height;
        dic =nil;
        
    }
    scrollView_Back.contentSize=CGSizeMake(0, scrollView_Back.frame.size.height);
    if(momentHeight+50>=scrollView_Back.frame.size.height)
    {
        momentHeight+=100;
        scrollView_Back.contentSize=CGSizeMake(0, momentHeight);
    }
    
}
-(void)btn_Action:(id)sender
{
    UIButton *btn=(UIButton *)sender;
    if(btn.tag==buttonTag-1)//返回
    {
        app.str_temporary=@"";
        app.str_temporary_valueH=@"";
        app.isOnlyGoBack=YES;
        [self.navigationController popViewControllerAnimated:YES];
    }
    else
    {
        isBack=YES;
        NSDictionary *dic=[sectionName objectAtIndex:btn.tag-buttonTag];
        if(self.isOnlyLabel)
        {
            app.str_temporary=[dic objectForKey:@"clabel"];
        }
        else
        {
            app.str_temporary=[dic objectForKey:@"clabel"];
            app.str_temporary_valueH=[dic objectForKey:@"cvalue"];
        }
        if([self.str_H isEqualToString:@"H9"]&&!self.isSuper)//如果是审批 先申请动态审批列表
        {
            [self Get_dynamic:[dic objectForKey:@"cvalue"] Tag:btn.tag-buttonTag];
           
        }
        else
        {
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
}
-(void)Get_dynamic:(NSString *)strH Tag:(NSInteger)btn_tag
{
    btnTag = btn_tag;
    if([Function isConnectionAvailable])
    {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.mode = MBProgressHUDModeIndeterminate;
        hud.labelText = @"加载中...";//加载提示语言

        if(app.isPortal)
        {
            urlString=[NSString stringWithFormat:@"%@%@",KPORTAL_URL,KGet_dynamic];
        }
        else
        {
            urlString=[NSString stringWithFormat:@"%@%@",kBASEURL,KGet_dynamic];
        }
        NSURL *url = [ NSURL URLWithString :  urlString];
        ASIFormDataRequest *request = [ ASIFormDataRequest requestWithURL :url];
        request.delegate = self;
        [request setRequestMethod:@"POST"];
        [request setPostValue:[[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"account"]forKey:KUSER_UID];
        [request setPostValue:[[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"secret"] forKey:KUSER_PASSWORD];
        [request setPostValue:[[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"token"] forKey:@"user.token"];
        [request setPostValue:[[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"db_ip"] forKey:@"db_ip"];
        [request setPostValue:[[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"db_name"] forKey:@"db_name"];
        
        [request setPostValue: strH forKey:@"rtype"];
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
//  0  列表数据   1每行的查看详细
-(void)get_JsonString:(NSString *)jsonString Tag:(NSInteger)tag
{
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    SBJsonParser *parser = [[SBJsonParser alloc] init];
    NSDictionary *dict =[parser objectWithString: jsonString];
    if([[dict objectForKey:@"ret"]isEqualToString:@"0"])
    {
        AddNewApprovalViewController *add=[[AddNewApprovalViewController alloc]init];
        add.str_Json=jsonString;
        add.str_typeLabel=app.str_temporary;
        app.VC_AddNewApproval=add;
        [self.navigationController pushViewController:add animated:YES];
    }
    else
    {
        [SGInfoAlert showInfo:[dict objectForKey:@"message"]
                      bgColor:[[UIColor darkGrayColor] CGColor]
                       inView:self.view
                     vertical:0.5];
    }
    dict=nil;
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)requestFinished:(ASIHTTPRequest *)request {
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    
    if([request responseStatusCode]==200)
    {
        NSString * jsonString  =  [request responseString];
        [self get_JsonString:jsonString Tag:btnTag];
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
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    
    [SGInfoAlert showInfo:@"哎呀，服务器无响应，一会再试试吧"
                  bgColor:[[UIColor darkGrayColor] CGColor]
                   inView:self.view
                 vertical:0.5];
    
    // 请求响应失败，返回错误信息
    //Dlog(@"HTTP 响应码：%d",[request responseStatusCode]);
}
@end
