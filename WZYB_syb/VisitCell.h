//
//  VisitCell.h
//  WZYB_syb
//
//  Created by wzyb on 14-7-2.
//  Copyright (c) 2014年 WZYB. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VisitCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *label_CompanyName;
@property (weak, nonatomic) IBOutlet UILabel *label_workStatus;
@property (weak, nonatomic) IBOutlet UILabel *userLabel;

@property (weak, nonatomic) IBOutlet UILabel *label_SignUp_time;
@property (weak, nonatomic) IBOutlet UILabel *label_SignOut_time;
@property (weak, nonatomic) IBOutlet UILabel *label_during;
@property (weak, nonatomic) IBOutlet UIImageView *imageView_status;
@property (weak, nonatomic) IBOutlet UIImageView *imageView_tap;


@end
