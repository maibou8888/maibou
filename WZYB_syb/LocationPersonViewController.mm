//
//  LocationPersonViewController.m
//  WZYB_syb
//
//  Created by wzyb on 14-6-27.
//  Copyright (c) 2014年 WZYB. All rights reserved.
//

#import "LocationPersonViewController.h"
#import "AppDelegate.h"
#import "SGInfoAlert.h"
@interface LocationPersonViewController ()<ASIHTTPRequestDelegate>
{
    AppDelegate *app;
    NSString *urlString1;
}
@end

@implementation LocationPersonViewController

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
    [self Set_SegmentView];
    isPointsOrList=NO;//列表
    distance=[[[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"GpsDistance"]floatValue];
}
-(void)viewWillAppear:(BOOL)animated
{
    
    app.str_Date=[Function getYearMonthDay_Now];
    [self getHistory:app.str_Date Index_no:app.str_index_no];
    [self Creat_mapView];
}
-(void)All_Init
{
    app=(AppDelegate *)[[UIApplication sharedApplication]delegate];
    if(StatusBar_System>0)
        moment_status=20;
    else moment_status=0;
    //处理导航start
    NavView *nav_View=[[NavView alloc]init];
    [self.view addSubview: [nav_View NavView_Title1:@""]];
    
    //初始化地图
    mapView = [[BMKMapView alloc]init ];
    mapView.frame=CGRectMake(0,moment_status+44, Phone_Weight, Phone_Height-(moment_status+44));
    [self.view addSubview:mapView];
    tableView =[[UITableView alloc]initWithFrame:CGRectMake(0, 44+moment_status, Phone_Weight, Phone_Height-44-moment_status)];
    tableView .dataSource=self;
    tableView .delegate=self;
    tableView.separatorStyle=UITableViewCellSeparatorStyleNone;
    [self.view addSubview:tableView];
    pickerView = [[RBCustomDatePickerView  alloc] init];
    
    imageView_Face=[[UIImageView alloc]init];
    imageView_Face=[NavView Show_Nothing_Face];
}
-(void)Creat_TableView
{
    [self.view addSubview:tableView];
    [tableView reloadData];
}
-(void)Creat_mapView
{
    [self.view addSubview:mapView];
    mapView.delegate=self;//必要
    mapView.zoomLevel=BaiduMap_level;
    mapView.showsUserLocation = NO;
    mapView.userTrackingMode = BMKUserTrackingModeFollow;
    mapView.showsUserLocation = YES;
}
-(void)creat_TheRed_X:(float)x Y:(float)y location:(NSString *)title Address :(NSString *)subtitle
{
    //添加火柴头
    BMKPointAnnotation* annotation = [[BMKPointAnnotation alloc]init];
    CLLocationCoordinate2D coor;
    coor.latitude = x;
    coor.longitude = y;
    annotation.coordinate = coor;
    annotation.title = title;
    annotation.subtitle=subtitle;
    [mapView addAnnotation:annotation];
    annotation=nil;
}
-(void)connect_line_X1:(float)x1 Y1:(float)y1 X2:(float)x2 Y2:(float)y2
{
    CLLocationCoordinate2D coor1;
	coor1.latitude = x1;
	coor1.longitude = y1;
    BMKMapPoint pt1 = BMKMapPointForCoordinate(coor1);
    CLLocationCoordinate2D coor2;
	coor2.latitude = x2;
	coor2.longitude = y2;
    BMKMapPoint pt2 = BMKMapPointForCoordinate(coor2);
    BMKMapPoint * temppoints = new BMKMapPoint[2];
    temppoints[0].x = pt2.x;
    temppoints[0].y = pt2.y;
    temppoints[1].x = pt1.x;
    temppoints[1].y = pt1.y;
    CustomOverlay* custom =[[CustomOverlay alloc] initWithPoints:temppoints count:2] ;
	[mapView addOverlay:custom];
    temppoints=nil;
    custom=nil;
}
-(void)viewWillDisappear:(BOOL)animated {
    [mapView viewWillDisappear];
    mapView.delegate = nil; // 不用时，置nil
}

