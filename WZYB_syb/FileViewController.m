//
//  FileViewController.m
//  WZYB_syb
//
//  Created by wzyb on 14-7-1.
//  Copyright (c) 2014年 WZYB. All rights reserved.
//

#import "FileViewController.h"
#import "JSONKit.h"
#import "AppDelegate.h"
@interface FileViewController ()<ASIHTTPRequestDelegate>
{
    AppDelegate *app;
}
@end

@implementation FileViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}
-(void)All_Init
{
    app=(AppDelegate *)[UIApplication sharedApplication].delegate;
    if(StatusBar_System>0)
        moment_status=20;
    else moment_status=0;
    NavView *nav_View=[[NavView alloc]init];
    [self.view addSubview: [nav_View NavView_Title1:self.titleString]];
    
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
    
    imageView_Face=[[UIImageView alloc]init];
    imageView_Face=[NavView Show_Nothing_Face];
}
-(void)TableView
{
    if(StatusBar_System>0)
    {
        moment_status=20;
    }
    tableView_File=[[UITableView alloc]initWithFrame:CGRectMake(0, 44+moment_status, Phone_Weight,Phone_Height-moment_status-44 )];
    [self.view addSubview:tableView_File];
    tableView_File.dataSource=self;
    tableView_File.delegate=self;
    tableView_File.backgroundColor=[UIColor clearColor];
    tableView_File.separatorStyle=UITableViewCellSeparatorStyleNone;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self All_Init];
    [self Get_FileList];
}
#pragma tableView  Delegate
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (!section == 0) {
        
        return 46.0;
    } else {
        return 46.0;
    }
}
//cell  高度
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    return 80;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView* myView = [[UIView alloc] init];
    myView.backgroundColor = [UIColor clearColor];
    
    UIImageView *viewCell;
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.font = [UIFont boldSystemFontOfSize:18.0];
    viewCell=[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, Phone_Weight, 46)];
    titleLabel.frame= CGRectMake(30, 0, Phone_Weight-30, 46);
    viewCell.image=[UIImage imageNamed:@"cell_select_sectionBackground.png"];
    [myView addSubview:viewCell];
    titleLabel.textColor=[UIColor blackColor];
    titleLabel.backgroundColor = [UIColor clearColor];
    NSString *sectionStr = [arr_Key objectAtIndex:section];
    for (NSDictionary *tempDic in arr_H14) {
        if ([[tempDic objectForKey:@"cvalue"] isEqualToString:sectionStr]) {
            titleLabel.text=[tempDic objectForKey:@"clabel"];
        }
    }
    [myView addSubview:titleLabel];
    return myView;
}
//一共有几组 返回有几个 section 块
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    if(dic_all_Data.count==0)
    {
        [self.view addSubview:imageView_Face];
    }
    else
    {
        [imageView_Face removeFromSuperview];
    }
    return  dic_all_Data.count ;
}
//每组有几行  返回 每个块 有几行cell
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
   NSDictionary *dic=[dic_all_Data objectForKey:[arr_Key objectAtIndex:section]];
    return dic.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FileTableViewCell *cell=(FileTableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"FileTableViewCell"];
    if(cell==nil)
    {
        NSArray *nib ;
        nib= [[NSBundle mainBundle] loadNibNamed:@"FileTableViewCell" owner:[FileTableViewCell class] options:nil];

        cell = (FileTableViewCell *)[nib objectAtIndex:0];
        cell.contentView.backgroundColor = [UIColor clearColor];
    }
    UIImageView *viewCell;
    viewCell=[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, Phone_Weight, 80)];
    viewCell.image=[UIImage imageNamed:@"cell_message_background.png"];
    [cell insertSubview:viewCell atIndex:0];
    viewCell=nil;
    cell.backgroundColor=[UIColor clearColor];
    NSArray *arr=[dic_all_Data objectForKey:[arr_Key objectAtIndex:indexPath.section] ];
    NSDictionary *dic=[arr objectAtIndex:indexPath.row];
    cell.lab_title.text=[dic objectForKey:@"doc_name"];
    cell.lab_title.textAlignment=NSTextAlignmentCenter;
    cell.lab_title.textColor=tabbar_Color;
    cell.lab_size.textAlignment=NSTextAlignmentCenter;
    cell.lab_size.textColor=tabbar_Color;
    cell.lab_size.text=[dic objectForKey:@"doc_size"];
    cell.selectionStyle=UITableViewCellSelectionStyleNone;//无点击效果
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *arr= [dic_all_Data objectForKey:[arr_Key objectAtIndex:indexPath.section]];
    NSDictionary *dic=[arr objectAtIndex:indexPath.row];
    str_doc_name=[dic objectForKey:@"doc_name"];
    str_doc_path=[dic objectForKey:@"doc_path"];
    str_index_no=[dic objectForKey:@"index_no"];
    NSArray *array=[[dic objectForKey:@"doc_path"] componentsSeparatedByString:@"/"];
    str_Index=[array objectAtIndex:array.count-1];
    
    
    if([self isEXist])
    {
        DocumentViewController *docVC=[[DocumentViewController alloc]init];
        docVC.string_Title=str_doc_name;
        docVC.str_Url=str_doc_path;
        docVC.str_index_no=str_index_no;
        docVC.str_Index=str_Index;
        docVC.isCache=NO;
        docVC.exist=YES;
        [self.navigationController pushViewController:docVC animated:YES];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:str_doc_name message:[NSString stringWithFormat:@"文件大小:%@,是否下载查看",[dic objectForKey:@"doc_size"]] delegate:self cancelButtonTitle:@"关闭" otherButtonTitles:@"下载查看",nil];
        [alert show];
        alert.tag=10;
    }
}
-(BOOL)isEXist
{
    NSString *filepath=[Function CreateTheFolder_From:Library_Cache FileHolderName:Office_Products FileName:str_Index];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    return  [fileManager fileExistsAtPath:filepath];
}
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(alertView.tag==10)
    {
        DocumentViewController *docVC=[[DocumentViewController alloc]init];
        docVC.string_Title=str_doc_name;
        docVC.str_Url=str_doc_path;
        docVC.str_index_no=str_index_no;
        docVC.str_Index=str_Index;
        if(buttonIndex==1)
        {
            docVC.isCache=YES;
            [self.navigationController pushViewController:docVC animated:YES];
        }
        docVC.exist=NO;
    }
}

