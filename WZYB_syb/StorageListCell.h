//
//  StorageListCell.h
//  WZYB_syb
//
//  Created by wzyb on 14-12-1.
//  Copyright (c) 2014年 WZYB. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StorageListCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *lab_brand;
@property (weak, nonatomic) IBOutlet UILabel *lab_name;
@property (weak, nonatomic) IBOutlet UILabel *lab_storage_name;//这个现在用来显示型号
@property (weak, nonatomic) IBOutlet UILabel *lab_storage_Count;

@end
