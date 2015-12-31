//
//  SelfInf_Singleton.h
//  WZYB_syb
//
//  Created by wzyb on 14-7-3.
//  Copyright (c) 2014年 WZYB. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SelfInf_Singleton : NSObject
{
    NSMutableDictionary *dic_SelfInform;//SelfInfom
}
+ (SelfInf_Singleton *) sharedInstance;
@property(nonatomic,copy)   NSMutableDictionary *dic_SelfInform;
@end