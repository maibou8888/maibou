//
//  UIActionSheetViewController.h
//  WZYB_syb
//
//  Created by wzyb on 14-7-31.
//  Copyright (c) 2014年 WZYB. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIActionSheetViewController : UIViewController
{
    NSInteger moment_status;
    NSMutableArray *sectionName;//选择类型
    UIScrollView *scrollView_Back;
    NSInteger momentHeight;//当前高度
    NSInteger combox_height_thisView;
    NSInteger near_by_thisView;
    BOOL isBack;//是返回吗 YES;是
    NSMutableArray *arr_btn;//加入按钮
}
@property(nonatomic,strong)NSString *str_title;
//@property(nonatomic,strong)NSArray *arr_sectionName;
@property(nonatomic,strong)NSString *str_H;//是哪种  如果是H9则是从审批走来
@property(nonatomic,strong)NSString *str_tdefault;//满意,基本满意,不满意 格式字符串
@property(nonatomic,assign)BOOL isOnlyLabel;//只要clabel
@property(nonatomic,assign)BOOL isSuper;//是否是超级搜索
@property(nonatomic,assign)NSInteger searchListFlag;
@property(nonatomic,assign)NSInteger editFlag;
@end
