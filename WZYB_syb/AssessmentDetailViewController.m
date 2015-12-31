//
//  AssessmentDetailViewController.m
//  WZYB_syb
//
//  Created by wzyb on 14-8-6.
//  Copyright (c) 2014年 WZYB. All rights reserved.
//

#import "AssessmentDetailViewController.h"
#import "UIImageView+WebCache.h"
#import "AppDelegate.h"
#import "MarkViewController.h"
#import "ModiLogViewController.h"
@interface AssessmentDetailViewController ()<ASIHTTPRequestDelegate>
{
    AppDelegate *app;
    NSMutableArray *mutArray;
    int assessPerson;
    NSString *sendStatus;
    NSArray *DArray;
    NSInteger buttonTagNumber;
    NSInteger markbuttonFlag;
    UIView *view_back;//日历背景
    NSInteger dateIndex;
}
@end

@implementation AssessmentDetailViewController
@synthesize str_req_index_no;


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
    [self creatView];
    //ApplyInfo中的exe_sts有4种状态：0：审批中 1：拒绝 2：同意 3：终结
    //type 0 列表 1 反馈 2 同意拒绝结果
    
    [self getApprove_log_isSure_ISFromAssess:@"0"];
    
}
-(void)viewWillAppear:(BOOL)animated
{
    if(isReadDetail)
    {
        isReadDetail=NO;
    }
    else
    {
        str_isSubmit=@"0";
        if(isToOthers)
        {
            if([Function isBlankString:app.str_workerName])
            {
                label_later.text=[NSString stringWithFormat:@"【后续审批人】 无" ];
            }
            else
            {
                label_later.text=[NSString stringWithFormat:@"【后续审批人】 %@",app.str_workerName];
            }
        }
    }
    
    if (app.markFlag) {
        app.markFlag = 0;
        [self getApprove_log_isSure_ISFromAssess:@"0"];
    }
    
    if (sendStatus.integerValue || (self.ShowBtnFlag == 1)) {
        if ([Function StringIsNotEmpty:app.str_temporary]) {
            NSString *tagString = [NSString stringWithFormat:@"%ld",buttonTagNumber];
            
            for (int i = 0; i < arr_text.count; i ++) {
                NSDictionary *tempDic = [arr_text objectAtIndex:i];
                if ([tagString isEqualToString:[tempDic objectForKey:@"TAG"]]) {
                    UITextField *textField = [tempDic objectForKey:tagString];
                    textField.text = app.str_temporary;
                    [arr_text removeObjectAtIndex:i];
                    
                    NSMutableDictionary *dic1=[[NSMutableDictionary alloc]init];
                    [dic1 setObject:[tempDic objectForKey:@"title"] forKey:@"title"];
                    [dic1 setObject:[tempDic objectForKey:@"data_type"] forKey:@"data_type"];
                    [dic1 setObject:textField forKey:tagString];
                    [dic1 setObject:textField.text forKey:@"text"];
                    [dic1 setObject:tagString forKey:@"TAG"];
                    [arr_text insertObject:dic1 atIndex:i];
                }
            }
        }
    }
}
-(void)All_Init
{
    dateIndex = 0;
    markbuttonFlag = 0;
    app.str_temporary = [NSString string];
    buttonTagNumber = 0;
    sendStatus = [NSString string];
    assessPerson = 1;
    mutArray = [NSMutableArray array];
    app=(AppDelegate *)[[UIApplication sharedApplication]delegate];
    if(StatusBar_System>0)
        moment_status=20;
    else moment_status=0;
    combox_height_thisView=combox_height;
    near_by_thisView=Near_By;
    arr_text=[[NSMutableArray alloc]init];
    NavView *nav_View=[[NavView alloc]init];
    [self.view addSubview: [nav_View NavView_Title1:self.str_title]];
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
    
    //背景图案
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"AddNewClerkBacground"]]];
    //图片背景
    view_imageView_back=[[UIView alloc]init];
    view_imageView_back.frame=CGRectMake(0, 0, Phone_Weight, Phone_Height);
    arr_imageView=[NSMutableArray arrayWithCapacity:1];//大图片
}
-(void)creatView
{
    scrollView_Back=[[UIScrollView alloc]init];
    scrollView_Back.frame=CGRectMake(0, moment_status+44,Phone_Weight, Phone_Height-moment_status-44);
    scrollView_Back.backgroundColor=[UIColor clearColor];
    [self.view addSubview:scrollView_Back];
}
-(void)btn_Action:(id)sender
{
    UIButton *btn=(UIButton *)sender;
    if(btn.tag==buttonTag-2)
    {//去查看物料
        app.isApproval=YES;
        OrderListViewController *order=[[OrderListViewController alloc]init];
        order.str_isfromeDetail=@"1";//是查看详细
        order.str_isFromOnlineOrder=@"2";
        order.str_title=@"查看物料清单";
        order.str_index_no=self.str_req_index_no;
        [self.navigationController pushViewController:order animated:YES];
    }
    else if(btn.tag==buttonTag-1)//返回
    {
        app.isOnlyGoBack=YES;
        [self.navigationController popViewControllerAnimated:YES];
    }
    else if(btn.tag==buttonTag)
    {//浏览人员
        LocationViewController *loVC=[[LocationViewController alloc]init];
        loVC.str_from=@"3";//审批
        [self.navigationController pushViewController:loVC animated:NO];
    }
    else if(btn.tag==buttonTag+1)
    {//同意
        str_isSubmit=@"1";
        [self Creat_alertView];
    }
    else if(btn.tag==buttonTag+2)
    {//拒绝
        
        str_isSubmit=@"0";
        [self Creat_alertView];
    }
    else if(buttonTag +3==btn.tag)
    {
        str_isSubmit=@"1";
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"请您填写申请反馈" message:@" " delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定",nil];
        alert.alertViewStyle = UIAlertViewStylePlainTextInput;
        [alert show];
        alert=nil;
    }

}

-(void)show_action:(UIButton *)btn
{//data_type动态项目类型（0:数字，1:文本，2:金额，3:日期，4:列表）
    buttonTagNumber = btn.tag;
    NSDictionary *dic=[arr_text objectAtIndex:btn.tag-buttonTag*2-1];
    
    if([[dic objectForKey:@"data_type"]isEqualToString:@"3"]) {
        dateIndex = btn.tag-buttonTag*2-1;
        [self select_Date];
        return;
    }
    
    if(![[dic objectForKey:@"data_type"]isEqualToString:@"4"])
    {//如果是列表 就不进行页面查看详细了
        if(btn.tag-2*buttonTag==5)
        {
            ShowMyPositionViewController *show=[[ShowMyPositionViewController alloc]init];
            show.str_gname=[dic objectForKey:@"text"];
            show.str_glat=str_glat;
            show.str_glng=str_glng;
            [self.navigationController pushViewController:show animated:YES];
        }
        else
        {
            NoteViewController *noteVC=[[NoteViewController alloc]init];
            if (sendStatus.integerValue || (self.ShowBtnFlag == 1)) {
                if (btn.tag >= 210) {
                    noteVC.isDetail=NO;
                }else {
                    noteVC.isDetail=YES;
                }
            }else {
               noteVC.isDetail=YES;
            }
            isReadDetail=YES;
            noteVC.str_title=[dic objectForKey:@"title"];
            if (mutArray.count == 2) {
                if (btn.tag == 209) {
                    noteVC.str_content=[mutArray objectAtIndex:0];
                }else if (btn.tag == 210) {
                    noteVC.str_content=[mutArray objectAtIndex:1];
                }else {
                    noteVC.str_content=[dic objectForKey:@"text"];
                }
            }else {
                noteVC.str_content=[dic objectForKey:@"text"];
            }
            [self.navigationController pushViewController:noteVC animated:YES];
            noteVC=nil;
        }
    }else {
        UIActionSheetViewController *actionVC=[[UIActionSheetViewController alloc]init];
        NSDictionary *tempDic = nil;
        if (btn.tag > 209) {
            tempDic = [DArray objectAtIndex:(btn.tag - 210)];
        }else {
            tempDic = [DArray objectAtIndex:(btn.tag - 208)];
        }
        
        actionVC.str_title=[tempDic objectForKey:@"tname"];
        actionVC.str_tdefault=[tempDic objectForKey:@"tdefault"];
        actionVC.isOnlyLabel=YES;
        [self.navigationController pushViewController:actionVC animated:YES];

    }
}

