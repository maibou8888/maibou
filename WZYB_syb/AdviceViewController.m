//
//  AdviceViewController.m
//  WZYB_syb
//
//  Created by wzyb on 14-7-2.
//  Copyright (c) 2014年 WZYB. All rights reserved.
//
#import <AssetsLibrary/AssetsLibrary.h>
#import "AdviceViewController.h"
#import "AdviceViewController.h"
#import "AppDelegate.h"
#import "KGModal.h"
#import <QuartzCore/QuartzCore.h>
#import "PresentView.h"
@interface AdviceViewController ()<ASIHTTPRequestDelegate,PresentViewDelegate>
{
    AppDelegate *app;
}
@end

@implementation AdviceViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)All_Init
{
    app=(AppDelegate *)[[UIApplication sharedApplication]delegate];
    view_imgBack=[[UIView alloc]init];
    view_imgBack.frame=CGRectMake(0, 0, Phone_Weight, Phone_Height);
    view_imgBack.backgroundColor=[UIColor blackColor];
    if(StatusBar_System>0)
        moment_status=20;
    else moment_status=0;
    NavView *nav_View=[[NavView alloc]init];
    [self.view addSubview: [nav_View NavView_Title1:self.titleString]];
    for(NSInteger i=0;i<2;i++)
    {
        UIButton *btn=[UIButton buttonWithType:UIButtonTypeCustom];
        btn.backgroundColor=[UIColor clearColor];
        [btn addTarget:self action:@selector(btn_Action:) forControlEvents:UIControlEventTouchUpInside];
        [nav_View.view_Nav  addSubview:btn];
        [btn setBackgroundImage:[UIImage imageNamed:@"btn_color6.png"] forState:UIControlStateHighlighted];
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        btn.titleLabel.font=[UIFont systemFontOfSize:15];
        if(i==0)
        {
            btn.frame=CGRectMake(0, moment_status, 60, 44);
            btn.tag=buttonTag-1;
            [btn setTitle:@"< 返回" forState:UIControlStateNormal];
        }
        else if(i==1)
        {
            btn.frame=CGRectMake(Phone_Weight-44, moment_status, 44, 44);
            btn.tag=buttonTag+2;
            [btn setTitle:@"提交" forState:UIControlStateNormal];
        }
    }
    
    
    str_retype=@"0";//默认反馈类型建议
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self All_Init];
    [self creatView];
     arr_pic=[[NSMutableArray alloc]init];
}
-(void)viewWillAppear:(BOOL)animated
{
      if(isContent)
      {
          isContent=NO;
          tex_content.text=app.str_temporary;
      }
    
}
-(void)creatView
{
    scrollView.frame=CGRectMake(0, 44+moment_status, Phone_Weight,Phone_Height-44-moment_status);
    scrollView.backgroundColor=[UIColor clearColor];
    [self Row_ScrollView:scrollView Header:[UIColor colorWithRed:223/255.0 green:52/255.0 blue:46/255.0 alpha:1.0] Title:@"反馈明细" Pic:@"8" Background:@"icon_AddNewClerk_FirstTitle.png"];
    [self.view addSubview:scrollView];
    UIButton *btn_submit=[UIButton buttonWithType:UIButtonTypeCustom];
    btn_submit.frame=CGRectMake((Phone_Weight-300)/2, 205, 300, 44);
    [self Button_Describ_Scroll:scrollView Btn:btn_submit Title:@"提交" Tag:buttonTag+2 Normal:@"btn_color6.png" Highligt:@"btn_color1.png"];
    tex_content.enabled=NO;
    tex_advice.enabled=NO;
    tex_advice.textAlignment=NSTextAlignmentRight;
    tex_content.textAlignment=NSTextAlignmentRight;
    
}
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
-(void)Button_Describ_Scroll:(UIScrollView*)scroll Btn:(UIButton *)btn Title:(NSString*)title Tag:(NSInteger)tag Normal:(NSString *)pic1 Highligt:(NSString *)pic2
{
    [btn.layer setMasksToBounds:YES];
    [btn.layer setCornerRadius:5.0];//设置矩形四个圆角半径
    [btn setTitle:title forState:UIControlStateNormal];
    [btn setTitle:title forState:UIControlStateHighlighted ];
    
    btn.titleLabel.textColor=[UIColor whiteColor];
    btn.titleLabel.font=[UIFont systemFontOfSize:15];
    btn.backgroundColor=[UIColor colorWithPatternImage:[UIImage imageNamed:pic2]];
    btn.tag=tag;
    [btn setBackgroundImage:[UIImage imageNamed:pic1] forState:UIControlStateNormal];
    [btn setBackgroundImage:[UIImage imageNamed:pic2] forState:UIControlStateHighlighted];
    [btn addTarget:self action:@selector(btn_Action:) forControlEvents:UIControlEventTouchUpInside];
    [scroll addSubview:btn];
}
-(void)showPicture//显示缩略图
{
   // float  Height_pic=button_submit.frame.origin.y+button_submit.frame.size.height+20;
    float  Height_pic=270.0;
    NSInteger j=0;
    for (NSInteger i=0; i<arr_pic.count; i++)
    {
        UIImageView *imageView;
        imageView=[[UIImageView alloc]init];
        imageView.frame=CGRectMake(10+j*((scrollView.frame.size.width-40)/3.0+10),Height_pic, (scrollView.frame.size.width-40)/3.0, (scrollView.frame.size.width-40)/3.0);
        if(i==arr_pic.count)
        {
            imageView.image=[UIImage imageNamed:@"pic_create.png"];
            Height_pic+=imageView.frame.size.height+10;
          
        }
        else
        {
            imageView.image=(UIImage *)[arr_pic objectAtIndex:i];
            UIButton *btn_clear=[UIButton buttonWithType:UIButtonTypeCustom];
            btn_clear.frame=CGRectMake(0, 0, imageView.frame.size.width, imageView.frame.size.height);
            imageView.userInteractionEnabled=YES;
            [imageView addSubview:btn_clear];
            btn_clear.tag=buttonTag*2+i;
            [btn_clear addTarget:self action:@selector(photo:) forControlEvents:UIControlEventTouchUpInside];
        }
        [scrollView addSubview:imageView];
        ++j;
        
        if(i>=3&&i%3==0)
        {
            j=0;
            Height_pic+=imageView.frame.size.height+10;
        }
        imageView.userInteractionEnabled=YES;
        imageView=nil;
    }
    if(Height_pic<scrollView.frame.size.height)
    {
        Height_pic=scrollView.frame.size.height;
    }
    scrollView.contentSize=CGSizeMake(0,Height_pic+100);
}
-(void)photo:(UIButton *)btn1
{
    self.view.backgroundColor=[UIColor blackColor];
    isOpenBigPic=YES;
    button_submit.userInteractionEnabled=NO;
    UIImageView *imageview=[[UIImageView alloc]init];
    imageview.image=[arr_pic objectAtIndex:btn1.tag-200];
    imageview.frame=self.view.frame;
    ///////////可伸缩图片
    UIScrollView *scroll=[[UIScrollView alloc]init];
    scroll.frame=CGRectMake(0, 0, view_imgBack.frame.size.width, view_imgBack.frame.size.height);
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
    self.zoomScrollView.imageView.image=imageview.image;
    self.zoomScrollView.imageView.frame=[Function scaleImage:imageview.image toSize: CGRectMake(0.0, 0.0, Phone_Weight, Phone_Height)];
    
    scroll.backgroundColor=[UIColor blackColor];
    self.zoomScrollView.backgroundColor=[UIColor blackColor];
    [scroll addSubview: self.zoomScrollView];
    [view_imgBack addSubview:scroll];
    [scrollView addSubview:view_imgBack];
    ///////////可伸缩图片
    
    //识别单指点击 退出大图 start
    UITapGestureRecognizer *singleTap =[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap1:)] ;
    [singleTap setNumberOfTapsRequired:1];
    
    [self.zoomScrollView  addGestureRecognizer:singleTap];
    singleTap=nil;
    scroll=nil;
    self.zoomScrollView=nil;
    //识别单指点击 退出大图 end
    // 结束动画
    [UIView commitAnimations];

    view_imgBack.userInteractionEnabled=YES;
    imageview=nil;

}
- (void) handleSingleTap1:(UITapGestureRecognizer *) gestureRecognizer{
    //点击空白取消第一响应
    self.view.backgroundColor=[UIColor whiteColor];
    [self Cancel_pic];
}
-(void)Cancel_pic
{
    [view_imgBack removeFromSuperview];
}

