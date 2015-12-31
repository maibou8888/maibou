//
//  AssessViewCell.h
//  WZYB_syb
//
//  Created by wzyb on 14-7-15.
//  Copyright (c) 2014年 WZYB. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AssessViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *lab_content;
@property (weak, nonatomic) IBOutlet UILabel *lab_type;
@property (weak, nonatomic) IBOutlet UILabel *lab_uname;
@property (weak, nonatomic) IBOutlet UILabel *lab_date;
@property (weak, nonatomic) IBOutlet UILabel *lab_section;//废弃掉了
@property (weak, nonatomic) IBOutlet UIImageView *img_status;
@property (weak, nonatomic) IBOutlet UILabel *lab_applyMoney;
@property (weak, nonatomic) IBOutlet UILabel *lab_assessNumb;
 

@end
