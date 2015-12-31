//
//  ADSignViewController.m
//  WZYB_syb
//
//  Created by wzyb on 15-3-6.
//  Copyright (c) 2015年 WZYB. All rights reserved.
//

#import "ADSignViewController.h"
#import "AppDelegate.h"
#import "ADCell.h"

@interface ADSignViewController ()<UITableViewDelegate,UITableViewDataSource>
{
    AppDelegate *app;
    NSString *urlString;
    NSMutableArray *dataArray;
    NSMutableArray *indexArray;
    UITableView *tableView1;
}
@end

@implementation ADSignViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor colorWithRed:252/255.0 green:252/255.0 blue:252/255.0 alpha:1];
    self.showPushView = NO;
    [self.view addSubview: [nav_View NavView_Title1:@"终端"]];
    app=(AppDelegate *)[[UIApplication sharedApplication]delegate];
    
    UIButton *btn=[UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame=CGRectMake(0, moment_status, 60, 44);
    [btn setBackgroundImage:[UIImage imageNamed:@"btn_color6.png"] forState:UIControlStateHighlighted];
    [btn setTitle:@"< 返回" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    btn.titleLabel.font=[UIFont systemFontOfSize:15];
    btn.backgroundColor=[UIColor clearColor];
    [btn addTarget:self action:@selector(btn_Action:) forControlEvents:UIControlEventTouchUpInside];
    [nav_View.view_Nav  addSubview:btn];
    
    dataArray = [NSMutableArray array];
    indexArray = [NSMutableArray array];
    
    tableView1 = [[UITableView alloc] initWithFrame:CGRectMake(10, 80, 300, 44*dataArray.count) style:UITableViewStylePlain];
    tableView1.delegate = self;
    tableView1.dataSource = self;
    tableView1.bounces = NO;
    [tableView1.layer setMasksToBounds:YES];
    [tableView1.layer setCornerRadius:10.0];
    tableView1.layer.borderColor = [UIColor grayColor].CGColor;
    [tableView1 setSeparatorColor:[UIColor clearColor]];
    tableView1.layer.borderWidth = 1;
    [self.view addSubview:tableView1];
    
    [self get_NewOrFighterList];
}

-(void)btn_Action:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)get_NewOrFighterList
{
    if([Function isConnectionAvailable])
    {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.mode = MBProgressHUDModeIndeterminate;
        hud.labelText = @"加载中...";//加载提示语言
        
        if(app.isPortal)
        {
            urlString = [NSString stringWithFormat:@"%@%@",KPORTAL_URL,Boss_getSign];
            
        }
        else
        {
            urlString = [NSString stringWithFormat:@"%@%@",kBASEURL,Boss_getSign];
        }
        
        NSURL *url = [ NSURL URLWithString: urlString];
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

#pragma mark ---- ASIHttpRequest method
-(void)requestFinished:(ASIHTTPRequest *)request {
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    if([request responseStatusCode]==200){
        NSString * jsonString  =  [request responseString];
        SBJsonParser *parser = [[SBJsonParser alloc] init];
        NSDictionary *dict =[parser objectWithString: jsonString];
        NSArray *tempArray = [dict objectForKey:@"CorpList"];
        for (NSDictionary *tempDic in tempArray) {
            [dataArray addObject:[tempDic objectForKey:@"gname"]];
            [indexArray addObject:[tempDic objectForKey:@"index_no"]];
        }
        tableView1.height = 44*dataArray.count;
        [tableView1 reloadData];
    }else{
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
}

#pragma mark ---- UITableView delegate and dataSource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return dataArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ADCell *cell=(ADCell*)[tableView dequeueReusableCellWithIdentifier:@"ADCell"];
    if(cell==nil)
    {
        NSArray *nib;
        if(isPad)
        {
            nib= [[NSBundle mainBundle] loadNibNamed:@"ADCell_ipad" owner:[ADCell class] options:nil];
        }
        else
        {
            nib= [[NSBundle mainBundle] loadNibNamed:@"ADCell" owner:[ADCell class] options:nil];
        }
        cell = (ADCell *)[nib objectAtIndex:0];
        cell.contentView.backgroundColor = [UIColor clearColor];
    }
    cell.backgroundColor=[UIColor clearColor];
    cell.addressLabel.text = [dataArray objectAtIndex:indexPath.row];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    app.BSAddress = [indexArray objectAtIndex:indexPath.row];
    app.BSAddressStr = [dataArray objectAtIndex:indexPath.row];
    [self.navigationController popViewControllerAnimated:YES];
}

@end
