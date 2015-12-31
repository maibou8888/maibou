  //
//  MessageViewController.m
//  WZYB_syb
//
//  Created by wzyb on 14-6-25.
//  Copyright (c) 2014年 WZYB. All rights reserved.
//
#import <AudioToolbox/AudioToolbox.h>
#import "MessageViewController.h"
#import "MessageTableViewCell.h"
#import "AppDelegate.h"
@interface MessageViewController ()<MyDelegate_msgVC,ASIHTTPRequestDelegate>
{
    AppDelegate *app;
}
@end

@implementation MessageViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setInteger:0 forKey:NUM_MES];
    
    [self All_Init];
    if (app.notifier) { //1.0.4重大调整 全局只执行一次
        [self Local_NoticeCache];//获取本地缓存好的通知数据
        app.notifier = 0;
    }
    [self Request_Url];//向网络请求通知数据
    app.is_msg_open=YES;
    
    /*
     1.先判断本地是否有通知文本 有则取出来放入动态数组  然后 请求网络 
     有数据则判断数据每条是否和本地的重复 重复则不添加 不重复 塞进动态数组里面 保存入库（标引和信息）
     然后把动态数组 显示出 并根据 是否读过 进行状态标引显示
     
     2.进行阅读 并根据返回结果 已经传给远程 我读过 那么 状态标引为YES 入库
     
     3.如果阅读过的信息 再阅读的时候就不必告知网络 我读过了 也不用操作数据库
     
     */
    //[self To_getMessage];//向网络请求通知数据
