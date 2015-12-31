//
//  TasksAssignedViewController.m
//  WZYB_syb
//
//  Created by wzyb on 14-7-2.
//  Copyright (c) 2014年 WZYB. All rights reserved.
//

#import "TasksAssignedViewController.h"
#import "AppDelegate.h"
#import "TaskCell.h"
#import "UIViewExt.h"
#define People 3
@interface TasksAssignedViewController ()<MyDelegate_msgVC,MyDelegate_AdvancedSearch,UIGestureRecognizerDelegate>
{
    AppDelegate *app;
    NSString *urlString;
    BOOL isMyTask;
}
@end

@implementation TasksAssignedViewController

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
    URLFlag = 0;
    app.str_Date=[Function getYearMonthDay_Now];
    [[Advance_Search sharedInstance].arr_search removeAllObjects];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setInteger:0 forKey:NUMBER];
}
-(void)viewWillAppear:(BOOL)animated
{
    if(app.isOnlyGoBack){
        app.isOnlyGoBack=NO;
    }else {
        [self Get_list:self.isMineTask];//我的任务YES
    }
}
//通知有新的我的任务
-(void)Notify_TaskVC
{
    if(self.isMineTask)
    {
        [self Jpush_mention:YES];
    }
}
-(void)Notify_AdvancedSearch
{
//    [self Get_list:NO];//我的任务YES -》之前的任务交办实在tabar控制器里面  现在页面结构换了  所以这个位置不用在实现了
}

-(void)pushViewOpenOrClose{
    tableView_task.top = self.pushView.bottom;
}

- (void)labelTapMethod{
    if(self.isMineTask)
    {
        app.str_Date=[Function getYearMonthDay_Now];
        [self Get_list:YES];//我的任务YES
    }
}

