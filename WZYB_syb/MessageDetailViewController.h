//
//  MessageDetailViewController.h
//  WZYB_syb
//  查看信息详细视图控制器
//  Created by wzyb on 14-6-27.
//  Copyright (c) 2014年 WZYB. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NavView.h"
@interface MessageDetailViewController : UIViewController<UIScrollViewDelegate>
{
    NSInteger moment_status;
    NSInteger combox_height_thisView;
    NSInteger near_by_thisView;
    UIScrollView *scrollView_Back;
}
@property(nonatomic,retain)MessageNotice *msg_Notice;//消息通知


@end