-(void)select_Date
{
    view_back=[[UIView alloc]initWithFrame:CGRectMake(0, moment_status+44, Phone_Weight, Phone_Height-moment_status-44)];
    view_back.backgroundColor=[UIColor colorWithRed:193/255.0 green:193/255.0 blue:193/255.0 alpha:0.6];
    [self.view addSubview:view_back];
    RBCustomDatePickerView *pickerView = [[RBCustomDatePickerView  alloc] initWithFrame:CGRectMake((Phone_Weight-278.5)/2, (view_back.frame.size.height-(190+54*2)-49)/2, 278.5, 54+190.0)];
    pickerView.backgroundColor=[UIColor clearColor];
    pickerView.layer.cornerRadius = 8;
    pickerView.layer.masksToBounds = YES;
    [view_back addSubview:pickerView];
    for(NSInteger i=2;i<4;i++)
    {
        UIButton *btn=[UIButton buttonWithType:UIButtonTypeCustom];
        UILabel *label_btn=[[UILabel alloc]init];
        label_btn.backgroundColor=[UIColor whiteColor];
        label_btn.layer.cornerRadius = 8;
        label_btn.layer.masksToBounds = YES;
        label_btn.textColor=[UIColor blackColor];
        label_btn.textAlignment=NSTextAlignmentCenter;
        if(i==2)
        {
            btn.frame=CGRectMake((Phone_Weight-278.5)/2,pickerView.frame.origin.y +pickerView.frame.size.height+10,278.5/2-5, 44);
            label_btn.text=@"取消";
        }
        else
        {
            btn.frame=CGRectMake((Phone_Weight-278.5)/2+5+278.5/2,pickerView.frame.origin.y +pickerView.frame.size.height+10 , 278.5/2-5, 44);
            label_btn.text=@"确定";
        }
        [btn addSubview:label_btn];
        btn.backgroundColor=[UIColor clearColor];
        label_btn.frame=CGRectMake(0, 0, btn.frame.size.width, btn.frame.size.height);
        btn.tag=buttonTag*2+i;
        [btn addTarget:self action:@selector(dateAction:) forControlEvents:UIControlEventTouchUpInside];
        [view_back  addSubview:btn];
    }
}

- (void)dateAction:(UIButton *)button {
    [view_back removeFromSuperview];
    if (button.tag == buttonTag*2+2) {
        return;
    }
    NSString *keyStr = [NSString stringWithFormat:@"%ld",201+dateIndex];
    if(app.isDateLegal)
    {
        NSMutableDictionary *dic=[arr_text objectAtIndex:dateIndex];
        UITextField *tex=[dic objectForKey:keyStr];
        tex.text=app.str_Date;
    }
    else
    {
        app.str_Date=[Function getYearMonthDay_Now];
        NSDictionary *dic=[arr_text objectAtIndex:dateIndex];
        UITextField *text=[dic objectForKey:keyStr];
        text.text=app.str_Date;
    }
}

