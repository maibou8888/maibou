//
//  StorageListViewController.m
//  WZYB_syb
//
//  Created by wzyb on 14-12-1.
//  Copyright (c) 2014年 WZYB. All rights reserved.
//

#import "StorageListViewController.h"
#import "StorageDetailViewController.h"
#import "StorageListCell.h"
#import "AppDelegate.h"
@interface StorageListViewController ()
{
    NSInteger moment_status;
    AppDelegate *app;
    NSArray *arr_list;
    NSArray *arr_H13;//物料或者产品单位
    BOOL isFirst;
    NSString *urlString;
}
@property (strong, nonatomic) UITableView *tabVIew;
@property (strong, nonatomic)UISearchBar *searchBar;
@end

@implementation StorageListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self All_init];
    
    self.searchBar=[[UISearchBar alloc]initWithFrame:CGRectMake(0,44+moment_status, Phone_Weight, 44)];
    self.searchBar.autocorrectionType = UITextAutocorrectionTypeNo;
    self.searchBar.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.searchBar.keyboardType = UIKeyboardTypeDefault;
    self.searchBar.backgroundColor = [UIColor clearColor];
    self.searchBar.translucent=YES;
    self.searchBar.placeholder=@"检索范围:品牌 品名 型号";
    self.searchBar.delegate = self;
    self.searchBar.showsCancelButton=YES;
    self.searchBar.barStyle=UIBarStyleDefault;
    [self.view addSubview:self.searchBar];
    
    self.tabVIew=[[UITableView alloc]init];
    self.tabVIew.frame=CGRectMake(0, moment_status+44+44, Phone_Weight, Phone_Height-44-moment_status-44);
    [self.view addSubview:self.tabVIew];
    self.tabVIew.dataSource=self;
    self.tabVIew.delegate=self;
    isFirst=YES;
}
-(void)viewWillAppear:(BOOL)animated
{
    if([self.str_isFromQR isEqualToString:@"1"]&&isFirst)
    {
        isFirst=NO;
        [self Get_StoreList];
    }
}
-(void)All_init
{
    app=(AppDelegate *)[[UIApplication sharedApplication]delegate];
    if(StatusBar_System>0)
        moment_status=20;
    else moment_status=0;
    NavView *nav_View=[[NavView alloc]init];
    [self.view addSubview: [nav_View NavView_Title1:@"产品库存列表"]];
    //左边返回键
    for (NSInteger i=0; i<1; i++)
    {
        UIButton *btn=[UIButton buttonWithType:UIButtonTypeCustom];
        btn.backgroundColor=[UIColor clearColor];
        [btn addTarget:self action:@selector(btn_Action:) forControlEvents:UIControlEventTouchUpInside];
        [nav_View.view_Nav  addSubview:btn];
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        btn.titleLabel.font=[UIFont systemFontOfSize:15];
        [btn setBackgroundImage:[UIImage imageNamed:@"btn_color6.png"] forState:UIControlStateHighlighted];
        if(i==0)
        {
            btn.frame=CGRectMake(0, moment_status, 60, 44);
            btn.tag=buttonTag-1;
            [btn setTitle:@"< 返回" forState:UIControlStateNormal];
        }
    }
    //物料或者产品单位
    NSDictionary *dic_H=[[BasicData sharedInstance].dic_BasicData objectForKey:@"MasterList"];
    arr_H13=[dic_H objectForKey:@"H13"];//所有的head
}
-(void)btn_Action:(id)sender
{
    UIButton *btn=(UIButton *)sender;
    if(btn.tag==buttonTag-1)//返回
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mask TableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return arr_list.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 140.0;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    StorageListCell *cell=(StorageListCell*)[tableView dequeueReusableCellWithIdentifier:@"StorageListCell"];
    if(cell==nil)
    {
        NSArray *nib;
        nib= [[NSBundle mainBundle] loadNibNamed:@"StorageListCell" owner:[StorageListCell class] options:nil];
        cell = (StorageListCell *)[nib objectAtIndex:0];
        cell.contentView.backgroundColor = [UIColor clearColor];
        cell.backgroundColor= [UIColor clearColor];
    }
    UIImageView *viewCell;
    viewCell=[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, Phone_Weight, 140)];
    viewCell.image=[UIImage imageNamed:@"cell_message_background@2X.png"];
    [cell insertSubview:viewCell atIndex:0];
    viewCell=nil;
    NSDictionary *dic=[arr_list objectAtIndex:indexPath.row];
    cell.lab_brand.text=[Function isBlankString:[dic objectForKey:@"ext1"]]?@"": [dic objectForKey:@"ext1"];
    cell.lab_name.text=[dic objectForKey:@"pname"];
    cell.lab_storage_name.text=[dic objectForKey:@"ptype"];
    BOOL flag=NO;
    for (NSInteger i=0; i<arr_H13.count; i++)
    {
        NSDictionary *dic_H=[arr_H13 objectAtIndex:i];
        if([[dic_H objectForKey:@"cvalue"] isEqualToString:[dic objectForKey:@"punit"]])
        {
            cell.lab_storage_Count.text=[NSString stringWithFormat:@"%@%@",[dic objectForKey:@"stock_cnt"],[dic_H objectForKey:@"clabel"]];
            flag=YES;
            break;
        }
    }
    if(!flag)
    {
         cell.lab_storage_Count.text=[NSString stringWithFormat:@"%@",[dic objectForKey:@"stock_cnt"]];
    }
        

    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *dic=[arr_list objectAtIndex:indexPath.row];
    StorageDetailViewController *detail=[[StorageDetailViewController alloc]init];
    detail.str_index_no=[dic objectForKey:@"index_no"];
    BOOL flag=NO;
    for (NSInteger i=0; i<arr_H13.count; i++)
    {
        NSDictionary *dic_H=[arr_H13 objectAtIndex:i];
        if([[dic_H objectForKey:@"cvalue"] isEqualToString:[dic objectForKey:@"punit"]])
        {
            detail.str_unit=[dic_H objectForKey:@"clabel"];
            flag=YES;
            break;
        }
    }
    if(!flag)
    {
        detail.str_unit=@" ";
    }
    [self.navigationController pushViewController:detail animated:YES];
}
#pragma mark -
#pragma mark search bar delegate methods
- (void)searchBar:(UISearchBar *)_searchBar textDidChange:(NSString *)searchText
{
    
}
-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [self.searchBar resignFirstResponder];
}
-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{//远程检索
    [self.searchBar resignFirstResponder];
    self.str_pcode=nil;
    [self Get_StoreList];
}
-(void)Get_StoreList
{
    if([Function isConnectionAvailable])
    {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.mode = MBProgressHUDModeIndeterminate;
        hud.labelText = @"加载中...";//加载提示语言
        
        urlString=[NSString stringWithFormat:@"%@%@",KPORTAL_URL,KStore_get_product];
        NSURL *url = [ NSURL URLWithString :  urlString];
        ASIFormDataRequest *request = [ ASIFormDataRequest requestWithURL :url];
        request.delegate = self;
        [request setRequestMethod:@"POST"];
        [request setPostValue:[[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"account"]forKey:KUSER_UID];
        [request setPostValue:[[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"secret"] forKey:KUSER_PASSWORD];
        [request setPostValue:[[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"token"] forKey:@"user.token"];
        [request setPostValue:[[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"db_ip"] forKey:@"db_ip"];
        [request setPostValue:[[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"db_name"] forKey:@"db_name"];
        
        [request setPostValue:self.str_pcode forKey:@"pcode"];
        [request setPostValue:self.searchBar.text forKey:@"pname"];
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
    SBJsonParser *parser = [[SBJsonParser alloc] init];
    NSDictionary *dict =[parser objectWithString: jsonString];
    if([[dict objectForKey:@"ret"] isEqualToString:@"0"])
    {
        arr_list=nil;
        arr_list=[NSArray arrayWithArray:[dict objectForKey:@"ProductList"]];
        [self.tabVIew reloadData];
    }
    else
    {
        [SGInfoAlert showInfo:[dict objectForKey:@"message"]
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
