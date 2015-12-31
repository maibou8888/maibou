//
//  ChooseCell.h
//  WZYB_syb
//
//  Created by wzyb on 14-7-23.
//  Copyright (c) 2014年 WZYB. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChooseCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *lab_pname;//品名
@property (weak, nonatomic) IBOutlet UILabel *lab_pcode;//编号
@property (weak, nonatomic) IBOutlet UILabel *lab_price;//单价
@property (weak, nonatomic) IBOutlet UILabel *lab_poo;//产地
@property (weak, nonatomic) IBOutlet UILabel *lab_branded;//品牌
@property (weak, nonatomic) IBOutlet UILabel *lab_ptype;
@property (strong, nonatomic) IBOutlet UILabel *unitLabel; //型号
@property (strong, nonatomic) IBOutlet UIButton *itemNumbtn;

@end
