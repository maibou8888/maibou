//
//  AddNewClerkOrRivalViewController.m
//  WZYB_syb
//
//  Created by wzyb on 14-8-25.
//  Copyright (c) 2014年 WZYB. All rights reserved.
//
#import <AssetsLibrary/AssetsLibrary.h>
#import "AddNewClerkOrRivalViewController.h"
#import "UIImageView+WebCache.h"
#import "AppDelegate.h"
#import "RegisterViewController.h"
#import "KGModal.h"
#import <QuartzCore/QuartzCore.h>
#import "PresentView.h"
@interface AddNewClerkOrRivalViewController ()<ASIHTTPRequestDelegate,PresentViewDelegate>
{
    AppDelegate *app;
    NSString *tempBtnTag;
    NSMutableArray *tempArray;
    NSData *imageData;
    NSString *tempIndexNumber;
    NSString *KAddressString;
    NSMutableString *mutString;
}
@end
@implementation AddNewClerkOrRivalViewController
@synthesize str_value1=str_value1;
@synthesize str_value2=str_value2;
@synthesize str_value3=str_value3;
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
    if(isIOS7)
    {
         scrollView_Back.frame=CGRectMake(0, moment_status+44,Phone_Weight, Phone_Height-moment_status-44);
    }
    else
    {
         scrollView_Back.frame=CGRectMake(0, moment_status+44,Phone_Weight, Phone_Height-44);
    }
    [self.view addSubview:scrollView_Back];
    scrollView_Back.backgroundColor=[UIColor clearColor];
}
-(void)viewWillAppear:(BOOL)animated
{
    if(self.isDetail)
    {
        if(!isFirstOpen) //第一次进来时调用  前一个页面传过来的值
        {
            isFirstOpen=YES;
            tex_0.text=self.str_tex0;
            tex_1.text=self.str_tex1;
            tex_2.text=self.str_tex2;
            tex_3.text=self.str_tex3;
            tex_4.text=self.str_tex4;
            tex_5.text=self.str_tex5;
            tex_6.text=self.str_tex6;
            tex_7.text=self.str_tex7;
            tex_8.text=self.str_tex8;
            
            app.str_LocationName=self.str_tex7;
            [self CreatView:[self.dic_data_all objectForKey:@"DynamicList"]
                      Media:[self.dic_data_all objectForKey:@"MediaList"]];
        }
        else
        {//修改
            [self Edit_AllInform];
        }
    }
    else
    {//编辑
        if(!isFirstOpen) //点击创建进来时调用
        {
            isFirstOpen=YES;
            [self Get_dynamic];//获取动态列表
        }
        else
        {
            [self Edit_AllInform];
        }      
    }
}

-(void)viewWillDisappear:(BOOL)animated {
}
-(void)Edit_AllInform
{
    if(num_editer==-1||[app.str_temporary isEqualToString:@"0"])
        return;
    UITextField *tex=[arr_tex objectAtIndex:num_editer];
    if(num_editer==8)
    {
        tex_7.text=app.str_LocationName;
    }
    else
    {
        if(tex.tag==1)
        {
            str_value1=app.str_temporary_valueH;
            tex.text=app.str_temporary;
        }
        else if(num_editer==4)
        {
            tex_8.text = app.str_temporary;
        }
        else if(num_editer==5)
        {
            tex_4.text = app.str_temporary;
        }
        else if(tex.tag==6)
        {
            str_value2=app.str_temporary_valueH;
            tex.text=app.str_temporary;
        }
        else if(tex.tag==7)
        {
            str_value3=app.str_temporary_valueH;
            tex.text=app.str_temporary;
            
        }else {
            tex.text=app.str_temporary;
        }
    }
    num_editer=-1;
}
-(void)All_Init
{
    mutString = [NSMutableString string];
    tex_7.text = @"定位中...";
    KAddressString = @"";
    app=(AppDelegate *)[[UIApplication sharedApplication]delegate];
    if(StatusBar_System>0)
        moment_status=20;
    else moment_status=0;
    combox_height_thisView=combox_height;
    near_by_thisView=Near_By;
    num_editer=-1;
    imageData = [NSData data];
    tempBtnTag = [NSString string];
    arr_tex=[[NSMutableArray alloc]init];
    arr_Media_image=[[NSMutableArray alloc]init];
    arr_ShowImage=[[NSMutableArray alloc]init];
    tempArray = [NSMutableArray array];
    NavView *nav_View=[[NavView alloc]init];
    if(self.isDetail)
    {
        if([self.str_title isEqualToString:@"0"])
        {
            [self.view addSubview: [nav_View NavView_Title1:@"新客户详细"]];
        }
        else if([self.str_title isEqualToString:@"1"])
        {
            [self.view addSubview: [nav_View NavView_Title1:@"竞争对手详细"]];
        }
        else if([self.str_title isEqualToString:@"2"])
        {
            [self.view addSubview: [nav_View NavView_Title1:@"签约客户"]];
        }
    }
    else
    {
        if([self.str_title isEqualToString:@"0"])
        {
            [self.view addSubview: [nav_View NavView_Title1:@"添加新客户"]];
        }
        else
        {
            [self.view addSubview: [nav_View NavView_Title1:@"添加竞争对手"]];
        }
    }
    //左边返回键
    UIButton *btn=[UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame=CGRectMake(0, moment_status, 60, 44);
    [btn setBackgroundImage:[UIImage imageNamed:@"btn_color6.png"] forState:UIControlStateHighlighted];
    btn.backgroundColor=[UIColor clearColor];
    btn.tag=buttonTag-1;
    [btn setTitle:@"< 返回" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    btn.titleLabel.font=[UIFont systemFontOfSize:15];
    [btn addTarget:self action:@selector(btn_Action:) forControlEvents:UIControlEventTouchUpInside ];
    [nav_View.view_Nav  addSubview:btn];
    //背景图案
   [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"AddNewClerkBacground"]]];
    //
    //放大图片 的背景
    view_imageView_back=[[UIView alloc]init];
    view_imageView_back.backgroundColor=[UIColor blackColor];
    view_imageView_back.frame=CGRectMake(0, 0, Phone_Weight, Phone_Height);

    if([Function isConnectionAvailable]) {
        if (self.addressFlag == 1) {
            [self locationInfo];
        }
    }else {
        tex_7.text = @"地址未知";
        if (!self.isDetail) {
            if([self.str_title isEqualToString:@"0"])
            {
                if([Function judgeFileExist:Customer_List Kind:Library_Cache])
                {
                    NSDictionary *dict = [Function ReadFromFile:Customer_List Kind:Library_Cache];
                    [self CreatView:[dict objectForKey:@"DynamicList"]
                              Media:[dict objectForKey:@"MediaList"]];
                }
            }
            else
            {
                if([Function judgeFileExist:Opponent_List Kind:Library_Cache])
                {
                    NSDictionary *dict = [Function ReadFromFile:Opponent_List Kind:Library_Cache];
                    [self CreatView:[dict objectForKey:@"DynamicList"]
                              Media:[dict objectForKey:@"MediaList"]];
                }
            }
        }
    }
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
    if (self.addressFlag == 1) {
        
        app.str_nlng = [NSString stringWithFormat:@"%f",userLocation.location.coordinate.longitude];
        app.str_alat = [NSString stringWithFormat:@"%f",userLocation.location.coordinate.latitude];
        
        if (app.str_nlng.integerValue > 0 && app.str_alat.integerValue > 0) {
            CLGeocoder *geocoder = [[CLGeocoder alloc] init];
            [geocoder reverseGeocodeLocation: userLocation.location completionHandler:^(NSArray *array, NSError *error) {
                if(error==0&&array.count > 0) {
                    CLPlacemark *placemark = [array objectAtIndex:0];
                    if ([Function StringIsNotEmpty:placemark.administrativeArea]) {
                        [mutString appendString:placemark.administrativeArea];
                    }
                    if ([Function StringIsNotEmpty:placemark.locality]) {
                        [mutString appendString:placemark.locality];
                    }
                    if ([Function StringIsNotEmpty:placemark.subLocality]) {
                        [mutString appendString:placemark.subLocality];
                    }
                    if ([Function StringIsNotEmpty:placemark.thoroughfare]) {
                        [mutString appendString:placemark.thoroughfare];
                    }
                    
                    app.str_LocationName=[NSString stringWithFormat:@"%@",mutString];
                    KAddressString = [NSString stringWithFormat:@"%@%@%@%@",placemark.administrativeArea,placemark.locality,placemark.subLocality,placemark.thoroughfare];
                    if ([Function StringIsNotEmpty:app.str_LocationName]) {
                        tex_7.text = app.str_LocationName;
                    }else {
                        tex_7.text = @"未知地址";
                    }
                }
            }];
            geocoder=nil;
        }else {
            tex_7.text = @"点击定位";
        }
    }else if (self.addressFlag == 2) {
        CLGeocoder *geocoder = [[CLGeocoder alloc] init];
        [geocoder reverseGeocodeLocation: userLocation.location completionHandler:^(NSArray *array, NSError *error) {
            if(error==0&&array.count > 0) {
                CLPlacemark *placemark = [array objectAtIndex:0];
                KAddressString = [NSString stringWithFormat:@"%@%@%@%@",placemark.administrativeArea,placemark.locality,placemark.subLocality,placemark.thoroughfare];
            }
        }];
        geocoder=nil;
    }
    [self.locService stopUserLocationService];
}

