//
//  OrderListViewController.m
//  WZYB_syb
//
//  Created by wzyb on 14-6-27.
//  Copyright (c) 2014年 WZYB. All rights reserved.
//

#import "OrderListViewController.h"
#import "OrderListCell.h"
#import "AppDelegate.h"
#import "ZBarSDK.h"
#define menu_sub 0
@interface OrderListViewController ()<ASIHTTPRequestDelegate,UIActionSheetDelegate,ZBarReaderDelegate>
{
    AppDelegate *app;
    NSString *urlString;
    ZbarCustomVC * reader;
    BOOL isChoose;//是否去扫码或者选择列表项  YES 是
    BOOL chooseBack;
}

@property (strong, nonatomic)NSString *str_QR_url;
@property (strong, nonatomic) IBOutlet UILabel *totalInfoLab;

@end
/*
 物料 取消 返回时候逻辑处理
 取消 或者返回
 */
@implementation OrderListViewController
@synthesize dic_json=dic_json;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self All_Init];
    [self theMenu];//构建菜单明细
    
     str_isInstead=@"0";//默认 不代收 “否”
    if(![self.str_isfromeDetail isEqualToString:@"1"]&&!app.isApproval&&!self.localFlag)
    {
        if([Function isConnectionAvailable]) {
            if (self.returnFlag) {
                [self getReturnDynamicList];
            }else {
                [self get_OrderDynamic];
            }
        }
        if (app.dic_json.count || app.dic_json1.count) {
            self.isDynamic=YES;
            if (self.returnFlag) {
                self.dic_json=app.dic_json1;
            }else {
                self.dic_json=app.dic_json;
            }
            [btn_submit setImage:[UIImage imageNamed:@"icon_orderList_Next.png"] forState:UIControlStateNormal]; //下一步
        }
    }
    lab_should.adjustsFontSizeToFitWidth = YES;
    lab_real.adjustsFontSizeToFitWidth = YES;
    lab_discount.adjustsFontSizeToFitWidth=YES;
    
    if (self.returnFlag || self.HIDFlag) {
        self.totalInfoLab.text = @"退单合计信息";
    }
}
-(void)viewWillAppear:(BOOL)animated
{
    if (self.returnFlag == 1 || self.HIDFlag == 1) {
        label_RealWords.text=@"实付合计:";
    }else {
        label_RealWords.text=@"实收合计:";
    }
   
   if([self.str_isfromeDetail isEqualToString:@"1"])
   {
       btn_Add.hidden=YES;
       if(!isDetail_FirstOpen)
       {
            //点击我的订单cell进入订单详细的时候调用
           if (self.returnFlag) {
               [self getROrderList];
           }else {
              [self getOrderList];
           }
           isDetail_FirstOpen=YES;
       }
   }
   else
   {//0 名称 1 型号 2 地方 3 单价 4 实收单价 5 数量 6 应收 7实收 8单位
       if (self.localFlag && ![AddProduct sharedInstance].arr_AddToList.count) {
           self.isDynamic = YES;
           arr_list = [self.dataDic objectForKey:@"AddProduct"];
           for (int i = 0; i < arr_list.count; i ++) {
               [[AddProduct sharedInstance].arr_AddToList addObject:[arr_list objectAtIndex:i]];
           }
           app.tempOrderArray = [[NSArray alloc] initWithArray:arr_list];
           float a=[[self.dataDic objectForKey:@"osum"] floatValue];
           float b=[[self.dataDic objectForKey:@"orsum"] floatValue];
           lab_should.text=[NSString stringWithFormat:@"%.2f元",a];
           lab_real.text=[NSString stringWithFormat:@"%.2f元",b];
           lab_discount.text=[NSString stringWithFormat:@"%.0f%@",b/a*100,@"%"];
           
           if ([[self.dataDic objectForKey:@"ctc_sts"] isEqualToString:@"0"]) {
               str_isInstead = @"0";
               [btn_switch setBackgroundImage:[UIImage imageNamed:@"switchOne_off.png"] forState:UIControlStateNormal];
           }else {
               str_isInstead = @"1";
               [btn_switch setBackgroundImage:[UIImage imageNamed:@"switchOne_on.png"] forState:UIControlStateNormal];
           }
           [btn_submit setImage:[UIImage imageNamed:@"icon_orderList_more.png"] forState:UIControlStateNormal];
           btn_switch.enabled = YES;
       }else {
           arr_list = [AddProduct sharedInstance].arr_AddToList;
           app.tempOrderArray = [[NSArray alloc] initWithArray:arr_list];
           [self Account_List];
       }
       [tableView_orderList reloadData];
       [self Is_Nothing];
       [self The_Menu_Opened];
   }
   if(app.isApproval)
   {
       label_ShouldTitle.text=@"合计:";
       label_ShouldTitle.textAlignment=NSTextAlignmentCenter;
       lab_real.hidden=YES;
       label_RealWords.hidden=YES;
       lab_switch.hidden=YES;
       btn_switch.hidden=YES;
       btn_AllCancel.hidden = YES;
       btn_submit.center = CGPointMake(150.0, 163.0);
   }
}
-(void)Account_List//统计订单
{
    should_Accounts=0;
    real_Accounts=0;
    for (NSInteger i=0; i<[AddProduct sharedInstance].arr_AddToList.count; i++)
    {//添加订单cell有数据时调用
        NSDictionary *dic=[[AddProduct sharedInstance].arr_AddToList objectAtIndex:i];
        should_Accounts+=[[dic objectForKey:@"should"]floatValue];//应收
        real_Accounts+=[[dic objectForKey:@"real_rsum"]floatValue];
    }
        lab_should.text=[NSString stringWithFormat:@"%.2f元",should_Accounts];
        lab_real.text=[NSString stringWithFormat:@"%.2f元",real_Accounts];
    if(real_Accounts!=0)
    {
        disCount=real_Accounts/should_Accounts;
        lab_discount.text=[NSString stringWithFormat:@"%.0f%@",disCount*100,@"%"];
    }
    else
    {
        lab_discount.text=[NSString stringWithFormat:@"无"];
    }
}
-(void)All_Init
{
    app=(AppDelegate *)[[UIApplication sharedApplication]delegate];
    if(StatusBar_System>0)
        moment_status=20;
    else moment_status=0;
    NavView *nav_View=[[NavView alloc]init];
    [self.view addSubview: [nav_View NavView_Title1:self.str_title]]; //很多页面都会进入这个页面 所以title不是固定的
    
    for(NSInteger i=0;i<2;i++)
    {//左边返回键 右边扫描二维码 添加新订单
        UIButton *btn=[UIButton buttonWithType:UIButtonTypeCustom];
        [btn setBackgroundImage:[UIImage imageNamed:@"btn_color6.png"] forState:UIControlStateHighlighted];
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        btn.titleLabel.font=[UIFont systemFontOfSize:15];
        if(i==0)
        {
            btn.frame=CGRectMake(0, moment_status, 60, 44);
            [btn setTitle:@"< 返回" forState:UIControlStateNormal];
        }
        else
        {
            btn.frame=CGRectMake(Phone_Weight-85, moment_status, 100, 44);
            [btn setTitle:@"添加产品" forState:UIControlStateNormal];
            btn_Add=btn;
        }
        btn.backgroundColor=[UIColor clearColor];
        btn.tag=buttonTag+i;
        
        [btn addTarget:self action:@selector(btn_Action:) forControlEvents:UIControlEventTouchUpInside];
        [nav_View.view_Nav  addSubview:btn];
    }
    //tableView 初始化
    tableView_orderList=[[UITableView alloc]initWithFrame:CGRectMake(0, 44+moment_status, Phone_Weight, Phone_Height-(44+moment_status))];
    [self.view addSubview:tableView_orderList];
    tableView_orderList.backgroundColor=[UIColor clearColor];
    tableView_orderList.separatorStyle = UITableViewCellSeparatorStyleNone;//隐藏tableViewCell的分割线
    tableView_orderList.dataSource=self;
    tableView_orderList.delegate=self;
    
    //物料或者产品单位
    NSDictionary *dic_H=[[BasicData sharedInstance].dic_BasicData objectForKey:@"MasterList"];
    arr_H13=[dic_H objectForKey:@"H13"];//所有的head
    dic_H=nil;
    imageView_Face=[[UIImageView alloc]init];
    imageView_Face=[NavView Show_Nothing_Face];
    //物料或产品数据
    if (app.isApproval)
    {//物料  数据表
        arr_sectionName=[[[BasicData sharedInstance].dic_BasicData objectForKey:@"ProductList"] objectForKey:@"1"];//数据表
    }
    else
    {//商品 数据表
        arr_sectionName=[[[BasicData sharedInstance].dic_BasicData objectForKey:@"ProductList"] objectForKey:@"0"];//数据表
    }
    
    if (self.returnFlag == 1 || self.HIDFlag == 1) {
        lab_switch.hidden = YES;
        btn_switch.hidden = YES;
        btn_AllCancel.hidden = YES;
        btn_submit.center = CGPointMake(150, 163);
        label_ShouldTitle.text = @"应付合计:";
        label_RealWords.text = @"应付合计:";
    }
    reader = [ZbarCustomVC getSingle];
}
-(void)Is_Nothing
{
    if([self.str_isfromeDetail isEqualToString:@"1"])
    {
        if(arr_list.count==0)
        {
            [self.view addSubview:imageView_Face];
        }
        else
        {
            [imageView_Face removeFromSuperview];
        }
    }
    else
    {
        [imageView_Face removeFromSuperview];
    }
    
}
-(void)theMenu
{
    /************动态菜单**************/
    view_meun_background.backgroundColor=[UIColor clearColor];
    view_meun_background.frame=CGRectMake((Phone_Weight-300)/2, Phone_Height-190, 300, 190);
    [self.view addSubview:view_meun_background];
    /************动态菜单**************/
}
-(void)btn_Action:(id)sender
{
    UIButton *btn=(UIButton *)sender;
    if(btn.tag==buttonTag)//返回
    {
        if([self.str_isfromeDetail isEqualToString:@"1"])
        {
            //我的订单点击cell进来之后的返回
            [self.navigationController popViewControllerAnimated:YES];
            return;
        }
        if([AddProduct sharedInstance].arr_AddToList.count>0)
        {
            //添加订单里面有数据时的返回
            [self Mention_alert:@"是否返回?" Tag:buttonTag];
        }
        else
        {
            if(app.isApproval)
            {//返回到申请的主页面
                [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:4]
                                                      animated:YES];
                return;
            }
            //返回到我的订单的主页面
            [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:2]
                                                  animated:YES];
        }
    }
    else if(btn.tag==buttonTag+1)//添加新订单
    {
        UIActionSheet *actionSheet =[[UIActionSheet alloc]initWithTitle:@"选择产品方式" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"扫码", @"列表",nil];
        [actionSheet showInView:self.view];
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex==0)
    {
        //扫码
        [self CreateTheQR];
        isChoose=YES;
    }
    else if(buttonIndex==1)
    {
        //列表
        ChooseListViewController *chooseListVC = [ChooseListViewController new];
        if (self.RDFlag || self.HIDFlag || self.returnFlag) {
            chooseListVC.returnFlag = 1;
        }
        chooseListVC.cIndexNumber = self.str_cindex_no;
        [self.navigationController pushViewController:chooseListVC animated:YES];
    }
    else
    {
        isChoose=NO;
    }
}

