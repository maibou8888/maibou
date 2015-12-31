//
//  ItemBrowseViewController.h
//  WZYB_syb
//
//  Created by wzyb on 15/6/24.
//  Copyright (c) 2015年 WZYB. All rights reserved.
//

#import "BaseViewController.h"

@interface ItemBrowseViewController : BaseViewController
@property (nonatomic , assign) NSInteger returnFlag;
@property (nonatomic , assign) NSInteger meterialFlag; //物料flag
@property (nonatomic , retain) NSString  *cIndexNumber;
@end
