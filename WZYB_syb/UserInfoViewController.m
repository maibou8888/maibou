//
//  UserInfoViewController.m
//  WZYB_syb
//
//  Created by wzyb on 15-3-9.
//  Copyright (c) 2015年 WZYB. All rights reserved.
//

#import "UserInfoViewController.h"
#import "PersonIDCell.h"
#import "NormalCell.h"
#import "UserInfoCell.h"
#import "AppDelegate.h"
#import "UIImageView+WebCache.h"
#import "KGModal.h"
#import <QuartzCore/QuartzCore.h>
#import "PresentView.h"
#import "MRZoomScrollView.h"

@interface UserInfoViewController ()<UITableViewDelegate,UITableViewDataSource,UIActionSheetDelegate,UINavigationControllerDelegate, UIImagePickerControllerDelegate,PresentViewDelegate>
{
    AppDelegate *app;
    UITableView  *myTableView;
    NSString *urlString;
    NSMutableArray *LabelArray;     //静态部分label数组
    NSMutableArray *httpData;       //静态部分从服务器获取的数据
    NSArray *keyArray;              //静态部分从服务器取值时对应的Key
    NSMutableArray *Label1Array;    //动态部分的数据
    NSMutableArray *Label2Array;    //media动态部分的数据
    NSMutableDictionary *btnDic;    //存储button的Dic
    NSMutableDictionary *ImgDic;    //存储buttonImage的Dic
    NSMutableDictionary *dataDic;   //存储imageData的Dic
    BOOL isCamera;                  //如果是拍照  YES
    NSString * cellButtonIndex;     //获取cell上面的button的tag值
    NSInteger selectTable;          //判断是否点击过tableView
    NSInteger takeIndexPathRow;     //点击之后拿到当前的indexPath.row
    NSInteger indexPathSection;     //判断当前点击的是否为第一个section
    NSString *iconURLStr;
    NSString *iconStr_big;
    CGRect oldframe;
    UIView *backgroundView;
    NSMutableDictionary *imageURLDic;
    UIView *view_imageView_back;
}
@property (nonatomic, retain) MRZoomScrollView  *zoomScrollView;
@property (strong, nonatomic) IBOutlet UIView *sectionView;     //顶部的View
@property (strong, nonatomic) IBOutlet UIView *sectionView1;    //底部的View
@property (weak, nonatomic) IBOutlet UIButton *submitBtn;       //底部的提交按键
- (IBAction)pressSibmitButton:(id)sender;

@end

@implementation UserInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initSubView];
    [self.view addSubview: [nav_View NavView_Title1:@"个人资料"]];
    app=(AppDelegate *)[[UIApplication sharedApplication]delegate];
    if (isIOS6) {
        self.sectionView1.backgroundColor = [UIColor clearColor];
        self.submitBtn.backgroundColor = [UIColor clearColor];
        [self.submitBtn setTitleColor:[UIColor colorWithRed:34/255.0 green:127/255.0 blue:187/255.0 alpha:1]
                             forState:UIControlStateNormal];
    }

    [self addReturnBtn];
    [self getUserInformation];
}

-(void)viewWillAppear:(BOOL)animated {
    //判断当前是否点击了tableView并且section==0
    if (selectTable && (indexPathSection == 0)) {
        selectTable = 0;
        indexPathSection = 100;
        if (app.str_temporary.length) {
            [httpData replaceObjectAtIndex:takeIndexPathRow withObject:app.str_temporary];
        }
        [myTableView reloadData];
    }
}

