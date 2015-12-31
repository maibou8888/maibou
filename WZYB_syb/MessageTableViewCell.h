//
//  MessageTableViewCell.h
//  WZYB_syb
//
//  Created by wzyb on 14-7-28.
//  Copyright (c) 2014年 WZYB. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MessageTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *imgView_Infomtype;//通知类型
@property (weak, nonatomic) IBOutlet UIImageView *img_isRead;//是否已读、
@property (weak, nonatomic) IBOutlet UIImageView *imageView_BigRead;//已阅大红戳
@property (weak, nonatomic) IBOutlet UIImageView *img_Background;//最后面的背景
@property (weak, nonatomic) IBOutlet UIImageView *showImageView;

@property (weak, nonatomic) IBOutlet UILabel *comeLabel;
@property (weak, nonatomic) IBOutlet UIImageView *timeImageView;
@property (weak, nonatomic) IBOutlet UILabel *lab_sendFromeWhom;
@property (weak, nonatomic) IBOutlet UILabel *lab_content;
@property (weak, nonatomic) IBOutlet UILabel *lab_sendTime;

@end
