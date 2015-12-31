//
//  QuickCell.h
//  WZYB_syb
//
//  Created by wzyb on 15-1-9.
//  Copyright (c) 2015年 WZYB. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QuickCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIButton *firstButton;
@property (weak, nonatomic) IBOutlet UIButton *secondButton;
@property (weak, nonatomic) IBOutlet UIButton *thirdButton;
@property (weak, nonatomic) IBOutlet UIButton *fourthButton;

@property (weak, nonatomic) IBOutlet UILabel *firstLabel;
@property (weak, nonatomic) IBOutlet UILabel *secondLabel;
@property (weak, nonatomic) IBOutlet UILabel *thirdLabel;
@property (weak, nonatomic) IBOutlet UILabel *fourthLabel;

@property (weak, nonatomic) IBOutlet UIButton *firstBackBtn;
@property (weak, nonatomic) IBOutlet UIButton *secondBackBtn;
@property (weak, nonatomic) IBOutlet UIButton *thirdBackBtn;
@property (weak, nonatomic) IBOutlet UIButton *forthBackBtn;
@end
