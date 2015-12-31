//
//  PresentView_loc.h
//  WZYB_syb
//
//  Created by wzyb on 15-3-30.
//  Copyright (c) 2015年 WZYB. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PresentViewDelegate_loc
@optional
- (void)presentViewDissmissAction_loc;          //点击消失的委托回调
@end

@interface PresentView_loc : UIView

@property(assign,nonatomic)id<PresentViewDelegate_loc> presentViewDelegate;
+(PresentView_loc*)getSingle;  //单例

@end
