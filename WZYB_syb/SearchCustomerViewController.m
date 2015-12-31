//
//  SearchCustomerViewController.m
//  WZYB_syb
//
//  Created by wzyb on 15-3-5.
//  Copyright (c) 2015年 WZYB. All rights reserved.
//

#import "SearchCustomerViewController.h"
#import "AppDelegate.h"
#import "RegisterCell.h"
#import "AddNewClerkOrRivalViewController.h"

@interface SearchCustomerViewController ()
{
    AppDelegate *app;
    NSString *urlString;
    NSArray *arr_Customer;//存储列表数据
    NSArray *arr_H12;//客户类型
}

@property(nonatomic,assign)BOOL isRival;//默认是新客户--->NO  YES 是竞争对手
@property (weak, nonatomic) IBOutlet UITableView *BossTableView;
@end

@implementation SearchCustomerViewController

- (void)Notify_AdvancedSearch {
    [self get_NewOrFighterList];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.showPushView = NO;
    [self addNavTItle:@"客户查询" flag:2];
    
    [[Advance_Search sharedInstance].arr_search removeAllObjects];
    app=(AppDelegate *)[[UIApplication sharedApplication]delegate];
    app.VC_searchCustomer = self;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];   //第一次进入时保存的字段(高级搜索时清空数据用)
    [defaults setObject:@"1" forKey:@"CLIST"];
    [defaults synchronize];
    
    NSDictionary *dic_H=[[BasicData sharedInstance].dic_BasicData objectForKey:@"MasterList"];
    arr_H12=[dic_H objectForKey:@"H12"];//所有的head
    
    app.str_Date = [Function getYearMonthDay_Now];
    
    [self Set_SegmentView];
    [self get_NewOrFighterList];
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
            ad.str_Num = @"24";
            ad.firstFlag = 1;
            [self.navigationController pushViewController:ad animated:YES];
        }
            break;
        default:
            break;
    }
}

-(NSString *)SettingURL_getAssessmentList:(NSString*)url
{
    NSString *string=[NSString stringWithFormat:@"%@%@",url,Boss_customer]; //1.0.4 修改接口
    return string;
}

-(NSString *)SettingURL_getListDetail:(NSString *)url
{
    NSString *string;
    if(!self.isRival)
    {
        string=[NSString stringWithFormat:@"%@%@",url,KGet_Detail0 ];
    }
    else
    {
        string=[NSString stringWithFormat:@"%@%@",url,KGet_Detail1 ];
    }
    return string;
}