-(void)btn_Action:(id)sender
{
    UIButton *btn=(UIButton *)sender;
    if(btn.tag==buttonTag-1)//返回
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
}
-(void)Get_FileList
{
    if([Function isConnectionAvailable])
    {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.mode = MBProgressHUDModeIndeterminate;
        hud.labelText = @"加载中...";//加载提示语言
 
        if(app.isPortal)
        {
            self.urlString=[NSString stringWithFormat:@"%@%@",KPORTAL_URL, KList_Document];
        }
        else
        {
            self.urlString=[NSString stringWithFormat:@"%@%@",kBASEURL, KList_Document];
        } 

        NSURL *url = [ NSURL URLWithString :  self.urlString];
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
        arr_Key=[NSMutableArray arrayWithCapacity:1];
        dic_all_Data=[dict objectForKey:@"DocumentList"];
        NSDictionary *dic_H=[[BasicData sharedInstance].dic_BasicData objectForKey:@"MasterList"];
        arr_H14=[dic_H objectForKey:@"H14"];
        for(NSInteger i=0;i<arr_H14.count;i++)
        {
            NSDictionary *dic_Key=[arr_H14 objectAtIndex: i];
            NSDictionary *dic=[dic_all_Data objectForKey:[dic_Key objectForKey:@"cvalue"]];
            if(dic.count!=0)
            {
                [arr_Key addObject:[dic_Key objectForKey:@"cvalue"]];
            }
        }
       [self TableView];
    }
    else
    {
        [SGInfoAlert showInfo:@"获取文档失败请重试"
                      bgColor:[[UIColor darkGrayColor] CGColor]
                       inView:self.view
                     vertical:0.5];
    }
}

-(void)requestFinished:(ASIHTTPRequest *)request {
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

-(void)requestFailed:(ASIHTTPRequest *)request {
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    
    [SGInfoAlert showInfo:@"哎呀，服务器无响应，一会再试试吧"
                  bgColor:[[UIColor darkGrayColor] CGColor]
                   inView:self.view
                 vertical:0.5];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
