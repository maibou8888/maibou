//
//  FileViewController.h
//  WZYB_syb
//  //企业文档视图控制器
//  Created by wzyb on 14-7-1.
//  Copyright (c) 2014年 WZYB. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NavView.h"
#import "FileTableViewCell.h"
#import "DocumentViewController.h"
@interface FileViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,UIAlertViewDelegate>
{
    NSInteger moment_status;
    UITableView *tableView_File;//办公文档列表
    NSArray *array_header;//tableview cell Header
    NSArray *array_cellName;//cell name
    NSArray *arr_H14;//useful
    NSDictionary *dic_all_Data;//所有数据
    NSMutableArray *arr_Key;//记住出现了哪些key
    UIImageView *imageView_Face;
    NSString *str_doc_name;
    NSString *str_doc_path;
    NSString *str_index_no;
    NSString *str_Index;
}

@property(nonatomic,retain)NSString *titleString;
@property(nonatomic,retain)NSString *urlString;
@end