-(void)Choose_Line
{
    ChooseListViewController *choose=[[ChooseListViewController alloc]init];
    [self.navigationController pushViewController:choose animated:YES];
}

-(void)CreateTheQR
{
    [reader CreateTheQR:self];
}

- (IBAction)Actioncancel:(id)sender
{
    //收放菜单
    //Dlog(@"收放菜单");
    if(!isCloseMenu)
    {
        [self The_Menu_Closed];
    }
    else
    {
        [self The_Menu_Opened];
    }
}

- (IBAction)Action_switch:(id)sender
{
    if(isSwitch)
    {
        str_isInstead=@"0";//不代收
        isSwitch=NO;
        [btn_switch setBackgroundImage:[UIImage imageNamed:@"switchOne_off.png"] forState:UIControlStateNormal];
    }
    else
    {
        str_isInstead=@"1";//代收
        isSwitch=YES;
        [btn_switch setBackgroundImage:[UIImage imageNamed:@"switchOne_on.png"] forState:UIControlStateNormal];
    }
}

- (IBAction)Action_AllCancel:(id)sender
{
    //销售历史
    DocumentViewController *docVC=[[DocumentViewController alloc]init];
    docVC.titleString=@"销售历史";
    docVC.string_Title=@"销售历史";
    docVC.webViewHeight = 1;
    docVC.str_Url=[self String_To_UrlString:SaleHistory];
    docVC.str_isGraph=@"1";
    docVC.modalFlag = 1;
    docVC.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [self presentViewController:docVC animated:YES completion:nil];
}

