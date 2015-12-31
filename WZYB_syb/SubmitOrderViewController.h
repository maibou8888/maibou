//
//  SubmitOrderViewController.h
//  WZYB_syb
//  我的订单视图控制器
//  Created by wzyb on 14-6-27.
//  Copyright (c) 2014年 WZYB. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NavView.h"

@interface SubmitOrderViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,UIActionSheetDelegate,ZBarReaderDelegate>
{
    NSInteger moment_status;
    UITableView *tableView_Submit;//订单上报提交
    NSMutableArray *arr_ListData;//存储列表数据
    UIImageView *imageView_Face;
    NSString *str_auth;
    ZbarCustomVC * reader;
}

@property(nonatomic,retain)NSString *str_qr_url;//获取二维码串
@property(nonatomic,retain)NSString *titleString;
@end
