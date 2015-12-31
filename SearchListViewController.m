//
//  SearchListViewController.m
//  WZYB_syb
//
//  Created by wzyb on 15-3-3.
//  Copyright (c) 2015年 WZYB. All rights reserved.
//

#import "SearchListViewController.h"
#import "AdvancedSearchViewController.h"
#import "AppDelegate.h"
#import "SubmitOrderTableViewCell.h"

@interface SearchListViewController ()
{
    AppDelegate *app;
    NSString *urlString;
    NSArray *arr_ListData;//存储列表数据
}
@property (weak, nonatomic) IBOutlet UITableView *BossTableView;

@end

@implementation SearchListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.showPushView = NO;
    [self addNavTItle:@"订单查询" flag:2];
    
    [[Advance_Search sharedInstance].arr_search removeAllObjects];
    app=(AppDelegate *)[[UIApplication sharedApplication]delegate];
    app.VC_searchList = self;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];   //第一次进入时保存的字段(高级搜索时清空数据用)
    [defaults setObject:@"1" forKey:@"LIST"];
    [defaults synchronize];
    
    [self Set_SegmentView];
    [self Get_OrderList];
}

- (void)Notify_AdvancedSearch {
    [self Get_OrderList];
}

-(void)Set_SegmentView
{
    for(NSInteger i=0;i<2;i++)
    {
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
        else  if(i==1) //日历
        {
            btn.backgroundColor=[UIColor clearColor];
            btn.frame=CGRectMake(Phone_Weight*0.5-44, moment_status, 44*2.5, 44);
            [btn setBackgroundImage:[UIImage imageNamed:@"nav_menu_arrow_back.png"] forState:UIControlStateHighlighted];
        }
        btn.tag=buttonTag+i;
        [btn addTarget:self action:@selector(btn_Action:) forControlEvents:UIControlEventTouchUpInside ];
        [self.view addSubview:btn];
    }
}

-(void)btn_Action:(id)sender {
    UIButton *btn=(UIButton *)sender;
    switch (btn.tag) {
        case buttonTag:
            [self.navigationController popViewControllerAnimated:YES];
            break;
        case buttonTag+1:
        {
            AdvancedSearchViewController *ad=[[AdvancedSearchViewController alloc]init];
            ad.str_Num = @"22";
            ad.firstFlag = 1;
            [self.navigationController pushViewController:ad animated:YES];
        }
            break;
        default:
            break;
    }
}