-(NSString *)String_To_UrlString:(NSString*)string
{
    NSString *urlString1 = [[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"portal_url"];
    if ([Function StringIsNotEmpty:urlString]) {
        NSString *str=[NSString stringWithFormat:@"%@%@&user.uid=%@&user.password=%@&user.token=%@&cindex_no=%@",urlString1,string,[[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"account"],[[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"secret"],[[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"token"],self.cIndexNumber];
        return str;
    }
    NSString *str=[NSString stringWithFormat:@"%@%@&user.uid=%@&user.password=%@&user.token=%@&cindex_no=%@",kBASEURL,string,[[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"account"],[[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"secret"],[[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"token"],self.cIndexNumber];
    return str;
}

- (IBAction)Action_Submit:(id)sender
{
    //下一步
    if([self.str_isfromeDetail isEqualToString:@"1"])
    {
        OrderListDynamic *order=[[OrderListDynamic alloc]init];
        order.dic_json=dic_json;
        if (self.returnFlag) {
            order.titleString = @"退单附加信息";
        }
        if([self.str_isfromeDetail isEqualToString:@"1"])
        {
            order.isDetail=YES;
        }
        [self.navigationController pushViewController:order animated:YES];
        return;
    }
    
    if (![AddProduct sharedInstance].arr_AddToList.count && !arr_list.count) {
        if(app.isApproval)
        {//从审批的路径进入的物料添加 YES
            
        }
        else
        {
            if(real_Accounts==0.0)
            {
                [SGInfoAlert showInfo:@"实收款项为0元,不合法"
                              bgColor:[[UIColor darkGrayColor] CGColor]
                               inView:self.view
                             vertical:0.5];
                return;
            }
        }
    }
    if(self.isDynamic)
    {//下一步 跳转页面 添加动态信息 后 然后提交
        OrderListDynamic *order=[[OrderListDynamic alloc]init];
        if (self.localFlag) {
            [[AddProduct sharedInstance].arr_AddToList removeAllObjects];
            order.dic_json=self.dataDic;
            order.localFlag = self.localFlag;
            order.terminalName = [self.dataDic objectForKey:@"terminal"];
            order.str_cindex_no = [self.dataDic objectForKey:@"cindex_no"];
            order.str_isFromOnlineOrder = self.str_isFromOnlineOrder;
            order.str_isInstead = str_isInstead;
            order.str_real_Accounts = [lab_real.text substringToIndex:lab_real.text.length-1];
            order.str_should_Accounts = [lab_should.text substringToIndex:lab_should.text.length-1];
            for (int i = 0; i < app.tempOrderArray.count; i ++) {
                [[AddProduct sharedInstance].arr_AddToList addObject:[app.tempOrderArray objectAtIndex:i]];
            }
            if (self.RDFlag) {
                order.RDFlag = 1;
                order.titleString = @"退单附加信息";
                order.str_disCount = [NSString stringWithFormat:@"%.2f",lab_discount.text.floatValue/100];
            }else {
                order.str_disCount = lab_discount.text;
            }
        }else {
            order.terminalName = self.terminalName;
            order.dic_json=self.dic_json;
            order.str_cindex_no=self.str_cindex_no;
            order.str_disCount=[NSString stringWithFormat:@"%f",disCount];
            order.str_isFromOnlineOrder=self.str_isFromOnlineOrder;
            order.str_isInstead=str_isInstead;
            order.str_real_Accounts= [NSString stringWithFormat:@"%.2f",real_Accounts];
            order.str_should_Accounts=[NSString stringWithFormat:@"%.2f",should_Accounts];
            if([self.str_isfromeDetail isEqualToString:@"1"])
            {
                order.isDetail=YES;
            }
            if (self.returnFlag == 1) {
                order.titleString = @"退单附加信息";
                order.RDFlag = 1;
            }
        }
    
        [self.navigationController pushViewController:order animated:YES];
        order=nil;
    }
    else
    {
        //self.isDynamic=NO
        [self Mention_alert:@"提交订单列表数据" Tag: buttonTag+1];
    }
}
-(void)Mention_alert:(NSString *)msg Tag:(NSInteger)tag
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:msg delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定",nil];
    [alert show];
    alert.tag=tag;
    alert=nil;
}
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(alertView.tag==buttonTag||alertView.tag==buttonTag+2)
    {
        if(buttonIndex==1)
        {
            if(app.isApproval)
            {//返回到申请的主页面
                [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:4]
                                                      animated:YES];
                return;
            }
            [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:2]
                                                  animated:YES];
        }
    }
    else if(alertView.tag==buttonTag+1)
    {
        if(buttonIndex==1)
        {
            if(app.isApproval)
            {
                if(should_Accounts==0)
                {
                    [SGInfoAlert showInfo:@"无可提交数据"
                                  bgColor:[[UIColor darkGrayColor] CGColor]
                                   inView:self.view
                                 vertical:0.5];
                    return;
                }
                app.str_cindex_no=self.str_cindex_no;
                app.str_osum=[NSString stringWithFormat:@"%.2f",should_Accounts];
                app.str_orsum=[NSString stringWithFormat:@"%.2f",real_Accounts];
                app.str_odiscount=[NSString stringWithFormat:@"%.2f",disCount ];
                app.str_ctc_sts=str_isInstead;
                [self.navigationController popToViewController: app.VC_AddNewApproval animated:YES];
                return;
            }
            if (self.returnFlag) {
                [self Submit_TheRQrder];
            }else {
                [self Submit_TheQrder];
            }
        }
    }
}

-(void)The_Menu_Opened//去打开
{
    isCloseMenu=NO;
    [UIView animateWithDuration:0.8f animations:^{
       view_meun_background.frame=CGRectMake((Phone_Weight-300)/2, Phone_Height-190, 300, 190);
        
    } completion:^(BOOL finished) {
         [btn_cancel setImage:[UIImage imageNamed:@"icon_goto_close.png"] forState:UIControlStateNormal];
    }];
}
-(void)The_Menu_Closed//去关闭
{
    isCloseMenu=YES;
    [UIView animateWithDuration:0.8f animations:^{
        view_meun_background.frame=CGRectMake((Phone_Weight-300)/2, Phone_Height-60, 300, 190);
    } completion:^(BOOL finished)
     {
         [btn_cancel setImage:[UIImage imageNamed:@"icon_goto_open.png"] forState:UIControlStateNormal];
     }];
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if([self.str_isfromeDetail isEqualToString:@"1"] || self.localFlag)
        return arr_list.count;
    return [AddProduct sharedInstance].arr_AddToList.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    if(isPad)
        return 100;
    return 120;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    OrderListCell *cell=(OrderListCell*)[tableView dequeueReusableCellWithIdentifier:@"OrderListCell"];
    if(cell==nil)
    {
        NSArray *nib;
        nib = [[NSBundle mainBundle] loadNibNamed:@"OrderListCell" owner:[OrderListCell class] options:nil];
        cell = (OrderListCell *)[nib objectAtIndex:0];
        if(app.isApproval)
        {
            cell.lab_isReal.text=@"合计:";
        }
        if(self.str_isfromeDetail)
        {
            NSDictionary *dic=[arr_list objectAtIndex:indexPath.row];
            if (self.localFlag) {
                cell.label_Name.text = [dic objectForKey:@"name"];
                cell.label_Unit_price.text = [NSString stringWithFormat:@"%@元",[dic objectForKey:@"price"]];
                cell.label_shoudMoney.text = [NSString stringWithFormat:@"%@元",[dic objectForKey:@"should"]];
                cell.label_TotalMoney.text = [NSString stringWithFormat:@"%@元",[dic objectForKey:@"real_rsum"]];
            }else {
                cell.label_Name.text= [dic objectForKey:@"pname"];
                cell.label_Unit_price.text=[NSString stringWithFormat:@"%@元",[dic objectForKey:@"price"]];
                cell.label_TotalMoney.text=[NSString stringWithFormat:@"%@元",[dic objectForKey:@"rsum"]];
                
                cell.label_shoudMoney.text=[NSString stringWithFormat:@"%.2f元",[[dic objectForKey:@"cnt"]floatValue]*[[dic objectForKey:@"price"]floatValue ]];

            }
            
            if (self.localFlag) {
                if([[dic objectForKey:@"real_rsum"]floatValue]<[[dic objectForKey:@"should"]floatValue])
                {
                    cell.img_isRealOrShould.image=[UIImage imageNamed:@"cell_OrderList_red.png"];
                }
            }else if([[dic objectForKey:@"rsum"]  floatValue]<[[dic objectForKey:@"cnt"]floatValue]*[[dic objectForKey:@"price"]floatValue ])
            {
                cell.img_isRealOrShould.image=[UIImage imageNamed:@"cell_OrderList_red.png"];
            }
            BOOL isFlag=NO;
            for(NSInteger j=0;j<arr_sectionName.count;j++)
            {
                NSDictionary *_dic=[arr_sectionName objectAtIndex:j];
                if([[_dic objectForKey:@"pcode"]isEqualToString:[dic objectForKey:@"pcode"]])
                {
                     for (NSInteger i=0; i<arr_H13.count; i++)
                     {
                         NSDictionary *dic_H=[arr_H13 objectAtIndex:i];
                         if([[dic_H objectForKey:@"cvalue"] isEqualToString:[_dic objectForKey:@"punit"]])
                         {
                             cell.label_totalNum.text=[NSString stringWithFormat:@"%@%@",[dic objectForKey:@"cnt"],[dic_H objectForKey:@"clabel"]];
                             isFlag=YES;
                             break;
                         }
                     }
                }
                if(isFlag)break;
            }
        }
        else
        {
            NSDictionary *dic_unit=[[AddProduct sharedInstance].arr_AddToList objectAtIndex:indexPath.row];
            cell.label_Name.text=[dic_unit objectForKey:@"name"];
            cell.label_Unit_price.text=[NSString stringWithFormat:@"%@元",[dic_unit objectForKey:@"price"]];
            cell.label_totalNum.text=[NSString stringWithFormat:@"%@%@",[dic_unit objectForKey:@"cnt"],[dic_unit objectForKey:@"unit"]];
            
            cell.label_shoudMoney.text=[NSString stringWithFormat:@"%@元",[dic_unit objectForKey:@"should"]];//应收
            cell.label_TotalMoney.text=[NSString stringWithFormat:@"%@元",[dic_unit objectForKey:@"real_rsum"]];//实收
            if([[dic_unit objectForKey:@"real_rsum"]floatValue]<[[dic_unit objectForKey:@"should"]floatValue])
            {
                cell.img_isRealOrShould.image=[UIImage imageNamed:@"cell_OrderList_red.png"];
            }
        }
        if(indexPath.row+1>9)
        {
            cell.label_index.text=[NSString stringWithFormat:@"%ld",indexPath.row+1];
        }
        else
        {
            cell.label_index.text=[NSString stringWithFormat:@"0%ld",indexPath.row+1];
        }
        cell.label_shoudMoney.textAlignment=NSTextAlignmentCenter;
        cell.label_totalNum.textAlignment=NSTextAlignmentCenter;
        cell.label_Unit_price.textAlignment=NSTextAlignmentCenter;
        cell.contentView.backgroundColor = [UIColor clearColor];
    }
    
    UIImageView *viewCell;
    viewCell=[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, Phone_Weight, 120)];
    viewCell.image=[UIImage imageNamed:@"cell_message_background@2X.png"];
    [cell insertSubview:viewCell atIndex:0];
    cell.selectionStyle=UITableViewCellSelectionStyleNone;//无点击效果
    cell.backgroundColor=[UIColor clearColor];
    cell.label_TotalMoney.adjustsFontSizeToFitWidth = YES;
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    AddListOrderViewController *addVC=[[AddListOrderViewController alloc]init];
    if([self.str_isfromeDetail isEqualToString:@"1"])
    {
        NSDictionary *dic=[arr_list objectAtIndex:indexPath.row];
        addVC.str_Detail=@"2";
        addVC.str_name=[dic objectForKey:@"pname"];
        addVC.str_real=[dic objectForKey:@"rsum"];
        addVC.str_price=[dic objectForKey:@"price"];
        addVC.str_real_price=[dic objectForKey:@"selling_price"];
        addVC.str_count=[dic objectForKey:@"cnt"];//数量
        addVC.str_momo = [dic objectForKey:@"memo"];
        addVC.str_switch = [dic objectForKey:@"gift_flg"];
        addVC.str_total=[NSString stringWithFormat:@"%.2f",[addVC.str_price floatValue]*[addVC.str_count floatValue]];
        if (self.returnFlag) {
            addVC.str_title=@"退单内容";
            addVC.returnFlag = 1;
        }else {
            addVC.str_title=@"订单内容";
        }
        addVC.str_index_no_fromSuper=[dic objectForKey:@"pindex_no"];
        BOOL isflag=NO;
        for(NSInteger j=0;j<arr_sectionName.count;j++)
        {//赋值数量单位
            NSDictionary *_dic=[arr_sectionName objectAtIndex:j];
            if([[_dic objectForKey:@"index_no"]isEqualToString:[dic objectForKey:@"pindex_no"]])
            {
                for (NSInteger i=0; i<arr_H13.count; i++)
                {
                    NSDictionary *dic_H=[arr_H13 objectAtIndex:i];
                    if([[dic_H objectForKey:@"cvalue"] isEqualToString:[_dic objectForKey:@"punit"]])
                    {
                        isflag=YES;
                        addVC.str_numUnit=[dic_H objectForKey:@"clabel"];
                        break;
                    }
                }
            }
            if(isflag)break;
        }
    }
    else
    {
        //添加订单点击创建之后返回到添加订单再次点击tableView进入显示的内容
        if (self.returnFlag || self.HIDFlag) {
            addVC.str_title=@"编辑退单内容";
            addVC.returnFlag = 1;
        }else {
            addVC.str_title=@"编辑订单内容";
        }
        addVC.str_Detail=@"1";
        addVC.str_Index=[NSString stringWithFormat:@"%ld",(long)indexPath.row];
        
    }
    if (app.isApproval) {
        app.str_Product_material=@"1";//物料
    }
    else
    {
        app.str_Product_material=@"0";//商品
    }
    
    [self.navigationController pushViewController:addVC animated:YES];
}
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        if(![self.str_isfromeDetail isEqualToString:@"1"])
        {
            [[AddProduct sharedInstance].arr_AddToList removeObjectAtIndex:indexPath.row];
            if (self.localFlag) {
                arr_list = [AddProduct sharedInstance].arr_AddToList;
                app.tempOrderArray = [[NSArray alloc] initWithArray:arr_list];
            }
            [self Account_List];
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        }
        else
        {
            [SGInfoAlert showInfo:@"当前为只读模式"
                          bgColor:[[UIColor darkGrayColor] CGColor]
                           inView:self.view
                         vertical:0.5];
        }
    }
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
}

