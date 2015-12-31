//
//  StorageDetailViewController.m
//  WZYB_syb
//
//  Created by wzyb on 14-12-1.
//  Copyright (c) 2014年 WZYB. All rights reserved.
//

#import "StorageDetailViewController.h"
#import "UIImageView+WebCache.h"
#import "MRZoomScrollView.h"
#import "AppDelegate.h"
#import "PresentView.h"
#import "KGModal.h"
#import <AssetsLibrary/AssetsLibrary.h>
@interface StorageDetailViewController ()<UIActionSheetDelegate,UINavigationControllerDelegate, UIImagePickerControllerDelegate,PresentViewDelegate,BMKLocationServiceDelegate>
{
    NSInteger moment_status;
    NSInteger momentHeight;
    NSInteger combox_height_thisView;
    NSInteger near_by_thisView;
    AppDelegate *app;
    UIScrollView *scrollView_Back;
    NSMutableArray *arr_text;//承接所有的text数据
    NSInteger btn_tag;//累计tag
    UIView *view_imageView_back;//全屏大图片
    NSMutableArray *arr_imageView;//所有图片
    NSString *urlString;
    NSString *enableString;     //判断
    NSMutableArray *mutArray;
    NSDictionary *dataDic;
    NSMutableArray *imageMutArray;
    UIView *backgroundView;
    BOOL isCamera;
    NSInteger btnTag;
    NSMutableArray *imageDataArray;
    NSMutableArray *imageTypeArray;
    NSString *stockNum;
}

@property(strong,nonatomic)BMKLocationService* locService;//定位服务
@property(strong,nonatomic)CLLocationManager  *locationManager;
@property (nonatomic, retain) MRZoomScrollView  *zoomScrollView;
@end

@implementation StorageDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self All_init];
    [self creatView];
    [self locationInfo];
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

    if ([Function StringIsNotEmpty:app.str_nlng]) {
        CLGeocoder *geocoder = [[CLGeocoder alloc] init];
        [geocoder reverseGeocodeLocation: userLocation.location completionHandler:^(NSArray *array, NSError *error) {
            if(error==0&&array.count > 0) {
                CLPlacemark *placemark = [array objectAtIndex:0];
                app.str_LocationName = [NSString stringWithFormat:@"%@%@%@%@",placemark.administrativeArea,placemark.locality,placemark.subLocality,placemark.thoroughfare];
            }
        }];
        geocoder=nil;
    }
    
    [self.locService stopUserLocationService];
}

