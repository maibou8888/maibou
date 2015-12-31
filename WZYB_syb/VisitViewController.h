//
//  VisitViewController.h
//  WZYB_syb
//  签到巡访视图控制器
//  Created by wzyb on 14-6-27.
//  Copyright (c) 2014年 WZYB. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NavView.h"
#import "SignInViewController.h"
#import "NotQRViewController.h"
#import "ZBarSDK.h"
#import "VisitCell.h"
#import "AdvancedSearchViewController.h"
@interface VisitViewController : UIViewController<UITableViewDelegate,UITableViewDataSource,UIActionSheetDelegate,ZBarReaderDelegate,UIAlertViewDelegate>
{
    NSInteger moment_status;
    UITableView *tableView_Visit;//巡访列表
    NSArray *arr_VistData;//列表数据数组
    UIImageView *imageView_Face;
    NSString *str_auth;
    ZbarCustomVC * reader;
}

@property (strong , nonatomic) NSString* qRUrl;//解析的结果（可能是url）
@end
