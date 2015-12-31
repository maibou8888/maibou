//
//  SearchSignViewController.m
//  WZYB_syb
//
//  Created by wzyb on 15-3-6.
//  Copyright (c) 2015年 WZYB. All rights reserved.
//

#import "SearchSignViewController.h"
#import "AppDelegate.h"

@interface SearchSignViewController ()
{
    AppDelegate *app;
    NSString *urlString;
    NSArray *arr_VistData;//存储列表数据
}
@property (weak, nonatomic) IBOutlet UITableView *BossTableView;

@end

@implementation SearchSignViewController

- (void)Notify_AdvancedSearch {
    [self get_SignData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.showPushView = NO;
    [self addNavTItle:@"考勤查询" flag:2];
    
    [[Advance_Search sharedInstance].arr_search removeAllObjects];
    app=(AppDelegate *)[[UIApplication sharedApplication]delegate];
    app.VC_searchSign = self;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];   //第一次进入时保存的字段(高级搜索时清空数据用)
    [defaults setObject:@"1" forKey:@"SLIST"];
    [defaults synchronize];
    
    [self Set_SegmentView];
    [self get_SignData];
}

#pragma mark --- custom Action method
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
            ad.str_Num = @"25";
            ad.firstFlag = 1;
            [self.navigationController pushViewController:ad animated:YES];
        }
            break;
        default:
            break;
    }
}

-(void)Is_Nothing
{
    if(arr_VistData.count==0)
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

-(void)get_SignData
{
    if([Function isConnectionAvailable])
    {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.mode = MBProgressHUDModeIndeterminate;
        hud.labelText = @"加载中...";//加载提示语言
        
        if(app.isPortal)
        {
            urlString = [NSString stringWithFormat:@"%@%@",KPORTAL_URL,Boss_sign];
        }
        else
        {
            urlString = [NSString stringWithFormat:@"%@%@",kBASEURL,Boss_sign];
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
        if([Advance_Search sharedInstance].arr_search.count>0)
        {
            [request setPostValue: [[Advance_Search sharedInstance].arr_search objectAtIndex:0] forKey:@"start_date"];
            [request setPostValue: [[Advance_Search sharedInstance].arr_search objectAtIndex:1] forKey:@"end_date"];
            if ([Function retuYES:[[Advance_Search sharedInstance].arr_search objectAtIndex:2]]) {
                [request setPostValue:app.BSAddress forKey:@"customer_index_no"];
            }
            if ([Function retuYES:[[Advance_Search sharedInstance].arr_search objectAtIndex:3]]) {
                [request setPostValue: app.str_temporary_valueH forKey:@"gbelongto"];
            }
            if ([Function retuYES:[[Advance_Search sharedInstance].arr_search objectAtIndex:4]]) {
                [request setPostValue: app.str_index_no forKey:@"user_index_no"];
            }

            [request setPostValue:[NavView return_SignStatus:[[Advance_Search sharedInstance].arr_search objectAtIndex:5]]
                           forKey:@"gps_result"];
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

#pragma mark ---- ASIHttpRequest method
-(void)requestFinished:(ASIHTTPRequest *)request {
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    if([request responseStatusCode]==200){
        NSString * jsonString  =  [request responseString];
        SBJsonParser *parser = [[SBJsonParser alloc] init];
        NSDictionary *dict =[parser objectWithString: jsonString];
        arr_VistData = [dict objectForKey:@"AccessList"];
        self.BossTableView.frame = CGRectMake(0, 44, 320, Phone_Height-44);
        [self.BossTableView reloadData];
        [self Is_Nothing];
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
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return arr_VistData.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    return 120;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    VisitCell *cell=(VisitCell*)[tableView dequeueReusableCellWithIdentifier:@"VisitCell"];
    if(cell==nil)
    {
        NSArray *nib;
        if(isPad)
        {
            nib = [[NSBundle mainBundle] loadNibNamed:@"VisitCell_ipad" owner:[VisitCell class] options:nil];
        }
        else
        {
            nib = [[NSBundle mainBundle] loadNibNamed:@"VisitCell" owner:[VisitCell class] options:nil];
        }
        cell = (VisitCell *)[nib objectAtIndex:0];
        cell.contentView.backgroundColor = [UIColor clearColor];
    }
    cell.backgroundColor=[UIColor clearColor];
    NSDictionary *dic=[arr_VistData objectAtIndex:indexPath.row];
    cell.userLabel.hidden = NO;
    cell.userLabel.text = [NSString stringWithFormat:@"考勤员工:%@",[dic objectForKey:@"uname"]];
    cell.label_CompanyName.text=[dic objectForKey:@"gname"];
    cell.label_during.text=[dic objectForKey:@"access_time"];
    cell.label_SignUp_time.text=[dic objectForKey:@"access_start_date"];
    cell.label_SignOut_time.text=[dic objectForKey:@"access_end_date"];
    /*
     gps_result
     0:疑似地址不匹配
     1:到达已签到
     2:到达未签退
     3:签到成功 签到和签退的流程已结束 gps_result为3
     -1:终端无坐标
     */
    cell.imageView_status.image=[UIImage imageNamed:[NSString stringWithFormat:@"%@.png",[self return_signUpStatus:[dic objectForKey:@"gps_result"]]]];
    NSArray *array = [[dic objectForKey:@"access_start_date"] componentsSeparatedByString:@" "]; //寻访日期
    NSString *date=[array objectAtIndex:0];
    NSString *today=[Function getYearMonthDay_Now];
    if([[dic objectForKey:@"gps_result"] isEqualToString:@"1"]&&[date isEqualToString:today])
    {
        cell.imageView_tap.image=[UIImage imageNamed:@"cell_right_arrow.png"];
    }
    else
    {

    }
    cell.selectionStyle=UITableViewCellSelectionStyleNone;//无点击效果
    return cell;
}
-(NSString*)return_signUpStatus:(NSString *)str
{
    /*
     gps_result
     0:疑似地址不匹配
     1:到达已签到
     2:到达未签退
     3:签到成功
     -1:终端无坐标
     */
    if([str isEqualToString:@"-1"])
    {
        return @"cell_sign-1";
    }
    else if([str isEqualToString:@"1"])
    {
        return @"cell_sign1";//到达已签到
    }
    else if([str isEqualToString:@"2"])
    {
        return @"cell_sign2";
    }
    else if([str isEqualToString:@"3"])
    {
        return @"cell_sign3";
    }
    else //0
    {
        return @"cell_sign0";
    }
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
/*
    //只有当gps_result为1的时候（即到达已签到）才能点击
    NSDictionary *dic=[arr_VistData objectAtIndex:indexPath.row];
    NSArray *array = [[dic objectForKey:@"access_start_date"] componentsSeparatedByString:@" "];
    NSString *date=[array objectAtIndex:0];
    NSString *today=[Function getYearMonthDay_Now];
    if([[dic objectForKey:@"gps_result"] isEqualToString:@"1"]&&[today isEqualToString:date])//到达已签到
    {
        SignInViewController *signVC=[[SignInViewController alloc]initWithNibName:@"SignInViewController" bundle:nil ];
        signVC.str_isFrom_More=@"1";//巡访
        app.VC_notify=signVC;
        signVC.is_QR=NO;
        app.str_atu=[dic objectForKey:@"atu"];
        [self.navigationController pushViewController:signVC animated:YES];
    }
 */
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
