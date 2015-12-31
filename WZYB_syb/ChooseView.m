//
//  ChooseView.m
//  WZYB_syb
//
//  Created by wzyb on 15/9/10.
//  Copyright (c) 2015年 WZYB. All rights reserved.
//

#import "ChooseView.h"
#import "UIViewController+LewPopupViewController.h"
#import "LewPopupViewAnimationSpring.h"


#define TextColor [UIColor colorWithRed:29 / 255.0 green:182 / 255.0 blue:235 / 255.0 alpha:1]
#define BackColor [UIColor colorWithRed:233 / 255.0 green:233 / 255.0 blue:233 / 255.0 alpha:1]

@implementation ChooseView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        //整体视图
        self.layer.borderWidth = 0.5;
        self.layer.cornerRadius = 4.0;
        self.layer.borderColor = [UIColor grayColor].CGColor;
        self.layer.masksToBounds = YES;
        self.backgroundColor = [UIColor whiteColor];

        //标题
        UILabel* titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(98, 8, 85, 21)];
        titleLabel.text = @"请输入数量";
        titleLabel.textColor = TextColor;
        titleLabel.font = [UIFont boldSystemFontOfSize:17.0];
        [self addSubview:titleLabel];

        //标题分割线
        UIImageView* imageLine = [[UIImageView alloc] initWithFrame:CGRectMake(0, 40, 280, 1)];
        imageLine.backgroundColor = TextColor;
        [self addSubview:imageLine];

        //底部分割线
        UIImageView* imageLineB = [[UIImageView alloc] initWithFrame:CGRectMake(0, 230, 280, 1)];
        imageLineB.backgroundColor = BackColor;
        [self addSubview:imageLineB];

        //底部纵向分割线
        UIImageView* imageLineBH = [[UIImageView alloc] initWithFrame:CGRectMake(140, 241, 1, 30)];
        imageLineBH.backgroundColor = BackColor;
        [self addSubview:imageLineBH];

        //数量
        UILabel* numberLabel = [[UILabel alloc] initWithFrame:CGRectMake(8, 55, 30, 16)];
        numberLabel.font = [UIFont systemFontOfSize:13.0];
        numberLabel.text = @"数量:";
        [self addSubview:numberLabel];

        //备注
        UILabel* remarkLabel = [[UILabel alloc] initWithFrame:CGRectMake(8, 95, 30, 16)];
        remarkLabel.font = [UIFont systemFontOfSize:13.0];
        remarkLabel.text = @"备注:";
        [self addSubview:remarkLabel];

        //赠品
        UILabel* giftLabel = [[UILabel alloc] initWithFrame:CGRectMake(8, 185, 30, 16)];
        giftLabel.font = [UIFont systemFontOfSize:13.0];
        giftLabel.text = @"赠品";
        [self addSubview:giftLabel];

        //数量文本
        _numberTextField = [[UITextField alloc] initWithFrame:CGRectMake(55, 50, 207, 30)];
        _numberTextField.backgroundColor = BackColor;
        _numberTextField.keyboardType = UIKeyboardTypeDecimalPad;
        _numberTextField.borderStyle = UITextBorderStyleNone;
        _numberTextField.layer.borderWidth = 0.5;
        _numberTextField.layer.borderColor = [UIColor grayColor].CGColor;
        [self addSubview:_numberTextField];

        //备注文本
        _remarkTextView = [[UITextView alloc] initWithFrame:CGRectMake(55, 95, 207, 75)];
        _remarkTextView.textColor = [UIColor grayColor];
        _remarkTextView.backgroundColor = BackColor;
        _remarkTextView.layer.borderWidth = 0.5;
        _remarkTextView.layer.borderColor = [UIColor grayColor].CGColor;
        [self addSubview:_remarkTextView];

        //赠品开关
        _switchBtn = [[UISwitch alloc] initWithFrame:CGRectMake(55, 185, 51, 31)];
        [self addSubview:_switchBtn];

        //取消
        UIButton* cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        cancelBtn.frame = CGRectMake(40, 235, 60, 40);
        cancelBtn.titleLabel.font = [UIFont boldSystemFontOfSize:15.0];
        [cancelBtn setTitleColor:TextColor forState:UIControlStateNormal];
        [cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
        [cancelBtn addTarget:self action:@selector(cancelAction) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:cancelBtn];

        //确定
        _sureBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _sureBtn.frame = CGRectMake(180, 235, 60, 40);
        _sureBtn.titleLabel.font = [UIFont boldSystemFontOfSize:15.0];
        [_sureBtn setTitleColor:TextColor forState:UIControlStateNormal];
        [_sureBtn setTitle:@"确定" forState:UIControlStateNormal];
        [self addSubview:_sureBtn];
    }
    return self;
}

+ (instancetype)defaultPopupView
{
    return [[ChooseView alloc] initWithFrame:CGRectMake(0, 0, 280, 280)];
}

- (void)cancelAction {
    self.switchBtn.on = 0;
    self.numberTextField.text = @"";
    self.remarkTextView.text = @"";
    [_parentVC lew_dismissPopupViewWithanimation:[LewPopupViewAnimationSpring new]];
}

@end
