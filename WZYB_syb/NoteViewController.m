//
//  NoteViewController.m
//  WZYB_syb
//
//  Created by wzyb on 14-8-1.
//  Copyright (c) 2014年 WZYB. All rights reserved.
//

#import "NoteViewController.h"
#import "AppDelegate.h"
#import "HistoryViewController.h"
@interface NoteViewController ()
{
    AppDelegate *app;
    NSMutableArray *tempMutArray;
}

@end

@implementation NoteViewController

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
}
-(void)viewWillAppear:(BOOL)animated
{
    app.str_temporary=@"";
    textView_Edit=[[UITextView alloc]init ];
    textView_Edit.frame= CGRectMake(10, moment_status+44+10,Phone_Weight-20, 44*5);
    textView_Edit.backgroundColor=[UIColor whiteColor];
    [self.view addSubview:textView_Edit];
    textView_Edit.editable=YES;
    textView_Edit.textAlignment=NSTextAlignmentLeft;
    textView_Edit.textColor=[UIColor blackColor];
    textView_Edit.font=[UIFont systemFontOfSize:17];
    textView_Edit.layer.borderColor = [UIColor lightGrayColor].CGColor;
    textView_Edit.layer.borderWidth =0.5;
    textView_Edit.layer.cornerRadius =3.0;
    textView_Edit.delegate=self;
    
    UILabel *holderLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, textView_Edit.bottom+10, Phone_Weight, 30)];
    if ([Function StringIsNotEmpty:self.placeHolderString] && ![self.placeHolderString isEqualToString:@"-1"]) {
        holderLabel.text = [NSString stringWithFormat:@"填写提示：%@",self.placeHolderString];
        holderLabel.textColor = [UIColor grayColor];
    }
    [self.view addSubview:holderLabel];
    
    if(self.isDetail || self.editFlag)
    {
        textView_Edit.editable=NO;
    }
    else
    {
        [textView_Edit becomeFirstResponder];
    }
    textView_Edit.text=self.str_content;
    if (app.takeText.length) {
        textView_Edit.text=app.takeText;
        app.takeText = @"";
    }
    if(![Function isBlankString:self.str_keybordType]&&[self.str_keybordType isEqualToString:@"0"])
    {//如果 self.str_keybordType  ==0弹起数字键盘 纯数字键盘//UIKeyboardTypeNamePhonePad 电话键盘，也支持输入人名
        textView_Edit.keyboardType=UIKeyboardTypeNumberPad;
    }
    else if(![Function isBlankString:self.str_keybordType]&&[self.str_keybordType isEqualToString:@"2"])
    {//金额 带小数点
        textView_Edit.keyboardType=UIKeyboardTypeDecimalPad;  //   数字键盘 有数字和小数点;
    }else if (self.keyboardFlag) {
        textView_Edit.keyboardType=UIKeyboardTypeAlphabet;
    }
}
-(void)All_Init
{
    app=(AppDelegate *)[[UIApplication sharedApplication]delegate];
    if(StatusBar_System>0)
        moment_status=20;
    else moment_status=0;
    NavView *nav_View=[[NavView alloc]init];
    [self.view addSubview: [nav_View NavView_Title3:self.str_title]];
    tempMutArray = [NSMutableArray array];
    for(NSInteger i=0;i<3;i++)
    {
        if(self.isDetail)
        {
            if ((i == 1) || i == 2) {
                continue;
            }
        }
        UIButton *btn=[UIButton buttonWithType:UIButtonTypeCustom];
        btn.backgroundColor=[UIColor clearColor];
        [btn addTarget:self action:@selector(btn_Action:) forControlEvents:UIControlEventTouchUpInside];
        [nav_View.view_Nav  addSubview:btn];
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        btn.titleLabel.font=[UIFont systemFontOfSize:14];
        if(i==0)
        {
            btn.frame=CGRectMake(0, moment_status, 60, 44);
            btn.tag=buttonTag-1;
            [btn setTitle:@"< 返回" forState:UIControlStateNormal];
        }
        else if(i==1)
        {
            if(!self.editFlag){
                btn.frame=CGRectMake(Phone_Weight-44, moment_status, 44, 44);
                btn.tag=buttonTag+2;
                [btn setTitle:@"完成" forState:UIControlStateNormal];
            }
        }
        else if(i==2 && !self.editFlag)
        {
            if (![self.str_keybordType isEqualToString:@"0"] && ![self.str_keybordType isEqualToString:@"2"]) {
                btn.frame=CGRectMake(Phone_Weight-75, moment_status+7, 30, 30);
                btn.tag=buttonTag+3;
                [btn setTitle:@"历史" forState:UIControlStateNormal];
            }
        }
    }
    //背景图案
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"AddNewClerkBacground"]]];
}
-(void)btn_Action:(id)sender
{
    [textView_Edit resignFirstResponder];
    UIButton *btn=(UIButton *)sender;
    if(btn.tag==buttonTag-1)//返回
    {
        if(self.isDetail)
        {
            [self.navigationController popViewControllerAnimated:YES];
        }
        else
        {
            if( [self.str_keybordType isEqualToString:@"2"]||[self.str_keybordType isEqualToString:@"0"] )
            {
                if([NavView  validateMobile:textView_Edit.text])
                {
                    [self mention];
                }
                else
                {
                    [SGInfoAlert showInfo:@"输入不合法,不可返回"
                                  bgColor:[[UIColor darkGrayColor] CGColor]
                                   inView:self.view
                                 vertical:0.5];
                }
            }
            else
            {
                 [self mention];
            }
        }
    }
    else if(btn.tag==buttonTag+2)
    {
        if( [self.str_keybordType isEqualToString:@"2"]||[self.str_keybordType isEqualToString:@"0"] )
        {
            if([NavView  validateMobile:textView_Edit.text])
            {
                app.str_temporary=textView_Edit.text;
                [self _addDataToHistory];
                [self.navigationController popViewControllerAnimated:YES];
            }
            else
            {
                [SGInfoAlert showInfo:@"输入不合法,请重新输入"
                              bgColor:[[UIColor darkGrayColor] CGColor]
                               inView:self.view
                             vertical:0.5];
            }
        }
        else
        {
            app.str_temporary=textView_Edit.text;
            [self _addDataToHistory];
            [self.navigationController popViewControllerAnimated:YES];
        }
    }else if (btn.tag==buttonTag+3) {
        //历史
        HistoryViewController *historyVC = [HistoryViewController new];
        [self.navigationController pushViewController:historyVC animated:YES];
    }
}