//我的任务状态改变 代理刷新页面
-(void)Notify_MyTask:(NSString *)msg
{
    //[NSThread sleepForTimeInterval:3.0];
    if(self.isMineTask)
    {
        [self Get_list:YES];
    }
    else
    {
        [self Get_list:NO];
    }
    [SGInfoAlert showInfo:msg
                  bgColor:[[UIColor darkGrayColor] CGColor]
                   inView:self.view
                 vertical:0.5];
}
-(void)All_Init
{
    /*
     1.普通员工
     2.部门经理
     3.管理员
     4.boss
     */
    if([[[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"auth"] isEqualToString:@"4"]&&!self.isMineTask)
    {
        //1.0.4 任务交办tableView高度调整
        tableView_task=[[UITableView alloc]initWithFrame:CGRectMake(0, moment_status+44, Phone_Weight,Phone_Height-moment_status-44)];
    }
    else
    {
        tableView_task=[[UITableView alloc]initWithFrame:CGRectMake(0, moment_status+44, Phone_Weight,Phone_Height-moment_status-44 )];
    }
    tableView_task.separatorStyle = UITableViewCellSeparatorStyleNone;//隐藏tableViewCell的分割线
    tableView_task.backgroundColor=[UIColor clearColor];
    tableView_task.dataSource=self;
    tableView_task.delegate=self;
    [self.view addSubview:tableView_task];

    app=(AppDelegate*)[[UIApplication sharedApplication]delegate];
    auth=[[SelfInf_Singleton sharedInstance].dic_SelfInform  objectForKey:@"auth"];
    
    if(self.isMineTask){
        [self addNavTItle:self.titleString flag:2]; //我的任务->1.0.4
    }
    else{
        [self addNavTItle:self.titleString flag:2]; //任务交办->1.0.4
    }
    
    [self Set_SegmentView];
}

-(void)Is_Nothing{
    if(arr_list.count==0){
        [self.view addSubview:imageView_Face];
    }
    else{
        [imageView_Face removeFromSuperview];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return arr_list.count;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(isPad)
        return 100;
    return 120;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TaskCell *cell=(TaskCell*)[tableView dequeueReusableCellWithIdentifier:@"TaskCell"];
    if(cell==nil)
    {
        NSArray *nib;
        nib = [[NSBundle mainBundle] loadNibNamed:@"TaskCell" owner:[TaskCell class] options:nil];
        cell = (TaskCell *)[nib objectAtIndex:0];
        cell.contentView.backgroundColor = [UIColor clearColor];
    }
    cell.backgroundColor=[UIColor clearColor];
    UIImageView *viewCell;
    if(isPad)
    {
        viewCell=[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, Phone_Weight, 100)];
    }
    else
    {
        viewCell=[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, Phone_Weight, 120)];
    }
    viewCell.image=[UIImage imageNamed:@"cell_message_background@2X.png"];
    [cell insertSubview:viewCell atIndex:0];
    viewCell=nil;

    /*
     tsts//任务状态
     无值 未查阅
     0查阅
     1接收
     2拒绝
     3完成
     4
     */
    
    NSDictionary *dic=[arr_list objectAtIndex:indexPath.row];
    cell.lab_content.text=[dic objectForKey:@"tcontent"];
    if(self.isMineTask)
    {//我的任务 发起者
        cell.people.text=[NSString stringWithFormat:@"%@",[dic objectForKey:@"uname"]];
        cell.lab_FromOrImply.text=@"来自";
    }
    else
    {//我的指派发起者就是我自己
        cell.people.text=[dic objectForKey:@"uname"];
        cell.lab_FromOrImply.text=@"执行人";
    }
    cell.label_totalTime.text=[dic objectForKey:@"access_time"];
    cell.date.text=[dic objectForKey:@"ins_date"];
    NSString *tsts=[dic objectForKey:@"tsts"];
    if([Function isBlankString:tsts]||[tsts isEqualToString:@""])
    {
        cell.imageView_tsts.image=[UIImage imageNamed:@"cell_TaskCell-1.png"];
    }
    else if([tsts isEqualToString:@"0"] )
    {
        cell.imageView_tsts.image=[UIImage imageNamed:@"cell_TaskCell0.png"];
    }
    else if([tsts isEqualToString:@"1"] )
    {
        cell.imageView_tsts.image=[UIImage imageNamed:@"cell_TaskCell1.png"];
    }
    else if([tsts isEqualToString:@"2"] )
    {
        cell.imageView_tsts.image=[UIImage imageNamed:@"cell_TaskCell2.png"];
    }
    else if([tsts isEqualToString:@"3"] )
    {
        cell.imageView_tsts.image=[UIImage imageNamed:@"cell_TaskCell3.png"];
        cell.imageView_finish.image=[UIImage imageNamed:@"cell_TaskCell_finish.png"];
    }
    cell.selectionStyle=UITableViewCellSelectionStyleNone;//无点击效果
    dic=nil;
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *dic=[arr_list objectAtIndex:indexPath.row];
    MyTaskViewController *myVC=[[MyTaskViewController alloc]init];
    myVC.assignDic = dic;
    myVC.str_content=[dic objectForKey:@"tcontent"];
    myVC.str_ins_date=[dic objectForKey:@"ins_date"];
    myVC.str_index_no=[dic objectForKey:@"index_no"];
    myVC.str_tsts=[dic objectForKey:@"tsts"];
    myVC.delegate = self;
    if(self.isMineTask)
    {
        myVC.str_uname=[dic objectForKey:@"uname"];//发起者
        myVC.str_isMyTask=@"1";
        myVC.str_tret=[dic objectForKey:@"tret"];//备注
    }
    else
    {
        myVC.str_uname=[dic objectForKey:@"uname"];//指派相关人员
        myVC.str_isMyTask=@"0";
        if([Function isBlankString:[dic objectForKey:@"tret"]])
        {
            myVC.str_tret=@"";
        }
        else
        {
            myVC.str_tret=[dic objectForKey:@"tret"];
        }
    }
    myVC.isAddNewTask=NO;
    [self.navigationController pushViewController:myVC animated:YES];
    dic=nil;
}

