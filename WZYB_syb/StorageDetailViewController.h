//
//  StorageDetailViewController.h
//  WZYB_syb
//  产品库存明细视图控制器
//  Created by wzyb on 14-12-1.
//  Copyright (c) 2014年 WZYB. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StorageDetailViewController : UIViewController<UIScrollViewDelegate>
@property(nonatomic,strong)NSString *str_index_no;//产品表主键
@property(nonatomic,strong)NSString *str_unit;//单位
@end
