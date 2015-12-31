//
//  SecretViewController.h
//  WZYB_syb
//  修改密码视图控制器
//  Created by wzyb on 14-8-15.
//  Copyright (c) 2014年 WZYB. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SecretViewController : UIViewController<UITextFieldDelegate>
{
    NSInteger moment_status;
    float momentHeight;
    NSInteger near_by_thisView;
    //---------xib
    __weak IBOutlet UIView *view_background;
    __weak IBOutlet UITextField *tex_Old;
    __weak IBOutlet UITextField *tex_New;
    __weak IBOutlet UITextField *tex_Review;
    NSInteger index_row;//设置编辑行索引 1 2 3
}

- (IBAction)Action_EditTextField:(id)sender;

@end