//    [self start];
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    app.New_msg=NO;
    [self To_getMessage];
}
-(void)viewWillDisappear:(BOOL)animated
{
    app.is_msg_open=NO;
    
}
-(void)Update_Read//更新阅读提示
{//1加载新消息时候更新 2查看详细时候更新 3删除单条 4多条时候更新
    //=======做未读消息提示start
    app.unRead_count=[NavView returnCount];
    
    if(app.unRead_count!=0)
    {
        app.VC_msg.tabBarItem.badgeValue = [NSString stringWithFormat:@"%ld",(long)app.unRead_count];
    }
    else
    {
        app.VC_msg.tabBarItem.badgeValue=nil;
    }
    //=======做未读消息提示end
}
-(void)start
{
    //1second 调用一次
    float update_msg=[[[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"NoticeTimer"] floatValue];
    if(update_msg>0)
    {
        timer = [NSTimer scheduledTimerWithTimeInterval:update_msg target:self selector:@selector(To_getMessage) userInfo:nil repeats:YES];
    }
}
- (void)stop
{
    [timer invalidate];
    timer = nil;
}
-(void)To_getMessage
{
    [self Request_Url];//向网络请求通知数据
    //Dlog(@"我在定时获取消息 5秒一次");
}
-(void)Notify_msgVC//代理方法刷页面
{
    [self Jpush_mention:YES];
    tableView_message.hidden = NO;
}
-(void)All_Init
{
    app=(AppDelegate *)[[UIApplication sharedApplication]delegate];
    [self addNavTItle:self.titleString flag:1];
    
    UIButton *btn_back=[UIButton buttonWithType:UIButtonTypeCustom];
    btn_back.frame=CGRectMake(0, moment_status, 60, 44);
    btn_back.backgroundColor=[UIColor clearColor];
    btn_back.tag=buttonTag-1;
    [btn_back addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    [nav_View.view_Nav  addSubview:btn_back];
    [btn_back setBackgroundImage:[UIImage imageNamed:@"btn_color6.png"] forState:UIControlStateHighlighted];
    [btn_back setTitle:@"< 返回" forState:UIControlStateNormal];
    [btn_back setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    btn_back.titleLabel.font=[UIFont systemFontOfSize:15];
    
    UIButton *btn=[UIButton buttonWithType:UIButtonTypeCustom]; //删除所有消息
    btn.frame=CGRectMake(Phone_Weight-62, moment_status, 60, 44);
    btn.backgroundColor=[UIColor clearColor];
    btn.tag=buttonTag;
    [btn setTitle:@"清空消息" forState:UIControlStateNormal];
    [btn setBackgroundImage:[UIImage imageNamed:@"btn_color6.png"] forState:UIControlStateHighlighted];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    btn.titleLabel.font=[UIFont systemFontOfSize:15];
    [btn addTarget:self action:@selector(Delect) forControlEvents:UIControlEventTouchUpInside];
    [nav_View.view_Nav  addSubview:btn];
    
    dictionary_data=[[NSMutableDictionary alloc]init];
    
    tableView_message=[[BaseTableView alloc]initWithFrame:CGRectMake(0, 44+moment_status, Phone_Weight, Phone_Height-44-moment_status)];
    [self.view addSubview:tableView_message];
    tableView_message.eventDelegate = self;
    [tableView_message setSeparatorColor:[UIColor clearColor]];
    
    tableView_message.data = [IsRead sharedInstance].arr_isRead;
}

- (void)back {
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)pushViewOpenOrClose{
    tableView_message.top = self.pushView.bottom;
}

- (void)labelTapMethod{
    [self To_getMessage];
}

-(void)Delect
{
    isDelectAll=YES;
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"是否清空消息通知列表" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定",nil];
    [alert show];
    alert=nil;
}
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex==1)
    {
        if(isDelectAll)
        {
            isDelectAll=NO;
            [[IsRead  sharedInstance ].arr_isRead removeAllObjects];
            [self Update_Read];//更新显示未读数
            [app.array_message removeAllObjects];
            [Function DeleteTheFile:[NSString stringWithFormat:@"%@/%@",MyFolder,IsReadBefore] Kind:Library_Cache];
            [Function DeleteTheFile:[NSString stringWithFormat:@"%@/%@",MyFolder,Message_Notice] Kind:Library_Cache];
            [tableView_message reloadData];
            [self Is_Nothing];
        }
        else{
        }
    }
    else
    {
        if(isDelectAll)
        {
            isDelectAll=NO;
        }
        else{
        }
    }
}

-(void)Request_Url
{
    if([Function isConnectionAvailable])
    {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.mode = MBProgressHUDModeIndeterminate;
        hud.labelText = @"加载中...";//加载提示语言
        if(app.isPortal)
        {
            self.urlString=[NSString stringWithFormat:@"%@%@",KPORTAL_URL,KGET_NOTICE];
        }
        else
        {
            self.urlString=[NSString stringWithFormat:@"%@%@",kBASEURL,KGET_NOTICE];
        }
        
        NSURL *url = [ NSURL URLWithString :  self.urlString];
        ASIFormDataRequest *request = [ ASIFormDataRequest requestWithURL :url];
        request.delegate = self;
        request.tag = 100;
        [request setRequestMethod:@"POST"];
        
        [request setPostValue:[[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"account"]forKey:KUSER_UID];
        [request setPostValue:[[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"secret"] forKey:KUSER_PASSWORD];
        [request setPostValue:[[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"token"] forKey:@"user.token"];
        [request setPostValue:[[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"db_ip"] forKey:@"db_ip"];
        [request setPostValue:[[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"db_name"] forKey:@"db_name"];
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
-(void)startPlayer
{
    AudioServicesPlaySystemSound(1007);
}

-(void)get_JsonString:(NSString *)jsonString
{
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    SBJsonParser *parser = [[SBJsonParser alloc] init];
    NSDictionary *dict =[parser objectWithString: jsonString];
    if([[dict objectForKey:@"ret"]isEqualToString:@"0"])
    {
        NSArray *arr=[dict objectForKey:@"NoticeList"];
        
        if(arr.count!=0)
        {
            [self startPlayer]; //推送声音
            //推送的消息标记未读
            for (NSInteger i=0;i<arr.count; i++) {
                NSDictionary *dic=[arr objectAtIndex:arr.count-i-1];
                [app.array_message insertObject:dic atIndex:0];
                NSMutableDictionary *dictionary=[[NSMutableDictionary alloc]init];
                [dictionary setObject:@"NO" forKey:@"is_read"];
                [dictionary setObject:[dic objectForKey:@"index_no"] forKey:@"index_no"];
                [[IsRead sharedInstance].arr_isRead insertObject:dictionary atIndex:0];
                dictionary=nil;
            }
            [self Re_write];
        }
        [self Update_Read];
        [self Is_Nothing];
        [tableView_message reloadData];
        
    }
    else{
    }
}
-(void)Is_Nothing
{
    if([IsRead sharedInstance].arr_isRead.count==0)
    {
        [self.view addSubview:imageView_Face];
        tableView_message.hidden = YES;
    }
    else
    {
        [imageView_Face removeFromSuperview];
    }
}
-(void)Local_NoticeCache
{//获取本地缓存好的通知数据
    
    if([Function judgeFileExist:Message_Notice Kind:Library_Cache])
    {
        NSDictionary *dic=[Function ReadFromFile:Message_Notice Kind:Library_Cache];
        [app.array_message addObjectsFromArray:[dic objectForKey:@"data"]];
    }
//是否已读 逻辑判断
    if([Function judgeFileExist:IsReadBefore Kind:Library_Cache])
    {
        NSDictionary *dic=[Function ReadFromFile:IsReadBefore Kind:Library_Cache];
        [[IsRead sharedInstance].arr_isRead addObjectsFromArray:[dic objectForKey:@"data"]];
    }
}

#pragma mark ---- BaseTableView Delegate and DataSource Method Start
-(void)pullDown:(BaseTableView *)tableView {
    [self To_getMessage];
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}

//一共有几组 返回有几个 section 块
-(CGFloat)tableView:(BaseTableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(isPad) return 100;
    else      return 120;
}

-(NSInteger)tableView:(BaseTableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return tableView_message.data.count;
}

//cell注意数据结构的变化 indexPath.row 是循环变化的
-(UITableViewCell *)tableView:(BaseTableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MessageTableViewCell *cell=(MessageTableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"MessageTableViewCell"];
    if(cell==nil)
    {
        NSArray *nib ;
        if(isPad)
        {
            nib= [[NSBundle mainBundle] loadNibNamed:@"MessageTableViewCell_ipad" owner:[MessageTableViewCell class] options:nil];
        }
        else
        {
            nib= [[NSBundle mainBundle] loadNibNamed:@"MessageTableViewCell" owner:[MessageTableViewCell class] options:nil];
        }
        
        cell = (MessageTableViewCell *)[nib objectAtIndex:0];
        cell.contentView.backgroundColor = [UIColor clearColor];
    }
    //mtype 0个人  1 企业  2 系统
    
    NSDictionary * dic=[app.array_message  objectAtIndex: indexPath.row];
    cell.lab_sendFromeWhom.text=[dic objectForKey:@"uname"];
    cell.lab_content.text=[dic objectForKey:@"content"];
    cell.lab_sendTime.text=[dic objectForKey:@"upd_date"];
    if([[dic objectForKey:@"mtype"] isEqualToString:@"0"])
    {
        cell.imgView_Infomtype.image=[UIImage imageNamed:@"icon_message_0.png"];
    }
    else if([[dic objectForKey:@"mtype"] isEqualToString:@"1"])
    {
        cell.imgView_Infomtype.image=[UIImage imageNamed:@"icon_message_1.png"];
    }
    else
    {
        cell.imgView_Infomtype.image=[UIImage imageNamed:@"icon_message_2.png"];
    }
    cell.img_Background.image=[UIImage imageNamed:@"cell_message_background.png"];
    
    NSDictionary *dict=[[IsRead sharedInstance].arr_isRead objectAtIndex:indexPath.row];
    if( [[NSString stringWithFormat:@"%@",[dict objectForKey:@"is_read"]]isEqualToString:@"YES"])
    {
        cell.img_isRead.image=[UIImage imageNamed:@"icon_read.png"];
        cell.imageView_BigRead.image=[UIImage imageNamed:@"icon_read_ever.png"];
    }
    cell.selectionStyle=UITableViewCellSelectionStyleNone;//无点击效果
    return cell;
}
-(void)tableView:(BaseTableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    __block MessageDetailViewController *messageVC=[[MessageDetailViewController alloc]init];
    NSDictionary * dic=[app.array_message  objectAtIndex:indexPath.row];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSDictionary *dict=[[IsRead sharedInstance].arr_isRead objectAtIndex:indexPath.row];
        if( ![[NSString stringWithFormat:@"%@",[dict objectForKey:@"is_read"]]isEqualToString:@"YES"])
            [self Have_read_notice_IDIndex: indexPath.row];//通知已读该条通知
        
        dispatch_async(dispatch_get_main_queue(), ^{
            messageVC.msg_Notice=[[MessageNotice alloc]init];
            messageVC.msg_Notice.str_uname=[dic objectForKey:@"uname"];
            messageVC.msg_Notice.str_content=[dic objectForKey:@"content"];
            messageVC.msg_Notice.str_Date=[dic objectForKey:@"upd_date"];
            messageVC.msg_Notice.str_index_no=[dic objectForKey:@"index_no"];
            [self.navigationController pushViewController:messageVC animated:YES];
            messageVC=nil;
        });
    });
}
- (void)tableView:(BaseTableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [[IsRead sharedInstance].arr_isRead removeObjectAtIndex:indexPath.row];
        [self Update_Read];//更新显示未读数
        [app.array_message removeObjectAtIndex:indexPath.row];
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self Re_write];
        });
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

#pragma mark ---- BaseTableView Delegate and DataSource Method end

-(void)Re_write//重新写入文件 是否已读  消息条数
{
    NSDictionary *dict_read=[NSDictionary dictionaryWithObject:[IsRead sharedInstance].arr_isRead forKey:@"data"];
    
    NSString *str= [Function achieveThe_filepath:[NSString stringWithFormat:@"%@%@",MyFolder,IsReadBefore] Kind:Library_Cache];
    [Function Delete_TotalFileFromPath:str];
    [Function creatTheFile:IsReadBefore Kind:Library_Cache];
    [Function WriteToFile:IsReadBefore File: dict_read Kind:Library_Cache];
    //推送的消息标记未读end
    NSDictionary *dic_data=[NSDictionary dictionaryWithObject:app.array_message forKey:@"data"];
    NSString *str1= [Function achieveThe_filepath:Message_Notice Kind:Library_Cache];
    [Function Delete_TotalFileFromPath:str1];
    [Function creatTheFile:Message_Notice Kind:Library_Cache];
    [Function WriteToFile:Message_Notice File:dic_data Kind:Library_Cache];
}
-(void)Have_read_notice_IDIndex:(NSInteger  )indexPath
{
    self.indexPath = indexPath;
    NSDictionary * dic=[app.array_message  objectAtIndex:indexPath];
    if([Function isConnectionAvailable])
    {
        if(app.isPortal)
        {
            self.urlString=[NSString stringWithFormat:@"%@%@",KPORTAL_URL,KREAD_NOTICE];
        }
        else
        {
            self.urlString=[NSString stringWithFormat:@"%@%@",kBASEURL,KREAD_NOTICE];
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
 
        [request setPostValue:[dic objectForKey:@"index_no"] forKey:KINDEX_NO];
        [request startAsynchronous ];//异步
    }
    else
    {
        [SGInfoAlert showInfo:@"网络不佳,无法反馈您已读过该条通知"
                      bgColor:[[UIColor darkGrayColor] CGColor]
                       inView:self.view
                     vertical:0.5];
    }
}
-(void)get_JsonString1:(NSString *)jsonString  Index:(NSInteger)indexPath
{
    NSDictionary * dic=[app.array_message  objectAtIndex:indexPath];
    SBJsonParser *parser = [[SBJsonParser alloc] init];
    NSDictionary *dict =[parser objectWithString: jsonString];
    if([[dict objectForKey:@"ret"]isEqualToString:@"0"])
    {
        MessageNotice *msg_New=[[MessageNotice alloc]init];
        msg_New.str_index_no=[dic objectForKey:@"index_no"];
        msg_New.str_Date=[dic objectForKey:@"upd_date"];
        msg_New.str_content=[dic objectForKey:@"content"];
        msg_New.isRead=YES;
        
        NSMutableDictionary *dictionary=[[NSMutableDictionary alloc]init];
        [dictionary setObject:@"YES" forKey:@"is_read"];
        [dictionary setObject:[dic objectForKey:@"index_no"] forKey:@"index_no"];
        
        [[IsRead sharedInstance].arr_isRead replaceObjectAtIndex:indexPath withObject:dictionary];
        NSDictionary *dict=[NSDictionary dictionaryWithObject:[IsRead sharedInstance].arr_isRead forKey:@"data"];
        [self Update_Read];//更新显示未读数
        NSString *str= [Function achieveThe_filepath:IsReadBefore Kind:Library_Cache];
        [Function Delete_TotalFileFromPath:str];
        [Function creatTheFile:IsReadBefore Kind:Library_Cache];
        [Function WriteToFile:IsReadBefore File: dict Kind:Library_Cache];
        NSDictionary *dic=[Function ReadFromFile:Message_Notice Kind:Library_Cache];
        [app.array_message removeAllObjects];
        [app.array_message addObjectsFromArray:[dic objectForKey:@"data"]];
        [tableView_message reloadData];
    }
    else
    {
        [SGInfoAlert showInfo:@"网络不佳,无法反馈您已读过该条通知"
                      bgColor:[[UIColor darkGrayColor] CGColor]
                       inView:self.view
                     vertical:0.5];
    }
    dict=nil;
    dic=nil;

}
-(void)btn_Action:(id)sender
{
    UIButton *btn=(UIButton *)sender;
    if(btn.tag==buttonTag-1)//返回
    {
      
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
        if([request responseStatusCode]==200){
            NSString * jsonString  =  [request responseString];
            [self get_JsonString1:jsonString  Index:self.indexPath];
        }
        else{
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
    }
    if (request.tag == 101) {
        [SGInfoAlert showInfo:@"服务器无响应,无法反馈您已读过该条通知"
                      bgColor:[[UIColor darkGrayColor] CGColor]
                       inView:self.view
                     vertical:0.5];
    }
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
