//
//  ChooseView.m
//  WZYB_syb
//
//  Created by wzyb on 15/9/10.
//  Copyright (c) 2015年 WZYB. All rights reserved.
//

#import "ChooseView.h"

@implementation ChooseView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        ChooseView *chooseView=[[[NSBundle mainBundle] loadNibNamed:@"ChooseView" owner:self options:nil] lastObject];
        [chooseView setFrame:frame];
        
        [self addSubview:chooseView];
    }
    return self;
}

-(void)awakeFromNib {
    //整体视图
    self.layer.borderWidth = 0.5;
    self.layer.cornerRadius = 4.0;
    self.layer.borderColor = [UIColor grayColor].CGColor;
    self.layer.masksToBounds = YES;
    
    //数量
    self.numberTF.layer.borderWidth = 0.5;
    self.numberTF.layer.borderColor = [UIColor grayColor].CGColor;
    
    //备注
    self.remarkTW.layer.borderWidth = 0.5;
    self.remarkTW.layer.borderColor = [UIColor grayColor].CGColor;
}

+ (instancetype)defaultPopupView{
    return [[ChooseView alloc]initWithFrame:CGRectMake(0, 0, 280, 280)];
}

@end
