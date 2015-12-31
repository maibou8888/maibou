//
//  SubmitOrderTableViewCell.h
//  WZYB_syb
//
//  Created by wzyb on 14-7-28.
//  Copyright (c) 2014年 WZYB. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SubmitOrderTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *lab_gname;
@property (weak, nonatomic) IBOutlet UILabel *lab_gcode;
@property (weak, nonatomic) IBOutlet UILabel *lab_should;
@property (weak, nonatomic) IBOutlet UILabel *lab_real;
@property (weak, nonatomic) IBOutlet UILabel *lab_isInstead;
@property (weak, nonatomic) IBOutlet UILabel *lab_count_number;//没有数量 暂时传折扣
@property (weak, nonatomic) IBOutlet UILabel *lab_time;
@property (weak, nonatomic) IBOutlet UIImageView *img_isInstead;
@property (weak, nonatomic) IBOutlet UIImageView *img_exe_sts;
@property (weak, nonatomic) IBOutlet UIImageView *img_am_pm;
@property (weak, nonatomic) IBOutlet UILabel *personLabel;
@property (weak, nonatomic) IBOutlet UILabel *offLineLabel;

@property (strong, nonatomic) IBOutlet UILabel *shouldLabel;
@property (strong, nonatomic) IBOutlet UILabel *realLabel;
@property (strong, nonatomic) IBOutlet UILabel *codeLabel;
@property (strong, nonatomic) IBOutlet UILabel *takeLabel;
@property (strong, nonatomic) IBOutlet UILabel *ctsLabel;
@end
