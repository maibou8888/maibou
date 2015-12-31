//
//  MessageViewController.h
//  WZYB_syb
//
//  Created by wzyb on 14-6-25.
//  Copyright (c) 2014年 WZYB. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NavView.h"
#import "UnderLineLabel.h"
#import "MessageDetailViewController.h"
#import "BaseTableView.h"

@interface MessageViewController : BaseViewController<UITableViewDataSource,UITableViewDelegate,UIAlertViewDelegate,UIScrollViewDelegate,UITableViewEventDelegate>
{
    BaseTableView *tableView_message;//通知列表
    NSMutableDictionary *dictionary_data;//动态字典 通知数据加入 是否读过
    NSInteger mess_toal;//信息条数 总数
    BOOL isDelectAll;//是删除一个 还是全部  YES 全部
    NSTimer *timer;//定时器 定时调用 消息
    NSInteger indexRow;//删除的那行
    
    BOOL flagShuaxin;
    BOOL isFirstLoad;
    BOOL isFirstOpen;
}
@property (nonatomic, strong) UISwipeGestureRecognizer *leftSwipeGestureRecognizer;
@property (nonatomic, strong) UISwipeGestureRecognizer *rightSwipeGestureRecognizer;
@property(nonatomic,retain)NSString *titleString;
@property(nonatomic,retain)NSString *urlString;
@property(nonatomic,assign)NSInteger indexPath;
@end