-(void)CreatView:(NSArray *)arr_DynamicList Media:(NSArray *)arr_MediaList
{
//----------------静态
    [arr_tex addObject:tex_0];
    [arr_tex addObject:tex_1];
    [arr_tex addObject:tex_2];
    [arr_tex addObject:tex_3];
    [arr_tex addObject:tex_4];
    [arr_tex addObject:tex_8];
    [arr_tex addObject:tex_5];
    [arr_tex addObject:tex_6];
    [arr_tex addObject:tex_7];
    
    array_Dynamic=[[NSMutableArray alloc]init];
    NSArray *arr_allTitle;//所有静态跳转页面标题
    arr_allTitle=[NSArray arrayWithObjects:@"名称",@"类型",@"联系人",@"电话",@"邮件",@"规模",@"档次",@"状态",@"地址", nil];
    for(NSInteger i=0;i<9;i++)
    {
        UITextField *tex=[arr_tex objectAtIndex:i];
        tex.enabled=NO;
        tex.textAlignment=NSTextAlignmentRight;
        NSDictionary *dic=[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[arr_allTitle objectAtIndex:i],@"-1",@"-1", @"-1",@"-1",@"-1",@"-1",nil] forKeys:[NSArray arrayWithObjects:@"tname",@"trequired",@"data_type",@"tdefault", @"tag",@"index_no",@"tindex_no",nil]];
        [array_Dynamic addObject:dic];
    }

    [btn_0 addTarget:self action:@selector(Action_textField: ) forControlEvents:UIControlEventTouchUpInside];
    [btn_1 addTarget:self action:@selector(Action_textField: ) forControlEvents:UIControlEventTouchUpInside];
    [btn_2 addTarget:self action:@selector(Action_textField: ) forControlEvents:UIControlEventTouchUpInside];
    [btn_3 addTarget:self action:@selector(Action_textField: ) forControlEvents:UIControlEventTouchUpInside];
    [btn_4 addTarget:self action:@selector(Action_textField: ) forControlEvents:UIControlEventTouchUpInside];
    [btn_5 addTarget:self action:@selector(Action_textField: ) forControlEvents:UIControlEventTouchUpInside];
    [btn_6 addTarget:self action:@selector(Action_textField: ) forControlEvents:UIControlEventTouchUpInside];
    [btn_7 addTarget:self action:@selector(Action_textField: ) forControlEvents:UIControlEventTouchUpInside];
    [btn_8 addTarget:self action:@selector(Action_textField: ) forControlEvents:UIControlEventTouchUpInside];
    
    if (self.authFlag == 1) {
       NSString *str_auth=[[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"auth"];//用户权限级别
        if ([str_auth isEqualToString:@"2"] || [str_auth isEqualToString:@"4"]) {
            btn_7.enabled = YES;
        }else {
            btn_7.enabled = NO;
        }
    }
//----------------动态
    btn_tag=9;
    momentHeight=560;
    if(arr_DynamicList.count!=0)
    {
        //专属信息（长条背景图片）
        UIImageView *imgView=[[UIImageView alloc]init];
        imgView.frame=CGRectMake(0, momentHeight, Phone_Weight, 53);
        imgView.image=[UIImage imageNamed:@"icon_AddNewClerk_NextTitle.png"];
        [scrollView_Back addSubview:imgView];
        
        UILabel *lab=[[UILabel alloc]init];
        lab.frame=CGRectMake(54, 8, 100, 38);
        lab.backgroundColor=[UIColor clearColor];
        lab.textColor=[UIColor colorWithRed:214/255.0 green:28/255.0 blue:29/255.0 alpha:1.0];
        lab.text=@"专属信息";
        lab.font=[UIFont systemFontOfSize:19.0];
        [imgView addSubview:lab];
        
        //专属信息前面的图片
        UIImageView *imgView_icon1=[[UIImageView alloc]init];
        imgView_icon1.frame=CGRectMake(14, 10, 32, 32);
        imgView_icon1.backgroundColor=[UIColor clearColor];
        imgView_icon1.image=[UIImage imageNamed:@"iconic_3.png"];
        [imgView addSubview:imgView_icon1];
        momentHeight+=53;
        
        for(NSInteger i=0;i<arr_DynamicList.count;i++)
        {
            NSDictionary *dic=[arr_DynamicList objectAtIndex:i];
            NSMutableDictionary *dict=[[NSMutableDictionary alloc]init];
            
            UIButton *btn=[UIButton buttonWithType:UIButtonTypeCustom];
            btn.frame=CGRectMake((Phone_Weight-300)/2, momentHeight, 300, 44);
            btn.tag=btn_tag++;
            [dict setObject:[NSString stringWithFormat:@"%ld",(long)btn.tag] forKey:@"btn.tag"];
            btn.backgroundColor=[UIColor clearColor];
            if(arr_DynamicList.count==1)
            {
                [btn setBackgroundImage:[UIImage imageNamed:@"set_single@2X.png"] forState: UIControlStateNormal];
            }
            else
            {
                if(i==0)
                {
                    [btn setBackgroundImage:[UIImage imageNamed:@"set_header@2X.png"] forState: UIControlStateNormal];
                }
                else if(i==arr_DynamicList.count-1)
                {
                    [btn setBackgroundImage:[UIImage imageNamed:@"set_bottom@2X.png"] forState: UIControlStateNormal];
                }
                else
                {
                    [btn setBackgroundImage:[UIImage imageNamed:@"set_middle@2X.png"] forState: UIControlStateNormal];
                }
            }
            
            //箭头
            UIImageView *imgView_arrow=[[UIImageView alloc]init];
            imgView_arrow.backgroundColor=[UIColor clearColor];
            imgView_arrow.image=[UIImage imageNamed:@"icon_everyline_arrow.png"];
            imgView_arrow.frame=CGRectMake(270,(44-10)/2.0, 6, 10);
            [btn addSubview:imgView_arrow];

            [btn addTarget:self action:@selector(Action_textField:) forControlEvents:UIControlEventTouchUpInside];
            [scrollView_Back addSubview:btn];
            
            //属性 (前排label)
            UILabel *lab1=[[UILabel alloc]init];
            lab1.frame=CGRectMake(10, 0, 140, 44);
            lab1.backgroundColor=[UIColor clearColor];
            lab1.text=[dic objectForKey:@"tname"];
            lab1.font=[UIFont systemFontOfSize:15.0];
            [btn addSubview:lab1];
            
            //文本框
            UITextField *tex1=[[UITextField alloc]init];
            if(isIOS7)
            {
                 tex1.frame=CGRectMake(150, (44-30)/2.0, 107, 30);
            }
            else
            {
                 tex1.frame=CGRectMake(150, (44-30)/2.0-toolBar_Height/2, 107, 30);
            }
            tex1.textAlignment=NSTextAlignmentRight;
            tex1.backgroundColor=[UIColor clearColor];
            [dict setObject:[dic objectForKey:@"tname"] forKey:@"tname"];
            if([[dic objectForKey:@"trequired"] isEqualToString:@"1"])
            {
                 [dict setObject:@"1" forKey:@"trequired"];//1必填
                 tex1.placeholder=@"必填";
            }
            else
            {
                 [dict setObject:@"-1" forKey:@"trequired"];
                 tex1.placeholder=@"选填";
            }
            [dict setObject:[dic objectForKey:@"data_type"] forKey:@"data_type"];
            [dict setObject:[dic objectForKey:@"tdefault"] forKey:@"tdefault"];
            [dict setObject:[NSString stringWithFormat:@"%ld",(long)btn.tag] forKey:@"tag"];
            if([Function isBlankString:[dic objectForKey:@"index_no"]])
            {//在手机这边做插入就没有index_no  这个属性 是没有的 默认动态 是-2
                [dict setObject:@"-2" forKey:@"index_no"];
            }
            else
            {
                [dict setObject:[dic objectForKey:@"index_no"] forKey:@"index_no"];
            }
            if(self.isDetail && ![self local])
            {
               [dict setObject:[dic objectForKey:@"tindex_no"] forKey:@"tindex_no"];
            }
            [array_Dynamic addObject:dict];
            dict=nil;
            
            tex1.font=[UIFont systemFontOfSize:15.0];
            tex1.enabled=NO;
            tex1.tag=btn.tag;
            [btn addSubview:tex1];
            if(self.isDetail)
            {
                tex1.text=[dic objectForKey:@"tcontent"];
            }
            [arr_tex addObject:tex1];
            momentHeight+=44;
        }
    }
//----------------媒体
    if(arr_MediaList.count!=0)
    {
        //背景图片
        UIImageView *imgView=[[UIImageView alloc]init];
        imgView.frame=CGRectMake(0, momentHeight, Phone_Weight, 53);
        imgView.image=[UIImage imageNamed:@"icon_AddNewClerk_NextTitle.png"];
        [scrollView_Back addSubview:imgView];
        
        //字体信息
        UILabel *lab=[[UILabel alloc]init];
        lab.frame=CGRectMake(54, 8, 100, 38);
        lab.backgroundColor=[UIColor clearColor];
        lab.textColor=[UIColor colorWithRed:25/255.0 green:35/255.0 blue:49/255.0 alpha:1.0];
        lab.text=@"媒体信息";
        lab.font=[UIFont systemFontOfSize:19.0];
        [imgView addSubview:lab];
        
        //媒体前面的小图片
        UIImageView *imgView_icon1=[[UIImageView alloc]init];
        imgView_icon1.frame=CGRectMake(14, 10, 32, 32);
        imgView_icon1.backgroundColor=[UIColor clearColor];
        imgView_icon1.image=[UIImage imageNamed:@"iconic_4.png"];
        [imgView addSubview:imgView_icon1];
        momentHeight+=53;
        
        for (NSInteger i=0; i<arr_MediaList.count; i++)
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
            NSDictionary *dic=[arr_MediaList objectAtIndex:i];
            
            //媒体信息的图片设置
            UIImageView *imageView_Back=[[UIImageView alloc] init];
            imageView_Back.backgroundColor=[UIColor clearColor];
            if(self.isDetail)
            {
                if ([self local]) {
                    NSData *imageData1 = [dic objectForKey:@"imageData"];
                    if(imageData1.length) {
                        UIImage *image = [UIImage imageWithData:imageData1];
                        imageView_Back.image = image;
                    }else {
                        imageView_Back.image = [UIImage imageNamed:@"default_picture.png"];
                    }
                }else {
                    [imageView_Back setImageWithURL:[dic objectForKey:@"mpath"]
                                   placeholderImage:[UIImage imageNamed:@"default_picture.png"]
                                            success:^(UIImage *image) { }
                                            failure:^(NSError *error) {//Dlog(@"图片显示失败NO");
                                            }];
                }
            }
            else
            {
                imageView_Back.image=[UIImage imageNamed:@"icon_take_picture"];
            }
            imageView_Back.userInteractionEnabled=YES;
            [view_btn addSubview:imageView_Back];
            [arr_ShowImage addObject:imageView_Back];
            imageView_Back.frame=CGRectMake(view_btn.frame.size.width- view_btn.frame.size.height ,10,view_btn.frame.size.height-20, view_btn.frame.size.height-20);
            //照片前面的文字设置
            UILabel *lab_describ=[[UILabel alloc]initWithFrame:CGRectMake(0, 0, view_btn.frame.size.width-imageView_Back.frame.size.width, view_btn.frame.size.height)];
            lab_describ.backgroundColor=[UIColor clearColor];
            lab_describ.textAlignment=NSTextAlignmentCenter;
            lab_describ.font=[UIFont systemFontOfSize:app.Font];
            [view_btn addSubview:lab_describ];
            
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
            btn_image.tag=buttonTag+i;
            [btn_image addTarget:self action:@selector(BigImage:) forControlEvents:UIControlEventTouchUpInside];
            
            //required97
            NSMutableDictionary *dic_media=[[NSMutableDictionary alloc]init];
            if (![self local]) {
                [dic_media setObject:[dic objectForKey:@"required97"] forKey:@"required"];
                [dic_media setObject:[dic objectForKey:@"required97"] forKey:@"required97"];
                [dic_media setObject:[dic objectForKey:@"clabel"] forKey:@"clabel"];
            }
            UIImageView *imageView=[[UIImageView alloc]init];
            if(self.isDetail)
            {
                if (![self local]) {
                    [dic_media setObject:[dic objectForKey:@"mtype"]  forKey:@"mtype"];
                    [imageView setImageWithURL:[NSURL URLWithString:[dic objectForKey:@"mpath"]]
                              placeholderImage:[UIImage imageNamed:@"default_picture.png"]];
                    
                    if([Function isBlankString:[dic objectForKey:@"mpath"]]){
                        [dic_media setObject:@"0" forKey:@"is_addimg"];//无图
                        [dic_media setObject:@"" forKey:@"dicMpath"];
                    }
                    else{
                        [dic_media setObject:@"1" forKey:@"is_addimg"];//已有图片计为1
                        [dic_media setObject:[dic objectForKey:@"mpath"] forKey:@"dicMpath"];
                    }
                     [dic_media setObject:@"0" forKey:@"re_take"];//是否重照 默认 0 否 1是
                }else {
                    [dic_media setObject:[dic objectForKey:@"required97"] forKey:@"required"];
                    [dic_media setObject:[dic objectForKey:@"required97"] forKey:@"required97"];
                    [dic_media setObject:[dic objectForKey:@"clabel"] forKey:@"clabel"];
                    [dic_media setObject:[dic objectForKey:@"is_addimg"] forKey:@"is_addimg"];
                    NSString *re_take = [dic objectForKey:@"re_take"];
                    NSString *mtype = [dic objectForKey:@"mtype"];
                    NSData *data = [dic objectForKey:@"imageData"];
                    if (re_take.length) {
                        [dic_media setObject:re_take forKey:@"re_take"];//图片初始化
                    }else {
                        [dic_media setObject:@"" forKey:@"re_take"];//图片初始化
                    }
                    
                    if (mtype.length) {
                        [dic_media setObject:mtype forKey:@"mtype"];//图片初始化
                    }else {
                        [dic_media setObject:@"" forKey:@"mtype"];//图片初始化
                    }
                    
                    if (data.length) {
                        [dic_media setObject:data forKey:@"imageData"];//图片初始化
                    }else {
                        [dic_media setObject:@"" forKey:@"imageData"];//图片初始化
                    }
                }
                
                [dic_media setObject:@"0" forKey:@"isme"];//是否我正在拍照 1是在拍 其他不是
                [arr_Media_image addObject:dic_media];
            }
            else
            {
                [dic_media setObject:[dic objectForKey:@"h7type"]  forKey:@"mtype"];
                [dic_media setObject:@"0" forKey:@"is_addimg"];//暂无图片初始化 0
                [dic_media setObject:@"0" forKey:@"isme"];//是否我正在拍照 1是在拍 其他不是
                NSData *imagedata=UIImagePNGRepresentation(imageView.image);
                if (imagedata.length) {
                    [dic_media setObject:imagedata forKey:@"imageData"];//图片初始化
                }else {
                    [dic_media setObject:@"" forKey:@"imageData"];//图片初始化
                }
                [arr_Media_image addObject:dic_media];
            }
            imageView=nil;
            dic_media=nil;
            dic=nil;
            imageView_Back=nil;
            momentHeight+=88;
        }
    }
    momentHeight+=44;
    
