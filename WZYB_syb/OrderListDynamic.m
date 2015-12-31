//
//  OrderListDynamic.m
//  WZYB_syb
//
//  Created by wzyb on 14-9-26.
//  Copyright (c) 2014年 WZYB. All rights reserved.
//

#import "OrderListDynamic.h"
#import "AppDelegate.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "UIImageView+WebCache.h"
#import "KGModal.h"
#import <QuartzCore/QuartzCore.h>
#import "PresentView.h"
#import "QuickViewController.h"
@interface OrderListDynamic () <MyDelegate_OrderListView,
    ASIHTTPRequestDelegate, PresentViewDelegate> {
    AppDelegate* app;
    NSString* urlString;
    BOOL brinkFlag;
    NSData* imagedata;
    NSString* tempIndexNumber;
}
@property (assign, nonatomic) id<MyDelegate_OrderListView> delegate;
@end

@implementation OrderListDynamic

- (id)initWithNibName:(NSString*)nibNameOrNil
               bundle:(NSBundle*)nibBundleOrNil
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
    [self Set_SegmentView];
    [self CreatDynamicView];
    if (!self.isDetail) {
        if (isIOS8) {
            //由于IOS8中定位的授权机制改变 需要进行手动授权
            locationManager = [[CLLocationManager alloc] init];
            //获取授权认证
            [locationManager requestAlwaysAuthorization];
            [locationManager requestWhenInUseAuthorization];
        }

        locService = nil;
        locService = [[BMKLocationService alloc] init];
        [locService startUserLocationService];
        locService.delegate = self;
    }
}
- (void)viewWillAppear:(BOOL)animated
{
    if (self.isDetail && ![self.mtypeStr isEqualToString:@"1"]) {
    }
    else {
        if (num_editer == -1 || [app.str_temporary isEqualToString:@""])
            return;
        UITextField* tex = [arr_tex objectAtIndex:num_editer];
        tex.text = app.str_temporary;
    }
}
- (void)setStop
{
    if (!self.isDetail) {
        [locService stopUserLocationService];
        locService.delegate = nil;
        geocodesearch.delegate = nil; // 不用时，置nil
    }
}
- (void)CreatDynamicView
{
    arr_tex = [NSMutableArray arrayWithCapacity:1];
    array_Dynamic = [NSMutableArray arrayWithCapacity:1];
    arr_Media_image = [NSMutableArray arrayWithCapacity:1];
    arr_ShowImage = [NSMutableArray arrayWithCapacity:1];
    scroll = [[UIScrollView alloc] init];

    scroll.frame = CGRectMake(0, 44 + moment_status, Phone_Weight,
        Phone_Height - 44 - moment_status);
    scroll.backgroundColor = [UIColor clearColor];
    [self.view addSubview:scroll];
    [self Row_ScrollView:scroll
                  Header:[UIColor colorWithRed:43.0 / 255.0
                                         green:132 / 255.0
                                          blue:210 / 255.0
                                         alpha:1.0]
                   Title:@"附加信息"
                     Pic:@"10"
              Background:@"icon_AddNewClerk_FirstTitle.png"];
    momentHeight = 53;

    NSArray* arr_Dynamic = [NSArray array];
    if (self.localFlag) {
        arr_Dynamic = [self.dic_json objectForKey:@"array_Dynamic"];
    }
    else {
        arr_Dynamic = [self.dic_json objectForKey:@"DynamicList"];
    }
    for (NSInteger i = 0; i < arr_Dynamic.count; i++) {
        NSDictionary* dic = [arr_Dynamic objectAtIndex:i];
        NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];

        UIButton* btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake((Phone_Weight - 300) / 2, momentHeight, 300, 44);
        btn.tag = btn_tag++;
        [dict setObject:[NSString stringWithFormat:@"%ld", (long)btn.tag]
                 forKey:@"btn.tag"];
        btn.backgroundColor = [UIColor clearColor];
        if (arr_Dynamic.count == 1) {
            [btn setBackgroundImage:[UIImage imageNamed:@"set_single@2X.png"]
                           forState:UIControlStateNormal];
        }
        else {
            if (i == 0) {
                [btn setBackgroundImage:[UIImage imageNamed:@"set_header@2X.png"]
                               forState:UIControlStateNormal];
            }
            else if (i == arr_Dynamic.count - 1) {
                [btn setBackgroundImage:[UIImage imageNamed:@"set_bottom@2X.png"]
                               forState:UIControlStateNormal];
            }
            else {
                [btn setBackgroundImage:[UIImage imageNamed:@"set_middle@2X.png"]
                               forState:UIControlStateNormal];
            }
        }

        UIImageView* imgView_arrow = [[UIImageView alloc] init];
        imgView_arrow.backgroundColor = [UIColor clearColor];
        imgView_arrow.image = [UIImage imageNamed:@"icon_everyline_arrow.png"];
        imgView_arrow.frame = CGRectMake(270, (44 - 10) / 2.0, 6, 10);
        [btn addSubview:imgView_arrow];
        [btn addTarget:self
                      action:@selector(Action_textField:)
            forControlEvents:UIControlEventTouchUpInside];
        [scroll addSubview:btn];

        //属性
        UILabel* lab1 = [[UILabel alloc] init];
        lab1.frame = CGRectMake(10, 0, 140, 44);
        lab1.backgroundColor = [UIColor clearColor];
        lab1.text = [dic objectForKey:@"tname"];
        lab1.font = [UIFont systemFontOfSize:15.0];
        [btn addSubview:lab1];
        //文本框
        UITextField* tex1 = [[UITextField alloc] init];
        if (isIOS7) {
            tex1.frame = CGRectMake(150, (44 - 30) / 2.0, 107, 30);
        }
        else {
            tex1.frame = CGRectMake(150, (44 - 30) / 2.0 - toolBar_Height / 2, 107, 30);
        }
        tex1.textAlignment = NSTextAlignmentRight;
        tex1.backgroundColor = [UIColor clearColor];
        [dict setObject:[dic objectForKey:@"tname"] forKey:@"tname"];
        if ([[dic objectForKey:@"trequired"] isEqualToString:@"1"]) {
            [dict setObject:@"1" forKey:@"trequired"]; // 1必填
            tex1.placeholder = @"必填";
        }
        else {
            [dict setObject:@"-1" forKey:@"trequired"];
            tex1.placeholder = @"选填";
        }
        [dict setObject:[dic objectForKey:@"data_type"] forKey:@"data_type"];
        [dict setObject:[dic objectForKey:@"tdefault"] forKey:@"tdefault"];
        [dict setObject:[NSString stringWithFormat:@"%ld", (long)btn.tag]
                 forKey:@"tag"];
        if ([Function isBlankString:
                          [dic objectForKey:
                                   @"index_no"]]) { //在手机这边做插入就没有index_no
            //这个属性 是没有的 默认动态 是-2
            [dict setObject:@"" forKey:@"index_no"];
        }
        else {
            [dict setObject:[dic objectForKey:@"index_no"] forKey:@"index_no"];
        }
        if (!self.localFlag) {
            if (self.isDetail || [self.mtypeStr isEqualToString:@"1"]) {
                [dict setObject:[dic objectForKey:@"tindex_no"] forKey:@"tindex_no"];
            }
        }
        [array_Dynamic addObject:dict];
        dict = nil;

        tex1.font = [UIFont systemFontOfSize:15.0];
        tex1.enabled = NO;
        tex1.tag = btn.tag;
        [btn addSubview:tex1];
        if (self.isDetail) {
            tex1.text = [dic objectForKey:@"tcontent"];
        }
        if (self.localFlag) {
            NSString* keyStr = [NSString stringWithFormat:@"%ld", (long)i];
            tex1.text = [[self.dic_json objectForKey:@"mutDic"] objectForKey:keyStr];
        }
        [arr_tex addObject:tex1];
        momentHeight += 44;
    }
    //------media
    NSArray* arr_MediaList = [NSArray array];
    if (self.localFlag) {
        arr_MediaList = [self.dic_json objectForKey:@"arr_Media_image"];
    }
    else {
        arr_MediaList = [self.dic_json objectForKey:@"MediaList"];
    }
    if (arr_MediaList.count > 0) {
        [self Row_ScrollView:scroll
                      Header:[UIColor colorWithRed:25 / 255.0
                                             green:35 / 255.0
                                              blue:49 / 255.0
                                             alpha:1.0]
                       Title:@"附加媒体"
                         Pic:@"4"
                  Background:@"icon_AddNewClerk_FirstTitle.png"];
    }
    momentHeight += 53;
    for (NSInteger i = 0; i < arr_MediaList.count; i++) {
        UIImageView* view_btn = [[UIImageView alloc] init]; //整个下方背景
        view_btn.frame = CGRectMake(10, momentHeight, (Phone_Weight - 10 * 2), 44 * 2);
        view_btn.backgroundColor = [UIColor clearColor];
        [scroll addSubview:view_btn];
        view_btn.userInteractionEnabled = YES;

        if (arr_MediaList.count == 1) {
            view_btn.image = [UIImage imageNamed:@"set_single@2X.png"]; //椭圆框
        }
        else {
            if (i == 0) {
                view_btn.image = [UIImage imageNamed:@"set_header@2X.png"]; //上
            }
            else if (i == arr_MediaList.count - 1) {
                view_btn.image = [UIImage imageNamed:@"set_bottom@2X.png"]; //中
            }
            else {
                view_btn.image = [UIImage imageNamed:@"set_middle@2X.png"]; //下
            }
        }
        NSDictionary* dic = [arr_MediaList objectAtIndex:i];

        //右侧点击button
        UIImageView* imageView_Back = [[UIImageView alloc]
            initWithFrame:CGRectMake(view_btn.frame.size.width - view_btn.frame.size.height,
                              10, view_btn.frame.size.height - 20,
                              view_btn.frame.size.height - 20)];
        imageView_Back.backgroundColor = [UIColor clearColor];

        if (self.isDetail || self.localFlag) {
            NSData* imageData1 = [dic objectForKey:@"imageData"];
            if (imageData1.length) {
                UIImage* image = [UIImage imageWithData:imageData1];
                imageView_Back.image = image;
            }
            else {
                imageView_Back.image = [UIImage imageNamed:@"default_picture.png"];
            }
            if (!self.localFlag) {
                [imageView_Back setImageWithURL:[dic objectForKey:@"mpath_small"]
                    placeholderImage:[UIImage imageNamed:@"default_picture.png"]
                    success:^(UIImage* image) {
                        brinkFlag = YES;
                    }
                    failure:^(NSError* error){
                        // Dlog(@"图片显示失败NO");
                    }];
            }
        }
        else {
            imageView_Back.image = [UIImage imageNamed:@" "];
        }

        if (brinkFlag == NO && !self.localFlag) {
            imageView_Back.image = ImageName(@"icon_take_picture.png");
        }

        imageView_Back.userInteractionEnabled = YES;
        [arr_ShowImage addObject:imageView_Back];
        [view_btn addSubview:imageView_Back];

        UILabel* lab_describ = [[UILabel alloc]
            initWithFrame:CGRectMake(0, 0, view_btn.frame.size.width - imageView_Back.frame.size.width,
                              view_btn.frame.size.height)];
        lab_describ.backgroundColor = [UIColor clearColor];
        lab_describ.textAlignment = NSTextAlignmentCenter;
        lab_describ.font = [UIFont systemFontOfSize:app.Font];
        [view_btn addSubview:lab_describ];

        if ([[dic objectForKey:@"required97"] isEqualToString:@"1"]) {
            lab_describ.text =
                [NSString stringWithFormat:@"%@(必填)", [dic objectForKey:@"clabel"]];
        }
        else {
            lab_describ.text =
                [NSString stringWithFormat:@"%@(选填)", [dic objectForKey:@"clabel"]];
        }

        //拍照 或查看照片按钮
        UIButton* btn_image = [UIButton buttonWithType:UIButtonTypeCustom];
        btn_image.frame = CGRectMake(0, 0, 77, 74);
        [btn_image addTarget:self
                      action:@selector(BigImage:)
            forControlEvents:UIControlEventTouchUpInside];
        btn_image.backgroundColor = [UIColor clearColor];
        btn_image.tag = buttonTag + i;
        [imageView_Back addSubview:btn_image];

        // required97
        NSMutableDictionary* dic_media = [[NSMutableDictionary alloc] init];
        if (self.localFlag) {
            [dic_media setObject:[dic objectForKey:@"required"] forKey:@"required"];
        }
        else {
            [dic_media setObject:[dic objectForKey:@"required97"] forKey:@"required"];
        }

        UIImageView* imageView = [[UIImageView alloc] init];
        if (self.isDetail || self.localFlag) {
            [dic_media setObject:[dic objectForKey:@"clabel"] forKey:@"clabel"];
            [dic_media setObject:[dic objectForKey:@"mtype"] forKey:@"mtype"];
            [dic_media setObject:@"0"
                          forKey:@"isme"]; //是否我正在拍照 1是在拍 其他不是

            NSData* imageData1 = [dic objectForKey:@"imageData"];
            if (imageData1.length) {
                [dic_media setObject:imageData1 forKey:@"imageData"];
                UIImage* image = [UIImage imageWithData:imageData1];
                imageView.image = image;
            }
            else {
                imageView.image = [UIImage imageNamed:@"default_picture.png"];
            }
            if (!self.localFlag) {
                [imageView
                     setImageWithURL:[NSURL URLWithString:[dic objectForKey:@"mpath"]]
                    placeholderImage:[UIImage imageNamed:@"default_picture.png"]];
            }

            [dic_media setObject:imageView forKey:@"imgView"];
            if ([Function isBlankString:[dic objectForKey:@"mpath"]]) {
                [dic_media setObject:@"0" forKey:@"is_addimg"]; //无图
                [dic_media setObject:@"" forKey:@"dicMpath"];
            }
            else {
                [dic_media setObject:@"1" forKey:@"is_addimg"]; //已有图片计为1
                [dic_media setObject:[dic objectForKey:@"mpath"] forKey:@"dicMpath"];
            }
            [dic_media setObject:@"0" forKey:@"re_take"]; //是否重照 默认 0 否 1是
            [arr_Media_image addObject:dic_media];
        }
        else {
            [dic_media setObject:[dic objectForKey:@"clabel"] forKey:@"clabel"];
            [dic_media setObject:imageView forKey:@"imgView"]; //图片初始化
            if ([self.mtypeStr isEqualToString:@"1"] || self.localFlag) {
                [dic_media setObject:[dic objectForKey:@"mtype"] forKey:@"mtype"];
            }
            else {
                [dic_media setObject:[dic objectForKey:@"h7type"] forKey:@"mtype"];
            }
            [dic_media setObject:@"0" forKey:@"is_addimg"]; //暂无图片 初始化为0
            [dic_media setObject:@"0"
                          forKey:@"isme"]; //是否我正在拍照 1是在拍 其他不是
            [arr_Media_image addObject:dic_media];
        }
        imageView = nil;
        dic_media = nil;
        dic = nil;
        imageView_Back = nil;
        momentHeight += 88;
    }
    momentHeight += 44;
    if (!self.fromSign) {
        momentHeight -= 15;
        UIButton* btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn.layer setMasksToBounds:YES];
        [btn.layer setCornerRadius:5.0]; //设置矩形四个圆角半径
        btn.frame = CGRectMake((Phone_Weight - 300) / 2, momentHeight, 140, 44);
        if (![self.titleString isEqualToString:@"巡检附加信息"]) {
            btn.width = 300;
        }
        btn.backgroundColor = [UIColor clearColor];
        [btn setBackgroundImage:[UIImage imageNamed:@"btn_color6.png"]
                       forState:UIControlStateNormal];
        [btn setBackgroundImage:[UIImage imageNamed:@"btn_color1.png"]
                       forState:UIControlStateHighlighted];
        [btn addTarget:self
                      action:@selector(btn_Action:)
            forControlEvents:UIControlEventTouchUpInside];
        [scroll addSubview:btn];
        btn.titleLabel.textColor = [UIColor whiteColor];
        btn.titleLabel.font = [UIFont systemFontOfSize:15];
        if (self.isDetail)
            btn.hidden = YES;
        if ([self.mtypeStr isEqualToString:@"1"] || self.localFlag) {
            btn.hidden = NO;
        }
        //提交
        if ([app returnYES]) {
            if ([self.titleString isEqualToString:@"巡检附加信息"]) {
                [btn setTitle:@"提交" forState:UIControlStateNormal];
            }
            else {
                [btn setTitle:@"离线保存" forState:UIControlStateNormal];
            }
        }
        else {
            if ([Function isConnectionAvailable]) {
                [btn setTitle:@"提交" forState:UIControlStateNormal];
            }
            else {
                [btn setTitle:@"离线保存" forState:UIControlStateNormal];
            }
        }
        btn.tag = buttonTag + 1;

        if (self.localFlag) {
            UIButton* btn = [UIButton buttonWithType:UIButtonTypeCustom];
            [btn.layer setMasksToBounds:YES];
            [btn.layer setCornerRadius:5.0]; //设置矩形四个圆角半径
            btn.frame = CGRectMake((Phone_Weight - 300) / 2, momentHeight + 60, 300, 44);
            btn.backgroundColor = [UIColor clearColor];
            [btn setBackgroundImage:[UIImage imageNamed:@"btn_color7.png"]
                           forState:UIControlStateNormal];
            [btn setBackgroundImage:[UIImage imageNamed:@"btn_color1.png"]
                           forState:UIControlStateHighlighted];
            [btn addTarget:self
                          action:@selector(deleteData)
                forControlEvents:UIControlEventTouchUpInside];
            btn.titleLabel.textColor = [UIColor whiteColor];
            btn.titleLabel.font = [UIFont systemFontOfSize:15];
            [btn setTitle:@"离线删除" forState:UIControlStateNormal];
            [scroll addSubview:btn];
            momentHeight += 80;
        }

        if ([self.titleString isEqualToString:@"巡检附加信息"]) {
            UIButton* btn1 = [UIButton buttonWithType:UIButtonTypeCustom];
            [btn1.layer setMasksToBounds:YES];
            [btn1.layer setCornerRadius:5.0]; //设置矩形四个圆角半径
            btn1.frame = CGRectMake(170, momentHeight, 140, 44);
            btn1.backgroundColor = [UIColor clearColor];
            [btn1 setBackgroundImage:[UIImage imageNamed:@"btn_color2.png"]
                            forState:UIControlStateNormal];
            [btn1 setBackgroundImage:[UIImage imageNamed:@"btn_color1.png"]
                            forState:UIControlStateHighlighted];
            [btn1 addTarget:self
                          action:@selector(btn_Action:)
                forControlEvents:UIControlEventTouchUpInside];
            [scroll addSubview:btn1];
            btn1.titleLabel.textColor = [UIColor whiteColor];
            btn1.titleLabel.font = [UIFont systemFontOfSize:15];
            if (self.isDetail)
                btn1.hidden = YES;
            if ([self.mtypeStr isEqualToString:@"1"]) {
                btn1.hidden = NO;
            }
            //提交签退
            [btn1 setTitle:@"提交签退" forState:UIControlStateNormal];
            btn1.tag = buttonTag * 2 + 10;
            momentHeight += 44;
        }
    }
    if (momentHeight <= scroll.frame.size.height) {
        momentHeight = scroll.frame.size.height;
    }
    scroll.contentSize = CGSizeMake(0, momentHeight + 50);
}
- (void)All_Init
{
    app = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    if (StatusBar_System > 0)
        moment_status = 20;
    else
        moment_status = 0;
    NavView* nav_View = [[NavView alloc] init];
    if ([Function StringIsNotEmpty:self.titleString]) {
        [self.view addSubview:[nav_View NavView_Title1:self.titleString]];
    }
    else {
        [self.view addSubview:[nav_View NavView_Title1:@"订单附加信息"]];
    }

    num_editer = -1;
    //放大图片 的背景
    view_imageView_back = [[UIView alloc] init];
    view_imageView_back.backgroundColor = [UIColor blackColor];
    view_imageView_back.frame = CGRectMake(0, 0, Phone_Weight, Phone_Height);
    if (self.RDFlag) {
        self.convertNumber = [self.dic_json objectForKey:@"tempIndexNumber_Rorder"];
    }
    else {
        self.convertNumber = [self.dic_json objectForKey:@"tempIndexNumber_order"];
    }
}
- (void)Set_SegmentView
{
    UIButton* btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.backgroundColor = [UIColor clearColor];
    btn.frame = CGRectMake(0, moment_status, 60, 44);
    btn.titleLabel.font = [UIFont systemFontOfSize:15];
    btn.tag = buttonTag;
    [btn setBackgroundImage:[UIImage imageNamed:@"btn_color6.png"]
                   forState:UIControlStateHighlighted];
    [btn setTitle:@"< 返回" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btn addTarget:self
                  action:@selector(btn_Action:)
        forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
}
- (void)btn_Action:(UIButton*)btn
{
    if (btn.tag == buttonTag) {
        if (self.isDetail) {
            [self.navigationController popViewControllerAnimated:YES];
        }
        else {
            [self WhenBack_mention_Title:@"是否返回上一级画面,"
                  @"放弃当前填写的附加订单信息?"
                                     Tag:2];
        }
    }
    else if (btn.tag == buttonTag + 1) {
        if ([self Verify_All]) {
            if ([self.mtypeStr isEqualToString:@"1"]) {
                [self WhenBack_mention_Title:@"提交事由" Tag:1];
            }
            else {
                if ([app returnYES]) {
                    if (self.RDFlag) {
                        [self WhenBack_mention_Title:@"离线保存退单" Tag:1];
                    }
                    else {
                        [self WhenBack_mention_Title:@"离线保存订单" Tag:1];
                    }
                }
                else {
                    if ([Function isConnectionAvailable]) {
                        if (self.RDFlag) {
                            [self WhenBack_mention_Title:@"提交退单" Tag:1];
                        }
                        else {
                            [self WhenBack_mention_Title:@"提交订单" Tag:1];
                        }
                    }
                    else {
                        [self WhenBack_mention_Title:@"离线保存订单" Tag:1];
                    }
                }
            }
        }
    }
    else if (btn.tag == buttonTag * 2 + 2) {
        [view_back removeFromSuperview];
        UITextField* text = [arr_tex objectAtIndex:dateIndex];
        text.text = @"";
        isOpenDate = NO;
    }
    else if (btn.tag == buttonTag * 2 + 3) {
        num_editer = -1;
        [view_back removeFromSuperview];
        isOpenDate = NO;
        if (app.isDateLegal) {
            UITextField* text = [arr_tex objectAtIndex:dateIndex];
            text.text = app.str_Date;
        }
        else {
            app.str_Date = [Function getYearMonthDay_Now];
            UITextField* text = [arr_tex objectAtIndex:dateIndex];
            text.text = app.str_Date;
        }
    }
    else if (buttonTag * 2 + 10 == btn.tag) {
        if ([self Verify_All]) {
            if ([Function isConnectionAvailable]) {
                MBProgressHUD* hud =
                    [MBProgressHUD showHUDAddedTo:self.view
                                         animated:YES];
                hud.mode = MBProgressHUDModeIndeterminate;
                hud.labelText = @"加载中..."; //加载提示语言

                if (app.isPortal) {
                    urlString =
                        [NSString stringWithFormat:@"%@%@", KPORTAL_URL, KUpdate_Sign];
                }
                else {
                    urlString =
                        [NSString stringWithFormat:@"%@%@", kBASEURL, KUpdate_Sign];
                }

                NSURL* url = [NSURL URLWithString:urlString];
                ASIFormDataRequest* request = [ASIFormDataRequest requestWithURL:url];
                request.tag = 104;
                request.delegate = self;
                [request setRequestMethod:@"POST"];
                [request setPostValue:[[SelfInf_Singleton sharedInstance]
                                              .dic_SelfInform objectForKey:@"account"]
                               forKey:KUSER_UID];
                [request setPostValue:[[SelfInf_Singleton sharedInstance]
                                              .dic_SelfInform objectForKey:@"secret"]
                               forKey:KUSER_PASSWORD];
                [request setPostValue:[[SelfInf_Singleton sharedInstance]
                                              .dic_SelfInform objectForKey:@"token"]
                               forKey:@"user.token"];
                [request setPostValue:[[SelfInf_Singleton sharedInstance]
                                              .dic_SelfInform objectForKey:@"db_ip"]
                               forKey:@"db_ip"];
                [request setPostValue:[[SelfInf_Singleton sharedInstance]
                                              .dic_SelfInform objectForKey:@"db_name"]
                               forKey:@"db_name"];

                //动态和媒体
                NSInteger count_action = 0;
                for (NSInteger i = 0; i < array_Dynamic.count; i++) {
                    NSDictionary* dic = [array_Dynamic objectAtIndex:i];
                    UITextField* text =
                        [arr_tex objectAtIndex:[[dic objectForKey:@"tag"] integerValue]];
                    [request
                        setPostValue:[dic objectForKey:@"index_no"]
                              forKey:[NSString
                                         stringWithFormat:@"dynamicList[%ld].index_no",
                                         (long)count_action]];
                    [request
                        setPostValue:text.text
                              forKey:[NSString
                                         stringWithFormat:@"dynamicList[%ld].tcontent",
                                         (long)count_action]];
                    [request
                        setPostValue:[dic objectForKey:@"tindex_no"]
                              forKey:[NSString
                                         stringWithFormat:@"dynamicList[%ld].tindex_no",
                                         (long)count_action]];

                    count_action++;
                }
                count_action = 0;
                for (NSInteger i = 0; i < arr_Media_image.count; i++) {
                    NSDictionary* dic = [arr_Media_image objectAtIndex:i];
                    if ([[dic objectForKey:@"is_addimg"] isEqualToString:@"1"]) {
                        if ([self.mtypeStr isEqualToString:@"1"]) {
                            UIImageView* imageView = [dic objectForKey:@"imgView"];
                            imagedata = UIImageJPEGRepresentation(imageView.image, 1.0);
                            [request setData:imagedata
                                  withFileName:[NSString stringWithFormat:@"T1.jpg"]
                                andContentType:@"image/jpeg"
                                        forKey:[NSString
                                                   stringWithFormat:@"fileList[%ld].file",
                                                   (long)count_action]];
                            imagedata = nil;
                        }
                        else {
                            [request setData:[dic objectForKey:@"imageData"]
                                  withFileName:[NSString stringWithFormat:@"T1.jpg"]
                                andContentType:@"image/jpeg"
                                        forKey:[NSString
                                                   stringWithFormat:@"fileList[%ld].file",
                                                   (long)count_action]];
                        }

                        [request
                            setPostValue:[dic objectForKey:@"mtype"]
                                  forKey:[NSString stringWithFormat:@"fileList[%ld].mtype",
                                                   (long)count_action]];

                        count_action++;
                    }
                    dic = nil;
                }
                //动态和媒体
                [request setPostValue:self.indexStr forKey:@"item.index_no"];
                [request setPostValue:@"1" forKey:@"sign_type"];

                [request setPostValue:[self.convertDic
                                          objectForKey:@"item.customer_index_no"]
                               forKey:@"item.customer_index_no"];
                [request setPostValue:[self.convertDic objectForKey:@"item.gname"]
                               forKey:@"item.gname"];
                [request setPostValue:[self.convertDic objectForKey:@"item.gaddress"]
                               forKey:@"item.gaddress"];
                [request setPostValue:[self.convertDic objectForKey:@"item.gbelongto"]
                               forKey:@"item.gbelongto"];
                [request setPostValue:[self.convertDic objectForKey:@"item.glng"]
                               forKey:@"item.glng"];
                [request setPostValue:[self.convertDic objectForKey:@"item.glat"]
                               forKey:@"item.glat"];
                [request setPostValue:[self.convertDic objectForKey:@"atu"]
                               forKey:@"atu"];
                [request setPostValue:[self.convertDic objectForKey:@"address"]
                               forKey:@"address"];
                [request setPostValue:[self.convertDic objectForKey:@"alng"]
                               forKey:@"alng"];
                [request setPostValue:[self.convertDic objectForKey:@"alat"]
                               forKey:@"alat"];
                [request setPostValue:[self.convertDic objectForKey:@"dist"]
                               forKey:@"dist"];
                [request setPostValue:[self.convertDic objectForKey:@"item.gmemo"]
                               forKey:@"item.gmemo"];
                [request setPostValue:self.matterFlag forKey:@"item.stype"];
                [request startAsynchronous]; //异步
            }
            else {
                [SGInfoAlert showInfo:@"当前网络不可用，请检查网络连接"
                              bgColor:[[UIColor darkGrayColor] CGColor]
                               inView:self.view
                             vertical:0.5];
            }
        }
    }
}
- (void)Action_textField:(UIButton*)btn
{
    num_editer = btn.tag; //设置标记索引
    NSDictionary* dic = [array_Dynamic objectAtIndex:btn.tag];

    if ([[dic objectForKey:@"data_type"]
            isEqualToString:
                @"4"]) { //动态项目类型（0:数字，1:文本，2:金额，3:日期，4:列表）
        // if(self.isDetail)return;
        if (self.isDetail)
            return;
        UIActionSheetViewController* actionVC =
            [[UIActionSheetViewController alloc] init];
        actionVC.str_title = [dic objectForKey:@"tname"];
        actionVC.str_tdefault = [dic objectForKey:@"tdefault"];
        [self.navigationController pushViewController:actionVC animated:YES];
    }
    else if ([[dic objectForKey:@"data_type"] isEqualToString:@"3"]) { //是日期
        if (self.isDetail)
            return;
        dateIndex = btn.tag;
        [self select_Date];
    }
    else {
        NoteViewController* noteVC = [[NoteViewController alloc] init];
        noteVC.str_title = [dic objectForKey:@"tname"];
        //动态项目类型（0:数字，1:文本，2:金额 3）
        if (self.isDetail) {
            noteVC.isDetail = YES;
        }
        if ([self.mtypeStr isEqualToString:@"1"]) {
            noteVC.isDetail = NO;
        }

        UITextField* tex = [arr_tex objectAtIndex:btn.tag];
        noteVC.str_content = tex.text;
        noteVC.str_keybordType = [dic objectForKey:@"data_type"];
        [self.navigationController pushViewController:noteVC animated:YES];
    }
}
- (void)Row_ScrollView:(UIScrollView*)scroll1
                Header:(UIColor*)color
                 Title:(NSString*)title
                   Pic:(NSString*)png
            Background:(NSString*)name
{
    //信息start
    UIImageView* imgView = [[UIImageView alloc] init];
    imgView.frame = CGRectMake(0, momentHeight, Phone_Weight, 53);
    imgView.image = [UIImage imageNamed:name];
    [scroll1 addSubview:imgView];

    UILabel* lab = [[UILabel alloc] init];
    lab.frame = CGRectMake(54, 8, 100, 38);
    lab.backgroundColor = [UIColor clearColor];
    lab.textColor = color;
    lab.text = title;
    lab.font = [UIFont systemFontOfSize:19.0];
    [imgView addSubview:lab];

    UIImageView* imgView_icon1 = [[UIImageView alloc] init];
    imgView_icon1.frame = CGRectMake(14, 10, 32, 32);
    imgView_icon1.backgroundColor = [UIColor clearColor];
    imgView_icon1.image =
        [UIImage imageNamed:[NSString stringWithFormat:@"iconic_%@.png", png]];
    [imgView addSubview:imgView_icon1];

    [scroll1 addSubview:imgView];
    // end
}
- (void)select_Date
{
    view_back = [[UIView alloc]
        initWithFrame:CGRectMake(0, moment_status + 44, Phone_Weight,
                          Phone_Height - moment_status - 44)];
    view_back.backgroundColor = [UIColor colorWithRed:193 / 255.0
                                                green:193 / 255.0
                                                 blue:193 / 255.0
                                                alpha:0.6];
    [self.view addSubview:view_back];

    RBCustomDatePickerView* pickerView = [[RBCustomDatePickerView alloc]
        initWithFrame:CGRectMake(
                          (Phone_Weight - 278.5) / 2,
                          (view_back.frame.size.height - (190 + 54 * 2) - 49) / 2,
                          278.5, 54 + 190.0)];
    pickerView.backgroundColor = [UIColor clearColor];
    pickerView.layer.cornerRadius = 8; //设置视图圆角
    pickerView.layer.masksToBounds = YES;
    [view_back addSubview:pickerView];
    for (NSInteger i = 2; i < 4; i++) { //
        UIButton* btn = [UIButton buttonWithType:UIButtonTypeCustom];
        UILabel* label_btn = [[UILabel alloc] init];
        label_btn.backgroundColor = [UIColor whiteColor];
        label_btn.layer.cornerRadius = 8;
        label_btn.layer.masksToBounds = YES;
        label_btn.textColor = [UIColor blackColor];
        label_btn.textAlignment = NSTextAlignmentCenter;
        if (i == 2) {
            btn.frame = CGRectMake((Phone_Weight - 278.5) / 2,
                pickerView.frame.origin.y + pickerView.frame.size.height + 10,
                278.5 / 2 - 5, 44);
            label_btn.text = @"取消";
        }
        else {
            btn.frame = CGRectMake((Phone_Weight - 278.5) / 2 + 5 + 278.5 / 2,
                pickerView.frame.origin.y + pickerView.frame.size.height + 10,
                278.5 / 2 - 5, 44);
            label_btn.text = @"确定";
        }
        [btn addSubview:label_btn];
        btn.backgroundColor = [UIColor clearColor];
        label_btn.frame = CGRectMake(0, 0, btn.frame.size.width, btn.frame.size.height);
        btn.tag = buttonTag * 2 + i;
        [btn addTarget:self
                      action:@selector(btn_Action:)
            forControlEvents:UIControlEventTouchUpInside];
        [view_back addSubview:btn];
    }
}
- (void)BigImage:(UIButton*)btn
{ // required97
    NSDictionary* dic = [arr_Media_image objectAtIndex:btn.tag - buttonTag];
    
    if (([[dic objectForKey:@"dicMpath"] rangeOfString:@"jpg"].location != NSNotFound) ||
        ([[dic objectForKey:@"dicMpath"] rangeOfString:@"png"].location != NSNotFound) ||
        ![Function StringIsNotEmpty:[dic objectForKey:@"dicMpath"]]) {
        if ([[dic objectForKey:@"is_addimg"] isEqualToString:@"1"] || self.localFlag) //说明已经照过图片了
        {
            UIImageView* imgView = [dic objectForKey:@"imgView"];
            [self view_image_AllScreen:imgView];
        }
        
        camera_index = btn.tag - buttonTag;
        if (self.isDetail && ![self.mtypeStr isEqualToString:@"1"])
            return;
        [self TakePhoto];
    }else {
        DocumentViewController *docVC=[[DocumentViewController alloc]init];
        docVC.titleString=@"文件";
        docVC.mutiSelect = 1;
        docVC.str_Url=[dic objectForKey:@"dicMpath"];
        docVC.str_isGraph=@"1";
        [self.navigationController pushViewController:docVC animated:YES];
    }
}
- (void)Give_you_Photo:(UIImage*)image ImageData:(NSData*)data
{
    NSMutableDictionary* dic = [arr_Media_image objectAtIndex:camera_index];
    UIImageView* imageView = [[UIImageView alloc] init];
    imageView.image = image;
    [dic setObject:imageView forKey:@"imgView"];
    [dic setObject:@"1" forKey:@"is_addimg"];
    [dic setObject:@"1" forKey:@"re_take"];
    [dic setObject:data forKey:@"imageData"];
    UIImageView* img_show = [arr_ShowImage objectAtIndex:camera_index];
    img_show.image = image;
}
- (void)view_image_AllScreen:(UIImageView*)image
{
    ///////////可伸缩图片
    UIScrollView* _scroll = [[UIScrollView alloc] init];
    _scroll.frame = CGRectMake(0, 0, view_imageView_back.frame.size.width,
        view_imageView_back.frame.size.height);
    _scroll.delegate = self;
    _scroll.multipleTouchEnabled = YES;
    _scroll.showsHorizontalScrollIndicator = NO;
    _scroll.showsVerticalScrollIndicator = NO;
    [_scroll setContentSize:CGSizeMake(_scroll.frame.size.width,
                                _scroll.frame.size.height)];
    self.zoomScrollView = [[MRZoomScrollView alloc] init];
    CGRect frame = _scroll.frame;
    frame.origin.x = 0;
    frame.origin.y = 0;
    self.zoomScrollView.frame = frame;
    self.zoomScrollView.imageView.image = image.image;
    self.zoomScrollView.imageView.frame =
        [Function scaleImage:image.image
                      toSize:CGRectMake(0.0, 0.0, Phone_Weight, Phone_Height)];
    _scroll.backgroundColor = [UIColor blackColor];
    [_scroll addSubview:self.zoomScrollView];
    [view_imageView_back addSubview:_scroll];
    ///////////可伸缩图片
    //识别单指点击 退出大图 start
    UITapGestureRecognizer* singleTap = [[UITapGestureRecognizer alloc]
        initWithTarget:self
                action:@selector(handleSingleTap:)];
    [singleTap setNumberOfTapsRequired:1];

    [self.zoomScrollView addGestureRecognizer:singleTap];
    singleTap = nil;
    _scroll = nil;
    self.zoomScrollView = nil;
    //识别单指点击 退出大图 end
    [self.view addSubview:view_imageView_back];
}
- (void)handleSingleTap:(UITapGestureRecognizer*)sender
{
    [self cancel_AllScreen];
}
- (void)cancel_AllScreen
{
    [view_imageView_back removeFromSuperview];
}
#pragma TakePhoto
- (void)TakePhoto
{
    if (isPad) {
        if ([self.mtypeStr isEqualToString:@"1"]) {
            if ([self.matterFlag isEqualToString:@"2"]) {
                UIActionSheet* actionSheet =
                    [[UIActionSheet alloc] initWithTitle:@"您想如何获取照片?"
                                                delegate:self
                                       cancelButtonTitle:@"取消"
                                  destructiveButtonTitle:nil
                                       otherButtonTitles:@"拍照", nil];
                [actionSheet showInView:self.view];
            }
            else {
                UIActionSheet* actionSheet = [[UIActionSheet alloc]
                             initWithTitle:@"您想如何获取照片?"
                                  delegate:self
                         cancelButtonTitle:@"取消"
                    destructiveButtonTitle:nil
                         otherButtonTitles:@"拍照", @"相册", @"取消", nil];
                [actionSheet showInView:self.view];
            }
        }
        else {
            UIActionSheet* actionSheet = [[UIActionSheet alloc]
                         initWithTitle:@"您想如何获取照片?"
                              delegate:self
                     cancelButtonTitle:@"取消"
                destructiveButtonTitle:nil
                     otherButtonTitles:@"拍照", @"相册", @"取消", nil];
            [actionSheet showInView:self.view];
        }
    }
    else {
        if ([self.mtypeStr isEqualToString:@"1"]) {
            if ([self.matterFlag isEqualToString:@"2"]) {
                UIActionSheet* actionSheet =
                    [[UIActionSheet alloc] initWithTitle:@"您想如何获取照片?"
                                                delegate:self
                                       cancelButtonTitle:@"取消"
                                  destructiveButtonTitle:nil
                                       otherButtonTitles:@"拍照", nil];
                [actionSheet showInView:self.view];
            }
            else {
                UIActionSheet* actionSheet =
                    [[UIActionSheet alloc] initWithTitle:@"您想如何获取照片?"
                                                delegate:self
                                       cancelButtonTitle:@"取消"
                                  destructiveButtonTitle:nil
                                       otherButtonTitles:@"拍照", @"相册", nil];
                [actionSheet showInView:self.view];
            }
        }
        else {
            UIActionSheet* actionSheet =
                [[UIActionSheet alloc] initWithTitle:@"您想如何获取照片?"
                                            delegate:self
                                   cancelButtonTitle:@"取消"
                              destructiveButtonTitle:nil
                                   otherButtonTitles:@"拍照", @"相册", nil];
            [actionSheet showInView:self.view];
        }
    }
}
- (void)actionSheet:(UIActionSheet*)actionSheet
    clickedButtonAtIndex:(NSInteger)buttonIndex
{
    UIImagePickerController* picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    if (buttonIndex == 2)
        return;
    if (buttonIndex == 0) { //拍照
        BOOL cameraFlag = [Function CanOpenCamera];

        if (!cameraFlag) {
            PresentView* presentView = [PresentView getSingle];

            presentView.presentViewDelegate = self;

            presentView.frame = CGRectMake(0, 0, 240, 250);

            [[KGModal sharedInstance] showWithContentView:presentView
                                              andAnimated:YES];

            return;
        }
        isCamera = YES;
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        [self cancel_AllScreen];
        [self presentViewController:picker animated:YES completion:NULL];
    }
    else if (buttonIndex == 1) { //图库
        if ([self.matterFlag isEqualToString:@"2"]) {
            return;
        }
        isCamera = NO;
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        [self cancel_AllScreen];
        [self presentViewController:picker animated:YES completion:NULL];
    }
}
#pragma - mark UIImagePickerController delegate
- (void)imagePickerController:(UIImagePickerController*)picker
didFinishPickingMediaWithInfo:(NSDictionary*)info
{
    chosenImage = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
    NavView* nav = [[NavView alloc] init];
    MBProgressHUD* hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.labelText = @"加载中..."; //加载提示语言
    if (isCamera) {
        NSString* strAll;
        UILabel* lab_content;

        NSData* image_data = UIImageJPEGRepresentation(
            [chosenImage resize:CGSizeMake(Phone_Weight * 2, Phone_Height * 2)],
            0.6);
        UIImage* image_New = [UIImage imageWithData:image_data];
        strAll = [NSString
            stringWithFormat:@"采集人:%@     "
            @"GPS:%@,%@\n地址:%@\n采集时间:%@\n文件生成时间:%@\n",
            [[SelfInf_Singleton sharedInstance]
                                     .dic_SelfInform objectForKey:@"uname"],
            app.str_nlng, app.str_alat, app.str_LocationName,
            [Function getSystemTimeNow],
            [Function getSystemTimeNow]];
        lab_content =
            [Water_Mark Label_Freedom_Content:strAll
                                 Choose_image:image_New];
        UIImage* getImage = [Water_Mark
            TransFor_ChooseImage:image_New
                             Lab:[Water_Mark imageWithUIView:lab_content]];
        [self Give_you_Photo:getImage
                   ImageData:UIImageJPEGRepresentation(getImage, 0.6)];
        strAll = nil;
        //保存到系统相册
        dispatch_async(
            dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                UIImageWriteToSavedPhotosAlbum(
                    chosenImage, self,
                    @selector(image:didFinishSavingWithError:contextInfo:), NULL);
            });
    }
    else {
        NSURL* assetURL = [info objectForKey:UIImagePickerControllerReferenceURL];
        ALAssetsLibrary* library = [[ALAssetsLibrary alloc] init];
        [library assetForURL:assetURL
            resultBlock:^(ALAsset* asset) {
                NSString* strAll;
                UILabel* lab_content;

                NSData* image_data = UIImageJPEGRepresentation(
                    [chosenImage
                        resize:CGSizeMake(Phone_Weight * 2, Phone_Height * 2)],
                    0.6);
                UIImage* image_New = [UIImage imageWithData:image_data];

                NSDate* date = [asset valueForProperty:ALAssetPropertyDate];
                NSArray* arr_date = [[NSString stringWithFormat:@"%@", date]
                    componentsSeparatedByString:@"+"];

                strAll = [NSString
                    stringWithFormat:@"采集人:%@     "
                    @"GPS:%@,%@\n地址:%@\n采集时间:%@ "
                    @"文件生成时间:%@\n",
                    [[SelfInf_Singleton sharedInstance]
                                             .dic_SelfInform objectForKey:@"uname"],
                    app.str_nlng, app.str_alat, app.str_LocationName,
                    [Function getSystemTimeNow],
                    [arr_date objectAtIndex:0]];
                lab_content =
                    [Water_Mark Label_Freedom_Content:strAll
                                         Choose_image:image_New];
                UIImage* getImage = [Water_Mark
                    TransFor_ChooseImage:image_New
                                     Lab:[Water_Mark imageWithUIView:lab_content]];
                [self Give_you_Photo:getImage
                           ImageData:UIImageJPEGRepresentation(getImage, 0.6)];
                strAll = nil;

            }
            failureBlock:^(NSError* error){
            }];
    }
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    [SGInfoAlert showInfo:@" 照片添加成功! "
                  bgColor:[[UIColor darkGrayColor] CGColor]
                   inView:self.view
                 vertical:0.5];
    [picker dismissViewControllerAnimated:YES completion:NULL];
    nav = nil;
    picker = nil;
}
- (void)image:(UIImage*)image
    didFinishSavingWithError:(NSError*)error
                 contextInfo:(void*)contextInfo
{
    if (error != NULL) {
        // Dlog(@"保存图片失败");
    }
    else {
        // Dlog(@"保存图片成功");
    }
}
- (void)didUpdateBMKUserLocation:(BMKUserLocation*)userLocation
{
    app.str_alat = [NSString
        stringWithFormat:@"%lf", userLocation.location.coordinate.latitude];
    app.str_nlng = [NSString
        stringWithFormat:@"%lf", userLocation.location.coordinate.longitude];
    CLGeocoder* geocoder = [[CLGeocoder alloc] init];
    [geocoder
        reverseGeocodeLocation:userLocation.location
             completionHandler:^(NSArray* array, NSError* error) {
                 if (array.count > 0) {
                     CLPlacemark* placemark = [array objectAtIndex:0];

                     app.str_LocationName = [NSString
                         stringWithFormat:@"%@%@%@%@%@", placemark.administrativeArea,
                         placemark.locality, placemark.subLocality,
                         placemark.thoroughfare,
                         placemark.subThoroughfare];
                     app.str_LocationName =
                         [NavView returnString:app.str_LocationName];
                 }
             }];
    geocoder = nil;
    // locService.delegate=nil;
}
- (BOOL)Verify_All //校验必填选项
{
    //动态
    for (NSInteger i = 0; i < array_Dynamic.count; i++) {
        NSDictionary* dic = [array_Dynamic objectAtIndex:i];
        if ([[dic objectForKey:@"trequired"] isEqualToString:@"1"]) {
            UITextField* tex =
                [arr_tex objectAtIndex:[[dic objectForKey:@"tag"] integerValue]];
            if ([tex.text isEqualToString:@""] || [Function isBlankString:tex.text]) {
                [self Must_write];
                return NO;
            }
        }
    }
    if ([Function isConnectionAvailable]) {
        if (!self.localFlag || !self.RDFlag) {
            if ([Function isBlankString:app.str_LocationName] ||
                [app.str_LocationName isEqualToString:@""] ||
                [Function isBlankString:app.str_nlng] ||
                [app.str_nlng isEqualToString:@""] ||
                [Function isBlankString:app.str_alat] ||
                [app.str_alat isEqualToString:@""]) {
                [SGInfoAlert
                    showInfo:
                        @"定位服务不佳,请确认定位服务开启状态良好"
                     bgColor:[[UIColor darkGrayColor] CGColor]
                      inView:self.view
                    vertical:0.5];
                return NO;
            }
        }
    }

    //媒体
    for (NSInteger i = 0; i < arr_Media_image.count; i++) {
        NSDictionary* dic = [arr_Media_image objectAtIndex:i];
        if ([[dic objectForKey:@"required"] isEqualToString:@"1"]) {
            if (self.localFlag) {
                NSData* data = [dic objectForKey:@"imageData"];
                if (!data.length) {
                    [self Must_write];
                    dic = nil;
                    return NO;
                }
            }
            else if ([[dic objectForKey:@"is_addimg"]
                         isEqualToString:@"0"]) //等于0表示没添加
            {
                [self Must_write];
                dic = nil;
                return NO;
            }
        }
    }
    return YES;
}
- (void)Must_write
{ //如果必填字段为空或者字符串长度为0 做提示 并且不予提交远程
    [SGInfoAlert showInfo:@"请把必填内容完善,再尝试提交"
                  bgColor:[[UIColor darkGrayColor] CGColor]
                   inView:self.view
                 vertical:0.5];
}

