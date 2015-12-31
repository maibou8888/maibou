//
//  AssessViewCell.m
//  WZYB_syb
//
//  Created by wzyb on 14-7-15.
//  Copyright (c) 2014年 WZYB. All rights reserved.
//

#import "AssessViewCell.h"

@implementation AssessViewCell

- (void)awakeFromNib
{
    self.lab_assessNumb.adjustsFontSizeToFitWidth=YES;
    self.lab_assessNumb.textAlignment=NSTextAlignmentCenter;
    self.lab_type.adjustsFontSizeToFitWidth=YES;
    self.lab_type.textAlignment=NSTextAlignmentCenter;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
