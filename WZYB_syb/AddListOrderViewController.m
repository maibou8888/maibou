//
//  AddListOrderViewController.m
//  WZYB_syb
//
//  Created by wzyb on 14-6-28.
//  Copyright (c) 2014年 WZYB. All rights reserved.
//

#import "AddListOrderViewController.h"
#import "NoteViewController.h"
#import "AppDelegate.h"
#import "PresentView.h"
#import "KGModal.h"
#import <QuartzCore/QuartzCore.h>

@interface AddListOrderViewController ()<zbarNewViewDelegate,ASIHTTPRequestDelegate,PresentViewDelegate>
{
    AppDelegate *app;
    NSString *remarkStr;
    NSString *switchStr;
    NSInteger rewardFlag;
}

@property (strong, nonatomic) IBOutlet UILabel *rewardLabel;
@property (strong, nonatomic) IBOutlet UILabel *giftLabel;
@property (strong, nonatomic) IBOutlet UITextField *rewardTextField;
@property (strong, nonatomic) IBOutlet UISwitch *switchBtn;
@property (strong, nonatomic) IBOutlet UIButton *rewardBtn;
@property (strong, nonatomic) IBOutlet UIButton *giftBtn;
@property (strong, nonatomic) IBOutlet UIImageView *rewardImageLine;
@property (strong, nonatomic) IBOutlet UIImageView *realBtnImage;
@property (strong, nonatomic) IBOutlet UIImageView *realTotalImage;

@end

@implementation AddListOrderViewController

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
    isFirst=YES;
    chooseBack = NO;
    self.lab_numUnit.text=@"数量";
    self.lab_stock_Unit.text=@"库存";
    remarkStr = [NSString string];
    switchStr = [NSString string];
    
    [self All_Init];
    [self Create_Scroll];
    
    img_arrow.image=[UIImage imageNamed:@"icon_everyline_arrow.png"];
    if(app.isApproval)
    {
        text_real.hidden=YES;
        label_realwords.hidden=YES;
        btn_real.hidden=YES;
        [btn_should setBackgroundImage:[UIImage imageNamed:@"set_bottom@2X.png"] forState:UIControlStateNormal];
        img_arrow.hidden=YES;
        lab_should.text=@"合计(元)";
    }
    if (self.returnFlag) {
        lab_should.text = @"应付合计";
        label_realwords.text = @"实付合计";
    }
}

- (void)HiddenSomeScript {
    self.rewardBtn.hidden = YES;
    self.rewardLabel.hidden = YES;
    self.rewardTextField.hidden = YES;
    self.giftBtn.hidden = YES;
    self.giftLabel.hidden = YES;
    self.switchBtn.hidden = YES;
    self.rewardImageLine.hidden = YES;
    [btn_real setBackgroundImage:ImageName(@"set_bottom@2X.png") forState:UIControlStateNormal];
}

