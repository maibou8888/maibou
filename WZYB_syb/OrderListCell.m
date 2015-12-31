//
//  OrderListCell.m
//  WZYB_syb
//
//  Created by wzyb on 14-7-2.
//  Copyright (c) 2014年 WZYB. All rights reserved.
//

#import "OrderListCell.h"

@implementation OrderListCell

- (void)awakeFromNib
{
    // Initialization code
    self.img_arrow.image=[UIImage imageNamed:@"cell_right_arrow.png"];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
