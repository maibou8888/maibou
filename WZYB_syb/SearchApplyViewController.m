//
//  SearchApplyViewController.m
//  WZYB_syb
//
//  Created by wzyb on 15-3-5.
//  Copyright (c) 2015年 WZYB. All rights reserved.
//

#import "SearchApplyViewController.h"
#import "AdvancedSearchViewController.h"
#import "AppDelegate.h"
#import "KxMenu.h"

@interface SearchApplyViewController ()
{
    AppDelegate *app;
    NSString *urlString;
    NSArray *arr_AssessList;//存储列表数据
    NSArray *arr_H9;//审批类型
    NSString* selectString;
    NSDictionary* allDynamicDic;
}
@property (weak, nonatomic) IBOutlet UITableView *BossTableView;
@end

@implementation SearchApplyViewController

- (void)Notify_AdvancedSearch {
    [self getAssessmentList];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.showPushView = NO;
    [self addNavTItle:@"申请查询" flag:2];
    
    [[Advance_Search sharedInstance].arr_search removeAllObjects];
    app=(AppDelegate *)[[UIApplication sharedApplication]delegate];
    app.VC_searchApply = self;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];   //第一次进入时保存的字段(高级搜索时清空数据用)
    [defaults setObject:@"1" forKey:@"ALIST"];
    [defaults synchronize];
    
    NSDictionary *dic=[[BasicData sharedInstance].dic_BasicData objectForKey:@"MasterList"];
    arr_H9=[dic objectForKey:@"H9"];
    
    selectString = [NSString string];
    
    [self Set_SegmentView];
    [self getAssessmentList];
    [self GetAllApply_dynamic];
}

