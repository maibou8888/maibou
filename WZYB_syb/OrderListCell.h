//
//  OrderListCell.h
//  WZYB_syb
//
//  Created by wzyb on 14-7-2.
//  Copyright (c) 2014年 WZYB. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OrderListCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *label_Name;
@property (weak, nonatomic) IBOutlet UILabel *label_Unit_price;
@property (weak, nonatomic) IBOutlet UILabel *label_totalNum;
@property (weak, nonatomic) IBOutlet UILabel *label_TotalMoney;//实收
@property (weak, nonatomic) IBOutlet UILabel *label_shoudMoney;//应收
@property (weak, nonatomic) IBOutlet UILabel *label_index;
@property (weak, nonatomic) IBOutlet UIImageView *img_arrow;
@property (weak, nonatomic) IBOutlet UIImageView *img_isRealOrShould;
@property (weak, nonatomic) IBOutlet UILabel *lab_isReal;//应收或者实收标签

@end
