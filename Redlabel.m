//
//  Redlabel.m
//  WZYB_syb
//
//  Created by wzyb on 15-2-2.
//  Copyright (c) 2015年 WZYB. All rights reserved.
//

#import "Redlabel.h"

@implementation Redlabel

-(instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.textColor = [UIColor whiteColor];
        self.backgroundColor = [UIColor redColor];
        self.font = [UIFont systemFontOfSize:13.0];
        self.textAlignment = NSTextAlignmentCenter;
        self.layer.borderColor   = [UIColor redColor].CGColor;
        self.layer.borderWidth   = 0.1;
        self.layer.cornerRadius  = 8.0;
        self.layer.masksToBounds = YES;
        self.hidden = YES;
    }
    return self;
}

@end