- (void)_addDataToHistory {
    if([Function judgeFileExist:HISTORY Kind:Library_Cache])
    {
        NSDictionary *dic=[Function ReadFromFile:HISTORY Kind:Library_Cache];
        if (dic.count) {
            tempMutArray = [dic objectForKey:HISTORY];
        }
    }
    
    if([Function StringIsNotEmpty:app.str_temporary]) {
        [tempMutArray addObject:app.str_temporary];
        NSDictionary *dic_data=[NSDictionary dictionaryWithObjectsAndKeys:tempMutArray,HISTORY, nil];
        NSString *str1= [Function achieveThe_filepath:HISTORY Kind:Library_Cache];
        [Function Delete_TotalFileFromPath:str1];
        [Function creatTheFile:HISTORY Kind:Library_Cache];
        [Function WriteToFile:HISTORY File:dic_data Kind:Library_Cache];
    }
}
#pragma textViewDelegate
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView;
{
    textView.returnKeyType=UIReturnKeyDone;
    return YES;
}
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        [self mention];
        return NO;
    }
    return YES;
}
-(void)textViewDidEndEditing:(UITextView *)textView
{
    //Dlog(@"%@",self.str_keybordType);
    //Dlog(@"%@",textView.text);
}
-(void)mention
{
     if([textView_Edit.text isEqualToString:@""]||[Function isBlankString:textView_Edit.text])
     {
         UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"编辑内容为空,确认要返回吗" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定",nil];
         [alert show];
         alert=nil;
     }
     else
     {
         app.str_temporary=textView_Edit.text;
         [self.navigationController popViewControllerAnimated:YES];
     }
    
}
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex==1)
    {//确定
        app.str_temporary=@"";
        [self.navigationController popViewControllerAnimated:YES];
    }
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
