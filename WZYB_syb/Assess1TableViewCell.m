//
//  Assess1TableViewCell.m
//  WZYB_syb
//
//  Created by wzyb on 14-7-29.
//  Copyright (c) 2014年 WZYB. All rights reserved.
//

#import "Assess1TableViewCell.h"

@implementation Assess1TableViewCell

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