-(void)creatView
{
    scrollView_Back=[[UIScrollView alloc]init];
    scrollView_Back.frame=CGRectMake(0, moment_status+44,Phone_Weight, Phone_Height-moment_status-44);
    scrollView_Back.backgroundColor=[UIColor clearColor];
    [self.view addSubview:scrollView_Back];
    [self Get_StoreDetail];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    if ([Function StringIsNotEmpty:app.str_temporary]) {
        UITextField *tempTextF = (UITextField *)[mutArray objectAtIndex:0];
        tempTextF.text = [NSString stringWithFormat:@"%@%@",app.str_temporary,self.str_unit];
        stockNum = [NSString stringWithFormat:@"%@",app.str_temporary];
        app.str_temporary = @"";
    }
}
-(void)All_init
{
    app=(AppDelegate *)[[UIApplication sharedApplication]delegate];
    if(StatusBar_System>0)
        moment_status=20;
    else moment_status=0;
    NavView *nav_View=[[NavView alloc]init];
    [self.view addSubview: [nav_View NavView_Title1:@"产品库存明细"]];
    //左边返回键
    for (NSInteger i=0; i<1; i++)
    {
        UIButton *btn=[UIButton buttonWithType:UIButtonTypeCustom];
        btn.backgroundColor=[UIColor clearColor];
        [btn addTarget:self action:@selector(btn_Action:) forControlEvents:UIControlEventTouchUpInside];
        [nav_View.view_Nav  addSubview:btn];
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        btn.titleLabel.font=[UIFont systemFontOfSize:15];
        [btn setBackgroundImage:[UIImage imageNamed:@"btn_color6.png"] forState:UIControlStateHighlighted];
        if(i==0)
        {
            btn.frame=CGRectMake(0, moment_status, 60, 44);
            btn.tag=buttonTag-1;
            [btn setTitle:@"< 返回" forState:UIControlStateNormal];
        }
    }
    combox_height_thisView=combox_height;
    near_by_thisView=Near_By;
    //图片背景
    view_imageView_back=[[UIView alloc]init];
    view_imageView_back.frame=CGRectMake(0, 0, Phone_Weight, Phone_Height);
    arr_imageView=[NSMutableArray arrayWithCapacity:1];//大图片
    
    enableString = [NSString string];
    stockNum = [NSString string];
    mutArray = [NSMutableArray array];
    dataDic = [NSDictionary dictionary];
    imageMutArray = [NSMutableArray array];
    imageDataArray = [NSMutableArray array];
    imageTypeArray = [NSMutableArray array];
}
-(void)btn_Action:(id)sender
{
    UIButton *btn=(UIButton *)sender;
    if(btn.tag==buttonTag-1)//返回
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
    
    if (btn.tag == 206) {
        NoteViewController *noteVC=[[NoteViewController alloc]init];
        noteVC.str_title=@"库存数";
        noteVC.placeHolderString = stockNum;
        noteVC.str_content=stockNum;
        noteVC.isDetail=NO;
        [self.navigationController pushViewController:noteVC animated:YES];
    }
}
-(void)Get_StoreDetail
{
    if([Function isConnectionAvailable])
    {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.mode = MBProgressHUDModeIndeterminate;
        hud.labelText = @"加载中...";//加载提示语言
        
        urlString=[NSString stringWithFormat:@"%@%@",KPORTAL_URL,KStore_get_deatail];
        NSURL *url = [ NSURL URLWithString :  urlString];
        ASIFormDataRequest *request = [ ASIFormDataRequest requestWithURL :url];
        request.delegate = self;
        [request setRequestMethod:@"POST"];
        [request setPostValue:[[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"account"]forKey:KUSER_UID];
        [request setPostValue:[[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"secret"] forKey:KUSER_PASSWORD];
        [request setPostValue:[[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"token"] forKey:@"user.token"];
        [request setPostValue:[[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"db_ip"] forKey:@"db_ip"];
        [request setPostValue:[[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"db_name"] forKey:@"db_name"];
        
        [request setPostValue:self.str_index_no forKey:@"index_no"];
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
    dataDic =[parser objectWithString: jsonString];
    enableString = [[dataDic objectForKey:@"ProductInfo"] objectForKey:@"editable_flg"];
    if([[dataDic objectForKey:@"ret"] isEqualToString:@"0"])
    {
        [self createListView:dataDic];
    }
    else
    {
        [SGInfoAlert showInfo:[dataDic objectForKey:@"message"]
                      bgColor:[[UIColor darkGrayColor] CGColor]
                       inView:self.view
                     vertical:0.5];
    }
}
-(void)createListView :(NSDictionary *)dict
{
    NSArray *arr_basic=[NSArray arrayWithObjects:@"条码",@"品牌",@"品名",@"型号",@"最小包装量",@"单价",@"库存总量",@"产地",nil];
    NSArray *arr_ApplyInfo=[NSArray arrayWithObjects:@"pcode",@"ext1",@"pname",@"ptype",@"ext2",@"price",@"stock_cnt",@"poo",nil];
//----------静态数据
    momentHeight=0;
    btn_tag=0;
    //基本信息头start
    [self Row_Header:[UIColor colorWithRed:24/255.0 green:84/255.0 blue:156/255.0 alpha:1.0] Title:@"产品信息"  Pic:@"5" Background:@"icon_AddNewClerk_FirstTitle.png"];
    //基本信息头end
    NSDictionary *dic_ApplyInfo=[dict objectForKey:@"ProductInfo"];
    for(NSInteger i=0;i<arr_basic.count;i++)
    {
        UIButton *btn=[UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame=CGRectMake(near_by_thisView, momentHeight, (scrollView_Back.frame.size.width-near_by_thisView*2), combox_height_thisView);
        btn.backgroundColor=[UIColor clearColor];
        [scrollView_Back addSubview:btn];
        btn.tag=buttonTag*2+btn_tag++;
        
        //属性
        UILabel *lab1=[[UILabel alloc]initWithFrame:CGRectMake(0,0, btn.frame.size.width/2-combox_height_thisView*0.5,btn.frame.size.height)];
        lab1.backgroundColor=[UIColor clearColor];
        
        lab1.text=[NSString stringWithFormat:@"  %@",[arr_basic objectAtIndex:i ]];
        lab1.font=[UIFont systemFontOfSize:app.Font];
        [btn addSubview:lab1];
        if (btn.tag == 206) {
            btn.enabled=enableString.integerValue;
            
            UIImageView *imageView = [[UIImageView alloc] initWithImage:ImageName(@"icon_everyline_arrow")];
            imageView.frame = CGRectMake(288, 17, 6, 10);
            [btn addSubview:imageView];
        }else {
            btn.enabled = NO;
        }
        
        [btn addTarget:self action:@selector(btn_Action:) forControlEvents:UIControlEventTouchUpInside];
        if(i==0)
        {
            [btn setImage:[UIImage imageNamed:@"set_header@2X.png"] forState:UIControlStateNormal];
        }
        else if(i==arr_basic.count-1)
        {
            [btn setImage:[UIImage imageNamed:@"set_bottom@2X.png"] forState:UIControlStateNormal];
        }
        else
        {
            [btn setImage:[UIImage imageNamed:@"set_middle@2X.png"] forState:UIControlStateNormal];
        }
        UITextField *textF=[[UITextField alloc]init];
        [btn addSubview:textF];
        if(isIOS7)
        {
            textF.frame=CGRectMake(combox_height_thisView+44,0,btn.frame.size.width/2+44, btn.frame.size.height);
        }
        else
        {
            textF.frame=CGRectMake(combox_height_thisView+44,btn.frame.size.height/4,btn.frame.size.width/2+44, btn.frame.size.height);
        }
        textF.tag=btn.tag;
        textF.enabled=NO;
        textF.backgroundColor=[UIColor clearColor];
        textF.textAlignment=NSTextAlignmentRight;
        textF.font=[UIFont systemFontOfSize:app.Font];
        NSString *str_unit=[Function isBlankString:[dic_ApplyInfo objectForKey:[arr_ApplyInfo objectAtIndex:i]]]?@"":[dic_ApplyInfo objectForKey:[arr_ApplyInfo objectAtIndex:i]];
        if(i==5)
        {
            textF.text=[NSString stringWithFormat:@"%@元",str_unit];
        }
        else if (i==6)
        {
            textF.text=[NSString stringWithFormat:@"%@%@",str_unit,self.str_unit];
        }
        else
        {
            textF.text=str_unit;
        }
        
        if(i==6)textF.textColor=[UIColor colorWithRed:85.0/255 green:210/255.0 blue:85/255.0 alpha:1.0];
        else
        textF.textColor=[UIColor darkGrayColor];
        
        if (textF.tag == 206) {
            stockNum = [NSString stringWithFormat:@"%@",str_unit];
            [mutArray addObject:textF];
        }
        
        [btn addSubview:textF];
        momentHeight+=combox_height_thisView;
    }
    arr_ApplyInfo=nil;
    arr_basic=nil;
//----------动态数据
    NSArray *arr_DynamicList=[dict objectForKey:@"DynamicList"];
    if(arr_DynamicList.count!=0)
    {
        [self Row_Header:[UIColor colorWithRed:223/255.0 green:52/255.0 blue:46/255.0 alpha:1.0] Title:@"专属信息"  Pic:@"3" Background:@"icon_AddNewClerk_NextTitle.png"];
    }
    for (NSInteger i=0; i<arr_DynamicList.count; i++)
    {
        NSDictionary *dic=[arr_DynamicList objectAtIndex:i];
        UIButton *btn=[UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame=CGRectMake(near_by_thisView, momentHeight, (scrollView_Back.frame.size.width-near_by_thisView*2), combox_height_thisView);
        btn.backgroundColor=[UIColor clearColor];
        [scrollView_Back addSubview:btn];
        btn.tag=buttonTag*2+btn_tag++;
        
        //属性
        UILabel *lab1=[[UILabel alloc]initWithFrame:CGRectMake(0,0, btn.frame.size.width/2-combox_height_thisView,btn.frame.size.height)];
        lab1.backgroundColor=[UIColor clearColor];
        
        lab1.text=[NSString stringWithFormat:@"  %@",[dic objectForKey:@"tname"]];
        lab1.font=[UIFont systemFontOfSize:app.Font];
        [btn addSubview:lab1];
        //文本
        UITextField *textF=[[UITextField alloc]init];
        [btn addSubview:textF];
        
        if(isIOS7)
        {
            textF.frame=CGRectMake(combox_height_thisView+44,0,btn.frame.size.width/2+44, btn.frame.size.height);
        }
        else
        {
            textF.frame=CGRectMake(combox_height_thisView+44,btn.frame.size.height/4,btn.frame.size.width/2+44, btn.frame.size.height);
        }

        //data_type动态项目类型（0:数字，1:文本，2:金额，3:日期，4:列表）
        textF.tag=btn.tag;
        textF.enabled=NO;
        textF.backgroundColor=[UIColor clearColor];
        textF.textAlignment=NSTextAlignmentRight;
        textF.font=[UIFont systemFontOfSize:app.Font];
        textF.text=[Function isBlankString:[dic objectForKey:@"tcontent"]]?@"":[dic objectForKey:@"tcontent"];
        textF.textColor=[UIColor darkGrayColor];
        [btn addSubview:textF];
        [btn addTarget:self action:@selector(btn_Action:) forControlEvents:UIControlEventTouchUpInside];
        btn.enabled=NO;
        NSMutableDictionary *dic1=[[NSMutableDictionary alloc]init];
        [dic1 setObject:textF.text forKey:@"text"];
        [dic1 setObject:lab1.text forKey:@"title"];
        [dic1 setObject:[dic objectForKey:@"data_type"] forKey:@"data_type"];
        [arr_text addObject:dic1];
        dic1=nil;
        if(arr_DynamicList.count==1)
        {
            [btn setImage:[UIImage imageNamed:@"set_single@2X.png"] forState:UIControlStateNormal];
        }
        else
        {
            if(i==0)
            {
                [btn setImage:[UIImage imageNamed:@"set_header@2X.png"] forState:UIControlStateNormal];
            }
            else if(i==arr_DynamicList.count-1)
            {
                [btn setImage:[UIImage imageNamed:@"set_bottom@2X.png"] forState:UIControlStateNormal];
            }
            else
            {
                [btn setImage:[UIImage imageNamed:@"set_middle@2X.png"] forState:UIControlStateNormal];
            }
        }
        momentHeight+=combox_height_thisView;
        dic=nil;
    }
    arr_DynamicList=nil;
//----------------媒体图片
    //----------------媒体图片
    NSArray *arr_MediaList =[dict objectForKey:@"MediaList"];
    if(arr_MediaList.count!=0)
    {
        //媒体信息start
        [self Row_Header:[UIColor colorWithRed:25/255.0 green:35/255.0 blue:49/255.0 alpha:1.0] Title:@"媒体信息" Pic:@"4" Background:@"icon_AddNewClerk_NextTitle.png"];
        //媒体信息end
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
        NSDictionary *_dic=[arr_MediaList objectAtIndex:i];
        //图片按钮
        UIImageView *view_btn=[[UIImageView alloc]init];
        view_btn.frame=CGRectMake(imgView_back.frame.size.width- imgView_back.frame.size.height ,10,imgView_back.frame.size.height-20,imgView_back.frame.size.height-20);
        view_btn.backgroundColor=[UIColor clearColor];
        [imgView_back addSubview:view_btn];
        view_btn.userInteractionEnabled=YES;
        [view_btn setImageWithURL:[_dic objectForKey:@"mpath_small"]
                 placeholderImage:[UIImage imageNamed:@"default_picture.png"]
                          success:^(UIImage *image) {
                          }
                          failure:^(NSError *error) {
                          }];
        
        if ([Function StringIsNotEmpty:[_dic objectForKey:@"mtype"]]) {
            [imageTypeArray addObject:[_dic objectForKey:@"mtype"]];
        }else {
            [imageTypeArray addObject:@""];
        }
        
        if ([Function StringIsNotEmpty:[_dic objectForKey:@"mpath"]]) {
            NSURL *url = [NSURL URLWithString:[_dic objectForKey:@"mpath"]];
            NSData *soundData = [NSData dataWithContentsOfURL:url];
            [imageDataArray addObject:soundData];
        }else {
            [imageDataArray addObject:@""];
        }
        
        [imageMutArray addObject:view_btn];
        
        UIButton *btn=[UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame=CGRectMake(0, 0, view_btn.frame.size.width, view_btn.frame.size.height);
        btn.backgroundColor=[UIColor clearColor];
        btn.tag=buttonTag/2+i;
        [btn addTarget:self action:@selector(BigImageAction:) forControlEvents:UIControlEventTouchUpInside];
        [view_btn addSubview:btn];
        if([Function isBlankString:[_dic objectForKey:@"mpath"]])
        {
            [arr_imageView addObject:@""];
        }
        else
        [arr_imageView addObject:[_dic objectForKey:@"mpath"]];
        
        //图片描述
        UILabel *lab_describ=[[UILabel alloc]initWithFrame:CGRectMake(0, 0, imgView_back.frame.size.width-view_btn.frame.size.width, imgView_back.frame.size.height)];
        lab_describ.backgroundColor=[UIColor clearColor];
        lab_describ.textAlignment=NSTextAlignmentCenter;
        lab_describ.text=[Function isBlankString:[_dic objectForKey:@"clabel"]]?@"":[_dic objectForKey:@"clabel"];
        lab_describ.font=[UIFont systemFontOfSize:app.Font];
        [imgView_back addSubview:lab_describ];
        momentHeight+=imgView_back.frame.size.height;
        lab_describ.textColor=[UIColor darkGrayColor];
        _dic=nil;
    }
    momentHeight+=20;
    arr_MediaList=nil;
    dict=nil;
    scrollView_Back.contentSize=CGSizeMake(0, momentHeight);
    
    if (enableString.integerValue) {
        UIButton *btn2 = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn2.layer setMasksToBounds:YES];
        [btn2.layer setCornerRadius:5.0];//设置矩形四个圆角半径
        btn2.frame=CGRectMake((Phone_Weight-300)/2, momentHeight+20, 300, 44);
        [btn2 setTitle:@"更新" forState:UIControlStateNormal];
        btn2.tag=buttonTag+3;
        btn2.titleLabel.textColor=[UIColor whiteColor];
        btn2.titleLabel.font=[UIFont systemFontOfSize:15];
        btn2.backgroundColor=[UIColor clearColor];
        [btn2 setBackgroundImage:[UIImage imageNamed:@"btn_color6.png"] forState:UIControlStateNormal];
        [btn2 addTarget:self action:@selector(updateAction) forControlEvents:UIControlEventTouchUpInside];
        [scrollView_Back  addSubview:btn2];
    }
    
    momentHeight+=100;
    scrollView_Back.contentSize=CGSizeMake(0, momentHeight);
}

- (void)updateAction {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:@"是否更新" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    [alertView show];
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
-(void)BigImageAction:(UIButton *)btn
{
    btnTag = btn.tag;
    UIImageView *imgView=[[UIImageView alloc]init];
    __weak UIImageView *weakImageView = imgView;
    
    NSData *tempData = [imageDataArray objectAtIndex:btnTag-50];
    if (tempData.length) {
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageWithData:tempData]];
        [self view_image_AllScreen:imageView];
    }else {
        [imgView setImageWithURL:[arr_imageView objectAtIndex:btn.tag-buttonTag/2]
                placeholderImage:[UIImage imageNamed:@"default_picture.png"]
                         success:^(UIImage *image) {//Dlog(@" 图片显示成功OK");
                             weakImageView.image=image;
                             [self view_image_AllScreen:weakImageView];
                         }
                         failure:^(NSError *error) {//Dlog(@" 顶图片显示失败NO");
                         }];
    }
    
    if (enableString.integerValue) {
        [self TakePhoto];
    }
}

- (void)TakePhoto {
    UIActionSheet *actionSheet =[[UIActionSheet alloc]initWithTitle:@"您想如何获取照片?"
                                                           delegate:self
                                                  cancelButtonTitle:@"取消"
                                             destructiveButtonTitle:nil
                                                  otherButtonTitles:@"拍照",@"相册", nil];
    [actionSheet showInView:self.view];
}

#pragma mark ---- UIAlertView delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        if([Function isConnectionAvailable])
        {
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            hud.mode = MBProgressHUDModeIndeterminate;
            hud.labelText = @"加载中...";//加载提示语言
            
            if(app.isPortal)
            {
                urlString=[NSString stringWithFormat:@"%@%@",KPORTAL_URL,UpdateProduct];;
            }
            else
            {
                urlString=[NSString stringWithFormat:@"%@%@",kBASEURL,UpdateProduct];
            }
            
            NSURL *url = [NSURL URLWithString:urlString];
            ASIFormDataRequest *request = [ ASIFormDataRequest requestWithURL :url];
            request.tag = 20;
            request.delegate = self;
            [request setRequestMethod:@"POST"];
            [request setPostValue:[[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"account"]forKey:KUSER_UID];
            [request setPostValue:[[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"secret"] forKey:KUSER_PASSWORD];
            [request setPostValue:[[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"token"] forKey:@"user.token"];
            [request setPostValue:[[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"db_ip"] forKey:@"db_ip"];
            [request setPostValue:[[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"db_name"] forKey:@"db_name"];
            
            [request setPostValue:self.str_index_no forKey:@"index_no"];
            [request setPostValue:stockNum forKey:@"stock_cnt"];
            
            for (NSInteger i=0; i<imageDataArray.count; i++)
            {
                NSData *tempData = [imageDataArray objectAtIndex:i];
                if (tempData.length) {
                    [request setData:tempData
                        withFileName:[NSString stringWithFormat:@"T1.jpg"]
                      andContentType:@"image/jpeg"
                              forKey:[NSString stringWithFormat:@"fileList[%ld].file",(long)i]];
                    [request setPostValue:[imageTypeArray objectAtIndex:i] forKey:[NSString stringWithFormat:@"fileList[%ld].mtype",(long)i]];
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
}

#pragma mark ---- UIActionSheet delegate
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (backgroundView.superview) {
        [UIView animateWithDuration:0.3 animations:^{
            backgroundView.alpha=0;
        } completion:^(BOOL finished) {
            [backgroundView removeFromSuperview];
        }];
    }
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    
    if(buttonIndex==2)
        return;
    if(buttonIndex==0)
    {//拍照
        [self cancel_AllScreen];
        BOOL cameraFlag = [Function CanOpenCamera];
        
        if (!cameraFlag) {
            PresentView *presentView = [PresentView getSingle];
            presentView.presentViewDelegate = self;
            presentView.frame = CGRectMake(0, 0, 240, 250);
            [[KGModal sharedInstance] showWithContentView:presentView andAnimated:YES];
            return;
        }
        
        isCamera = YES;
        picker.sourceType=UIImagePickerControllerSourceTypeCamera;
        [self presentViewController:picker animated:YES completion:NULL];
    }
    else if(buttonIndex==1)
    {//图库
        [self cancel_AllScreen];
        isCamera = NO;
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        [self presentViewController:picker animated:YES completion:NULL];
    }
}

#pragma mark ---- UIImagePickerController delegate method
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage * chosenImage = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
    
    if(isCamera)
    {
        NSString *strAll;
        UILabel *lab_content;
        NSData *image_data=UIImageJPEGRepresentation( [chosenImage resize:CGSizeMake(Phone_Weight*2,Phone_Height*2)],0.6);
        UIImage *image_New=[UIImage imageWithData:image_data];
        
        strAll=[NSString stringWithFormat:@"采集人:%@     GPS:%@,%@\n地址:%@\n采集时间:%@\n文件生成时间:%@\n",[[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"uname"],app.str_nlng,app.str_alat,app.str_LocationName,[Function getSystemTimeNow],[Function getSystemTimeNow]];
        lab_content=[Water_Mark Label_Freedom_Content:strAll  Choose_image:image_New];
        UIImage *getImage=[Water_Mark TransFor_ChooseImage:image_New  Lab:[Water_Mark imageWithUIView:lab_content]];
        [imageDataArray replaceObjectAtIndex:btnTag-50 withObject:UIImageJPEGRepresentation(getImage, 1)];
        UIImageView *tempImageView = [imageMutArray objectAtIndex:btnTag-50];
        tempImageView.image = getImage;
        strAll=nil;
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
                     strAll=[NSString stringWithFormat:@"采集人:%@     GPS:%@,%@\n地址:%@\n采集时间:%@ 文件生成时间:%@\n",[[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"uname"],app.str_nlng,app.str_alat,app.str_LocationName,[Function getSystemTimeNow],[arr_date objectAtIndex:0]];
                     lab_content=[Water_Mark Label_Freedom_Content:strAll  Choose_image:image_New];
                     UIImage *getImage=[Water_Mark TransFor_ChooseImage:image_New  Lab:[Water_Mark imageWithUIView:lab_content]];
                     [imageDataArray replaceObjectAtIndex:btnTag-50 withObject:UIImageJPEGRepresentation(getImage, 1)];
                     UIImageView *tempImageView = [imageMutArray objectAtIndex:btnTag-50];
                     tempImageView.image = getImage;
                     strAll=nil;
                     
                 }
                failureBlock:^(NSError *error) {
                }];
    }
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

//transferDate
- (NSDate *)tDate:(NSDate *)date{
    NSTimeZone *zone = [NSTimeZone systemTimeZone];
    NSInteger interval = [zone secondsFromGMTForDate: date];
    NSDate *localeDate = [date  dateByAddingTimeInterval: interval];
    return localeDate;
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)requestFinished:(ASIHTTPRequest *)request {
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    
    if([request responseStatusCode]==200)
    {
        if (request.tag == 20) {
            [SGInfoAlert showInfo:@"更新成功"
                          bgColor:[[UIColor darkGrayColor] CGColor]
                           inView:self.view
                         vertical:0.5];
            return;
        }
        NSString * jsonString  =  [request responseString];
        [self get_JsonString:jsonString];
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