//请求服务器数据
- (void)Get_OrderList {
    if([Function isConnectionAvailable])
    {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.mode = MBProgressHUDModeIndeterminate;
        hud.labelText = @"加载中...";//加载提示语言
        
        if(app.isPortal)
        {
            urlString=[NSString stringWithFormat:@"%@%@",KPORTAL_URL,KGet_Order_Boss];
        }
        else
        {
            urlString=[NSString stringWithFormat:@"%@%@",kBASEURL,KGet_Order_Boss];
        }
        NSURL *url = [ NSURL URLWithString : urlString];
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
            [request setPostValue: [[Advance_Search sharedInstance].arr_search objectAtIndex:0] forKey:@"start_date"];
            [request setPostValue: [[Advance_Search sharedInstance].arr_search objectAtIndex:1] forKey:@"end_date"];
            if ([Function retuYES:[[Advance_Search sharedInstance].arr_search objectAtIndex:2]]) {
                [request setPostValue: app.str_temporary_valueH forKey:@"gbelongto"];
            }
            if ([Function retuYES:[[Advance_Search sharedInstance].arr_search objectAtIndex:3]]) {
                [request setPostValue: app.str_index_no forKey:@"user_index_no"];
            }
            [request setPostValue: [[Advance_Search sharedInstance].arr_search objectAtIndex:4] forKey:@"minOrsum"];
            [request setPostValue: [[Advance_Search sharedInstance].arr_search objectAtIndex:5] forKey:@"maxOrsum"];
            if ([Function retuYES:[[Advance_Search sharedInstance].arr_search objectAtIndex:6]]) {
                [request setPostValue: [NavView return_YES_Or_NO:[[Advance_Search sharedInstance].arr_search objectAtIndex:6]]
                               forKey:@"exe_sts"];
            }
        }
        else
        {
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

-(void)JsonString:(NSString *)jsonString
{
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    
    SBJsonParser *parser = [[SBJsonParser alloc] init];
    NSDictionary *dict =[parser objectWithString: jsonString];
    if([[dict objectForKey:@"ret"]isEqualToString:@"0"])
    {
        arr_ListData=[dict objectForKey:@"OrderList"];
        [self Is_Nothing];
        self.BossTableView.frame = CGRectMake(0, 44, 320, Phone_Height-44);
        [self.BossTableView reloadData];
    }
    else
    {
        [SGInfoAlert showInfo:@"获取订单列表失败"
                      bgColor:[[UIColor darkGrayColor] CGColor]
                       inView:self.view
                     vertical:0.5];
    }
    
    dict=nil;
}

-(void)Is_Nothing
{
    if(arr_ListData.count==0)
    {
        self.BossTableView.hidden = YES;
        [self.view addSubview:imageView_Face];
    }
    else
    {
        self.BossTableView.hidden = NO;
        [imageView_Face removeFromSuperview];
    }
}

#pragma mark ---- ASIRequest delegate method
-(void)requestFinished:(ASIHTTPRequest *)request
{
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    
    if([request responseStatusCode]==200)
    {
        NSString * jsonString  =  [request responseString];
        [self JsonString:jsonString];
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
}

#pragma mark ---- UITableView delegate and dataSouurce
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return arr_ListData.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    if(isPad)
        return 110;
    return 130;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SubmitOrderTableViewCell *cell=(SubmitOrderTableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"SubmitOrderTableViewCell"];
    if(cell==nil)
    {
        NSArray *nib;
        if(isPad)
        {
            nib= [[NSBundle mainBundle] loadNibNamed:@"SubmitOrderTableViewCell_ipad" owner:[SubmitOrderTableViewCell class] options:nil];
        }
        else
        {
            nib= [[NSBundle mainBundle] loadNibNamed:@"SubmitOrderTableViewCell" owner:[SubmitOrderTableViewCell class] options:nil];
        }
        cell = (SubmitOrderTableViewCell *)[nib objectAtIndex:0];
        cell.contentView.backgroundColor = [UIColor clearColor];
    }
    cell.backgroundColor=[UIColor clearColor];
    UIImageView *viewCell;
    viewCell=[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, Phone_Weight, 120)];
    viewCell.image=[UIImage imageNamed:@"cell_message_background@2X.png"]; //白色背景图片
    [cell insertSubview:viewCell atIndex:0];
    viewCell=nil;
    
    NSDictionary *dic=[arr_ListData objectAtIndex:indexPath.row];
    cell.personLabel.hidden = NO;
    cell.personLabel.text = [NSString stringWithFormat:@"下单人：%@",[dic objectForKey:@"uname"]];
    cell.lab_gname.text=[dic objectForKey:@"gname"];
    cell.lab_gcode.text=[dic objectForKey:@"index_no"];//订单编号
    cell.lab_count_number.text=[NSString stringWithFormat:@"%@%@",[dic objectForKey:@"odiscount"],@"%"];
    cell.offLineLabel.hidden = YES;
    if([[dic objectForKey:@"ctc_sts"]isEqualToString:@"0"]) //ctc_sts 0/不代收 1/代收
    {
        cell.img_isInstead.image=[UIImage imageNamed:@"cell_unimplement.png"]; //方块图片
    }
    else
    {
        cell.img_isInstead.image=[UIImage imageNamed:@"cell_implement.png"];   //对号方块图片
    }
    if([[dic objectForKey:@"exe_sts"]isEqualToString:@"0"])  //exe_sts 0/未执行 1/已执行
    {
        cell.img_exe_sts.image=[UIImage imageNamed:@"cell_unimplement.png"];
    }
    else
    {
        cell.img_exe_sts.image=[UIImage imageNamed:@"cell_implement.png"];
    }
    cell.lab_real.text=[NSString stringWithFormat:@"%@元",[dic objectForKey:@"orsum"]];
    cell.lab_should.text=[NSString stringWithFormat:@"%@元",[dic objectForKey:@"osum"]];
    cell.lab_time.text=[dic objectForKey:@"ins_date"];
    cell.img_am_pm.image=[UIImage imageNamed:[NavView returnPeriod:[dic objectForKey:@"ins_date"]]];
    cell.selectionStyle=UITableViewCellSelectionStyleNone;//无点击效果
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    OrderListViewController *order=[[OrderListViewController alloc]init];
    order.str_isfromeDetail=@"1";//是查看详细
    NSDictionary *dic=[arr_ListData objectAtIndex:indexPath.row];
    order.str_title=[NSString stringWithFormat:@"订单详细"];
    order.str_index_no=[dic objectForKey:@"index_no"];
    app.isApproval=NO;
    [self.navigationController pushViewController:order animated:YES];
    dic=nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
