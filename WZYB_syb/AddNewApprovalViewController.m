//
//  AddNewApprovalViewController.m
//  WZYB_syb
//
//  Created by wzyb on 14-7-11.
//  Copyright (c) 2014年 WZYB. All rights reserved.
//
#import <AssetsLibrary/AssetsLibrary.h>
#import "AddNewApprovalViewController.h"
#import "AppDelegate.h"
#import "OrientationViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "KGModal.h"
#import <QuartzCore/QuartzCore.h>
#import "PresentView.h"

@interface AddNewApprovalViewController ()<zbarNewViewDelegate,ASIHTTPRequestDelegate,BMKLocationServiceDelegate,PresentViewDelegate>
@property(strong,nonatomic)BMKLocationService* locService;//定位服务
@property(strong,nonatomic)CLLocationManager  *locationManager;
@end

@implementation AddNewApprovalViewController
{
    AppDelegate *app;
    NSString *NumStr;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    app.str_workerName=@"";
    app.str_index_no=@"";
    self.flag = 0;
    NumStr = [NSString string];
    [self All_Init];
    [self creatView];
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    if(isToChooseOther)
    {
        isToChooseOther=NO;
        if(![Function isBlankString:app.str_workerName])
            [btn_Approval_Master setTitle:[NSString stringWithFormat:@"选择【审批人】:%@",app.str_workerName] forState:UIControlStateNormal];
        return;
    }
    str_ValueH=app.str_temporary_valueH;
    for (NSInteger i=0;i<arr_text.count;i++) {
        NSMutableDictionary *dic=[arr_text objectAtIndex:i];
        UITextField *tex=[dic objectForKey:@"text"];
        if(button_Index==tex.tag)
        {
            if(tex.tag<4+buttonTag*2)
            {
                if (tex.tag == 203) {
                    NumStr = app.str_temporary;
                }
                tex.text=app.str_temporary;
                [dic setObject:app.str_temporary_valueH forKey:@"cvalue"];
            }
            else if(tex.tag==4+buttonTag*2)
            {
                tex.text=app.str_LocationName;
            }
            else
            {
                tex.text=app.str_temporary;
            }
            button_Index=-100;//清零
            return;
        }
    }
    
    NSDictionary *dic=[arr_text objectAtIndex:2];
    UITextField *tex_total=[dic objectForKey:@"text"];
    if ([app.str_osum integerValue]) {
        tex_total.text = app.str_osum;
    }
}
-(void)All_Init
{
    app=(AppDelegate *)[[UIApplication sharedApplication]delegate];
    if(StatusBar_System>0)
        moment_status=20;
    else moment_status=0;
    combox_height_thisView=combox_height;
    near_by_thisView=Near_By;
    btn_tag=0;
    arr_text=[[NSMutableArray alloc]init];
    arr_Media_image=[[NSMutableArray alloc]init];
    arr_ShowImage=[[NSMutableArray alloc]init];
    
    NavView *nav_View=[[NavView alloc]init];
    [self.view addSubview: [nav_View NavView_Title1:@"申请清单添加"]];
    //背景图案
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"AddNewClerkBacground"]]];
    
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
    
    //放大图片 的背景
    view_imageView_back=[[UIView alloc]init];
    view_imageView_back.backgroundColor=[UIColor blackColor];
    view_imageView_back.frame=CGRectMake(0, 0, Phone_Weight, Phone_Height);
    
    reader = [ZbarCustomVC getSingle];  //1.0.4
}

- (void)locationInfo {
    if (isIOS8) {
        //由于IOS8中定位的授权机制改变 需要进行手动授权
        self.locationManager = [[CLLocationManager alloc] init];
        //获取授权认证
        [self.locationManager requestAlwaysAuthorization];
        [self.locationManager requestWhenInUseAuthorization];
    }
    
    self.locService=[[BMKLocationService alloc]init];
    [self.locService startUserLocationService];
    self.locService.delegate = self;
}

- (void)didUpdateBMKUserLocation:(BMKUserLocation *)userLocation
{
    app.str_nlng = [NSString stringWithFormat:@"%f",userLocation.location.coordinate.longitude];
    app.str_alat = [NSString stringWithFormat:@"%f",userLocation.location.coordinate.latitude];
    NSMutableDictionary *dic=[arr_text objectAtIndex:3];
    UITextField *tex=[dic objectForKey:@"text"];
    if (app.str_nlng.integerValue > 0 && app.str_alat.integerValue > 0)
    {
        CLGeocoder *geocoder = [[CLGeocoder alloc] init];
        [geocoder reverseGeocodeLocation: userLocation.location completionHandler:^(NSArray *array, NSError *error)
        {
            if(error==0&&array.count > 0) {
                CLPlacemark *placemark = [array objectAtIndex:0];
                app.str_LocationName=[NSString stringWithFormat:@"%@%@%@%@",placemark.administrativeArea,placemark.locality,placemark.subLocality,placemark.thoroughfare];
                app.str_LocationName = [NSString stringWithFormat:@"%@%@%@%@",placemark.administrativeArea,placemark.locality,placemark.subLocality,placemark.thoroughfare];
                if ([Function StringIsNotEmpty:app.str_LocationName])
                {
                    tex.text=app.str_LocationName;
                }else {
                    tex.text = @"未知地址";
                }
            }
        }];
        geocoder=nil;
    }else {
        tex.text = @"点击定位";
    }
    [self.locService stopUserLocationService];
}