//根据overlay生成对应的View
- (BMKOverlayView *)mapView:(BMKMapView *)mapView viewForOverlay:(id <BMKOverlay>)overlay
{
    if ([overlay isKindOfClass:[CustomOverlay class]])
    {
        CustomOverlayView* cutomView = [[CustomOverlayView alloc] initWithOverlay:overlay]  ;
        cutomView.strokeColor = [[UIColor blueColor] colorWithAlphaComponent:10];
       // cutomView.fillColor = [[UIColor purpleColor] colorWithAlphaComponent:0.5];
        cutomView.lineWidth = 2.0;
        return cutomView;
    }
    if ([overlay isKindOfClass:[BMKCircle class]])
    {
        BMKCircleView* circleView = [[BMKCircleView alloc] initWithOverlay:overlay] ;
        circleView.fillColor = [[UIColor cyanColor] colorWithAlphaComponent:0.2];
        circleView.strokeColor = [[UIColor blueColor] colorWithAlphaComponent:0.2];
        circleView.lineWidth = 2.0;
        return circleView;
    }
    return nil;
}
- (BMKAnnotationView *)mapView:(BMKMapView *)mapView viewForAnnotation:(id <BMKAnnotation>)annotation
{
    if ([annotation isKindOfClass:[BMKPointAnnotation class]] ) {
        
        
        
        
        BMKPinAnnotationView *newAnnotationView = [[BMKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"myAnnotation"];
        newAnnotationView.annotation=annotation;
        [newAnnotationView setDraggable:NO];//允许用户拖动
        newAnnotationView.animatesDrop = NO;// 设置该标注点动画显示
        /******/
        if(isRealPaoPao)
        {
            UIView *popView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 180, 150)];
            popView.backgroundColor=[UIColor clearColor];
            //设置弹出气泡图片
            UIImageView *image = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"bg_paopao@2X.png"]];
            image.frame = CGRectMake(0, -10, 190, 170);
            [popView addSubview:image];
            [popView addSubview: newAnnotationView.paopaoView];
            //自定义显示的内容
            UITextView *driverName = [[UITextView alloc]initWithFrame:CGRectMake(0, 10, 190, 120)];
            driverName.editable=NO;
            driverName.text = annotation.subtitle;
            //Dlog(@"%@",annotation.subtitle);
            driverName.backgroundColor = [UIColor clearColor];
            driverName.font = [UIFont systemFontOfSize:14];
            driverName.textColor = [UIColor blackColor];
            [popView addSubview:driverName];
            
            BMKActionPaopaoView *pView = [[BMKActionPaopaoView alloc]initWithCustomView:popView];
            pView.frame = CGRectMake(0, 0, 180, 150);
            newAnnotationView.paopaoView=pView;
        }
        else
        {
             newAnnotationView.image = [UIImage imageNamed:@"terminal@2X.png"];   //把大头针换成别的图片
        }
        return newAnnotationView;
    }

    return nil;
}
- (void)mapView:(BMKMapView *)mapView didSelectAnnotationView:(BMKAnnotationView *)view
{
}