-(void)Submit_TheQrder//提交订单
{
    if([Function isConnectionAvailable])
    {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.mode = MBProgressHUDModeIndeterminate;
        hud.labelText = @"加载中...";//加载提示语言

        if(app.isPortal)
        {
            urlString=[NSString stringWithFormat:@"%@%@",KPORTAL_URL,KNew_Order];
        }
        else
        {
            urlString=[NSString stringWithFormat:@"%@%@",kBASEURL,KNew_Order];
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
        
        for (NSInteger i=0; i<[AddProduct sharedInstance].arr_AddToList.count; i++)
        {
            NSDictionary *dic_unit =[[AddProduct sharedInstance].arr_AddToList objectAtIndex:i];
            [request setPostValue:[dic_unit objectForKey:@"pcode"] forKey:[NSString stringWithFormat:@"postList[%ld].pcode",(long)i]];
            [request setPostValue:[dic_unit objectForKey:@"price"] forKey:[NSString stringWithFormat:@"postList[%ld].price",(long)i]];
            [request setPostValue:[dic_unit objectForKey:@"cnt"] forKey:[NSString stringWithFormat:@"postList[%ld].cnt",(long)i]];
            [request setPostValue:[dic_unit objectForKey:@"real_rsum"] forKey:[NSString stringWithFormat:@"postList[%ld].rsum",(long)i]];
            [request setPostValue:[dic_unit objectForKey:@"pindex_no"] forKey:[NSString stringWithFormat:@"postList[%ld].pindex_no",(long)i]];
            [request setPostValue:[dic_unit objectForKey:@"selling_price"] forKey:[NSString stringWithFormat:@"postList[%ld].selling_price",(long)i]];
        }
        [request setPostValue:self.str_cindex_no forKey:@"cindex_no"];//终端索引
        [request setPostValue:[NSString stringWithFormat:@"%.2f",should_Accounts] forKey:@"osum"];
        [request setPostValue:[NSString stringWithFormat:@"%.2f",real_Accounts]  forKey:@"orsum"];
        [request setPostValue:[NSString stringWithFormat:@"%.0f",disCount]  forKey:@"odiscount"];
        [request setPostValue:str_isInstead forKey:@"ctc_sts"];
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

-(void)Submit_TheRQrder//提交订单
{
    if([Function isConnectionAvailable])
    {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.mode = MBProgressHUDModeIndeterminate;
        hud.labelText = @"加载中...";//加载提示语言
        
        if(app.isPortal)
        {
            urlString=[NSString stringWithFormat:@"%@%@",KPORTAL_URL,KRet_Order];
        }
        else
        {
            urlString=[NSString stringWithFormat:@"%@%@",kBASEURL,KRet_Order];
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
        
        for (NSInteger i=0; i<[AddProduct sharedInstance].arr_AddToList.count; i++)
        {
            NSDictionary *dic_unit =[[AddProduct sharedInstance].arr_AddToList objectAtIndex:i];
            [request setPostValue:[dic_unit objectForKey:@"pcode"]
                           forKey:[NSString stringWithFormat:@"postList[%ld].pcode",(long)i]];
            [request setPostValue:[dic_unit objectForKey:@"price"]
                           forKey:[NSString stringWithFormat:@"postList[%ld].price",(long)i]];
            [request setPostValue:[dic_unit objectForKey:@"cnt"]
                           forKey:[NSString stringWithFormat:@"postList[%ld].cnt",(long)i]];
            [request setPostValue:[dic_unit objectForKey:@"real_rsum"]
                           forKey:[NSString stringWithFormat:@"postList[%ld].rsum",(long)i]];
            [request setPostValue:[dic_unit objectForKey:@"pindex_no"]
                           forKey:[NSString stringWithFormat:@"postList[%ld].pindex_no",(long)i]];
            [request setPostValue:[dic_unit objectForKey:@"selling_price"]
                           forKey:[NSString stringWithFormat:@"postList[%ld].selling_price",(long)i]];
        }
        [request setPostValue:self.str_cindex_no forKey:@"cindex_no"];//终端索引
        [request setPostValue:[NSString stringWithFormat:@"%.2f",should_Accounts] forKey:@"osum"];
        [request setPostValue:[NSString stringWithFormat:@"%.2f",real_Accounts]  forKey:@"rsum"];
        [request setPostValue:[NSString stringWithFormat:@"%.0f",disCount]  forKey:@"odiscount"];
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

-(void)get_JsonString:(NSString *)jsonString Type:(NSString*)type
{
    app.order_refresh = 1;
    SBJsonParser *parser = [[SBJsonParser alloc] init];
    NSDictionary *dict =[parser objectWithString: jsonString];
    if([type isEqualToString:@"0"])//提交订单向服务器
    {
        if([[dict objectForKey:@"ret"] isEqualToString:@"0"])
        {
            
            [SGInfoAlert showInfo:@" 成功提交订单 "
                          bgColor:[[UIColor darkGrayColor] CGColor]
                           inView:self.view
                         vertical:0.5];
            [[AddProduct sharedInstance].arr_AddToList removeAllObjects];
            //以下两段 返回OK 了
            if([self.str_isFromOnlineOrder isEqualToString:@"0"])
            {
                self.delegate =(id) app.VC_SubmitOrder;
                //指定代理对象为，second
                [self.delegate Notify_OrderListView];//这里获得代理方法的返回值。
                [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:2]
                                                      animated:YES];
            }
            else if([self.str_isFromOnlineOrder isEqualToString:@"1"])
            {
                [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:2]
                                                      animated:YES];
            }
            
            [tableView_orderList reloadData];
            [self Is_Nothing];
        }
        else
        {
            [SGInfoAlert showInfo:[dict objectForKey:@"message"]
                          bgColor:[[UIColor darkGrayColor] CGColor]
                           inView:self.view
                         vertical:0.5];
        }
    }
    else
    {//请求列表数据
        if([[dict objectForKey:@"ret"] isEqualToString:@"0"])
        {
            NSDictionary *dic = nil;
            dic_json=dict;
            if (self.returnFlag) {
                dic=[dict objectForKey:@"ReturnInfo"];
            }else {
                dic=[dict objectForKey:@"OrderInfo"];
            }
            [self The_Menu_Opened];
            lab_should.text=[NSString stringWithFormat:@"%@元",[dic objectForKey:@"osum"]];
            if (self.returnFlag) {
                lab_real.text=[NSString stringWithFormat:@"%@元",[dic objectForKey:@"rsum"]];
            }else {
                lab_real.text=[NSString stringWithFormat:@"%@元",[dic objectForKey:@"orsum"]];
            }
            
            lab_discount.text=[NSString stringWithFormat:@"%@%@",[dic objectForKey:@"odiscount"],@"%"];
            btn_switch.userInteractionEnabled=NO;
            
            if(!app.isApproval)
            {
                if(![[dic objectForKey:@"DynamicCount"] isEqualToString:@"0"]||![[dic objectForKey:@"MediaCount"] isEqualToString:@"0"])
                {
                    if (self.returnFlag) {
                        [btn_submit setImage:[UIImage imageNamed:@"icon_orderList_more1.png"] forState:UIControlStateNormal];
                    }else {
                        [btn_submit setImage:[UIImage imageNamed:@"icon_orderList_more.png"] forState:UIControlStateNormal];
                    }
                }
                else
                {
                    [btn_submit setBackgroundImage:[UIImage imageNamed:@"icon_orderList_submit_finish.png"] forState:UIControlStateNormal]; //提交(灰色)
                    btn_submit.userInteractionEnabled=NO;
                }
                if ([[dic objectForKey:@"ctc_sts"]isEqualToString:@"0"])
                {
                    [btn_switch setBackgroundImage:[UIImage imageNamed:@"switchOne_off.png"] forState:UIControlStateNormal];
                }
                else
                {
                    [btn_switch setBackgroundImage:[UIImage imageNamed:@"switchOne_on.png"] forState:UIControlStateNormal];
                    
                }
            }
            else
            {
                [btn_submit setBackgroundImage:[UIImage imageNamed:@"icon_orderList_submit_finish.png"] forState:UIControlStateNormal];
                btn_submit.userInteractionEnabled=NO;
            }
            arr_list=[dict objectForKey:@"ProductList"];
            [tableView_orderList reloadData];
            [self Is_Nothing];
        }
        else
        {
            [SGInfoAlert showInfo:[dict objectForKey:@"message"]
                          bgColor:[[UIColor darkGrayColor] CGColor]
                           inView:self.view
                         vertical:0.5];
        }
    }
}
-(NSString *)SettingURL_getOrderList:(NSString *)url
{
    NSString *string;
    if([self.str_isFromOnlineOrder isEqualToString:@"2"])
    {
        string =[NSString stringWithFormat:@"%@%@",url,KGet_material];
    }
    else
    {
        string =[NSString stringWithFormat:@"%@%@",url,KGet_DetailList];
    }
    return string;
}
-(void)getOrderList//请求列表数据
{
    if([Function isConnectionAvailable])
    {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.mode = MBProgressHUDModeIndeterminate;
        hud.labelText = @"加载中...";//加载提示语言

        if(app.isPortal)
        {
            urlString=[self SettingURL_getOrderList:KPORTAL_URL];
        }
        else
        {
            urlString=[self SettingURL_getOrderList:kBASEURL];
        }
        NSURL *url = [ NSURL URLWithString :  urlString];
        ASIFormDataRequest *request = [ ASIFormDataRequest requestWithURL :url];
        request.delegate = self;
        request.tag = 101;
        [request setRequestMethod:@"POST"];
        [request setPostValue:[[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"account"]forKey:KUSER_UID];
        [request setPostValue:[[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"secret"] forKey:KUSER_PASSWORD];
        [request setPostValue:[[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"token"] forKey:@"user.token"];
        [request setPostValue:[[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"db_ip"] forKey:@"db_ip"];
        [request setPostValue:[[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"db_name"] forKey:@"db_name"];
        if([self.str_isFromOnlineOrder isEqualToString:@"2"])
        {
            [request setPostValue:self.str_index_no  forKey:@"req_index_no"];
        }
        else
        {
            [request setPostValue:self.str_index_no  forKey:@"index_no"];
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

//退货详细
-(void)getROrderList//请求列表数据
{
    if([Function isConnectionAvailable])
    {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.mode = MBProgressHUDModeIndeterminate;
        hud.labelText = @"加载中...";//加载提示语言
        
        if(app.isPortal)
        {
            urlString = [NSString stringWithFormat:@"%@%@",KPORTAL_URL,KROrder_detail];
        }
        else
        {
            urlString = [NSString stringWithFormat:@"%@%@",kBASEURL,KROrder_detail];
        }
        NSURL *url = [ NSURL URLWithString :  urlString];
        ASIFormDataRequest *request = [ ASIFormDataRequest requestWithURL :url];
        request.delegate = self;
        request.tag = 101;
        [request setRequestMethod:@"POST"];
        [request setPostValue:[[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"account"]forKey:KUSER_UID];
        [request setPostValue:[[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"secret"] forKey:KUSER_PASSWORD];
        [request setPostValue:[[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"token"] forKey:@"user.token"];
        [request setPostValue:[[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"db_ip"] forKey:@"db_ip"];
        [request setPostValue:[[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"db_name"] forKey:@"db_name"];
        if([self.str_isFromOnlineOrder isEqualToString:@"2"])
        {
            [request setPostValue:self.str_index_no  forKey:@"req_index_no"];
        }
        else
        {
            [request setPostValue:self.str_index_no  forKey:@"index_no"];
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

//取得订单动态项目
-(void)get_OrderDynamic
{
    if(app.isPortal)
    {
        urlString =[NSString stringWithFormat:@"%@%@",KPORTAL_URL,KGetOrder_Dynamic];
    }
    else
    {
        urlString =[NSString stringWithFormat:@"%@%@",kBASEURL,KGetOrder_Dynamic];
    }
    NSURL *url = [ NSURL URLWithString :  urlString];
    ASIFormDataRequest *request = [ ASIFormDataRequest requestWithURL :url];
    request.delegate = self;
    request.tag = 102;
    [request setRequestMethod:@"POST"];
    [request setPostValue:[[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"account"]forKey:KUSER_UID];
    [request setPostValue:[[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"secret"] forKey:KUSER_PASSWORD];
    [request setPostValue:[[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"token"] forKey:@"user.token"];
    [request setPostValue:[[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"db_ip"] forKey:@"db_ip"];
    [request setPostValue:[[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"db_name"] forKey:@"db_name"];
    [request startAsynchronous ];
}

//取得退单动态项目
-(void)getReturnDynamicList
{
    if(app.isPortal) {
        urlString =[NSString stringWithFormat:@"%@%@",KPORTAL_URL,KGetROrder_Dynamic];
    }
    else {
        urlString =[NSString stringWithFormat:@"%@%@",kBASEURL,KGetROrder_Dynamic];
    }
    NSURL *url = [ NSURL URLWithString :  urlString];
    ASIFormDataRequest *request = [ ASIFormDataRequest requestWithURL :url];
    request.delegate = self;
    request.tag = 102;
    [request setRequestMethod:@"POST"];
    [request setPostValue:[[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"account"]forKey:KUSER_UID];
    [request setPostValue:[[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"secret"] forKey:KUSER_PASSWORD];
    [request setPostValue:[[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"token"] forKey:@"user.token"];
    [request setPostValue:[[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"db_ip"] forKey:@"db_ip"];
    [request setPostValue:[[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"db_name"] forKey:@"db_name"];
    [request startAsynchronous ];//异步
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [picker dismissViewControllerAnimated:YES completion:^{
        [reader dismissOverlayView:nil];
        [picker removeFromParentViewController];
        UIImage * image = [info objectForKey:UIImagePickerControllerOriginalImage];
        //初始化
        ZBarReaderController * read = [ZBarReaderController new];
        //设置代理
        read.readerDelegate = self;
        CGImageRef cgImageRef = image.CGImage;
        ZBarSymbol * symbol = nil;
        id <NSFastEnumeration> results = [read scanImage:cgImageRef];
        for (symbol in results)
        {
            break;
        }
        NSString * result;
        if ([symbol.data canBeConvertedToEncoding:NSShiftJISStringEncoding])
            
        {
            result = [NSString stringWithCString:[symbol.data cStringUsingEncoding: NSShiftJISStringEncoding] encoding:NSUTF8StringEncoding];
        }
        else
        {
            result = symbol.data;
        }
        [self PK_QR_VS_List :result];
    }];
}

-(void)PK_QR_VS_List:(NSString *)url
{
    BOOL OK=NO;
    for(NSInteger i=0;i<arr_sectionName.count;i++)
    {
        NSDictionary *dic=[arr_sectionName objectAtIndex:i];
        if([[dic objectForKey:@"pcode"] isEqualToString:url])
        {
            OK=YES;
            ChooseListViewController *choose=[[ChooseListViewController alloc]init];
            choose.str_isFromQR=@"1";
            choose.str_pcode=url;
            [self.navigationController pushViewController:choose animated:YES];
            isChoose=YES;
            break;
        }
    }
}

-(void)requestFinished:(ASIHTTPRequest *)request {
    if (request.tag == 100) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        
        if([request responseStatusCode]==200)
        {
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
    if (request.tag == 101) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        if([request responseStatusCode]==200)
        {
            NSString * jsonString  =  [request responseString];
            [self get_JsonString:jsonString Type:@"1"];
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
    if (request.tag == 102) {
        if([request responseStatusCode]==200)
        {
            SBJsonParser *parser = [[SBJsonParser alloc] init];
            NSDictionary *dict =[parser objectWithString:[request responseString]];
            if([[dict objectForKey:@"DynamicCount"] isEqualToString:@"0"]&&[[dict objectForKey:@"MediaCount"] isEqualToString:@"0"] )
            {
                self.isDynamic=NO;
            }
            else
            {   //btn_submit
                self.isDynamic=YES;
                self.dic_json=dict;
                [btn_submit setImage:[UIImage imageNamed:@"icon_orderList_Next.png"] forState:UIControlStateNormal]; //下一步
            }
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
}

-(void)requestFailed:(ASIHTTPRequest *)request {
    if (request.tag == 100) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        
        [SGInfoAlert showInfo:@"哎呀，服务器无响应，一会再试试吧"
                      bgColor:[[UIColor darkGrayColor] CGColor]
                       inView:self.view
                     vertical:0.5];
        // 请求响应失败，返回错误信息
        //Dlog(@"HTTP 响应码：%d",[request responseStatusCode]);
    }
    if (request.tag == 101) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [SGInfoAlert showInfo:@"哎呀，服务器无响应，一会再试试吧"
                      bgColor:[[UIColor darkGrayColor] CGColor]
                       inView:self.view
                     vertical:0.5];
        // 请求响应失败，返回错误信息
        //Dlog(@"HTTP 响应码：%d",[request responseStatusCode]);
    }
}
@end