-(void)creatView
{
    scrollView_Back=[[UIScrollView alloc]initWithFrame:CGRectMake(0, moment_status+44,Phone_Weight, Phone_Height-moment_status-44)];
    scrollView_Back.backgroundColor=[UIColor clearColor];
    [self.view addSubview:scrollView_Back];
    
    NSArray *arr_basic=[NSArray arrayWithObjects:@"审批类型",@"申请内容",@"申请相关人员",@"费用支出合计",@"我的地址", nil];
    momentHeight=0;
    //基本信息头start
    [self Row_Header:[UIColor colorWithRed:24/255.0 green:84/255.0 blue:156/255.0 alpha:1.0] Title:@"基本信息"  Pic:@"5" Background:@"icon_AddNewClerk_FirstTitle.png"];
    //基本信息头end
    //-----------------------前五项 静态
    for(NSInteger i=0;i<5;i++)
    {
        UIButton *btn=[UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame=CGRectMake(near_by_thisView, momentHeight, (scrollView_Back.frame.size.width-near_by_thisView*2), combox_height_thisView);
        btn.backgroundColor=[UIColor clearColor];
        [scrollView_Back addSubview:btn];
        [btn addTarget:self action:@selector(apply_action:) forControlEvents:UIControlEventTouchUpInside];
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
            lab.textAlignment=NSTextAlignmentRight;
            lab.backgroundColor=[UIColor clearColor];
            lab.text=self.str_typeLabel;
            lab.font=[UIFont systemFontOfSize:app.Font];
            [btn addSubview:lab];
            btn.userInteractionEnabled=NO;
        }
        else if(i==4)
        {
            [btn setImage:[UIImage imageNamed:@"set_bottom@2X.png"] forState:UIControlStateNormal];
        }
        else
        {
            [btn setImage:[UIImage imageNamed:@"set_middle@2X.png"] forState:UIControlStateNormal];
        }
        if(i>0)
        {
            [self creatArrow:btn];//右侧小箭头
            UITextField *textF=[[UITextField alloc]init];
            if(i==2 || i==1)
            {
                textF.placeholder=@"选填";
            }
            else
            {
                if (i == 3) {
                    textF.text=@"0";
                }else {
                    textF.placeholder=@"必填";
                }
            }
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
            [btn addSubview:textF];
            NSMutableDictionary *dic=[[NSMutableDictionary alloc]init];
            [dic setObject:textF forKey:@"text"];
            [dic setObject:@"-1" forKey:@"index_no"];
            [dic setObject:[arr_basic objectAtIndex:i] forKey:@"title"];
            if(i==3)
            {
                [dic setObject:@"2" forKey:@"data_type"];//书写类型 动态项目类型（0:数字，1:文本，2:金额，3:日期，4:列表）
            }
            else
            {
                [dic setObject:@"-1" forKey:@"data_type"];
            }
            [dic setObject:@"-1" forKey:@"cvalue"];
            if(i==2 || i==1)
            {
                [dic  setObject:@"0" forKey:@"required"];
            }
            else
            {
                [dic  setObject:@"1" forKey:@"required"];//1是必填
            }
            [arr_text addObject:dic];
            dic=nil;
        }
        momentHeight+=combox_height_thisView;
    }
//---------------------动态
    SBJsonParser *parser = [[SBJsonParser alloc] init];
    NSDictionary *dict =[parser objectWithString: self.str_Json];
    arr_list=[dict objectForKey:@"DynamicList"];
    if(arr_list.count!=0)
    {
        //申请详情start
        [self Row_Header:[UIColor colorWithRed:234/255.0 green:119/255.0 blue:0/255.0 alpha:1.0] Title:@"申请详情"  Pic:@"6" Background:@"icon_AddNewClerk_NextTitle.png"];
        //申请详情end
    }
    for(NSInteger i=0;i<arr_list.count;i++)
    {
        UIButton *btn=[UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame=CGRectMake(near_by_thisView, momentHeight, (scrollView_Back.frame.size.width-near_by_thisView*2), combox_height_thisView);
        btn.backgroundColor=[UIColor clearColor];
        [scrollView_Back addSubview:btn];
        [btn addTarget:self action:@selector(apply_action:) forControlEvents:UIControlEventTouchUpInside];
        btn.tag=buttonTag*2+btn_tag++;
        
        [self creatArrow:btn];//右侧小箭头
        //属性
        UILabel *lab1=[[UILabel alloc]initWithFrame:CGRectMake(0,0, btn.frame.size.width/2-combox_height_thisView,btn.frame.size.height)];
        lab1.backgroundColor=[UIColor clearColor];
        NSDictionary *dic=[arr_list objectAtIndex:i];
        lab1.text=[NSString stringWithFormat:@"  %@",[dic objectForKey:@"tname"]];
        lab1.font=[UIFont systemFontOfSize:app.Font];
        [btn addSubview:lab1];
        if(arr_list.count==1)
        {
            [btn setImage:[UIImage imageNamed:@"set_single@2X.png"] forState:UIControlStateNormal];
        }
        else if(i==0)
        {
            [btn setImage:[UIImage imageNamed:@"set_header@2X.png"] forState:UIControlStateNormal];
        }
        else if(i==arr_list.count-1 )
        {
            [btn setImage:[UIImage imageNamed:@"set_bottom@2X.png"] forState:UIControlStateNormal];
        }
        else
        {
            [btn setImage:[UIImage imageNamed:@"set_middle@2X.png"] forState:UIControlStateNormal];
        }
        UITextField *textF=[[UITextField alloc]init];
        if([[dic objectForKey:@"trequired"]isEqualToString:@"1"])
        {
            textF.placeholder=@"必填";
        }
        else
        {
            textF.placeholder=@"选填";
        }
        [btn addSubview:textF];
        if(isIOS7)
        {
            textF.frame=CGRectMake(btn.frame.size.width/2-combox_height_thisView,0,btn.frame.size.width/2, btn.frame.size.height);
        }
        else
        {
            textF.frame=CGRectMake(btn.frame.size.width/2-combox_height_thisView,btn.frame.size.height/4,btn.frame.size.width/2, btn.frame.size.height);
        }
        textF.font=[UIFont systemFontOfSize:app.Font];
        textF.tag=btn.tag;
        textF.enabled=NO;
        textF.backgroundColor=[UIColor clearColor];
        textF.textAlignment=NSTextAlignmentRight;
        [btn addSubview:textF];
        NSMutableDictionary *dic_two=[[NSMutableDictionary alloc]init];
        [dic_two setObject:textF forKey:@"text"];
        [dic_two setObject:[dic objectForKey:@"index_no"] forKey:@"index_no"];
        [dic_two setObject:[dic objectForKey:@"data_type"] forKey:@"data_type"];//书写类型
        [dic_two setObject:[dic objectForKey:@"tname"] forKey:@"title"];
        [dic_two setObject:[dic objectForKey:@"tdefault"] forKey:@"tdefault"];
        [dic_two setObject:@"-1" forKey:@"cvalue"];
        [dic_two setObject:[dic objectForKey:@"trequired"] forKey:@"required"];//1是必填
        [arr_text addObject:dic_two];
        dic_two=nil;
        dic=nil;
        momentHeight+=combox_height_thisView;
    }
//-----------------------------动态媒体
    arr_MediaList=[dict objectForKey:@"MediaList"];
    if(arr_MediaList.count!=0)
    {
        //媒体信息start
        [self Row_Header:[UIColor colorWithRed:25/255.0 green:35/255.0 blue:49/255.0 alpha:1.0] Title:@"媒体信息" Pic:@"4" Background:@"icon_AddNewClerk_NextTitle.png"];
        //媒体信息end
    }
    for(NSInteger i=0;i<arr_MediaList.count;i++)
    {
        UIImageView *view_btn=[[UIImageView alloc]init];
        view_btn.frame=CGRectMake(near_by_thisView, momentHeight, (Phone_Weight-near_by_thisView*2),combox_height_thisView*2);
        view_btn.backgroundColor=[UIColor clearColor];
        [scrollView_Back addSubview:view_btn];
        view_btn.userInteractionEnabled=YES;
        if(arr_MediaList.count==1)
        {
            view_btn.image=[UIImage imageNamed:@"set_single@2X.png"];
        }
        else
        {
            if(i==0)
            {
                view_btn.image=[UIImage imageNamed:@"set_header@2X.png"];
            }
            else if(i==arr_MediaList.count-1)
            {
                view_btn.image=[UIImage imageNamed:@"set_bottom@2X.png"];
            }
            else
            {
                view_btn.image=[UIImage imageNamed:@"set_middle@2X.png"];
            }

        }
        momentHeight+=view_btn.frame.size.height;
        UIImageView *imageView_Back=[[UIImageView alloc]init ];
        imageView_Back.backgroundColor=[UIColor clearColor];
        imageView_Back.image=[UIImage imageNamed:@"icon_take_picture"];
        imageView_Back.userInteractionEnabled=YES;
        [view_btn addSubview:imageView_Back];
        [arr_ShowImage addObject:imageView_Back];
        imageView_Back.frame=CGRectMake(view_btn.frame.size.width- view_btn.frame.size.height ,10,view_btn.frame.size.height-20, view_btn.frame.size.height-20);
        UILabel *lab_describ=[[UILabel alloc]initWithFrame:CGRectMake(0, 0, view_btn.frame.size.width-imageView_Back.frame.size.width, view_btn.frame.size.height)];
        lab_describ.backgroundColor=[UIColor clearColor];
        lab_describ.textAlignment=NSTextAlignmentCenter;
        lab_describ.font=[UIFont systemFontOfSize:app.Font];
        [view_btn addSubview:lab_describ];
        NSDictionary *dic=[arr_MediaList objectAtIndex:i];
        if([[dic objectForKey:@"required97"] isEqualToString:@"1"])
        {
            lab_describ.text=[NSString stringWithFormat:@"%@(必填)",[dic objectForKey:@"clabel"]];
        }
        else
        {
            lab_describ.text=[NSString stringWithFormat:@"%@(选填)",[dic objectForKey:@"clabel"]];
        }
        //拍照 或查看照片按钮
        UIButton *btn_image=[UIButton buttonWithType:UIButtonTypeCustom];
        btn_image.frame=CGRectMake(0, 0, 77, 74);
        [imageView_Back addSubview:btn_image];
        btn_image.backgroundColor=[UIColor clearColor];
        btn_image.tag=buttonTag*4+i;
        [btn_image addTarget:self action:@selector(BigImage:) forControlEvents:UIControlEventTouchUpInside];
        //required97
        NSMutableDictionary *dic_media=[[NSMutableDictionary alloc]init];
        [dic_media setObject:[dic objectForKey:@"h7type"]  forKey:@"mtype"];
        [dic_media setObject:[dic objectForKey:@"required97"] forKey:@"required"];
        UIImageView *imageView=[[UIImageView alloc]init];
        [dic_media setObject:imageView forKey:@"imgView"];//图片初始化
        [dic_media setObject:@"0" forKey:@"is_addimg"];//暂无图片初始化 0
        [dic_media setObject:@"0" forKey:@"isme"];//是否我正在拍照 1是在拍 其他不是
        [arr_Media_image addObject:dic_media];
        imageView=nil;
        dic_media=nil;
        dic=nil;
        imageView_Back=nil;
    }
//---------------提交和物料申请按钮
    momentHeight=momentHeight+20;
    for(NSInteger i=0;i<3;i++)
    {
        if(![app.str_temporary_valueH isEqualToString:@"0"])//如果不是物料
        {
            if(i==0)
                continue;
        }
        UIButton *btn=[UIButton buttonWithType:UIButtonTypeCustom];
        [btn.layer setMasksToBounds:YES];
        [btn.layer setCornerRadius:5.0];//设置矩形四个圆角半径
        btn.frame=CGRectMake((Phone_Weight-300)/2, momentHeight, 300, 44);
        btn.backgroundColor=[UIColor clearColor];
        [btn addTarget:self action:@selector(btn_Action:) forControlEvents:UIControlEventTouchUpInside];
        [scrollView_Back  addSubview:btn];
        
        btn.titleLabel.textColor=[UIColor whiteColor];
        btn.titleLabel.font=[UIFont systemFontOfSize:15];
        btn.tag=buttonTag*6+i;
        if(i==0)
        {
            [[AddProduct sharedInstance].arr_AddToList removeAllObjects];
            [btn setBackgroundImage:[UIImage imageNamed:@"btn_color6.png"] forState:UIControlStateNormal];
            [btn setBackgroundImage:[UIImage imageNamed:@"btn_color1.png"] forState:UIControlStateHighlighted];
            [btn setTitle:@"点击填写审批物料" forState:UIControlStateNormal];
        }
        else if(i==1)
        {
            [btn setBackgroundImage:[UIImage imageNamed:@"btn_color3.png"] forState:UIControlStateNormal];
            [btn setBackgroundImage:[UIImage imageNamed:@"btn_color5.png"] forState:UIControlStateHighlighted];
            [btn setTitle:@"选择审批人" forState:UIControlStateNormal];
            btn_Approval_Master=btn;
        }
        else
        {
            [btn setBackgroundImage:[UIImage imageNamed:@"btn_color6.png"] forState:UIControlStateNormal];
            [btn setBackgroundImage:[UIImage imageNamed:@"btn_color1.png"] forState:UIControlStateHighlighted];
            [btn setTitle:@"提交" forState:UIControlStateNormal];
        }
        momentHeight+=combox_height_thisView+10;
    }
    
    dict=nil;
    momentHeight+=100;
    scrollView_Back.contentSize=CGSizeMake(0, momentHeight);
    
    [self locationInfo];
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
-(void)apply_action:(UIButton *)btn
{
    NSInteger tag=btn.tag-buttonTag*2;
    button_Index=btn.tag;//赋值索引
    NSDictionary *dic_data=[arr_text objectAtIndex:tag-1];
    if(tag<4)
    {
        UITextField *tex=[dic_data objectForKey:@"text"];
        NoteViewController *noteVC=[[NoteViewController alloc]init];
        noteVC.str_title=[dic_data objectForKey:@"title"];
        noteVC.str_keybordType=[dic_data objectForKey:@"data_type"];
        noteVC.str_content=tex.text;
        [self.navigationController pushViewController:noteVC animated:YES];
        noteVC=nil;
    }
    else if(tag==4)
    {
        OrientationViewController *lotVC=[[OrientationViewController alloc]init];
        lotVC.str_IsFromWhere=@"2";//审批
        lotVC.showGreenView = 1;
        lotVC.str_title=@"确认我的位置";

        [self.navigationController pushViewController:lotVC animated:NO];
    }
    else
    {//@"data_type"//书写类型 动态项目类型（0:数字，1:文本，2:金额，3:日期，4:列表）
        NSString *str_data_type=[dic_data objectForKey:@"data_type"];
        if([str_data_type isEqualToString:@"4"])
        {//选择列表
            UIActionSheetViewController *actionVC=[[UIActionSheetViewController alloc]init];
            actionVC.str_title=[dic_data objectForKey:@"title"];
            actionVC.str_tdefault=[dic_data objectForKey:@"tdefault"];
            actionVC.isOnlyLabel=YES;
            [self.navigationController pushViewController:actionVC animated:YES];
            actionVC=nil;
        }
        else if([str_data_type isEqualToString:@"3"])
        {//日期选择器
            dateIndex= tag-1;
            [self select_Date];
        }
        else//0 1文本框
        {
            UITextField *tex=[dic_data objectForKey:@"text"];
            NoteViewController *noteVC=[[NoteViewController alloc]init];
            noteVC.str_title=[dic_data objectForKey:@"title"];
            noteVC.str_keybordType=str_data_type;
            noteVC.str_content=tex.text;
            [self.navigationController pushViewController:noteVC animated:YES];
            noteVC=nil;
        }
    }
    dic_data=nil;
}
-(void)BigImage:(UIButton *)btn
{//required97
    NSDictionary *dic=[arr_Media_image objectAtIndex:btn.tag-4*buttonTag];
    if([[dic objectForKey:@"is_addimg"]isEqualToString:@"1"])//说明已经照过图片了
    {
        UIImageView *imgView=[dic objectForKey:@"imgView"];
        [self view_image_AllScreen:imgView];
    }
    camera_index=btn.tag-4*buttonTag;
    [self TakePhoto];
}
-(void)Give_you_Photo:(UIImage*)image ImageData:(NSData*)data
{
    NSMutableDictionary *dic=[arr_Media_image objectAtIndex:camera_index];
    UIImageView *imageView=[[UIImageView alloc]init];
    imageView.image=image;
    [dic setObject:imageView forKey:@"imgView"];
    [dic setObject:@"1" forKey:@"is_addimg"];
    [dic setObject:data forKey:@"imageData"];
    UIImageView *img_show=[arr_ShowImage objectAtIndex:camera_index];
    img_show.image=image;
}
-(void)view_image_AllScreen:(UIImageView *) image
{
    ///////////可伸缩图片
    UIScrollView *scroll=[[UIScrollView alloc]init];
    scroll.frame=CGRectMake(0, 0, view_imageView_back.frame.size.width, view_imageView_back.frame.size.height);
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
    ///////////可伸缩图片
    //识别单指点击 退出大图 start
    UITapGestureRecognizer *singleTap =[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)] ;
    [singleTap setNumberOfTapsRequired:1];
    
    [self.zoomScrollView  addGestureRecognizer:singleTap];
    singleTap=nil;
    scroll=nil;
    self.zoomScrollView=nil;
    //识别单指点击 退出大图 end

    [self.view addSubview:view_imageView_back];
}
-(void)handleSingleTap:(UITapGestureRecognizer *)sender
{
    [self cancel_AllScreen];
}
-(void)cancel_AllScreen
{
    [view_imageView_back removeFromSuperview];
}
-(void)btn_Action:(id)sender
{
    UIButton *btn=(UIButton *)sender;
    if(btn.tag==buttonTag-1)//返回
    {
        [self WhenBack_mention];
    }
    else if(btn.tag==buttonTag)//去校验地址是否正确
    {
        OrientationViewController *lotVC=[[OrientationViewController alloc]init];
        lotVC.str_IsFromWhere=@"2";//审批
        lotVC.str_title=@"确认我的位置";
        [self.navigationController pushViewController:lotVC animated:NO];
    }
    else if(btn.tag==buttonTag*6+1)
    {//选人
        //Dlog(@"选人");
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"马上去选择审批人" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定",nil];
        [alert show];
        alert.tag=10;
        alert=nil;
    }
    else if(btn.tag==buttonTag*6+2)//提交新审批任务
    {
        if([self Verify_All])
        {
            if([app.str_temporary_valueH isEqualToString:@"0"])//如果不是物料
            {
                NSDictionary *dic=[arr_text objectAtIndex:2];
                UITextField *tex_total=[dic objectForKey:@"text"];
                if([tex_total.text integerValue]!=[app.str_osum integerValue])
                {
                    [SGInfoAlert showInfo:@"申请金额与物料合计金额不一致!"
                                  bgColor:[[UIColor darkGrayColor] CGColor]
                                   inView:self.view
                                 vertical:0.5];
                    
                }
                else
                {
                    [self Mention_alert:@"提交申请"];
                }
            }
            else
            {
                [self Mention_alert:@"提交申请"];
            }
            
        }
    }
    else if(btn.tag==buttonTag*6)//填写物料信息
    {
        //Dlog(@"填写物料信息");
        isProduct=YES;
        if(isProduct)
        {
            isProduct=NO;
            if([AddProduct sharedInstance].arr_AddToList.count>0)
            {//如果有数据的话
                app.isApproval=YES;
                app.str_Product_material=@"1";//物料
                OrderListViewController *listVC=[[OrderListViewController alloc]init];
                listVC.str_title=@"物料信息登记";
                listVC.str_cindex_no=app.str_cindex_no;//获取终端编号
                listVC.str_suspend=@"1";//有未提交的物料
                [self.navigationController pushViewController:listVC animated:NO];
            }
            else
            {
                UIActionSheet *actionSheet =[[UIActionSheet alloc]initWithTitle:@"先选择确认终端方式" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"扫二维码",@"列表", nil];
                [actionSheet showInView:self.view];
                actionSheet.tag=buttonTag;
                actionSheet=nil;
            }
        }
    }
    else if(btn.tag==buttonTag*2+2)
    {
        [view_back removeFromSuperview];
        NSDictionary *dic=[arr_text objectAtIndex:dateIndex];
        UITextField *text=[dic objectForKey:@"text"];
        text.text=@"";
        isOpenDate=NO;
    }
    else if(btn.tag==buttonTag*2+3)
    {
        button_Index=-100;
        [view_back removeFromSuperview];
        isOpenDate=NO;
        if(app.isDateLegal)
        {
            NSMutableDictionary *dic=[arr_text objectAtIndex:dateIndex];
            UITextField *tex=[dic objectForKey:@"text"];
            tex.text=app.str_Date;
        }
        else
        {
            app.str_Date=[Function getYearMonthDay_Now];
            NSDictionary *dic=[arr_text objectAtIndex:dateIndex];
            UITextField *text=[dic objectForKey:@"text"];
            text.text=app.str_Date;
        }
    }
}
-(BOOL)Verify_All//校验必填项目
{
    for (NSInteger i=0; i<arr_text.count; i++)
    {
        NSDictionary *dic=[arr_text objectAtIndex:i];
        if([[dic objectForKey:@"required"] isEqualToString:@"1"])
        {
            UITextField *text=[dic objectForKey:@"text"];
            if([Function isBlankString:text.text]||text.text.length==0)
            {
                [self Must_write];
                dic=nil;
                return NO;
            }
        }
    }
    for (NSInteger i=0; i<arr_Media_image.count; i++)
    {
        NSDictionary *dic=[arr_Media_image objectAtIndex:i];
        if([[dic objectForKey:@"required"] isEqualToString:@"1"])
        {
            if([[dic objectForKey:@"is_addimg"]isEqualToString:@"0"])//等于0表示没添加
            {
                [self Must_write];
                dic=nil;
                return NO;
            }
        }
    }
    
    if([app.str_temporary_valueH isEqualToString:@"0"])
    {
        if([AddProduct sharedInstance].arr_AddToList.count==0)
        {//是物料 却为空
            [SGInfoAlert showInfo:@"请先去填写物料"
                          bgColor:[[UIColor darkGrayColor] CGColor]
                           inView:self.view
                         vertical:0.5];
            return NO;
        }
    }
    return YES;
}
-(void)Must_write
{//如果必填字段为空或者字符串长度为0 做提示 并且不予提交远程
    [SGInfoAlert showInfo:@"请把必填内容完善,再尝试提交"
                  bgColor:[[UIColor darkGrayColor] CGColor]
                   inView:self.view
                 vertical:0.5];
}
-(void)Mention_alert:(NSString*)msg
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:msg
                                                   delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定",nil];
    [alert show];
    alert=nil;
}
-(void)WhenBack_mention//编辑状态中 返回提示
{
    isBack=YES;
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"即将清除编辑信息,确认要返回吗" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定",nil];
    [alert show];
    alert=nil;
}
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(alertView.tag==10)
    {//选人
        if(buttonIndex==1)
        {
            isToChooseOther=YES;
            LocationViewController *lVC=[[LocationViewController alloc]init];
            lVC.str_from=@"3";
            [self.navigationController pushViewController:lVC animated:NO];
        }
        else
        {
            isToChooseOther=NO;
        }
        //Dlog(@"选人");
    }
    else
    if(buttonIndex==1)
    {
        if(isBack)//返回键
        {
            isBack=NO;
            [[AddProduct sharedInstance].arr_AddToList removeAllObjects];
            [self.navigationController popViewControllerAnimated:YES];
            return;
        }
        else
        {
            [self submit_Apply];
        }
    }
    else
    {
        if(isBack)
        {
            isBack=NO;
            return;
        }
        if(isProduct)
        {
            isProduct=NO;
            return;
        }
    }
    
}
#pragma TakePhoto
-(void)TakePhoto
{
    if([Function isBlankString:app.str_LocationName]||[Function isBlankString:app.str_nlng]||[Function isBlankString:app.str_alat])
    {
        [SGInfoAlert showInfo:@" 请先去确认我的位置 "
                      bgColor:[[UIColor darkGrayColor] CGColor]
                       inView:self.view
                     vertical:0.5];
        return;
    }
    if(isPad)
    {
        UIActionSheet *actionSheet =[[UIActionSheet alloc]initWithTitle:@"您想如何获取照片?" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"拍照",@"相册", nil];
        [actionSheet showInView:self.view];
    }
    else
    {
        UIActionSheet *actionSheet =[[UIActionSheet alloc]initWithTitle:@"您想如何获取照片?" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"拍照",@"相册", nil];
        [actionSheet showInView:self.view];
    }
}
-(void)ActionSheet
{
    UIActionSheet *actionSheet =[[UIActionSheet alloc]init];
    actionSheet.delegate=self;
    [actionSheet setTitle:@"选择项目"];
    for(NSInteger i=0;i<arrData_H9.count;i++)
    {
        NSDictionary *dic=[arrData_H9 objectAtIndex:i];
        [actionSheet buttonTitleAtIndex:[actionSheet addButtonWithTitle:[dic objectForKey:@"clabel"]]];
        dic=nil;
    }
    [actionSheet buttonTitleAtIndex:[actionSheet addButtonWithTitle:@"取消"]];
    [actionSheet showInView:self.view];
}
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(actionSheet.tag==buttonTag)
    {
        if(buttonIndex==0)
        {
            //Dlog(@"扫二维码");
            isPressProduct=YES;
            [self CreateTheQR];
            // [self SubmitTheQR_Inform:@"http://127.0.0.1:8080/wzyb/sign.do?actionId=sign&atu=9766527f2b5d3e95d4a733fcfb77bd7e165"];
        }
        else if(buttonIndex==1)
        {
            //Dlog(@"列表选择");
            NotQRViewController *notQR=[[NotQRViewController alloc]init];
            notQR.str_From=@"3";//物料订单
            [self.navigationController pushViewController: notQR animated:YES];
        }
    }
    else
    {
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.allowsEditing = YES;
        if(buttonIndex==2)
            return;
        if(buttonIndex==0)
        {//拍照
            BOOL cameraFlag = [Function CanOpenCamera];
            
            if (!cameraFlag) {
                
                PresentView *presentView = [PresentView getSingle];
                
                presentView.presentViewDelegate = self;
                
                presentView.frame = CGRectMake(0, 0, 240, 250);
                
                [[KGModal sharedInstance] showWithContentView:presentView andAnimated:YES];
                
                return;
                
            }
            isCamera=YES;
            picker.sourceType=UIImagePickerControllerSourceTypeCamera;
            [self cancel_AllScreen];
            [self presentViewController:picker animated:YES completion:NULL];
        }
        else if(buttonIndex==1)
        {//图库
            isCamera=NO;
            picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            [self cancel_AllScreen];
            [self presentViewController:picker animated:YES completion:NULL];
        }
    }
}
#pragma -mark UIImagePickerController delegate
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    if(isPressProduct)
    {
        [picker dismissViewControllerAnimated:YES completion:^{
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
            self.str_qr_url = result;
            [self SubmitTheQR_Inform:result];
        }];
        isPressProduct=NO;
    }
    else
    {
        chosenImage = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
        // 指定回调方法
        
        [picker dismissViewControllerAnimated:YES completion:NULL];
        [SGInfoAlert showInfo:@" 照片添加成功! "
                      bgColor:[[UIColor darkGrayColor] CGColor]
                       inView:self.view
                     vertical:0.5];
        if(isCamera)
        {
            NSString *strAll;
            UILabel *lab_content;
            NSData *image_data=UIImageJPEGRepresentation( [chosenImage resize:CGSizeMake(Phone_Weight*2  , Phone_Height*2)],0.6 );
            UIImage *image_New=[UIImage imageWithData:image_data];
            strAll=[NSString stringWithFormat:@"采集人:%@     GPS:%@,%@\n地址:%@\n采集时间:%@\n文件生成时间:%@\n",[[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"uname"],app.str_nlng,app.str_alat,app.str_LocationName,[Function getSystemTimeNow],[Function getSystemTimeNow]];
            lab_content=[Water_Mark Label_Freedom_Content:strAll  Choose_image:image_New];
            UIImage *getImage=[Water_Mark TransFor_ChooseImage:image_New  Lab:[Water_Mark imageWithUIView:lab_content]];
            [self Give_you_Photo:getImage  ImageData:UIImageJPEGRepresentation(getImage,0.6) ];
            strAll=nil;
            //保存到系统相册
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                UIImageWriteToSavedPhotosAlbum(chosenImage, self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
            });
        }
        else
        {
            NSURL *assetURL = [info objectForKey:UIImagePickerControllerReferenceURL];
            ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
            [library assetForURL:assetURL
                     resultBlock:^(ALAsset *asset) {
                         NSDate* date = [asset valueForProperty:ALAssetPropertyDate];
                         NSArray *arr_date=[[NSString stringWithFormat:@"%@",date]   componentsSeparatedByString:@"+"];
                         
                         NSString *strAll;
                         UILabel *lab_content;
                         NSData *image_data=UIImageJPEGRepresentation( [chosenImage resize:CGSizeMake(Phone_Weight*2  , Phone_Height*2)],0.6 );
                         UIImage *image_New=[UIImage imageWithData:image_data];
                         strAll=[NSString stringWithFormat:@"采集人:%@     GPS:%@,%@\n地址:%@\n采集时间:%@ 文件生成时间:%@\n",[[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"uname"],app.str_nlng,app.str_alat,app.str_LocationName,[Function getSystemTimeNow],[arr_date objectAtIndex:0]];
                         lab_content=[Water_Mark Label_Freedom_Content:strAll  Choose_image:image_New];
                         UIImage *getImage=[Water_Mark TransFor_ChooseImage:image_New  Lab:[Water_Mark imageWithUIView:lab_content]];
                         [self Give_you_Photo:getImage  ImageData:UIImageJPEGRepresentation(getImage,0.6)];
                         strAll=nil;
                         
                     } 
                    failureBlock:^(NSError *error) { 
                    }];
 
        }
        picker=nil;
    }
}
- (void)image: (UIImage *) image didFinishSavingWithError: (NSError *) error contextInfo: (void *) contextInfo
{
    if(error != NULL){
        //Dlog(@"保存图片失败");
    }else{
        //Dlog(@"保存图片成功" );
    }
}

