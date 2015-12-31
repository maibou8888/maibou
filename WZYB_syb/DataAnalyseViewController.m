//
//  DataAnalyseViewController.m
//  WZYB_syb
//
//  Created by wzyb on 14-8-19.
//  Copyright (c) 2014年 WZYB. All rights reserved.
//

#import "DataAnalyseViewController.h"
#import "AnalysicCell.h"
#import "MMDrawerBarButtonItem.h"
#import "MMDrawerController.h"

@interface DataAnalyseViewController ()
{
    MMDrawerController *mmDrawVC;
    NSMutableArray *_topMutableArray;
    NSMutableArray *_bottomMutableArray;
    NSMutableArray *_imageViewmutArray;
}
@end

@implementation DataAnalyseViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
-(void)All_Init
{
    _topMutableArray    = [NSMutableArray array];
    _bottomMutableArray = [NSMutableArray array];
    
    _imageViewmutArray = [[NSMutableArray alloc] initWithObjects:
                          @"analy_custom.png",@"analy_hold.png",        @"analy_bind.png",      @"analy_money.png",
                          @"analy_people.png",@"analy_stru.png",        @"analy_peoAndGood.png",@"analy_goodAndMac.png",
                          @"analy_sale.png"  ,@"analy_oper.png",        @"analy_macMap.png",    @"analy_gpsMap.png"    , nil];
    
    NSArray *keyArray = @[@"customerAnalysis",@"customerAccessAnalysis",@"orderAnalysis",      @"financialAnalysis",
                          @"userAnalysis"    ,@"productAnalysis",       @"productUserAnalysis",@"productCustomerAnalysis",
                          @"activityAnalysis",@"operationAnalysis",     @"customerMap",        @"gpsMap"];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *tempDic    = [[NSDictionary alloc] initWithDictionary:[defaults objectForKey:@"TileTitle"]];
    
    for (NSInteger i = 0; i < keyArray.count; i ++) {
        NSDictionary *enumDic = [tempDic objectForKey:[keyArray objectAtIndex:i]];
        if (enumDic.count) {
            if ([[enumDic objectForKey:@"authority"] isEqualToString:@"1"]) {
                [_topMutableArray addObject:[enumDic objectForKey:@"title"]];
                [_bottomMutableArray addObject:[enumDic objectForKey:@"description"]];
            }
        }
    }
    
    if(StatusBar_System>0)
        moment_status=20;
    else moment_status=0;
    NavView *nav_View=[[NavView alloc]init];
    [self.view addSubview: [nav_View NavView_Title1:@"企业分析"]];
    
    CGRect scrollViewFrame = CGRectMake(0,moment_status+44, Phone_Weight, Phone_Height-moment_status-44-TabbarHeight);
    self.scrollView = [[UIScrollView alloc] initWithFrame:scrollViewFrame];
    self.scrollView.contentSize=CGSizeMake(0, 66*_topMutableArray.count);
    [self.view addSubview:self.scrollView];
    
    self.myTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, 66*_topMutableArray.count)
                                                    style:UITableViewStylePlain];
    self.myTableView.delegate = self;
    self.myTableView.dataSource = self;
    [self.scrollView addSubview:self.myTableView];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(12,31, 40, 22);
    if (isIOS6) {
        button.top = 11;
    }
    [button setImage:ImageName(@"draw") forState:UIControlStateNormal];
    [button addTarget:self action:@selector(leftDrawerButtonPress) forControlEvents:UIControlEventTouchUpInside];
    [nav_View.view_Nav addSubview:button];
}

-(void)Creat_data
{
    NSArray *urlArray  = @[KAn_term,KAn_term_man,KAn_ord,KAn_fin,KAn_emp,KAn_prod,
                           KAn_prod_emp,KAn_prod_t,KMa_Do,KAn_ope,KMap,KGps];
    arr_List=[NSMutableArray arrayWithCapacity:urlArray.count];
    
    for (NSInteger i = 0; i <urlArray.count; i ++) {
        NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithCapacity:urlArray.count];
        [dic setObject:[self String_To_UrlString:[urlArray objectAtIndex:i]] forKey:@"url"];
        [arr_List addObject:dic];
    }
}

-(NSString *)String_To_UrlString:(NSString*)string
{
    NSString *urlString = [[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"portal_url"];
    if ([Function StringIsNotEmpty:urlString]) {
        NSString *str=[NSString stringWithFormat:@"%@%@&user.uid=%@&user.password=%@&user.token=%@",urlString,string,[[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"account"],[[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"secret"],[[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"token"]];
        return str;
    }
    NSString *str=[NSString stringWithFormat:@"%@%@&user.uid=%@&user.password=%@&user.token=%@",kBASEURL,string,[[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"account"],[[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"secret"],[[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"token"]];
    return str;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self All_Init];
    [self Creat_data];
}

- (void)leftDrawerButtonPress {
    [self returnMMDrawVC];
    [mmDrawVC toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
}

- (void)returnMMDrawVC {
    if (mmDrawVC != nil) {
        return;
    }
    mmDrawVC = (MMDrawerController*)self.parentViewController.parentViewController;
}

-(void)btn_Action:(id)sender
{
    UIButton *btn=(UIButton *)sender;
    if(btn.tag==buttonTag+4)//返回
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark ---- UITableView delegate and dataSource method
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _topMutableArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    AnalysicCell *cell=(AnalysicCell*)[tableView dequeueReusableCellWithIdentifier:@"AnalysicCell"];
    if(cell==nil)
    {
        NSArray *nib ;
        nib= [[NSBundle mainBundle] loadNibNamed:@"AnalysicCell" owner:[AnalysicCell class] options:nil];
        cell = (AnalysicCell *)[nib objectAtIndex:0];
        cell.contentView.backgroundColor = [UIColor clearColor];
    }
    cell.analyImageView.frame = CGRectMake(20, 13, 40, 40);
    cell.analyImageView.image = ImageName([_imageViewmutArray objectAtIndex:indexPath.row]);
    cell.analytopLabel.text = [_topMutableArray objectAtIndex:indexPath.row];
    cell.analybottomLabel.text = [_bottomMutableArray objectAtIndex:indexPath.row];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    AnalysicCell *anaCell = (AnalysicCell *)[self.myTableView cellForRowAtIndexPath:indexPath];
    NSString *titleString = anaCell.analytopLabel.text;
    NSDictionary *dic=[arr_List objectAtIndex:indexPath.row];
    
    DocumentViewController *docVC=[[DocumentViewController alloc]init];
    docVC.titleString=titleString;
    docVC.str_Url=[dic objectForKey:@"url"];
    docVC.str_isGraph=@"1";
    [self.navigationController pushViewController:docVC animated:YES];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 66;
}

@end