//退单提交
- (void)Submit_TheRQrder
{
    if ([Function isConnectionAvailable]) {
        MBProgressHUD* hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.mode = MBProgressHUDModeIndeterminate;
        hud.labelText = @"加载中..."; //加载提示语言

        if (app.isPortal) {
            urlString = [NSString stringWithFormat:@"%@%@", KPORTAL_URL, KRet_Order];
        }
        else {
            urlString = [NSString stringWithFormat:@"%@%@", kBASEURL, KRet_Order];
        }

        NSURL* url = [NSURL URLWithString:urlString];
        ASIFormDataRequest* request = [ASIFormDataRequest requestWithURL:url];
        request.delegate = self;
        [request setRequestMethod:@"POST"];
        [request setPostValue:[[SelfInf_Singleton sharedInstance]
                                      .dic_SelfInform objectForKey:@"account"]
                       forKey:KUSER_UID];
        [request setPostValue:[[SelfInf_Singleton sharedInstance]
                                      .dic_SelfInform objectForKey:@"secret"]
                       forKey:KUSER_PASSWORD];
        [request setPostValue:[[SelfInf_Singleton sharedInstance]
                                      .dic_SelfInform objectForKey:@"token"]
                       forKey:@"user.token"];
        [request setPostValue:[[SelfInf_Singleton sharedInstance]
                                      .dic_SelfInform objectForKey:@"db_ip"]
                       forKey:@"db_ip"];
        [request setPostValue:[[SelfInf_Singleton sharedInstance]
                                      .dic_SelfInform objectForKey:@"db_name"]
                       forKey:@"db_name"];
        if (self.localFlag) {
            array_Dynamic = [self.dic_json objectForKey:@"array_Dynamic"];
        }
        for (NSInteger i = 0; i < [AddProduct sharedInstance].arr_AddToList.count;
             i++) {
            NSDictionary* dic_unit =
                [[AddProduct sharedInstance]
                        .arr_AddToList objectAtIndex:i];
            [request setPostValue:[dic_unit objectForKey:@"pcode"]
                           forKey:[NSString stringWithFormat:@"postList[%ld].pcode",
                                            (long)i]];
            [request setPostValue:[dic_unit objectForKey:@"price"]
                           forKey:[NSString stringWithFormat:@"postList[%ld].price",
                                            (long)i]];
            [request setPostValue:[dic_unit objectForKey:@"cnt"]
                           forKey:[NSString stringWithFormat:@"postList[%ld].cnt",
                                            (long)i]];
            [request setPostValue:[dic_unit objectForKey:@"real_rsum"]
                           forKey:[NSString stringWithFormat:@"postList[%ld].rsum",
                                            (long)i]];
            [request
                setPostValue:[dic_unit objectForKey:@"pindex_no"]
                      forKey:[NSString stringWithFormat:@"postList[%ld].pindex_no",
                                       (long)i]];
            [request setPostValue:[dic_unit objectForKey:@"selling_price"]
                           forKey:[NSString
                                      stringWithFormat:@"postList[%ld].selling_price",
                                      (long)i]];
        }
        //动态和媒体
        NSInteger count_action = 0;
        for (NSInteger i = 0; i < array_Dynamic.count; i++) {
            NSDictionary* dic = [array_Dynamic objectAtIndex:i];
            [request
                setPostValue:[dic objectForKey:@"index_no"]
                      forKey:[NSString stringWithFormat:@"dynamicList[%ld].index_no",
                                       (long)count_action]];
            UITextField* text =
                [arr_tex objectAtIndex:[[dic objectForKey:@"tag"] integerValue]];
            [request
                setPostValue:text.text
                      forKey:[NSString stringWithFormat:@"dynamicList[%ld].tcontent",
                                       (long)count_action]];
            count_action++;
        }
        count_action = 0;
        for (NSInteger i = 0; i < arr_Media_image.count; i++) {
            NSDictionary* dic = [arr_Media_image objectAtIndex:i];
            if ([[dic objectForKey:@"is_addimg"] isEqualToString:@"1"] || self.localFlag) {
                [request setData:[dic objectForKey:@"imageData"]
                      withFileName:[NSString stringWithFormat:@"T1.jpg"]
                    andContentType:@"image/jpeg"
                            forKey:[NSString stringWithFormat:@"fileList[%ld].file",
                                             (long)count_action]];
                [request setPostValue:[dic objectForKey:@"mtype"]
                               forKey:[NSString stringWithFormat:@"fileList[%ld].mtype",
                                                (long)count_action]];

                count_action++;
            }
            dic = nil;
        }
        //动态和媒体
        [request setPostValue:self.str_cindex_no forKey:@"cindex_no"]; //终端索引
        [request setPostValue:self.str_should_Accounts forKey:@"osum"];
        [request setPostValue:self.str_real_Accounts forKey:@"rsum"];
        [request setPostValue:self.str_disCount forKey:@"odiscount"];
        [request startAsynchronous]; //异步
    }
    else {
        [SGInfoAlert showInfo:@"当前网络不可用，请检查网络连接"
                      bgColor:[[UIColor darkGrayColor] CGColor]
                       inView:self.view
                     vertical:0.5];
    }
}

