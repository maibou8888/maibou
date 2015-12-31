//
//  IsRead.h
//  WZYB_syb
//
//  Created by wzyb on 14-7-4.
//  Copyright (c) 2014年 WZYB. All rights reserved.
//

#import <Foundation/Foundation.h>

//@end
@interface IsRead : NSObject
{
    NSMutableArray *arr_isRead;//标记是否已读
}
+ (IsRead *) sharedInstance;
@property(nonatomic,copy) NSMutableArray *arr_isRead;
@end
