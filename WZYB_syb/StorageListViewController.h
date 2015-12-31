//
//  StorageListViewController.h
//  WZYB_syb
//  产品库存列表控制器
//  Created by wzyb on 14-12-1.
//  Copyright (c) 2014年 WZYB. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StorageListViewController : UIViewController<UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate>
@property(strong,nonatomic)NSString *str_pcode;//页面传值
@property(strong,nonatomic)NSString *str_isFromQR;// 1  来自 QR  存在pcode
@end
