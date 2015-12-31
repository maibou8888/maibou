//
//  Advance_Search.h
//  WZYB_syb
//
//  Created by wzyb on 14-9-24.
//  Copyright (c) 2014年 WZYB. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Advance_Search : NSObject
{
    NSMutableArray *arr_search;//标记是否已读
}
+ (Advance_Search *) sharedInstance;
@property(nonatomic,copy) NSMutableArray*arr_search;
@end
