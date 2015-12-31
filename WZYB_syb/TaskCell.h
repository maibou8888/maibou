//
//  TaskCell.h
//  WZYB_syb
//
//  Created by wzyb on 14-7-14.
//  Copyright (c) 2014年 WZYB. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TaskCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *img_tsts;
@property (weak, nonatomic) IBOutlet UILabel *lab_content;
@property (weak, nonatomic) IBOutlet UILabel *people;
@property (weak, nonatomic) IBOutlet UILabel *date;
@property (weak, nonatomic) IBOutlet UILabel *lab_FromOrImply;
@property (weak, nonatomic) IBOutlet UILabel *label_totalTime;
@property (weak, nonatomic) IBOutlet UIImageView *imageView_tsts;
//我的指派添加一个参数
@property (weak, nonatomic) IBOutlet UIImageView *imageView_finish;

@end
