//
//  UnderLineLabel.h
//  CustomLabelWithUnderLine
//  WZYB_syb
//
//  Created by wzyb on 14-8-18.
//  Copyright (c) 2014年 WZYB. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UnderLineLabel.h"
@interface UnderLineLabel : UILabel
{
    UIControl *_actionView;
    UIColor *_highlightedColor;
    BOOL _shouldUnderline;
}

@property (nonatomic, retain) UIColor *highlightedColor;
@property (nonatomic, assign) BOOL shouldUnderline;

- (void)setText:(NSString *)text andCenter:(CGPoint)center;
- (void)addTarget:(id)target action:(SEL)action;
@end
 