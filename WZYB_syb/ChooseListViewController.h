//
//  ChooseListViewController.h
//  WZYB_syb
//  选择清单视图控制器
//  Created by wzyb on 14-7-23.
//  Copyright (c) 2014年 WZYB. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChooseCell.h"
#import "ContactPeople.h"
#import "SearchCoreManager.h"

@interface ChooseListViewController : UIViewController<UITableViewDelegate,UITableViewDataSource,UIAlertViewDelegate,UISearchBarDelegate>
{
    NSInteger moment_status;
    UITableView *tableView;
    NSMutableArray *arr_List;//数据表
    BOOL isSearching;//是否正在搜索 YES 是
    UIImageView *imageView_Face;
    //BOOL  isEmpty;//检索结果是否为空 YES是
}
@property (strong, nonatomic) NSMutableArray* allTableData;//测试
@property (strong, nonatomic) NSMutableArray* filteredTableData;//测试

@property (nonatomic,strong) UISearchBar *searchBar;
@property (nonatomic,strong) NSMutableDictionary *contactDic;
@property (nonatomic,strong) NSMutableArray *searchByName;
@property (nonatomic,strong) NSMutableArray *searchByPhone;
@property (nonatomic,strong) NSString *str_isFromQR;//是否是扫描条形码进来的
@property (nonatomic,strong) NSString *str_pcode;//传值传过来的pcode
@property (nonatomic,assign) NSInteger returnFlag;
@property (nonatomic,assign) NSString *cIndexNumber;

@end