#pragma mark ---- custom Action method
- (void)initSubView {
    myTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 78, 320, Phone_Height-78) style:UITableViewStyleGrouped];
    if (isIOS6) {
        myTableView.top+=20;
    }
    [self.view addSubview:myTableView];
    if (isIOS7) {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    self.sectionView.frame = CGRectMake(0, 64, 320, 53);
    if (isIOS6) {
        self.sectionView.top = 44;
    }
    [self.view addSubview:self.sectionView];
    
    //设置形状
    [self.submitBtn.layer setMasksToBounds:YES];
    [self.submitBtn.layer setCornerRadius:5.0];
    
    LabelArray = [[NSMutableArray alloc] initWithObjects:@"姓名",@"手机号",@"电子邮件",@"身份证号",@"所属部门",@"用户类型",@"主管区分",@"试用期", nil];
    keyArray   = @[@"uname",@"umtel",@"uemail",@"id_no",@"gbelongto",@"auth",@"utype"];
    httpData    = [NSMutableArray array];
    Label1Array = [NSMutableArray array];
    Label2Array = [NSMutableArray array];
    btnDic      = [NSMutableDictionary dictionary];
    ImgDic      = [NSMutableDictionary dictionary];
    dataDic     = [NSMutableDictionary dictionary];
    imageURLDic    = [NSMutableDictionary dictionary];
    isCamera = NO;
    iconURLStr = @"";
    selectTable = 0;
    takeIndexPathRow = 100;
    indexPathSection = 100;
    
    view_imageView_back=[[UIView alloc]init];
    view_imageView_back.backgroundColor=[UIColor blackColor];
    view_imageView_back.frame=CGRectMake(0, 0, Phone_Weight, Phone_Height);
}

- (void)addReturnBtn {
    UIButton *btn=[UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame=CGRectMake(0, moment_status, 60, 44);
    btn.backgroundColor=[UIColor clearColor];
    [btn setBackgroundImage:[UIImage imageNamed:@"btn_color6.png"] forState:UIControlStateHighlighted];
    [btn setTitle:@"< 返回" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    btn.titleLabel.font=[UIFont systemFontOfSize:15];
    [btn addTarget:self action:@selector(btn_Action:) forControlEvents:UIControlEventTouchUpInside ];
    [self.view addSubview:btn];
}

-(void)btn_Action:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

//设置图片
-(void)SetPicture:(id)sender {
    UIButton *tempBtn = (UIButton *)sender;
    NSString *keyStr = [NSString stringWithFormat:@"%ld",(long)tempBtn.tag];
    NSString *urlString1 = [imageURLDic objectForKey:keyStr];
    UIImage *image = [ImgDic objectForKey:keyStr];
    if (ImgDic.count && image) {
        UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
        imageView.frame = self.view.frame;
        if (image) {
            [self view_image_AllScreen:imageView];
        }
        UIButton *button = (UIButton *)sender;
        cellButtonIndex = [NSString stringWithFormat:@"%ld",button.tag];
        UIActionSheet *actionSheet =[[UIActionSheet alloc]initWithTitle:@"您想如何获取照片?" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"拍照",@"相册", nil];
        [actionSheet showInView:self.view];
    }else if (urlString1.length) {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.mode = MBProgressHUDModeIndeterminate;
        hud.labelText = @"加载中...";
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            UIImage *image = nil;
            NSURL *url = [NSURL URLWithString:[imageURLDic objectForKey:keyStr]];
            NSData *data = [NSData dataWithContentsOfURL:url];
            image = [UIImage imageWithData:data];
            
            if (image) {
                UIImageView *imageView = [[UIImageView alloc] initWithFrame:self.view.frame];
                imageView.image = image;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self view_image_AllScreen:imageView];
                    UIButton *button = (UIButton *)sender;
                    cellButtonIndex = [NSString stringWithFormat:@"%ld",button.tag];
                    [ImgDic setObject:image forKey:cellButtonIndex];
                    UIActionSheet *actionSheet =[[UIActionSheet alloc]initWithTitle:@"您想如何获取照片?" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"拍照",@"相册", nil];
                    [actionSheet showInView:self.view];
                    [MBProgressHUD hideHUDForView:self.view animated:YES];
                });
            }else {
                NSLog(@"async load error.");
                [MBProgressHUD hideHUDForView:self.view animated:YES];
            }
        });
    }else {
        UIButton *button = (UIButton *)sender;
        cellButtonIndex = [NSString stringWithFormat:@"%ld",button.tag];
        UIActionSheet *actionSheet =[[UIActionSheet alloc]initWithTitle:@"您想如何获取照片?" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"拍照",@"相册", nil];
        [actionSheet showInView:self.view];
    }
}

