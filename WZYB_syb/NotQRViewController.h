//
//  NotQRViewController.h
//  WZYB_syb
//  我的收藏/终端查询视图控制器
//  Created by wzyb on 14-9-1.
//  Copyright (c) 2014年 WZYB. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NotORCell.h"
@interface NotQRViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate>
{
    NSInteger moment_status;
    BOOL isSearching;//是否正在检索 YES 是
    BOOL isSave;//是否是收藏  YES 是
    UITableView *tableView;
    NSArray *arr_CustomerList;
    NSMutableArray *arr_SaveList;//收藏终端信息列表 动态变化的
    UIImageView *imageView_Face;
}
@property (nonatomic,strong)NSString *str_From;//从哪个页面来的  1 VisitVC
@property (nonatomic,assign)NSInteger returnFlag;
@property (nonatomic,retain) UISearchBar *searchBar;
@property (nonatomic,retain) NSMutableDictionary *contactDic;
@property (nonatomic,retain) NSMutableArray *searchByName;
@property (nonatomic,retain) NSMutableArray *searchByPhone;
@end