-(void)btn_Action:(id)sender
{
    UIButton *btn=(UIButton *)sender;
    if(btn.tag==buttonTag-1)//返回
    {
        [self WhenBack_mention];
    }
    else if(btn.tag==buttonTag)
    {
        //Dlog(@"类型");
        isPhoto=NO;
        [self Type];
    }
    else if(btn.tag==buttonTag+1)
    {
        //Dlog(@"图片");
        isPhoto=YES;
        [self TakePhoto];
    }
    else if(btn.tag==buttonTag+2)
    {
        //Dlog(@"提交");
        [self Mention_alert];
    }
}
-(void)Mention_alert
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"提交反馈信息" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定",nil];
    [alert show];
    alert.tag=11;
    alert=nil;
}
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(alertView.tag==11)
    {
        if(buttonIndex==1)
        {
            if([Function isBlankString:tex_content.text])
            {
                [SGInfoAlert showInfo:@"请填写反馈内容"
                              bgColor:[[UIColor darkGrayColor] CGColor]
                               inView:self.view
                             vertical:0.5];
            }
            else
            {
                [self Submit_reply];
            }
        }
    }
    else  if(alertView.tag==10)
    {
        if(buttonIndex==1)
        {
            [self.navigationController popViewControllerAnimated:YES];
        }
        
    }
}
-(void)WhenBack_mention//编辑状态中 返回提示
{
    isBack=YES;
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"即将清除编辑信息,确认要返回吗" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定",nil];
    [alert show];
    alert.tag=10;
    alert=nil;
}