-(void)switchAction:(id)sender
{
    UISwitch *_switchButton = (UISwitch*)sender;
    BOOL isButtonOn = [_switchButton isOn];
    if (isButtonOn) {//是
        //Dlog(@"YES");
        [btn_peo setBackgroundImage:[UIImage imageNamed:@"btn_color3.png"] forState:UIControlStateNormal];
        btn_peo.enabled=YES;
        isToOthers=YES;
    }else {//否
        //Dlog(@"否");
        isToOthers=NO;
        [btn_peo setBackgroundImage:[UIImage imageNamed:@"btn_color5.png"] forState:UIControlStateNormal];
        btn_peo.enabled=NO;
    }
}
-(void)Creat_alertView
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"请您填写审批批注" message:@" " delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定",nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alert show];
}
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    str_replay_content=[alertView textFieldAtIndex:0].text;
    if(buttonIndex==1)
    {
        //0是列表
        if(self.isFromWillAssess)
        {
            if([str_isSubmit isEqualToString:@"0"]&&[Function isBlankString:str_replay_content])//是拒绝的画  批注必填
            {
                [SGInfoAlert showInfo:@"请填写审批批注"
                              bgColor:[[UIColor darkGrayColor] CGColor]
                               inView:self.view
                             vertical:0.5];
            }
            else
            {
                [self getApprove_log_isSure_ISFromAssess:@"2"];//同意或拒绝
            }
        }
        else
        {
            if([Function isBlankString:str_replay_content])
            {
                [SGInfoAlert showInfo:@"请填写申请反馈"
                              bgColor:[[UIColor darkGrayColor] CGColor]
                               inView:self.view
                             vertical:0.5];
            }
            else
            {
                [self getApprove_log_isSure_ISFromAssess:@"1"];//反馈按钮
            }
        }
        
    }
}
-(NSString *)SettingURL_getApprove_log_isSure_ISFromAssess:(NSString *)url ISAssess:(NSString *)isAssess
{
    NSString *string;
    if([isAssess isEqualToString:@"1"])
    {//申请者确认
        string=[NSString stringWithFormat:@"%@%@",url,KConfirm];
    }
    else if([isAssess isEqualToString:@"2"])
    {//同意 拒绝
        string=[NSString stringWithFormat:@"%@%@",url,KAction_approve];
    }
    else if([isAssess isEqualToString:@"0"])
    {//获得流程
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.mode = MBProgressHUDModeIndeterminate;
        hud.labelText = @"加载中...";//加载提示语言
        string=[NSString stringWithFormat:@"%@%@",url,KApprove_log];
    }
    else if([isAssess isEqualToString:@"4"])
    {
        string=[NSString stringWithFormat:@"%@%@",url,KLog_record];
    }
    else if([isAssess isEqualToString:@"5"])
    {
        string=[NSString stringWithFormat:@"%@%@",url,KUpdate_dynamic];
    }
    return string;
}
-(void)getApprove_log_isSure_ISFromAssess:(NSString*)isAssess
{/*
  审批列表 0  我进行审批1
  */
    self.isAss = isAssess;
    if([Function isConnectionAvailable])
    {
        if(app.isPortal)
        {
            self.urlString=[self SettingURL_getApprove_log_isSure_ISFromAssess:KPORTAL_URL ISAssess:isAssess];
        }
        else
        {
           self.urlString=[self SettingURL_getApprove_log_isSure_ISFromAssess:kBASEURL ISAssess:isAssess];
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
        
        if([isAssess isEqualToString:@"1"])
        {//申请者确认
            [request setPostValue:self.str_req_index_no forKey:@"req_index_no"];
            [request setPostValue:str_replay_content forKey:@"result"];
        }
        else if([isAssess isEqualToString:@"2"])
        {//同意 拒绝
            if (sendStatus.integerValue || (self.ShowBtnFlag == 1)) {
                for (int i = 0; i < DArray.count; i ++) {
                    NSDictionary *tempDic = [DArray objectAtIndex:i];
                    NSString *keyStr0 = [NSString stringWithFormat:@"dynamicList[%d].index_no",i];
                    NSString *keyStr1 = [NSString stringWithFormat:@"dynamicList[%d].tindex_no",i];
                    NSString *keyStr2 = [NSString stringWithFormat:@"dynamicList[%d].tcontent",i];
                    NSString *indexStr = [NSString stringWithFormat:@"%d",208+i];
                    [request setPostValue:[tempDic objectForKey:@"index_no"] forKey:keyStr0];
                    [request setPostValue:[tempDic objectForKey:@"tindex_no"] forKey:keyStr1];
                    
                    for (int i = 0; i < arr_text.count; i ++) {
                        NSDictionary *tempDic = [arr_text objectAtIndex:i];
                        if ([indexStr isEqualToString:[tempDic objectForKey:@"TAG"]]) {
                            UITextField *textField = [tempDic objectForKey:indexStr];
                            [request setPostValue:textField.text forKey:keyStr2];
                        }
                    }
                }
            }
            [request setPostValue:str_ins_uid forKey:@"ins_uid"];
            [request setPostValue:str_rcontent forKey:@"rcontent"];
            [request setPostValue:self.str_index_no forKey:@"index_no"];
            [request setPostValue:self.str_req_index_no forKey:@"req_index_no"];
            [request setPostValue:str_isSubmit forKey:@"exe_sts"];
            [request setPostValue:str_replay_content forKey:@"replay_content"];
            //如果有下一位审批人的话
            if(isToOthers)
            {
                 [request setPostValue:app.str_index_no forKey:@"next_uindex_no"];
            }
        }
        else if([isAssess isEqualToString:@"0"])
        {//获得流程
            [request setPostValue:self.str_req_index_no forKey:@"req_index_no"];
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
-(void)get_JsonString:(NSString *)jsonString Type:(NSString*)type
{//ApplyInfo中的exe_sts有4种状态：0：审批中 1：拒绝 2：同意 3：终结
    //type 0 列表 1 反馈 2 同意拒绝结果
    SBJsonParser *parser = [[SBJsonParser alloc] init];
    NSDictionary *dict =[parser objectWithString: jsonString];
    if([[dict objectForKey:@"ret"] isEqualToString:@"0"])//列表返回结果
    {
        if([type isEqualToString:@"0"])//申请 审批流程表
        {
            
            [self createListView:dict];
            
        }
        else if([type isEqualToString:@"2"]||[type isEqualToString:@"1"])
        {
            [SGInfoAlert showInfo:@"提交成功!"
                          bgColor:[[UIColor darkGrayColor] CGColor]
                           inView:self.view
                         vertical:0.5];
            app.VC_notify=app.VC_Assessment; 
            self.delegate = (id)app.VC_notify ;//vc
            //指定代理对象为，second
            [self.delegate Notify_AssessDetailView];//这里获得代理方法的返回值。
            
            [self.navigationController popViewControllerAnimated:YES];
        }

    }
    else
    {
        [SGInfoAlert showInfo:[dict objectForKey:@"message"]
                      bgColor:[[UIColor darkGrayColor] CGColor]
                       inView:self.view
                     vertical:0.5];
    }
}
-(void)createListView :(NSDictionary *)dict
{//ApplyInfo中的exe_sts有4种状态：0：审批中 1：拒绝 2：同意 3：终结
    //type 0 列表 1 反馈 2 同意拒绝结果

    NSMutableArray *arr_basic=[NSMutableArray arrayWithObjects:@"审批类型",@"申请内容",@"申请相关人员",@"费用支出合计",@"申请人姓名",@"申请人地址",@"申请时间",@"申请状态", nil];
    if([Function isBlankString:self.str_type])
    {
        self.str_type=@"其他";
    }
    NSMutableArray *arr_ApplyInfo=[NSMutableArray arrayWithObjects:self.str_type,@"rcontent",@"relations",@"rsum",@"uname",@"address",@"ins_date",@"exe_sts",nil];
//----------静态数据
    momentHeight=0;
    btn_tag=0;
    //基本信息头start
    [self Row_Header:[UIColor colorWithRed:24/255.0 green:84/255.0 blue:156/255.0 alpha:1.0] Title:@"基本信息"  Pic:@"5" Background:@"icon_AddNewClerk_FirstTitle.png"];
    //基本信息头end
    NSDictionary *dic_ApplyInfo=[dict objectForKey:@"ApplyInfo"];
    sendStatus = [dic_ApplyInfo objectForKey:@"send_sts"];
    self.tsts = [dic_ApplyInfo objectForKey:@"tsts"];
    if ([self.tsts isEqualToString:@"1"]) {
        [arr_basic addObject:@"分值"];
        [arr_basic addObject:@"备注"];
        [arr_ApplyInfo addObject:@"num_sign"];
        [arr_ApplyInfo addObject:@"memo"];
    }
    ////////关键字
    str_ins_uid=[dic_ApplyInfo objectForKey:@"ins_uid"];
    str_rcontent=[dic_ApplyInfo objectForKey:@"rcontent"];
    str_rtype=[dic_ApplyInfo objectForKey:@"rtype"];
    str_req_index_no=[dic_ApplyInfo objectForKey:@"req_index_no"];
    str_glat=[dic_ApplyInfo objectForKey:@"alat"];
    str_glng=[dic_ApplyInfo objectForKey:@"alng"];
    ///////
    for(NSInteger i=0;i<arr_basic.count;i++)
    {
        UIButton *btn=[UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame=CGRectMake(near_by_thisView, momentHeight, (scrollView_Back.frame.size.width-near_by_thisView*2), combox_height_thisView);
        btn.backgroundColor=[UIColor clearColor];
        [scrollView_Back addSubview:btn];
        [btn addTarget:self action:@selector(show_action:) forControlEvents:UIControlEventTouchUpInside];
        btn.tag=buttonTag*2+btn_tag++;
        
        //属性
        UILabel *lab1=[[UILabel alloc]initWithFrame:CGRectMake(0,0, btn.frame.size.width/2-combox_height_thisView,btn.frame.size.height)];
        lab1.backgroundColor=[UIColor clearColor];
        
        lab1.text=[NSString stringWithFormat:@"  %@",[arr_basic objectAtIndex:i ]];
        lab1.font=[UIFont systemFontOfSize:app.Font];
        [btn addSubview:lab1];
        if(i==0)
        {
            [btn setImage:[UIImage imageNamed:@"set_header@2X.png"] forState:UIControlStateNormal];
            //审批类型 名称
            UILabel *lab=[[UILabel alloc]initWithFrame:CGRectMake(btn.frame.size.width/2-combox_height_thisView,0,btn.frame.size.width/2, btn.frame.size.height)];
            lab.textAlignment=NSTextAlignmentCenter;
            lab.backgroundColor=[UIColor clearColor];
            lab.text=self.str_type;
            lab.font=[UIFont systemFontOfSize:app.Font];
            [btn addSubview:lab];
            btn.userInteractionEnabled=NO;
        }
        else if(i==arr_basic.count-1)
        {
            [btn setImage:[UIImage imageNamed:@"set_bottom@2X.png"] forState:UIControlStateNormal];
        }
        else
        {
            [btn setImage:[UIImage imageNamed:@"set_middle@2X.png"] forState:UIControlStateNormal];
        }
        if(i>0)
        {
            [self creatArrow:btn];
            UITextField *textF=[[UITextField alloc]init];
            [btn addSubview:textF];
            
            if(isIOS7)
            {
                textF.frame=CGRectMake(btn.frame.size.width/2-combox_height_thisView,0,btn.frame.size.width/2, btn.frame.size.height);
            }
            else
            {
                textF.frame=CGRectMake(btn.frame.size.width/2-combox_height_thisView,btn.frame.size.height/4,btn.frame.size.width/2, btn.frame.size.height);
            }
            textF.tag=btn.tag;
            textF.enabled=NO;
            textF.backgroundColor=[UIColor clearColor];
            textF.textAlignment=NSTextAlignmentRight;
            textF.font=[UIFont systemFontOfSize:app.Font];
            if(btn.tag==207)
            {
                textF.text=[self reType: [dic_ApplyInfo objectForKey:[arr_ApplyInfo objectAtIndex:i]]];
            }
            else
            {
                textF.text=[dic_ApplyInfo objectForKey:[arr_ApplyInfo objectAtIndex:i]];
                if ((i == 8) || (i == 9)) {
                    [mutArray addObject:textF.text];
                }
            }
            [btn addSubview:textF];
            NSMutableDictionary *dic=[[NSMutableDictionary alloc]init];
            [dic setObject:textF.text forKey:@"text"];
            [dic setObject:[arr_basic objectAtIndex:i] forKey:@"title"];
            [dic setObject:@"1" forKey:@"data_type"];
            [arr_text addObject:dic];
            dic=nil;
        }
        momentHeight+=combox_height_thisView;
    }
    arr_ApplyInfo=nil;
    arr_basic=nil;
    
//********************************************************************动态数据
    DArray=[dict objectForKey:@"DynamicList"];
    if(DArray.count!=0) {
        [self Row_Header:[UIColor colorWithRed:234/255.0 green:119/255.0 blue:0/255.0 alpha:1.0] Title:@"申请详情"  Pic:@"6" Background:@"icon_AddNewClerk_NextTitle.png"];
    }
    for (NSInteger i=0; i<DArray.count; i++) {
        NSDictionary *dic=[DArray objectAtIndex:i];
        //按钮
        UIButton *btn=[UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame=CGRectMake(near_by_thisView, momentHeight, (scrollView_Back.frame.size.width-near_by_thisView*2), combox_height_thisView);
        btn.backgroundColor=[UIColor clearColor];
        [btn addTarget:self action:@selector(show_action:) forControlEvents:UIControlEventTouchUpInside];
        btn.tag=buttonTag*2+btn_tag++;
        [scrollView_Back addSubview:btn];
        [self creatArrow:btn];
        
        //属性（前面的label）
        UILabel *lab1=[[UILabel alloc]initWithFrame:CGRectMake(0,0, btn.frame.size.width/2-combox_height_thisView+60,btn.frame.size.height)];
        lab1.backgroundColor=[UIColor clearColor];
        lab1.text=[NSString stringWithFormat:@"  %@",[dic objectForKey:@"tname"]];
        lab1.font=[UIFont systemFontOfSize:app.Font];
        [btn addSubview:lab1];
        
        //文本
        UITextField *textF=[[UITextField alloc]init];
        [btn addSubview:textF];
        
        if(isIOS7) {
            textF.frame=CGRectMake(btn.frame.size.width/2-combox_height_thisView+73,0,btn.frame.size.width/2-61, btn.frame.size.height);
            textF.backgroundColor = [UIColor greenColor];
        }
        else {
            textF.frame=CGRectMake(btn.frame.size.width/2-combox_height_thisView+73,btn.frame.size.height/4,btn.frame.size.width/2-61, btn.frame.size.height);
        }
        textF.tag=btn.tag;
        textF.enabled=NO;
        textF.backgroundColor=[UIColor clearColor];
        textF.textAlignment=NSTextAlignmentRight;
        textF.font=[UIFont systemFontOfSize:app.Font];
        textF.text=[dic objectForKey:@"tcontent"];
        [btn addSubview:textF];
        
         NSMutableDictionary *dic1=[[NSMutableDictionary alloc]init];
        [dic1 setObject:lab1.text forKey:@"title"];
        [dic1 setObject:[dic objectForKey:@"data_type"] forKey:@"data_type"];   //data_type动态项目类型（0:数字，1:文本，2:金额，3:日期，4:列表）
        NSString *keyStr = [NSString stringWithFormat:@"%ld",(long)btn.tag];
        [dic1 setObject:textF forKey:keyStr];
        [dic1 setObject:textF.text forKey:@"text"];
        [dic1 setObject:keyStr forKey:@"TAG"];
        [arr_text addObject:dic1];
        dic1=nil;
        
        if(DArray.count==1) {
            [btn setImage:[UIImage imageNamed:@"set_single@2X.png"] forState:UIControlStateNormal];
        }
        else {
            if(i==0) {
                [btn setImage:[UIImage imageNamed:@"set_header@2X.png"] forState:UIControlStateNormal];
            }
            else if(i==DArray.count-1) {
                [btn setImage:[UIImage imageNamed:@"set_bottom@2X.png"] forState:UIControlStateNormal];
            }
            else {
                [btn setImage:[UIImage imageNamed:@"set_middle@2X.png"] forState:UIControlStateNormal];
            }
        }
        momentHeight+=combox_height_thisView;
        dic=nil;
    }
    
//********************************************************************申请流程
    [self Row_Header:[UIColor colorWithRed:234/255.0 green:119/255.0 blue:0/255.0 alpha:1.0] Title:@"申请流程"  Pic:@"6" Background:@"icon_AddNewClerk_NextTitle.png"];
    
    arr_ApproveList =[dict objectForKey:@"ApproveList"];
    for (NSInteger i=0; i<arr_ApproveList.count+1; i++)
    {
        if((!self.isFromWillAssess&&i==arr_ApproveList.count)||(self.isFromWillAssess&&![[dic_ApplyInfo objectForKey:@"send_sts"] isEqualToString:@"1"]&&i==arr_ApproveList.count))
        {
            continue;
        }
        
        /*btn*/
        UIButton *btn=[UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame=CGRectMake(near_by_thisView, momentHeight, (scrollView_Back.frame.size.width-near_by_thisView*2), combox_height_thisView);
        btn.userInteractionEnabled=YES;
        [btn.layer setMasksToBounds:YES];
        [btn.layer setCornerRadius:5.0];
        btn .backgroundColor=[UIColor colorWithPatternImage:[UIImage imageNamed:@"btn_color8.png"]];
        [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [scrollView_Back addSubview:btn];
        /*btn*/
        
        if(i==arr_ApproveList.count)
        {
            //label.text=@"交代他人";
            [btn setTitle:@"交代他人" forState:UIControlStateNormal];
            switchButton = [[UISwitch alloc] initWithFrame:CGRectMake(0,0,btn.frame.size.width/2,10)];
            switchButton.backgroundColor=[UIColor clearColor];
            [switchButton setOn:NO];
            [switchButton addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventValueChanged];
            [btn addSubview:switchButton];
            
           
            switchButton.center=CGPointMake(btn.frame.size.width/4*3, 22);
        }
        else
        {//sql.add(" ,CASE WHEN exe_sts = '0' THEN '拒绝' WHEN exe_sts = '1' THEN '同意' ELSE '未处理' END AS result");// 审批结果
            NSDictionary *dic=[arr_ApproveList objectAtIndex:i];
            [btn setTitle:[NSString stringWithFormat:@"【审批人】%@:%@",[dic objectForKey:@"uname"],[dic objectForKey:@"result"]] forState:UIControlStateNormal];
            if([Function isBlankString:[dic objectForKey:@"exe_sts"]])
            {//无此key "未处理"
                 btn.backgroundColor=[UIColor colorWithPatternImage:[UIImage imageNamed:@"btn_color8.png"]];
            }
            else
            {
                if([[dic objectForKey:@"exe_sts"]isEqualToString:@"0"])
                {
                    btn.backgroundColor=[UIColor colorWithPatternImage:[UIImage imageNamed:@"btn_color7.png"]];
                }
                else if([[dic objectForKey:@"exe_sts"]isEqualToString:@"1"])
                {
                     btn.backgroundColor=[UIColor colorWithPatternImage:[UIImage imageNamed:@"btn_color1.png"]];
                }
                else
                {
                     btn.backgroundColor=[UIColor colorWithPatternImage:[UIImage imageNamed:@"btn_color8.png"]];
                }
            }
            [btn  addTarget:self action:@selector(Action_Btn_Peo:) forControlEvents:UIControlEventTouchUpInside];
            btn.tag=i+buttonTag*8;
            dic=nil;
        }
        momentHeight+=combox_height_thisView;
        if(i<arr_ApproveList.count-1)
        {
            UIImageView *imageView_arrow=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"arrow.png"]];
            imageView_arrow.frame=CGRectMake(scrollView_Back.frame.size.width/2-10, momentHeight, 20, 20);
            [scrollView_Back addSubview:imageView_arrow];
            imageView_arrow=nil;
        }
        momentHeight+=20;
    }
    if(self.isFromWillAssess&&[[dic_ApplyInfo objectForKey:@"send_sts"] isEqualToString:@"1"])
    {
        //浏览人员
        btn_peo=[UIButton buttonWithType:UIButtonTypeCustom];
        btn_peo.frame=CGRectMake((Phone_Weight-300)/2, momentHeight, 300, 44);
        [btn_peo.layer setMasksToBounds:YES];
        [btn_peo.layer setCornerRadius:5.0];//设置矩形四个圆角半径
        btn_peo.backgroundColor=[UIColor clearColor];
        [scrollView_Back addSubview:btn_peo];
        btn_peo.enabled=NO;
        btn_peo.tag=buttonTag;
        [btn_peo addTarget:self action:@selector(btn_Action:) forControlEvents:UIControlEventTouchUpInside];
        [btn_peo setBackgroundImage:[UIImage imageNamed:@"btn_color5.png"] forState:UIControlStateNormal];
        [btn_peo setBackgroundImage:[UIImage imageNamed:@"btn_color5.png"] forState:UIControlStateHighlighted];
        btn_peo.titleLabel.textColor=[UIColor whiteColor];
        btn_peo.titleLabel.font=[UIFont systemFontOfSize:15];
        [btn_peo setTitle:@"浏览人员" forState:UIControlStateNormal];
    
        momentHeight+=combox_height_thisView+20;
        
        UIImageView *imgView_back=[[UIImageView alloc]init];
        imgView_back.frame=CGRectMake(near_by_thisView, momentHeight, (scrollView_Back.frame.size.width-near_by_thisView*2), combox_height_thisView);
        imgView_back.backgroundColor=[UIColor clearColor];
        imgView_back.image=[UIImage imageNamed:@"icon_line_lightgray_viewback@2X.png"];
        [scrollView_Back addSubview:imgView_back];
        //后续审批人
        label_later=[[UILabel alloc]initWithFrame:CGRectMake(0,0, imgView_back.frame.size.width, imgView_back.frame.size.height)];
        label_later.textAlignment=NSTextAlignmentCenter;
        label_later.backgroundColor=[UIColor clearColor];
        label_later.font=[UIFont systemFontOfSize:app.Font];
        [imgView_back addSubview:label_later];
        label_later.text=@"【后续审批人】无";
         momentHeight+=combox_height_thisView+10;
    }
 
//********************************************************************媒体图片
    NSArray *arr_MediaList =[dict objectForKey:@"MediaList"];
    if(arr_MediaList.count!=0)
    {
        [self Row_Header:[UIColor colorWithRed:25/255.0 green:35/255.0 blue:49/255.0 alpha:1.0] Title:@"媒体信息" Pic:@"4" Background:@"icon_AddNewClerk_NextTitle.png"];
    }
    for (NSInteger i=0; i<arr_MediaList.count; i++)
    {
        UIImageView *imgView_back=[[UIImageView alloc]init];
        imgView_back.frame=CGRectMake(near_by_thisView, momentHeight, (scrollView_Back.frame.size.width-near_by_thisView*2), combox_height_thisView*2);
        imgView_back.backgroundColor=[UIColor clearColor];
        imgView_back.userInteractionEnabled=YES;
        [scrollView_Back addSubview:imgView_back];
        if(arr_MediaList.count==1)
        {
            [imgView_back setImage:[UIImage imageNamed:@"set_single@2X.png"]];
        }
        else
        {
            if(i==0)
            {
                [imgView_back setImage:[UIImage imageNamed:@"set_header@2X.png"]];
            }
            else if(i==arr_MediaList.count-1)
            {
                [imgView_back setImage:[UIImage imageNamed:@"set_bottom@2X.png"]];
            }
            else
            {
                [imgView_back setImage:[UIImage imageNamed:@"set_middle@2X.png"]];
            }
        }
        NSDictionary *dic=[arr_MediaList objectAtIndex:i];
        //图片按钮
        UIImageView *view_btn=[[UIImageView alloc]init];
        view_btn.frame=CGRectMake(imgView_back.frame.size.width- imgView_back.frame.size.height ,10,imgView_back.frame.size.height-20,imgView_back.frame.size.height-20);
        view_btn.backgroundColor=[UIColor clearColor];
        [imgView_back addSubview:view_btn];
        view_btn.userInteractionEnabled=YES;
        [view_btn setImageWithURL:[dic objectForKey:@"mpath_small"]
                placeholderImage:[UIImage imageNamed:@"default_picture.png"]
                         success:^(UIImage *image) {//Dlog(@" 图片显示成功OK");
                         }
                         failure:^(NSError *error) {//Dlog(@" 顶图片显示失败NO");
                         }];
        UIButton *btn=[UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame=CGRectMake(0, 0, view_btn.frame.size.width, view_btn.frame.size.height);
        btn.backgroundColor=[UIColor clearColor];
        btn.tag=buttonTag/2+i;
        [btn addTarget:self action:@selector(BigImageAction:) forControlEvents:UIControlEventTouchUpInside];
        [view_btn addSubview:btn];
        [arr_imageView addObject:[dic objectForKey:@"mpath"]];
        
        //图片描述
        UILabel *lab_describ=[[UILabel alloc]initWithFrame:CGRectMake(0, 0, imgView_back.frame.size.width-view_btn.frame.size.width, imgView_back.frame.size.height)];
        lab_describ.backgroundColor=[UIColor clearColor];
        lab_describ.textAlignment=NSTextAlignmentCenter;
        lab_describ.text=[dic objectForKey:@"clabel"];
        lab_describ.font=[UIFont systemFontOfSize:app.Font];
        [imgView_back addSubview:lab_describ];
        momentHeight+=imgView_back.frame.size.height;
        dic=nil;
    }
    momentHeight+=20;
    arr_MediaList=nil;
//查看物料按钮
    if(self.isMaterial)
    {
        UIButton *btn=[UIButton buttonWithType:UIButtonTypeCustom];
        [btn.layer setMasksToBounds:YES];
        [btn.layer setCornerRadius:5.0];//设置矩形四个圆角半径
        btn.frame=CGRectMake((Phone_Weight-300)/2, momentHeight, 300, combox_height_thisView);
        btn.backgroundColor=[UIColor clearColor];
        [btn setBackgroundImage:[UIImage imageNamed:@"btn_color6.png"] forState:UIControlStateNormal];
        [btn setBackgroundImage:[UIImage imageNamed:@"btn_color1.png"] forState:UIControlStateHighlighted];
        [btn addTarget:self action:@selector(btn_Action:) forControlEvents:UIControlEventTouchUpInside];
        [scrollView_Back  addSubview:btn];
        
        btn.titleLabel.textColor=[UIColor whiteColor];
        btn.titleLabel.font=[UIFont systemFontOfSize:15];
        btn.tag=buttonTag-2;
        [btn setTitle:@"点击查看审批物料" forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(btn_Action:) forControlEvents:UIControlEventTouchUpInside];
        momentHeight+=combox_height_thisView+10;
    }
//==============同意按钮和拒绝按钮
    if(self.isFromWillAssess&&[[dic_ApplyInfo objectForKey:@"send_sts"] isEqualToString:@"1"])
    {
        for (NSInteger i=0; i<2; i++)
        {
            UIButton *btn =[UIButton buttonWithType:UIButtonTypeCustom];
            btn.frame=CGRectMake(near_by_thisView+i*(10+(Phone_Weight-near_by_thisView*2)/2-5) ,momentHeight , (Phone_Weight-near_by_thisView*2)/2-5,combox_height_thisView);
            [btn.layer setMasksToBounds:YES];
            [btn.layer setCornerRadius:5.0];//设置矩形四个圆角半径
            btn .backgroundColor=[UIColor clearColor];
            [scrollView_Back addSubview:btn ];
            
            [btn  addTarget:self action:@selector(btn_Action:) forControlEvents:UIControlEventTouchUpInside];
            if(i==0)
            {
                //@"同意";
                [btn setBackgroundImage:[UIImage imageNamed:@"btn_color2.png"] forState:UIControlStateNormal];
                [btn setBackgroundImage:[UIImage imageNamed:@"btn_color1.png"] forState:UIControlStateHighlighted];
                [btn setTitle:@"同意" forState:UIControlStateNormal];
                btn .tag=buttonTag+1;
                assessPerson = 0;
            }
            else
            {
                //@"拒绝";
                [btn setBackgroundImage:[UIImage imageNamed:@"btn_color7.png"] forState:UIControlStateNormal];
                [btn setBackgroundImage:[UIImage imageNamed:@"btn_color1.png"] forState:UIControlStateHighlighted];
                [btn setTitle:@"拒绝" forState:UIControlStateNormal];
                btn .tag=buttonTag+2;
            }
        }
    }
    else
    {
        if(isAgree&&[[dic_ApplyInfo objectForKey:@"exe_sts"] isEqualToString:@"2"]&&!self.isFromWillAssess && !self.ShowBtnFlag)
        {
           // momentHeight+=20;
            UIButton *btn =[UIButton buttonWithType:UIButtonTypeCustom];
            btn.frame=CGRectMake((Phone_Weight-300)/2, momentHeight, 300, 44);
            [btn.layer setMasksToBounds:YES];
            [btn.layer setCornerRadius:5.0];//设置矩形四个圆角半径
            btn .backgroundColor=[UIColor clearColor];
            [scrollView_Back addSubview:btn ];
            [btn  addTarget:self action:@selector(btn_Action:) forControlEvents:UIControlEventTouchUpInside];
            btn.titleLabel.textColor=[UIColor whiteColor];
            btn.titleLabel.font=[UIFont systemFontOfSize:16];
            [btn setTitle:@"申请反馈" forState:UIControlStateNormal];
            [btn setBackgroundImage:[UIImage imageNamed:@"btn_color3.png"] forState:UIControlStateNormal];
            [btn setBackgroundImage:[UIImage imageNamed:@"btn_color5.png"] forState:UIControlStateHighlighted];
            btn .tag=buttonTag+3;
        }
    }
    dict=nil;
    
    //评价Button
    UIButton *markButton = [UIButton buttonWithType:UIButtonTypeCustom];
    if ([self.tsts isEqualToString:@"1"]) {
        markButton.frame = CGRectMake(10, self.isFromWillAssess?momentHeight+60:momentHeight+10, 300, combox_height_thisView);
        if(isAgree&&[[dic_ApplyInfo objectForKey:@"exe_sts"] isEqualToString:@"2"]&&!self.isFromWillAssess && !self.ShowBtnFlag) {
            markButton.top = momentHeight + 50;
        }
        if (assessPerson == 1) {
            markButton.top = momentHeight;
        }
        [markButton setBackgroundImage:[UIImage imageNamed:@"btn_color6.png"] forState:UIControlStateNormal];
        [markButton setTitle:@"评价" forState:UIControlStateNormal];
        [markButton addTarget:self action:@selector(markAction) forControlEvents:UIControlEventTouchUpInside];
        [markButton.layer setMasksToBounds:YES];
        [markButton.layer setCornerRadius:5.0];
        markButton.backgroundColor=[UIColor clearColor];
        [scrollView_Back addSubview:markButton];
        momentHeight+=120;
    }else {
        markbuttonFlag = 1;
    }
    
    //取得修改日志Button
    UIButton *modiRecordBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    modiRecordBtn.frame = CGRectMake(10, momentHeight, 300, combox_height_thisView);
    [modiRecordBtn setBackgroundImage:[UIImage imageNamed:@"btn_color6.png"] forState:UIControlStateNormal];
    [modiRecordBtn setTitle:@"操作记录" forState:UIControlStateNormal];
    [modiRecordBtn addTarget:self action:@selector(GotoRecordVC) forControlEvents:UIControlEventTouchUpInside];
    [modiRecordBtn.layer setMasksToBounds:YES];
    [modiRecordBtn.layer setCornerRadius:5.0];
    modiRecordBtn.backgroundColor=[UIColor clearColor];
    [scrollView_Back addSubview:modiRecordBtn];
    
    if (markbuttonFlag == 1 && self.isFromWillAssess) {
        modiRecordBtn.top += 60;
        momentHeight += 60;
    }
    
    if (self.ShowBtnFlag == 1) {
        UIButton *saveBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        saveBtn.frame = CGRectMake(10, momentHeight+10, 300, combox_height_thisView);
        [saveBtn setBackgroundImage:[UIImage imageNamed:@"btn_color6.png"] forState:UIControlStateNormal];
        [saveBtn setTitle:@"保存" forState:UIControlStateNormal];
        [saveBtn addTarget:self action:@selector(pressSaveButton) forControlEvents:UIControlEventTouchUpInside];
        [saveBtn.layer setMasksToBounds:YES];
        [saveBtn.layer setCornerRadius:5.0];
        saveBtn.backgroundColor=[UIColor clearColor];
        [scrollView_Back addSubview:saveBtn];
        momentHeight+=70;
    }
    
    if (assessPerson != 0 && [self.tsts isEqualToString:@"1"]) {
        modiRecordBtn.top = markButton.bottom +20;
        momentHeight-=70;
    }
    momentHeight+=70;
    
    scrollView_Back.contentSize=CGSizeMake(0, momentHeight);
}

- (void)pressSaveButton {
    if([Function isConnectionAvailable])
    {
        if(app.isPortal)
        {
            self.urlString=[self SettingURL_getApprove_log_isSure_ISFromAssess:KPORTAL_URL ISAssess:@"5"];
        }
        else
        {
            self.urlString=[self SettingURL_getApprove_log_isSure_ISFromAssess:kBASEURL ISAssess:@"5"];
        }
        
        NSURL *url = [NSURL URLWithString:self.urlString];
        ASIFormDataRequest *request = [ ASIFormDataRequest requestWithURL :url];
        request.delegate = self;
        request.tag = 112;
        [request setRequestMethod:@"POST"];
        
        [request setPostValue:[[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"account"]forKey:KUSER_UID];
        [request setPostValue:[[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"secret"] forKey:KUSER_PASSWORD];
        [request setPostValue:[[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"token"] forKey:@"user.token"];
        [request setPostValue:[[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"db_ip"] forKey:@"db_ip"];
        [request setPostValue:[[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"db_name"] forKey:@"db_name"];
        
        [request setPostValue:self.str_req_index_no forKey:@"req_index_no"];
        if (sendStatus.integerValue || (self.ShowBtnFlag == 1)) {
            for (int i = 0; i < DArray.count; i ++) {
                NSDictionary *tempDic = [DArray objectAtIndex:i];
                NSString *keyStr0 = [NSString stringWithFormat:@"dynamicList[%d].index_no",i];
                NSString *keyStr1 = [NSString stringWithFormat:@"dynamicList[%d].tindex_no",i];
                NSString *keyStr2 = [NSString stringWithFormat:@"dynamicList[%d].tcontent",i];
                NSString *indexStr = [NSString stringWithFormat:@"%d",211+i];
                
                [request setPostValue:[tempDic objectForKey:@"index_no"] forKey:keyStr0];
                [request setPostValue:[tempDic objectForKey:@"tindex_no"] forKey:keyStr1];
                
                for (int i = 0; i < arr_text.count; i ++) {
                    NSDictionary *tempDic = [arr_text objectAtIndex:i];
                    if ([indexStr isEqualToString:[tempDic objectForKey:@"TAG"]]) {
                        UITextField *textField = [tempDic objectForKey:indexStr];
                        [request setPostValue:textField.text forKey:keyStr2];
                    }
                }
            }
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

//跳转到修改日志界面
- (void)GotoRecordVC {
    if([Function isConnectionAvailable])
    {
        if(app.isPortal)
        {
            self.urlString=[self SettingURL_getApprove_log_isSure_ISFromAssess:KPORTAL_URL ISAssess:@"4"];
        }
        else
        {
            self.urlString=[self SettingURL_getApprove_log_isSure_ISFromAssess:kBASEURL ISAssess:@"4"];
        }
        
        NSURL *url = [NSURL URLWithString:self.urlString];
        ASIFormDataRequest *request = [ ASIFormDataRequest requestWithURL :url];
        request.delegate = self;
        request.tag = 111;
        [request setRequestMethod:@"POST"];
        
        [request setPostValue:[[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"account"]forKey:KUSER_UID];
        [request setPostValue:[[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"secret"] forKey:KUSER_PASSWORD];
        [request setPostValue:[[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"token"] forKey:@"user.token"];
        [request setPostValue:[[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"db_ip"] forKey:@"db_ip"];
        [request setPostValue:[[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"db_name"] forKey:@"db_name"];
        
        [request setPostValue:self.str_req_index_no forKey:@"req_index_no"];
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

- (void)markAction {
    MarkViewController *markVC = [MarkViewController new];
    markVC.req_index_no = self.str_req_index_no;
    markVC.secondArray = mutArray;
    mutArray = [NSMutableArray array];
    [self.navigationController pushViewController:markVC animated:YES];
}

-(void)Row_Header:(UIColor *)color Title:(NSString *)title Pic:(NSString *)png Background:(NSString*)name
{
    //信息start
    UIImageView *imgView=[[UIImageView alloc]init];
    imgView.frame=CGRectMake(0, momentHeight, Phone_Weight, 53);
    imgView.image=[UIImage imageNamed:name];
    [scrollView_Back addSubview:imgView];
    UILabel *lab=[[UILabel alloc]init];
    lab.frame=CGRectMake(54, 8, 100, 38);
    lab.backgroundColor=[UIColor clearColor];
    lab.textColor=color;
    lab.text=title;
    lab.font=[UIFont systemFontOfSize:19.0];
    [imgView addSubview:lab];
    UIImageView *imgView_icon1=[[UIImageView alloc]init];
    imgView_icon1.frame=CGRectMake(14, 10, 32, 32);
    imgView_icon1.backgroundColor=[UIColor clearColor];
    imgView_icon1.image=[UIImage imageNamed:[NSString stringWithFormat:@"iconic_%@.png",png]];
    [imgView addSubview:imgView_icon1];
    [scrollView_Back addSubview:imgView];
    momentHeight+=10+imgView.frame.size.height;
    //end
}
-(void)creatArrow:(UIButton *)btn
{//右侧小箭头
    UIImageView *imgView_arrow=[[UIImageView alloc]init];
    imgView_arrow.backgroundColor=[UIColor clearColor];
    imgView_arrow.image=[UIImage imageNamed:@"icon_everyline_arrow.png"];
    imgView_arrow.frame=CGRectMake(270,(44-10)/2.0, 6, 10);
    [btn addSubview:imgView_arrow];
}
-(void)BigImageAction:(UIButton *)btn
{
    UIImageView *imgView=[[UIImageView alloc]init];
    __weak UIImageView *weakImageView = imgView;
    NSString *tempURLString = [arr_imageView objectAtIndex:btn.tag-buttonTag/2];
    if (([tempURLString rangeOfString:@"jpg"].location != NSNotFound) ||
        ([tempURLString rangeOfString:@"png"].location != NSNotFound)) {
        [imgView setImageWithURL:[arr_imageView objectAtIndex:btn.tag-buttonTag/2]
                placeholderImage:[UIImage imageNamed:@"default_picture.png"]
                         success:^(UIImage *image) {//Dlog(@" 图片显示成功OK");
                             weakImageView.image=image;
                             [self view_image_AllScreen:weakImageView];
                         }
                         failure:^(NSError *error) {//Dlog(@" 顶图片显示失败NO");
                         }];

    }else {
        DocumentViewController *docVC=[[DocumentViewController alloc]init];
        docVC.titleString=@"文件";
        docVC.mutiSelect = 1;
        docVC.str_Url=tempURLString;
        docVC.str_isGraph=@"1";
        [self.navigationController pushViewController:docVC animated:YES];
    }
}
-(void)view_image_AllScreen:(UIImageView *) image
{
    ///////////可伸缩图片
    UIScrollView *scroll=[[UIScrollView alloc]init];
    scroll.frame=CGRectMake(0, 0, view_imageView_back.frame.size.width, view_imageView_back.frame.size.height);
    scroll.backgroundColor=[UIColor whiteColor];
    scroll .delegate=self;
    scroll.multipleTouchEnabled=YES;
    scroll.showsHorizontalScrollIndicator = NO;
    scroll.showsVerticalScrollIndicator = NO;
    [scroll setContentSize:CGSizeMake(scroll.frame.size.width, scroll.frame.size.height)];
    self.zoomScrollView = [[MRZoomScrollView alloc]init];
    CGRect frame = scroll.frame;
    frame.origin.x = 0 ;
    frame.origin.y = 0;
    self.zoomScrollView.frame = frame;
    self.zoomScrollView.imageView.image=image.image;
    self.zoomScrollView.imageView.frame=[Function scaleImage:image.image toSize: CGRectMake(0.0, 0.0, Phone_Weight, Phone_Height)];
    scroll.backgroundColor=[UIColor blackColor];
    
    [scroll addSubview: self.zoomScrollView];
    [view_imageView_back addSubview:scroll];
    [self.view addSubview:view_imageView_back];
    ///////////可伸缩图片
    
    //识别单指点击 退出大图 start
    UITapGestureRecognizer *singleTap =[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)] ;
    [singleTap setNumberOfTapsRequired:1];
    [self.zoomScrollView  addGestureRecognizer:singleTap];
    singleTap=nil;
    scroll=nil;
    self.zoomScrollView=nil;
    //识别单指点击 退出大图 end
    
}
-(void)handleSingleTap:(UITapGestureRecognizer *)sender
{
    [self cancel_AllScreen];
}
-(void)cancel_AllScreen
{
    [view_imageView_back removeFromSuperview];
}

-(NSString *)reType:(NSString *)str
{//exe_sts有4种状态：0：审批中 1：拒绝 2：同意 3：终结
    if([str isEqualToString:@"1"])
    {
        isAgree=YES;
        return @"拒绝";
    }
    else if([str isEqualToString:@"2"])
    {
        isAgree=YES;
        return @"同意";
    }
    else if([str isEqualToString:@"3"])
    {
        return @"终结";
    }
    else//0或者其他
    {
        return @"审批中";
    }
}

-(void)Action_Btn_Peo:(UIButton*)btn
{
    UIActionSheet *actionSheet =[[UIActionSheet alloc]initWithTitle:@"您想通过何种方式和当前审批人联系" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"通过应用发消息",@"打电话",@"发短信",@"查看批复反馈", nil];
    [actionSheet showInView:self.view];
    actionSheet.tag=btn.tag-8*buttonTag;
}
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    //Dlog(@"%ld",(long)buttonIndex);//2--->取消
    if(buttonIndex==0)
    {
        SendMessageViewController *send=[[SendMessageViewController alloc]init];
        NSDictionary *dic=[arr_ApproveList objectAtIndex:actionSheet.tag];
        send.str_peo=[dic objectForKey:@"uname"];
        if (![Function isBlankString:[dic objectForKey:@"umtel"]])
        {
            send.str_tel=[dic objectForKey:@"umtel"];
        }
        else  send.str_tel=@"暂无";
        send.str_mtype=@"0";
        send.str_index_no=[dic objectForKey:@"next_uindex_no"];
        [self.navigationController pushViewController:send animated:YES];
    }
    else if (buttonIndex==1)
    {
         NSDictionary *dic=[arr_ApproveList objectAtIndex:actionSheet.tag];
        if (![Function isBlankString:[dic objectForKey:@"umtel"]])
        {
            UIWebView*callWebview =[[UIWebView alloc] init];
            NSURL *telURL =[NSURL URLWithString:[NSString stringWithFormat:@"tel:%@",[dic objectForKey:@"umtel"]]];
            [callWebview loadRequest:[NSURLRequest requestWithURL:telURL]];
            //记得添加到view上
            [self.view addSubview:callWebview];
        }
        else
        {
            [SGInfoAlert showInfo:@"号码不合法"
                          bgColor:[[UIColor darkGrayColor] CGColor]
                           inView:self.view
                         vertical:0.5];
        }
    }
    else if(buttonIndex==2)
    {
        NSDictionary *dic=[arr_ApproveList objectAtIndex:actionSheet.tag];
        if (![Function isBlankString:[dic objectForKey:@"umtel"]])
        {
             [self showMessageView:[dic objectForKey:@"umtel"]];
        }
        else
        {
            [SGInfoAlert showInfo:@"号码不合法"
                          bgColor:[[UIColor darkGrayColor] CGColor]
                           inView:self.view
                         vertical:0.5];
        }
    }
    else if(buttonIndex==3) {
        NSDictionary *dic=[arr_ApproveList objectAtIndex:actionSheet.tag];
        NoteViewController *noteVC=[[NoteViewController alloc]init];
        noteVC.str_title=@"查看批复反馈";
        noteVC.str_content=[dic objectForKey:@"replay_content"];
        noteVC.isDetail=YES;
        [self.navigationController pushViewController:noteVC animated:YES];
        noteVC=nil;
    }
}
- (void)showMessageView:(NSString *)tel
{
    
    if( [MFMessageComposeViewController canSendText] ){
        
        MFMessageComposeViewController * controller = [[MFMessageComposeViewController alloc]init]; //autorelease];
        
        controller.recipients = [NSArray arrayWithObject:tel];
        //controller.body = @"测试发短信";
        controller.messageComposeDelegate = self;
        [self presentModalViewController:controller animated:YES];
        [[[[controller viewControllers] lastObject] navigationItem] setTitle:@"短信"];//修改短信界面标题
    }else{
        [self alertWithTitle:@"提示信息" msg:@"设备没有短信功能"];
    }
}
- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result{

}
- (void) alertWithTitle:(NSString *)title msg:(NSString *)msg {
    
    [SGInfoAlert showInfo:msg
                  bgColor:[[UIColor darkGrayColor] CGColor]
                   inView:self.view
                 vertical:0.5];
    
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)requestFinished:(ASIHTTPRequest *)request {
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    NSString * jsonString  =[request responseString];
    if (request.tag == 111) {
        SBJsonParser *parser = [[SBJsonParser alloc] init];
        NSDictionary *dict =[parser objectWithString:jsonString];
        if([[dict objectForKey:@"ret"] isEqualToString:@"0"]) {
            ModiLogViewController *modiLogVC = [ModiLogViewController new];
            modiLogVC.dataDic = dict;
            [self.navigationController pushViewController:modiLogVC animated:YES];
            return;
        }
    }
    if (request.tag == 112) {
        SBJsonParser *parser = [[SBJsonParser alloc] init];
        NSDictionary *dict =[parser objectWithString:jsonString];
        if([[dict objectForKey:@"ret"] isEqualToString:@"0"]) {
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
    if([request responseStatusCode]==200)
    {
        [self get_JsonString:jsonString Type:self.isAss];
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

@end
