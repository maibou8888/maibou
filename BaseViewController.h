//
//  BaseViewController.h
//  oc discuss
//  基类的视图控制器->1.0.4重新设计的基类
//  Created by wzyb on 15-1-6.
//  Copyright (c) 2015年 YLYL. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIViewExt.h"
#import "NavView.h"

@interface BaseViewController : UIViewController
{
    NSInteger moment_status;                         //状态栏高度
    NavView *nav_View;                               //导航栏
    UIImageView *imageView_Face;                     //背景图片
    NSTimer *baseTimer;
}
@property (nonatomic,retain) UIView *pushView;       //推送视图
@property (nonatomic,assign) BOOL showPushView; //是否显示pushView

 /**
 *  添加导航栏title
 *  @param navTitle 要显示的title
 *  @param flag     用来区分(flag为1的时候title左边没有向下的箭头，为2的时候则有乡下的箭头)
 */
- (void)addNavTItle:(NSString *)navTitle flag:(NSInteger)flag;

- (void)labelTapMethod;                              //点击label事件
- (void)Jpush_mention:(BOOL)isOpen;                  //是否弹出推送视图
- (void)pushViewOpenOrClose;                         //推送视图打开或关闭

@end
