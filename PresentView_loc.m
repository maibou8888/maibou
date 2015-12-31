//
//  PresentView_loc.m
//  WZYB_syb
//
//  Created by wzyb on 15-3-30.
//  Copyright (c) 2015年 WZYB. All rights reserved.
//

#import "PresentView_loc.h"
static PresentView_loc * presentView = nil;
@implementation PresentView_loc

+(PresentView_loc*)getSingle
{
    if (presentView != nil)
    {
        return presentView;
    }
    static dispatch_once_t lock;
    
    dispatch_once(&lock, ^{ presentView = [[self alloc] initWithFrame:CGRectMake(0, 0, 240, 250)]; });
    
    return presentView;
}

-(instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithRed:204/255.0 green:204/255.0 blue:204/255.0 alpha:1];
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 240, 240)];
        imageView.image = ImageName(@"show.png");
        [self addSubview:imageView];
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(37, 224, 166, 22);
        button.titleLabel.font = [UIFont systemFontOfSize:14.0];
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
    [self.presentViewDelegate presentViewDissmissAction_loc];
}

@end
