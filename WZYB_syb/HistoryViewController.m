//
//  HistoryViewController.m
//  WZYB_syb
//
//  Created by wzyb on 15-3-26.
//  Copyright (c) 2015年 WZYB. All rights reserved.
//

#import "HistoryViewController.h"
#import "HistoryCell.h"
#import "AppDelegate.h"

@interface HistoryViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    AppDelegate *app;
    NSInteger moment_status;
    NSMutableArray *mutArray;
    UITableView *historyTableView;
    CGFloat cellHeight;
    NSIndexPath *myIndexPath;
}
@end

@implementation HistoryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    mutArray = [NSMutableArray array];
    if([Function judgeFileExist:HISTORY Kind:Library_Cache])
    {
        NSDictionary *dic=[Function ReadFromFile:HISTORY Kind:Library_Cache];
        mutArray = [dic objectForKey:HISTORY];
        [historyTableView reloadData];
    }
    
    [self _initSubView];
}

#pragma mark ---- private method
- (void)_initSubView {
    if(StatusBar_System>0)
        moment_status=20;
    else moment_status=0;
    cellHeight = 0.0;
    app=(AppDelegate*)[[UIApplication sharedApplication]delegate];
    [self.view addSubview: [nav_View NavView_Title1:@"历史"]];
    
    UIButton *btn=[UIButton buttonWithType:UIButtonTypeCustom];
    btn.backgroundColor=[UIColor clearColor];
    [btn addTarget:self action:@selector(_backAction) forControlEvents:UIControlEventTouchUpInside];
    [nav_View.view_Nav  addSubview:btn];
    [btn setBackgroundImage:[UIImage imageNamed:@"btn_color6.png"] forState:UIControlStateHighlighted];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    btn.titleLabel.font=[UIFont systemFontOfSize:15];
    btn.frame=CGRectMake(0, moment_status, 60, 44);
    btn.tag=buttonTag-1;
    [btn setTitle:@"< 返回" forState:UIControlStateNormal];
    
    UIButton *btnDelete=[UIButton buttonWithType:UIButtonTypeCustom];
    btnDelete.backgroundColor=[UIColor clearColor];
    [btnDelete addTarget:self action:@selector(deleteAction) forControlEvents:UIControlEventTouchUpInside];
    [nav_View.view_Nav  addSubview:btnDelete];
    [btnDelete setBackgroundImage:[UIImage imageNamed:@"btn_color6.png"] forState:UIControlStateHighlighted];
    [btnDelete setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    btnDelete.titleLabel.font=[UIFont systemFontOfSize:15];
    btnDelete.frame=CGRectMake(260, moment_status, 60, 44);
    btnDelete.tag=buttonTag-1;
    [btnDelete setTitle:@"清空" forState:UIControlStateNormal];
    
    [self Is_Nothing];
    
    if (mutArray.count) {
        historyTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, 320, Phone_Height-64)
                                                        style:UITableViewStylePlain];
        historyTableView.separatorColor = [UIColor orangeColor];
        historyTableView.delegate = self;
        historyTableView.dataSource = self;
        [self.view addSubview:historyTableView];
    }
}

- (void)_backAction {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)deleteAction {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"清空全部内容" message:@"" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:@"取消", nil];
    alertView.tag = 100;
    [alertView show];
}

-(void)Is_Nothing
{
    if(mutArray.count==0)
    {
        [self.view addSubview:imageView_Face];
    }
    else
    {
        [imageView_Face removeFromSuperview];
    }
}

#pragma  mark ---- UITableView delegate and datasource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return mutArray.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    HistoryCell *cell=(HistoryCell*)[tableView dequeueReusableCellWithIdentifier:@"HistoryCell"];
    if(cell==nil)
    {
        NSArray *nib;
        if(isPad)
        {
            nib= [[NSBundle mainBundle] loadNibNamed:@"HistoryCell_ipad" owner:[HistoryCell class] options:nil];
        }
        else
        {
            nib= [[NSBundle mainBundle] loadNibNamed:@"HistoryCell" owner:[HistoryCell class] options:nil];
        }
        cell = (HistoryCell *)[nib objectAtIndex:0];
        cell.contentView.backgroundColor = [UIColor clearColor];
    }
    cell.backgroundColor=[UIColor clearColor];
    cell.textLabelCustom.text = [mutArray objectAtIndex:indexPath.row];
//    CGSize size = [Function labelSize:cell.textLabelCustom text:[mutArray objectAtIndex:indexPath.row]];
//    cellHeight = size.height+10.0;
//    cell.textLabelCustom.height = cellHeight;
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    myIndexPath = indexPath;
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"选取当前内容" message:@"" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:@"取消", nil];
    [alertView show];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 70;
}

#pragma mark ---- UIAlertView delegate method
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        if (alertView.tag == 100) {
            NSString *str1= [Function achieveThe_filepath:HISTORY Kind:Library_Cache];
            [Function Delete_TotalFileFromPath:str1];
            [Function creatTheFile:HISTORY Kind:Library_Cache];
            [Function WriteToFile:HISTORY File:@"" Kind:Library_Cache];
            mutArray = nil;
            historyTableView.hidden = YES;
            [self Is_Nothing];
            return;
        }
        app.takeText = [mutArray objectAtIndex:myIndexPath.row];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
