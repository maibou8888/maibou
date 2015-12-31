//
//  AdviceViewController.h
//  WZYB_syb
//  问题反馈视图控制器
//  Created by wzyb on 14-7-2.
//  Copyright (c) 2014年 WZYB. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NavView.h"
#import "MRZoomScrollView.h"
@protocol MyDelegate_Advice <NSObject>
@optional
-(void)Notify_Advice:(NSString *)msg;
@end

@interface AdviceViewController : UIViewController<UITextViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIActionSheetDelegate,UIGestureRecognizerDelegate, UIAlertViewDelegate >
{
    NSInteger moment_status;
    float momentHeight;
    UIButton *button_pic;//贴图；
    UIButton *button_submit;//提交
    NSMutableArray *arr_pic;//图片集
    UIImage *chosenImage;//做显示在self.view 上的image
    BOOL isPhoto;//YES 照片 NO  类型
    BOOL isCamera;
    NSString *str_retype;//反馈类型
    UIView *view_imgBack;//放大图片背景
    BOOL isOpenBigPic;//大图是否打开 YES 打开则屏蔽其他按钮
    BOOL isBack;//是否 返回 YES 是
//------------xib
    __weak IBOutlet UIScrollView *scrollView;
    __weak IBOutlet UIButton *btn_content;
    __weak IBOutlet UIButton *btn_advice;
    __weak IBOutlet UIButton *btn_addPic;
    
    __weak IBOutlet UITextField *tex_content;
    __weak IBOutlet UITextField *tex_advice;
    BOOL isContent;//是不是在编辑文本 YES 是
}
@property(weak,nonatomic)id< MyDelegate_Advice > delegate;
@property (nonatomic, retain) MRZoomScrollView  *zoomScrollView;
- (IBAction)Action_Content:(id)sender;
- (IBAction)Action_Advice:(id)sender;
- (IBAction)Action_AddPic:(id)sender;

@property(nonatomic,retain)NSString *titleString;
@property(nonatomic,retain)NSString *urlString;
@end
