//
//  WZYB_TwoSectionViewController.h
//  WZYB_syb
//
//  Created by wzyb on 14-11-12.
//  Copyright (c) 2014年 WZYB. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
@interface WZYB_TwoSectionViewController : UIViewController
{
    NSInteger moment_status;
    AppDelegate *app;
}
-(void)All_Init:(NSString *)title;
-(void)btn_Action:(UIButton *)btn;
@end
