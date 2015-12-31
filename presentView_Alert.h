//
//  presentView_Alert.h
//  WZYB_syb
//
//  Created by wzyb on 15/7/13.
//  Copyright (c) 2015年 WZYB. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PresentViewDelegate_Alert
@optional
- (void)presentViewDissmissAction;          //点击消失的委托回调
@end

@interface presentView_Alert : UIView

@property(assign,nonatomic)id<PresentViewDelegate_Alert> presentViewDelegate;
+(presentView_Alert*)getSingle;  //单例
@end