-(void)Set_SegmentView
{
    for(NSInteger i=0;i<5;i++)
    {
        UIButton *btn=[UIButton buttonWithType:UIButtonTypeCustom];
        btn.backgroundColor=[UIColor clearColor];
        if(i==0)//返回
        {
            btn.frame=CGRectMake(0, moment_status, 60, 44);
            [btn setBackgroundImage:[UIImage imageNamed:@"btn_color6.png"] forState:UIControlStateHighlighted];
            [btn setTitle:@"< 返回" forState:UIControlStateNormal];
            [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            btn.titleLabel.font=[UIFont systemFontOfSize:15];
        }
        else if(i==1)//日历
        {
            btn.frame=CGRectMake(Phone_Weight-50, moment_status, 44, 44);
            [btn setTitle:@"日期" forState:UIControlStateNormal];
            btn.titleLabel.font=[UIFont systemFontOfSize:15];
        }
        else if(i>1)
        {
            if(i==2)//寻访列表
            {
                [btn setImage:[UIImage imageNamed:@"switch2.png"] forState:UIControlStateNormal];
                btn.frame=CGRectMake(Phone_Weight/2-82, moment_status+(44-34)/2, 82, 34);
                btn_list=btn;
            }
            else if(i==3)//轨迹回放
            {
                btn.frame=CGRectMake(Phone_Weight/2, moment_status+(44-34)/2, 82, 34);
                [btn setImage:[UIImage imageNamed:@"switch3.png"] forState:UIControlStateNormal];
                btn_graph=btn;
            }
        }
        btn.tag=buttonTag+i;
        [btn addTarget:self action:@selector(btn_Action:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:btn];
    }
}
-(void)btn_Action:(id)sender
{
    UIButton *btn=(UIButton *)sender;
    if(btn.tag==buttonTag)//返回
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
    else if(btn.tag==buttonTag+1)//日历
    {
        if(!isOpenDate)
        {
            isOpenDate=YES;
            [self select_Date];
        }
    }
    else if(btn.tag==buttonTag+2)//巡访列表
    {
        //Dlog(@"巡访列表");
        isPointsOrList=NO;
        [btn_list setImage:[UIImage imageNamed:@"switch2.png"] forState:UIControlStateNormal];
        [btn_graph setImage:[UIImage imageNamed:@"switch3.png"] forState:UIControlStateNormal];
        if(isOpenDate)
        {
            isOpenDate=NO;
            [view_back removeFromSuperview];
        }
        [self getHistory:app.str_Date Index_no:app.str_index_no];
    }
    else if(btn.tag==buttonTag+3)//轨迹回放
    {
        //Dlog(@"轨迹回放");
        isPointsOrList=YES;
        [btn_list setImage:[UIImage imageNamed:@"switch1.png"] forState:UIControlStateNormal];
        [btn_graph setImage:[UIImage imageNamed:@"switch4.png"] forState:UIControlStateNormal];
        if(isOpenDate)
        {
            isOpenDate=NO;
            [view_back removeFromSuperview];
        }
        [tableView removeFromSuperview];
        [self getHistory:app.str_Date Index_no:app.str_index_no];
    }
    else if(btn.tag==buttonTag +4)//选择部门员工
    {
        [self To_LocationViewController];
    }
    else if(btn.tag==buttonTag*2+2)
    {
        //Dlog(@"取消");
        [view_back removeFromSuperview];
        isOpenDate=NO;
    }
    else if(btn.tag==buttonTag*2+3)
    {
        //Dlog(@"确定");
        isOpenDate=NO;
        [view_back removeFromSuperview];
        if(app.isDateLegal)
        {
            //Dlog(@"========%@=========",app.str_Date);
            if(![Function isBlankString:app.str_index_no])
            {
                
                  [self getHistory:app.str_Date Index_no:app.str_index_no];
            }
            else
            {
                [self GoTo_workers];
            }
        }
        isOpenDate=NO;
    }
}
-(void)To_LocationViewController
{
    LocationViewController *loc=[[LocationViewController alloc]init];
    loc.str_from=@"1";
    [self.navigationController pushViewController:loc animated:YES];
}
-(void)GoTo_workers
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                    message:@"去选择员工,才能查看轨迹"
                                                   delegate:self
                                          cancelButtonTitle:@"不去"
                                          otherButtonTitles:@"这就去", nil];
    [alert show];
}
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex==1)
    {
        [self To_LocationViewController];
    }
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectio
{
    if(arr_HistoryList.count==0)
    {
        [self.view addSubview:imageView_Face];
    }
    else
    {
        [imageView_Face removeFromSuperview];
    }
    return arr_HistoryList.count;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(isPad)
        return 100;
    return 120;
}
- (UITableViewCell *)tableView:(UITableView *)tableView1 cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    VisitCell *cell=(VisitCell*)[tableView1 dequeueReusableCellWithIdentifier:@"VisitCell"];
    if(cell==nil)
    {
        NSArray *nib ;
        nib= [[NSBundle mainBundle] loadNibNamed:@"VisitCell" owner:[VisitCell class] options:nil];
        
        cell = (VisitCell *)[nib objectAtIndex:0];
        cell.contentView.backgroundColor = [UIColor whiteColor];
    }
    NSDictionary *dic=[arr_HistoryList objectAtIndex:indexPath.row];
    
    cell.label_CompanyName.text=[dic objectForKey:@"gname"];
    cell.label_during.text=[dic objectForKey:@"access_time"];
    cell.label_SignUp_time.text=[dic objectForKey:@"access_start_date"];
    cell.label_SignOut_time.text=[dic objectForKey:@"access_end_date"];
        
    //cell.label_workStatus.text=[self return_signUpStatus:[dic objectForKey:@"gps_result"]];
    cell.imageView_status.image=[UIImage imageNamed:[NSString stringWithFormat:@"%@.png",[self return_signUpStatus:[dic objectForKey:@"gps_result"]]]];
    cell.selectionStyle=UITableViewCellSelectionStyleNone;//无点击效果
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([Function isConnectionAvailable])
    {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.mode = MBProgressHUDModeIndeterminate;
        hud.labelText = @"加载中...";//加载提示语言
        
        if(app.isPortal)
        {
            urlString1=[NSString stringWithFormat:@"%@%@",KPORTAL_URL,KGet_matter];
        }
        else
        {
            urlString1=[NSString stringWithFormat:@"%@%@",kBASEURL,KGet_matter];
        }
        NSURL *url = [ NSURL URLWithString : urlString1];
        ASIFormDataRequest *request = [ ASIFormDataRequest requestWithURL :url];
        request.delegate = self;
        request.tag = 104;
        [request setRequestMethod:@"POST"];
        [request setPostValue:[[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"account"]forKey:KUSER_UID];
        [request setPostValue:[[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"secret"] forKey:KUSER_PASSWORD];
        [request setPostValue:[[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"token"] forKey:@"user.token"];
        [request setPostValue:[[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"db_ip"] forKey:@"db_ip"];
        [request setPostValue:[[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"db_name"] forKey:@"db_name"];
        
        NSDictionary *dic=[arr_HistoryList objectAtIndex:indexPath.row];
        [request setPostValue:@"1" forKey:@"item.stype"];
        [request setPostValue:[dic objectForKey:@"index_no"] forKey:@"item.index_no"];
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
-(NSString*)return_signUpStatus:(NSString *)str
{
    if([str isEqualToString:@"-1"])
    {
        return @"cell_sign-1";
    }
    else if([str isEqualToString:@"1"])
    {
        return @"cell_sign1";
    }
    else if([str isEqualToString:@"2"])
    {
        return @"cell_sign2";
    }
    else if([str isEqualToString:@"3"])
    {
        return @"cell_sign3";
    }
    else //0
    {
        return @"cell_sign0";
    }
}
-(NSString*)return_signUpStatus1:(NSString *)str
{
    if([str isEqualToString:@"-1"])
    {
        return @"没有坐标";
    }
    else if([str isEqualToString:@"1"])
    {
        return @"到达已签到";
    }
    else if([str isEqualToString:@"2"])
    {
        return @"签到未签退";
    }
    else if([str isEqualToString:@"3"])
    {
        return @"签到成功";
    }
    else //0
    {
        return @"疑似地址不匹配";
    }
}
-(NSString *)Setting_URL:(NSString *)url
{
    NSString *string;
    if(!isPointsOrList)
    {//list
        string=[NSString stringWithFormat:@"%@%@",url,KHistoryList];
    }
    else
    {
        string=[NSString stringWithFormat:@"%@%@",url,KHistory];
    }
    return string;
}
//判断是不是纯数字
-(void)getHistory:(NSString *)str_date1 Index_no:(NSString *)index_no
{
    if([Function isConnectionAvailable])
    {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.mode = MBProgressHUDModeIndeterminate;
        hud.labelText = @"加载中...";//加载提示语言
        if(app.isPortal)
        {
            self.urlString=[self Setting_URL:KPORTAL_URL];
        }
        else
        {
            self.urlString=[self Setting_URL:kBASEURL];
        }
        NSURL *url = [ NSURL URLWithString :  self.urlString];
        ASIFormDataRequest *request = [ ASIFormDataRequest requestWithURL :url];
        request.delegate = self;
        [request setPostValue:[[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"account"]forKey:KUSER_UID];
        [request setPostValue:[[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"secret"] forKey:KUSER_PASSWORD];
        [request setPostValue:[[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"token"] forKey:@"user.token"];
        [request setPostValue:[[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"db_ip"] forKey:@"db_ip"];
        [request setPostValue:[[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"db_name"] forKey:@"db_name"];
        
        
        
        [request setPostValue:index_no forKey:@"user_index_no"];
        [request setPostValue: str_date1 forKey:@"access_start_date"];
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
        if(isPointsOrList)
        {
            arr_HistoryList_Data=[dict objectForKey:@"History"];
            NSArray *arr=[NSArray arrayWithArray:mapView.annotations];
            [mapView removeAnnotations:arr];
            NSArray *arr_overlay=[NSArray arrayWithArray:mapView.overlays];
            [mapView removeOverlays:arr_overlay];
            [imageView_Face removeFromSuperview];
            if(arr_HistoryList_Data.count==0)
            {
                [self mentionView];
              //  mapView.hidden=YES;
                return;
            }
            //mapView.hidden=NO;
            
            [self connectPoint];
        }
        else
        {
            arr_HistoryList=[dict objectForKey:@"HistoryList"];
            if(arr_HistoryList.count==0)
            {
                [self mentionView];
            }
            [self Creat_TableView];
           
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
-(void)mentionView
{
    [SGInfoAlert showInfo:[NSString stringWithFormat:@"%@ 无数据",app.str_Date]
                  bgColor:[[UIColor darkGrayColor] CGColor]
                   inView:self.view
                 vertical:0.5];
}


-(void)connectPoint
{
    for(NSInteger i=0;i<arr_HistoryList_Data.count;i++)
    {
        NSDictionary *dic_fa=[arr_HistoryList_Data objectAtIndex:i];
        
        
        //实际签到坐标
        NSString *str1=[dic_fa objectForKey:@"alat"];
        NSString *str2=[dic_fa objectForKey:@"alng"];
        //终端坐标
        NSString *str3=[dic_fa objectForKey:@"glat"];
        NSString *str4=[dic_fa objectForKey:@"glng"];
        if(i==arr_HistoryList.count/2)
        {
            CLLocationCoordinate2D coor;
            coor.latitude = [str3 floatValue];
            coor.longitude =[str4 floatValue];
            mapView.centerCoordinate=coor;
        }
        NSString *str_address=@"";
        if(![Function isBlankString:[dic_fa objectForKey:@"gname"]])
        {
            str_address=[dic_fa objectForKey:@"gname"];
        }
        //创建终端坐标火柴头
        [self creat_TheRed_X:[str3 floatValue] Y:[str4 floatValue] location:[NSString stringWithFormat:@"%@(NO.%ld)",str_address,i+1] Address:nil ];
        isRealPaoPao=YES;
        //创建实际签到坐标火柴头
        str_address=@"";//终端名 不要地址
        if(![Function isBlankString:[dic_fa objectForKey:@"gname"]])
        {
            str_address=[dic_fa objectForKey:@"gname"];
        }
        NSString *str_access_start_date=@"";
        NSString *str_access_time=@"";
        if(![Function isBlankString:[dic_fa objectForKey:@"access_start_date"]])
        {
            str_access_start_date=[dic_fa objectForKey:@"access_start_date"];
        }
        if(![Function isBlankString:[dic_fa objectForKey:@"access_time"]])
        {
            str_access_time=[NSString stringWithFormat:@"(%@)",[dic_fa objectForKey:@"access_time"]];
        }
        NSString *str_adist=@"";
        if(![Function isBlankString:[dic_fa objectForKey:@"adist"]])
        {
            str_adist=[NSString stringWithFormat:@"大约%@米",[dic_fa objectForKey:@"adist"]];
        }
        NSString *str_odist=@"";
        if(![Function isBlankString:[dic_fa objectForKey:@"odist"]])
        {
            str_odist=[NSString stringWithFormat:@"大约%@米",[dic_fa objectForKey:@"odist"]];
        }
        [self creat_TheRed_X:[str1 floatValue] Y:[str2 floatValue] location:nil Address:[NSString stringWithFormat:@"目的地:%@\n到达时间:%@ %@\n签到状态:%@\n签到偏差:%@\n签退偏差:%@\n",[dic_fa objectForKey:@"gname"],str_access_start_date,str_access_time,[self return_signUpStatus1:[dic_fa objectForKey:@"gps_result"]],str_adist,str_odist]];
        isRealPaoPao=NO;
        

        
        //给终端添加圆形覆盖物
        BMKCircle* circle;
        CLLocationCoordinate2D coor1;
        coor1.latitude =[str3 doubleValue];
        coor1.longitude = [str4 doubleValue];
        circle = [BMKCircle circleWithCenterCoordinate:coor1 radius: distance];
        [mapView addOverlay:circle];
        //实际运动轨迹
        if(i+1<arr_HistoryList_Data.count)
        {
            NSDictionary *dic_kid=[arr_HistoryList_Data objectAtIndex:i+1];
            [self connect_line_X1:[str1 floatValue] Y1:[str2 floatValue] X2:[[dic_kid objectForKey:@"alat"]floatValue] Y2:[[dic_kid objectForKey:@"alng"]floatValue]];
             dic_kid=nil;
        }
        dic_fa=nil;
    }
}

-(void)select_Date
{
    view_back=[[UIView alloc]initWithFrame:CGRectMake(0, moment_status+44, Phone_Weight, Phone_Height-moment_status-44)];
    view_back.backgroundColor=[UIColor colorWithRed:193/255.0 green:193/255.0 blue:193/255.0 alpha:0.6];
    [self.view addSubview:view_back];
    pickerView.frame= CGRectMake((Phone_Weight-278.5)/2, (view_back.frame.size.height-(190+54*2)-49)/2, 278.5, 54+190.0);
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
        label_btn=nil;
    }
}

-(void)requestFinished:(ASIHTTPRequest *)request {
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    if([request responseStatusCode]==200)
    {
        if (request.tag == 104) {
            NSString * jsonString  =  [request responseString];
            SBJsonParser *parser = [[SBJsonParser alloc] init];
            NSDictionary *dict =[parser objectWithString: jsonString];
            OrderListDynamic *order=[[OrderListDynamic alloc]init];
            order.fromSign = 1;
            order.dic_json=dict;
            order.isDetail=YES;
            order.titleString = @"附加信息";
            [self.navigationController pushViewController:order animated:YES];
            return;
        }
        NSString * jsonString  =  [request responseString];
        [self get_JsonString:jsonString];
    }else{
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
    
    // 请求响应失败，返回错误信息
    //Dlog(@"HTTP 响应码：%d",[request responseStatusCode]);
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}
@end
