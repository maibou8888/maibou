//
//  DataAnalyseViewController.h
//  WZYB_syb
//  企业分析
//  Created by wzyb on 14-8-19.
//  Copyright (c) 2014年 WZYB. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DocumentViewController.h"
@interface DataAnalyseViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>
{
    NSInteger moment_status;
    NSMutableArray *arr_List;//数据表
}
@property(nonatomic,assign)BOOL isOnTabbar;//YES 在tabbar上
@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) UITableView *myTableView;

@end
