//
//  BaseTableView.h
//  WZYB_syb
//
//  Created by wzyb on 15-1-9.
//  Copyright (c) 2015年 WZYB. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EGORefreshTableHeaderView.h"

@class BaseTableView;
@protocol UITableViewEventDelegate <NSObject>
@optional

- (void)pullDown:(BaseTableView *)tableView;    //下拉

//numberOfRows
-(NSInteger)tableView:(BaseTableView *)tableView numberOfRowsInSection:(NSInteger)section;

//heightForRow
-(CGFloat)tableView:(BaseTableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;

//cellForRow
-(UITableViewCell *)tableView:(BaseTableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;

//didSelectForRow
-(void)tableView:(BaseTableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;

//editingStyle
- (void)tableView:(BaseTableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
                                              forRowAtIndexPath:(NSIndexPath *)indexPath;

@end

@interface BaseTableView : UITableView<EGORefreshTableDelegate,UITableViewDelegate,UITableViewDataSource>
{
    EGORefreshTableHeaderView *_refreshHeaderView; //上拉刷新
    BOOL _reloading;
    CGFloat _tableViewHeight;
}

@property(nonatomic,assign)id<UITableViewEventDelegate> eventDelegate;
@property(nonatomic,retain)NSArray* data;
@property(nonatomic,assign)BOOL showRefreshHeader;  //是否显示下拉刷新
@end
