//
//  ForgetSecretViewController.h
//  WZYB_syb
//
//  Created by wzyb on 14-8-15.
//  Copyright (c) 2014年 WZYB. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ForgetSecretViewController : UIViewController<UITextFieldDelegate>
{
    NSInteger moment_status;
    NSInteger momentHeight;
    NSInteger height_20;
    NSInteger near_by_thisView;
    __weak IBOutlet UITextField *text_oldSecret;
    __weak IBOutlet UIView *view_background;
}
@property (nonatomic,retain)NSString *urlString;
@end
