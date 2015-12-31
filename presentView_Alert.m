//
//  presentView_Alert.m
//  WZYB_syb
//
//  Created by wzyb on 15/7/13.
//  Copyright (c) 2015年 WZYB. All rights reserved.
//

#import "presentView_Alert.h"
static presentView_Alert * presentView = nil;
@implementation presentView_Alert

+(presentView_Alert*)getSingle
{
    if (presentView != nil)
    {
        return presentView;
    }
    static dispatch_once_t lock;
    
    dispatch_once(&lock, ^{ presentView = [[self alloc] initWithFrame:CGRectMake(0, 0, 280, 206)]; });
    
    return presentView;
}

-(instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
//        self.backgroundColor = [UIColor colorWithRed:204/255.0 green:204/255.0 blue:204/255.0 alpha:1];

        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 284, 210)];
        imageView.image = ImageName(@"alert1.png");
        [self addSubview:imageView];

        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(57, 191, 166, 16);
        button.titleLabel.font = [UIFont systemFontOfSize:13.0];
        [button setTitle:@"我知道了" forState:UIControlStateNormal];
        [button setBackgroundImage:ImageName(@"knowBack.png") forState:UIControlStateNormal];
        [button setTitleColor:[UIColor colorWithRed:255/255.0 green:24/255.0 blue:71/255.0 alpha:1]
                     forState:UIControlStateNormal];
        [button addTarget:self action:@selector(dissmissAction) forControlEvents:UIControlEventTouchUpInside];
        
        [button.layer setMasksToBounds:YES];
        [button.layer setCornerRadius:5.0];
        button.layer.borderColor = [UIColor redColor].CGColor;
        button.layer.borderWidth = 1;
        [self addSubview:button];
    }
    return self;
}

- (void)dissmissAction {
    [self.presentViewDelegate presentViewDissmissAction];
}

@end
