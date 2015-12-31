//
//  SendMessageViewController.h
//  WZYB_syb
//  发送应用信息视图控制器
//  Created by wzyb on 14-10-9.
//  Copyright (c) 2014年 WZYB. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NoteViewController.h"
@interface SendMessageViewController : UIViewController<UIAlertViewDelegate>
{
    NSInteger moment_status;
    __weak IBOutlet UIButton *btn_content;
    __weak IBOutlet UIView *view_back;
    __weak IBOutlet UITextField *tex_peo;
    __weak IBOutlet UITextField *tex_tel;
    __weak IBOutlet UITextField *tex_content;
    BOOL isFirstOpen;//YES 是第一次打开
}
@property(nonatomic,strong)NSString* str_peo;
@property(nonatomic,strong)NSString* str_tel;
@property(nonatomic,strong)NSString* str_mtype;
@property(nonatomic,strong)NSString* str_index_no;
@property(nonatomic,strong)NSString* str_belong;
@property(nonatomic,strong)NSString* str_gbelong;

- (IBAction)Action_Content:(id)sender;
@end
