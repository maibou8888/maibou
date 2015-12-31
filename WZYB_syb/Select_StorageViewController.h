//
//  Select_StorageViewController.h
//  WZYB_syb
//  仓库查询视图控制器
//  Created by wzyb on 14-12-1.
//  Copyright (c) 2014年 WZYB. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QR_GetCustomer.h"
#import "ZBarSDK.h"
@interface Select_StorageViewController : UIViewController<ZBarReaderDelegate>
{
    ZbarCustomVC * reader;
}
@property (nonatomic,retain)QR_GetCustomer *qr_getCustomer;//二维码得到客户信息
@property(nonatomic,retain)NSString *titleString;
@end
