//
//  DairyCell.h
//  WZYB_syb
//
//  Created by wzyb on 15-1-12.
//  Copyright (c) 2015年 WZYB. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DairyCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *dairyImage;
@property (weak, nonatomic) IBOutlet UILabel *topText;
@property (weak, nonatomic) IBOutlet UILabel *bottomText;
@property (weak, nonatomic) IBOutlet UIButton *addBtn;

@end
