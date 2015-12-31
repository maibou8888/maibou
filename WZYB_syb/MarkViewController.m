//
//  MarkViewController.m
//  WZYB_syb
//
//  Created by wzyb on 15-4-3.
//  Copyright (c) 2015年 WZYB. All rights reserved.
//

#import "MarkViewController.h"
#import "MarkCell.h"
#import "NoteViewController.h"
#import "AppDelegate.h"

@interface MarkViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    AppDelegate *app;
    NSInteger moment_status;
    NSArray *firstArray;
    UITableView *markTableView;
    NSIndexPath *myIndexPath;
    NSString *urlString;
    NSInteger FirstFlag;
}
@property (weak, nonatomic) IBOutlet UIButton *submitBtn;
- (IBAction)PressSubmitButton:(id)sender;
@end

@implementation MarkViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    
    //标题
    NavView *nav_View=[[NavView alloc]init];
    [self.view addSubview: [nav_View NavView_Title1:@"评价"]];
    app = (AppDelegate *)[UIApplication sharedApplication].delegate;
    
    //高度
    if(StatusBar_System>0)
        moment_status=20;
    else moment_status=0;
    
    app.markFlag = 1;
    
    //左边返回键
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
    
    //表格
    markTableView = [[UITableView alloc] initWithFrame:CGRectMake(10, 80, 300, 88)
                                                              style:UITableViewStylePlain];
    markTableView.bounces = NO;
    [markTableView.layer setMasksToBounds:YES];
    [markTableView.layer setCornerRadius:10.0];
    [markTableView setSeparatorColor:[UIColor clearColor]];
    markTableView.layer.borderColor = [UIColor colorWithRed:204/255.0 green:204/255.0 blue:204/255.0 alpha:1].CGColor;
    markTableView.layer.borderWidth = 1;
    
    markTableView.delegate = self;
    markTableView.dataSource = self;
    [self.view addSubview:markTableView];
    
    //提交按钮设置
    self.submitBtn.top = markTableView.bottom+40;
    [self.submitBtn.layer setMasksToBounds:YES];
    [self.submitBtn.layer setCornerRadius:5.0];
    
    FirstFlag = 1;
    urlString = [NSString string];
    firstArray = @[@"分值",@"备注"];
    if (self.secondArray.count != 2) {
        self.secondArray = [[NSMutableArray alloc] initWithObjects:@"",@"" ,nil];
     }
}

- (void)viewWillAppear:(BOOL)animated {
    if (!FirstFlag) {
        if (app.str_temporary) {
            [self.secondArray replaceObjectAtIndex:myIndexPath.row withObject:app.str_temporary];
            app.str_temporary = @"";
            [markTableView reloadData];
        }
    }
    FirstFlag = 0;
}

#pragma mark ---- UITableView delegate and datasource method
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MarkCell *cell=(MarkCell*)[tableView dequeueReusableCellWithIdentifier:@"MarkCell"];
    if(cell==nil)
    {
        NSArray *nib ;
        if(isPad)
        {
            nib= [[NSBundle mainBundle] loadNibNamed:@"MarkCell_ipad" owner:[MarkCell class] options:nil];
        }
        else
        {
            nib= [[NSBundle mainBundle] loadNibNamed:@"MarkCell" owner:[MarkCell class] options:nil];
        }
        
        cell = (MarkCell *)[nib objectAtIndex:0];
        cell.contentView.backgroundColor = [UIColor clearColor];
    }
    cell.firstLabel.text = [firstArray objectAtIndex:indexPath.row];
    cell.secondLabel.text = [self.secondArray objectAtIndex:indexPath.row];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    MarkCell *cell = (MarkCell *)[markTableView cellForRowAtIndexPath:indexPath];
    NoteViewController *noteVC =  [[NoteViewController alloc]init];
    noteVC.str_title = cell.firstLabel.text;
    noteVC.str_content = [self.secondArray objectAtIndex:indexPath.row];
    myIndexPath = indexPath;
    noteVC.isDetail = NO;
    [self.navigationController pushViewController:noteVC animated:YES];
}

#pragma mark ---- private method
-(void)btn_Action:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)PressSubmitButton:(id)sender {
#pragma mark ---- will write
    if([Function isConnectionAvailable])
    {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.mode = MBProgressHUDModeIndeterminate;
        hud.labelText = @"加载中...";//加载提示语言
        
        if(app.isPortal)
        {
            urlString = [NSString stringWithFormat:@"%@%@",KPORTAL_URL,Ksign_num];
        }
        else
        {
            urlString = [NSString stringWithFormat:@"%@%@",kBASEURL,Ksign_num];
        }
        
        NSURL *url = [ NSURL URLWithString:urlString];
        ASIFormDataRequest *request = [ ASIFormDataRequest requestWithURL :url];
        request.delegate = self;
        [request setRequestMethod:@"POST"];
        [request setPostValue:[[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"account"]forKey:KUSER_UID];
        [request setPostValue:[[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"secret"] forKey:KUSER_PASSWORD];
        [request setPostValue:[[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"token"] forKey:@"user.token"];
        [request setPostValue:[[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"db_ip"] forKey:@"db_ip"];
        [request setPostValue:[[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"db_name"] forKey:@"db_name"];
        
        [request setPostValue:self.req_index_no forKey:@"req_index_no"];
        [request setPostValue:[self.secondArray objectAtIndex:0] forKey:@"num_sign"];
        [request setPostValue:[self.secondArray objectAtIndex:1] forKey:@"memo"];
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

-(void)requestFinished:(ASIHTTPRequest *)request {
   
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    if([request responseStatusCode]==200)
    {
        [self.navigationController popViewControllerAnimated:YES];
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

@end