-(void)Set_SegmentView
{
    for(NSInteger i=0;i<3;i++)
    {
        if(i==0&&self.isOnTabbar)//如果是在tabbar上隐藏返回键
            continue;
        UIButton *btn=[UIButton buttonWithType:UIButtonTypeCustom];
        if(i==0)//返回
        {
            btn.frame=CGRectMake(0, moment_status, 60, 44);
            btn.backgroundColor=[UIColor clearColor];
            [btn setBackgroundImage:[UIImage imageNamed:@"btn_color6.png"] forState:UIControlStateHighlighted];
            [btn setTitle:@"< 返回" forState:UIControlStateNormal];
            [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            btn.titleLabel.font=[UIFont systemFontOfSize:15];
        }
        else  if(i==1&&([auth isEqualToString:@"4"]||[auth isEqualToString:@"2"]))//新指派
        {
            btn.backgroundColor=[UIColor clearColor];
            btn.frame=CGRectMake(Phone_Weight-44, moment_status, 44, 44);
            [btn setBackgroundImage:[UIImage imageNamed:@"btn_color6.png"] forState:UIControlStateHighlighted];
            [btn setTitle:@"创建" forState:UIControlStateNormal];
            [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            btn.titleLabel.font=[UIFont systemFontOfSize:15];
            if(self.isMineTask)//我的任务
            {
                btn.hidden=YES;
            }
        }
        else if(i==2)//日历
        {
            btn.backgroundColor=[UIColor clearColor];
            if(([auth isEqualToString:@"2"]||[auth isEqualToString:@"4"]) )
            {
                btn.frame=CGRectMake(Phone_Weight*0.5-44, moment_status, 44*2.5, 44);
            }
            else
            {
                btn.frame=CGRectMake(Phone_Weight*0.5-44, moment_status, 44*2.5, 44);
            }
            [btn setBackgroundImage:[UIImage imageNamed:@"nav_menu_arrow_back.png"] forState:UIControlStateHighlighted];
        }
        btn.tag=buttonTag+i;
        [btn addTarget:self action:@selector(btn_Action:) forControlEvents:UIControlEventTouchUpInside ];
        [self.view addSubview:btn];
    }
}
-(void)btn_Action:(id)sender
{
    UIButton *btn=(UIButton *)sender;
    if(btn.tag==buttonTag )//返回
    {
        self.delegate=(id)app.VC_more; //vc
        [self.delegate Notify_Task];
        [self.navigationController popViewControllerAnimated:YES];
    }
    else if(btn.tag==buttonTag+1)//新任务
    {
        //Dlog(@"添加新任务");
        MyTaskViewController *myVC=[[MyTaskViewController alloc]init];
        myVC.isAddNewTask=YES;
        if(self.isMineTask)
        {
            myVC.str_isMyTask=@"1";
        }
        else
        {
            myVC.str_isMyTask=@"0";
        }
        [self.navigationController pushViewController:myVC animated:YES];
    }
    else if(btn.tag==buttonTag+2)//日历
    {/*
        //Dlog(@"日历");
        if(!isOpenDate)
        {
            isOpenDate=YES;
            [self select_Date];
        }
      */
        
        AdvancedSearchViewController *ad=[[AdvancedSearchViewController alloc]init];
        if(self.isMineTask)
        {
            ad.str_Num=@"3";
        }
        else
        {
            ad.str_Num=@"4";
        }
        [self.navigationController pushViewController:ad animated:YES];
    }
}
-(NSString *)SettingURL_Get_list:(NSString *)url IsMyTask:(BOOL)ismyTask
{
    NSString *string;
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    NSString * flag = [defaults objectForKey:@"userFlag"];
    if(ismyTask)//任务
    {
        if ([flag intValue]) {
            [defaults setObject:@"0" forKey:@"userFlag"];
            string=[NSString stringWithFormat:@"%@%@",url,KGETTASK];    //高级搜索之后调用的URL
        }else{
            string=[NSString stringWithFormat:@"%@%@",url,KGetTask];    //高级搜索之前调用的URL
        }
    }
    else//指派
    {
        if ([flag intValue]) {
            [defaults setObject:@"0" forKey:@"userFlag"];
            string=[NSString stringWithFormat:@"%@%@",url,KGETASSIGN];
        }else{
            string=[NSString stringWithFormat:@"%@%@",url,KGetAssign];
        }
    }
    return string;
}
-(void)Get_list:(BOOL)ismyTask
{
    isMyTask = ismyTask;
    if([Function isConnectionAvailable])
    {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.mode = MBProgressHUDModeIndeterminate;
        hud.labelText = @"加载中...";//加载提示语言

        if(app.isPortal)
        {
            urlString=[self SettingURL_Get_list:KPORTAL_URL IsMyTask:ismyTask];
        }
        else
        {
            urlString=[self SettingURL_Get_list:kBASEURL IsMyTask:ismyTask];
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
        
        if([Advance_Search sharedInstance].arr_search.count>0)
        {
            if(ismyTask)
            {
                [request setPostValue: [[Advance_Search sharedInstance].arr_search objectAtIndex:0] forKey:@"start_date"];
                [request setPostValue: [[Advance_Search sharedInstance].arr_search objectAtIndex:1] forKey:@"end_date"];
                [request setPostValue: app.str_temporary_valueH  forKey:@"tsts"];
                [request setPostValue: [[Advance_Search sharedInstance].arr_search objectAtIndex:3] forKey:@"uname"];
                [request setPostValue: [[Advance_Search sharedInstance].arr_search objectAtIndex:4] forKey:@"tcontent"];
            }
            else
            {
                [request setPostValue: [[Advance_Search sharedInstance].arr_search objectAtIndex:0] forKey:@"start_date"];
                [request setPostValue: [[Advance_Search sharedInstance].arr_search objectAtIndex:1] forKey:@"end_date"];
                [request setPostValue: app.str_temporary_valueH  forKey:@"tsts"];
                [request setPostValue: [[Advance_Search sharedInstance].arr_search objectAtIndex:3] forKey:@"uname"];
                [request setPostValue: [[Advance_Search sharedInstance].arr_search objectAtIndex:4] forKey:@"minDays"];
                [request setPostValue: [[Advance_Search sharedInstance].arr_search objectAtIndex:5] forKey:@"maxDays"];
            }
        }
        else
        {     //以前是默认搜索今天 1.0.4以后需求变了
//            [request setPostValue: [Function getYearMonthDay_Now] forKey:@"start_date"];
//            [request setPostValue: [Function getYearMonthDay_Now] forKey:@"end_date"];
        }

        
//        [request setCompletionBlock :^{
//            
//            [MBProgressHUD hideHUDForView:self.view animated:YES];
//            
//            if([request responseStatusCode]==200)
//            {
//                NSString * jsonString  =  [request responseString];
//                [self get_JsonString:jsonString Type:ismyTask];
//            }
//            else
//            {
//                [SGInfoAlert showInfo:@"发生异常,请稍后再试"
//                              bgColor:[[UIColor darkGrayColor] CGColor]
//                               inView:self.view
//                             vertical:0.5];
//                [NdUncaughtExceptionHandler Post_url:[NSString stringWithFormat:@"URL:%@,HTTP_Code%d",urlString,[request responseStatusCode]]];
//            }
//            
//            
//        }];
//        [request setFailedBlock :^{
//            [MBProgressHUD hideHUDForView:self.view animated:YES];
//            
//            [SGInfoAlert showInfo:@"哎呀，服务器无响应，一会再试试吧"
//                          bgColor:[[UIColor darkGrayColor] CGColor]
//                           inView:self.view
//                         vertical:0.5];
//            
//            // 请求响应失败，返回错误信息
//            //Dlog(@"HTTP 响应码：%d",[request responseStatusCode]);
//        }];
        [request startAsynchronous ];//异步
    }
    else
    {
        [SGInfoAlert showInfo:@"当前网络不可用，请检查网络连接"
                      bgColor:[[UIColor darkGrayColor] CGColor]
                       inView:self.view
                     vertical:0.5];
    }
    
    [tableView_task reloadData];
    
}
-(void)get_JsonString:(NSString *)jsonString Type:(BOOL)ismyTask
{
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    SBJsonParser *parser = [[SBJsonParser alloc] init];
    NSDictionary *dict =[parser objectWithString: jsonString];
    
    if([[dict objectForKey:@"ret"] isEqual:@"0"])
    {
        arr_list=nil;
        if(ismyTask)
        {
            arr_list=[dict objectForKey:@"TaskList"];
        }
        else//我的指派
        {
            arr_list=[dict objectForKey:@"TaskList"];
            
        }
        [self Is_Nothing];
        [tableView_task reloadData];
    }
    else
    {
        if(ismyTask){
        }
        else{
        }
    }
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
        [self get_JsonString:jsonString Type:isMyTask];
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
