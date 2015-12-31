//
//  RootViewController.h
//  WZYB_syb
//
//  Created by wzyb on 14-6-5.
//  Copyright (c) 2014年 WZYB. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TabBarViewController.h"
#import "ForgetSecretViewController.h"
#import "SDWebImageDownloaderDelegate.h"
#import "NewTabbarViewController.h"
#import "LeftViewController.h"
#import "RightViewController.h"
#import "MMDrawerController.h"

@interface RootViewController : UIViewController<UITextFieldDelegate,UITabBarControllerDelegate,SDWebImageDownloaderDelegate>
{
    NSInteger moment_status_bar;                             //状态栏高度
    TabBarViewController *tabBar;                      //tabbar控制器
    
    __weak IBOutlet UIButton *btn_Login;
    __weak IBOutlet UIButton *btn_forgetSecret;
    __weak IBOutlet UITextField *textField_Account;
    __weak IBOutlet UITextField *textField_Secret;
    __weak IBOutlet UILabel *lab_CompanyTitle;         //最上面云领亿联字体

    BOOL isSelect;
    BOOL isSelectCode;
    NSString *str_url_version;
    BOOL Again_request;                                //YES 第二次
    NSString *urlString;
}
- (IBAction)Action_FindBack:(id)sender;                //忘记密码Btn
- (IBAction)To_term:(id)sender;                        //应用协议
- (IBAction)select:(UIButton *)sender;                 //勾选对号

@end