//    //更新(提交)按钮
    if (!self.editFlag) {
        UIButton *btn=[UIButton buttonWithType:UIButtonTypeCustom];
        [btn.layer setMasksToBounds:YES];
        [btn.layer setCornerRadius:5.0];//设置矩形四个圆角半径
        btn.frame=CGRectMake((Phone_Weight-300)/2, momentHeight, 300, 44);
        btn.backgroundColor=[UIColor clearColor];
        [btn setBackgroundImage:[UIImage imageNamed:@"btn_color6.png"] forState:UIControlStateNormal];
        [btn setBackgroundImage:[UIImage imageNamed:@"btn_color1.png"] forState:UIControlStateHighlighted];
        [btn addTarget:self action:@selector(btn_Action:) forControlEvents:UIControlEventTouchUpInside];
        [scrollView_Back  addSubview:btn];
        
        btn.titleLabel.textColor=[UIColor whiteColor];
        btn.titleLabel.font=[UIFont systemFontOfSize:15];
        if(self.isDetail)
        {//更新
            if([self Local]) {
                [btn setTitle:@"提交" forState:UIControlStateNormal];
            }else {
                [btn setTitle:@"更新" forState:UIControlStateNormal];
            }
            btn.tag=buttonTag;
        }
        else
        {//提交
            [btn setTitle:@"提交" forState:UIControlStateNormal];
            btn.tag=buttonTag+1;
        }
        momentHeight+=44;
        
        //保存本地按钮
        if (self.showLocalImage) {
            UIButton *btn1 = [UIButton buttonWithType:UIButtonTypeCustom];
            [btn1.layer setMasksToBounds:YES];
            [btn1.layer setCornerRadius:5.0];//设置矩形四个圆角半径
            btn1.frame=CGRectMake((Phone_Weight-300)/2, momentHeight+10, 300, 44);
            [btn1 setTitle:@"离线保存" forState:UIControlStateNormal];
            btn1.tag=buttonTag+2;
            btn1.titleLabel.textColor=[UIColor whiteColor];
            btn1.titleLabel.font=[UIFont systemFontOfSize:15];
            btn1.backgroundColor=[UIColor clearColor];
            [btn1 setBackgroundImage:[UIImage imageNamed:@"btn_color1.png"] forState:UIControlStateNormal];
            [btn1 addTarget:self action:@selector(btn_Action:) forControlEvents:UIControlEventTouchUpInside];
            [scrollView_Back  addSubview:btn1];
            momentHeight+=44;
        }
        
        if (self.isDetail && self.showLocalImage) {
            UIButton *btn2 = [UIButton buttonWithType:UIButtonTypeCustom];
            [btn2.layer setMasksToBounds:YES];
            [btn2.layer setCornerRadius:5.0];//设置矩形四个圆角半径
            btn2.frame=CGRectMake((Phone_Weight-300)/2, momentHeight+20, 300, 44);
            [btn2 setTitle:@"离线删除" forState:UIControlStateNormal];
            btn2.tag=buttonTag+3;
            btn2.titleLabel.textColor=[UIColor whiteColor];
            btn2.titleLabel.font=[UIFont systemFontOfSize:15];
            btn2.backgroundColor=[UIColor clearColor];
            [btn2 setBackgroundImage:[UIImage imageNamed:@"btn_color7.png"] forState:UIControlStateNormal];
            [btn2 addTarget:self action:@selector(btn_Action:) forControlEvents:UIControlEventTouchUpInside];
            [scrollView_Back  addSubview:btn2];
            momentHeight+=44;
        }
    }
    
    scrollView_Back.contentSize=CGSizeMake(0, momentHeight+50);
}
-(void)btn_Action:(UIButton *)btn
{
    if(btn.tag==buttonTag-1) //返回
    {
        if(self.isDetail)
        {
            app.isOnlyGoBack=YES;
            [self.navigationController popViewControllerAnimated:YES];
            return;
        }
        else
        {
            [self WhenBack_mention];
        }
    }
    else if(btn.tag==buttonTag)//更新
    {
        if([self Verify_All])
        {
            UIAlertView *alert = nil;
            if ([self Local]) {
                alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"是否提交数据" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定",nil];
            }else {
                alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"是否更新数据" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定",nil];
            }
            [alert show];
            alert.tag=2;
            alert=nil;
        }
    }
    else if(btn.tag==buttonTag+1)//提交
    {
        if([self Verify_All])
            [self Mention_alert];
    }
    else if(btn.tag==buttonTag*2+2) //取消
    {
        [view_back removeFromSuperview];
        UITextField *tempTextField = [arr_tex objectAtIndex:dateIndex];
        tempTextField.text=@"";
        isOpenDate=NO;
    }
    else if(btn.tag==buttonTag+3) //确定
    {
        NSMutableArray *customerLArray = nil;
        if([Function judgeFileExist:Customer_Local Kind:Library_Cache])
        {
            customerLArray = [Function ReadFromFile:Customer_Local WithKind:Library_Cache];
            if (customerLArray.count) {
                for (int i = 0; i < customerLArray.count; i ++) {
                    NSString *numberString = [[customerLArray objectAtIndex:i] objectForKey:@"tempIndexNumber"];
                    if ([numberString isEqualToString:self.convertNumber]) {
                        [customerLArray removeObjectAtIndex:i];
                        break;
                    }
                }
            }
            
            NSString *str1= [Function achieveThe_filepath:Customer_Local Kind:Library_Cache];
            [Function Delete_TotalFileFromPath:str1];
            [Function creatTheFile:Customer_Local Kind:Library_Cache];
            [Function WriteToFile:Customer_Local File:customerLArray Kind:Library_Cache];
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
    else if(btn.tag==buttonTag*2+3) //确定
    {
        num_editer=-1;
        [view_back removeFromSuperview];
        isOpenDate=NO;
        if(app.isDateLegal)
        {
            UITextField *text=[arr_tex objectAtIndex:dateIndex];
            text.text=app.str_Date;
        }
        else 
        {
            app.str_Date=[Function getYearMonthDay_Now];
            UITextField *text=[arr_tex objectAtIndex:dateIndex];
            text.text=app.str_Date;
        }
    }else if (btn.tag == buttonTag + 2) {
        NSString *dateString = [Function getSystemTimeNow];
        NSMutableArray *localArray = [NSMutableArray array];
        for (int i = 9; i < array_Dynamic.count; i ++) {
            NSMutableDictionary *mutableDic = [array_Dynamic objectAtIndex:i];
            UITextField *tempTextField = [arr_tex objectAtIndex:i ];
            [mutableDic setObject:tempTextField.text forKey:@"tcontent"];
            [localArray addObject:mutableDic];
        }
        NSDictionary *tempDic = [[NSDictionary alloc] initWithObjectsAndKeys:localArray,@"DynamicList",arr_Media_image,@"MediaList", nil];
        NSMutableDictionary *normalDic = [NSMutableDictionary dictionary];
        if (![Function StringIsNotEmpty:self.convertNumber]) {
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            tempIndexNumber = [defaults objectForKey:@"tempIndexNumber"];
            if (tempIndexNumber.length) {
                tempIndexNumber = [NSString stringWithFormat:@"%ld",tempIndexNumber.integerValue + 1];
            }else {
                tempIndexNumber = @"1";
            }
            [defaults setObject:tempIndexNumber forKey:@"tempIndexNumber"];
            [defaults synchronize];
        }else {
            tempIndexNumber = [NSString stringWithFormat:@"%@",self.convertNumber];
        }
        
        [self MutableDic:normalDic setObject:tempIndexNumber forKey:@"tempIndexNumber"];
        [self MutableDic:normalDic setObject:dateString forKey:@"ins_date"];
        [self MutableDic:normalDic setObject:tex_7.text forKey:@"gaddress"];
        [self MutableDic:normalDic setObject:self.str_title forKey:@"gtype"];
        [self MutableDic:normalDic setObject:@"1" forKey:@"local"];
        [self MutableDic:normalDic setObject:tex_0.text forKey:@"gname"];
        [self MutableDic:normalDic setObject:str_value1 forKey:@"svtype"];
        [self MutableDic:normalDic setObject:tex_2.text forKey:@"gcontact"];
        [self MutableDic:normalDic setObject:tex_3.text forKey:@"gtel"];
        [self MutableDic:normalDic setObject:tex_4.text forKey:@"gvolume"];
        [self MutableDic:normalDic setObject:str_value2 forKey:@"plevel"];
        [self MutableDic:normalDic setObject:str_value3 forKey:@"gcoopstate"];
        [self MutableDic:normalDic setObject:app.str_nlng forKey:@"glng"];
        [self MutableDic:normalDic setObject:app.str_alat forKey:@"glat"];
        [self MutableDic:normalDic setObject:tex_8.text forKey:@"gmail"];
        if (tempDic.count) {
            [normalDic setObject:tempDic forKey:@"tempDic"];
        }
        
        NSMutableArray *customerLArray = nil;
        if([Function judgeFileExist:Customer_Local Kind:Library_Cache])
        {
            customerLArray = [Function ReadFromFile:Customer_Local WithKind:Library_Cache];
        }
        if (!customerLArray.count) {
            customerLArray = [NSMutableArray array];
        }
        
        for (int i = 0; i <customerLArray.count; i ++) {
            NSDictionary *dic = [customerLArray objectAtIndex:i];
            NSString *tempIndexNumber1 = [dic objectForKey:@"tempIndexNumber"];
            if (self.convertNumber.length) {
                if ([self.convertNumber isEqualToString:tempIndexNumber1]) {
                    [customerLArray removeObjectAtIndex:i];
                }
            }
        }
        [customerLArray addObject:normalDic];
        NSString *str1= [Function achieveThe_filepath:Customer_Local Kind:Library_Cache];
        [Function Delete_TotalFileFromPath:str1];
        [Function creatTheFile:Customer_Local Kind:Library_Cache];
        [Function WriteToFile:Customer_Local File:customerLArray Kind:Library_Cache];
        [self.navigationController popViewControllerAnimated:YES];
    }
}
-(BOOL)Verify_All//校验必填选项
{
    //静态
    if([tex_0.text isEqualToString:@""]||[Function isBlankString:tex_0.text] || [tex_2.text isEqualToString:@""]||[Function isBlankString:tex_2.text] || [tex_3.text isEqualToString:@""]||[Function isBlankString:tex_3.text])
    {
        [self Must_write];
        return NO;
    }
    //动态
    for(NSInteger i=0;i<array_Dynamic.count;i++)
    {
        NSDictionary *dic=[array_Dynamic objectAtIndex:i];
        if([[dic objectForKey:@"trequired"]isEqualToString:@"1"])
        {
            UITextField *tex=[arr_tex objectAtIndex:[[dic objectForKey:@"tag"] integerValue]];
            if([tex.text isEqualToString:@""]||[Function isBlankString:tex.text])
            {
                [self Must_write];
                return NO;
            }
        }
    }
    if([Function isBlankString:app.str_LocationName ]||[app.str_LocationName  isEqualToString:@""]||[Function isBlankString:app.str_nlng]||[app.str_nlng isEqualToString:@""]||[Function isBlankString:app.str_alat]||[app.str_alat isEqualToString:@""])
    {
        [SGInfoAlert showInfo:@"地址无效,请重新填写地址"
                      bgColor:[[UIColor darkGrayColor] CGColor]
                       inView:self.view
                     vertical:0.5];
        return NO;
    }
    //媒体
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
    return YES;
}
-(void)Must_write
{//如果必填字段为空或者字符串长度为0 做提示 并且不予提交远程
    [SGInfoAlert showInfo:@"请把必填内容完善,再尝试提交"
                  bgColor:[[UIColor darkGrayColor] CGColor]
                   inView:self.view
                 vertical:0.5];
}
-(void)Mention_alert
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"是否提交数据" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定",nil];
    [alert show];
    alert.tag=1;
    alert=nil;
}
-(void)Action_textField:(UIButton*)btn
{
    num_editer=btn.tag;//设置标记索引
    NSDictionary *dic=[array_Dynamic objectAtIndex:btn.tag];
    if(btn.tag==8)
    {
        if ([Function isConnectionAvailable]) {
            OrientationViewController *locVC=[[OrientationViewController alloc]init];
            locVC.editFlag = self.editFlag;
            locVC.str_title=@"地图点选终端位置";
            locVC.str_IsFromWhere=@"1";//客户
            if ([self local]) {
                NSString *addressStr = tex_7.text;
                if ([addressStr isEqualToString:@"地址未知"]) {
                    app.str_LocationName = @"";
                }
            }
            [self.navigationController pushViewController:locVC animated:YES];
        }
    }
    else if(btn.tag==1||btn.tag==6||btn.tag==7||[[dic objectForKey:@"data_type"]isEqualToString:@"4"])
    {//动态项目类型（0:数字，1:文本，2:金额，3:日期，4:列表）
       // if(self.isDetail)return;
        UIActionSheetViewController *actionVC=[[UIActionSheetViewController alloc]init];
        if (self.editFlag) {
            actionVC.editFlag = self.editFlag;
        }
        if(btn.tag==1)
        {
            actionVC.str_title=@"客户类型";
            actionVC.str_H=@"H12";
        }
        else if(btn.tag==6)
        {
            actionVC.str_title=@"经营档次";
            actionVC.str_H=@"H4";
        }
        else if(btn.tag==7)
        {
            actionVC.str_title=@"经营状态";
            actionVC.str_H=@"H3";
        }
        else//tdefault  就是 Hxx
        {
            actionVC.str_title=[dic objectForKey:@"tname"];
            actionVC.str_tdefault=[dic objectForKey:@"tdefault"];
        }
        [self.navigationController pushViewController:actionVC animated:YES];
    }
    else if([[dic objectForKey:@"data_type"]isEqualToString:@"3"])
    {//是日期
        if (!self.editFlag) {
            dateIndex=btn.tag;
            [self select_Date];
        }
    }
    else
    {
        NoteViewController *noteVC=[[NoteViewController alloc]init];
        noteVC.str_title=[dic objectForKey:@"tname"];
        noteVC.placeHolderString = [dic objectForKey:@"tdefault"];
        if (self.editFlag) {
            noteVC.editFlag = self.editFlag;
        }
        //动态项目类型（0:数字，1:文本，2:金额 3）
        if(self.isDetail)
        {
            noteVC.isDetail=NO;
        }
        if(btn.tag==2)
        {
            noteVC.str_content=tex_2.text;
        }
        else if(btn.tag==3)
        {
            noteVC.str_content=tex_3.text;
        }
        else if(btn.tag==4)
        {
            noteVC.str_content=tex_8.text;
        }
        else if(btn.tag==5)
        {
            noteVC.str_content=tex_4.text;
            noteVC.str_keybordType=@"0";
        }
        else if(btn.tag==6)
        {
            noteVC.str_content=tex_5.text;
        }
        else//动态
        {
            UITextField *tex=[arr_tex objectAtIndex:btn.tag];
            noteVC.str_content=tex.text;
            noteVC.str_keybordType=[dic objectForKey:@"data_type"];
        }
        [self.navigationController pushViewController:noteVC animated:YES];
    }
}
-(void)BigImage:(UIButton *)btn
{//required97
    if ([self Local]) {
        tempArray = [self.dic_data_all objectForKey:@"MediaList"];
        NSDictionary *dic=[tempArray objectAtIndex:btn.tag-buttonTag];
        imageData = [dic objectForKey:@"imageData"];
    }
    
    tempBtnTag = [NSString stringWithFormat:@"%d",btn.tag - 100];
    NSDictionary *dic=[arr_Media_image objectAtIndex:btn.tag-buttonTag];
    
    if (([[dic objectForKey:@"dicMpath"] rangeOfString:@"jpg"].location != NSNotFound) ||
        ([[dic objectForKey:@"dicMpath"] rangeOfString:@"png"].location != NSNotFound) ||
        ![Function StringIsNotEmpty:[dic objectForKey:@"dicMpath"]]) {
        if([[dic objectForKey:@"is_addimg"]isEqualToString:@"1"] || imageData.length)//说明已经照过图片了
        {
            UIImageView *imgView=[arr_ShowImage objectAtIndex:tempBtnTag.integerValue];
            [self view_image_AllScreen:imgView];
        }
        camera_index=btn.tag-buttonTag;
        if (!self.editFlag) {
            [self TakePhoto];
        }
    }else {
        DocumentViewController *docVC=[[DocumentViewController alloc]init];
        docVC.titleString=@"文件";
        docVC.mutiSelect = 1;
        docVC.str_Url=[dic objectForKey:@"dicMpath"];
        docVC.str_isGraph=@"1";
        [self.navigationController pushViewController:docVC animated:YES];
    }
}
-(void)Give_you_Photo:(UIImage*)image ImageData:(NSData*)data
{
    NSMutableDictionary *dic=[arr_Media_image objectAtIndex:camera_index];
    UIImageView *imageView=[[UIImageView alloc]init];
    imageView.image=image;
    [dic setObject:@"1" forKey:@"is_addimg"];
    [dic setObject:@"1" forKey:@"re_take"];
    [dic setObject:data forKey:@"imageData"];
    UIImageView *img_show=[arr_ShowImage objectAtIndex:tempBtnTag.integerValue];
    img_show.image=[UIImage imageWithData:data];
    isPhoto_OK=NO;
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
#pragma TakePhoto
-(void)TakePhoto
{
    if (!KAddressString.length) {
        [self locationInfo];
        self.addressFlag = 2;
    }
    
    NSString *textString = tex_7.text;
    if (![textString isEqualToString:@"地址未知"]) {
        if([Function isBlankString:app.str_LocationName]||[Function isBlankString:app.str_nlng]||[Function isBlankString:app.str_alat])
        {
            [SGInfoAlert showInfo:@" 请先去确认我的位置 "
                          bgColor:[[UIColor darkGrayColor] CGColor]
                           inView:self.view
                         vertical:0.5];
            return;
        }
    }
    if(isPad)
    {
        UIActionSheet *actionSheet =[[UIActionSheet alloc]initWithTitle:@"您想如何获取照片?" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"拍照",@"相册",@"取消", nil];
        [actionSheet showInView:self.view];
    }
    else
    {
        UIActionSheet *actionSheet =[[UIActionSheet alloc]initWithTitle:@"您想如何获取照片?" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"拍照",@"相册", nil];
        [actionSheet showInView:self.view];
    }
    
}
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
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
#pragma -mark UIImagePickerController delegate 
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    chosenImage = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.labelText = @"加载中...";//加载提示语言
    isPhoto_OK=YES;
    if(isCamera)
    {
        NSString *strAll;
        UILabel *lab_content;
        NSData *image_data=UIImageJPEGRepresentation( [chosenImage resize:CGSizeMake(Phone_Weight*2,Phone_Height*2)],0.6);
        UIImage *image_New=[UIImage imageWithData:image_data];
        
        strAll=[NSString stringWithFormat:@"采集人:%@     GPS:%@,%@\n地址:%@\n采集时间:%@\n文件生成时间:%@\n",[[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"uname"],app.str_nlng,app.str_alat,KAddressString,[Function getSystemTimeNow],[Function getSystemTimeNow]];
        lab_content=[Water_Mark Label_Freedom_Content:strAll  Choose_image:image_New];
        UIImage *getImage=[Water_Mark TransFor_ChooseImage:image_New  Lab:[Water_Mark imageWithUIView:lab_content]];
        [self Give_you_Photo:getImage  ImageData:UIImageJPEGRepresentation(getImage,0.6)];
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
                     NSDate *newDate = [self tDate:date];
                     NSArray *arr_date=[[NSString stringWithFormat:@"%@",newDate]   componentsSeparatedByString:@"+"];
                     NSString *strAll;
                     UILabel *lab_content;
                     NSData *image_data=UIImageJPEGRepresentation( [chosenImage resize:CGSizeMake(Phone_Weight*2  , Phone_Height*2)],0.6);
                     UIImage *image_New=[UIImage imageWithData:image_data];
                     strAll=[NSString stringWithFormat:@"采集人:%@     GPS:%@,%@\n地址:%@\n采集时间:%@ 文件生成时间:%@\n",[[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"uname"],app.str_nlng,app.str_alat,KAddressString,[Function getSystemTimeNow],[arr_date objectAtIndex:0]];
                     lab_content=[Water_Mark Label_Freedom_Content:strAll  Choose_image:image_New];
                     UIImage *getImage=[Water_Mark TransFor_ChooseImage:image_New  Lab:[Water_Mark imageWithUIView:lab_content]];
                     [self Give_you_Photo:getImage  ImageData:UIImageJPEGRepresentation(getImage,0.6)];
                     strAll=nil;
                     
                 } 
                failureBlock:^(NSError *error) {
                    isPhoto_OK=NO;
                }];
    }

    [MBProgressHUD hideHUDForView:self.view animated:YES];
    [SGInfoAlert showInfo:@" 照片添加成功! "
                  bgColor:[[UIColor darkGrayColor] CGColor]
                   inView:self.view
                 vertical:0.5];
    [picker dismissViewControllerAnimated:YES completion:NULL];
    picker=nil;
}
- (void)image: (UIImage *) image didFinishSavingWithError: (NSError *) error contextInfo: (void *) contextInfo
{
    
    if(error != NULL)
    {
        //Dlog(@"保存图片失败");
    }else{
       //Dlog(@"保存图片成功");
    }
}
-(void)WhenBack_mention//编辑状态中 返回提示
{

    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"您还没有提交数据,确认返回吗" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定",nil];
    [alert show];
    alert.tag=0;
    alert=nil;
}
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(alertView.tag==0)//返回
    {
        if(buttonIndex==1)
        {
            app.isOnlyGoBack=YES;
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
    else if(alertView.tag==1)//提交
    {
        if(buttonIndex==1)
        {
            if(!isPhoto_OK)
            [self AddNewClerk];
        }
    }
    else if(alertView.tag==2)//更新
    {
        if(buttonIndex==1)
        {
            if(!isPhoto_OK)
            [self AddNewClerk];
        }
    }
}
-(NSString*)Setting_URL_Get_dynamic:(NSString *)basic_url
{
    NSString *str;
    if([self.str_title isEqual:@"0"])
    {
        str=[NSString stringWithFormat:@"%@%@",basic_url,KNewCustomer_Dynamic0];
    }
    else
    {
        str=[NSString stringWithFormat:@"%@%@",basic_url,KNewCustomer_Dynamic1];
    }
    return str;
}
-(void)Get_dynamic//获取动态信息
{
    if([Function isConnectionAvailable])
    {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.mode = MBProgressHUDModeIndeterminate;
        hud.labelText = @"加载中...";//加载提示语言
        
        if(app.isPortal)
        {
            self.urlString=[self Setting_URL_Get_dynamic:KPORTAL_URL];
        }
        else
        {
            self.urlString=[self Setting_URL_Get_dynamic:kBASEURL];
        }
        NSURL *url = [ NSURL URLWithString :  self.urlString];
        ASIFormDataRequest *request = [ ASIFormDataRequest requestWithURL :url];
        request.delegate = self;
        request.tag = 100;
        [request setRequestMethod:@"POST"];
        [request setPostValue:[[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"account"]forKey:KUSER_UID];
        [request setPostValue:[[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"secret"] forKey:KUSER_PASSWORD];
        [request setPostValue:[[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"token"] forKey:@"user.token"];
        [request setPostValue:[[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"db_ip"] forKey:@"db_ip"];
        [request setPostValue:[[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"db_name"] forKey:@"db_name"];
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
-(void)GetJson_DynamicList:(NSString *)jsonString
{
    SBJsonParser *parser = [[SBJsonParser alloc] init];
    NSDictionary *dict =[parser objectWithString: jsonString];
    if([[dict objectForKey:@"ret"]isEqualToString:@"0"])
    {
        [self CreatView:[dict objectForKey:@"DynamicList"]
                  Media:[dict objectForKey:@"MediaList"]];
        dict=nil;
    }
    else
    {
        [SGInfoAlert showInfo:[dict objectForKey:@"message"]
                      bgColor:[[UIColor darkGrayColor] CGColor]
                       inView:self.view
                     vertical:0.5];
    }
}
-(NSString*)Setting_URL_AddNewClerk:(NSString *)basic_url
{
    NSString *string;
    if(self.isDetail)
    {
        if([self.str_title isEqual:@"0"])
        {
            string=[NSString stringWithFormat:@"%@%@",basic_url,KUpdate0 ];
        }
        else if([self.str_title isEqualToString:@"1"])
        {
            string=[NSString stringWithFormat:@"%@%@",basic_url, KUpdate1 ];
        }
        else if([self.str_title isEqualToString:@"2"])
        {
            string=[NSString stringWithFormat:@"%@%@",basic_url, KUpdate2 ];
        }
        if ([self local]) {
            if([self.str_title isEqual:@"0"])
            {
                string=[NSString stringWithFormat:@"%@%@",basic_url, KNewCustomer0];
            }
            else
            {
                string=[NSString stringWithFormat:@"%@%@",basic_url, KNewCustomer1];
            }
        }
    }
    else
    {
        if([self.str_title isEqual:@"0"])
        {
            string=[NSString stringWithFormat:@"%@%@",basic_url, KNewCustomer0];
        }
        else
        {
            string=[NSString stringWithFormat:@"%@%@",basic_url, KNewCustomer1];
        }
    }
    return string;
}
-(void)AddNewClerk
{
    if([Function isConnectionAvailable])
    {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.mode = MBProgressHUDModeIndeterminate;
        hud.labelText = @"加载中...";//加载提示语言
        
        if(app.isPortal)
        {
            self.urlString=[self Setting_URL_AddNewClerk:KPORTAL_URL];
        }
        else
        {
            self.urlString=[self Setting_URL_AddNewClerk:kBASEURL];
        } 

        NSURL *url = [NSURL URLWithString :  self.urlString];
        ASIFormDataRequest *request = [ ASIFormDataRequest requestWithURL :url];
        request.delegate = self;
        request.tag = 101;
        [request setRequestMethod:@"POST"];
        [request setPostValue:[[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"account"]forKey:KUSER_UID];
        [request setPostValue:[[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"secret"] forKey:KUSER_PASSWORD];
        [request setPostValue:[[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"token"] forKey:@"user.token"];
        [request setPostValue:[[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"db_ip"] forKey:@"db_ip"];
        [request setPostValue:[[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"db_name"] forKey:@"db_name"];
        
        //静态
        if(self.isDetail)
        {
            [request setPostValue:self.str_index_no forKey:@"index_no"];
        }
        [request setPostValue:tex_0.text forKey:@"gname"];
        [request setPostValue:str_value1 forKey:@"svtype"];//H12 svtype类型
        [request setPostValue:tex_2.text forKey:@"gcontact"];
        [request setPostValue:tex_3.text forKey:@"gtel"];
        [request setPostValue:tex_8.text forKey:@"gmail"];
        [request setPostValue:tex_4.text forKey:@"gvolume"];//规模
        [request setPostValue:str_value2 forKey:@"plevel"];//档次（H4数据）--[plevel
        [request setPostValue:str_value3 forKey:@"gcoopstate"];//状态H3
        [request setPostValue:app.str_LocationName forKey:@"gaddress"];
        [request setPostValue:app.str_nlng forKey:@"glng"];
        [request setPostValue:app.str_alat forKey:@"glat"];
        //动态
        NSInteger count_action=0;
        for (NSInteger i=9; i<array_Dynamic.count; i++)
        {
            NSDictionary *dic=[array_Dynamic objectAtIndex:i];
            UITextField *text=[arr_tex objectAtIndex:[[dic objectForKey:@"tag"] integerValue]];
            if(!self.isDetail)
            {
                [request setPostValue:[dic objectForKey:@"index_no"] forKey:[NSString stringWithFormat:@"dynamicList[%ld].index_no",(long)count_action]];
                [request setPostValue:text.text forKey:[NSString stringWithFormat:@"dynamicList[%ld].tcontent",(long)count_action]];
            }
            else
            {
                if(![[dic objectForKey:@"index_no"] isEqualToString:@"-2"])
                {
                    [request setPostValue:[dic objectForKey:@"index_no"] forKey:[NSString stringWithFormat:@"dynamicList[%ld].index_no",(long)count_action]];
                }
                [request setPostValue:[dic objectForKey:@"tindex_no"] forKey:[NSString stringWithFormat:@"dynamicList[%ld].tindex_no",(long)count_action]];
                [request setPostValue:text.text forKey:[NSString stringWithFormat:@"dynamicList[%ld].tcontent",(long)count_action]];
            }
            count_action++;
            
        }
        //媒体
        count_action=0;
        for (NSInteger i=0; i<arr_Media_image.count; i++)
        {
            NSDictionary *dic=[arr_Media_image objectAtIndex:i];//[dic_media setObject:@"0" forKey:@"re_take"];
            if([[dic objectForKey:@"is_addimg"] isEqualToString:@"1"])
            {//(新客户或新竞争对手)该张图片添加过则提交
                if(self.isDetail)
                {//如果没重新照相 就不提交
                    if(![[dic objectForKey:@"re_take"] isEqualToString:@"1"])
                        continue;
                }
                [request setData:[dic objectForKey:@"imageData"]
                    withFileName:[NSString stringWithFormat:@"T1.jpg"]
                  andContentType:@"image/jpeg"
                          forKey:[NSString stringWithFormat:@"fileList[%ld].file",(long)count_action]];
                [request setPostValue:[dic objectForKey:@"mtype"] forKey:[NSString stringWithFormat:@"fileList[%ld].mtype",(long)count_action]];
                count_action++;
            }
            dic=nil;
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
-(void)get_JsonString:(NSString *)jsonString
{
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    SBJsonParser *parser = [[SBJsonParser alloc] init];
    NSDictionary *dict =[parser objectWithString: jsonString];
    if([[dict objectForKey:@"ret"]isEqualToString:@"0"])
    {
        self.delegate = (id)app.VC_Register ;//vc
        //指定代理对象为，second
        if(self.isDetail)
        {
            if ([self Local]) {
                [self.delegate Notify_AddClerkOrRival:@" 提交成功 "];//这里获得代理方法的返回值。
            }else {
                [self.delegate Notify_AddClerkOrRival:@" 更新成功 "];//这里获得代理方法的返回值。
            }
        }
        else
        {
            [self.delegate Notify_AddClerkOrRival:@" 提交成功 "];
        }
        
        [self deleteLocalIndexData];
        [self.navigationController popViewControllerAnimated:YES];
    }
    else
    {
        [SGInfoAlert showInfo:[dict objectForKey:@"message"]
                      bgColor:[[UIColor darkGrayColor] CGColor]
                       inView:self.view
                     vertical:0.5];
    }
    dict=nil;
    parser=nil;
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
    {//
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
            NSString * jsonString  =  [request responseString];
            [self GetJson_DynamicList:jsonString];
        }
        else
        {
            [SGInfoAlert showInfo:@"发生异常,请稍后再试"
                          bgColor:[[UIColor darkGrayColor] CGColor]
                           inView:self.view
                         vertical:0.5];
            [NdUncaughtExceptionHandler Post_url:[NSString stringWithFormat:@"URL:%@,%d",self.urlString,[request responseStatusCode]]];
        }
    }
    if (request.tag == 101) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        if([request responseStatusCode]==200)
        {
            NSString * jsonString  =  [request responseString];
            [self get_JsonString:jsonString];
        }
        else
        {
            [SGInfoAlert showInfo:@"发生异常,请稍后再试"
                          bgColor:[[UIColor darkGrayColor] CGColor]
                           inView:self.view
                         vertical:0.5];
            [NdUncaughtExceptionHandler Post_url:[NSString stringWithFormat:@"URL:%@,%d",self.urlString,[request responseStatusCode]]];
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
    }
    if (request.tag == 101) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [SGInfoAlert showInfo:@"哎呀，服务器无响应，一会再试试吧"
                      bgColor:[[UIColor darkGrayColor] CGColor]
                       inView:self.view
                     vertical:0.5];
    }
}

- (BOOL) Local{
    if ([self.local isEqualToString:@"1"]) {
        return YES;
    }
    return NO;
}

//delete local data
- (void)deleteLocalIndexData {
    if([Function judgeFileExist:Customer_Local Kind:Library_Cache]) {
        NSMutableArray *customerLArray = [Function ReadFromFile:Customer_Local WithKind:Library_Cache];
        for (int i = 0; i < customerLArray.count; i ++) {
            NSString *tempIndexNumber1 = [[customerLArray objectAtIndex:i] objectForKey:@"tempIndexNumber"];
            if (tempIndexNumber1.length) {
                if ([tempIndexNumber1 isEqualToString:self.convertNumber]) {
                    [customerLArray removeObjectAtIndex:i];
                    NSString *str1= [Function achieveThe_filepath:Customer_Local Kind:Library_Cache];
                    [Function Delete_TotalFileFromPath:str1];
                    [Function creatTheFile:Customer_Local Kind:Library_Cache];
                    [Function WriteToFile:Customer_Local File:customerLArray Kind:Library_Cache];
                }
            }
        }
    }
}

- (void)MutableDic:(NSMutableDictionary *)mutableDic setObject:(NSString *)object forKey:(NSString *)key {
    if ([Function StringIsNotEmpty:object]) {
        [mutableDic setObject:object forKey:key];
    }
}

//transferDate
- (NSDate *)tDate:(NSDate *)date{
    NSTimeZone *zone = [NSTimeZone systemTimeZone];
    NSInteger interval = [zone secondsFromGMTForDate: date];
    NSDate *localeDate = [date  dateByAddingTimeInterval: interval];
    return localeDate;
}

#pragma mark ---- presentView delegate method

- (void)presentViewDissmissAction {
    
    [[KGModal sharedInstance] closeAction:nil];
    
}

@end

