//
//  ModiLogViewController.m
//  WZYB_syb
//
//  Created by wzyb on 15-4-22.
//  Copyright (c) 2015年 WZYB. All rights reserved.
//

#import "ModiLogViewController.h"
#import "MessageTableViewCell.h"
#import "MessageDetailViewController.h"

@interface ModiLogViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    UITableView  *_modTableView;
    NSString *LogCountStr;
}
@end

@implementation ModiLogViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //title
    [self addNavTItle:@"操作记录" flag:1];
    
    //back Button
    UIButton *btn_back=[UIButton buttonWithType:UIButtonTypeCustom];
    btn_back.frame=CGRectMake(0, moment_status, 60, 44);
    btn_back.backgroundColor=[UIColor clearColor];
    [btn_back addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    [btn_back setBackgroundImage:[UIImage imageNamed:@"btn_color6.png"] forState:UIControlStateHighlighted];
    [btn_back setTitle:@"< 返回" forState:UIControlStateNormal];
    [btn_back setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    btn_back.titleLabel.font=[UIFont systemFontOfSize:15];
    [nav_View.view_Nav  addSubview:btn_back];
    
    //tableView init
    _modTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, 320, Phone_Height-64) style:UITableViewStylePlain];
    _modTableView.separatorColor = [UIColor clearColor];
    _modTableView.delegate = self;
    _modTableView.dataSource = self;
    [self.view addSubview:_modTableView];
    
    LogCountStr = [self.dataDic objectForKey:@"LogCount"];
}

#pragma mark ---- private method
- (void)back {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark ---- UITableView delegate and dataSource method
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(isPad) return 100.0;
    else      return 120.0;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return LogCountStr.integerValue;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MessageTableViewCell *cell=(MessageTableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"MessageTableViewCell"];
    if(cell==nil)
    {
        NSArray *nib ;
        if(isPad)
        {
            nib= [[NSBundle mainBundle] loadNibNamed:@"MessageTableViewCell_ipad" owner:[MessageTableViewCell class] options:nil];
        }
        else
        {
            nib= [[NSBundle mainBundle] loadNibNamed:@"MessageTableViewCell" owner:[MessageTableViewCell class] options:nil];
        }
        
        cell = (MessageTableViewCell *)[nib objectAtIndex:0];
        cell.contentView.backgroundColor = [UIColor clearColor];
    }
    cell.img_isRead.image = ImageName(@"cell_clerk.png");
    
    cell.comeLabel.left-=15;
    cell.timeImageView.left-=15;
    cell.lab_sendFromeWhom.left-=15;
    cell.lab_content.left-=15;
    cell.lab_sendTime.left-=15;
    
    cell.img_isRead.width = 12.0;
    cell.img_isRead.left = 22.0;
    cell.showImageView.hidden = YES;
    cell.lab_content.width = 275;
    cell.lab_sendFromeWhom.text = [[[self.dataDic objectForKey:@"LogList"] objectAtIndex:indexPath.row]objectForKey:@"uname"];
    cell.lab_content.text = [[[self.dataDic objectForKey:@"LogList"] objectAtIndex:indexPath.row]objectForKey:@"memo"];
    cell.lab_sendTime.text = [[[self.dataDic objectForKey:@"LogList"] objectAtIndex:indexPath.row]objectForKey:@"ins_date"];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    __block MessageDetailViewController *messageVC=[[MessageDetailViewController alloc]init];
    NSDictionary * dic=[[self.dataDic objectForKey:@"LogList"] objectAtIndex:indexPath.row];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            dispatch_async(dispatch_get_main_queue(), ^{
            messageVC.msg_Notice=[[MessageNotice alloc]init];
            messageVC.msg_Notice.str_uname=[dic objectForKey:@"uname"];
            messageVC.msg_Notice.str_content=[dic objectForKey:@"memo"];
            messageVC.msg_Notice.str_Date=[dic objectForKey:@"ins_date"];
            [self.navigationController pushViewController:messageVC animated:YES];
            messageVC=nil;
        });
    });
}
@end
