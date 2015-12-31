//
//  LocationViewController.h
//  WZYB_syb
//  部门员工视图控制器
//  Created by wzyb on 14-6-27.
//  Copyright (c) 2014年 WZYB. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import "NavView.h"
#import "LocationPersonViewController.h"
@interface LocationViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,UIAlertViewDelegate,UISearchBarDelegate,UIScrollViewDelegate,MFMessageComposeViewControllerDelegate>
{
    NSInteger moment_status;
    NSDictionary *dic_UserList;//部门员工列表数据
    NSArray *arr_H1;
    UITableView *tableView_Inform;
    NSMutableArray *arr_Key;//记住出现了哪些key
    NSMutableDictionary *dic_add;
    NSInteger Index;//索引
    NSMutableArray *arr_Inform;//cvalue clabel
    NSMutableArray *array_Data_back;//需要返回的数据
    
    BOOL isSelectOne;//YES 单选  NO  多选
    BOOL isSearching;//是否正在搜索
    NSString *str_tel;//拨打的电话号;
    NSString *str_redname;
    NSString *auth;
    NSString *gbelongto;
    NSInteger section;//计数
    NSInteger index_num;
    NSInteger  index_section;
    UIImageView *imageView_Face;
}
@property(nonatomic,retain)NSString *str_from;// 1---从轨迹进入 2----任务交办 3---后续审批人/当前审批人 只有从任务交办进入才能多选 1和3都是单选

 
@property (nonatomic,retain) UISearchBar *searchBar;

@property (nonatomic,retain) NSMutableDictionary *contactDic;
@property (nonatomic,retain) NSMutableArray *searchByName;
@property (nonatomic,retain) NSMutableArray *searchByPhone;
@property (nonatomic,retain) NSString *titleString;
@property (nonatomic,retain) NSString *fromLeftStr;
@end
