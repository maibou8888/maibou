//
//  NotORCell.m
//  WZYB_syb
//
//  Created by wzyb on 14-9-1.
//  Copyright (c) 2014年 WZYB. All rights reserved.
//

#import "NotORCell.h"

@implementation NotORCell

- (void)awakeFromNib
{
    // Initialization code
    [self.lab_gaddress setNumberOfLines:2];
    [self.lab_gname setNumberOfLines:2];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