-(void)get_JsonString:(NSString *)jsonString Type:(NSString*)type
{
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    SBJsonParser *parser = [[SBJsonParser alloc] init];
    NSDictionary *dict =[parser objectWithString: jsonString];
    if([[dict objectForKey:@"ret"]isEqualToString:@"0"])
    {
        arr_Customer=[dict objectForKey:@"CustomerList"];
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
    if(arr_Customer.count==0)
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

//  0  列表数据   1每行的查看详细
-(void)get_JsonString1:(NSString *)jsonString  Type:(NSString *)type
{
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    SBJsonParser *parser = [[SBJsonParser alloc] init];
    NSDictionary *dict =[parser objectWithString: jsonString];
    if([[dict objectForKey:@"ret"]isEqualToString:@"0"])
    {
        NSDictionary *dic=[dict objectForKey:@"CustomerInfo"];
        NSArray *arr=[dict objectForKey:@"MediaList"];
        [self To_DetailView_Info:dic Photo:arr AllData:dict];
    }
    else
    {
        if([type isEqual:@"0"])
        {
            NSString *str;
            if(self.isRival)
            {
                str=@"获取竞争对手列表失败";
            }
            else
            {
                str=@"获取新客户列表失败";
                
            }
            [SGInfoAlert showInfo:str
                          bgColor:[[UIColor darkGrayColor] CGColor]
                           inView:self.view
                         vertical:0.5];
        }
        else
        {
        }
    }
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
            urlString=[self SettingURL_getAssessmentList:KPORTAL_URL];
        }
        else
        {
            urlString=[self SettingURL_getAssessmentList:kBASEURL];
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
            NSString *customerStr = [NSString stringWithFormat:@"%ld",(long)app.customerNumber];
            [request setPostValue: [[Advance_Search sharedInstance].arr_search objectAtIndex:0] forKey:@"start_date"];
            [request setPostValue: [[Advance_Search sharedInstance].arr_search objectAtIndex:1] forKey:@"end_date"];
            if ([Function retuYES:[[Advance_Search sharedInstance].arr_search objectAtIndex:2]]) {
                [request setPostValue:customerStr forKey:@"gtype"];
            }
            if ([Function retuYES:[[Advance_Search sharedInstance].arr_search objectAtIndex:3]]) {
                [request setPostValue: app.str_temporary_valueH forKey:@"gbelongto"];
            }
            if ([Function retuYES:[[Advance_Search sharedInstance].arr_search objectAtIndex:4]]) {
                [request setPostValue: app.str_index_no forKey:@"user_index_no"];
            }

            [request setPostValue: [[Advance_Search sharedInstance].arr_search objectAtIndex:5] forKey:@"minGvolume"];
            [request setPostValue: [[Advance_Search sharedInstance].arr_search objectAtIndex:6] forKey:@"maxGvolume"];
            [request setPostValue: [[Advance_Search sharedInstance].arr_search objectAtIndex:7] forKey:@"minDays"];
            [request setPostValue: [[Advance_Search sharedInstance].arr_search objectAtIndex:8] forKey:@"maxDays"];
            
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

-(void)getListDetail:(NSString *)index_no
{
    if([Function isConnectionAvailable])
    {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.mode = MBProgressHUDModeIndeterminate;
        hud.labelText = @"加载中...";//加载提示语言
        
        if(app.isPortal)
        {
            urlString=[self SettingURL_getListDetail:KPORTAL_URL];
        }
        else
        {
            urlString=[self SettingURL_getListDetail:kBASEURL];
        }
        
        NSURL *url = [ NSURL URLWithString :  urlString];
        ASIFormDataRequest *request = [ ASIFormDataRequest requestWithURL :url];
        request.delegate = self;
        request.tag = 100;
        [request setRequestMethod:@"POST"];
        [request setPostValue:[[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"account"]forKey:KUSER_UID];
        [request setPostValue:[[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"secret"] forKey:KUSER_PASSWORD];
        [request setPostValue:[[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"token"] forKey:@"user.token"];
        [request setPostValue:[[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"db_ip"] forKey:@"db_ip"];
        [request setPostValue:[[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"db_name"] forKey:@"db_name"];
        
        [request setPostValue: index_no forKey:@"index_no"];
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

-(void)To_DetailView_Info:(NSDictionary *)dic Photo:(NSArray *)arr AllData:(NSDictionary *)data
{
    AddNewClerkOrRivalViewController * addVC=[[AddNewClerkOrRivalViewController alloc]init];
    NSString *str;
    if(self.isRival)
    {
        str=@"1";
    }
    else
    {
        str=@"0";
    }
    addVC.str_title=str;
    addVC.isDetail=YES;
    addVC.local = [dic objectForKey:@"local"];
    addVC.editFlag = 1;
    addVC.str_value1=[dic objectForKey:@"svtype"];//类型H12
    addVC.str_value2=[dic objectForKey:@"plevel"];//档次H4
    addVC.str_value3=[dic objectForKey:@"gcoopstate"];//状态H3
    
    addVC.str_tex0=[dic objectForKey:@"gname"];
    addVC.str_tex1=[self Calculate:@"H12" Value:[dic objectForKey:@"svtype"]];
    addVC.str_tex2=[dic objectForKey:@"gcontact"];
    
    addVC.str_tex3=[dic objectForKey:@"gtel"];
    addVC.str_tex4=[dic objectForKey:@"gvolume"];
    
    addVC.str_tex5=[self Calculate:@"H4" Value:[dic objectForKey:@"plevel"]];
    addVC.str_tex6=[self Calculate:@"H3" Value:[dic objectForKey:@"gcoopstate"]];
    
    addVC.str_tex7=[dic objectForKey:@"gaddress"];
    addVC.str_tex8= [dic objectForKey:@"gmail"];
    
    addVC.str_index_no=[dic objectForKey:@"index_no"];
    app.str_alat=[dic objectForKey:@"glat"];
    app.str_nlng=[dic objectForKey:@"glng"];
    
    if ([[dic objectForKey:@"local"] isEqualToString:@"1"]) {
        addVC.showLocalImage = YES;
        NSString *addressStr = [dic objectForKey:@"gaddress"];
        if (![addressStr isEqualToString:@"地址未知"]) {
            addVC.str_tex7 = addressStr;
        }else {
            addVC.addressFlag = 1;
        }
    }
    NSString *number = [dic objectForKey:@"tempIndexNumber"];
    if (number.length) {
        addVC.convertNumber = number;
    }
    addVC.dic_data_all=[NSDictionary dictionaryWithDictionary:data];
    
    [self.navigationController pushViewController: addVC animated:YES];
}

-(NSString *)Calculate:(NSString *)str_H Value:(NSString *)str_value
{
    NSDictionary *dic=[[BasicData sharedInstance].dic_BasicData objectForKey:@"MasterList"];
    NSArray *arr=[dic objectForKey:str_H];
    for(NSInteger i=0;i<arr.count;i++)
    {
        NSDictionary *dict=[arr objectAtIndex:i];
        if([[dict objectForKey:@"cvalue"] isEqualToString:str_value])
        {
            return [dict objectForKey:@"clabel"];
        }
    }
    return @"";
}

#pragma mark ---- ASIHttpRequest method
-(void)requestFinished:(ASIHTTPRequest *)request {
    if (request.tag == 100) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        if([request responseStatusCode]==200)
        {
            NSString * jsonString  =  [request responseString];
            [self get_JsonString1:jsonString  Type:@"1"];
        }
        else
        {
            [SGInfoAlert showInfo:@"发生异常,请稍后再试"
                          bgColor:[[UIColor darkGrayColor] CGColor]
                           inView:self.view
                         vertical:0.5];
            [NdUncaughtExceptionHandler Post_url:[NSString stringWithFormat:@"URL:%@,HTTP_Code%d",urlString,[request responseStatusCode]]];
        }
        return;
    }

    [MBProgressHUD hideHUDForView:self.view animated:YES];
    if([request responseStatusCode]==200)
    {
        NSString * jsonString  =  [request responseString];
        [self get_JsonString:jsonString  Type:@"1"];
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
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 120;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return arr_Customer.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    RegisterCell *cell=(RegisterCell*)[tableView dequeueReusableCellWithIdentifier:@"RegisterCell"];
    if(cell==nil)
    {
        NSArray *nib;
        if(isPad)
        {
            nib= [[NSBundle mainBundle] loadNibNamed:@"RegisterCell_ipad" owner:[RegisterCell class] options:nil];
        }
        else
        {
            nib= [[NSBundle mainBundle] loadNibNamed:@"RegisterCell" owner:[RegisterCell class] options:nil];
        }
        cell = (RegisterCell *)[nib objectAtIndex:0];
        cell.contentView.backgroundColor = [UIColor clearColor];
    }
    cell.backgroundColor=[UIColor clearColor];
    
    NSDictionary *dic=[arr_Customer objectAtIndex:indexPath.row];
    for(NSInteger i=0;i<arr_H12.count;i++)
    {
        NSDictionary *dicH=[arr_H12 objectAtIndex:i];
        if([[dicH objectForKey:@"cvalue"]isEqualToString:[dic objectForKey:@"svtype"]])
        {
            cell.label_CompanyName.text=[dicH objectForKey:@"clabel"];
            break;
        }
    }
    if([[dic objectForKey:@"gtype"]isEqualToString:@"0"])
    {//新客户
        cell.imageView_Head.image=[UIImage imageNamed:@"cell_clerk.png"];
    }
    else
    {
        cell.imageView_Head.image=[UIImage imageNamed:@"cell_competitor.png"];
    }
    if ([[dic objectForKey:@"local"] isEqualToString:@"1"]) {
        cell.label_CompanyName.backgroundColor = [UIColor colorWithRed:166.0/255.0 green:153.0/255.0  blue:163.0/255.0 alpha:1.0 ];
        cell.localLabel.hidden = NO;
    }else {
        cell.label_CompanyName.backgroundColor=[UIColor colorWithRed:238.0/255.0 green:138.0/255.0  blue:16.0/255.0 alpha:1.0 ];
    }
    cell.personLabel.hidden = NO;
    cell.personLabel.text = [NSString stringWithFormat:@"登记人：%@",[dic objectForKey:@"uname"]];
    cell.label_BusinessName.text=[dic objectForKey:@"gname"];
    cell.label_CompanyName.textAlignment=NSTextAlignmentCenter;
    cell.label_CompanyName.layer.cornerRadius=5.0;
    cell.label_adress.text=[dic objectForKey:@"gaddress"];
    cell.label_Date.text=[dic objectForKey:@"ins_date"];
    if ([Function StringIsNotEmpty:[dic objectForKey:@"gvolume"]]) {
        cell.label_Scale.text=[NSString stringWithFormat:@"规模:%@",[dic objectForKey:@"gvolume"]];
    }else {
        cell.label_Scale.text=@"规模:";
    }
    cell.selectionStyle=UITableViewCellSelectionStyleNone;//无点击效果
    dic=nil;
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *dic=[arr_Customer objectAtIndex:indexPath.row];
    self.isRival = [[dic objectForKey:@"gtype"] boolValue];
    if ([[dic objectForKey:@"local"] isEqualToString:@"1"]) {
        [self To_DetailView_Info:dic Photo:nil AllData:[dic objectForKey:@"tempDic"]];
        return;
    }
    [self getListDetail:[dic objectForKey:@"index_no"]];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