-(void)Type
{
    if(isPad)
    {
        UIActionSheet *actionSheet =[[UIActionSheet alloc]initWithTitle:@"选择反馈类型" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"建议",@"投诉",@"运行错误",@"取消", nil];
        [actionSheet showInView:self.view];
    }
    else
    {
        UIActionSheet *actionSheet =[[UIActionSheet alloc]initWithTitle:@"选择反馈类型" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"建议",@"投诉",@"运行错误", nil];
        [actionSheet showInView:self.view];
    }

}
#pragma TakePhoto
-(void)TakePhoto
{
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
    //Dlog(@"%ld",(long)buttonIndex);//2--->取消
    if(isPhoto)
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
        }
        else if(buttonIndex==1)
        {//图库
            isCamera=NO;
            picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        }
        [self presentViewController:picker animated:YES completion:NULL];
        
    }
    else
    {
        str_retype=[NSString stringWithFormat:@"%ld",(long)buttonIndex];
        if(buttonIndex==0)
        {
            tex_advice.text=@"建议";
        }
        else if(buttonIndex==1)
        {
            tex_advice.text=@"投诉";
        }
        else if(buttonIndex==2)
        {
            tex_advice.text=@"运行错误";
        }
    }
   
}
#pragma -mark UIImagePickerController delegate
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    chosenImage = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
    // 指定回调方法
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
    [SGInfoAlert showInfo:@" 照片添加成功! "
                  bgColor:[[UIColor darkGrayColor] CGColor]
                   inView:self.view
                 vertical:0.5];
    NavView *nav=[[NavView alloc]init];
    
    
    NSString *strAll;
    UILabel *lab_content;
    
    if(isCamera)
    {
        //保存到系统相册
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            UIImageWriteToSavedPhotosAlbum(chosenImage, self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
        });
        NSData *image_data=UIImageJPEGRepresentation( [chosenImage resize:CGSizeMake(Phone_Weight*2  , Phone_Height*2)],0.6 );
        UIImage *image_New=[UIImage imageWithData:image_data];
        //Dlog(@"1次: %luKB",image_data.length/1000);
        strAll=[NSString stringWithFormat:@"采集人:%@\n采集时间:%@\n文件生成时间:%@\n",[[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"uname"],[Function getSystemTimeNow],[Function getSystemTimeNow]];
        lab_content=[Water_Mark Label_Freedom_Content:strAll  Choose_image:image_New];
        UIImage *getImage=[Water_Mark TransFor_ChooseImage:image_New  Lab:[Water_Mark imageWithUIView:lab_content]];
        //Dlog(@"2次 %lu",UIImageJPEGRepresentation(getImage,0.6).length/1000);
        [arr_pic addObject:getImage];
        [self showPicture];
    }
    else
    {
        NSURL *assetURL = [info objectForKey:UIImagePickerControllerReferenceURL];
        ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
        [library assetForURL:assetURL
                 resultBlock:^(ALAsset *asset) {
                     NSDate* date = [asset valueForProperty:ALAssetPropertyDate];
                     //Dlog(@"date：%@",date);
                     NSArray *arr_date=[[NSString stringWithFormat:@"%@",date]   componentsSeparatedByString:@"+"];
                     
                     NSString *strAll;
                     UILabel *lab_content;
                     NSData *image_data=UIImageJPEGRepresentation( [chosenImage resize:CGSizeMake(Phone_Weight*2  , Phone_Height*2)],0.6 );
                     UIImage *image_New=[UIImage imageWithData:image_data];
                     //Dlog(@"1--%lu",image_data.length/1024);
                     strAll=[NSString stringWithFormat:@"采集人:%@\n采集时间:%@ 文件生成时间:%@\n",[[SelfInf_Singleton sharedInstance].dic_SelfInform objectForKey:@"uname"],[Function getSystemTimeNow],[arr_date objectAtIndex:0]];
                     lab_content=[Water_Mark Label_Freedom_Content:strAll  Choose_image:image_New];
                     UIImage *getImage=[Water_Mark TransFor_ChooseImage:image_New  Lab:[Water_Mark imageWithUIView:lab_content]];
                     //Dlog(@"2次 %lu",UIImageJPEGRepresentation(getImage,0.6).length/1000);
                     [arr_pic addObject:getImage];
                     [self showPicture];
                     strAll=nil;
                 }
                failureBlock:^(NSError *error) {
                }];

    }
    nav=nil;
    picker=nil;
}
- (void)image: (UIImage *) image didFinishSavingWithError: (NSError *) error contextInfo: (void *) contextInfo
{
    if(error != NULL){
        //Dlog(@"保存图片失败");
    }else{
        //Dlog(@"保存图片成功");
    }
}
-(void)Submit_reply//提交反馈
{
    if([Function isConnectionAvailable])
    {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.mode = MBProgressHUDModeIndeterminate;
        hud.labelText = @"加载中...";//加载提示语言
        
        if(app.isPortal)
        {
            self.urlString=[NSString stringWithFormat:@"%@%@",KPORTAL_URL,KNew_Reply];
        }
        else
        {
             self.urlString=[NSString stringWithFormat:@"%@%@",kBASEURL,KNew_Reply];
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
        
        [request setPostValue:str_retype forKey:@"retype"];
        [request setPostValue:tex_content.text forKey:@"recontent"];
        for (NSInteger i=0; i<arr_pic.count; i++)
        {//[Function Image_TransForm_Data: (UIImage *)[arr_pic objectAtIndex:i]]
            [request setData:UIImageJPEGRepresentation((UIImage *)[arr_pic objectAtIndex:i], 0.6)
                withFileName:@"T1.jpg"
              andContentType:@"image/jpeg"
                      forKey:[NSString stringWithFormat:@"fileList[%ld].file",(long)i]];
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
    //Dlog(@"%@",jsonString);
    SBJsonParser *parser = [[SBJsonParser alloc] init];
    NSDictionary *dict =[parser objectWithString: jsonString];
    if([[dict objectForKey:@"ret"]isEqualToString:@"0"])
    {
        self.delegate =(id) app.VC_more ;//vc
        [self.delegate Notify_Advice:@"反馈提交成功"];
        [self.navigationController popViewControllerAnimated:YES];
    }
    else
    {
        [SGInfoAlert showInfo:[dict objectForKey:@"message"]
                      bgColor:[[UIColor darkGrayColor] CGColor]
                       inView:self.view
                     vertical:0.5];
    }
    
}
//-(void)BigPic:(UIButton *)sender
//{
//    [self BigImageView:sender.tag-300];
//}
//-(void)BigImageView:(NSInteger)i
//{
//    UIImageView *imageview=[[UIImageView alloc]init];
//    imageview.image=[arr_pic objectAtIndex:i];
//    imageview.frame=self.view.frame;
//   
//    [view_imgBack addSubview:imageview];
//    imageview=nil;
//
//}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    [arr_pic removeAllObjects];
}

- (IBAction)Action_Content:(id)sender
{
    NoteViewController *noteVC=[[NoteViewController alloc]init];
    isContent=YES;
    noteVC.str_title=@"反馈内容";
    noteVC.str_content=tex_content.text;
    noteVC.isDetail=NO;
    [self.navigationController pushViewController:noteVC animated:YES];

}

- (IBAction)Action_Advice:(id)sender
{
    //Dlog(@"类型");
    isPhoto=NO;
    [self Type];
}

- (IBAction)Action_AddPic:(id)sender
{
    //Dlog(@"图片");
    isPhoto=YES;
    [self TakePhoto];
}

-(void)requestFinished:(ASIHTTPRequest *)request {
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

#pragma mark ---- presentView delegate method

- (void)presentViewDissmissAction {
    
    [[KGModal sharedInstance] closeAction:nil];
    
}
@end