-(void)submit_Apply
{
    if([Function isConnectionAvailable])
    {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.mode = MBProgressHUDModeIndeterminate;
        hud.labelText = @"加载中...";//加载提示语言
        
        if(app.isPortal)
        {
            self.urlString=[NSString stringWithFormat:@"%@%@",KPORTAL_URL,KAdd_apply];
        }
        else
        {
            self.urlString=[NSString stringWithFormat:@"%@%@",kBASEURL,KAdd_apply];
        }
         
        NSURL *url = [NSURL URLWithString:self.urlString];

        ASIFormDataRequest *request = [ ASIFormDataRequest requestWithURL :url];
        request.delegate = self;
        request.tag = 100;
        [request setRequestMethod:@"POST"];
        [request setPostValue:[[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"account"]forKey:KUSER_UID];
        [request setPostValue:[[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"secret"] forKey:KUSER_PASSWORD];
        [request setPostValue:[[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"token"] forKey:@"user.token"];
        [request setPostValue:[[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"db_ip"] forKey:@"db_ip"];
        [request setPostValue:[[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"db_name"] forKey:@"db_name"];
        [request setPostValue:app.str_temporary_valueH forKey:@"rtype"];
//------------静态
        for(NSInteger i=0;i<arr_text.count;i++)
        {
            NSDictionary *dic=[arr_text objectAtIndex:i];
            UITextView *text=[dic objectForKey:@"text"];
            //Dlog(@"%@",text.text);
            if(i==0)
            {
                [request setPostValue:text.text forKey:@"rcontent"];
            }
            else if(i==1)
            {
                [request setPostValue:text.text forKey:@"relations"];
            }
            else if(i==2)
            {
                [request setPostValue:text.text forKey:@"rsum"];
            }
            else if(i==3)
            {
                [request setPostValue:app.str_nlng forKey:@"rlng"];
                [request setPostValue:app.str_alat forKey:@"rlat"];
                [request setPostValue:app.str_LocationName forKey:@"raddress"];
            }
            //--------------------动态
            else
            {
                [request setPostValue:[dic objectForKey:@"index_no"] forKey:[NSString stringWithFormat:@"dynamicList[%ld].index_no",i-4]];
                [request setPostValue:text.text forKey:[NSString stringWithFormat:@"dynamicList[%ld].tcontent",i-4]];
            }
            dic=nil;
        }
//--------------------媒体图片
        //Dlog(@"%@",arr_Media_image);
        NSInteger count_action=0;
        for(NSInteger i=0;i<arr_Media_image.count;i++)
        {
            NSDictionary *dic=[arr_Media_image objectAtIndex:i];
            if([[dic objectForKey:@"is_addimg"] isEqualToString:@"1"])
            {//该张图片添加过则提交
                [request setData:[dic objectForKey:@"imageData"]
                    withFileName:[NSString stringWithFormat:@"T1.jpg"]
                  andContentType:@"image/jpeg"
                          forKey:[NSString stringWithFormat:@"fileList[%ld].file",(long)count_action]];
                [request setPostValue:[dic objectForKey:@"mtype"] forKey:[NSString stringWithFormat:@"fileList[%ld].mtype",(long)count_action]];
                count_action++;
            }
            dic=nil;
        }
//--------------物料信息
        if(app.isApproval)
        {
            for (NSInteger i=0; i<[AddProduct sharedInstance].arr_AddToList.count; i++)
            {
                NSDictionary *dic_unit=[[AddProduct sharedInstance].arr_AddToList objectAtIndex:i];
                [request setPostValue:[dic_unit objectForKey:@"pcode"] forKey:[NSString stringWithFormat:@"postList[%ld].pcode",(long)i]];
                [request setPostValue:[dic_unit objectForKey:@"price"] forKey:[NSString stringWithFormat:@"postList[%ld].price",(long)i]];
                [request setPostValue:[dic_unit objectForKey:@"cnt"] forKey:[NSString stringWithFormat:@"postList[%ld].cnt",(long)i]];
                [request setPostValue:[dic_unit objectForKey:@"real_rsum"] forKey:[NSString stringWithFormat:@"postList[%ld].rsum",(long)i]];
                [request setPostValue:[dic_unit objectForKey:@"pindex_no"] forKey:[NSString stringWithFormat:@"postList[%ld].pindex_no",(long)i]];
            }
            [request setPostValue:app.str_cindex_no forKey:@"cindex_no"];
            [request setPostValue:app.str_osum forKey:@"osum"];
            [request setPostValue:app.str_orsum  forKey:@"orsum"];
            [request setPostValue:app.str_odiscount  forKey:@"odiscount"];
            [request setPostValue:app.str_ctc_sts forKey:@"ctc_sts"];
        }
        [request setPostValue:app.str_index_no forKey:@"next_uindex_no"];//新添加审批人 顺序无关
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
-(void)get_JsonString:(NSString *)jsonString
{
    SBJsonParser *parser = [[SBJsonParser alloc] init];
    NSDictionary *dict =[parser objectWithString: jsonString];
    if([[dict objectForKey:@"ret"]isEqualToString:@"0"])
    {
        [SGInfoAlert showInfo:@" 移动审批清单提交成功 "
                      bgColor:[[UIColor darkGrayColor] CGColor]
                       inView:self.view
                     vertical:0.5];
        [[AddProduct sharedInstance].arr_AddToList removeAllObjects];
        app.str_workerName=@"";
        app.str_index_no=@"";
        [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:2] animated:YES];
    }
    else
    {
        [SGInfoAlert showInfo:[dict objectForKey:@"message"]
                      bgColor:[[UIColor darkGrayColor] CGColor]
                       inView:self.view
                     vertical:0.5];
    }
}
-(void)CreateTheQR
{
    BOOL cameraFlag = [Function CanOpenCamera];
    
    if (!cameraFlag) {
        
        PresentView *presentView = [PresentView getSingle];
        
        presentView.presentViewDelegate = self;
        
        presentView.frame = CGRectMake(0, 0, 240, 250);
        
        [[KGModal sharedInstance] showWithContentView:presentView andAnimated:YES];
        
        return;
        
    }
    if (isIOS7) {
        zbarNewViewController *zbarNew = [zbarNewViewController new];
        zbarNew.zbarNewDelegate = self;
        [self presentViewController:zbarNew animated:YES completion:^{
        }];
    }else {
        [reader CreateTheQR:self];
    }
}

-(void)dismissZbarAction {
    //Dlog(@"dismiss"); //iOS6
}
- (void)zbarDismissAction {
    //Dlog(@"dismiss"); //iOS7
}

-(void)getCodeString:(NSString *)codeString {
    self.str_qr_url = codeString;
    [self SubmitTheQR_Inform:codeString];
    isPressProduct=NO;
}

-(void)SubmitTheQR_Inform:(NSString *)str_QR_atu
{
    if([Function isConnectionAvailable])
    {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.mode = MBProgressHUDModeIndeterminate;
        hud.labelText = @"加载中...";//加载提示语言
        
        if(app.isPortal)
        {
            self.urlString=[NSString stringWithFormat:@"%@%@",KPORTAL_URL,KGET_CUSTOMER];
        }
        else
        {
             self.urlString=[NSString stringWithFormat:@"%@%@",kBASEURL,KGET_CUSTOMER];
        }
          
        NSURL *url = [ NSURL URLWithString :  self.urlString];
        ASIFormDataRequest *request = [ ASIFormDataRequest requestWithURL :url];
        request.delegate = self;
        request.tag = 101;
        [request setRequestMethod:@"POST"];
        [request setPostValue:[[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"account"]forKey:KUSER_UID];
        [request setPostValue:[[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"secret"] forKey:KUSER_PASSWORD];
        [request setPostValue:[[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"token"] forKey:@"user.token"];
        [request setPostValue:[[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"db_ip"] forKey:@"db_ip"];
        [request setPostValue:[[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"db_name"] forKey:@"db_name"];
        
        [request setPostValue:str_QR_atu forKey:KATU];
        [request setPostValue:@"1" forKey:@"stype"];//2考勤 1巡访 物料
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
    SBJsonParser *parser = [[SBJsonParser alloc] init];
    NSDictionary *dict =[parser objectWithString: jsonString];
    if([[dict objectForKey:@"ret"]isEqualToString:@"0"])
    {
        NSDictionary *dic=[dict objectForKey:@"CustomerInfo"];
        if( [[[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"gbelongto"] isEqualToString:[dic objectForKey:@"gbelongto"]])
        {
            app.str_cindex_no=[dic objectForKey:@"index_no"];//从二维码获取终端编号
            isProduct=NO;
            app.isApproval=YES;
            app.str_Product_material=@"1";//物料
            OrderListViewController *listVC=[[OrderListViewController alloc]init];
            listVC.str_title=@"物料信息登记";
            [self.navigationController pushViewController:listVC animated:NO];
        }
        else
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"您不隶属该部门,不能下订单!"delegate:nil cancelButtonTitle:nil otherButtonTitles:@"确定",nil];
            [alert show];
            alert=nil;
        }
        dic=nil;
    }
    else
    {
        [SGInfoAlert showInfo: [dict objectForKey:@"message"]
                      bgColor:[[UIColor darkGrayColor] CGColor]
                       inView:self.view
                     vertical:0.5];
    }
    dict=nil;
}
-(void)select_Date
{
    view_back=[[UIView alloc]initWithFrame:CGRectMake(0, moment_status+44, Phone_Weight, Phone_Height-moment_status-44)];
    view_back.backgroundColor=[UIColor colorWithRed:193/255.0 green:193/255.0 blue:193/255.0 alpha:0.6];
    [self.view addSubview:view_back];
    RBCustomDatePickerView *pickerView = [[RBCustomDatePickerView  alloc] initWithFrame:CGRectMake((Phone_Weight-278.5)/2, (view_back.frame.size.height-(190+54*2)-49)/2, 278.5, 54+190.0)];
    pickerView.backgroundColor=[UIColor clearColor];
    pickerView.layer.cornerRadius = 8;//设置视图圆角
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
        [btn addTarget:self action:@selector(btn_Action:) forControlEvents:UIControlEventTouchUpInside];
        [view_back  addSubview:btn];
    }
}

-(void)requestFinished:(ASIHTTPRequest *)request {
    if (request.tag == 100) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        if([request responseStatusCode]==200)
        {
            NSString * jsonString  =[request responseString];
            [self get_JsonString:jsonString ];
        }
        else
        {
            [SGInfoAlert showInfo:@"发生异常,请稍后再试"
                          bgColor:[[UIColor darkGrayColor] CGColor]
                           inView:self.view
                         vertical:0.5];
            [NdUncaughtExceptionHandler Post_url:[NSString stringWithFormat:@"URL:%@,HttpCode:%d",self.urlString,[request responseStatusCode]]];
        }
    }
    if (request.tag == 101) {
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
            [NdUncaughtExceptionHandler Post_url:[NSString stringWithFormat:@"URL:%@,HttpCode:%d",self.urlString,[request responseStatusCode]]];
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


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark ---- presentView delegate method

- (void)presentViewDissmissAction {
    
    [[KGModal sharedInstance] closeAction:nil];
    
}
@end
