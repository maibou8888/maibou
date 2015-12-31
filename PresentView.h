//
//  PresentView.h
//  WZYB_syb
//
//  Created by wzyb on 15-3-30.
//  Copyright (c) 2015年 WZYB. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PresentViewDelegate
@optional
- (void)presentViewDissmissAction;          //点击消失的委托回调
@end

@interface PresentView : UIView

@property(assign,nonatomic)id<PresentViewDelegate> presentViewDelegate;
+(PresentView*)getSingle;  //单例
@end