#pragma mark --- custom Action method
-(void)Set_SegmentView
{
    for(NSInteger i=0;i<2;i++)
    {
        UIButton *btn=[UIButton buttonWithType:UIButtonTypeCustom];
        if(i==0)//返回
        {
            btn.tag=buttonTag+i;
            btn.frame=CGRectMake(0, moment_status, 60, 44);
            btn.backgroundColor=[UIColor clearColor];
            [btn setBackgroundImage:[UIImage imageNamed:@"btn_color6.png"] forState:UIControlStateHighlighted];
            [btn setTitle:@"< 返回" forState:UIControlStateNormal];
            [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            btn.titleLabel.font=[UIFont systemFontOfSize:15];
            [btn addTarget:self action:@selector(btn_Action:) forControlEvents:UIControlEventTouchUpInside ];
        }
        else  if(i==1) //日历
        {
            btn.backgroundColor=[UIColor clearColor];
            btn.frame=CGRectMake(Phone_Weight*0.5-44, moment_status, 44*2.5, 44);
            [btn setBackgroundImage:[UIImage imageNamed:@"nav_menu_arrow_back.png"] forState:UIControlStateHighlighted];
            [btn addTarget:self action:@selector(_refreshButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        }
        [self.view addSubview:btn];
    }
}

-(void)btn_Action:(id)sender {
    UIButton *btn=(UIButton *)sender;
    switch (btn.tag) {
        case buttonTag:
            [self.navigationController popViewControllerAnimated:YES];
            break;
        default:
            break;
    }
}

//下拉列表
- (void)_refreshButtonAction:(UIButton*)sender
{
    NSDictionary* dic = [[BasicData sharedInstance].dic_BasicData objectForKey:@"MasterList"];
    NSMutableArray* buttonArray = [NSMutableArray array];
    NSArray* H9Array = [dic objectForKey:@"H9"];
    for (NSDictionary* tempDic in H9Array) {
        KxMenuItem* item = [KxMenuItem menuItem:[tempDic objectForKey:@"clabel"]
                                          image:nil
                                         target:self
                                         action:@selector(pushMenuItem:)];
        [buttonArray addObject:item];
    }
    
    KxMenuItem* item = [KxMenuItem menuItem:@"全部类型"
                                      image:nil
                                     target:self
                                     action:@selector(pushMenuItem:)];
    [buttonArray addObject:item];
    
    [KxMenu showMenuInView:self.view
                  fromRect:sender.frame
                 menuItems:buttonArray];
}

//下拉列表action
- (void)pushMenuItem:(id)sender
{
    KxMenuItem* menu = (KxMenuItem*)sender;
    
    AdvancedSearchViewController* ad = [[AdvancedSearchViewController alloc] init];
    ad.str_Num = @"23";
    ad.firstFlag = 1;
    
    if (![selectString isEqualToString:menu.title]) {
        selectString = [NSString stringWithFormat:@"%@", menu.title];
        [[Advance_Search sharedInstance].arr_search removeAllObjects];
    }
    
    if ([menu.title isEqualToString:@"全部类型"]) {
        ad.allTypeFlag = 1;
        ad.applyType = @"全部类型";
    }
    else {
        ad.dynamic_customer = [allDynamicDic objectForKey:[NavView return_index_H:@"H9" Label:menu.title]];
        ad.applyType = menu.title;
    }
    
    [self.navigationController pushViewController:ad animated:YES];
}

//获取全部申请动态项目
- (void)GetAllApply_dynamic
{
    if ([Function isConnectionAvailable]) {
        MBProgressHUD* hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.mode = MBProgressHUDModeIndeterminate;
        hud.labelText = @"加载中..."; //加载提示语言
        
        if (app.isPortal) {
            urlString = [NSString stringWithFormat:@"%@%@", KPORTAL_URL, KAllApplyDynamic];
        }
        else {
            urlString = [NSString stringWithFormat:@"%@%@", kBASEURL, KAllApplyDynamic];
        }
        NSURL* url = [NSURL URLWithString:urlString];
        ASIFormDataRequest* request = [ASIFormDataRequest requestWithURL:url];
        request.delegate = self;
        request.tag = 101;
        [request setRequestMethod:@"POST"];
        [request setPostValue:[[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"account"] forKey:KUSER_UID];
        [request setPostValue:[[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"secret"] forKey:KUSER_PASSWORD];
        [request setPostValue:[[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"token"] forKey:@"user.token"];
        [request setPostValue:[[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"db_ip"] forKey:@"db_ip"];
        [request setPostValue:[[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"db_name"] forKey:@"db_name"];
        [request startAsynchronous]; //异步
    }
    else {
        [SGInfoAlert showInfo:@"当前网络不可用，请检查网络连接"
                      bgColor:[[UIColor darkGrayColor] CGColor]
                       inView:self.view
                     vertical:0.5];
    }
}

-(void)getAssessmentList
{
    if([Function isConnectionAvailable])
    {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.mode = MBProgressHUDModeIndeterminate;
        hud.labelText = @"加载中...";//加载提示语言
        if(app.isPortal&&[app.assessSearch isEqualToString:@"0"])
        {
            urlString=[self SettingURL_getAssessmentList:KPORTAL_URL];
        }
        else
        {
            urlString=[self SettingURL_getAssessmentList:kBASEURL];
        }
        NSURL *url = [ NSURL URLWithString:urlString];
        ASIFormDataRequest *request = [ ASIFormDataRequest requestWithURL :url];
        request.delegate = self;
        [request setPostValue:[[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"account"]forKey:KUSER_UID];
        [request setPostValue:[[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"secret"] forKey:KUSER_PASSWORD];
        [request setPostValue:[[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"token"] forKey:@"user.token"];
        [request setPostValue:[[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"db_ip"] forKey:@"db_ip"];
        [request setPostValue:[[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"db_name"] forKey:@"db_name"];
        
        if([Advance_Search sharedInstance].arr_search.count>0) {
            [request setPostValue: [[Advance_Search sharedInstance].arr_search objectAtIndex:0]
                           forKey:@"start_date"];
            [request setPostValue: [[Advance_Search sharedInstance].arr_search objectAtIndex:1]
                           forKey:@"end_date"];
            if ([[[Advance_Search sharedInstance].arr_search objectAtIndex:2] isEqualToString:@"全部类型"]) {
                [request setPostValue:[NavView return_index_H:@"H9" Label:@""] forKey:@"rtype"];
            }
            else {
                [request setPostValue:[NavView return_index_H:@"H9" Label:[[Advance_Search sharedInstance].arr_search objectAtIndex:2]] forKey:@"rtype"];
            }
            if ([Function retuYES:[[Advance_Search sharedInstance].arr_search objectAtIndex:3]]) {
                [request setPostValue: app.str_temporary_valueH
                               forKey:@"gbelongto"];
            }
            if ([Function retuYES:[[Advance_Search sharedInstance].arr_search objectAtIndex:4]]) {
                [request setPostValue: app.personIndex1
                               forKey:@"user_index_no"];
            }
            if ([Function retuYES:[[Advance_Search sharedInstance].arr_search objectAtIndex:5]]) {
                [request setPostValue: [NavView return_index_H:@"H10" Label:[[Advance_Search sharedInstance].arr_search objectAtIndex:5]]
                               forKey:@"exe_sts"];
            }
            
            [request setPostValue:app.personIndex2 forKey:@"relations"];
            [request setPostValue: [[Advance_Search sharedInstance].arr_search objectAtIndex:6]
                           forKey:@"minOrsum"];
            [request setPostValue: [[Advance_Search sharedInstance].arr_search objectAtIndex:7]
                           forKey:@"maxOrsum"];
            
            for (int i = 0; i < app.mutDynDic.count; i++) {
                NSString* tempStr = [[Advance_Search sharedInstance].arr_search objectAtIndex:9 + i];
                NSDictionary* tempDic = [app.mutDynDic objectAtIndex:i];
                if ([Function StringIsNotEmpty:tempStr]) {
                    NSString* tempKey0 = [NSString stringWithFormat:@"dynamicList[%d].tindex_no", i];
                    NSString* tempKey1 = [NSString stringWithFormat:@"dynamicList[%d].data_type", i];
                    NSString* tempKey2 = nil;
                    if ([[tempDic objectForKey:@"rcontent"] integerValue]) {
                        tempKey2 = [NSString stringWithFormat:@"dynamicList[%d].rcontent", i];
                    }
                    else {
                        tempKey2 = [NSString stringWithFormat:@"dynamicList[%d].tcontent", i];
                    }
                    
                    [request setPostValue:[tempDic objectForKey:@"index_no"] forKey:tempKey0];
                    [request setPostValue:[tempDic objectForKey:@"data_type"] forKey:tempKey1];
                    [request setPostValue:tempStr forKey:tempKey2];
                }
            }
        }else {
            [request setPostValue: [Function getYearMonthDay_Now] forKey:@"start_date"];
            [request setPostValue: [Function getYearMonthDay_Now] forKey:@"end_date"];
        }
        [request startAsynchronous ];
    }
    else
    {
        [SGInfoAlert showInfo:@"当前网络不可用，请检查网络连接"
                      bgColor:[[UIColor darkGrayColor] CGColor]
                       inView:self.view
                     vertical:0.5];
    }
}

-(NSString *)SettingURL_getAssessmentList:(NSString*)url
{
    NSString *string=[NSString stringWithFormat:@"%@%@",url,Boss_apply]; //1.0.4 修改接口
    return string;
}

-(void)get_JsonString:(NSString *)jsonString Type:(NSString*)type
{
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    SBJsonParser *parser = [[SBJsonParser alloc] init];
    NSDictionary *dict =[parser objectWithString: jsonString];
    if([[dict objectForKey:@"ret"]isEqualToString:@"0"])
    {
        arr_AssessList=[dict objectForKey:@"ApplyList"];
        self.BossTableView.frame = CGRectMake(0, 44, 320, Phone_Height-44);
        [self.BossTableView reloadData];
        [self Is_Nothing];
    }
    else
    {
        NSString *str;
        if([type isEqual:@"0"])
        {
            str=@"获取待办审批列表失败";
        }
        else
        {
            str=@"获取申请事项列表表失败";
        }
        [SGInfoAlert showInfo:str
                      bgColor:[[UIColor darkGrayColor] CGColor]
                       inView:self.view
                     vertical:0.5];
    }
}

-(void)Is_Nothing
{
    if(arr_AssessList.count==0)
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

#pragma mark ---- ASIHttpRequest method
-(void)requestFinished:(ASIHTTPRequest *)request {
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    if([request responseStatusCode]==200)
    {
        if (request.tag == 101) {
            NSString* jsonString = [request responseString];
            SBJsonParser* parser = [[SBJsonParser alloc] init];
            NSDictionary* dict = [parser objectWithString:jsonString];
            if ([[dict objectForKey:@"ret"] isEqualToString:@"0"]) {
                allDynamicDic = [dict objectForKey:@"DynamicList"];
                return;
            }
        }

        NSString * jsonString  =  [request responseString];
        [self get_JsonString:jsonString Type:@"0"];
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

#pragma mark ---- UITableView delegate and dataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return arr_AssessList.count;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 120;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    Assess1TableViewCell *cell=(Assess1TableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"Assess1TableViewCell"];
    if(cell==nil)
    {
        NSArray *nib;
        nib= [[NSBundle mainBundle] loadNibNamed:@"Assess1TableViewCell" owner:[AssessViewCell class] options:nil];
        
        cell = (Assess1TableViewCell *)[nib objectAtIndex:0];
        cell.contentView.backgroundColor = [UIColor clearColor];
    }
    cell.backgroundColor=[UIColor clearColor];
    UIImageView *viewCell;
    viewCell=[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, Phone_Weight, 120)];
    viewCell.image=[UIImage imageNamed:@"cell_message_background@2X.png"];
    [cell insertSubview:viewCell atIndex:0];
    viewCell=nil;
    
    NSDictionary *dic=[arr_AssessList objectAtIndex:indexPath.row];
    cell.personLabel.hidden = NO;
    cell.personLabel.text = [NSString stringWithFormat:@"申请人：%@",[dic objectForKey:@"uname"]];
    cell.personLabel.top = 34;
    cell.lab_content.top = 44;
    cell.lab_content.text=[dic objectForKey:@"rcontent"];
    cell.lab_date.text=[dic objectForKey:@"ins_date"];
    cell.lab_applyMoney.text=[NSString stringWithFormat:@"%@元",[dic objectForKey:@"rsum"]];
    cell.img_status.image=[UIImage imageNamed:[self return_AssessStatus:[dic objectForKey:@"exe_sts"]]];
    for (NSInteger i=0; i<arr_H9.count; i++)
    {
        NSDictionary *dict=[arr_H9 objectAtIndex:i];
        if([[dict objectForKey:@"cvalue"] isEqualToString:[dic objectForKey:@"rtype"]])
        {
            cell.lab_type.text=[dict objectForKey:@"clabel"];
            break;
        }
        dict=nil;
    }
    cell.lab_type.backgroundColor=[UIColor colorWithRed:37.0/255.0 green:101.0/255.0  blue:171.0/255.0 alpha:1.0 ];
    cell.lab_type.layer.cornerRadius=5.0;
    cell.lab_type.textAlignment=NSTextAlignmentCenter;
    cell.lab_type.textColor=[UIColor whiteColor];
    cell.lab_assessNumb.text=[NSString stringWithFormat:@"申请编号:%@",[dic objectForKey:@"index_no"]];
    dic=nil;
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *dic=[arr_AssessList objectAtIndex:indexPath.row];
    AssessmentDetailViewController *assVC=[[AssessmentDetailViewController alloc]init];
    assVC.str_index_no=[dic objectForKey:@"index_no"];
    
    if([[dic objectForKey:@"rtype"]isEqualToString:@"0"])//判断是否是物料申请
    {
        assVC.isMaterial=YES;
    }
    assVC.isFromWillAssess=NO;
    assVC.str_title=@"申请事项";
    assVC.str_req_index_no=[dic objectForKey:@"index_no"];
    
    for (NSInteger i=0; i<arr_H9.count; i++) {
        NSDictionary *dict=[arr_H9 objectAtIndex:i];
        if([[dict objectForKey:@"cvalue"] isEqualToString:[dic objectForKey:@"rtype"]])
        {
            assVC.str_type=[dict objectForKey:@"clabel"];
            
            break;
        }
        dict=nil;
    }
    dic=nil;
    
    assVC.ShowBtnFlag = 1;
    [self.navigationController pushViewController:assVC animated:YES];
    
}
-(NSString *)return_AssessStatus:(NSString *)str
{
    if([str isEqualToString:@"3"])
    {
        return @"cell_assess1_3.png";
    }
    else  if([str isEqualToString:@"1"])
    {//拒绝
        return @"cell_assess1_1.png";
    }
    else  if([str isEqualToString:@"2"])
    {
        return @"cell_assess1_2.png";
    }
    return @"cell_assess1_0.png";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