-(void)Create_Scroll
{
    scroll_back.backgroundColor=[UIColor whiteColor];
    scroll_back.frame=CGRectMake(0, 44+moment_status, Phone_Weight,Phone_Height-44-moment_status);
    [self.view addSubview:scroll_back];
    
    [self Row_ScrollView:scroll_back
                  Header:[UIColor colorWithRed:43.0/255.0 green:132/255.0 blue:210/255.0 alpha:1.0]
                   Title:@"单品订单"
                     Pic:@"10"
              Background:@"icon_AddNewClerk_FirstTitle.png"];
    
    if([self.str_Detail isEqualToString:@"3"]) //物料
    {
        text_name.placeholder=@"必填";//10
        text_count.placeholder=@"必填";//17
        text_total.placeholder=@"必填";//18
        text_real.placeholder=@"必填";//19
        text_real_price.placeholder=@"必填";//16
        [self Buid_SubmitBtn];
    }
    else if([self.str_Detail isEqualToString:@"2"])
    {//查看详细
        self.lab_stock_Unit.hidden=YES;
        BOOL isFlag=NO;
        for(NSInteger i=0;i<sectionName.count;i++)
        {
            NSDictionary *dic=[sectionName objectAtIndex:i];
            
            for (NSInteger j=0;j<dic.count;j++)
            {
                if([[dic objectForKey:@"index_no"] isEqualToString:self.str_index_no_fromSuper])
                {
                    isFlag=YES;
                    self.str_address=[dic objectForKey:@"poo"]; //产地
                    self.str_code=[dic objectForKey:@"ptype"];  //extra(型号)
                    if([Function isBlankString:[dic objectForKey:@"ext1"]]) //品牌
                        text_branded.text=@" ";
                    else
                    text_branded.text=[dic objectForKey:@"ext1"];
                    break;
                }
            }
            if(isFlag) break;
        }
        if(!isFlag)
        {
            self.str_address=@"";
            self.str_code=@"";
        }
        text_name.text=self.str_name;
        text_code.text=self.str_code;
        text_address.text=self.str_address;
        text_price.text=self.str_price;
        text_real_price.text=self.str_real_price;
        text_count.text=self.str_count;
        text_total.text=self.str_total;
        text_real.text=self.str_real;
        self.rewardTextField.text = self.str_momo;
        self.switchBtn.on = self.str_switch.integerValue;
        self.lab_numUnit.text=[NSString stringWithFormat:@"数量(%@)",self.str_numUnit];
        self.lab_stock_Unit.text=[NSString stringWithFormat:@"库存(%@)",self.str_numUnit];

        if([text_real.text floatValue]<[text_total.text floatValue])
        {
            text_real.textColor=[UIColor redColor];
        }
        else
        {
            text_real.textColor=[UIColor colorWithRed:43.0/255.0 green:132/255.0 blue:210/255.0 alpha:1.0];
        }
    }
    else if([self.str_Detail isEqualToString:@"1"])
    {//二次编辑
        [self Buid_SubmitBtn];
        NSDictionary *dic_unit=[[AddProduct sharedInstance].arr_AddToList objectAtIndex:[self.str_Index integerValue]];
        self.lab_numUnit.text=[NSString stringWithFormat:@"数量(%@)",[dic_unit objectForKey:@"unit"]];
        self.lab_stock_Unit.text=[NSString stringWithFormat:@"库存(%@)",[dic_unit objectForKey:@"unit"]];
 
        remarkStr = [dic_unit objectForKey:@"remark"];
        switchStr = [dic_unit objectForKey:@"switch"];
        str_unit_clabel=[dic_unit objectForKey:@"unit"];
        str_pcode=[dic_unit objectForKey:@"pcode"];
        str_index_no=[dic_unit objectForKey:@"pindex_no"];
        text_stock_num.text=[dic_unit objectForKey:@"stock_cnt"];
        text_branded.text=[dic_unit objectForKey:@"ext1"];
        
        self.rewardTextField.text = remarkStr;
        self.switchBtn.on = switchStr.integerValue;
        
        for (NSInteger i=0; i<array_TextField.count; i++)
        {
            UITextField *text=[array_TextField objectAtIndex:i];
            switch (i) {
                case 0:
                    text.text=[dic_unit objectForKey:@"name"];
                    break;
                case 1:
                     text.text=[dic_unit objectForKey:@"type"];
                    break;
                case 2:
                    text.text=[dic_unit objectForKey:@"address"];
                    break;
                case 3:
                    text.text=[dic_unit objectForKey:@"price"];
                    break;
                case 4:
                    text.text=[dic_unit objectForKey:@"selling_price"];
                    break;
                case 5:
                    text.text=[dic_unit objectForKey: @"cnt"];
                    break;
                case 6:
                    text.text=[dic_unit objectForKey:@"should"];
                    break;
                case 7:
                    text.text=[dic_unit objectForKey:@"real_rsum"];
                    break;
                default:
                    break;
            }
        }
        if([text_real.text floatValue]<[text_total.text floatValue])
        {
            text_real.textColor=[UIColor redColor];
        }
        else
        {
            text_real.textColor=[UIColor colorWithRed:43.0/255.0 green:132/255.0 blue:210/255.0 alpha:1.0];
        }
    }
}
-(void)Buid_SubmitBtn
{
    [array_TextField addObject:text_name];
    [array_TextField addObject:text_code];
    [array_TextField addObject:text_address];
    [array_TextField addObject:text_price];
    [array_TextField addObject:text_real_price];
    [array_TextField addObject:text_count];
    [array_TextField addObject:text_total];
    [array_TextField addObject:text_real];
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    if(isFirst)
    {//第一次进入当前页面
        btn_submit=[UIButton buttonWithType:UIButtonTypeCustom];
        if(app.isApproval)
        {//下物料  隐藏 实收合计 库存数量  实收单价
            if([self.str_Detail isEqualToString:@"2"])
            {//只读状态 隐藏确定按钮
                btn_submit.hidden=YES;
            }

            [self Set_Detail];

        }
        else
        {
            if([self.str_Detail isEqualToString:@"2"])
            {//只读状态 隐藏库存数量
                [self Set_Detail2];
                btn_submit.hidden=YES;
            }
            else
            {//编辑状态 暂无
                
            }
        }
        //
        if(app.isApproval || chooseBack)
        {
            btn_submit.frame=CGRectMake((Phone_Weight-300)/2,text_total.frame.origin.y+44+20, 300, 44);
        }
        else
        {
            btn_submit.frame=CGRectMake((Phone_Weight-300)/2,app.GiftFlagStr.integerValue?text_real.frame.origin.y+44+108:text_real.frame.origin.y+44+20, 300, 44);
        }
        [btn_submit.layer setMasksToBounds:YES];
        [btn_submit.layer setCornerRadius:5.0];
        [btn_submit setTitle:@"确定" forState:UIControlStateNormal];
        
        btn_submit.titleLabel.textColor=[UIColor whiteColor];
        btn_submit.titleLabel.font=[UIFont systemFontOfSize:15];
        btn_submit.backgroundColor=[UIColor clearColor];
        btn_submit.tag=buttonTag+4;
        [btn_submit setBackgroundImage:[UIImage imageNamed:@"btn_color6.png"] forState:UIControlStateNormal];
        [btn_submit setBackgroundImage:[UIImage imageNamed:@"btn_color1.png"] forState:UIControlStateHighlighted];
        [btn_submit addTarget:self action:@selector(btn_Action:) forControlEvents:UIControlEventTouchUpInside];
        [scroll_back addSubview:btn_submit];
        
        momentHeight=btn_submit.frame.origin.y+44+44;
        isFix_Real_UnitPrice=NO;
        if(momentHeight<scroll_back.frame.size.height)
            momentHeight=scroll_back.frame.size.height;
        scroll_back.contentSize=CGSizeMake(0, momentHeight+44);
        isFirst=NO;
        return;
    }

    if(momentHeight<scroll_back.frame.size.height)
        momentHeight=scroll_back.frame.size.height;
    scroll_back.contentSize=CGSizeMake(0, momentHeight+44);
    
    if([self.str_Detail isEqualToString:@"2"])
    {
        self.lab_numUnit.text=[NSString stringWithFormat:@"数量(%@)",self.str_numUnit];
         return;
    }
    if(isChoose)
    {
        isChoose=NO;
        if ([app returnYES] || ![Function isConnectionAvailable]) {
            [self Priorty];
            text_stock_num.text = [app.offLineDic objectForKey:@"stock_cnt"];
            text_real_price.text = [app.offLineDic objectForKey:@"price"];
        }else {
            if([Function isBlankString:app.str_choose])
                return;
            if(app.isApproval || chooseBack)
            {
                [self getStock_And_SellingPrice];
                return;
            }
        }
    }
    if(isWirte)
    {
        //isWirte=NO;
        text_count.text=app.str_temporary;
    }
    if(isFix_Real)
    {
        isFix_Real=NO;
        text_real.text=app.str_temporary;
        if([text_real.text floatValue]<[text_total.text floatValue])
        {
            text_real.textColor=[UIColor redColor];
        }
        else
        {
            text_real.textColor=[UIColor colorWithRed:43.0/255.0 green:132/255.0 blue:210/255.0 alpha:1.0];
        }
        return;
    }
    if(isFix_Real_UnitPrice)
    {
        isFix_Real_UnitPrice=NO;
        text_real_price.text=app.str_temporary;
    }
    if (rewardFlag) {
        remarkStr = [NSString stringWithFormat:@"%@",app.str_temporary];
        self.rewardTextField.text = app.str_temporary;
    }
    [self The_TextReal_Color];
}
-(void)The_TextReal_Color
{
    text_total.text=[NSString stringWithFormat:@"%.2f",[text_price.text floatValue]*[text_count.text floatValue] ];
    if(isWirte||app.isApproval)
    {
        if(isWirte)
        {
            isWirte=NO;
            //如果是下物料或写入数量
            if(app.isApproval)
            {
                text_real.text=text_total.text;
            }
            else
            {
                text_real.text=[NSString stringWithFormat:@"%.2f",[text_real_price.text floatValue]*[text_count.text floatValue]];
            }
        }
    }
    else
    {
        text_real.text=[NSString stringWithFormat:@"%.2f",[text_real_price.text floatValue]*[text_count.text floatValue]];
    }
    if([text_real.text floatValue]<[text_total.text floatValue])
    {
        text_real.textColor=[UIColor redColor];
    }
    else
    {
        text_real.textColor=[UIColor colorWithRed:43.0/255.0 green:132/255.0 blue:210/255.0 alpha:1.0];
    }
}
-(void)Set_Detail
{
    if ([self.str_Detail isEqualToString:@"2"]) {
        text_stock_num.hidden=YES;
        btn_stockNum.hidden=YES;
        
        //型号
        text_code.center=CGPointMake(text_code.center.x, text_code.center.y-44);
        lab_type.center=CGPointMake(lab_type.center.x, lab_type.center.y-44);
        btn_type.center=CGPointMake(btn_type.center.x, btn_type.center.y-44);
        //产地
        text_address.center=CGPointMake(text_address.center.x, text_address.center.y-44);
        lab_paddress.center=CGPointMake(lab_paddress.center.x, lab_paddress.center.y-44);
        btn_address.center=CGPointMake(btn_address.center.x, btn_address.center.y-44);
        //单价
        text_price.center=CGPointMake(text_price.center.x, text_price.center.y-44);
        lab_Init_Unit.center=CGPointMake(lab_Init_Unit.center.x, lab_Init_Unit.center.y-44);
        btn_price.center=CGPointMake(btn_price.center.x, btn_price.center.y-44);
        
        //实收单价
        text_real_price.hidden=YES;
        lab_real_unit.hidden=YES;
        btn_real_price.hidden=YES;
        //数量
        text_count.center=CGPointMake(text_count.center.x, text_count.center.y-88);
        self.lab_numUnit.center=CGPointMake(self.lab_numUnit.center.x,self.lab_numUnit.center.y-88);
        btn_count.center=CGPointMake(btn_count.center.x, btn_count.center.y-88);
        //应收合计
        text_total.center=CGPointMake(text_total.center.x, text_total.center.y-88);
        lab_should.center=CGPointMake(lab_should.center.x, lab_should.center.y-88);
        btn_should.center=CGPointMake(btn_should.center.x, btn_should.center.y-88);
        
        //实收合计
        text_real.hidden=YES;
        label_realwords.hidden=YES;
        btn_real.hidden=YES;
        //
        img_arrow_cnt.center=CGPointMake(img_arrow_cnt.center.x, img_arrow_cnt.center.y-88);
        img_arrow_real_unitPrice.hidden=YES;
        img_arrow.hidden=YES;
    }else {
        //型号
        text_code.center=CGPointMake(text_code.center.x, text_code.center.y);
        lab_type.center=CGPointMake(lab_type.center.x, lab_type.center.y);
        btn_type.center=CGPointMake(btn_type.center.x, btn_type.center.y);
        //产地
        text_address.center=CGPointMake(text_address.center.x, text_address.center.y);
        lab_paddress.center=CGPointMake(lab_paddress.center.x, lab_paddress.center.y);
        btn_address.center=CGPointMake(btn_address.center.x, btn_address.center.y);
        //单价
        text_price.center=CGPointMake(text_price.center.x, text_price.center.y);
        lab_Init_Unit.center=CGPointMake(lab_Init_Unit.center.x, lab_Init_Unit.center.y);
        btn_price.center=CGPointMake(btn_price.center.x, btn_price.center.y);
        
        //实收单价
        text_real_price.hidden=YES;
        lab_real_unit.hidden=YES;
        btn_real_price.hidden=YES;
        //数量
        text_count.center=CGPointMake(text_count.center.x, text_count.center.y-44);
        self.lab_numUnit.center=CGPointMake(self.lab_numUnit.center.x,self.lab_numUnit.center.y-44);
        btn_count.center=CGPointMake(btn_count.center.x, btn_count.center.y-44);
        //应收合计
        text_total.center=CGPointMake(text_total.center.x, text_total.center.y-44);
        lab_should.center=CGPointMake(lab_should.center.x, lab_should.center.y-44);
        btn_should.center=CGPointMake(btn_should.center.x, btn_should.center.y-44);
        
        //实收合计
        text_real.hidden=YES;
        label_realwords.hidden=YES;
        btn_real.hidden=YES;
        //
        img_arrow_cnt.center=CGPointMake(img_arrow_cnt.center.x, img_arrow_cnt.center.y-44);
        img_arrow_real_unitPrice.hidden=YES;
        img_arrow.hidden=YES;
    }
}
-(void)Set_Detail2
{
    //库存
    text_stock_num.hidden=YES;
    btn_stockNum.hidden=YES;
    //型号
    text_code.center=CGPointMake(text_code.center.x, text_code.center.y-44);
    lab_type.center=CGPointMake(lab_type.center.x, lab_type.center.y-44);
    btn_type.center=CGPointMake(btn_type.center.x, btn_type.center.y-44);
    //产地
    text_address.center=CGPointMake(text_address.center.x, text_address.center.y-44);
    lab_paddress.center=CGPointMake(lab_paddress.center.x, lab_paddress.center.y-44);
    btn_address.center=CGPointMake(btn_address.center.x, btn_address.center.y-44);
    //单价
    text_price.center=CGPointMake(text_price.center.x, text_price.center.y-44);
    lab_Init_Unit.center=CGPointMake(lab_Init_Unit.center.x, lab_Init_Unit.center.y-44);
    btn_price.center=CGPointMake(btn_price.center.x, btn_price.center.y-44);
    //实收单价
    text_real_price.center=CGPointMake(text_real_price.center.x, text_real_price.center.y-44);
    lab_real_unit.center=CGPointMake(lab_real_unit.center.x, lab_real_unit.center.y-44);
    btn_real_price.center=CGPointMake(btn_real_price.center.x, btn_real_price.center.y-44);
    //数量
    text_count.center=CGPointMake(text_count.center.x, text_count.center.y-44);
    self.lab_numUnit.center=CGPointMake(self.lab_numUnit.center.x,self.lab_numUnit.center.y-44);
    btn_count.center=CGPointMake(btn_count.center.x, btn_count.center.y-44);
    //应收合计
    text_total.center=CGPointMake(text_total.center.x, text_total.center.y-44);
    lab_should.center=CGPointMake(lab_should.center.x, lab_should.center.y-44);
    btn_should.center=CGPointMake(btn_should.center.x, btn_should.center.y-44);
    //实收合计
    text_real.center=CGPointMake(text_real.center.x, text_real.center.y-44);
    label_realwords.center=CGPointMake(label_realwords.center.x, label_realwords.center.y-44);
    btn_real.center=CGPointMake(btn_real.center.x, btn_real.center.y-44);
    img_arrow.center=CGPointMake(img_arrow.center.x, img_arrow.center.y-44);
    img_arrow_cnt.center=CGPointMake(img_arrow_cnt.center.x, img_arrow_cnt.center.y-44);
    img_arrow_real_unitPrice.center=CGPointMake(img_arrow_real_unitPrice.center.x, img_arrow_real_unitPrice.center.y-44);
    
    self.rewardBtn.top -= 45;
    self.rewardLabel.top -= 45;
    self.rewardTextField.top -= 45;
    self.giftBtn.top -= 45;
    self.giftLabel.top -= 45;
    self.switchBtn.top -= 45;
    self.rewardImageLine.top -= 45;
    self.switchBtn.enabled = NO;
}
-(void)All_Init
{
    app=(AppDelegate *)[[UIApplication sharedApplication]delegate];
    if(StatusBar_System>0)
        moment_status=20;
    else moment_status=0;
    NavView *nav_View=[[NavView alloc]init];
    if(app.isApproval)
        self.str_title=@"物料清单详细";
    [self.view addSubview: [nav_View NavView_Title1:self.str_title]];
    
    UIButton *btn_back=[UIButton buttonWithType:UIButtonTypeCustom];
    btn_back.frame=CGRectMake(0, moment_status, 60, 44);
    btn_back.backgroundColor=[UIColor clearColor];
    btn_back.tag=buttonTag+10;
    [btn_back addTarget:self action:@selector(btn_Action:) forControlEvents:UIControlEventTouchUpInside];
    [nav_View.view_Nav  addSubview:btn_back];
    [btn_back setBackgroundImage:[UIImage imageNamed:@"btn_color6.png"] forState:UIControlStateHighlighted];
    [btn_back setTitle:@"< 返回" forState:UIControlStateNormal];
    [btn_back setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    btn_back.titleLabel.font=[UIFont systemFontOfSize:15];
    
    if(![self.str_Detail isEqualToString:@"2"])
    {
        UIButton *btn=[UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame=CGRectMake(Phone_Weight-44, moment_status, 44, 44);
        btn.backgroundColor=[UIColor clearColor];
        btn.tag=buttonTag+4;
        [btn addTarget:self action:@selector(btn_Action:) forControlEvents:UIControlEventTouchUpInside];
        [nav_View.view_Nav  addSubview:btn];
        [btn setBackgroundImage:[UIImage imageNamed:@"btn_color6.png"] forState:UIControlStateHighlighted];
        [btn setTitle:@"确定" forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        btn.titleLabel.font=[UIFont systemFontOfSize:15];
    }
    array_TextField=[NSMutableArray arrayWithCapacity:1];
    
    //物料或者产品单位
    NSDictionary *dic_H=[[BasicData sharedInstance].dic_BasicData objectForKey:@"MasterList"];
    arr_H13=[dic_H objectForKey:@"H13"];//所有的head
    dic_H=nil;

    NSMutableDictionary* dic_ProductList=[[BasicData sharedInstance].dic_BasicData objectForKey:@"ProductList"];
    
    if([app.str_Product_material isEqualToString:@"1"])
    {//物料
         sectionName=[dic_ProductList objectForKey:@"1"];//数据表
    }
    else if([app.str_Product_material isEqualToString:@"0"])
    {//商品
         sectionName=[dic_ProductList objectForKey:@"0"];//数据表
    }
    dic_H=nil;
    
    text_count.textAlignment=NSTextAlignmentRight;
    text_name.textAlignment=NSTextAlignmentRight;
    text_price.textAlignment=NSTextAlignmentRight;
    text_real.textAlignment=NSTextAlignmentRight;
    text_real_price.textAlignment=NSTextAlignmentRight;
    text_stock_num.textAlignment=NSTextAlignmentRight;
    text_total.textAlignment=NSTextAlignmentRight;
    text_code.textAlignment=NSTextAlignmentRight;
    text_address.textAlignment=NSTextAlignmentRight;
    text_branded.textAlignment=NSTextAlignmentRight;
    
    reader = [ZbarCustomVC getSingle]; //1.0.4
    if (!app.GiftFlagStr.integerValue || [app.str_Product_material isEqualToString:@"1"]) {
        [self HiddenSomeScript];
    }
    
    if (app.NCPString.integerValue) {
        self.realBtnImage.hidden = YES;
        self.realTotalImage.hidden = YES;
    }
    
    if (app.GiftFlagStr.integerValue) {
        self.realTotalImage.hidden = YES;
    }
}
-(void)Priorty//预填充
{
    if([Function isBlankString:app.str_choose])return;
    NSDictionary *dic=[sectionName objectAtIndex:[app.str_choose integerValue]];
    str_pcode=[dic objectForKey:@"pcode"];//编码赋值
    str_index_no=[dic objectForKey:@"index_no"];//商品或者物料索引赋值
    if([Function isBlankString:[dic objectForKey:@"ext1"]])
        text_branded.text=@" ";
    else
        text_branded.text=[dic objectForKey:@"ext1"];
    app.str_choose=nil;
    for(NSInteger i=0;i<4;i++)
    {
        UITextField *text=[array_TextField objectAtIndex:i];
        if(i==0)
        {
            text.text=[dic objectForKey:@"pname"];
        }
        else if(i==1)
        {
            text.text=[dic objectForKey:@"ptype"];//显示型号
        }
        else if(i==2)
        {
            text.text=[dic objectForKey:@"poo"];
        }
        else if(i==3)
        {
            text.text=[dic objectForKey:@"price"];
        }
        str_unit=[dic objectForKey:@"punit"];//单位value
        //物料或者产品单位
        if([Function isBlankString:str_unit])
        {
            str_unit=@"0";
        }
        for (NSInteger i=0; i<arr_H13.count; i++)
        {
            NSDictionary *dic_H=[arr_H13 objectAtIndex:i];
            if([[dic_H objectForKey:@"cvalue"]isEqualToString:str_unit])
            {
                str_unit_clabel=[dic_H objectForKey:@"clabel"];
                self.lab_numUnit.text=[NSString stringWithFormat:@"数量(%@)",str_unit_clabel];
                self.lab_stock_Unit.text=[NSString stringWithFormat:@"库存(%@)",str_unit_clabel];
            }
        }
    }
}
//===========================//
-(void)Row_ScrollView:(UIScrollView *)scroll Header:(UIColor *)color Title:(NSString *)title Pic:(NSString *)png Background:(NSString*)name
{
    //信息start
    UIImageView *imgView=[[UIImageView alloc]init];
    imgView.frame=CGRectMake(0,0, Phone_Weight, 53);
    imgView.image=[UIImage imageNamed:name];
    [scroll addSubview:imgView];
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
    [scroll addSubview:imgView];
    //end
}
//===========================//
-(void)btn_Action:(id)sender
{
    UIButton *btn=(UIButton *)sender;
    if(btn.tag==buttonTag+10)//返回
    {
        if([self.str_Detail isEqualToString:@"2"])//处于只读状态
        {
            [self.navigationController popViewControllerAnimated:YES];
            return;
        }
        [self WhenBack_mention];
    }
    else if (btn.tag==buttonTag)
    {
        [self CreateTheQR];
    }
    else if(buttonTag+4==btn.tag)//确定
    {//提交
        [self Submit_Mention];
    }
}
-(void)WhenBack_mention//编辑状态中 返回提示
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"即将清除编辑信息,确认要返回吗" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定",nil];
    [alert show];
    alert.tag=11;
    alert=nil;
}
-(void)Submit_Mention
{
    NSString *mesStr = nil;
    if ([self.str_title isEqualToString:@"编辑退单内容"]) {
        mesStr = @"提交该条退单";
    }else {
        mesStr = @"提交该条订单";
    }
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:mesStr delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定",nil];
    [alert show];
    alert.tag=10;
    alert=nil;
}
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if(alertView.tag==10)
    {
        if(buttonIndex==1)
        {
            if(app.isApproval)
            {
                text_real.text=text_total.text;
                text_real_price.text=text_price.text;
            }
            for(NSInteger i=0;i<array_TextField.count;i++)
            {
                UITextField *text=[array_TextField objectAtIndex:i];
                if([Function isBlankString:text.text]&&(text.tag==10||text.tag==16||text.tag==17||text.tag==18||text.tag==19))//品名、实收单价、数量、应收、实收为必填字段
                {
                    [SGInfoAlert showInfo:@"请填写必填内容"
                                  bgColor:[[UIColor darkGrayColor] CGColor]
                                   inView:self.view
                                 vertical:0.5];
                    return;
                }
            }
            if([text_stock_num.text floatValue]<[text_count.text floatValue])
            {
                [SGInfoAlert showInfo:@"数量不应大于库存量"
                              bgColor:[[UIColor darkGrayColor] CGColor]
                               inView:self.view
                             vertical:0.5];
                return;
            }
            /*需要提交的参数
             0 名称 1 型号 2 地方 3 单价 4 实收单价 5 数量 6 应收 7实收 8单位
             名称 name
             型号 type
             地址 address
             单价 price
             实收价格 selling_price
             数量  cnt
             应收  should
             实收  real_rsum
             
             编码 code
             单位名称 unit
             商品主键 pindex_no  "商品和物料里面的index_no"
             库存数量  stock_cnt
             */
            NSMutableDictionary *dic_unit=[NSMutableDictionary dictionaryWithCapacity:1];
            for (NSInteger i=0; i<array_TextField.count; i++) {
                UITextField *text=(UITextField *)[array_TextField objectAtIndex:i];
                switch (i) {
                    case 0:
                        [dic_unit setObject:text.text forKey:@"name"];
                        break;
                    case 1:
                        [dic_unit setObject:text.text forKey:@"type"];
                        break;
                    case 2:
                        [dic_unit setObject:text.text forKey:@"address"];
                        break;
                    case 3:
                        [dic_unit setObject:text.text forKey:@"price"];
                        break;
                    case 4:
                        [dic_unit setObject:text.text forKey:@"selling_price"];
                        break;
                    case 5:
                        [dic_unit setObject:text.text forKey:@"cnt"];
                        break;
                    case 6:
                        [dic_unit setObject:text.text forKey:@"should"];
                        break;
                    case 7:
                        [dic_unit setObject:text.text forKey:@"real_rsum"];
                        break;
                    default:
                        break;
                }
            }
            
            if (app.GiftFlagStr.integerValue && !app.isApproval) {
                [dic_unit setObject:remarkStr forKey:@"remark"];
                [dic_unit setObject:switchStr forKey:@"switch"];
            }
            
            if (switchStr.integerValue) {
                [dic_unit setObject:@"0" forKey:@"real_rsum"];
            }else {
                NSString *realSum = [NSString stringWithFormat:@"%.2f",[[dic_unit objectForKey:@"selling_price"] floatValue]*
                                    [[dic_unit objectForKey:@"cnt"] integerValue]];
                [dic_unit setObject:realSum forKey:@"real_rsum"];
            }
            [dic_unit setObject:str_unit_clabel forKey:@"unit"];//单位
            [dic_unit setObject:str_index_no forKey:@"pindex_no"];
            [dic_unit setObject:str_pcode forKey:@"pcode"];
            [dic_unit setObject:text_stock_num.text forKey:@"stock_cnt"];
            [dic_unit setObject:text_branded.text forKey:@"ext1"];
            if([self.str_Detail isEqual:@"1"])
            {//编辑修改
                [[AddProduct sharedInstance].arr_AddToList replaceObjectAtIndex:[self.str_Index integerValue]
                                                                     withObject:dic_unit];
            }
            else
            {//首次创建
                [[AddProduct sharedInstance].arr_AddToList addObject:dic_unit];
            }
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
    else if(alertView.tag==11)
    {
        if(buttonIndex==1)
        {//返回
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
}
-(void)PK_QR_VS_List:(NSString *)url
{
    BOOL OK=NO;
    for(NSInteger i=0;i<sectionName.count;i++)
    {
        NSDictionary *dic=[sectionName objectAtIndex:i];
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
    if(!OK)
    {
         [self Choose_Line];
    }
}
-(void)Choose_Line
{
    ChooseListViewController *choose=[[ChooseListViewController alloc]init];
    [self.navigationController pushViewController:choose animated:YES];
}
-(void)clearAllLine
{
    for(NSInteger i=0;i<array_TextField.count;i++)
    {
        UITextField *text=[array_TextField objectAtIndex:i];
        text.text=@"";
    }
}
-(void)CreateTheQR
{
    [reader CreateTheQR:self];
}

-(void)dismissZbarAction {

}

-(void)getCodeString:(NSString *)codeString {
    BOOL cameraFlag = [Function CanOpenCamera];
    
    if (!cameraFlag) {
        
        PresentView *presentView = [PresentView getSingle];
        
        presentView.presentViewDelegate = self;
        
        presentView.frame = CGRectMake(0, 0, 240, 250);
        
        [[KGModal sharedInstance] showWithContentView:presentView andAnimated:YES];
        
        return;
        
    }
    self.str_QR_url = codeString;
    [self PK_QR_VS_List :codeString];
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
        self.str_QR_url = result;
        [self PK_QR_VS_List :result];
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)Action_Name:(id)sender
{

    if([self.str_Detail isEqualToString:@"2"])
    {
        NoteViewController *noteVC=[[NoteViewController alloc]init];
        noteVC.str_title=@"品名";
        noteVC.str_content=text_name.text;
        noteVC.isDetail=YES;
        [self.navigationController pushViewController:noteVC animated:YES];
        return;
    }
    
    UIActionSheet *actionSheet =[[UIActionSheet alloc]initWithTitle:@"选择产品方式" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"扫码", @"列表",nil];
    [actionSheet showInView:self.view];
    actionSheet.tag=1;
    actionSheet=nil;
}

- (IBAction)Action_Count:(id)sender
{
    //Dlog(@"数量");
    NoteViewController *noteVC=[[NoteViewController alloc]init];
    noteVC.str_title=@"单品数量";
    noteVC.str_content=text_count.text;
    noteVC.str_keybordType=@"2";
    if([self.str_Detail isEqualToString:@"2"])
    {
        noteVC.isDetail=YES;
    }
    else
    {
        noteVC.isDetail=NO;
    }
    isWirte=YES;
    [self.navigationController pushViewController:noteVC animated:YES];
}

- (IBAction)Action_Real:(id)sender
{
    if (app.NCPString.integerValue || app.GiftFlagStr.integerValue) {
        return;
    }
    NoteViewController *noteVC=[[NoteViewController alloc]init];
    noteVC.str_title=@"实收合计";
    noteVC.str_content=text_real.text;
    noteVC.str_keybordType=@"2";
    if([self.str_Detail isEqualToString:@"2"])
    {
         noteVC.isDetail=YES;
    }
    else
    {
         noteVC.isDetail=NO;
    }
    isFix_Real=YES;
    [self.navigationController pushViewController:noteVC animated:YES];
}

- (IBAction)Action_Real_UnitPrice:(id)sender
{
    if (app.NCPString.integerValue) {
        return;
    }
    NoteViewController *noteVC=[[NoteViewController alloc]init];
    noteVC.str_title=@"现单价";
    noteVC.str_content=text_real_price.text;
    noteVC.str_keybordType=@"2";
    if([self.str_Detail isEqualToString:@"2"])
    {
        noteVC.isDetail=YES;
    }
    else
    {
        noteVC.isDetail=NO;
    }
    isFix_Real_UnitPrice=YES;
    [self.navigationController pushViewController:noteVC animated:YES];
}
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(actionSheet.tag==1)
    {
        if(buttonIndex==0)
        {
            //Dlog(@"扫条形码");
            [self CreateTheQR];
            isChoose=YES;
        }
        else if(buttonIndex==1)
        {
            //Dlog(@"列表选择");
            [self Choose_Line];
            isChoose=YES;
            chooseBack = 1;
        }
        else
        {
            isChoose=NO;
        }
    }
}
#pragma 取得商品价格和库存 //"一客一价"
-(void)getStock_And_SellingPrice
{
    if([Function isBlankString:app.str_choose])return;
    NSDictionary *dic=[sectionName objectAtIndex:[app.str_choose integerValue]];
    str_pcode=[dic objectForKey:@"pcode"];//编码赋值
    str_index_no=[dic objectForKey:@"index_no"];//商品或者物料索引赋值
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.labelText = @"加载中...";
    if(app.isPortal)
    {
        self.urlString =[NSString stringWithFormat:@"%@%@",KPORTAL_URL,KGetSellingPrice_Stock];
    }
    else
    {
        self.urlString =[NSString stringWithFormat:@"%@%@",kBASEURL,KGetSellingPrice_Stock];
    }
     
    NSURL *url = [NSURL URLWithString:self.urlString];
    ASIFormDataRequest *request = [ ASIFormDataRequest requestWithURL :url];
    request.delegate = self;
    [request setRequestMethod:@"POST"];
    [request setPostValue:[[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"account"]forKey:KUSER_UID];
    [request setPostValue:[[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"secret"] forKey:KUSER_PASSWORD];
    [request setPostValue:[[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"token"] forKey:@"user.token"];
    [request setPostValue:[[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"db_ip"] forKey:@"db_ip"];
    [request setPostValue:[[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"db_name"] forKey:@"db_name"];
    
    if (app.isApproval) {
        [request setPostValue:@"1" forKey:@"mptype"];
    }
    [request setPostValue:app.str_cindex_no forKey:@"cindex_no"];//终端编号
    [request setPostValue:str_index_no forKey:@"pindex_no"];//商品主键
    [request setPostValue:str_pcode forKey:@"pcode"];//商品条码
    [request startAsynchronous ];//异步
}
-(void)Justice_Stock_Selling_Price:(NSDictionary *)dict
{
    if([[dict objectForKey:@"ret"] isEqualToString:@"0"])
    {
        NSDictionary *dic=[dict objectForKey:@"ProductInfo"];
        text_real_price.text=[dic objectForKey:@"selling_price"]; //现单价
        text_stock_num.text=[Function isBlankString:[dic objectForKey:@"stock_cnt"]]?@"0":[dic objectForKey:@"stock_cnt"];  //库存数量
        text_stock_num.enabled=NO;
        isHaveStock=YES;
        [self Priorty];
        [self The_TextReal_Color];
        scroll_back.contentSize=CGSizeMake(0, btn_submit.frame.origin.y+100);
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
        SBJsonParser *parser = [[SBJsonParser alloc] init];
        NSDictionary *dict =[parser objectWithString:[request responseString]];
        [self Justice_Stock_Selling_Price:dict];
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
}

#pragma mark ---- presentView delegate method

- (void)presentViewDissmissAction {
    
    [[KGModal sharedInstance] closeAction:nil];
    
}

- (IBAction)Action_reward:(id)sender {
    NoteViewController *noteVC=[[NoteViewController alloc]init];
    noteVC.str_title=@"备注";
    
    if ([self.str_Detail isEqualToString:@"2"]) {
        noteVC.isDetail=YES;
        noteVC.str_content=self.str_momo;
    }else {
        noteVC.isDetail=NO;
        noteVC.str_content=remarkStr;
    }
    rewardFlag = 1;
    [self.navigationController pushViewController:noteVC animated:YES];
}
- (IBAction)Action_switch:(id)sender {
    UISwitch *tempSwitch = (UISwitch *)sender;
    switchStr = [NSString stringWithFormat:@"%d",tempSwitch.on];
}
@end
