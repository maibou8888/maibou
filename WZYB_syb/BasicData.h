//
//  BasicData.h
//  WZYB_syb
//
//  Created by wzyb on 14-7-3.
//  Copyright (c) 2014年 WZYB. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BasicData : NSObject
{
    NSMutableDictionary *dic_BasicData;//所有数据 要存表格里面 的 userlist selfInform productlist  masterlist
}
+ (BasicData *) sharedInstance;
@property(nonatomic,copy)  NSMutableDictionary *dic_BasicData;
@end
