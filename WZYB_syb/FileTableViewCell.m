//
//  FileTableViewCell.m
//  WZYB_syb
//
//  Created by wzyb on 14-9-2.
//  Copyright (c) 2014年 WZYB. All rights reserved.
//

#import "FileTableViewCell.h"

@implementation FileTableViewCell

- (void)awakeFromNib
{
    self.lab_title.textAlignment=NSTextAlignmentCenter;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
