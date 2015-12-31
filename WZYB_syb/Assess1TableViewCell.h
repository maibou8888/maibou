//
//  Assess1TableViewCell.h
//  WZYB_syb
//
//  Created by wzyb on 14-7-29.
//  Copyright (c) 2014年 WZYB. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Assess1TableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *img_status;
@property (weak, nonatomic) IBOutlet UILabel *lab_type;
@property (weak, nonatomic) IBOutlet UILabel *lab_content;
@property (weak, nonatomic) IBOutlet UILabel *lab_date;
@property (weak, nonatomic) IBOutlet UILabel *lab_applyMoney;
@property (weak, nonatomic) IBOutlet UILabel *lab_assessNumb;
@property (weak, nonatomic) IBOutlet UILabel *personLabel;
@end
