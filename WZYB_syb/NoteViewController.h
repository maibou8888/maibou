//
//  NoteViewController.h
//  WZYB_syb
//
//  Created by wzyb on 14-8-1.
//  Copyright (c) 2014年 WZYB. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NoteViewController : UIViewController<UITextViewDelegate,UIAlertViewDelegate>
{
    NSInteger moment_status;
    UITextView *textView_Edit;
}
@property(nonatomic,strong)NSString *str_title;//标题
@property(nonatomic,assign)BOOL isDetail;//是否查看详细  YES 是
@property(nonatomic,strong)NSString *str_content;//文本查看详细
@property(nonatomic,strong)NSString *str_keybordType;//动态项目类型（0:数字，1:文本，2:金额）
@property(nonatomic,assign)NSInteger editFlag;
@property(nonatomic,strong)NSString *placeHolderString;
@property(nonatomic,assign)NSInteger keyboardFlag;
@end
