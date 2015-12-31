//
//  MyTaskViewController.m
//  WZYB_syb
//
//  Created by wzyb on 14-7-2.
//  Copyright (c) 2014年 WZYB. All rights reserved.
//

#import "MyTaskViewController.h"
#import "NoteViewController.h"
#import "AppDelegate.h"
#import "AssignCell.h"
#import "Function.h"
@interface MyTaskViewController ()<UITableViewDataSource,UITableViewDelegate,ASIHTTPRequestDelegate>
{
    AppDelegate *app;
    NSMutableArray *_tableArray;
    NSMutableArray *_contentArray;
}
@end

@implementation MyTaskViewController
@synthesize str_tret;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
-(void)CreateScrollView
{
    if([self.str_isMyTask isEqualToString:@"1"]&&!self.isAddNewTask)
    {//@"我的任务"
        if(isIOS7)
        {
            scroll1.frame=CGRectMake(0, 44+moment_status, Phone_Weight,Phone_Height-44-moment_status);
        }
        else
        {
            scroll1.frame=CGRectMake(0, 44+moment_status, Phone_Weight,505);
        }
        [self Row_ScrollView:scroll1 Header:[UIColor colorWithRed:223/255.0 green:52/255.0 blue:46/255.0 alpha:1.0] Title:@"任务详情" Pic:@"7" Background:@"icon_AddNewClerk_FirstTitle.png"];
        lab_status.textAlignment=NSTextAlignmentRight;
        lab_content.textAlignment=NSTextAlignmentRight;
        lab_date.textAlignment=NSTextAlignmentRight;
        lab_text.textAlignment=NSTextAlignmentRight;
        lab_thePersonFrom.textAlignment=NSTextAlignmentRight;
        scroll1.backgroundColor=[UIColor clearColor];
        lab_content.text=self.str_content;
        lab_thePersonFrom.text=self.str_uname;//发起者
        lab_text.text=self.str_tret;//备注
        lab_date.text=self.str_ins_date;
        lab_status.text=[self TheTask_Status];//状态
        [self.view addSubview:scroll1];
        
        [self Button_Describ_Scroll:scroll1 Btn:btn_accept Title:@"接受" Tag:buttonTag+0 Normal:@"btn_color2.png" Highligt:@"btn_color1.png"];
        [self Button_Describ_Scroll:scroll1 Btn:btn_reject Title:@"拒绝" Tag:buttonTag+1 Normal:@"btn_color7.png" Highligt:@"btn_color8.png"];
        [self Button_Describ_Scroll:scroll1 Btn:btn_finish Title:@"完成" Tag:buttonTag+2 Normal:@"btn_color6" Highligt:@"btn_color5"];
        [self button_status];
    }
    else if([self.str_isMyTask isEqualToString:@"0"]&&!self.isAddNewTask)
    {//任务交办
//        if(isIOS7){
//            scroll2.top = 44+moment_status;
//            scroll2.height = 550;
//        }
//        else{
//            scroll2.top = 44+moment_status;
//            scroll2.backgroundColor=[UIColor clearColor];
//            scroll2.height = 550;
//        }
//
        [self Row_ScrollView1:self.view Header:[UIColor colorWithRed:223/255.0 green:52/255.0 blue:46/255.0 alpha:1.0] Title:@"交办明细" Pic:@"7" Background:@"icon_AddNewClerk_FirstTitle.png"];
//        [self.view addSubview:scroll2];
    }
    else
    {//新任务交办
        if(isIOS7)
        {
            scroll3.frame=CGRectMake(0, 44+moment_status, Phone_Weight,Phone_Height-44-moment_status);
        }
        else
        {
            scroll3.frame=CGRectMake(0, 44+moment_status, Phone_Weight,505);
            scroll3.backgroundColor=[UIColor clearColor];
        }
        [self Row_ScrollView:scroll3 Header:[UIColor colorWithRed:223/255.0 green:52/255.0 blue:46/255.0 alpha:1.0] Title:@"任务说明" Pic:@"7" Background:@"icon_AddNewClerk_FirstTitle.png"];
        lab_content3.textAlignment=NSTextAlignmentRight;
        lab_thePersonFrom3.textAlignment=NSTextAlignmentRight;
        [self Button_Describ_Scroll:scroll3 Btn:btn_submit Title:@"提交" Tag:buttonTag*2 Normal:@"btn_color6.png" Highligt:@"btn_color1.png"];
        [self.view addSubview:scroll3];
    }
}
-(void)Button_Describ_Scroll:(UIScrollView*)scroll Btn:(UIButton *)btn Title:(NSString*)title Tag:(NSInteger)tag Normal:(NSString *)pic1 Highligt:(NSString *)pic2
{
    [btn.layer setMasksToBounds:YES];
    [btn.layer setCornerRadius:5.0];//设置矩形四个圆角半径
    [btn setTitle:title forState:UIControlStateNormal];
    [btn setTitle:title forState:UIControlStateHighlighted ];
    
    btn.titleLabel.textColor=[UIColor whiteColor];
    btn.titleLabel.font=[UIFont systemFontOfSize:15];
    btn.backgroundColor=[UIColor colorWithPatternImage:[UIImage imageNamed:pic2]];
    btn.tag=tag;
    [btn setBackgroundImage:[UIImage imageNamed:pic1] forState:UIControlStateNormal];
    [btn setBackgroundImage:[UIImage imageNamed:pic2] forState:UIControlStateHighlighted];
    [btn addTarget:self action:@selector(btn_Action:) forControlEvents:UIControlEventTouchUpInside];
    [scroll addSubview:btn];
    
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self All_Init];
    [self CreateScrollView];
    
}
-(void)viewWillAppear:(BOOL)animated
{
    if([Function isBlankString:app.str_workerName])
    {
        app.str_workerName=@"";
    }
    if(self.isAddNewTask)
    {
    
        if(isPeople)
        {
            lab_thePersonFrom3.text=app.str_workerName;
            isPeople=NO;
        }
        if(isContent)
        {
            isContent=NO;
            lab_content3.text=app.str_temporary;
        }
    }
    else
    {
        //Dlog(@"%@",app.arr_uname_indexno);
        //Dlog(@"===%@===",app.str_index_no);
        if([Function isBlankString:self.str_tsts])
        {
            if([self.str_isMyTask isEqualToString:@"1"])
            {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    //Dlog(@"================================");
                    [self Submit_Update_Status0:@"0"];//发送我已查看该页面
                    //Dlog(@"发送我已查看该页面");
                    //Dlog(@"================================");
                });
            }
            self.str_tsts=@"0";
        }
    }
}
-(void)All_Init
{
    app=(AppDelegate *)[[UIApplication sharedApplication]delegate];
    if(StatusBar_System>0)
        moment_status=20;
    else moment_status=0;
    NavView *nav_View=[[NavView alloc]init];

    if([self.str_isMyTask isEqualToString:@"1"])
    {
        [self.view addSubview: [nav_View NavView_Title1:@"我的任务"]];
    }
    else if([self.str_isMyTask isEqualToString:@"0"])
    {
        [self.view addSubview: [nav_View NavView_Title1:@"任务交办"]];
    }
    else
    {
        [self.view addSubview: [nav_View NavView_Title1:@"新任务交办"]];
    }
    //背景图案
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"AddNewClerkBacground"]]];
    
    //左边返回键
    UIButton *btn=[UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame=CGRectMake(0, moment_status, 60, 44);
    btn.backgroundColor=[UIColor clearColor];
    btn.tag=buttonTag-1;
    [btn addTarget:self action:@selector(btn_Action:) forControlEvents:UIControlEventTouchUpInside];
    [nav_View.view_Nav  addSubview:btn];
    [btn setBackgroundImage:[UIImage imageNamed:@"btn_color6.png"] forState:UIControlStateHighlighted];
    [btn setTitle:@"< 返回" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    btn.titleLabel.font=[UIFont systemFontOfSize:15];
    
    str_auth=[[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"auth"];
    if([self.str_isMyTask isEqualToString:@"0"] && !self.isAddNewTask) {
        _tableArray = [[NSMutableArray alloc] initWithObjects:@"任务内容",@"发布时间",@"执行者",@"执行状态",@"处理结果", nil];
        _contentArray = [[NSMutableArray alloc] initWithObjects:self.str_content,self.str_ins_date,self.str_uname,[self TheTask_Status], self.str_tret,nil];
        
        if ([Function StringIsNotEmpty:[self.assignDic objectForKey:CCONFIRMDATE]]) {
            [_contentArray   insertObject:[self.assignDic objectForKey:CCONFIRMDATE]  atIndex:(_tableArray.count-1)];
            [_tableArray insertObject:@"确认时间" atIndex:(_tableArray.count-1)];
        }
        if ([Function StringIsNotEmpty:[self.assignDic objectForKey:CKACCEPTDATE]]) {
            [_contentArray   insertObject:[self.assignDic objectForKey:CKACCEPTDATE]  atIndex:(_tableArray.count-1)];
            [_tableArray insertObject:@"接受时间" atIndex:(_tableArray.count-1)];
        }
        if ([Function StringIsNotEmpty:[self.assignDic objectForKey:CKREFUSEDATE]]) {
            [_contentArray   insertObject:[self.assignDic objectForKey:CKREFUSEDATE]  atIndex:(_tableArray.count-1)];
            [_tableArray insertObject:@"拒绝时间" atIndex:(_tableArray.count-1)];
        }
        if ([Function StringIsNotEmpty:[self.assignDic objectForKey:COMPLETEDATE]]) {
            [_contentArray   insertObject:[self.assignDic objectForKey:COMPLETEDATE]  atIndex:(_tableArray.count-1)];
            [_tableArray insertObject:@"完成时间" atIndex:(_tableArray.count-1)];
        }
        
        self.myTableView = [[UITableView alloc] initWithFrame:CGRectMake(10, 130, 300, 44*_tableArray.count)
                                                        style:UITableViewStylePlain];
        [self.myTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
        self.myTableView.delegate = self;
        self.myTableView.dataSource = self;
        self.myTableView.layer.borderColor = [UIColor grayColor].CGColor;
        [self.myTableView.layer setCornerRadius:10.0];//设置矩形四个圆角半径
        self.myTableView.layer.borderWidth = 1;
        [self.myTableView.layer setMasksToBounds:YES];
        self.myTableView.bounces = NO;
        [self.view addSubview:self.myTableView];
    }
}

-(void)Row_ScrollView1:(UIView *)view Header:(UIColor *)color Title:(NSString *)title Pic:(NSString *)png Background:(NSString*)name
{
    //信息start
    UIImageView *imgView=[[UIImageView alloc]init];
    imgView.frame=CGRectMake(0,44+moment_status, Phone_Weight, 53);
    imgView.image=[UIImage imageNamed:name];
    [view addSubview:imgView];
    
    UILabel *lab=[[UILabel alloc]init];
    lab.frame=CGRectMake(54, 8, 100, 38);
    lab.backgroundColor=[UIColor clearColor];
    lab.textColor=color;
    lab.text=title;
    lab.font=[UIFont systemFontOfSize:19.0];
    [imgView addSubview:lab];
    
    UIImageView *imgView_icon1=[[UIImageView alloc]init];
    imgView_icon1.frame=CGRectMake(14, 10, 32, 32);
    imgView_icon1.backgroundColor=[UIColor clearColor];
    imgView_icon1.image=[UIImage imageNamed:[NSString stringWithFormat:@"iconic_%@.png",png]];
    [imgView addSubview:imgView_icon1];
    [view addSubview:imgView];
    //end
}

-(void)Row_ScrollView:(UIScrollView *)scroll Header:(UIColor *)color Title:(NSString *)title Pic:(NSString *)png Background:(NSString*)name
{
    //信息start
    UIImageView *imgView=[[UIImageView alloc]init];
    imgView.frame=CGRectMake(0,0, Phone_Weight, 53);
    imgView.image=[UIImage imageNamed:name];
    [scroll addSubview:imgView];
    
    UILabel *lab=[[UILabel alloc]init];
    lab.frame=CGRectMake(54, 8, 100, 38);
    lab.backgroundColor=[UIColor clearColor];
    lab.textColor=color;
    lab.text=title;
    lab.font=[UIFont systemFontOfSize:19.0];
    [imgView addSubview:lab];
    
    UIImageView *imgView_icon1=[[UIImageView alloc]init];
    imgView_icon1.frame=CGRectMake(14, 10, 32, 32);
    imgView_icon1.backgroundColor=[UIColor clearColor];
    imgView_icon1.image=[UIImage imageNamed:[NSString stringWithFormat:@"iconic_%@.png",png]];
    [imgView addSubview:imgView_icon1];
    [scroll addSubview:imgView];
    //end
}
-(void)btn_Action:(id)sender
{
    UIButton *btn=(UIButton *)sender;
    if(btn.tag==buttonTag-2)//去选择人员
    {
        //Dlog(@"去选择人员");
    }
    else if(btn.tag==buttonTag-1)//返回
    {
        if(!self.isAddNewTask)//只读状态
        {
            app.isOnlyGoBack=YES;
            [self.navigationController popViewControllerAnimated:YES];
            return;
        }
        [self WhenBack_mention];//返回 alertView
    }
    else if(buttonTag==btn.tag)//接收
    {
        //Dlog(@"接收");
        self.str_tsts=@"1";
        [self Creat_alertView:@"请填写接受任务备注"];
    }
    else if(buttonTag+1==btn.tag)//拒绝
    {
        //Dlog(@"拒绝");
        self.str_tsts=@"2";
        [self Creat_alertView:@"请填写拒绝原由"];
    }
    else if(buttonTag+2==btn.tag)//完成
    {
        //Dlog(@"完成");
        self.str_tsts=@"3";
        [self Creat_alertView:@"请填写完成备注"];
    }
    else if(buttonTag*2==btn.tag)//新任务
    {
        //Dlog(@"新任务");
        if(lab_content3.text.length==0||lab_thePersonFrom3.text.length==0)
        {
            [SGInfoAlert showInfo:@"任务说明内容和人员是必填字段!"
                          bgColor:[[UIColor darkGrayColor] CGColor]
                           inView:self.view
                         vertical:0.5];
        }
        else
        {
            //Dlog(@"这块是干嘛的？？？");
            [self alert_submit];
        }
    }
    else if(buttonTag*3==btn.tag)//添加人员
    {
        //Dlog(@"添加人员");
        LocationViewController *loVC=[[LocationViewController alloc]init];
        loVC.str_from=@"2";//指派
        [self.navigationController pushViewController:loVC animated:NO];
    }
}
-(void)Creat_alertView:(NSString *)title
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:@" " delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定",nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alert show];
    alert=nil;
}
-(void)alert_submit
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"要提交新任务吗" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定",nil];
    [alert show];
    alert=nil;
}
-(void)WhenBack_mention//编辑状态中 返回提示
{
    isBack=YES;
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"即将清除编辑信息,确认要返回吗" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定",nil];
    [alert show];
    alert=nil;
}
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if(buttonIndex==1)
    {
        if(isBack)//返回键
        {
            isBack=NO;
            app.isOnlyGoBack=YES;
            [self.navigationController popViewControllerAnimated:YES];
        }
        else if(self.isAddNewTask)//是添加新任务 提交
        {
            [self Submit_Update_Status:self.str_tsts];//实际这个字段这块没用
        }
        else
        {
            str_tret=[alertView textFieldAtIndex:0].text;
            if(([Function isBlankString:str_tret]||[str_tret isEqualToString:@""])&&(![alertView.title isEqualToString:@"请填写接受任务备注"]))
            {
                [SGInfoAlert showInfo:alertView.title
                              bgColor:[[UIColor darkGrayColor] CGColor]
                               inView:self.view
                             vertical:0.5];
                return;
            }
            [self Submit_Update_Status:self.str_tsts];
        }
        
    }
}
-(NSString *)SettingUrl_Submit_Update_Status:(NSString*)url
{
    NSString *string;
    if(self.isAddNewTask)//添加新任务
    {
        string=[NSString stringWithFormat:@"%@%@",url,KNew_task];
    }
    else//更新任务状态
    {
        string=[NSString stringWithFormat:@"%@%@",url,KUpdate_status];
    }
    return string;
}
-(void)Submit_Update_Status:(NSString *)str_status
{
    if([Function isConnectionAvailable])
    {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.mode = MBProgressHUDModeIndeterminate;
        hud.labelText = @"加载中...";//加载提示语言

        if(app.isPortal)
        {
            self.urlString=[self SettingUrl_Submit_Update_Status:KPORTAL_URL];
        }
        else
        {
            self.urlString=[self SettingUrl_Submit_Update_Status:kBASEURL];
        }
 
        NSURL *url = [ NSURL URLWithString :  self.urlString];
        ASIFormDataRequest *request = [ ASIFormDataRequest requestWithURL :url];
        request.tag = 100;
        request.delegate = self;
        [request setRequestMethod:@"POST"];
        [request setPostValue:[[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"account"]forKey:KUSER_UID];
        [request setPostValue:[[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"secret"] forKey:KUSER_PASSWORD];
        [request setPostValue:[[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"token"] forKey:@"user.token"];
        [request setPostValue:[[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"db_ip"] forKey:@"db_ip"];
        [request setPostValue:[[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"db_name"] forKey:@"db_name"];
        
        if(self.isAddNewTask)
        {
            [request setPostValue:app.str_index_no forKey:@"user_index_no"];
            [request setPostValue:lab_content3.text forKey:@"tcontent"];
        }
        else
        {
            [request setPostValue:self.str_index_no forKey:@"index_no"];
            [request setPostValue:str_status forKey:@"tsts"];
            [request setPostValue:str_tret forKey:@"tret"];
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
    NSString *str;
    if([[dict objectForKey:@"ret"] isEqual:@"0"])
    {
        if(self.isAddNewTask)
        {
            str=@"新任务建立成功";
            app.str_index_no=nil;
            app.str_workerName=nil;
        }
        else
        {
            str=@"更新任务状态成功";
        }
        
        if([str_auth isEqualToString:@"4"]&&[self.str_isMyTask isEqualToString:@"0"])
        {
            self.delegate= (id)app.VC_Task;
            [self.delegate Notify_MyTask:str];
        }
        else
        {
            //Dlog(@"%@",self.navigationController.viewControllers);
            for (id vc in self.navigationController.viewControllers) {
                if ([vc isKindOfClass:[TasksAssignedViewController class]]) {
                    self.delegate= vc;
                }
            }
            if (self.delegate && [self.delegate respondsToSelector:@selector(Notify_MyTask:)]) {
                [self.delegate Notify_MyTask:str];//这里获得代理方法的返回值。
            }
        }
        [self.navigationController popViewControllerAnimated:YES];
    }
    else
    {
        if(self.isAddNewTask)
        {
            str=@"新任务建立失败";
        }
        else
        {
            str=@"更新任务状态失败";
        }
        [SGInfoAlert showInfo:str
                      bgColor:[[UIColor darkGrayColor] CGColor]
                       inView:self.view
                     vertical:0.5];
    }
    
    
}
-(void)button_status
{
    /*
     if(我的任务)
     
     */
    if(([Function isBlankString:self.str_tsts]||[self.str_tsts isEqualToString:@"0"]||[self.str_tsts isEqualToString:@""])&&[self.str_isMyTask isEqualToString:@"1"])//我的任务
    {
         //都可用
    }
    else if([self.str_tsts isEqualToString:@"3"]||[self.str_isMyTask isEqualToString:@"0"])
    {//都不可用
        [btn_finish setBackgroundImage:[UIImage imageNamed:@"btn_color5.png"] forState:UIControlStateNormal];
        btn_finish.userInteractionEnabled=NO;
        
        [btn_accept setBackgroundImage:[UIImage imageNamed:@"btn_color5.png"] forState:UIControlStateNormal];
        btn_accept.userInteractionEnabled=NO;
        
        [btn_reject setBackgroundImage:[UIImage imageNamed:@"btn_color5.png"] forState:UIControlStateNormal];
        btn_reject.userInteractionEnabled=NO;
    }
    else if([self.str_tsts isEqualToString:@"1"])
    {
        [btn_accept setBackgroundImage:[UIImage imageNamed:@"btn_color5.png"] forState:UIControlStateNormal];
        btn_accept.userInteractionEnabled=NO;
        
        [btn_reject setBackgroundImage:[UIImage imageNamed:@"btn_color5.png"] forState:UIControlStateNormal];
        btn_reject.userInteractionEnabled=NO;
        
        [btn_finish setBackgroundImage:[UIImage imageNamed:@"btn_color6.png"] forState:UIControlStateNormal];
        btn_finish.userInteractionEnabled=YES;
    }
    else if ([self.str_tsts isEqualToString:@"2"])
    {//如果是拒绝 改成和姜哥一样 所有按钮都锁死
        [btn_accept setBackgroundImage:[UIImage imageNamed:@"btn_color5.png"] forState:UIControlStateNormal];
        btn_accept.userInteractionEnabled=NO;
        
        [btn_reject setBackgroundImage:[UIImage imageNamed:@"btn_color5.png"] forState:UIControlStateNormal];
        btn_reject.userInteractionEnabled=NO;
        
        [btn_finish setBackgroundImage:[UIImage imageNamed:@"btn_color5.png"] forState:UIControlStateNormal];
        btn_finish.userInteractionEnabled=NO;
    }
}
-(NSString *)TheTask_Status//任务状态
{
    NSString *status_task;
    if([self.str_tsts isEqualToString:@"1"])
    {
        status_task=@"已接受";
    }
    else if ([self.str_tsts isEqualToString:@"2"])
    {
        status_task=@"已拒绝";
    }
    else if([self.str_tsts isEqualToString:@"3"])
    {
        status_task=@"已完成";
    }
    else
    {
        status_task=@"无状态";
    }

    return status_task;
}
-(void)Submit_Update_Status0:(NSString *)str_status
{
    if([Function isConnectionAvailable])
    {
        if(app.isPortal)
        {
            self.urlString=[NSString stringWithFormat:@"%@%@",KPORTAL_URL,KUpdate_status];
        }
        else
        {
            self.urlString=[NSString stringWithFormat:@"%@%@",kBASEURL,KUpdate_status];
        }
        
        NSURL *url = [ NSURL URLWithString :  self.urlString];
        ASIFormDataRequest *request = [ ASIFormDataRequest requestWithURL :url];
        request.tag = 101;
        request.delegate = self;
        [request setRequestMethod:@"POST"];
        [request setPostValue:[[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"account"]forKey:KUSER_UID];
        [request setPostValue:[[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"secret"] forKey:KUSER_PASSWORD];
        [request setPostValue:[[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"token"] forKey:@"user.token"];
        [request setPostValue:[[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"db_ip"] forKey:@"db_ip"];
        [request setPostValue:[[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"db_name"] forKey:@"db_name"];
        
        [request setPostValue:self.str_index_no forKey:@"index_no"];
        [request setPostValue:str_status forKey:@"tsts"];
        [request setPostValue:str_tret forKey:@"tret"];
//        [request setCompletionBlock :^{
//            if([request responseStatusCode]==200)
//            {
//                //Dlog(@"我已查看该条任务");
//            }
//            else
//            {
//                [SGInfoAlert showInfo:@"发生异常,请稍后再试"
//                              bgColor:[[UIColor darkGrayColor] CGColor]
//                               inView:self.view
//                             vertical:0.5];
//                [NdUncaughtExceptionHandler Post_url:[NSString stringWithFormat:@"URL:%@,HTTP_Code%d",self.urlString,[request responseStatusCode]]];
//            }
//        }];
//        [request setFailedBlock :^{
//            // 请求响应失败，返回错误信息
//            //Dlog(@"HTTP 响应码：%d",[request responseStatusCode]);
//        }];
        [request startAsynchronous ];//异步
    }
}
- (IBAction)Action_content:(id)sender
{
    NoteViewController *noteVC=[[NoteViewController alloc]init];
    noteVC.str_title=@"任务内容";
    if(self.isAddNewTask)
    {
        isContent=YES;
        noteVC.isDetail=NO;
        noteVC.str_content=lab_content3.text;
    }
    else
    {
        noteVC.str_content=self.str_content;
        noteVC.isDetail=YES;
    }
    [self.navigationController pushViewController:noteVC animated:YES];
}

- (IBAction)Action_tret:(id)sender
{
    NoteViewController *noteVC=[[NoteViewController alloc]init];
    noteVC.str_title=@"反馈详细";
    noteVC.str_content=self.str_tret;
    noteVC.isDetail=YES;
     [self.navigationController pushViewController:noteVC animated:YES];
}

- (IBAction)Action_AbountPeople:(id)sender
{
    
    if(self.isAddNewTask)
    {
        //Dlog(@"添加人员");
        isPeople=YES;
        LocationViewController *loVC=[[LocationViewController alloc]init];
        loVC.str_from=@"2";//指派
        [self.navigationController pushViewController:loVC animated:NO];
    }
    else
    {
        NoteViewController *noteVC=[[NoteViewController alloc]init];
        noteVC.str_title=@"相关人员";
        noteVC.str_content=self.str_uname;
        noteVC.isDetail=YES;
        [self.navigationController pushViewController:noteVC animated:YES];
    }
    
}

#pragma mark ---- UITableView delegate method
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _tableArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    AssignCell *cell=(AssignCell*)[tableView dequeueReusableCellWithIdentifier:@"AssignCell"];
    if(cell==nil)
    {
        NSArray *nib ;
        nib= [[NSBundle mainBundle] loadNibNamed:@"AssignCell" owner:[AssignCell class] options:nil];
        cell = (AssignCell *)[nib objectAtIndex:0];
        cell.contentView.backgroundColor = [UIColor clearColor];
    }
    cell.titleLabel.text = [_tableArray objectAtIndex:indexPath.row];
    cell.contentLabel.text = [_contentArray objectAtIndex:indexPath.row];
    
    if (indexPath.row == 0 || indexPath.row == 2 || indexPath.row ==_tableArray.count-1) {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        [self Action_content:nil];
    }else if (indexPath.row == 2) {
        [self Action_AbountPeople:nil];
    }else if (indexPath.row == _tableArray.count-1) {
        [self Action_tret:nil];
    }
}

-(void)requestFinished:(ASIHTTPRequest *)request {
    if (request.tag == 100) {
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
            [NdUncaughtExceptionHandler Post_url:[NSString stringWithFormat:@"URL:%@,HTTP_Code%d",self.urlString,[request responseStatusCode]]];
        }
    }
    if (request.tag == 101) {
        if([request responseStatusCode]==200)
        {
            //Dlog(@"我已查看该条任务");
        }
        else
        {
            [SGInfoAlert showInfo:@"发生异常,请稍后再试"
                          bgColor:[[UIColor darkGrayColor] CGColor]
                           inView:self.view
                         vertical:0.5];
            [NdUncaughtExceptionHandler Post_url:[NSString stringWithFormat:@"URL:%@,HTTP_Code%d",self.urlString,[request responseStatusCode]]];
        }
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
    }
    if (request.tag == 101) {
        
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end

