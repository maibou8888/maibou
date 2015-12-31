//
//  Select_StorageViewController.m
//  WZYB_syb
//
//  Created by wzyb on 14-12-1.
//  Copyright (c) 2014年 WZYB. All rights reserved.
//

#import "Select_StorageViewController.h"
#import "StorageListViewController.h"
#import "AppDelegate.h"
#import "KGModal.h"
#import <QuartzCore/QuartzCore.h>
#import "PresentView.h"
@interface Select_StorageViewController ()<zbarNewViewDelegate,PresentViewDelegate>
{
    NSInteger moment_status;
    AppDelegate *app;
}
@property (weak, nonatomic) IBOutlet UIButton *btn_QR;
@property (weak, nonatomic) IBOutlet UIButton *btn_List;
@property (weak, nonatomic) IBOutlet UIImageView *tem_Background;

@end

@implementation Select_StorageViewController
- (IBAction)QR_Click:(id)sender
{
    [self CreateTheQR];
}
- (IBAction)List_Click:(id)sender
{
    StorageListViewController *store=[[StorageListViewController alloc]init];
    store.str_pcode=nil;
    store.str_isFromQR=@"0";
    [self.navigationController pushViewController:store animated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self All_init];
    self.btn_QR.center=CGPointMake(Phone_Weight/2, 44+moment_status+44);
    self.btn_List.center=CGPointMake(self.btn_QR.center.x, self.btn_QR.center.y+44+20);
    [self.btn_QR.layer setMasksToBounds:YES];
    [self.btn_QR.layer setCornerRadius:5.0];
    [self.btn_List.layer setMasksToBounds:YES];
    [self.btn_List.layer setCornerRadius:5.0];
    self.tem_Background.frame=CGRectMake(Phone_Weight-self.tem_Background.frame.size.width, Phone_Height-self.tem_Background.frame.size.height, self.tem_Background.frame.size.width, self.tem_Background.frame.size.height);
    self.view.backgroundColor=[UIColor  colorWithPatternImage:[UIImage imageNamed:@"cell_message_background.png"]];
}
-(void)All_init
{
    app=(AppDelegate *)[[UIApplication sharedApplication]delegate];
    if(StatusBar_System>0)
        moment_status=20;
    else moment_status=0;
    NavView *nav_View=[[NavView alloc]init];
    [self.view addSubview: [nav_View NavView_Title1:self.titleString]];
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
    reader = [ZbarCustomVC getSingle];
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
    
    [reader CreateTheQR:self]; //1.0.4 扫描条形码 用这个就可以了   不用判断iOS7
}

- (void)zbarDismissAction {
    
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
    StorageListViewController *store=[[StorageListViewController alloc]init];
    store.str_pcode=codeString;
    store.str_isFromQR=@"1";
    [self.navigationController pushViewController:store animated:YES];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissModalViewControllerAnimated:YES];
}
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
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
        StorageListViewController *store=[[StorageListViewController alloc]init];
        store.str_pcode=result;
        store.str_isFromQR=@"1";
        [self.navigationController pushViewController:store animated:YES];
    }];
}
-(void)btn_Action:(id)sender
{
    UIButton *btn=(UIButton *)sender;
    if(btn.tag==buttonTag-1)//返回
    {
        [self.navigationController popViewControllerAnimated:YES];
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
