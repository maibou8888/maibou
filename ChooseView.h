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
@property (strong, nonatomic) IBOutlet UITextField *numberTF;
@property (strong, nonatomic) IBOutlet UITextView *remarkTW;
@property (strong, nonatomic) IBOutlet UISwitch *switchBtn;
@property (strong, nonatomic) IBOutlet UIButton *cancelBtn;
@property (strong, nonatomic) IBOutlet UIButton *sureBtn;

@end
