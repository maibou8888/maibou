//
//  ChooseView.h
//  WZYB_syb
//
//  Created by wzyb on 15/9/10.
//  Copyright (c) 2015年 WZYB. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChooseView : UIView

+ (instancetype)defaultPopupView;

@property (strong, nonatomic) UITextField* numberTextField;
@property (strong, nonatomic) UITextView* remarkTextView;
@property (strong, nonatomic) UIButton* sureBtn;
@property (strong, nonatomic) UISwitch* switchBtn;
@property (weak, nonatomic) UIViewController* parentVC;

@end
