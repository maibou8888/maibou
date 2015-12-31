//
//  StorageListCell.m
//  WZYB_syb
//
//  Created by wzyb on 14-12-1.
//  Copyright (c) 2014年 WZYB. All rights reserved.
//

#import "StorageListCell.h"

@implementation StorageListCell

- (void)awakeFromNib {
    // Initialization code
    
    self.backgroundColor=[UIColor colorWithPatternImage:[UIImage imageNamed:@"cell_message_background.png"]];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
