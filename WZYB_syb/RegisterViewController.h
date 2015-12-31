//
//  RegisterViewController.h
//  WZYB_syb
//  新客户视图控制器
//  Created by wzyb on 14-6-27.
//  Copyright (c) 2014年 WZYB. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AddNewClerkOrRivalViewController.h"
@interface RegisterViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,MyDelegate_AddClerkOrRival>////一定要遵守代理
{
    NSInteger moment_status;
    UITableView *tableView_Register;//客户登记列表
    NSMutableArray *arr_Customer;//新客户data
    NSArray *arr_Fighter;//对手data
    NSArray *arr_H12;//客户类型
}
@property(nonatomic,assign)BOOL isRival;//默认是新客户--->NO  YES 是竞争对手
@property(nonatomic,retain)NSString *titleString;
@end
