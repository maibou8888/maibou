//
//  SearchCell.h
//  WZYB_syb
//
//  Created by wzyb on 14-8-4.
//  Copyright (c) 2014年 WZYB. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SearchCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *lab_uname;                //用户名
@property (weak, nonatomic) IBOutlet UILabel *lab_section;              //部门
@property (weak, nonatomic) IBOutlet UILabel *lab_tel;                  //电话
@property (weak, nonatomic) IBOutlet UIImageView *imgView_head;         //用户图片
@property (weak, nonatomic) IBOutlet UIImageView *sectionImg;           //部门图片
@property (weak, nonatomic) IBOutlet UIImageView *telImg;               //电话图片
@property (weak, nonatomic) IBOutlet UIImageView *imgView_isSeleted;    //选择图片

@end
