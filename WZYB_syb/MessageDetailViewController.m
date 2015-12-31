//
//  MessageDetailViewController.m
//  WZYB_syb
//
//  Created by wzyb on 14-6-27.
//  Copyright (c) 2014年 WZYB. All rights reserved.
//

#import "MessageDetailViewController.h"
#import "AppDelegate.h"
@interface MessageDetailViewController ()
{
    AppDelegate *app;
}
@end

@implementation MessageDetailViewController
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
    if(StatusBar_System>0)
        moment_status=20;
    else moment_status=0;
    combox_height_thisView=combox_height;
    near_by_thisView=Near_By;
    NavView *nav_View=[[NavView alloc]init];
    [self.view addSubview: [nav_View NavView_Title1:@"查看信息详细"]];
    //背景图案
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"AddNewClerkBacground"]]];
    //
    UIButton *btn_back=[UIButton buttonWithType:UIButtonTypeCustom];//签到按钮
    btn_back.frame=CGRectMake(0, moment_status, 60, 44);
    btn_back.backgroundColor=[UIColor clearColor];
    btn_back.tag=buttonTag+4;
    [btn_back addTarget:self action:@selector(btn_Action:) forControlEvents:UIControlEventTouchUpInside];
    [nav_View.view_Nav  addSubview:btn_back];
    
    [btn_back setBackgroundImage:[UIImage imageNamed:@"btn_color6.png"] forState:UIControlStateHighlighted];
    [btn_back setTitle:@"< 返回" forState:UIControlStateNormal];
    [btn_back setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    btn_back.titleLabel.font=[UIFont systemFontOfSize:15];
    //
    scrollView_Back=[[UIScrollView alloc]initWithFrame:CGRectMake(0, moment_status+44, Phone_Weight, Phone_Height-moment_status-44)];
    scrollView_Back.backgroundColor=[UIColor clearColor];
    [self.view addSubview:scrollView_Back];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self All_Init];
}
-(void)viewWillAppear:(BOOL)animated
{
    //Dlog(@"%@/n%@/n%@",self.msg_Notice.str_index_no,self.msg_Notice.str_content,self.msg_Notice.str_Date);
    [self CreateMessageViewDetail];
}
-(void)CreateMessageViewDetail
{
    float Near=10;
    if(isPad)Near=50;
    NSInteger momentHeight=20;
    for(NSInteger i=0;i<3;i++)
    {
        UIImageView *view_back=[[UIImageView alloc]initWithFrame:CGRectMake(Near, momentHeight, (Phone_Weight-Near*2), combox_height_thisView)];
        view_back.backgroundColor=[UIColor clearColor];
        if (i==0) {
            view_back.image=[UIImage imageNamed:@"set_header@2X.png"];
        }
        else if(i==2)
        {
            view_back.image=[UIImage imageNamed:@"set_bottom@2X.png"];
        }
        else
        {
            view_back.image=[UIImage imageNamed:@"set_middle@2X.png"];
        }
         //*/
        UILabel *lab_content=[[UILabel alloc]initWithFrame:CGRectMake(0, 0, view_back.frame.size.width, view_back.frame.size.height)];
        lab_content.backgroundColor=[UIColor clearColor];
        [lab_content setNumberOfLines:0];
        //lab_content.textAlignment=NSTextAlignmentCenter;
        UIFont *font = [UIFont systemFontOfSize:app.Font];
        CGSize size = CGSizeMake(lab_content.frame.size.width,2000);
        if(i==0)
        {
            lab_content.text=[NSString stringWithFormat:@" %@",self.msg_Notice.str_content];
        }
        else if(i==1)
        {
            lab_content.text=[NSString stringWithFormat:@" 发送人:%@",self.msg_Notice.str_uname];
        }
        else
        {
            lab_content.text=[NSString stringWithFormat:@" 发送时间:%@",self.msg_Notice.str_Date];
        }
        
        //6.计算UILabel字符显示的实际大小
        CGSize labelsize = [lab_content.text sizeWithFont:font constrainedToSize:size lineBreakMode:NSLineBreakByWordWrapping];
        
        //7.重设UILabel实例的frame
        lab_content.frame=CGRectMake(lab_content.frame.origin.x+5,lab_content.frame.origin.x,lab_content.frame.size.width-10, labelsize.height+combox_height_thisView);
        lab_content.font= [UIFont systemFontOfSize:app.Font];
        [view_back addSubview:lab_content];
        view_back.frame=CGRectMake(Near,momentHeight, (Phone_Weight-Near*2),lab_content.frame.size.height);
        momentHeight+=view_back.frame.size.height;
        [scrollView_Back addSubview:view_back];
    }
    if(momentHeight>=scrollView_Back.frame.size.height+40)
    {
        scrollView_Back.contentSize=CGSizeMake(0, momentHeight);
    }
    else
    {
        scrollView_Back.contentSize=CGSizeMake(0, scrollView_Back.frame.size.height);
    }
}
-(void)btn_Action:(id)sender
{
    UIButton *btn=(UIButton *)sender;
    if(btn.tag==buttonTag+4)//返回
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
    
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