//提交订单
- (void)Submit_TheQrder
{
    if ([Function isConnectionAvailable]) {
        MBProgressHUD* hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.mode = MBProgressHUDModeIndeterminate;
        hud.labelText = @"加载中..."; //加载提示语言

        if (app.isPortal) {
            urlString = [NSString stringWithFormat:@"%@%@", KPORTAL_URL, KNew_Order];
        }
        else {
            urlString = [NSString stringWithFormat:@"%@%@", kBASEURL, KNew_Order];
        }

        NSURL* url = [NSURL URLWithString:urlString];
        ASIFormDataRequest* request = [ASIFormDataRequest requestWithURL:url];
        request.delegate = self;
        [request setRequestMethod:@"POST"];
        [request setPostValue:[[SelfInf_Singleton sharedInstance]
                                      .dic_SelfInform objectForKey:@"account"]
                       forKey:KUSER_UID];
        [request setPostValue:[[SelfInf_Singleton sharedInstance]
                                      .dic_SelfInform objectForKey:@"secret"]
                       forKey:KUSER_PASSWORD];
        [request setPostValue:[[SelfInf_Singleton sharedInstance]
                                      .dic_SelfInform objectForKey:@"token"]
                       forKey:@"user.token"];
        [request setPostValue:[[SelfInf_Singleton sharedInstance]
                                      .dic_SelfInform objectForKey:@"db_ip"]
                       forKey:@"db_ip"];
        [request setPostValue:[[SelfInf_Singleton sharedInstance]
                                      .dic_SelfInform objectForKey:@"db_name"]
                       forKey:@"db_name"];
        if (self.localFlag) {
            array_Dynamic = [self.dic_json objectForKey:@"array_Dynamic"];
        }
        for (NSInteger i = 0; i < [AddProduct sharedInstance].arr_AddToList.count;
             i++) {
            NSDictionary* dic_unit =
                [[AddProduct sharedInstance]
                        .arr_AddToList objectAtIndex:i];
            if (app.GiftFlagStr.integerValue) {
                [request setPostValue:[dic_unit objectForKey:@"remark"]
                               forKey:[NSString stringWithFormat:@"postList[%ld].memo",
                                       (long)i]];
                [request setPostValue:[dic_unit objectForKey:@"switch"]
                               forKey:[NSString stringWithFormat:@"postList[%ld].gift_flg",
                                       (long)i]];
            }
            
            [request setPostValue:[dic_unit objectForKey:@"pcode"]
                           forKey:[NSString stringWithFormat:@"postList[%ld].pcode",
                                            (long)i]];
            [request setPostValue:[dic_unit objectForKey:@"price"]
                           forKey:[NSString stringWithFormat:@"postList[%ld].price",
                                            (long)i]];
            [request setPostValue:[dic_unit objectForKey:@"cnt"]
                           forKey:[NSString stringWithFormat:@"postList[%ld].cnt",
                                            (long)i]];
            [request setPostValue:[dic_unit objectForKey:@"real_rsum"]
                           forKey:[NSString stringWithFormat:@"postList[%ld].rsum",
                                            (long)i]];
            [request
                setPostValue:[dic_unit objectForKey:@"pindex_no"]
                      forKey:[NSString stringWithFormat:@"postList[%ld].pindex_no",
                                       (long)i]];
            [request setPostValue:[dic_unit objectForKey:@"selling_price"]
                           forKey:[NSString
                                      stringWithFormat:@"postList[%ld].selling_price",
                                      (long)i]];
        }
        //动态和媒体
        NSInteger count_action = 0;
        for (NSInteger i = 0; i < array_Dynamic.count; i++) {
            NSDictionary* dic = [array_Dynamic objectAtIndex:i];
            [request
                setPostValue:[dic objectForKey:@"index_no"]
                      forKey:[NSString stringWithFormat:@"dynamicList[%ld].index_no",
                                       (long)count_action]];
            UITextField* text =
                [arr_tex objectAtIndex:[[dic objectForKey:@"tag"] integerValue]];
            [request
                setPostValue:text.text
                      forKey:[NSString stringWithFormat:@"dynamicList[%ld].tcontent",
                                       (long)count_action]];
            count_action++;
        }
        count_action = 0;
        for (NSInteger i = 0; i < arr_Media_image.count; i++) {
            NSDictionary* dic = [arr_Media_image objectAtIndex:i];
            if ([[dic objectForKey:@"is_addimg"] isEqualToString:@"1"] || self.localFlag) {
                [request setData:[dic objectForKey:@"imageData"]
                      withFileName:[NSString stringWithFormat:@"T1.jpg"]
                    andContentType:@"image/jpeg"
                            forKey:[NSString stringWithFormat:@"fileList[%ld].file",
                                             (long)count_action]];
                [request setPostValue:[dic objectForKey:@"mtype"]
                               forKey:[NSString stringWithFormat:@"fileList[%ld].mtype",
                                                (long)count_action]];

                count_action++;
            }
            dic = nil;
        }
        //动态和媒体
        [request setPostValue:self.str_cindex_no forKey:@"cindex_no"]; //终端索引
        [request setPostValue:self.str_should_Accounts forKey:@"osum"];
        [request setPostValue:self.str_real_Accounts forKey:@"orsum"];
        [request setPostValue:self.str_disCount forKey:@"odiscount"];
        [request setPostValue:self.str_isInstead forKey:@"ctc_sts"];
        [request startAsynchronous]; //异步
    }
    else {
        [SGInfoAlert showInfo:@"当前网络不可用，请检查网络连接"
                      bgColor:[[UIColor darkGrayColor] CGColor]
                       inView:self.view
                     vertical:0.5];
    }
}
- (void)get_JsonString:(NSString*)jsonString Type:(NSString*)type
{
    SBJsonParser* parser = [[SBJsonParser alloc] init];
    NSDictionary* dict = [parser objectWithString:jsonString];
    if ([[dict objectForKey:@"ret"]
            isEqualToString:@"0"]) { //调用上一级页面的代理方法
        if (self.RDFlag) {
            [SGInfoAlert showInfo:@" 成功提交退单"
                          bgColor:[[UIColor darkGrayColor] CGColor]
                           inView:self.view
                         vertical:0.5];
            app.order_refresh = 1;
            [self.navigationController
                popToViewController:[self.navigationController.viewControllers
                                        objectAtIndex:2]
                           animated:YES];
        }
        else {
            [SGInfoAlert showInfo:@" 成功提交订单"
                          bgColor:[[UIColor darkGrayColor] CGColor]
                           inView:self.view
                         vertical:0.5];
        }
    }
    else {
        [SGInfoAlert showInfo:[dict objectForKey:@"message"]
                      bgColor:[[UIColor darkGrayColor] CGColor]
                       inView:self.view
                     vertical:0.5];
    }

    if ([AddProduct sharedInstance].arr_AddToList.count) {
        [[AddProduct sharedInstance]
                .arr_AddToList removeAllObjects]; //以下两段 返回OK 了
        if ([self.str_isFromOnlineOrder isEqualToString:@"0"]) {
            [self setStop];
            self.delegate = (id)app.VC_SubmitOrder;
            //指定代理对象为，second
            [self.delegate Notify_OrderListView]; //这里获得代理方法的返回值。
        }
        else if ([self.str_isFromOnlineOrder isEqualToString:@"1"]) {
            [self setStop];
        }

        if (!self.RDFlag) {
            [self deleteLocalIndexData];
        }
        else {
            [self deleteLocalIndexRData];
        }
    }
}
- (void)WhenBack_mention_Title:(NSString*)title
                           Tag:(NSInteger)tag //编辑状态中 返回提示
{
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                    message:title
                                                   delegate:self
                                          cancelButtonTitle:@"取消"
                                          otherButtonTitles:@"确定", nil];
    [alert show];
    alert.tag = tag;
    alert = nil;
}
- (void)alertView:(UIAlertView*)alertView
    clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 1) {
        if (buttonIndex == 1) {
            if ([self.mtypeStr isEqualToString:@"1"]) {
                [self matterRequest];
            }
            else {
                if ([app returnYES]) {
                    if (self.RDFlag) {
                        [self saveRDataToLocal];
                    }
                    else {
                        [self saveDataToLocal];
                    }
                }
                else {
                    if ([Function isConnectionAvailable]) {
                        if (self.RDFlag) {
                            [self Submit_TheRQrder];
                        }
                        else {
                            [self Submit_TheQrder];
                        }
                    }
                    else {
                        if (self.RDFlag) {
                            [self saveRDataToLocal];
                        }
                        else {
                            [self saveDataToLocal];
                        }
                    }
                }
            }
        }
    }
    else if (alertView.tag == 2) {
        if (buttonIndex == 1) {
            [self setStop];
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
}

- (void)matterRequest
{
    if ([Function isConnectionAvailable]) {
        MBProgressHUD* hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.mode = MBProgressHUDModeIndeterminate;
        hud.labelText = @"加载中..."; //加载提示语言

        if (app.isPortal) {
            urlString =
                [NSString stringWithFormat:@"%@%@", KPORTAL_URL, KUpdate_Sign];
        }
        else {
            urlString = [NSString stringWithFormat:@"%@%@", kBASEURL, KUpdate_Sign];
        }

        NSURL* url = [NSURL URLWithString:urlString];
        ASIFormDataRequest* request = [ASIFormDataRequest requestWithURL:url];
        request.tag = 103;
        request.delegate = self;
        [request setRequestMethod:@"POST"];
        [request setPostValue:[[SelfInf_Singleton sharedInstance]
                                      .dic_SelfInform objectForKey:@"account"]
                       forKey:KUSER_UID];
        [request setPostValue:[[SelfInf_Singleton sharedInstance]
                                      .dic_SelfInform objectForKey:@"secret"]
                       forKey:KUSER_PASSWORD];
        [request setPostValue:[[SelfInf_Singleton sharedInstance]
                                      .dic_SelfInform objectForKey:@"token"]
                       forKey:@"user.token"];
        [request setPostValue:[[SelfInf_Singleton sharedInstance]
                                      .dic_SelfInform objectForKey:@"db_ip"]
                       forKey:@"db_ip"];
        [request setPostValue:[[SelfInf_Singleton sharedInstance]
                                      .dic_SelfInform objectForKey:@"db_name"]
                       forKey:@"db_name"];

        //动态和媒体
        NSInteger count_action = 0;
        for (NSInteger i = 0; i < array_Dynamic.count; i++) {
            NSDictionary* dic = [array_Dynamic objectAtIndex:i];
            UITextField* text =
                [arr_tex objectAtIndex:[[dic objectForKey:@"tag"] integerValue]];
            [request
                setPostValue:[dic objectForKey:@"index_no"]
                      forKey:[NSString stringWithFormat:@"dynamicList[%ld].index_no",
                                       (long)count_action]];
            [request
                setPostValue:text.text
                      forKey:[NSString stringWithFormat:@"dynamicList[%ld].tcontent",
                                       (long)count_action]];
            [request
                setPostValue:[dic objectForKey:@"tindex_no"]
                      forKey:[NSString stringWithFormat:@"dynamicList[%ld].tindex_no",
                                       (long)count_action]];

            count_action++;
        }
        count_action = 0;
        for (NSInteger i = 0; i < arr_Media_image.count; i++) {
            NSDictionary* dic = [arr_Media_image objectAtIndex:i];
            if ([[dic objectForKey:@"is_addimg"] isEqualToString:@"1"]) {
                if ([self.mtypeStr isEqualToString:@"1"]) {
                    UIImageView* imageView = [dic objectForKey:@"imgView"];
                    imagedata = UIImageJPEGRepresentation(imageView.image, 1.0);
                    [request setData:imagedata
                          withFileName:[NSString stringWithFormat:@"T1.jpg"]
                        andContentType:@"image/jpeg"
                                forKey:[NSString stringWithFormat:@"fileList[%ld].file",
                                                 (long)count_action]];
                    imagedata = nil;
                }
                else {
                    [request setData:[dic objectForKey:@"imageData"]
                          withFileName:[NSString stringWithFormat:@"T1.jpg"]
                        andContentType:@"image/jpeg"
                                forKey:[NSString stringWithFormat:@"fileList[%ld].file",
                                                 (long)count_action]];
                }

                [request setPostValue:[dic objectForKey:@"mtype"]
                               forKey:[NSString stringWithFormat:@"fileList[%ld].mtype",
                                                (long)count_action]];

                count_action++;
            }
            dic = nil;
        }
        //动态和媒体
        [request setPostValue:self.indexStr forKey:@"item.index_no"];
        [request setPostValue:@"-1" forKey:@"sign_type"];
        [request startAsynchronous]; //异步
    }
    else {
        [SGInfoAlert showInfo:@"当前网络不可用，请检查网络连接"
                      bgColor:[[UIColor darkGrayColor] CGColor]
                       inView:self.view
                     vertical:0.5];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)requestFinished:(ASIHTTPRequest*)request
{
    [MBProgressHUD hideHUDForView:self.view animated:YES];

    if ([request responseStatusCode] == 200) {
        if (request.tag == 103) {
            NSString* jsonString = [request responseString];
            SBJsonParser* parser = [[SBJsonParser alloc] init];
            NSDictionary* dict = [parser objectWithString:jsonString];
            NSString* returnString = [dict objectForKey:@"ret"];
            if ([returnString isEqualToString:@"0"]) {
                app.backToSign = 1;
                [self.navigationController popViewControllerAnimated:YES];
            }
            else {
                [SGInfoAlert showInfo:@" 提交事由失败 "
                              bgColor:[[UIColor darkGrayColor] CGColor]
                               inView:self.view
                             vertical:0.5];
            }
            return;
        }
        else if (request.tag == 104) {
            NSString* jsonString = [request responseString];
            SBJsonParser* parser = [[SBJsonParser alloc] init];
            NSDictionary* dict = [parser objectWithString:jsonString];
            NSString* returnString = [dict objectForKey:@"ret"];
            if ([returnString isEqualToString:@"0"]) {
                if ([self.matterFlag isEqualToString:@"2"]) {
                    [self.navigationController
                        popToViewController:[self.navigationController.viewControllers
                                                objectAtIndex:1]
                                   animated:YES];
                }
                else {
                    [self.navigationController
                        popToViewController:[self.navigationController.viewControllers
                                                objectAtIndex:2]
                                   animated:YES];
                }
            }
            else {
                [SGInfoAlert showInfo:@" 提交签退失败 "
                              bgColor:[[UIColor darkGrayColor] CGColor]
                               inView:self.view
                             vertical:0.5];
            }
            return;
        }
        NSString* jsonString = [request responseString];
        [self get_JsonString:jsonString Type:@"0"];
    }
    else {
        [SGInfoAlert showInfo:@"发生异常,请稍后再试"
                      bgColor:[[UIColor darkGrayColor] CGColor]
                       inView:self.view
                     vertical:0.5];
        [NdUncaughtExceptionHandler
            Post_url:[NSString stringWithFormat:@"URL:%@,HTTP_Code%d", urlString,
                               [request responseStatusCode]]];
    }
}

- (void)requestFailed:(ASIHTTPRequest*)request
{
    [MBProgressHUD hideHUDForView:self.view animated:YES];

    [SGInfoAlert showInfo:@"哎呀，服务器无响应，一会再试试吧"
                  bgColor:[[UIColor darkGrayColor] CGColor]
                   inView:self.view
                 vertical:0.5];
    // 请求响应失败，返回错误信息
    // Dlog(@"HTTP 响应码：%d",[request responseStatusCode]);
}

#pragma mark---- presentView delegate method

- (void)presentViewDissmissAction
{
    [[KGModal sharedInstance] closeAction:nil];
}

- (void)saveDataToLocal
{
    NSString* dateString = [Function getSystemTimeNow];
    NSMutableDictionary* tempDic = [NSMutableDictionary dictionary];
    [self NSMutableDictionary:tempDic
                    SetObject:[AddProduct sharedInstance].arr_AddToList
                       forKey:@"AddProduct"];
    [self NSMutableDictionary:tempDic
                    SetObject:array_Dynamic
                       forKey:@"array_Dynamic"];
    [self NSMutableDictionary:tempDic
                    SetObject:self.str_cindex_no
                       forKey:@"cindex_no"];
    [self NSMutableDictionary:tempDic
                    SetObject:self.str_should_Accounts
                       forKey:@"osum"];
    [self NSMutableDictionary:tempDic
                    SetObject:self.str_real_Accounts
                       forKey:@"orsum"];
    [self NSMutableDictionary:tempDic
                    SetObject:self.str_disCount
                       forKey:@"odiscount"];
    [self NSMutableDictionary:tempDic
                    SetObject:self.str_isInstead
                       forKey:@"ctc_sts"];
    [self NSMutableDictionary:tempDic
                    SetObject:self.terminalName
                       forKey:@"terminal"];
    [tempDic setObject:@"0" forKey:@"exe_sts"];
    [tempDic setObject:dateString forKey:@"ins_date"];

    if (![Function StringIsNotEmpty:self.convertNumber]) {
        NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
        tempIndexNumber = [defaults objectForKey:@"tempIndexNumber_order"];
        if (tempIndexNumber.length) {
            tempIndexNumber =
                [NSString stringWithFormat:@"%ld", tempIndexNumber.integerValue + 1];
        }
        else {
            tempIndexNumber = @"1";
        }
        [defaults setObject:tempIndexNumber forKey:@"tempIndexNumber_order"];
        [defaults synchronize];
    }
    else {
        tempIndexNumber = [NSString stringWithFormat:@"%@", self.convertNumber];
    }

    NSMutableDictionary* mutDic = [NSMutableDictionary dictionary];
    for (NSInteger i = 0; i < array_Dynamic.count; i++) {
        NSDictionary* dic = [array_Dynamic objectAtIndex:i];
        UITextField* text =
            [arr_tex objectAtIndex:[[dic objectForKey:@"tag"] integerValue]];
        NSString* keyStr = [NSString stringWithFormat:@"%ld", (long)i];
        [mutDic setObject:text.text forKey:keyStr];
    }

    [tempDic setObject:mutDic forKey:@"mutDic"];

    NSMutableArray* tempImageArray = [NSMutableArray array];
    for (int i = 0; i < arr_Media_image.count; i++) {
        NSDictionary* tempDic1 = [arr_Media_image objectAtIndex:i];
        NSMutableDictionary* mutDic = [NSMutableDictionary dictionary];
        [self NSMutableDictionary:mutDic
                        SetObject:[tempDic1 objectForKey:@"is_addimg"]
                           forKey:@"is_addimg"];
        [self NSMutableDictionary:mutDic
                        SetObject:[tempDic1 objectForKey:@"isme"]
                           forKey:@"isme"];
        [self NSMutableDictionary:mutDic
                        SetObject:[tempDic1 objectForKey:@"re_take"]
                           forKey:@"re_take"];
        [self NSMutableDictionary:mutDic
                        SetObject:[tempDic1 objectForKey:@"required"]
                           forKey:@"required"];
        [self NSMutableDictionary:mutDic
                        SetObject:[tempDic1 objectForKey:@"mtype"]
                           forKey:@"mtype"];
        [self NSMutableDictionary:mutDic
                        SetObject:[tempDic1 objectForKey:@"clabel"]
                           forKey:@"clabel"];
        [self NSMutableDictionary:mutDic
                        SetObject:[tempDic1 objectForKey:@"imageData"]
                           forKey:@"imageData"];
        [tempImageArray addObject:mutDic];
    }

    if (tempImageArray.count) {
        [tempDic setObject:tempImageArray forKey:@"arr_Media_image"];
    }

    [tempDic setObject:tempIndexNumber forKey:@"tempIndexNumber_order"];
    NSMutableArray* localArray = nil;
    if ([Function judgeFileExist:Order_Local Kind:Library_Cache]) {
        localArray = [Function ReadFromFile:Order_Local WithKind:Library_Cache];
    }
    if (!localArray.count) {
        localArray = [NSMutableArray array];
    }

    for (int i = 0; i < localArray.count; i++) {
        NSDictionary* dic = [localArray objectAtIndex:i];
        NSString* tempIndexNumber1 = [dic objectForKey:@"tempIndexNumber_order"];
        if (self.convertNumber.length) {
            if ([self.convertNumber isEqualToString:tempIndexNumber1]) {
                [localArray removeObjectAtIndex:i];
            }
        }
    }

    [localArray addObject:tempDic];
    NSString* str1 =
        [Function achieveThe_filepath:Order_Local
                                 Kind:Library_Cache];
    [Function Delete_TotalFileFromPath:str1];
    [Function creatTheFile:Order_Local Kind:Library_Cache];
    [Function WriteToFile:Order_Local File:localArray Kind:Library_Cache];

    [self.navigationController
        popToViewController:[self.navigationController.viewControllers
                                objectAtIndex:2]
                   animated:YES];
}

- (void)saveRDataToLocal
{
    NSString* dateString = [Function getSystemTimeNow];
    NSMutableDictionary* tempDic = [NSMutableDictionary dictionary];
    [self NSMutableDictionary:tempDic
                    SetObject:[AddProduct sharedInstance].arr_AddToList
                       forKey:@"AddProduct"];
    [self NSMutableDictionary:tempDic
                    SetObject:array_Dynamic
                       forKey:@"array_Dynamic"];
    [self NSMutableDictionary:tempDic
                    SetObject:self.str_cindex_no
                       forKey:@"cindex_no"];
    [self NSMutableDictionary:tempDic
                    SetObject:self.str_should_Accounts
                       forKey:@"osum"];
    [self NSMutableDictionary:tempDic
                    SetObject:self.str_real_Accounts
                       forKey:@"orsum"];
    [self NSMutableDictionary:tempDic
                    SetObject:self.str_disCount
                       forKey:@"odiscount"];
    [self NSMutableDictionary:tempDic
                    SetObject:self.str_isInstead
                       forKey:@"ctc_sts"];
    [self NSMutableDictionary:tempDic
                    SetObject:self.terminalName
                       forKey:@"terminal"];
    [tempDic setObject:@"0" forKey:@"exe_sts"];
    [tempDic setObject:dateString forKey:@"ins_date"];

    if (![Function StringIsNotEmpty:self.convertNumber]) {
        NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
        tempIndexNumber = [defaults objectForKey:@"tempIndexNumber_Rorder"];
        if (tempIndexNumber.length) {
            tempIndexNumber =
                [NSString stringWithFormat:@"%ld", tempIndexNumber.integerValue + 1];
        }
        else {
            tempIndexNumber = @"1";
        }
        [defaults setObject:tempIndexNumber forKey:@"tempIndexNumber_Rorder"];
        [defaults synchronize];
    }
    else {
        tempIndexNumber = [NSString stringWithFormat:@"%@", self.convertNumber];
    }

    NSMutableDictionary* mutDic = [NSMutableDictionary dictionary];
    for (NSInteger i = 0; i < array_Dynamic.count; i++) {
        NSDictionary* dic = [array_Dynamic objectAtIndex:i];
        UITextField* text =
            [arr_tex objectAtIndex:[[dic objectForKey:@"tag"] integerValue]];
        NSString* keyStr = [NSString stringWithFormat:@"%ld", (long)i];
        [mutDic setObject:text.text forKey:keyStr];
    }

    [tempDic setObject:mutDic forKey:@"mutDic"];

    NSMutableArray* tempImageArray = [NSMutableArray array];
    for (int i = 0; i < arr_Media_image.count; i++) {
        NSDictionary* tempDic1 = [arr_Media_image objectAtIndex:i];
        NSMutableDictionary* mutDic = [NSMutableDictionary dictionary];
        [self NSMutableDictionary:mutDic
                        SetObject:[tempDic1 objectForKey:@"is_addimg"]
                           forKey:@"is_addimg"];
        [self NSMutableDictionary:mutDic
                        SetObject:[tempDic1 objectForKey:@"isme"]
                           forKey:@"isme"];
        [self NSMutableDictionary:mutDic
                        SetObject:[tempDic1 objectForKey:@"re_take"]
                           forKey:@"re_take"];
        [self NSMutableDictionary:mutDic
                        SetObject:[tempDic1 objectForKey:@"required"]
                           forKey:@"required"];
        [self NSMutableDictionary:mutDic
                        SetObject:[tempDic1 objectForKey:@"mtype"]
                           forKey:@"mtype"];
        [self NSMutableDictionary:mutDic
                        SetObject:[tempDic1 objectForKey:@"clabel"]
                           forKey:@"clabel"];
        [self NSMutableDictionary:mutDic
                        SetObject:[tempDic1 objectForKey:@"imageData"]
                           forKey:@"imageData"];
        [tempImageArray addObject:mutDic];
    }

    if (tempImageArray.count) {
        [tempDic setObject:tempImageArray forKey:@"arr_Media_image"];
    }

    [tempDic setObject:tempIndexNumber forKey:@"tempIndexNumber_Rorder"];
    NSMutableArray* localArray = nil;
    if ([Function judgeFileExist:ROrder_Local Kind:Library_Cache]) {
        localArray = [Function ReadFromFile:ROrder_Local WithKind:Library_Cache];
    }
    if (!localArray.count) {
        localArray = [NSMutableArray array];
    }

    for (int i = 0; i < localArray.count; i++) {
        NSDictionary* dic = [localArray objectAtIndex:i];
        NSString* tempIndexNumber1 = [dic objectForKey:@"tempIndexNumber_Rorder"];
        if (self.convertNumber.length) {
            if ([self.convertNumber isEqualToString:tempIndexNumber1]) {
                [localArray removeObjectAtIndex:i];
            }
        }
    }

    [localArray addObject:tempDic];
    NSString* str1 =
        [Function achieveThe_filepath:ROrder_Local
                                 Kind:Library_Cache];
    [Function Delete_TotalFileFromPath:str1];
    [Function creatTheFile:ROrder_Local Kind:Library_Cache];
    [Function WriteToFile:ROrder_Local File:localArray Kind:Library_Cache];

    [self.navigationController
        popToViewController:[self.navigationController.viewControllers
                                objectAtIndex:2]
                   animated:YES];
}

- (void)NSMutableDictionary:(NSMutableDictionary*)dic
                  SetObject:(id)object
                     forKey:(NSString*)keyStr
{
    if ([object isKindOfClass:[NSMutableArray class]]) {
        NSMutableArray* tempArray = (NSMutableArray*)object;
        if (tempArray.count) {
            [dic setObject:tempArray forKey:keyStr];
        }
    }
    else if ([object isKindOfClass:[NSString class]]) {
        NSString* tempStr = (NSString*)object;
        if ([Function StringIsNotEmpty:tempStr]) {
            [dic setObject:tempStr forKey:keyStr];
        }
    }
    else if ([object isKindOfClass:[NSData class]]) {
        NSData* tempData = (NSData*)object;
        if (tempData.length) {
            [dic setObject:tempData forKey:keyStr];
        }
    }
}

- (void)deleteData
{
    if (self.RDFlag) {
        [self deleteLocalIndexRData];
    }
    else {
        [self deleteLocalIndexData];
    }
}

// delete local data
- (void)deleteLocalIndexData
{
    if ([Function judgeFileExist:Order_Local Kind:Library_Cache]) {
        NSMutableArray* customerLArray =
            [Function ReadFromFile:Order_Local
                          WithKind:Library_Cache];
        for (int i = 0; i < customerLArray.count; i++) {
            NSString* tempIndexNumber1 = [[customerLArray objectAtIndex:i]
                objectForKey:@"tempIndexNumber_order"];
            if (tempIndexNumber1.length) {
                if ([tempIndexNumber1 isEqualToString:self.convertNumber]) {
                    [customerLArray removeObjectAtIndex:i];
                    NSString* str1 =
                        [Function achieveThe_filepath:Order_Local
                                                 Kind:Library_Cache];
                    [Function Delete_TotalFileFromPath:str1];
                    [Function creatTheFile:Order_Local Kind:Library_Cache];
                    [Function WriteToFile:Order_Local
                                     File:customerLArray
                                     Kind:Library_Cache];
                }
            }
        }
    }
    app.order_refresh = 1;
    [self.navigationController
        popToViewController:[self.navigationController.viewControllers
                                objectAtIndex:2]
                   animated:YES];
}

// delete local data
- (void)deleteLocalIndexRData
{
    if ([Function judgeFileExist:ROrder_Local Kind:Library_Cache]) {
        NSMutableArray* customerLArray =
            [Function ReadFromFile:ROrder_Local
                          WithKind:Library_Cache];
        for (int i = 0; i < customerLArray.count; i++) {
            NSString* tempIndexNumber1 = [[customerLArray objectAtIndex:i]
                objectForKey:@"tempIndexNumber_Rorder"];
            if (tempIndexNumber1.length) {
                if ([tempIndexNumber1 isEqualToString:self.convertNumber]) {
                    [customerLArray removeObjectAtIndex:i];
                    NSString* str1 =
                        [Function achieveThe_filepath:ROrder_Local
                                                 Kind:Library_Cache];
                    [Function Delete_TotalFileFromPath:str1];
                    [Function creatTheFile:ROrder_Local Kind:Library_Cache];
                    [Function WriteToFile:ROrder_Local
                                     File:customerLArray
                                     Kind:Library_Cache];
                }
            }
        }
    }
    app.order_refresh = 1;
    [self.navigationController
        popToViewController:[self.navigationController.viewControllers
                                objectAtIndex:2]
                   animated:YES];
}

@end
