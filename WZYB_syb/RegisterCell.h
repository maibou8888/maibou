//
//  RegisterCell.h
//  WZYB_syb
//
//  Created by wzyb on 14-7-2.
//  Copyright (c) 2014年 WZYB. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RegisterCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *imageView_Head;
@property (weak, nonatomic) IBOutlet UILabel *label_CompanyName;//客户类型
@property (weak, nonatomic) IBOutlet UILabel *label_PersonName;//联系电话
@property (weak, nonatomic) IBOutlet UILabel *label_Date;
@property (weak, nonatomic) IBOutlet UILabel *label_adress;
@property (weak, nonatomic) IBOutlet UILabel *label_BusinessName;
@property (weak, nonatomic) IBOutlet UILabel *label_Scale;
@property (weak, nonatomic) IBOutlet UILabel *localLabel;
@property (weak, nonatomic) IBOutlet UILabel *personLabel;

@end