- (IBAction)pressSibmitButton:(id)sender {
    if([Function isConnectionAvailable])
    {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.mode = MBProgressHUDModeIndeterminate;
        hud.labelText = @"加载中...";
        if(app.isPortal&&[app.assessSearch isEqualToString:@"0"])
        {
            urlString = [NSString stringWithFormat:@"%@%@",KPORTAL_URL,UserUpdate];
        }
        else
        {
            urlString = [NSString stringWithFormat:@"%@%@",kBASEURL,UserUpdate];
        }
        
        NSURL *url = [ NSURL URLWithString:urlString];
        ASIFormDataRequest *request = [ ASIFormDataRequest requestWithURL :url];
        request.delegate = self;
        request.tag = 100;
        [request setPostValue:[[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"account"]forKey:KUSER_UID];
        [request setPostValue:[[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"secret"] forKey:KUSER_PASSWORD];
        [request setPostValue:[[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"token"] forKey:@"user.token"];
        [request setPostValue:[[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"db_ip"] forKey:@"db_ip"];
        [request setPostValue:[[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"db_name"] forKey:@"db_name"];
    
        [request setPostValue:[httpData objectAtIndex:0] forKey:@"uname"];
        [request setPostValue:[httpData objectAtIndex:2] forKey:@"uemail"];
        [request setPostValue:[httpData objectAtIndex:3] forKey:@"id_no"];
        
        if ([dataDic objectForKey:@"0"]) {
            [request setData:[dataDic objectForKey:@"0"]
                withFileName:[NSString stringWithFormat:@"T1.jpg"]
              andContentType:@"image/jpeg"
                      forKey:@"icon"];
        }
        
        if (Label2Array.count) {
            for (int i = 0; i < Label2Array.count; i ++) {
                NSString *dataKey = [NSString stringWithFormat:@"%d",20+i];
                NSDictionary *tempDic = [Label2Array objectAtIndex:i];
                if ([dataDic objectForKey:dataKey]) {
                    NSString *keyStr = [NSString stringWithFormat:@"fileList[%d].mtype",i];
                    NSString *keyStr1 = [NSString stringWithFormat:@"fileList[%d].file",i];
                    [request setPostValue:[tempDic objectForKey:@"mtype"] forKey:keyStr];
                    [request setData:[dataDic objectForKey:dataKey]
                        withFileName:[NSString stringWithFormat:@"T1.jpg"]
                      andContentType:@"image/jpeg"
                              forKey:keyStr1];
                }
            }
        }
        [request startAsynchronous ];
    }
    else
    {
        [SGInfoAlert showInfo:@"当前网络不可用，请检查网络连接"
                      bgColor:[[UIColor darkGrayColor] CGColor]
                       inView:self.view
                     vertical:0.5];
    }
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

#pragma mark ---- UIActionSheet delegate method
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
    UIImage *chosenImage = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
    NSData *imageData = [Function GetImageFromCamera:chosenImage];
    [dataDic setObject:imageData forKey:cellButtonIndex];
    [ImgDic setObject:chosenImage forKey:cellButtonIndex];
    if (btnDic.count) {
        UIButton *tempBtn = (UIButton *)[btnDic objectForKey:cellButtonIndex];
        [tempBtn setImage:[UIImage imageWithData:imageData] forState:UIControlStateNormal];
    }
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark ---- HttpDataRequest
-(void)getUserInformation
{
    if([Function isConnectionAvailable])
    {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.mode = MBProgressHUDModeIndeterminate;
        hud.labelText = @"加载中...";
        if(app.isPortal&&[app.assessSearch isEqualToString:@"0"])
        {
            urlString = [NSString stringWithFormat:@"%@%@",KPORTAL_URL,UserInfo];
        }
        else
        {
            urlString = [NSString stringWithFormat:@"%@%@",kBASEURL,UserInfo];
        }
        
        NSURL *url = [ NSURL URLWithString:urlString];
        ASIFormDataRequest *request = [ ASIFormDataRequest requestWithURL :url];
        request.delegate = self;
        [request setPostValue:[[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"account"]forKey:KUSER_UID];
        [request setPostValue:[[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"secret"] forKey:KUSER_PASSWORD];
        [request setPostValue:[[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"token"] forKey:@"user.token"];
        [request setPostValue:[[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"db_ip"] forKey:@"db_ip"];
        [request setPostValue:[[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"db_name"] forKey:@"db_name"];
        
        [request startAsynchronous ];
    }
    else
    {
        [SGInfoAlert showInfo:@"当前网络不可用，请检查网络连接"
                      bgColor:[[UIColor darkGrayColor] CGColor]
                       inView:self.view
                     vertical:0.5];
    }
}

#pragma mark ---- ASIHttpRequest method
-(void)requestFinished:(ASIHTTPRequest *)request {
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    if([request responseStatusCode]==200){
        NSString * jsonString  =  [request responseString];
        SBJsonParser *parser = [[SBJsonParser alloc] init];
        NSDictionary *dict =[parser objectWithString: jsonString];
        
        if (request.tag == 100) {
            [self.navigationController popViewControllerAnimated:YES];
            return;
        }
        //循环判断如果有数据就插入  如果没有数据就插入一个@""
        for (int i = 0; i < keyArray.count; i ++) {
            NSString *tempString = [[dict objectForKey:@"SelfInfo"] objectForKey:[keyArray objectAtIndex:i]];
            if ([Function StringIsNotEmpty:tempString]) {
                [httpData addObject:tempString];
            }else {
                [httpData addObject:@""];
            }
        }

        NSString *userApartment = [Function Calculate:@"H1" Value:[httpData objectAtIndex:4]]; 
        [httpData replaceObjectAtIndex:4 withObject:userApartment];
        NSString *userType = [Function userType:[httpData objectAtIndex:5]];
        [httpData replaceObjectAtIndex:5 withObject:userType];
        NSString *utype = [Function returnUtype:[httpData objectAtIndex:6]];
        [httpData replaceObjectAtIndex:6 withObject:utype];
        iconURLStr = [dict objectForKey:@"IconSmall"];
        iconStr_big = [dict objectForKey:@"Icon"];
        NSString *startString = [[dict objectForKey:@"SelfInfo"] objectForKey:@"ty_sdate"];
        NSString *endString = [[dict objectForKey:@"SelfInfo"] objectForKey:@"ty_edate"];
        if (![startString isEqualToString:@"0000-00-00"] && ![endString isEqualToString:@"0000-00-00"] && startString.length && endString.length) {
            NSString *duringTime = [NSString stringWithFormat:@"%@ ~ %@",startString,endString];
            [httpData addObject:duringTime];
        }else {
            [httpData addObject:@""];
        }
        Label1Array = [dict objectForKey:@"DynamicList"];
        Label2Array = [dict objectForKey:@"MediaList"];
        
        myTableView.delegate = self;
        myTableView.dataSource = self;
        [myTableView reloadData];
    }else{
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

#pragma mark ---- UITableView delegate and dataSource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return LabelArray.count;
    }else if (section == 1) {
        return Label1Array.count;
    }
    return Label2Array.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 5;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if (section == 2) {
        return 50;
    }
    return 5;
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    if (section == 2) {
        return self.sectionView1;
    }
    return nil;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *index = [NSString stringWithFormat:@"%ld",indexPath.section*10 + indexPath.row];
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            UserInfoCell *cell=(UserInfoCell*)[tableView dequeueReusableCellWithIdentifier:@"UserInfoCell"];
            if(cell==nil)
            {
                NSArray *nib ;
                nib= [[NSBundle mainBundle] loadNibNamed:@"UserInfoCell" owner:[UserInfoCell class] options:nil];
                cell = (UserInfoCell *)[nib objectAtIndex:0];
                cell.contentView.backgroundColor = [UIColor clearColor];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                if (httpData.count) {
                    cell.nameTF.text = [httpData objectAtIndex:indexPath.section*10 + indexPath.row];
                }
                cell.imageBtn.tag = indexPath.section*10+indexPath.row;
                [btnDic setObject:cell.imageBtn forKey:index];
                if (ImgDic.count) {
                    UIImage *image = [ImgDic objectForKey:index];
                    if (image) {
                        [cell.imageBtn setImage:image forState:UIControlStateNormal];
                    }else {
                        [Function setButtonimageWithURLString:iconURLStr Button:cell.imageBtn];
                    }
                }else {
                    [Function setButtonimageWithURLString:iconURLStr Button:cell.imageBtn];
                }
            });
            [imageURLDic setObject:iconStr_big forKey:index];
            [cell.imageBtn addTarget:self action:@selector(SetPicture:) forControlEvents:UIControlEventTouchUpInside];
            if (isIOS6) {
                cell.imageBtn.left-=15;
            }
            return cell;
        }
        
        NormalCell *cell=(NormalCell*)[tableView dequeueReusableCellWithIdentifier:@"NormalCell"];
        if(cell==nil)
        {
            NSArray *nib ;
            nib= [[NSBundle mainBundle] loadNibNamed:@"NormalCell" owner:[NormalCell class] options:nil];
            cell = (NormalCell *)[nib objectAtIndex:0];
            cell.contentView.backgroundColor = [UIColor clearColor];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            cell.firstlabel.text = [LabelArray objectAtIndex:indexPath.row];
            if (httpData.count) {
                cell.secondLabel.text = [httpData objectAtIndex:indexPath.row];
            }
        });
        if (isIOS6) {
            cell.secondLabel.left-=15;
        }
        
        return cell;
    }else if (indexPath.section == 1) {
        NormalCell *cell=(NormalCell*)[tableView dequeueReusableCellWithIdentifier:@"NormalCell"];
        if(cell==nil)
        {
            NSArray *nib ;
            nib= [[NSBundle mainBundle] loadNibNamed:@"NormalCell" owner:[NormalCell class] options:nil];
            cell = (NormalCell *)[nib objectAtIndex:0];
            cell.contentView.backgroundColor = [UIColor clearColor];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            NSDictionary *tempDic = [Label1Array objectAtIndex:indexPath.row];
            cell.firstlabel.text = [tempDic objectForKey:@"tname"];
            cell.secondLabel.text = [tempDic objectForKey:@"tcontent"];
        });
        if (isIOS6) {
            cell.secondLabel.left-=15;
        }
        return cell;
    }
    PersonIDCell *cell=(PersonIDCell*)[tableView dequeueReusableCellWithIdentifier:@"PersonIDCell"];
    NSDictionary *tempDic = [Label2Array objectAtIndex:indexPath.row];
    if(cell==nil)
    {
        NSArray *nib ;
        nib= [[NSBundle mainBundle] loadNibNamed:@"PersonIDCell" owner:[PersonIDCell class] options:nil];
        cell = (PersonIDCell *)[nib objectAtIndex:0];
        cell.contentView.backgroundColor = [UIColor clearColor];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (ImgDic.count) {
            UIImage *image = [ImgDic objectForKey:index];
            if (image) {
                [cell.personIDBtn setImage:image forState:UIControlStateNormal];
            }else {
                [Function setButtonimageWithURLString:[tempDic objectForKey:@"mpath_small"] Button:cell.personIDBtn];
            }
        }else {
            [Function setButtonimageWithURLString:[tempDic objectForKey:@"mpath_small"] Button:cell.personIDBtn];
        }
        
        if ([tempDic objectForKey:@"mpath"] ) {
            [imageURLDic setObject:[tempDic objectForKey:@"mpath"] forKey:index];
        }
        cell.personIDLabel.text = [tempDic objectForKey:@"clabel"];
        cell.personIDBtn.tag = indexPath.section*10 + indexPath.row;
        [btnDic setObject:cell.personIDBtn forKey:index];
    });
    
    if (isIOS6) {
        cell.personIDBtn.left-=15;
    }
    
    [cell.personIDBtn addTarget:self action:@selector(SetPicture:) forControlEvents:UIControlEventTouchUpInside];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        app.str_temporary = @"";
        selectTable = 1;
        indexPathSection = 0;
        takeIndexPathRow = indexPath.row;
        NoteViewController *noteVC=[[NoteViewController alloc]init];
        noteVC.isDetail=NO;
        if ((indexPath.row == 0) || (indexPath.row == 2) || (indexPath.row == 3)) {
            if (indexPath.row == 0) {
                UserInfoCell *cell = (UserInfoCell *)[myTableView cellForRowAtIndexPath:indexPath];
                noteVC.str_title=@"姓名";
                noteVC.str_content=cell.nameTF.text;
            }else {
                NormalCell *cell = (NormalCell *)[myTableView cellForRowAtIndexPath:indexPath];
                noteVC.str_title = cell.firstlabel.text;
                noteVC.str_content = cell.secondLabel.text;
            }
            [self.navigationController pushViewController:noteVC animated:YES];
        }
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        if ((indexPath.row == 0)) {
            return 60;
        }
        return 44;
    }else if (indexPath.section == 1) {
        return 44;
    }
    return 60;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([tableView respondsToSelector:@selector(setSeparatorInset:)]){
        [tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [tableView setLayoutMargins:UIEdgeInsetsZero]; // ios 8 newly added
    }
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

#pragma mark ---- presentView delegate method

- (void)presentViewDissmissAction {
    
    [[KGModal sharedInstance] closeAction:nil];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
