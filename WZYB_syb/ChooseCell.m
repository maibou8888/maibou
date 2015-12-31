//
//  ChooseCell.m
//  WZYB_syb
//
//  Created by wzyb on 14-7-23.
//  Copyright (c) 2014年 WZYB. All rights reserved.
//

#import "ChooseCell.h"

@implementation ChooseCell

- (void)awakeFromNib
{
    self.itemNumbtn.layer.cornerRadius  = 4.0;
    self.itemNumbtn.layer.masksToBounds = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
